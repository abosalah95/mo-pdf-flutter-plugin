
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class ObeikanPdfViewerPlugin extends StatefulWidget{
  ObeikanPdfViewerPlugin({
    Key? key, required this.url,
    required this.lang,
    required this.onAnoutationTap,
    required this.onPageChanged,
    required this.onBookLoaded,
    this.annotationsList}) : super(key: key);
  String url ;
  String lang ;
  Function(int id) onAnoutationTap;
  Function(int pageNum) onPageChanged;
  Function() onBookLoaded;
  List<Map<String,dynamic>>? annotationsList;
  @override
  State<ObeikanPdfViewerPlugin> createState() => _ObeikanPdfViewerPluginState();
}

class _ObeikanPdfViewerPluginState extends State<ObeikanPdfViewerPlugin> {

  static const platform = MethodChannel('obeikan_pdf_viewer_plugin');


  @override
  void initState() {
    super.initState();
    initMethodChannelCall();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  initMethodChannelCall() async {
    await getFileAndPassToPdfViewer();
    platform.setMethodCallHandler(_onMethodCall);
  }

  Future<bool?> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'AnnotationTapped':
        widget.onAnoutationTap(1);
        return null;
      case 'onPageChanged':
        widget.onPageChanged(1);
        return null;
      case 'onBookLoaded':
        widget.onBookLoaded();
        return null;
    }
    throw MissingPluginException(
        '${call.method} was invoked but has no handler');
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
                    // isLoading=false;
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

    return Stack(
      children: [
        AndroidView(
          viewType: viewType,
          layoutDirection: widget.lang=='ar'?TextDirection.rtl:TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      ],
    );
  }
}


class PDFViewController {
  PDFViewController();

  final MethodChannel _channel = const MethodChannel('obeikan_pdf_viewer_plugin');


  Future<int?> getPageCount() async {
    final int? pageCount = await _channel.invokeMethod('pageCount');
    return pageCount;
  }

  Future<int?> getCurrentPage() async {
    final int? currentPage = await _channel.invokeMethod('currentPage');
    return currentPage;
  }

  Future<bool?> setPage(int page) async {
    final bool? isSet =
    await _channel.invokeMethod('setPage', <String, dynamic>{
      'page': page,
    });
    return isSet;
  }
}



