package com.example.tablookuser;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.widget.ImageView;
import android.widget.MediaController;
import android.widget.Toast;
import android.widget.VideoView;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.storage.FileDownloadTask;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;

import static java.security.AccessController.getContext;

public class MainActivity extends AppCompatActivity {

    private FirebaseStorage firebaseStorage;
    private FirebaseFirestore firebaseFirestore;
    private StorageReference storageReference;
    private ImageView imageView;
    private VideoView videoView;
    private Uri imageUri, videoUri;
    private ArrayList<String> imageIds, videoIds, oldImageIds, oldVideoIds;
    private ArrayList<Media> mediaArrayList;
    private Timer timer = new Timer();

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        firebaseFirestore = FirebaseFirestore.getInstance();
        firebaseStorage = FirebaseStorage.getInstance();
        storageReference = firebaseStorage.getReference();
        imageView = findViewById(R.id.imageView);
        videoView = findViewById(R.id.videoView);
        imageView = findViewById(R.id.imageView);
        videoView = findViewById(R.id.videoView);
        imageIds = new ArrayList<>();
        videoIds = new ArrayList<>();
        oldImageIds = new ArrayList<>();
        oldVideoIds = new ArrayList<>();
        mediaArrayList = new ArrayList<>();
        Timer t = new java.util.Timer();
        t.schedule(
                new java.util.TimerTask() {
                    @Override
                    public void run() {
                        System.out.println("DENO");
                        getImagesFromStorage();
                        getVideosFromStorage();
                    }
                },
                0,5000
        );
        t.schedule(
                new java.util.TimerTask() {
                    @Override
                    public void run() {
                        System.out.println("CEM");
                        if (!videoView.isPlaying()) showMedia();

                    }
                },
                0,6000
        );

    }


    private void getImagesFromStorage()
    {
        firebaseFirestore.collection("images")
                .get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (task.isSuccessful()) {
                            for (QueryDocumentSnapshot document : task.getResult()) {
                                String name = document.getId();
                                imageIds.add(name);
                            }
                            for (String x : imageIds ) {
                                if (!oldImageIds.contains(x))
                                {
                                    String link = "images/" + x;
                                    StorageReference newRef = storageReference.child(link);

                                    File localFile = null;
                                    try
                                    {
                                        localFile = File.createTempFile(x, ".jpg");
                                        imageUri = Uri.fromFile(localFile);
                                        System.out.println(localFile.toString() + "buaraya");
                                    }
                                    catch (IOException e)
                                    {
                                        e.printStackTrace();
                                    }
                                    newRef.getFile(localFile).addOnSuccessListener(new OnSuccessListener<FileDownloadTask.TaskSnapshot>() {
                                        @Override
                                        public void onSuccess(FileDownloadTask.TaskSnapshot taskSnapshot) {
                                            System.out.println("Image is downloaded.");
                                            Media newImage = new Media(x,0,imageUri);
                                            mediaArrayList.add(newImage);
                                        }
                                    }).addOnFailureListener(new OnFailureListener() {
                                        @Override
                                        public void onFailure(@NonNull Exception exception) {
                                            System.out.println("Image cannot be downloaded.");
                                        }
                                    });
                                }
                            }
                            System.out.println(imageIds + "imageIdArray");
                            if (!oldImageIds.containsAll(imageIds))
                            {
                                for (String newS : imageIds) {
                                    if (!oldImageIds.contains(newS))
                                    {
                                        oldImageIds.add(newS);
                                    }
                                }

                            }
                            imageIds.clear();
                            System.out.println(oldImageIds + "oldImagesArray");
                        } else {
                            Log.d("ana","hata");
                        }
                    }
                });


    }

    public void getVideosFromStorage()
    {
        firebaseFirestore.collection("videos")
                .get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (task.isSuccessful()) {
                            for (QueryDocumentSnapshot document : task.getResult()) {
                                String name = document.getId();
                                videoIds.add(name);
                            }
                            for (String x : videoIds ) {
                                if (!oldVideoIds.contains(x))
                                {
                                    String link = "videos/" + x;
                                    StorageReference newRef = storageReference.child(link);

                                    File localFile = null;
                                    try {
                                        localFile = File.createTempFile(x, ".mp4");
                                        videoUri = Uri.fromFile(localFile);
                                        System.out.println(localFile.toString() + "buaraya");
                                    } catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                    newRef.getFile(localFile).addOnSuccessListener(new OnSuccessListener<FileDownloadTask.TaskSnapshot>() {
                                        @Override
                                        public void onSuccess(FileDownloadTask.TaskSnapshot taskSnapshot) {
                                            System.out.println("Video is downloaded.");
                                            Media newImage = new Media(x,1,videoUri);
                                            mediaArrayList.add(newImage);
                                        }
                                    }).addOnFailureListener(new OnFailureListener() {
                                        @Override
                                        public void onFailure(@NonNull Exception exception) {
                                            System.out.println("Video cannot be downloaded.");
                                        }
                                    });
                                }
                            }
                            System.out.println(videoIds + "videoIdArray");
                            if (!oldVideoIds.containsAll(videoIds))
                            {
                                for (String newV : videoIds) {
                                    if (!oldVideoIds.contains(newV))
                                    {
                                        oldVideoIds.add(newV);
                                    }
                                }

                            }
                            videoIds.clear();
                            System.out.println(oldVideoIds + "oldVideosArray");
                        } else {
                            Log.d("ana","hata");
                        }
                    }
                });
    }


    private void showMedia()
    {
        if(!mediaArrayList.equals(null))
        {
            System.out.println(mediaArrayList.size()+ "Size:");
            for (int i = 0 ; i < mediaArrayList.size() ; i++)
            {
                Media media = mediaArrayList.get(i);
                if (media.type == 0)
                {
                    Handler mainHandler = new Handler(getApplicationContext().getMainLooper());
                    Runnable myRunnable = new Runnable() {
                        @Override
                        public void run() {
                            imageView.setImageURI(media.mediaUri);
                        }
                    };
                    mainHandler.post(myRunnable);
                }
                else if (media.type == 1)
                {
                    Handler mainHandler = new Handler(getApplicationContext().getMainLooper());
                    Runnable myRunnable = new Runnable() {
                        @Override
                        public void run() {
                            videoView.setVideoURI(media.mediaUri);
                            videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                                @Override
                                public void onPrepared(MediaPlayer mp) {
                                    mp.setLooping(true);
                                    videoView.start();
                                }
                            });
                        }
                    };
                    mainHandler.post(myRunnable);
                }

            }
        }

    }
}
