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
          markers.add(Marker(
            width: 80.0,
            height: 80.0,
            point: snapshot.data!,
            child: Container(
              child: Tooltip(
                message: "當前位置",
                child: Icon(Icons.location_pin, color: Colors.red, size: 40.0),
              ),
            ),
          ));
        }

        return FlutterMap(
          options: MapOptions(
            center: const LatLng(23.563333, 120.474111), // 中心點
            zoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: markers),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: snapshot.data ?? const LatLng(23.563333, 120.474111),
                  child: const Tooltip(
                    message: "當前位置",
                    child:
                        Icon(Icons.location_pin, color: Colors.red, size: 40.0),
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
