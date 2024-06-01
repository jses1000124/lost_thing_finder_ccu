import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/building_data.dart';

class MapSelectPage extends StatefulWidget {
  const MapSelectPage({super.key});

  @override
  State<MapSelectPage> createState() => _MapSelectPageState();
}

class _MapSelectPageState extends State<MapSelectPage> {
  LatLng? _selectedLatLng;
  LatLng? _confirmedLatLng;
  String? _buildingName;
  final MapController _mapController = MapController();

  void _handleMapTap(LatLng point) {
    setState(() {
      _selectedLatLng = point;
    });
    String buildingName = _getBuildingNameAtPoint(point);
    _showNameDialog(point, buildingName);
  }

  String _getBuildingNameAtPoint(LatLng point) {
    for (var building in buildings) {
      if (_isPointInPolygon(point, building['points'])) {
        return building['name'];
      }
    }
    return '';
  }

  void _showNameDialog(LatLng point, String defaultBuildingName) {
    TextEditingController _controller =
        TextEditingController(text: defaultBuildingName);
    bool _isError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('輸入遺失地點'),
              content: TextField(
                maxLength: 20,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '遺失地點',
                  errorText: _isError ? '請填入遺失地點' : null,
                  errorBorder: _isError
                      ? const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red))
                      : null,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedLatLng = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    if (_controller.text.isEmpty) {
                      setState(() {
                        _isError = true;
                      });
                    } else {
                      setState(() {
                        _buildingName = _controller.text;
                        _confirmedLatLng = point;
                        _selectedLatLng = null;
                        _isError = false;
                      });
                      Navigator.of(context).pop();
                      Navigator.of(context).pop({
                        'latLng': _confirmedLatLng,
                        'buildingName': _buildingName,
                      }); // Return selected location and building name
                    }
                  },
                  child: const Text('確認'),
                ),
              ],
            );
          },
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地圖'),
        actions: [
          if (_buildingName != null && _confirmedLatLng != null)
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('儲存的位置'),
                      content: Text(
                        '遺失地點: $_buildingName\n經緯度: (${_confirmedLatLng!.latitude}, ${_confirmedLatLng!.longitude})',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('關閉'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(23.563333, 120.474111),
              initialZoom: 15.0,
              minZoom: 1.0,
              maxZoom: 22.0,
              interactionOptions: const InteractionOptions(
                enableMultiFingerGestureRace: true,
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (tapPosition, point) {
                _handleMapTap(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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
              if (_selectedLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 30.0,
                      height: 30.0,
                      point: _selectedLatLng!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
              if (_confirmedLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 30.0,
                      height: 30.0,
                      point: _confirmedLatLng!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
