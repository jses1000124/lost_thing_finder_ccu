import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../models/post_provider.dart'; 
import 'lost_thing_detail_screen.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentLatLng;
  final MapController _mapController = MapController();
  final int _retryLimit = 3;

  Future<void> _determineLatLng() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLatLng = null;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLatLng = null;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLatLng = null;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _retryTileLoading(TileImage tile, int retryCount) async {
    if (retryCount < _retryLimit) {
      await Future.delayed(Duration(seconds: 1));
      tile.load();
    } else {
      print('Failed to load tile after $_retryLimit attempts: $tile');
    }
  }

  @override
  void initState() {
    super.initState();
    _determineLatLng();
  }

  Future<void> _showNavigateDialog(
      BuildContext context, LostThing lostThing) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認查看${lostThing.lostThingName}'),
          content: Text('你確定要查看${lostThing.lostThingName}的詳細信息嗎？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => LostThingDetailScreen(lostThings: lostThing),
        ),
      );
    }
  }

  Future<void> _locateCurrentPosition() async {
    await _determineLatLng();
    if (_currentLatLng != null) {
      _mapController.move(_currentLatLng!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              if (postProvider.posts.isEmpty) {
                return const Center(child: Text('目前沒有遺失物喔'));
              }

              List<Marker> markers = [];
              if (_currentLatLng != null) {
                markers.add(
                  Marker(
                    width: 10.0,
                    height: 10.0,
                    point: _currentLatLng!,
                    child: Tooltip(
                      message: "當前位置",
                      child: Icon(
                        FontAwesomeIcons.locationArrow,
                        color: Colors.purple,
                        size: 30.0,
                      ),
                    ),
                  ),
                );
              }

              for (LostThing post in postProvider.posts) {
                if (post.latitude != null && post.longitude != null) {
                  markers.add(
                    Marker(
                      width: 100.0,
                      height: 100.0,
                      point: LatLng(post.latitude!, post.longitude!),
                      child: GestureDetector(
                        onTap: () => _showNavigateDialog(context, post),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4.0),
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
                            Icon(
                              Icons.location_on,
                              color: post.mylosting == 0
                                  ? Colors.red
                                  : Colors.blue,
                              size: 30.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLatLng ??
                      LatLng(23.563333, 120.474111), // Default location
                  initialZoom: 15.0,
                  minZoom: 1.0,
                  maxZoom: 22.0,
                  interactionOptions: const InteractionOptions(
                    enableMultiFingerGestureRace: true,
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    errorTileCallback: (tile, error, stackTrace) async {
                      await _retryTileLoading(tile, 0);
                      debugPrint('Failed to load tile: $tile, error: $error');
                    },
                  ),
                  MarkerLayer(
                    markers: markers,
                  ),
                ],
              );
            },
          ),
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: FloatingActionButton(
              onPressed: _locateCurrentPosition,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
