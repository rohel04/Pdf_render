package com.example.match_test

import android.annotation.SuppressLint
import io.flutter.embedding.android.FlutterActivity
import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException

class MainActivity: FlutterActivity() {
    private val channel = "pdf_renderer"
    @SuppressLint("SdCardPath")
    private val pdfFilePath="/data/user/0/com.example.match_test/app_flutter/pdf/random.pdf"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPageCount" -> {
//                    val filePath = call.arguments<String>()
                    try {
                        val pageCount = getPageCount()
                        result.success(pageCount)
                    } catch (e: IOException) {
                        result.error("UNAVAILABLE", "PDF file not available.", null)
                    }
                }

                "renderPage" -> {
//                    val path = call.argument<String>("filePath")
//                    val pageNumber = call.argument<Int>("pageNumber")
                    try {
                        val pageImage = renderPage()
                        result.success(pageImage)
                    } catch (e: IOException) {
                        result.error("UNAVAILABLE", "PDF file not available.", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    @Throws(IOException::class)
    private fun getPageCount(): Int {
        val file = File(pdfFilePath)
        val fileDescriptor = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        val renderer = PdfRenderer(fileDescriptor)
        val pageCount = renderer.pageCount
        renderer.close()
        fileDescriptor.close()
        return pageCount
    }

    @Throws(IOException::class)
    private fun renderPage(): List<ByteArray> {
        val byteArrays = mutableListOf<ByteArray>()
        val file = File(pdfFilePath)
        val fileDescriptor = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        val renderer = PdfRenderer(fileDescriptor)

        for (i in 0 until renderer.pageCount) {
            val page = renderer.openPage(i)

            // Increase resolution by setting a higher scale
            val scale = 2f  // Change this value to adjust the quality
            val width = (page.width * scale).toInt()
            val height = (page.height * scale).toInt()

            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val matrix = android.graphics.Matrix()
            matrix.postScale(scale, scale)
            page.render(bitmap, null, matrix, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            val byteArray = stream.toByteArray()
            byteArrays.add(byteArray)
            page.close()


        }
        renderer.close()
        fileDescriptor.close()
        return byteArrays
    }
}
