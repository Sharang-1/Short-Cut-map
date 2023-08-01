import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:geocoder2/geocoder2.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import '/screen/question_screen.dart';
import '../models/polygons.dart';

class AddPolygon extends StatefulWidget {
  final LatLng center;
  AddPolygon(this.center);
  @override
  State<AddPolygon> createState() => AddPolygonState();
}

class AddPolygonState extends State<AddPolygon> {
  LatLng point;
  List<double> latarr = [];
  List<double> longarr = [];
  var location = [];
  bool marker = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        );
    if (latarr.isNotEmpty && longarr.isNotEmpty) {
      marker = true;
    }
    final polygonsData = Provider.of<Polygons>(context);
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              onTap: (p) async {
                // location = await Geocoder2.getDataFromCoordinates(
                //     Coordinates(p.latitude, p.longitude));

                setState(() {
                  point = p;
                  latarr.add(p.latitude);
                  longarr.add(p.longitude);
                  // print(p);
                });
                // print(location.last);
                // print(
                //     "${location.first.countryName} - ${location.first.featureName}");
              },
              center: widget.center,
              zoom: 18.0,
            ),
            layers: [
              TileLayerOptions(
                  // urlTemplate:
                  //     "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  // subdomains: ['a', 'b', 'c']
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/shobhitm886/clg7r4rwl000o01n29pf3xd9b/tiles/256/{z}/{x}/{y}@2x?access_token={access_token}",
                  additionalOptions: {
                    "access_token":
                        "pk.eyJ1Ijoic2hvYmhpdG04ODYiLCJhIjoiY2xmd3BydzFwMGp4YzNkcXVhaWlwa3RtdSJ9.T-vgu4eoV8jxT0sYAxLfWg",
                    'id': 'mapbox.mapbox-streets-v8',
                  }),
              PolygonLayerOptions(
                polygons: [
                  for (int i = 0; i < polygonsData.buildings.length; i++)
                    Polygon(
                        points: [
                          for (int j = 0;
                              j < polygonsData.buildings[i].latlog.length - 1;
                              j++)
                            LatLng(polygonsData.buildings[i].latlog[j].latitude,
                                polygonsData.buildings[i].latlog[j].longitude),
                        ],
                        borderColor: Colors.pink,
                        color: Colors.pink.withOpacity(0.5),
                        borderStrokeWidth: 1.0),
                ],
              ),
              if (marker)
                PolygonLayerOptions(
                  polygons: [
                    Polygon(
                        points: [
                          for (int i = 0; i < latarr.length; i++)
                            LatLng(latarr[i], longarr[i]),
                        ],
                        borderColor: Colors.grey,
                        color: Colors.grey.withOpacity(0.5),
                        borderStrokeWidth: 1.0),
                  ],
                ),
              MarkerLayerOptions(
                markers: [
                  // Marker(
                  //   width: 80.0,
                  //   height: 80.0,
                  //   point: point,
                  //   builder: (ctx) => const Icon(
                  //     Icons.location_on,
                  //     color: Colors.red,
                  //   ),
                  // ),
                  if (marker)
                    for (int i = 0; i < latarr.length; i++)
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(latarr[i], longarr[i]),
                        builder: (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                        ),
                      ),
                ],
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 34.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      heroTag: "btn1",
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (latarr.isNotEmpty && longarr.isNotEmpty) {
                          setState(() {
                            latarr.removeLast();
                            longarr.removeLast();
                          });
                        }
                      },
                      child: Icon(
                        Icons.remove,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "btn2",
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        setState(() {
                          latarr.clear();
                          longarr.clear();
                        });
                      },
                      child: Icon(
                        Icons.clear,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "btn3",
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0))),
                            backgroundColor: Theme.of(context).primaryColor,
                            context: context,
                            builder: (BuildContext context) => QuestionScreeen(
                                latarr: latarr, longarr: longarr));
                      },
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 45, 0, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: FloatingActionButton(
                heroTag: "btn4",
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
