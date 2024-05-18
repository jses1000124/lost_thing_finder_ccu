import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Future<LatLng?> _determineLatLng() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 位置服務未啟用
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // 權限被拒絕或永久拒絕
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 權限被永久拒絕
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng?>(
      future: _determineLatLng(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Marker> markers = [];
        if (snapshot.data != null) {
          markers.add(
            Marker(
              width: 10.0, // Marker宽度
              height: 10.0, // Marker高度
              point: snapshot.data!,
              child: Container(
                width: 5.0, // 蓝点宽度减半
                height: 5.0, // 蓝点高度减半
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      spreadRadius: 4,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return FlutterMap(
          options: MapOptions(
            center: const LatLng(23.563333, 120.474111),
            zoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }
}
