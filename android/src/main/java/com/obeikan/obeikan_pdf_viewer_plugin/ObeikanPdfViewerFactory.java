package com.obeikan.obeikan_pdf_viewer_plugin;
import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.lang.ref.WeakReference;
import java.util.Map;


public class ObeikanPdfViewerFactory extends PlatformViewFactory{
    private final BinaryMessenger messenger;
    private final WeakReference<Context> mContextRef;


    public ObeikanPdfViewerFactory(BinaryMessenger messenger, Context activityContext) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        mContextRef = new WeakReference<>(activityContext);
    }

    @SuppressWarnings("unchecked")
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new ObeikanPdfViewer(context, mContextRef.get(), messenger , id , creationParams);
    }
}
