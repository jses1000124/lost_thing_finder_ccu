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
  Future<LatLng> _determineLatLng() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LatLng(23.563333, 120.474111);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LatLng(23.563333, 120.474111);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LatLng(23.563333, 120.474111);
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng>(
      future: _determineLatLng(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(23.563333, 120.474111),
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: snapshot.data ?? const LatLng(23.563333, 120.474111),
                  child: Container(
                    child: Tooltip(
                      message: "當前位置",
                      child: Icon(Icons.location_pin,
                          color: Colors.red, size: 40.0),
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
