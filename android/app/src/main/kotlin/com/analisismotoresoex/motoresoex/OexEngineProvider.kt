package com.analisismotoresoex.motoresoex

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileNotFoundException

class OexEngineProvider : ContentProvider() {
    override fun onCreate(): Boolean {
        return true
    }

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor {
        if (!mode.contains("r")) {
            throw FileNotFoundException("Only read mode is supported")
        }

        val appContext = context ?: throw FileNotFoundException("Context unavailable")

        // Extract filename from the last non-empty path segment
        val fileName = uri.pathSegments?.lastOrNull { it.isNotEmpty() }
            ?: throw FileNotFoundException("Missing file name in URI: $uri")

        val engine = OexEngineRegistry.findExportedEngine(fileName)
            ?: throw FileNotFoundException("Unknown engine: $fileName")

        val file = OexEngineRegistry.getEngineFile(appContext, engine.exportFileName)
        if (!file.exists()) {
            throw FileNotFoundException("Engine binary not found: ${file.absolutePath}")
        }

        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    }

    override fun getType(uri: Uri): String {
        return "application/x-chess-engine"
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?,
    ): Cursor {
        val appContext = context
            ?: return MatrixCursor(arrayOf("name", "filename", "targets"))

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
            }

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
