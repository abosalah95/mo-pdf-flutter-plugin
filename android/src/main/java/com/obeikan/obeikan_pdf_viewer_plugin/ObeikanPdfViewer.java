package com.obeikan.obeikan_pdf_viewer_plugin;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.PointF;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import ir.vasl.magicalpec.utils.Core.MagicalPdfCore;
import ir.vasl.magicalpec.utils.Exceptions.MagicalException;
import ir.vasl.magicalpec.utils.PublicFunction;
import ir.vasl.magicalpec.view.MagicalPdfViewer;
import ir.vasl.magicalpec.viewModel.MagicalPECViewModel;

import com.github.barteksc.pdfviewer.PDFView;
import com.github.barteksc.pdfviewer.link.LinkHandler;
import com.github.barteksc.pdfviewer.listener.OnLoadCompleteListener;
import com.github.barteksc.pdfviewer.listener.OnLongPressListener;
import com.github.barteksc.pdfviewer.listener.OnPageChangeListener;
import com.github.barteksc.pdfviewer.listener.OnPageErrorListener;
import com.github.barteksc.pdfviewer.listener.OnTapListener;
import com.github.barteksc.pdfviewer.model.LinkTapEvent;
import com.github.barteksc.pdfviewer.scroll.DefaultScrollHandle;

import org.benjinus.pdfium.Meta;
import org.json.JSONException;
import org.json.JSONObject;


public class ObeikanPdfViewer implements PlatformView, MethodChannel.MethodCallHandler, OnPageErrorListener, OnLoadCompleteListener, OnPageChangeListener, OnLongPressListener, LinkHandler, OnTapListener {

    private MethodChannel channel;
    public static final String STREAM = "com.obeikan.obeikan_pdf_viewer_plugin/eventChannel";
    private EventChannel.EventSink attachEvent;
    private EventChannel annotationClickedEventChannel;
    private Uri currUri ;

    private static final String TAG = "mo";

    @NonNull
    private MagicalPdfViewer pdfViewer;
    private ProgressBar progressBar;
    private PDFView.Configurator configurator = null;

    Context activityContext;
    int currentPage = 0 ;




    ObeikanPdfViewer(@NonNull Context context,Context activityContext, BinaryMessenger messenger, EventChannel.EventSink attachEvent, int id, @Nullable Map<String, Object> creationParams) {
        Log.e("mosalah","Obeikan PdfViewer constructor");
        this.activityContext=activityContext;
        this.attachEvent=attachEvent;
        Log.e("TAG_NAME123", attachEvent+"");

        pdfViewer = new MagicalPdfViewer(context,null);
        progressBar= new ProgressBar(context);
        channel = new MethodChannel(messenger, "obeikan_pdf_viewer_plugin");
        channel.setMethodCallHandler(this);
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("setPdfViewerFile")) {
            currUri = Uri.fromFile(new File(call.argument("filePath").toString()));
            displayFileFromUri();
            result.success(true);
        }else if (call.method.equals("drawPoints")) {
            ArrayList annotations = call.argument("annotationsList");
            for(int i = 0 ; i < annotations.size() ; i++){
                Log.e("mosalah",annotations.get(i).toString());
                HashMap obj = (HashMap) annotations.get(i);
                PointF point= new PointF(
                        Float.parseFloat(obj.get("x").toString()),
                        Float.parseFloat(obj.get("y").toString())
                );
                handleAddAnnotation(point,obj.get("id").toString(),Integer.parseInt(obj.get("page").toString()));
            }
            result.success("AnnotationDrew");
        } else {
            result.notImplemented();
        }
    }


    @Override
    public View getView() {
        return pdfViewer;
    }

    @Override
    public void dispose() {}

    public void displayFileFromUri() {
        Log.e("mosalah","displayFileFromUri");
        if (currUri==null)return;
        this.configurator = pdfViewer.fromUri(currUri)
                .defaultPage(currentPage)
                .onPageChange(this)
                .enableAnnotationRendering(true)
                .onLoad(this)
                .enableSwipe(true)
                .scrollHandle(new DefaultScrollHandle(activityContext))
                .spacing(10) // in dp
                .onPageError(this)
                .onTap(this)
                .onLongPress(this)
                .linkHandler(this);

        this.configurator.load();
    }

    @Override
    public void handleLinkEvent(LinkTapEvent event) {
//        channel.invokeMethod("AnnotationTapped",null);
        Toast.makeText(activityContext, event.getLink().getUri(), Toast.LENGTH_SHORT).show();


        attachEvent.success(Integer.parseInt(event.getLink().getUri()));
    }

    @Override
    public void loadComplete(int nbPages) {
        Meta meta = pdfViewer.getDocumentMeta();
        Log.e(TAG, "title = " + meta.getTitle());
        Log.e(TAG, "author = " + meta.getAuthor());
        Log.e(TAG, "subject = " + meta.getSubject());
        Log.e(TAG, "keywords = " + meta.getKeywords());
        Log.e(TAG, "creator = " + meta.getCreator());
        Log.e(TAG, "producer = " + meta.getProducer());
        Log.e(TAG, "creationDate = " + meta.getCreationDate());
        Log.e(TAG, "modDate = " + meta.getModDate());

        pdfViewer.setMinZoom(1f);
        pdfViewer.setMidZoom(5f);
        pdfViewer.setMaxZoom(10f);
        pdfViewer.zoomTo(1f);

    }

    @Override
    public void onLongPress(MotionEvent e) {
        Log.e("mosalah","onLongPress");
//        String referenceHash = new StringBuilder()
//                .append("ReferenceHash:")
//                .append(UUID.randomUUID().toString())
//                .toString(); // generate reference hash
//        Log.e("mosalah:",referenceHash);
//        handleAddAnnotation(new PointF(50,70),referenceHash);
    }

    @Override
    public void onPageChanged(int page, int pageCount) {
        currentPage=page;

    }

    @Override
    public void onPageError(int page, Throwable t) {
        Toast.makeText(activityContext, "Error at page: $page", Toast.LENGTH_SHORT).show();
    }

    @Override
    public boolean onTap(MotionEvent e) {
        return false;
    }

    public void handleAddAnnotation(PointF point,String id,int page) {


        byte[] OCGCover = PublicFunction.getByteFromDrawable(getView().getContext(), R.drawable.ic_logo_v4);

        addAnnotation(point,currUri,page,id, OCGCover,50,50);
    }

    private void addAnnotation(PointF pointF, Uri uri, int currPage, String referenceHash, byte[] OCGCover, float OCGWidth, float OCGHeight) {
        new Handler().post(new Runnable() {
            @Override
            public void run() {
                try {
                    Log.e("mosalah:","is start");
                    MagicalPdfCore.getInstance().addOCG(activityContext, pointF, uri, currPage, referenceHash, OCGCover, OCGWidth, OCGHeight);
                    Log.e("mosalah:","is add success");
                    displayFileFromUri();
                } catch (MagicalException e) {
                    e.printStackTrace();
                    Log.e("mosalah:",e.toString());
                }
            }
        });
    }
}
