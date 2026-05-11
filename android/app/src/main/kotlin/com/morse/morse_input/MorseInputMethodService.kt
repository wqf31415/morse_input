package com.morse.morse_input

import android.content.Context
import android.inputmethodservice.InputMethodService
import android.os.Vibrator
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

/**
 * 莫尔斯电码输入法 - Android IME 服务
 *
 * 核心交互：
 * - 短按大按钮 = 点 (.)
 * - 长按大按钮 = 划 (-)
 * - 超时自动将电码转换为字符
 * - 支持退格、空格、换行、清除操作
 */
class MorseInputMethodService : InputMethodService() {

    // 莫尔斯电码映射表
    private val morseMap = mapOf(
        ".-" to "A", "-..." to "B", "-.-." to "C", "-.." to "D",
        "." to "E", "..-." to "F", "--." to "G", "...." to "H",
        ".." to "I", ".---" to "J", "-.-" to "K", ".-.." to "L",
        "--" to "M", "-." to "N", "---" to "O", ".--." to "P",
        "--.-" to "Q", ".-." to "R", "..." to "S", "-" to "T",
        "..-" to "U", "...-" to "V", ".--" to "W", "-..-" to "X",
        "-.--" to "Y", "--.." to "Z",
        "-----" to "0", ".----" to "1", "..---" to "2", "...--" to "3",
        "....-" to "4", "....." to "5", "-...." to "6", "--..." to "7",
        "---.." to "8", "----." to "9",
        ".-.-.-" to ".", "--..--" to ",", "..--.." to "?",
        ".-.-.-" to ".", "--..--" to ",", "..--.." to "?",
        "'".toMorse() to "'", "-.-.--" to "!", "-..-." to "/",
        "-.--." to "(", "-.--.-" to ")", "---..." to ":",
        "-.-.-." to ";", "-...-" to "=", ".-.-." to "+",
        "-....-" to "-", "..--.-" to "_", ".-..-." to "\"",
        "..." to "S", ".--.-." to "@"
    )

    // 当前电码缓冲
    private var currentMorse = StringBuilder()
    private var isPressing = false
    private var pressStartTime = 0L

    // 时间阈值（毫秒）
    private val pressThreshold = 200L    // 短按/长按分界
    private val charTimeout = 1000L      // 字符自动转换超时
    private val wordTimeout = 2000L      // 单词间隔超时

    // UI 元素
    private lateinit var morseDisplay: TextView
    private lateinit var mainButton: Button
    private lateinit var inputView: LinearLayout

    // 振动器
    private lateinit var vibrator: Vibrator

    // 自动转换 Handler
    private val handler = android.os.Handler(android.os.Looper.getMainLooper())

    private val charTimeoutRunnable = Runnable {
        convertCurrentMorse()
    }

    private val wordTimeoutRunnable = Runnable {
        inputConnection?.commitText(" ", 1)
    }

    override fun onCreate() {
        super.onCreate()
        vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    }

    override fun onCreateInputView(): View {
        inputView = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(0xFFF5F5F5.toInt())
            setPadding(16, 12, 16, 16)
        }

        // 电码显示区域
        morseDisplay = TextView(this).apply {
            text = "等待输入..."
            textSize = 28f
            setPadding(16, 12, 16, 12)
            setBackgroundColor(0xFFFFFFFF.toInt())
            setTextColor(0xFF333333.toInt())
            typeface = android.graphics.Typeface.MONOSPACE
            letterSpacing = 0.1f
        }
        inputView.addView(morseDisplay, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            bottomMargin = 12
        })

        // 大输入按钮
        mainButton = Button(this).apply {
            text = "按住输入\n短按 · 点    长按 — 划"
            textSize = 18f
            setTextColor(0xFFFFFFFF.toInt())
            setBackgroundColor(0xFF1565C0.toInt())
            isAllCaps = false
            setPadding(0, 24, 0, 24)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                180
            )

            setOnTouchListener { _, event ->
                when (event.action) {
                    android.view.MotionEvent.ACTION_DOWN -> {
                        isPressing = true
                        pressStartTime = System.currentTimeMillis()
                        handler.removeCallbacks(charTimeoutRunnable)
                        handler.removeCallbacks(wordTimeoutRunnable)
                        vibrate(30)
                        text = "松开输入..."
                        true
                    }
                    android.view.MotionEvent.ACTION_UP,
                    android.view.MotionEvent.ACTION_CANCEL -> {
                        if (isPressing) {
                            isPressing = false
                            val duration = System.currentTimeMillis() - pressStartTime
                            val signal = if (duration < pressThreshold) "." else "-"
                            addSignal(signal)
                            text = "按住输入\n短按 · 点    长按 — 划"
                        }
                        true
                    }
                    else -> false
                }
            }
        }
        inputView.addView(mainButton)

        // 控制按钮行
        val controlRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, 12, 0, 0)
        }

        val controlButtons = listOf(
            "退格" to { backspace() },
            "空格" to { insertSpace() },
            "换行" to { insertNewline() },
            "清除" to { clearMorse() }
        )

        controlButtons.forEach { (label, action) ->
            val btn = Button(this).apply {
                text = label
                textSize = 14f
                setPadding(0, 8, 0, 8)
                setBackgroundColor(0xFFE3F2FD.toInt())
                setTextColor(0xFF1565C0.toInt())
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
                    marginStart = 4
                    marginEnd = 4
                }
                setOnClickListener { action() }
            }
            controlRow.addView(btn)
        }

        inputView.addView(controlRow, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ))

        return inputView
    }

    override fun onStartInput(attribute: EditorInfo?, restarting: Boolean) {
        super.onStartInput(attribute, restarting)
        currentMorse.clear()
        updateMorseDisplay()
    }

    /**
     * 添加一个莫尔斯信号
     */
    private fun addSignal(signal: String) {
        currentMorse.append(signal)
        updateMorseDisplay()

        // 启动字符超时定时器
        handler.removeCallbacks(charTimeoutRunnable)
        handler.postDelayed(charTimeoutRunnable, charTimeout)
    }

    /**
     * 将当前电码转换为字符并提交
     */
    private fun convertCurrentMorse() {
        if (currentMorse.isEmpty()) return

        val morse = currentMorse.toString()
        val char = morseMap[morse]

        if (char != null) {
            inputConnection?.commitText(char, 1)
            vibrate(50)
        }

        currentMorse.clear()
        updateMorseDisplay()

        // 启动单词间隔定时器
        if (char != null) {
            handler.removeCallbacks(wordTimeoutRunnable)
            handler.postDelayed(wordTimeoutRunnable, wordTimeout)
        }
    }

    /**
     * 退格
     */
    private fun backspace() {
        handler.removeCallbacks(charTimeoutRunnable)
        handler.removeCallbacks(wordTimeoutRunnable)

        if (currentMorse.isNotEmpty()) {
            currentMorse.deleteCharAt(currentMorse.length - 1)
            updateMorseDisplay()
            if (currentMorse.isNotEmpty()) {
                handler.postDelayed(charTimeoutRunnable, charTimeout)
            }
        } else {
            inputConnection?.deleteSurroundingText(1, 0)
        }
    }

    /**
     * 插入空格
     */
    private fun insertSpace() {
        handler.removeCallbacks(charTimeoutRunnable)
        handler.removeCallbacks(wordTimeoutRunnable)

        if (currentMorse.isNotEmpty()) {
            convertCurrentMorse()
        }
        inputConnection?.commitText(" ", 1)
    }

    /**
     * 插入换行
     */
    private fun insertNewline() {
        handler.removeCallbacks(charTimeoutRunnable)
        handler.removeCallbacks(wordTimeoutRunnable)

        if (currentMorse.isNotEmpty()) {
            convertCurrentMorse()
        }
        inputConnection?.commitText("\n", 1)
    }

    /**
     * 清除当前电码
     */
    private fun clearMorse() {
        handler.removeCallbacks(charTimeoutRunnable)
        currentMorse.clear()
        updateMorseDisplay()
    }

    /**
     * 更新电码显示
     */
    private fun updateMorseDisplay() {
        morseDisplay.text = if (currentMorse.isEmpty()) {
            "等待输入..."
        } else {
            currentMorse.toString()
        }
    }

    /**
     * 触发振动反馈
     */
    private fun vibrate(durationMs: Long) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            vibrator.vibrate(android.os.VibrationEffect.createOneShot(durationMs, android.os.VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(durationMs)
        }
    }

    override fun onDestroy() {
        handler.removeCallbacks(charTimeoutRunnable)
        handler.removeCallbacks(wordTimeoutRunnable)
        super.onDestroy()
    }
}

// 扩展函数：生成单引号的莫尔斯电码（避免 Kotlin 字符串转义问题）
private fun String.toMorse(): String = ".----."
