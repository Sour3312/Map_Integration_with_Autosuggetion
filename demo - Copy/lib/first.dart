// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literal, non_constant_identifier_names, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables

//last wala yehi hai

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mapmyindia_gl/mapmyindia_gl.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  // ==========Declared global variables==================
  var userInput, AT, request, myToken, sorted, acc_tok, SortedData, ApiData;

// =============1st Function for token generation===============================
  getToken() async {
    print("getToken called");
    request = https.Request(
        'POST',
        Uri.parse(
            'https://outpost.mapmyindia.com/api/security/oauth/token?grant_type=client_credentials&client_id=33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==&client_secret=lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww'));
    https.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var statusOfRespnse = response.reasonPhrase;
      print("Your current status is : $statusOfRespnse");

      AT = await response.stream.bytesToString();
      myToken = json.decode(AT);
      // print("MyToken: ${myToken}");

      acc_tok = myToken["access_token"];
      print("Your access token is: ${acc_tok}");
    } else {
      print(response.reasonPhrase);
    }
    getApi(userInput);
  }

//==============2nd  Function for calling API===================================
  getApi(value) async {
    final respon = await https.get(
        Uri.parse(
            'https://atlas.mappls.com/api/places/search/json?query=kerela'),
        headers: {
          'Access-Control-Allow-Origin': "*",
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS',
          'cors': '*',
          HttpHeaders.authorizationHeader: "bearer ${acc_tok}",
        });
    ApiData = await json.decode(respon.body);
    print(ApiData);
    return ApiData;
  }

//==============Map integration starts here=====================================
  final Completer<MapmyIndiaMapController> _controller = Completer();

  final CameraPosition _MmiPlex = CameraPosition(
      target: LatLng(22.805529670433828, 86.20229974835348), zoom: 9);

  @override
  void initState() {
    MapmyIndiaAccountManager.setMapSDKKey("${acc_tok}");
    MapmyIndiaAccountManager.setRestAPIKey("47e0624fbd6e55e8dd13e4453f089aa7");
    MapmyIndiaAccountManager.setAtlasClientId(
        "33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==");
    MapmyIndiaAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww");
    super.initState();
  }

//===============Main body starts here==========================================
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Scaffold(
          // =========AppBar==============
          appBar: AppBar(
              backgroundColor: Colors.green,
              titleSpacing: 40.0,
              title: Column(children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: TextField(
                      onChanged: (value) {
                        userInput = value;
                        print("userInput is: $userInput");
                        setState(() {
                          getToken();
                        });
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                userInput = Null;
                                print("pressed");
                              });
                            },
                          ),
                          hintText: 'Search here...',
                          border: InputBorder.none),
                    ),
                  ),
                ),
                //
              ])),

// =========Body==============
          body: MapmyIndiaMap(
              initialCameraPosition: _MmiPlex,
              myLocationRenderMode: MyLocationRenderMode.COMPASS,
              compassEnabled: true,
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.NoneCompass,
              onMapCreated: (MapmyIndiaMapController controller) {
                _controller.complete(controller);
              }),
        ),
      ),
    );
  }
}
