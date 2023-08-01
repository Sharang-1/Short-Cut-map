import 'dart:io';
import 'dart:convert';

import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

import '/main.dart';

class RoadQuestion extends StatefulWidget {
  static const items_roadmat = [
    'Asphalt',
    'Gravel',
    'Metal',
    'Dirt-Grass',
    'Concrete'
  ];
  List<double> latarr = [];
  List<double> longarr = [];

  RoadQuestion({@required this.latarr, @required this.longarr});
  @override
  State<RoadQuestion> createState() => _RoadQuestionState();
}

class _RoadQuestionState extends State<RoadQuestion> {
  TextEditingController laneController = TextEditingController();
  String valueChoose_material;
  var valueChoose_lanes;
  File _storedImage;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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
              "Road Material",
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
            value: valueChoose_material,
            onChanged: (newValue) {
              setState(() {
                valueChoose_material = newValue;
                // userChoice.add("Residential Building");
                // userChoice.add(valueChoose_resi);
                print(valueChoose_material);
                // Navigator.pop(context);
              });
            },

            isExpanded: true,
            items: RoadQuestion.items_roadmat.map(buildMenuItem).toList(),
            // onChanged: (value) => setState(
            //     () => this.valueChoose = value),
          ),
        ),
        Container(
          transformAlignment: Alignment.center,
          child: TextField(
            controller: laneController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(5),
              labelText: 'Number of lanes: ',
            ),
            onChanged: (value) {
              valueChoose_lanes = laneController.text;
              print(valueChoose_lanes);
            },
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
        '''<way id="-2" version="0" changeset="${changesetId}"><nd ref="-6"/><nd ref="-7"/><nd ref="-8"/><nd ref="-9"/><nd ref="-6"/><tag k="Road"
    v="${valueChoose_material}"/></way></create><modify/><delete if-unused="true"/></osmChange>''';
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
