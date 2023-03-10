package com.obeikan.obeikan_pdf_viewer_plugin;



import android.util.Log;

import androidx.annotation.NonNull;



import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformViewRegistry;


/** ObeikanPdfViewerPlugin */
public class ObeikanPdfViewerPlugin extends FlutterActivity implements FlutterPlugin, ActivityAware {

  private PlatformViewRegistry mRegistry;
  private BinaryMessenger mMessenger;
  private MethodChannel mMethodChannel;
//  public static final String STREAM = "com.obeikan.obeikan_pdf_viewer_plugin/eventChannel";
//  private EventChannel annotationClickedEventChannel;
//  private EventChannel.EventSink attachEvent;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mMessenger = flutterPluginBinding.getBinaryMessenger();
    mRegistry = flutterPluginBinding.getPlatformViewRegistry();
    mMethodChannel = new MethodChannel(mMessenger, "pdftron_flutter");
    flutterPluginBinding
            .getPlatformViewRegistry()
            .registerViewFactory("salah", new ObeikanPdfViewerFactory(flutterPluginBinding.getBinaryMessenger(),flutterPluginBinding.getApplicationContext()));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }


  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    Log.e("mosalah","onAttachedToActivity");

    mRegistry.registerViewFactory("salah", new ObeikanPdfViewerFactory(mMessenger,binding.getActivity()));
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Log.e("mosalah","onDetachedFromActivityForConfigChanges");
    mRegistry = null;
    mMessenger = null;
    mMethodChannel.setMethodCallHandler(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    Log.e("mosalah","onReattachedToActivityForConfigChanges");

    mRegistry.registerViewFactory("salah", new ObeikanPdfViewerFactory(mMessenger,binding.getActivity()));

  }

  @Override
  public void onDetachedFromActivity() {
    Log.e("mosalah","onDetachedFromActivity");
  }

}
