import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';

import 'road.dart';
import 'node.dart';
import 'changeset.dart';
import 'building.dart';

class Polygons with ChangeNotifier {
  List<Node> _nodes = [];
  List<ChangeSet> _changesets = [];
  List<Building> _buildings = [];
  List<Road> _roads = [];

  List<Node> get nodes {
    return [..._nodes];
  }

  List<ChangeSet> get changesets {
    return [..._changesets];
  }

  List<Building> get buildings {
    return [..._buildings];
  }

  List<Road> get roads {
    return [..._roads];
  }

  Future<void> fetchAndSetPolygons(String location) async {
    final url = Uri.parse(
        'https://rezbowjfc4.execute-api.us-east-2.amazonaws.com/dev/api/map.bbox?bbox=$location');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }
      final List<Node> loadedNodes = [];
      final List<ChangeSet> loadedChangeSets = [];

      List<dynamic> elements = extractedData["elements"];

      for (int i = 0; i < elements.length; i++) {
        if (elements[i]["type"] == "node") {
          loadedNodes.add(Node(
            id: elements[i]["id"],
            coordinates: LatLng(elements[i]["lat"], elements[i]["lon"]),
          ));
        } else if (elements[i]["type"] != "node") {
          loadedChangeSets.add(ChangeSet(
            id: elements[i]["id"],
            changesetId: elements[i]["changeset"],
            nodesID: elements[i]["nodes"],
          ));
        }
      }
      _nodes = loadedNodes;
      _changesets = loadedChangeSets;
      AddBuilding();
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  void AddBuilding() {
    List<dynamic> nodesID = [];
    List<LatLng> latlog = [];
    for (int i = 0; i < _changesets.length; i++) {
      nodesID = _changesets[i].nodesID;
      for (int j = 0; j < nodesID.length; j++) {
        for (int k = 0; k < _nodes.length; k++) {
          if (nodesID[j] == _nodes[k].id) {
            latlog.add(_nodes[k].coordinates);
          }
        }
      }
      _buildings.add(Building(id: _changesets[i].id, latlog: latlog));
      latlog = [];
    }
    notifyListeners();
  }

  void AddRoad() {
    List<dynamic> nodesID = [];
    List<LatLng> latlog = [];
    for (int i = 0; i < _changesets.length; i++) {
      nodesID = _changesets[i].nodesID;
      for (int j = 0; j < nodesID.length; j++) {
        for (int k = 0; k < _nodes.length; k++) {
          if (nodesID[j] == _nodes[k].id) {
            latlog.add(_nodes[k].coordinates);
          }
        }
      }
      _roads.add(Road(id: _changesets[i].id, latlog: latlog));
      latlog = [];
    }
    notifyListeners();
  }
}
