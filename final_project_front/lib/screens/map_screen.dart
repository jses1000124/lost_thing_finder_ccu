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
  final List<Map<String, dynamic>> buildings = [
    {
      "name": "圖書資訊大樓",
      "latlng": const LatLng(23.5633, 120.4741),
    },
    {
      "name": "共同教室大樓",
      "latlng": const LatLng(23.5630, 120.4763),
    },
    {
      "name": "行政大樓",
      "latlng": const LatLng(23.5621, 120.4752),
    },
    {
      "name": "資訊工程學系暨研究所",
      "latlng": const LatLng(23.5623, 120.4778),
    },
    {
      "name": "禮堂",
      "latlng": const LatLng(23.5616, 120.4770),
    },
    {
      "name": "管理學院",
      "latlng": const LatLng(23.5608, 120.4760),
    },
    {
      "name": "文學院",
      "latlng": const LatLng(23.5614, 120.4737),
    },
    {
      "name": "社會科學院",
      "latlng": const LatLng(23.5606, 120.4741),
    },
    {
      "name": "電機工程學系",
      "latlng": const LatLng(23.5621, 120.4773),
    },
    {
      "name": "化學工程學系",
      "latlng": const LatLng(23.5616, 120.4781),
    },
    {
      "name": "機械工程學系",
      "latlng": const LatLng(23.5625, 120.4787),
    },
    {
      "name": "創新大樓",
      "latlng": const LatLng(23.5618, 120.4794),
    },
    {
      "name": "管理學院二館",
      "latlng": const LatLng(23.5611, 120.4792),
    },
    {
      "name": "法學院",
      "latlng": const LatLng(23.5645, 120.4770),
    },
    {
      "name": "教育學院一館",
      "latlng": const LatLng(23.5634, 120.4763),
    },
    {
      "name": "教育學院二館",
      "latlng": const LatLng(23.5631, 120.4768),
    },
    {
      "name": "理學院一館",
      "latlng": const LatLng(23.5644, 120.4760),
    },
    {
      "name": "理學院二館",
      "latlng": const LatLng(23.5650, 120.4748),
    },
    {
      "name": "大學部宿舍A棟",
      "latlng": const LatLng(23.5607, 120.4689),
    },
    {
      "name": "大學部宿舍B棟",
      "latlng": const LatLng(23.5607, 120.4684),
    },
    {
      "name": "大學部宿舍C棟",
      "latlng": const LatLng(23.5600, 120.4687),
    },
    {
      "name": "大學部宿舍D棟",
      "latlng": const LatLng(23.5599, 120.4692),
    },
    {
      "name": "大學部宿舍E棟",
      "latlng": const LatLng(23.5600, 120.4697),
    },
  ];

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

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: currentLatLng,
                  zoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 10.0,
                        height: 10.0,
                        point: currentLatLng,
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
                      for (var building in buildings)
                        Marker(
                          width: 10.0,
                          height: 10.0,
                          point: building['latlng'],
                          child: Tooltip(
                            message: building['name'],
                            child: Container(
                              width: 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                color: Colors.red,
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
                    ],
                  ),
                ],
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
