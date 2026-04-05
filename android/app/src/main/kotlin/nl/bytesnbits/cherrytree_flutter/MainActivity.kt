package nl.bytesnbits.cherrytree_flutter

import android.os.Bundle
import android.view.View
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * Android 15+ (and especially 16 / OEM skins) often run edge-to-edge while the Flutter
 * engine still reports zero [MediaQuery] padding for the navigation bar. That draws the
 * UI under the three-button strip (e.g. on the right in landscape).
 *
 * Apply [WindowInsetsCompat] for system bars (and cutout) as real [View] padding on the
 * content root, then clear those inset types for descendants so Flutter does not apply
 * the same insets again (avoids double padding).
 *
 * The content [View.post] defers installation until after the embedding has attached the
 * window so this listener is not lost to Flutter’s own setup order.
 */
class MainActivity : FlutterFragmentActivity() {

    private val systemBarInsetTypes: Int =
        WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val root = findViewById<View>(android.R.id.content)
        root.post { installSystemBarInsetsOnContentRoot(root) }
    }

    private fun installSystemBarInsetsOnContentRoot(root: View) {
        ViewCompat.setOnApplyWindowInsetsListener(root) { view, insets ->
            val bars = insets.getInsets(systemBarInsetTypes)
            view.setPadding(bars.left, bars.top, bars.right, bars.bottom)
            WindowInsetsCompat.Builder(insets)
                .setInsets(systemBarInsetTypes, Insets.NONE)
                .build()
        }
        ViewCompat.requestApplyInsets(root)
    }
}
