package com.analisismotoresoex.motoresoex

import android.content.Context
import android.os.Build
import java.io.File

data class OexEngineDefinition(
    val displayName: String,
    val exportFileName: String,
    val targets: Set<String>,
    val exported: Boolean,
    val note: String? = null,
) {
    fun matches(fileName: String): Boolean {
        val clean = fileName.trim()
        return clean == exportFileName ||
            clean == exportFileName.removePrefix("lib").removeSuffix(".so")
    }
}

object OexEngineRegistry {
    private val engines = listOf(
        OexEngineDefinition(
            displayName = "Stockfish 18",
            exportFileName = "libstockfish.so",
            targets = setOf("arm64-v8a"),
            exported = true,
        ),
        OexEngineDefinition(
            displayName = "PlentyChess 7.0.65",
            exportFileName = "libplentychess.so",
            targets = setOf("arm64-v8a"),
            exported = true,
        ),
    )

    fun authority(context: Context): String = "${context.packageName}.engineprovider"

    fun advertisedEngines(): List<OexEngineDefinition> = engines.filter { it.exported }

    fun findExportedEngine(fileName: String): OexEngineDefinition? =
        advertisedEngines().firstOrNull { it.matches(fileName) }

    fun getEngineFile(context: Context, engineFileName: String): File {
        // 1. Check in nativeLibraryDir (standard case, e.g. local APK install with extractNativeLibs=true)
        val nativeDir = context.applicationInfo.nativeLibraryDir
        val nativeFile = File(nativeDir, engineFileName)
        if (nativeFile.exists()) {
            return nativeFile
        }

        // 2. Fallback: check in internal filesDir (manually extracted case)
        val internalFile = File(context.filesDir, engineFileName)
        if (internalFile.exists()) {
            return internalFile
        }

        // 3. Extract manually from APK to filesDir if not present (Google Play AAB case)
        try {
            val apkFile = File(context.applicationInfo.sourceDir)
            java.util.zip.ZipFile(apkFile).use { zip ->
                val abi = primaryAbi()
                var entry = zip.getEntry("lib/$abi/$engineFileName")
                if (entry == null) {
                    // Fallback to searching any entry matching the filename
                    entry = zip.entries().asSequence().firstOrNull { it.name.endsWith(engineFileName) }
                }
                if (entry != null) {
                    zip.getInputStream(entry).use { input ->
                        internalFile.outputStream().use { output ->
                            input.copyTo(output)
                        }
                    }
                    internalFile.setExecutable(true, false)
                    return internalFile
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // If everything fails, return the non-existent native file so normal error handling catches it
        return nativeFile
    }

    fun status(context: Context): Map<String, Any> {
        val abi = primaryAbi()
        val nativeDir = context.applicationInfo.nativeLibraryDir
        val engineStatus = engines.map { engine ->
            val engineFile = getEngineFile(context, engine.exportFileName)
            mapOf(
                "name" to engine.displayName,
                "fileName" to engine.exportFileName,
                "targets" to engine.targets.toList(),
                "exported" to engine.exported,
                "compatible" to isCompatible(engine),
                "prepared" to engineFile.exists(),
                "path" to engineFile.absolutePath,
                "note" to (engine.note ?: ""),
            )
        }

        return mapOf(
            "authority" to authority(context),
            "deviceAbi" to abi,
            "nativeLibraryDir" to nativeDir,
            "advertisedCount" to advertisedEngines().size,
            "engines" to engineStatus,
        )
    }

    fun primaryAbi(): String = Build.SUPPORTED_ABIS.firstOrNull() ?: @Suppress("DEPRECATION") Build.CPU_ABI

    fun isCompatible(engine: OexEngineDefinition): Boolean {
        val supportedAbis = Build.SUPPORTED_ABIS.toSet()
        return engine.targets.any { it in supportedAbis }
    }
}
