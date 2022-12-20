import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obeikan_pdf_viewer_plugin/obeikan_pdf_viewer_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('obeikan_pdf_viewer_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await ObeikanPdfViewerPlugin.platformVersion, '42');
  // });
}
