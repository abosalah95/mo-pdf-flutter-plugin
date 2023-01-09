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
        child: Column(
          children: [
            RaisedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyApp2(url:"http://ebooks.syncfusion.com/downloads/flutter-succinctly/flutter-succinctly.pdf"),
                ));
              },
              child: Text("pdf"),
            ),
            RaisedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyApp2(url:"https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_mobile_about.pdf"),
                ));
              },
              child: Text("pdf2"),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp2 extends StatefulWidget {
   MyApp2({Key? key,required this.url}) : super(key: key);
  String url;
  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {

  late PDFViewController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PDFViewController();
    getn();
  }

  Future<void> getn() async {
    int? y = await _pdfViewerController.getCurrentPage();
    print (y);
    int? x =await _pdfViewerController.getPageCount();
    print (x) ;
    await _pdfViewerController.setPage(10);
    y = await _pdfViewerController.getCurrentPage();
    print (y);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            IconButton(onPressed: () async {
              print (await _pdfViewerController.getCurrentPage()) ;
              print (await _pdfViewerController.getPageCount()) ;
              await _pdfViewerController.setPage(0);
              print (await _pdfViewerController.getCurrentPage()) ;
            }, icon: Icon(Icons.notifications))
          ],
        ),
        body: ObeikanPdfViewerPlugin(
          lang:'ar',
          url: widget.url,
          annotationsList: const [
            {'id':1,'x': 200,'y': 200,'page': 1},
            {'id':2,'x': 350,'y': 400,'page': 1},
            {'id':3,'x': 350,'y': 450,'page': 2},
            {'id':4,'x': 400,'y': 100,'page': 3},
          ],
          onAnoutationTap: (int id){
            _showMyDialog(id);
          }, onBookLoaded: () {  },
          onPageChanged: (int pageNum) {  },
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
                _pdfViewerController.getCurrentPage().then((value) {
                  print(value);
                }) ;
                print (_pdfViewerController.getPageCount()) ;
                print (_pdfViewerController.setPage(10)) ;
                print (_pdfViewerController.getCurrentPage()) ;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
