import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final LatLng? initialPosition;

  const MapSample({
    Key? key, 
    required this.onLocationSelected,
    this.initialPosition,
  }) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? mapController;
  Marker? _marker;
   final Map<String, Marker> _markers = {};

  final LatLng _defaultPosition = const LatLng(18.7883, 98.9853);
  
  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _marker = Marker(
        markerId: const MarkerId("selected-location"),
        position: widget.initialPosition!,
        draggable: true,
        onDragEnd: (newPosition) {
          widget.onLocationSelected(newPosition);
        },
      );
      _markers["selected-location"] = _marker!;
    }
  }

  void _onTap(LatLng position) {
    setState(() {
      _marker = Marker(
        markerId: const MarkerId("selected-location"),
        position: position,
        draggable: true,
        onDragEnd: (newPosition) {
          widget.onLocationSelected(newPosition);
        },
      );
    });
    widget.onLocationSelected(position);
  }
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition ?? _defaultPosition,
        zoom: 15,
      ),
       markers: Set<Marker>.of(_markers.values),
      onTap: _onTap,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
    );
  }
}