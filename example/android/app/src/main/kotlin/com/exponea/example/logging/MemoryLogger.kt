package com.exponea.example.logging

import android.os.Process
import java.io.BufferedReader
import java.io.InputStreamReader

/**
 * Memory-backed log buffer fed by a logcat reader for the example app process.
 * Ported from Android app-v2; streams entries to Flutter via [SdkLogBridge].
 */
object MemoryLogger {
    private const val MAX_ENTRIES = 500
    private val buffer: ArrayDeque<LogEntry> = ArrayDeque(MAX_ENTRIES)
    private val lock = Any()
    private val pid: Int = Process.myPid()

    @Volatile
    private var readerThread: Thread? = null

    @Volatile
    private var listener: ((LogEntry) -> Unit)? = null

    fun setListener(listener: ((LogEntry) -> Unit)?) {
        this.listener = listener
    }

    @Synchronized
    fun start() {
        if (readerThread?.isAlive == true) return
        readerThread = Thread {
            try {
                runCatching { Runtime.getRuntime().exec(arrayOf("logcat", "-c")).waitFor() }
                val process = Runtime.getRuntime().exec(arrayOf("logcat", "-v", "threadtime"))
                val reader = BufferedReader(InputStreamReader(process.inputStream))
                while (!Thread.currentThread().isInterrupted) {
                    val line = reader.readLine() ?: break
                    parseLine(line)?.let { append(it) }
                }
            } catch (_: Throwable) {
                // logcat unreachable on some devices; buffer stays empty.
            }
        }.also {
            it.name = "MemoryLogger-Reader"
            it.isDaemon = true
            it.start()
        }
    }

    fun snapshot(): List<LogEntry> {
        synchronized(lock) { return buffer.toList() }
    }

    fun clear() {
        synchronized(lock) { buffer.clear() }
    }

    private fun append(entry: LogEntry) {
        synchronized(lock) {
            if (buffer.size >= MAX_ENTRIES) buffer.removeFirst()
            buffer.addLast(entry)
        }
        listener?.invoke(entry)
    }

    private fun parseLine(line: String): LogEntry? {
        if (line.length < 33 || line.startsWith("---")) return null
        return try {
            val parts = line.trim().split(WHITESPACE_REGEX, limit = 6)
            if (parts.size < 6) return null
            val linePid = parts[2].toIntOrNull() ?: return null
            if (linePid != pid) return null
            val levelChar = parts[4]
            val tagAndMessage = parts[5]
            val colonIdx = tagAndMessage.indexOf(":")
            val (tag, message) = if (colonIdx > 0) {
                tagAndMessage.substring(0, colonIdx).trim() to
                    tagAndMessage.substring(colonIdx + 1).trim()
            } else {
                "" to tagAndMessage.trim()
            }
            LogEntry(
                timestamp = System.currentTimeMillis(),
                level = LogEntry.Level.fromShort(levelChar),
                tag = tag,
                message = message,
            )
        } catch (_: Throwable) {
            null
        }
    }
}

private val WHITESPACE_REGEX = "\\s+".toRegex()
