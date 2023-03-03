package com.exponea.style

import android.content.Context
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.DrawableWrapper
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.InsetDrawable
import android.graphics.drawable.LayerDrawable
import android.graphics.drawable.RippleDrawable
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.Base64
import android.widget.Button
import androidx.core.content.res.ResourcesCompat
import com.exponea.PlatformSize
import com.exponea.applyTint
import com.exponea.asColor
import com.exponea.sdk.util.Logger
import com.exponea.toTypeface

data class ButtonStyle(
    var textOverride: String? = null,
    var textColor: String? = null,
    var backgroundColor: String? = null,
    var showIcon: String? = null,
    var textSize: String? = null,
    var enabled: Boolean? = null,
    var borderRadius: String? = null,
    var textWeight: String? = null
) {
    private fun applyColorTo(target: Drawable?, color: Int): Boolean {
        if (target == null) {
            return false
        }
        val colorizedDrawable = findColorizedDrawable(target)
        when (colorizedDrawable) {
            is GradientDrawable -> {
                colorizedDrawable.setColor(color)
                return true
            }
            is ColorDrawable -> {
                colorizedDrawable.color = color
                return true
            }
        }
        Logger.e(this, "Unable to find colored background")
        return false
    }
    private fun findColorizedDrawable(root: Drawable?): Drawable? {
        if (root == null) {
            return null
        }
        if (VERSION.SDK_INT >= VERSION_CODES.M && root is DrawableWrapper) {
            return findColorizedDrawable(root.drawable)
        }
        when (root) {
            is GradientDrawable -> return root
            is ColorDrawable -> return root
            is LayerDrawable -> {
                for (i in 0 until root.numberOfLayers) {
                    val drawableLayer = root.getDrawable(i)
                    val colorizedDrawable = findColorizedDrawable(drawableLayer)
                    if (colorizedDrawable != null) {
                        return colorizedDrawable
                    }
                    // continue
                }
                Logger.d(this, "No colorizable Drawable found in LayerDrawable")
                return null
            }
            else -> {
                Logger.d(this, "Not implemented Drawable type to search colorized drawable")
                return null
            }
        }
    }
    fun applyTo(button: Button) {
        showIcon?.let {
            when (it.lowercase()) {
                "none", "false", "0", "no" -> {
                    button.setCompoundDrawablesRelative(null, null, null, null)
                }
                isNamedDrawable(it, button.context) -> {
                    button.setCompoundDrawablesRelative(
                        getDrawable(it, button.context), null, null, null
                    )
                }
                else -> {
                    try {
                        val iconDrawable = fromBase64(it, button.resources)
                        button.setCompoundDrawablesRelative(
                            iconDrawable, null, null, null
                        )
                    } catch (e: Exception) {
                        Logger.e(this, "Unable to parse Base64 (error: ${e.localizedMessage}): $it")
                    }
                }
            }
        }
        textOverride?.let {
            button.text = it
        }
        textColor?.asColor()?.let {
            button.setTextColor(it)
            val origIcons = button.compoundDrawablesRelative
            button.setCompoundDrawablesRelative(
                origIcons[0].applyTint(it),
                origIcons[1].applyTint(it),
                origIcons[2].applyTint(it),
                origIcons[3].applyTint(it)
            )
        }
        backgroundColor?.asColor()?.let {
            // force color drawable
            button.setBackgroundColor(Color.WHITE)
            val currentBackground = button.background
            if (!applyColorTo(currentBackground, it)) {
                Logger.d(this, "Overriding color as new background")
                button.setBackgroundColor(it)
            }
        }
        PlatformSize.parse(textSize)?.let {
            button.setTextSize(it.unit, it.size)
        }
        button.setTypeface(button.typeface, toTypeface(textWeight))
        enabled?.let {
            button.isEnabled = it
        }
        PlatformSize.parse(borderRadius)?.let {
            when (val currentBackground = button.background) {
                is GradientDrawable -> {
                    currentBackground.cornerRadius = it.size
                    button.background = currentBackground
                }
                is ColorDrawable -> {
                    val newBackground = GradientDrawable()
                    newBackground.cornerRadius = it.size
                    newBackground.setColor(currentBackground.color)
                    button.background = newBackground
                }
                is RippleDrawable -> {
                    for (i in 0 until currentBackground.numberOfLayers) {
                        try {
                            val drawable = currentBackground.getDrawable(i)
                            if (drawable is InsetDrawable) {
                                val subdrawable = drawable.drawable
                                Logger.e(this, "SubDrawable $i is ${subdrawable?.javaClass}")
                                if (subdrawable is GradientDrawable) {
                                    subdrawable.cornerRadius = it.size
                                }
                            }
                            Logger.e(this, "Drawable $i is ${drawable.javaClass}")
                        } catch (e: Exception) {
                            Logger.e(this, "No Drawable for $i")
                        }
                    }
                    Logger.e(this, "Background is ${currentBackground.current.javaClass}")
                    button.background = currentBackground
                }
                else -> {
                    Logger.e(this, "BorderRadius for Button can be used only with colored background")
                }
            }
        }
    }

    private fun fromBase64(imageB64: String, resources: Resources): Drawable {
        val imageDataB64 = if (imageB64.contains(",")) {
            // probably: 'data:image/jpg;base64,BASE_64_DATA'
            imageB64.split(",").last()
        } else {
            imageB64
        }
        val decodedString: ByteArray = Base64.decode(imageDataB64, Base64.DEFAULT)
        val decodedByte: Bitmap = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
        val drawable = BitmapDrawable(resources, decodedByte)
        drawable.setBounds(0, 0, decodedByte.width, decodedByte.height);
        return drawable
    }

    private fun getDrawable(name: String, context: Context): Drawable? {
        return ResourcesCompat.getDrawable(
            context.resources,
            getDrawableIdentifier(context, name),
            context.theme
        )
    }

    /**
     * Please accept Non-null String as TRUE. See usage in when :-)
     */
    private fun isNamedDrawable(name: String, context: Context): String? {
        if (getDrawableIdentifier(context, name) == 0) {
            return name
        }
        return null
    }

    private fun getDrawableIdentifier(context: Context, name: String) =
        context.resources.getIdentifier(name, "drawable", context.packageName)

    fun merge(source: ButtonStyle): ButtonStyle {
        this.textOverride = source.textOverride
        this.textColor = source.textColor ?: this.textColor
        this.backgroundColor = source.backgroundColor ?: this.backgroundColor
        this.showIcon = source.showIcon ?: this.showIcon
        this.textSize = source.textSize ?: this.textSize
        this.enabled = source.enabled ?: this.enabled
        this.borderRadius = source.borderRadius ?: this.borderRadius
        return this
    }
}
