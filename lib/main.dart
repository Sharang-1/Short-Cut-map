import 'package:QensMAP/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:map_controller/map_controller.dart';
import 'package:provider/provider.dart';

import './models/polygons.dart';
import 'screen/addPolygon.dart';
import 'screen/addPolyline.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => Polygons(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 104, 167, 203),
          accentColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class MapApp extends StatefulWidget {
  @override
  State<MapApp> createState() => _MapAppState();
}

class _MapAppState extends State<MapApp> {
  LocationData _currentPosition;
  LatLng center;
  double long = 75.818425;
  double lat = 26.915965;
  LatLng point = LatLng(26.915965, 75.818425);
  var _isInit = true;
  var _isLoading = false;
  bool isSaterlite = false;
  Location location = Location();
  MapController mapController;
  StatefulMapController statefulMapController;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    getLoc();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    statefulMapController.onReady
        .then((_) => print("The map controller is ready"));

    super.initState();
  }

  Future<void> getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    // ignore: missing_return
    await location.getLocation().then((value) {
      _currentPosition = value;
      center = LatLng(value.latitude, value.longitude);
      point = LatLng(value.latitude, value.longitude);
      _isInit = true;
      setState(() {});
    });
  }

  void changeView() {
    setState(() {
      isSaterlite = !isSaterlite;
    });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Polygons>(context, listen: false)
          .fetchAndSetPolygons(
              "${(point.longitude - 0.10).toStringAsFixed(3)},${(point.latitude - 0.10).toStringAsFixed(3)},${(point.longitude + 0.10).toStringAsFixed(3)},${(point.latitude + 0.10).toStringAsFixed(3)}")
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final polygonsData = Provider.of<Polygons>(context);

    return Scaffold(
      key: _key,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: Text('QensLab',
                    style: TextStyle(color: Colors.white, fontSize: 40)),
              ),
            ),
            Card(
              elevation: 2,
              shadowColor: Theme.of(context).primaryColor,
              child: ListTile(
                title: const Text(
                  'Street View',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  isSaterlite ? changeView() : null;
                  Navigator.pop(context);
                },
              ),
            ),
            Card(
              elevation: 2,
              shadowColor: Theme.of(context).primaryColor,
              child: ListTile(
                title: const Text(
                  'Satellite View',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  !isSaterlite ? changeView() : null;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      // body: Stack(
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    onPositionChanged: (position, hasGesture) {
                      if ((((point.longitude - 0.10) >
                                  position.center.longitude) ||
                              (position.center.longitude >
                                  (point.longitude + 0.10))) &&
                          (((point.latitude - 0.10) >
                                  position.center.latitude) ||
                              (position.center.latitude >
                                  (point.latitude + 0.10)))) {
                        point = position.center;
                        Provider.of<Polygons>(context, listen: false)
                            .fetchAndSetPolygons(
                                "${(point.longitude - 0.10).toStringAsFixed(3)},${(point.latitude - 0.10).toStringAsFixed(3)},${(point.longitude + 0.10).toStringAsFixed(3)},${(point.latitude + 0.10).toStringAsFixed(3)}");
                      }
                    },
                    // center: LatLng(_currentPosition.latitude ?? lat,
                    //     _currentPosition.longitude ?? long),
                    // center: LatLng(26.915965, 75.818425),
                    center: center,
                    zoom: 16.0,
                  ),
                  layers: [
                    isSaterlite
                        ? TileLayerOptions(
                            maxZoom: 22,
                            minZoom: 6,
                            urlTemplate:
                                // "https://api.mapbox.com/v4/mapbox.mapbox-streets-v8/1/0/0.mvt?access_token={access_token}",
                                // "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/{z}/{x}/{y}@2x?access_token={access_token}",
                                "https://api.mapbox.com/styles/v1/shobhitm886/clg7r4rwl000o01n29pf3xd9b/tiles/256/{z}/{x}/{y}@2x?access_token={access_token}",
                            additionalOptions: {
                                "access_token":
                                    "pk.eyJ1Ijoic2hvYmhpdG04ODYiLCJhIjoiY2xmd3BydzFwMGp4YzNkcXVhaWlwa3RtdSJ9.T-vgu4eoV8jxT0sYAxLfWg",
                                'id': 'mapbox.mapbox-streets-v8',
                              })
                        : TileLayerOptions(
                            maxZoom: 22,
                            minZoom: 6,
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                    PolygonLayerOptions(
                      polygons: [
                        for (int i = 0; i < polygonsData.buildings.length; i++)
                          Polygon(
                              points: [
                                for (int j = 0;
                                    j <
                                        polygonsData
                                                .buildings[i].latlog.length -
                                            1;
                                    j++)
                                  LatLng(
                                      polygonsData
                                          .buildings[i].latlog[j].latitude,
                                      polygonsData
                                          .buildings[i].latlog[j].longitude),
                              ],
                              borderColor: Colors.pink,
                              color: Colors.pink.withOpacity(0.5),
                              borderStrokeWidth: 1.0),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 45, 0, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FloatingActionButton(
                      heroTag: "btn1",
                      onPressed: () => _key.currentState.openDrawer(),
                      child: const Icon(Icons.format_align_left_sharp),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn2",
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => mapController.move(center, 16),
        child: Icon(
          Icons.my_location_sharp,
          color: Theme.of(context).accentColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 90),
              child: IconButton(
                icon: const Icon(
                  Icons.search,
                ),
                onPressed: () {},
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add,
              ),
              onPressed: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0))),
                    backgroundColor: Theme.of(context).primaryColor,
                    context: context,
                    builder: ((context) => Container(
                        decoration:
                            const BoxDecoration(shape: BoxShape.rectangle),
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(height: 20),
                            InkWell(
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Add Building',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddPolygon(center))),
                            ),
                            InkWell(
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Add Road',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddPolyline(center))),
                            )
                          ],
                        ))));
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.person,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
