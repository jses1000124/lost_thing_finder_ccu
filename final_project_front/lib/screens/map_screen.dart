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
      "points": [
        LatLng(23.563923494986597, 120.4739359362714),
        LatLng(23.563392446686912, 120.47351482947259),
        LatLng(23.563104794628284, 120.47385815221304),
        LatLng(23.563724352125778, 120.47426853017622),
      ],
    },
    {
      "name": "語言中心",
      "points": [
        LatLng(23.56374893768194, 120.4743355854037),
        LatLng(23.563407198059025, 120.4740620000949),
        LatLng(23.56313921456737, 120.4744214160888),
        LatLng(23.56353996032029, 120.47470573023324),
      ],
    },
    {
      "name": "資訊處",
      "points": [
        LatLng(23.563407198059025, 120.4740620000949),
        LatLng(23.56298186620748, 120.47379109699501),
        LatLng(23.56275813617868, 120.47411564427992),
        LatLng(23.56313921456737, 120.4744214160888),
      ],
    },
    {
      "name": "行政大樓",
      "points": [
        LatLng(23.562394498564206, 120.47500118943084),
        LatLng(23.5618339409944, 120.47458544704986),
        LatLng(23.56109882020568, 120.47565564840484),
        LatLng(23.561715526199208, 120.47597757675207),
      ],
    },
    {
      "name": "禮堂",
      "points": [
        LatLng(23.562280050259282, 120.4767044710704),
        LatLng(23.561469915839236, 120.47600651928644),
        LatLng(23.560764086499947, 120.4771027587732),
        LatLng(23.56158465621095, 120.47773243266528),
      ],
    },
    {
      "name": "共同教室大樓",
      "points": [
        LatLng(23.56343407168636, 120.47587565280594),
        LatLng(23.562858767121543, 120.47541431287345),
        LatLng(23.562153155091558, 120.47647646760171),
        LatLng(23.56269158412602, 120.47696731183218),
      ],
    },
    {
      "name": "活動中心",
      "points": [
        LatLng(23.561404884863293, 120.47205396088215),
        LatLng(23.56079381268026, 120.47157550559423),
        LatLng(23.55999268981928, 120.47278121291976),
        LatLng(23.56061253713201, 120.47331708284223),
      ],
    },
    {
      "name": "生活商圈",
      "points": [
        LatLng(23.56147213187551, 120.47154998796438),
        LatLng(23.561112506190728, 120.47126291479164),
        LatLng(23.560922459699594, 120.47149576303174),
        LatLng(23.561346409187035, 120.47187533756015),
      ],
    },
    {
      "name": "大學部宿舍A棟",
      "points": [
        LatLng(23.560992630737175, 120.46890891468017),
        LatLng(23.560714870134785, 120.46869201494965),
        LatLng(23.560536518280514, 120.46895038080513),
        LatLng(23.560817203056605, 120.46919917755481),
      ],
    },
    {
      "name": "大學部宿舍B棟",
      "points": [
        LatLng(23.560913688309903, 120.46835071684427),
        LatLng(23.560656394143656, 120.46815295532528),
        LatLng(23.560469270797192, 120.46842726969035),
        LatLng(23.560749955716958, 120.46865054882471),
      ],
    },
    {
      "name": "大學部宿舍C棟",
      "points": [
        LatLng(23.560407870891066, 120.46883236183409),
        LatLng(23.560130109052494, 120.46861865180551),
        LatLng(23.559940061140402, 120.46889296617057),
        LatLng(23.560235366239368, 120.46912262470877),
      ],
    },
    {
      "name": "大學部宿舍D棟",
      "points": [
        LatLng(23.560185661459823, 120.46918641875052),
        LatLng(23.55988450861452, 120.46897589842386),
        LatLng(23.559706155633133, 120.46927254070235),
        LatLng(23.559992689813143, 120.46948306102902),
      ],
    },
    {
      "name": "大學部宿舍E棟",
      "points": [
        LatLng(23.56052774686423, 120.46989772227857),
        LatLng(23.560092099484702, 120.46956599327892),
        LatLng(23.559896203883536, 120.46986901496128),
        LatLng(23.560340623334564, 120.47020712336472),
      ],
    },
    {
      "name": "研究生宿舍A棟",
      "points": [
        LatLng(23.56227003497022, 120.4706669428223),
        LatLng(23.56207532499285, 120.4705303870385),
        LatLng(23.561532917105755, 120.47140282676845),
        LatLng(23.56169981207875, 120.47151662325496),
      ],
    },
    {
      "name": "研究生宿舍B棟",
      "points": [
        LatLng(23.561873660783515, 120.47041659055196),
        LatLng(23.561783259485757, 120.47032176014652),
        LatLng(23.561393837799653, 120.4709514340386),
        LatLng(23.561501624274722, 120.47104247122782),
      ],
    },
    {
      "name": "研究生宿舍C棟",
      "points": [
        LatLng(23.562722738512136, 120.46986614068899),
        LatLng(23.562576550719665, 120.4697321732084),
        LatLng(23.562167224035363, 120.47036373418842),
        LatLng(23.562351421201118, 120.47048813256329),
      ],
    },
    {
      "name": "研究生宿舍D棟",
      "points": [
        LatLng(23.56240809127981, 120.46962587871288),
        LatLng(23.562304720669697, 120.4695401712383),
        LatLng(23.561903641932503, 120.47013561264058),
        LatLng(23.56206490054102, 120.47025289655313),
      ],
    },
    {
      "name": "研究生宿舍E棟",
      "points": [
        LatLng(23.561286527025242, 120.47077050193008),
        LatLng(23.561172499314594, 120.4706875696802),
        LatLng(23.560885967707435, 120.47111817943929),
        LatLng(23.56100876704417, 120.47121387049688),
      ],
    },
    {
      "name": "大學部宿舍停車場",
      "points": [
        LatLng(23.560523328986545, 120.46784585367438),
        LatLng(23.560314708369138, 120.46766757251216),
        LatLng(23.559481021196405, 120.46913857322207),
        LatLng(23.559624288609996, 120.46920555696241),
      ],
    },
    {
      "name": "宿舍腳踏車停車場",
      "points": [
        LatLng(23.56053511181024, 120.46851857229497),
        LatLng(23.56027196928526, 120.46828891375678),
        LatLng(23.560122854953857, 120.46856003841992),
        LatLng(23.560400616807772, 120.46876736904468),
      ],
    },
    {
      "name": "大門口機車停車場",
      "points": [
        LatLng(23.558580732325442, 120.4724537535226),
        LatLng(23.5583088143295, 120.47234211395542),
        LatLng(23.557797139155607, 120.47354463157903),
        LatLng(23.558080753640958, 120.47365946084813),
      ],
    },
    {
      "name": "東側門汽機車停車場",
      "points": [
        LatLng(23.561160300257253, 120.4812469509238),
        LatLng(23.56075508315174, 120.48092216470435),
        LatLng(23.55992397068839, 120.48136423483635),
        LatLng(23.56054006948621, 120.48215815670608),
      ],
    },
    {
      "name": "文學院",
      "points": [
        LatLng(23.562228076245354, 120.47369037976127),
        LatLng(23.561223230264652, 120.47273828249074),
        LatLng(23.560739927903658, 120.47346658000444),
        LatLng(23.561859517712364, 120.4743655722479),
      ],
    },
    {
      "name": "文學院汽車停車場",
      "points": [
        LatLng(23.562178297064516, 120.47212788105229),
        LatLng(23.561787381526237, 120.47181674481875),
        LatLng(23.561248948786176, 120.4726294541184),
        LatLng(23.561642324521184, 120.47295131918757),
      ],
    },
    {
      "name": "社會科學院",
      "points": [
        LatLng(23.561198891319957, 120.47428591475776),
        LatLng(23.5605834627102, 120.47386107454143),
        LatLng(23.560065387804016, 120.47468040924436),
        LatLng(23.560659956818576, 120.47509766302827),
      ],
    },
    {
      "name": "管理學院",
      "points": [
        LatLng(23.56137969465816, 120.47598148248959),
        LatLng(23.56078860590112, 120.47551491689488),
        LatLng(23.560117543089092, 120.47653149884107),
        LatLng(23.56072601987705, 120.47699427121961),
      ],
    },
    {
      "name": "工學院一館",
      "points": [
        LatLng(23.56282892744928, 120.47719802019593),
        LatLng(23.562323268211863, 120.4767578784257),
        LatLng(23.561663812878198, 120.4777563769691),
        LatLng(23.562212078254447, 120.4781989414392),
      ],
    },
    {
      "name": "工學院二館",
      "points": [
        LatLng(23.562738291110367, 120.47879287115563),
        LatLng(23.561606793487655, 120.47786466789708),
        LatLng(23.561358272032766, 120.47830165706004),
        LatLng(23.562475152997948, 120.47922986031858),
      ],
    },
    {
      "name": "教育學院一館",
      "points": [
        LatLng(23.563990670737443, 120.47634310415393),
        LatLng(23.56348999391984, 120.47594481645173),
        LatLng(23.563100577292634, 120.47652517853297),
        LatLng(23.56364297870756, 120.47691967301955),
      ],
    },
    {
      "name": "教育學院二館",
      "points": [
        LatLng(23.563636024857445, 120.47694243231686),
        LatLng(23.563100577292634, 120.47652517853297),
        LatLng(23.56276331374525, 120.47699933056012),
        LatLng(23.56336134748317, 120.47740520469537),
      ],
    },
    {
      "name": "法學院",
      "points": [
        LatLng(23.56462346788994, 120.47687036120873),
        LatLng(23.563990670737443, 120.47634310415393),
        LatLng(23.56364297870756, 120.47691967301955),
        LatLng(23.56427230061966, 120.47740141147915),
      ],
    },
    {
      "name": "理學院一館",
      "points": [
        LatLng(23.56543010600214, 120.47569446415996),
        LatLng(23.56445309974391, 120.4748713362408),
        LatLng(23.56373806949141, 120.47591067748425),
        LatLng(23.56474695216166, 120.47667753383567),
      ],
    },
    {
      "name": "理學院二館",
      "points": [
        LatLng(23.5658264694643, 120.47505720382475),
        LatLng(23.564915527105114, 120.47427959450022),
        LatLng(23.56445309974391, 120.4748713362408),
        LatLng(23.56543010600214, 120.47569446415996),
      ],
    },
    {
      "name": "管理學院二館",
      "points": [
        LatLng(23.561505508985764, 120.47878444751309),
        LatLng(23.561303903858757, 120.47861278614286),
        LatLng(23.56095478205348, 120.47916263896937),
        LatLng(23.561247356023674, 120.47932357150397),
      ],
    },
    {
      "name": "創新大樓",
      "points": [
        LatLng(23.562257837587424, 120.47931552487702),
        LatLng(23.561303903858757, 120.47861278614286),
        LatLng(23.56095478205348, 120.47916263896937),
        LatLng(23.5618152918707, 120.47997803047791),
      ],
    },
    {
      "name": "員工學生福利社",
      "points": [
        LatLng(23.562882390783017, 120.46942979584702),
        LatLng(23.562631616255043, 120.4692339945966),
        LatLng(23.562486560182094, 120.46940297375792),
        LatLng(23.56275208643117, 120.46962827930633),
      ],
    },
    {
      "name": "鳳凰大道",
      "points": [
        LatLng(23.56535531351698, 120.47162464378343),
        LatLng(23.564928453261043, 120.47129291478382),
        LatLng(23.563741423613887, 120.47306638905097),
        LatLng(23.564179982614643, 120.47341725626211),
      ],
    },
    {
      "name": "田徑場",
      "points": [
        LatLng(23.564265623239567, 120.4722426483543),
        LatLng(23.56433591421411, 120.47081719772456),
        LatLng(23.56256622411475, 120.47060067357828),
        LatLng(23.562460756325287, 120.47237589688643),
      ],
    },
    {
      "name": "體育館",
      "points": [
        LatLng(23.567186721984363, 120.47304815541453),
        LatLng(23.565480518218816, 120.4717392374666),
        LatLng(23.564511856650924, 120.47316080818874),
        LatLng(23.566252492120217, 120.47450727706142),
      ],
    },
    {
      "name": "高爾夫球練習場",
      "points": [
        LatLng(23.567289772301553, 120.47069303611103),
        LatLng(23.566504006722617, 120.47001784362435),
        LatLng(23.564511856650924, 120.47316080818874),
        LatLng(23.56630234931165, 120.47224825476012),
      ],
    },
    {
      "name": "足球場",
      "points": [
        LatLng(23.567644408324238, 120.47217239043576),
        LatLng(23.56678215436767, 120.47151995724639),
        LatLng(23.56630234931165, 120.47224825476012),
        LatLng(23.567178513744192, 120.47291586081434),
      ],
    },
    {
      "name": "壘球場",
      "points": [
        LatLng(23.568172883757892, 120.47140616075986),
        LatLng(23.567289772301553, 120.47069303611103),
        LatLng(23.56678215436767, 120.47151995724639),
        LatLng(23.567644408324238, 120.47217239043576),
      ],
    },
    {
      "name": "棒球場",
      "points": [
        LatLng(23.566427326081463, 120.4685499574066),
        LatLng(23.566179244070835, 120.46765679530317),
        LatLng(23.565484611948442, 120.46775603553687),
        LatLng(23.56531922280648, 120.46874843787403),
        LatLng(23.56626193812643, 120.46877550339231),
      ],
    },
    {
      "name": "射箭場",
      "points": [
        LatLng(23.568147472818087, 120.46950906197773),
        LatLng(23.567165128293748, 120.46868611888253),
        LatLng(23.566872762433313, 120.4691581947666),
        LatLng(23.567855109144233, 120.46989182620804),
      ],
    },
    {
      "name": "網球場",
      "points": [
        LatLng(23.564974160095623, 120.46974273507867),
        LatLng(23.56495954157423, 120.46904738006023),
        LatLng(23.56384560545915, 120.46900272423339),
        LatLng(23.563846196931156, 120.46977549994538),
      ],
    },
    {
      "name": "籃球場",
      "points": [
        LatLng(23.565347112595155, 120.46931538613453),
        LatLng(23.565016333756734, 120.46931087521482),
        LatLng(23.565016333756734, 120.46972587982852),
        LatLng(23.564768249081332, 120.46973941258766),
        LatLng(23.564780653326217, 120.47012284076338),
        LatLng(23.56549182807505, 120.47011832984367),
        LatLng(23.565495962800703, 120.46974392350738),
        LatLng(23.56534881671811, 120.46974267519383),
      ],
    },
  ];

  LatLng? _currentLatLng;
  final MapController _mapController = MapController();
  String? _hoveredBuildingName;

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

  void _handlePolygonHover(LatLng point) {
    for (var building in buildings) {
      if (_isPointInPolygon(point, building['points'])) {
        setState(() {
          _hoveredBuildingName = building['name'];
        });
        return;
      }
    }
    setState(() {
      _hoveredBuildingName = null;
    });
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
                    _handlePolygonHover(point);
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
                        color: Colors.red.withOpacity(0.3),
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
          if (_hoveredBuildingName != null)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.transparent,
                child: Text(
                  _hoveredBuildingName!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// void main() => runApp(MaterialApp(
//       home: MapPage(),
//     ));
