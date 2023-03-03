package com.exponea.style

import android.view.View
import android.widget.ImageView
import com.exponea.asColor

data class ImageViewStyle(
    var visible: Boolean? = null,
    var backgroundColor: String? = null
) {
    fun applyTo(target: ImageView) {
        visible?.let {
            target.visibility = if (it) View.VISIBLE else View.GONE
        }
        backgroundColor?.asColor()?.let {
            target.setBackgroundColor(it)
        }
    }
}
