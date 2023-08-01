import 'dart:io';
import 'dart:convert';

import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

import '/main.dart';

class QuestionScreeen extends StatefulWidget {
  static const items = ['item 1', 'item 2', 'item 3', 'item 4'];
  static const items_resi = [
    'Apartment',
    'Row House',
    'Farmhouse',
    'Bungalow',
    'Hut'
  ];
  static const items_comm = [
    'Office Building',
    'Industrial Building',
    'Retail Building',
    'Kiosk',
    'Warehouse',
    'Hotel'
  ];
  static const items_civic = [
    'School',
    'University',
    'Hospital',
    'Sports centre',
    'Transport Station',
    'Government Building',
    'Railway Station'
  ];
  static const items_rel = ['Church', 'Temple', 'Mosque', 'Pagoda', 'Shrine'];
  List<double> latarr = [];
  List<double> longarr = [];

  QuestionScreeen({@required this.latarr, @required this.longarr});
  @override
  State<QuestionScreeen> createState() => _QuestionScreeenState();
}

class _QuestionScreeenState extends State<QuestionScreeen> {
  String value;
  String valueChoose;
  String valueChoose_resi;
  String valueChoose_comm;
  String valueChoose_civic;
  String valueChoose_rel;
  File _storedImage;
  List userChoice = [];
  TextEditingController buildingNameController = TextEditingController();
  TextEditingController buildingAddressController = TextEditingController();
  TextEditingController buildingWidthController = TextEditingController();
  var name_Building;
  var address_Building;
  var width_Building;

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
    return ListView(
      children: [Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Container(
            transformAlignment: Alignment.center,
            child: TextField(
              controller: buildingNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(5),
                labelText: 'Name of Building',
              ),
              onChanged: (value) {
                name_Building = buildingNameController.text;
                print(name_Building);
              },
            ),
          ),
          Container(
            transformAlignment: Alignment.center,
            child: TextField(
              controller: buildingAddressController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(5),
                labelText: 'Address of Building',
              ),
              onChanged: (value) {
                address_Building = buildingNameController.text;
                print(address_Building);
              },
            ),
          ),
          Container(
            transformAlignment: Alignment.center,
            child: TextField(
              controller: buildingWidthController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(5),
                labelText: 'width of Building-Front',
              ),
              onChanged: (value) {
                width_Building = buildingNameController.text;
                print(width_Building);
              },
            ),
          ),
    
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).accentColor,
              ),
              // focusColor: Theme.of(context).primaryColor,
              hint: Text(
                valueChoose_resi ?? "Residential Building",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor),
              ),
              // onTap:() => {
              //   Navigator.push(context,
              //   MaterialPageRoute(builder: (context) => buildingOptions() ),
              //   )
              // },
              dropdownColor: Theme.of(context).primaryColor,
              value: valueChoose_resi,
              onChanged: (newValue) {
                setState(() {
                  valueChoose_resi = newValue;
                  userChoice.add("Residential Building");
                  userChoice.add(valueChoose_resi);
                  print(userChoice);
                  // Navigator.pop(context);
                });
              },
    
              isExpanded: true,
              items: QuestionScreeen.items_resi.map(buildMenuItem).toList(),
              // onChanged: (value) => setState(
              //     () => this.valueChoose = value),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).accentColor,
              ),
              elevation: 0,
              isExpanded: true,
              hint: Text("Commercial Building",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor)),
              dropdownColor: Theme.of(context).primaryColor,
              value: valueChoose_comm,
              onChanged: (newValue) {
                setState(() {
                  valueChoose_comm = newValue;
                  userChoice.add("Commercial Building");
                  userChoice.add(valueChoose_comm);
                  print(userChoice);
                  // Navigator.pop(context);
                });
              },
              items: QuestionScreeen.items_comm.map(buildMenuItem).toList(),
              // onChanged: (value) => setState(
              //     () => this.value = value),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).accentColor,
              ),
              isExpanded: true,
              hint: Text(
                "Civic Building",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor),
              ),
              dropdownColor: Theme.of(context).primaryColor,
              value: valueChoose_civic,
              onChanged: (newValue) {
                setState(() {
                  valueChoose_civic = newValue;
                  userChoice.add("Civic Building");
                  userChoice.add(valueChoose_civic);
                  print(userChoice);
                  // Navigator.pop(context);
                });
              },
              items: QuestionScreeen.items_civic.map(buildMenuItem).toList(),
              // onChanged: (value) => setState(
              //     () => this.value = value),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).accentColor,
              ),
              isExpanded: true,
              hint: Text(
                "Religious Building",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor),
              ),
              dropdownColor: Theme.of(context).primaryColor,
              value: valueChoose_rel,
              onChanged: (newValue) {
                setState(() {
                  valueChoose_rel = newValue;
                  userChoice.add("Religious Building");
                  userChoice.add(valueChoose_rel);
                  print(userChoice);
                  // Navigator.pop(context);
                });
              },
              items: QuestionScreeen.items_rel.map(buildMenuItem).toList(),
              // onChanged: (value) => setState(
              //     () => this.value = value),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).accentColor,
              ),
              isExpanded: true,
              hint: Text(
                "Others",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor),
              ),
              dropdownColor: Theme.of(context).primaryColor,
              value: valueChoose,
              onChanged: (newValue) {
                setState(() {
                  valueChoose = newValue;
                  userChoice.add("Other Building");
                  userChoice.add(valueChoose);
                  print(userChoice);
    
                  // Navigator.pop(context);
                });
              },
              items: QuestionScreeen.items.map(buildMenuItem).toList(),
              // onChanged: (value) => setState(
              //     () => this.value = value),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.camera_alt),
                  iconSize: 40,
                  color: Theme.of(context).accentColor,
                  onPressed: () => _takePicture(),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.done_rounded),
                  iconSize: 40,
                  color: Theme.of(context).accentColor,
                  onPressed: () async {
                    await getAccessToken();
                    var changesetID = await createChangeset();
                    await changesetUpload(changesetID);
                    await closeChangeset(changesetID).then((value) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => MapApp()));
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),]
    );
  }

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _storedImage = imageFile;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');
    // widget.onSelectImage(savedImage);
  }

  var _accessToken;

  Future<void> getAccessToken() async {
    final response1 = await http.post(
        Uri.parse(
            "https://rezbowjfc4.execute-api.us-east-2.amazonaws.com/dev/api/user.access_token"),
        body: jsonEncode({"email": "test@gmail.com", "password": "test222"}));
    var responseJson1 = jsonDecode(response1.body);
    _accessToken = responseJson1["data"]["token"];
  }

  Future<int> createChangeset() async {
    var _changesetId;
    var changesetCreateString =
        '''<osm><changeset version="0.6" generator="iD"><tag k="comment"
      v="test"/><tag k="created_by" v="RapiD 1.1.0"/><tag k="host" v="http://localhost:3000/"/><tag
      k="locale" v="en-US"/><tag k="imagery_used" v="Bing;mapbox_adb_overlay"/><tags
      k="comment" v="test"/><tags k="created_by" v="RapiD 1.1.0"/><tags k="host"
      v="http://localhost:3000/"/><tags k="locale" v="en-US"/><tags k="imagery_used"
      v="Bing;mapbox_adb_overlay"/></changeset></osm>''';
    var changesetCreateXml = XmlDocument.parse(changesetCreateString);
    final response2 = await http.put(
        Uri.parse(
            "https://rezbowjfc4.execute-api.us-east-2.amazonaws.com/dev/api/changeset.create"),
        headers: {"Authorization": _accessToken},
        body: changesetCreateXml.innerXml);
    var responseJson2 = jsonDecode(response2.body);
    _changesetId = responseJson2["data"]["changeset_id"];

    return (_changesetId as int);
  }

  Future<void> changesetUpload(int changesetId) async {
    var changesetUploadString =
        '''<osmChange version="0.6" generator="iD"><create>''';
    for (int i = 0; i < widget.longarr.length; i++) {
      changesetUploadString +=
          '''<node id="-${6 + i}" lon="${widget.longarr[i]}"
    lat="${widget.latarr[i]}" version="0" changeset="${changesetId}"/>''';
    }
    changesetUploadString +=
        '''<way id="-2" version="0" changeset="${changesetId}"><nd ref="-6"/><nd ref="-7"/><nd ref="-8"/><nd ref="-9"/><nd ref="-6"/><tag k="${userChoice[0]}"
    v="${userChoice[1]}", k="address" v=""/></way></create><modify/><delete if-unused="true"/></osmChange>''';
    var changesetUploadXml = XmlDocument.parse(changesetUploadString);
    final response3 = await http.put(
        Uri.parse(
            "https://rezbowjfc4.execute-api.us-east-2.amazonaws.com/dev/api/changeset.upload/$changesetId"),
        headers: {"Authorization": _accessToken},
        body: changesetUploadXml.innerXml);
  }

  Future<void> closeChangeset(changesetId) async {
    http.post(Uri.parse(
        "https://rezbowjfc4.execute-api.us-east-2.amazonaws.com/dev/api/changeset.close/$changesetId"));
  }
}
