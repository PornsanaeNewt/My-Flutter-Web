import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:project_web/styles/app-color.dart';

class MapAPI extends StatefulWidget {
  final Function(GeoPoint) onLocationSelected;
  final double? initialLat;
  final double? initialLng;

  const MapAPI({
    Key? key,
    required this.onLocationSelected,
    this.initialLat,
    this.initialLng,
  }) : super(key: key);

  @override
  State<MapAPI> createState() => _MapAPIState();
}

class _MapAPIState extends State<MapAPI> {
  late MapController controller;

  GeoPoint get _initialPoint {
    if (widget.initialLat != null && widget.initialLng != null) {
      return GeoPoint(
        latitude: widget.initialLat!,
        longitude: widget.initialLng!,
      );
    }
    return GeoPoint(latitude: 18.787776, longitude: 98.985686);
  }

  @override
  void initState() {
    super.initState();
    controller = MapController(initPosition: _initialPoint);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เลือกตำแหน่งโรงเรียน"),
        backgroundColor: AppColors.linkText,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 70, 
            child: OSMFlutter(
              controller: controller,
              osmOption: OSMOption(
                userTrackingOption: const UserTrackingOption(
                  enableTracking: false,
                  unFollowUser: false,
                ),
                zoomOption: const ZoomOption(
                  initZoom: 16,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                ),
              ),
            ),
          ),

          const Center(
            child: Icon(Icons.location_on, color: Colors.red, size: 48),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text("ยกเลิก"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final GeoPoint? point = await controller.centerMap;

                      if (point != null) {
                        widget.onLocationSelected(point);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'ไม่สามารถดึงพิกัดได้ ลองเลื่อนแผนที่อีกครั้ง',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("ยืนยัน", style: TextStyle()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inputFocusedBorder,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
