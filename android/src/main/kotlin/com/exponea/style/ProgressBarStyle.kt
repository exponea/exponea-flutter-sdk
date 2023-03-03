package com.exponea.style

import android.content.res.ColorStateList
import android.view.View
import android.widget.ProgressBar
import com.exponea.asColor

data class ProgressBarStyle(
    var visible: Boolean? = null,
    var progressColor: String? = null,
    var backgroundColor: String? = null
) {
    fun applyTo(target: ProgressBar) {
        visible?.let {
            target.visibility = if (it) View.VISIBLE else View.GONE
        }
        progressColor?.asColor()?.let {
            target.progressTintList = ColorStateList.valueOf(it)
        }
        backgroundColor?.asColor()?.let {
            target.setBackgroundColor(it)
        }
    }
}
