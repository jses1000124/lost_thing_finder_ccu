import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class PostMapPage extends StatefulWidget {
  final LostThing lostThing;
  const PostMapPage({super.key, required this.lostThing});

  @override
  State<PostMapPage> createState() => _MapPageState();
}

class _MapPageState extends State<PostMapPage> {
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

  Future<void> _locateCurrentPosition() async {
    LatLng currentLatLng = await _determineLatLng();
    setState(() {
      _currentLatLng = currentLatLng;
    });
    _mapController.move(currentLatLng, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地圖'),
      ),
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

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                      widget.lostThing.latitude!,
                      widget.lostThing
                          .longitude!), // Focus on lostThing's location
                  initialZoom: 18.0, // Zoom level increased
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
                  ),
                  MarkerLayer(
                    markers: [
                      if (_currentLatLng != null)
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
                      Marker(
                        width: 100.0,
                        height: 100.0,
                        point: LatLng(widget.lostThing.latitude!,
                            widget.lostThing.longitude!),
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
                                widget.lostThing.lostThingName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              color: widget.lostThing.mylosting == 0
                                  ? Colors.red
                                  : Colors.blue,
                              size: 30.0,
                            ),
                          ],
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
              onPressed: _locateCurrentPosition,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
