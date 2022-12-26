import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:obeikan_pdf_viewer_plugin/obeikan_pdf_viewer_plugin.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
void main() {
  runApp(MaterialApp(home: const MyApp()));
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => MyApp2(),
            ));
          },
          child: Text("pdf"),
        ),
      ),
    );
  }
}

class MyApp2 extends StatefulWidget {
  const MyApp2({Key? key}) : super(key: key);

  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ObeikanPdfViewerPlugin(
            url: "https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_mobile_about.pdf",
            loadingWidget: const Center(child: CircularProgressIndicator(),),
            annotationsList: const [
              {'id':1,'x': 200,'y': 200,'page': 1},
              {'id':2,'x': 350,'y': 400,'page': 1},
              {'id':3,'x': 350,'y': 450,'page': 2},
              {'id':4,'x': 400,'y': 100,'page': 3},
            ],
            onAnoutationTap: (int id){
              _showMyDialog(id);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
