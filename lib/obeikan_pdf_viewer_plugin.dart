
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class ObeikanPdfViewerPlugin extends StatefulWidget{
  ObeikanPdfViewerPlugin({Key? key, required this.url, required this.loadingWidget,required this.onAnoutationTap, this.annotationsList}) : super(key: key);
  String url ;
  Function(int id) onAnoutationTap;
  List<Map<String,dynamic>>? annotationsList;
  Widget loadingWidget;
  @override
  State<ObeikanPdfViewerPlugin> createState() => _ObeikanPdfViewerPluginState();
}

class _ObeikanPdfViewerPluginState extends State<ObeikanPdfViewerPlugin> {

  static const platform = MethodChannel('obeikan_pdf_viewer_plugin');
  static const stream = EventChannel('com.obeikan.obeikan_pdf_viewer_plugin/eventChannel');

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initMethodChannelCall();
  }

  late StreamSubscription _streamSubscription;

  void _startListener() {
    print("_startListener");
    _streamSubscription = stream.receiveBroadcastStream().listen(_listenStream);
  }

  void _cancelListener() {
    _streamSubscription.cancel();
  }

  void _listenStream(value) {
    debugPrint("Received From Native:  $value\n");
    widget.onAnoutationTap(value);
  }


  initMethodChannelCall() async {
    await getFileAndPassToPdfViewer();
    setState(() {
      isLoading=false;
    });
    _startListener();
  }

  Future<void> drawAnnotation() async {
    try {
      final result = await platform.invokeMethod('drawPoints', {
        'annotationsList':widget.annotationsList,
      });
        print(result);
    } on PlatformException catch (e) {
      print("Failed to get pdf");
    }

  }

  Future<bool> getFileAndPassToPdfViewer()async{
    if(widget.url!=""){
      requestPersmission();
      getFileFromUrl(widget.url).then(
            (value) async{
              try {
                final result = await platform.invokeMethod('setPdfViewerFile', {'filePath': value.path});
                if(result){
                  setState(() {
                    isLoading=false;
                    drawAnnotation();
                  });
                }
              } on PlatformException catch (e) {
                print("Failed to get pdf");
              }
        },
      );
    }
    return true;
  }

  Future<File> getFileFromUrl(String url, {name}) async {
    var fileName = 'testonline';
    if (name != null) {
      fileName = name;
    }
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" + fileName + ".pdf");
      print(dir.path);
      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  void requestPersmission() async {
    await Permission.storage.request();
  }

  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'salah';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return isLoading?widget.loadingWidget: AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }


}
