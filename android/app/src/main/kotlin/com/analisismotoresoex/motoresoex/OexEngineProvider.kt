package com.analisismotoresoex.motoresoex

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.File
import java.io.FileNotFoundException

class OexEngineProvider : ContentProvider() {

    companion object {
        private const val TAG = "OexEngineProvider"
    }

    override fun onCreate(): Boolean {
        Log.i(TAG, "onCreate called")
        val ctx = context ?: run {
            Log.e(TAG, "onCreate: context is null")
            return true
        }
        Log.i(TAG, "onCreate: authority=${OexEngineRegistry.authority(ctx)}, nativeLibraryDir=${ctx.applicationInfo.nativeLibraryDir}")
        return true
    }

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor {
        Log.i(TAG, "openFile called: uri=$uri, mode=$mode, callingPackage=${callingPackage}")
        if (mode != "r") {
            Log.e(TAG, "openFile: unsupported mode '$mode'")
            throw FileNotFoundException("Only read mode is supported")
        }

        val appContext = context ?: throw FileNotFoundException("Context unavailable")

        // Extract filename from the last non-empty path segment
        val fileName = uri.pathSegments?.lastOrNull { it.isNotEmpty() }
            ?: throw FileNotFoundException("Missing file name in URI: $uri")
        Log.d(TAG, "openFile: resolved fileName=$fileName from uri=$uri")

        val engine = OexEngineRegistry.findExportedEngine(fileName)
            ?: run {
                Log.e(TAG, "openFile: unknown engine '$fileName'. Available: ${OexEngineRegistry.advertisedEngines().map { it.exportFileName }}")
                throw FileNotFoundException("Unknown engine: $fileName")
            }

        // Serve from nativeLibraryDir (where jniLibs are installed)
        val file = File(appContext.applicationInfo.nativeLibraryDir, engine.exportFileName)
        if (!file.exists()) {
            Log.e(TAG, "openFile: engine binary not found at ${file.absolutePath}")
            throw FileNotFoundException("Engine binary not found: ${file.absolutePath}")
        }

        Log.i(TAG, "openFile: serving ${file.absolutePath} (${file.length()} bytes, exec=${file.canExecute()})")
        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    }

    override fun getType(uri: Uri): String {
        Log.d(TAG, "getType called: uri=$uri")
        return "application/x-chess-engine"
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?,
    ): Cursor {
        Log.i(TAG, "query called: uri=$uri, projection=${projection?.toList()}, callingPackage=${callingPackage}")

        val appContext = context
            ?: run {
                Log.e(TAG, "query: context is null")
                return MatrixCursor(arrayOf("name", "filename", "targets"))
            }

        val columns = arrayOf("name", "filename", "targets", "authority")
        val cursor = MatrixCursor(columns)

        OexEngineRegistry.advertisedEngines()
            .filter { OexEngineRegistry.isCompatible(it) }
            .forEach { engine ->
                cursor.addRow(arrayOf(
                    engine.displayName,
                    engine.exportFileName,
                    engine.targets.joinToString("|"),
                    OexEngineRegistry.authority(appContext),
                ))
                Log.i(TAG, "query: added engine '${engine.displayName}' file='${engine.exportFileName}' targets='${engine.targets.joinToString("|")}'")
            }

        Log.i(TAG, "query: returning ${cursor.count} engines")
        return cursor
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?,
    ): Int = 0
}