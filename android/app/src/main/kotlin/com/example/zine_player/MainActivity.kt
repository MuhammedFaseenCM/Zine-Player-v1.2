package com.example.zine_player

import android.content.ContentUris
import android.graphics.Bitmap
import android.net.Uri
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import java.util.concurrent.TimeUnit
import android.util.Size
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val DEVICE_INFO_CHANNEL = "com.example.zine_player/device_info"
    private val MEDIA_STORE_CHANNEL = "com.example.zine_player/media_store"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_INFO_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAndroidSDKVersion") {
                result.success(Build.VERSION.SDK_INT)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_STORE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getVideos") {
                result.success(getVideosFromMediaStore())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getVideosFromMediaStore(): List<Map<String, Any>> {
        val videos = mutableListOf<Map<String, Any>>()
        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.SIZE,
            MediaStore.Video.Media.MIME_TYPE,
            MediaStore.Video.Media.BUCKET_DISPLAY_NAME,
            MediaStore.Video.Media.BUCKET_ID,
            MediaStore.Video.Media.DATA 
        )
        val selection = "${MediaStore.Video.Media.DURATION} >= ?"
        val selectionArgs = arrayOf(
            TimeUnit.MILLISECONDS.convert(1, TimeUnit.SECONDS).toString()
        )
        val sortOrder = "${MediaStore.Video.Media.DATE_ADDED} DESC"

        val query = contentResolver.query(
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            sortOrder
        )

        query?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
            val nameColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
            val durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)
            val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
            val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.MIME_TYPE)
            val bucketNameColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.BUCKET_DISPLAY_NAME)
            val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val name = cursor.getString(nameColumn)
                val duration = cursor.getLong(durationColumn)
                val size = cursor.getLong(sizeColumn)
                val mimeType = cursor.getString(mimeTypeColumn)
                val folderName = cursor.getString(bucketNameColumn)
                val fullPath = cursor.getString(dataColumn)
                val folderPath = fullPath.substring(0, fullPath.lastIndexOf("/"))
            
                val contentUri = ContentUris.withAppendedId(
                    MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                    id
                )
                val thumbnail = getThumbnail(contentUri)
                val videoMap = mutableMapOf<String, Any>(
                    "id" to id.toString(),
                    "name" to name,
                    "uri" to contentUri.toString(),
                    "duration" to duration,
                    "size" to size,
                    "mimeType" to mimeType,
                    "folderPath" to folderPath,
                    "folderName" to folderName
                )
                thumbnail?.let { videoMap["thumbnail"] = it }
                videos.add(videoMap)
            }
        }

        return videos
    }

    private fun getThumbnail(uri: Uri): ByteArray? {
        return try {
            val thumbnail = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                contentResolver.loadThumbnail(uri, Size(96, 96), null)
            } else {
                MediaStore.Video.Thumbnails.getThumbnail(
                    contentResolver,
                    ContentUris.parseId(uri),
                    MediaStore.Video.Thumbnails.MINI_KIND,
                    null
                )
            }
            val stream = ByteArrayOutputStream()
            thumbnail.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }
}