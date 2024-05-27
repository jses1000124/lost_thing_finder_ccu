import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/post_provider.dart'; // Update the import path as needed

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentLatLng;
  final MapController _mapController = MapController();

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
  void initState() {
    super.initState();
    _determineLatLng().then((latlng) {
      setState(() {
        _currentLatLng = latlng;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<LatLng>(
            future: _determineLatLng(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              LatLng currentLatLng =
                  snapshot.data ?? const LatLng(23.563333, 120.474111);

              return Consumer<PostProvider>(
                builder: (context, postProvider, child) {
                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentLatLng,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                      if (_currentLatLng != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 10.0,
                              height: 10.0,
                              point: _currentLatLng!,
                              child: Tooltip(
                                message: "當前位置",
                                child: Container(
                                  width: 10.0,
                                  height: 10.0,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        spreadRadius: 10,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ...postProvider.posts
                                .where((post) =>
                                    post.latitude != null &&
                                    post.longitude != null)
                                .map(
                                  (post) => Marker(
                                    width: 100.0,
                                    height: 100.0,
                                    point:
                                        LatLng(post.latitude!, post.longitude!),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Text(
                                            post.lostThingName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 30.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                    ],
                  );
                },
              );
            },
          ),
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: FloatingActionButton(
              onPressed: () async {
                LatLng currentLatLng = await _determineLatLng();
                _mapController.move(currentLatLng, 15.0);
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
