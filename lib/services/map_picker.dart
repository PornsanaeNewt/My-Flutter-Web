import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String? initialAddress;

  const MapPickerScreen({Key? key, this.initialPosition, this.initialAddress})
    : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? mapController;
  LatLng selectedPosition = const LatLng(13.736717, 100.523186);
  String selectedAddress = '';
  bool isLoading = false;
  bool showAddressCard = true;

  @override
  void initState() {
    super.initState();

    // 💡 แก้ไข: การใช้ .toDouble() ถูกเพิ่มเข้ามาในคำสั่งก่อนหน้าแล้ว
    if (kIsWeb) {
      html.window.navigator.geolocation
          .getCurrentPosition()
          .then((position) {
            final double lat = position.coords!.latitude!.toDouble();
            final double lng = position.coords!.longitude!.toDouble();
            setState(() {
              selectedPosition = LatLng(lat, lng);
            });
            _getAddressFromLatLng(selectedPosition);
          })
          .catchError((e) {
            print('Error getting location: $e');
          });
    }

    if (widget.initialPosition != null) {
      selectedPosition = widget.initialPosition!;
      if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
        selectedAddress = widget.initialAddress!;
      } else {
        _getAddressFromLatLng(selectedPosition);
      }
    } else {
      // ถ้าไม่มีตำแหน่งเริ่มต้น ให้แปลงตำแหน่ง default
      _getAddressFromLatLng(selectedPosition);
    }
  }

  // ✅ ปรับปรุงฟังก์ชันแปลง LatLng เป็นที่อยู่
  Future<void> _getAddressFromLatLng(LatLng position) async {
    // ป้องกันการเรียกซ้ำถ้ากำลังโหลดอยู่
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      // ✅ เพิ่ม timeout และ error handling
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง');
        },
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String fullAddress = _buildThaiAddress(place, position);

        setState(() {
          selectedAddress = fullAddress;
        });

        print(' Address found: $fullAddress');
      } else {
        // ✅ ถ้าไม่มีข้อมูลที่อยู่ ให้ใช้พิกัดแทน
        setState(() {
          selectedAddress =
              'พิกัด: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      print(' Error getting address: $e');

      // ✅ แยกประเภท error
      String errorMessage;
      String fallbackAddress =
          'พิกัด: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';

      if (e.toString().contains('Service not available')) {
        errorMessage =
            'บริการแผนที่ไม่พร้อมใช้งาน กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
      } else if (e.toString().contains('IO_ERROR')) {
        errorMessage = 'ไม่สามารถเชื่อมต่อบริการได้ กรุณาลองใหม่อีกครั้ง';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
      } else {
        errorMessage = 'ไม่สามารถดึงข้อมูลที่อยู่ได้';
      }

      setState(() {
        selectedAddress = fallbackAddress;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'ลองใหม่',
              textColor: Colors.white,
              onPressed: () => _getAddressFromLatLng(position),
            ),
          ),
        );
      }
    }

    setState(() => isLoading = false);
  }

  // ✅ ฟังก์ชันสร้างที่อยู่
  String _buildThaiAddress(Placemark place, LatLng position) {
    List<String> addressParts = [];

    if (place.name != null &&
        place.name!.isNotEmpty &&
        place.name != 'Unnamed Road') {
      addressParts.add(place.name!);
    }

    if (place.street != null &&
        place.street!.isNotEmpty &&
        place.street != place.name) {
      addressParts.add(place.street!);
    }

    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }

    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(
        place.locality!.contains('ตำบล')
            ? place.locality!
            : 'ตำบล${place.locality!}',
      );
    }

    if (place.subAdministrativeArea != null &&
        place.subAdministrativeArea!.isNotEmpty) {
      addressParts.add(
        place.subAdministrativeArea!.contains('อำเภอ')
            ? place.subAdministrativeArea!
            : 'อำเภอ${place.subAdministrativeArea!}',
      );
    }

    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      addressParts.add(
        place.administrativeArea!.contains('จังหวัด')
            ? place.administrativeArea!
            : 'จังหวัด${place.administrativeArea!}',
      );
    }

    if (place.postalCode != null &&
        place.postalCode!.isNotEmpty &&
        place.postalCode != '00000') {
      addressParts.add(place.postalCode!);
    }

    String fullAddress = addressParts.join(', ');

    if (fullAddress.isEmpty || fullAddress.length < 10) {
      fullAddress =
          'พิกัด: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    }

    return fullAddress;
  }

  // ดึงตำแหน่งปัจจุบัน
  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      if (kIsWeb) {
        final position =
            await html.window.navigator.geolocation.getCurrentPosition();
        final double lat = position.coords!.latitude!.toDouble();
        final double lng = position.coords!.longitude!.toDouble();

        LatLng newPosition = LatLng(lat, lng);
        setState(() => selectedPosition = newPosition);

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16.0),
        );

        await _getAddressFromLatLng(newPosition);
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          LatLng newPosition = LatLng(position.latitude, position.longitude);
          setState(() => selectedPosition = newPosition);

          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(newPosition, 16.0),
          );

          await _getAddressFromLatLng(newPosition);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ ดึงตำแหน่งปัจจุบันสำเร็จ'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ กรุณาอนุญาตการเข้าถึงตำแหน่ง'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถดึงตำแหน่งได้: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map เต็มหน้าจอ
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: selectedPosition,
              zoom: 16.0,
            ),
            onTap: (LatLng position) {
              setState(() => selectedPosition = position);
              _getAddressFromLatLng(position);
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: selectedPosition,
                draggable: true,
                onDragEnd: (LatLng position) {
                  setState(() => selectedPosition = position);
                  _getAddressFromLatLng(position); // ✅ แปลงที่อยู่เมื่อลากหมุด
                },
                infoWindow: InfoWindow(
                  title: '📍 ตำแหน่งที่เลือก',
                  snippet:
                      selectedAddress.isEmpty
                          ? 'กำลังโหลด...'
                          : selectedAddress.length > 50
                          ? '${selectedAddress.substring(0, 50)}...'
                          : selectedAddress,
                ),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top Control Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  // ปุ่มกลับ
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Title
                  const Expanded(
                    child: Text(
                      'เลือกตำแหน่ง',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ ปุ่มยืนยัน - ส่งทั้งพิกัดและที่อยู่กลับไป
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF689F38),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      onPressed:
                          selectedAddress.isNotEmpty
                              ? () {
                                // 💡 แก้ไข: ลบ 'position': selectedPosition ออก เพื่อป้องกัน Clash บน Web
                                Navigator.pop(context, {
                                  'address':
                                      selectedAddress, // ✅ ที่อยู่ที่แปลงแล้ว
                                  'latitude': selectedPosition.latitude,
                                  'longitude': selectedPosition.longitude,
                                });
                              }
                              : null,
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Address Card (สามารถซ่อน/แสดงได้)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top:
                showAddressCard
                    ? 80 + MediaQuery.of(context).padding.top
                    : -250,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF689F38)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'ที่อยู่ที่เลือก',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF689F38),
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                            setState(() => showAddressCard = !showAddressCard);
                          },
                          icon: Icon(
                            showAddressCard
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    isLoading
                        ? const Text(
                          'กำลังค้นหาที่อยู่...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                        : Text(
                          selectedAddress.isEmpty
                              ? 'แตะเพื่อเลือกตำแหน่งบนแผนที่'
                              : selectedAddress,
                          style: TextStyle(
                            color:
                                selectedAddress.isEmpty
                                    ? Colors.grey
                                    : Colors.black87,
                            fontSize: 14,
                          ),
                        ),

                    // ✅ แสดงพิกัดเสริม
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.gps_fixed,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'พิกัด: ${selectedPosition.latitude.toStringAsFixed(6)}, ${selectedPosition.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Control Buttons (ด้านล่าง)
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // ปุ่มแสดง/ซ่อน Address Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() => showAddressCard = !showAddressCard);
                    },
                    icon: Icon(
                      showAddressCard ? Icons.info : Icons.info_outline,
                      color: const Color(0xFF689F38),
                    ),
                    tooltip: 'แสดง/ซ่อน ที่อยู่',
                  ),
                ),

                const Spacer(),

                // ปุ่ม GPS
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF689F38),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: isLoading ? null : _getCurrentLocation,
                    icon:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(
                              Icons.my_location,
                              color: Colors.white,
                            ),
                    tooltip: 'ตำแหน่งปัจจุบัน',
                  ),
                ),

                const SizedBox(width: 12),

                // ปุ่ม Zoom In
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      mapController?.animateCamera(CameraUpdate.zoomIn());
                    },
                    icon: const Icon(Icons.zoom_in, color: Colors.black87),
                    tooltip: 'ขยาย',
                  ),
                ),

                const SizedBox(width: 8),

                // ปุ่ม Zoom Out
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      mapController?.animateCamera(CameraUpdate.zoomOut());
                    },
                    icon: const Icon(Icons.zoom_out, color: Colors.black87),
                    tooltip: 'ย่อ',
                  ),
                ),
              ],
            ),
          ),

          // Center Crosshair
          const Center(
            child: Icon(
              Icons.add,
              size: 30,
              color: Colors.red,
              shadows: [
                Shadow(
                  color: Colors.white,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}