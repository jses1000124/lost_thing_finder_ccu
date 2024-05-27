import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../data/building_data.dart'; // 確保這個路徑正確，並且包含 buildings 資料

// 遺失物品類別
class LostItem {
  final String name;
  final LatLng location;
  final DateTime time;

  LostItem({
    required this.name,
    required this.location,
    required this.time,
  });
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentLatLng;
  final MapController _mapController = MapController();
  OverlayEntry? _overlayEntry;
  List<LostItem> _lostItems = [];

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

  void _handlePolygonHover(LatLng point, TapPosition tapPosition) {
    String? hoveredBuildingName;

    for (var building in buildings) {
      if (_isPointInPolygon(point, building['points'])) {
        hoveredBuildingName = building['name'];
        break;
      }
    }

    if (hoveredBuildingName != null) {
      _showOverlay(context, hoveredBuildingName, tapPosition);
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay(
      BuildContext context, String text, TapPosition tapPosition) {
    _removeOverlay();
    final overlay = Overlay.of(context);
    if (overlay != null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: tapPosition.global.dx + 10,
          top: tapPosition.global.dy + 10,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black54,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
      overlay.insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool result = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        result = !result;
      }
      j = i;
    }
    return result;
  }

  LatLng _findCentroid(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;
    for (var point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }
    return LatLng(latitude / points.length, longitude / points.length);
  }

  void _addLostItem(LatLng point) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: const Text('新增遺失物'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '物品名稱'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('儲存'),
              onPressed: () {
                setState(() {
                  _lostItems.add(LostItem(
                    name: nameController.text,
                    location: point,
                    time: DateTime.now(),
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLostItemInfo(LostItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('位置: ${item.location.latitude}, ${item.location.longitude}'),
              Text('時間: ${item.time}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                  onTap: (tapPosition, point) {
                    _handlePolygonHover(point, tapPosition);
                    _addLostItem(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  PolygonLayer(
                    polygons: buildings.map((building) {
                      return Polygon(
                        points: List<LatLng>.from(building['points']),
                        color: Colors.transparent,
                        borderStrokeWidth: 0.0,
                        borderColor: Colors.transparent,
                        isFilled: true,
                      );
                    }).toList(),
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
                        ..._lostItems.map((item) {
                          return Marker(
                            width: 10.0,
                            height: 10.0,
                            point: item.location,
                            child: GestureDetector(
                              onTap: () => _showLostItemInfo(item),
                              child: Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: MapPage(),
    ));
