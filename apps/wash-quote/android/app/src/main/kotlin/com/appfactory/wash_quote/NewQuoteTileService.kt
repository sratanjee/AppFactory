package com.appfactory.wash_quote

import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/**
 * Quick Settings tile that opens the quote builder with the camera armed.
 *
 * On tap, we fire a deep-link intent to `washquote:///quote/new`. The
 * MainActivity intent-filter in AndroidManifest.xml catches it and
 * Flutter's built-in deep-link routing (`flutter_deeplinking_enabled`
 * meta-data) forwards `/quote/new` to go_router.
 *
 * Tile stays in the inactive state; it's a one-shot launcher, not a toggle.
 */
class NewQuoteTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        qsTile?.apply {
            state = Tile.STATE_INACTIVE
            updateTile()
        }
    }

    override fun onClick() {
        super.onClick()

        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(DEEP_LINK)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            setPackage(packageName)
        }

        // Android 14+ requires a PendingIntent for startActivityAndCollapse.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val pending = PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            startActivityAndCollapse(pending)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }

    private companion object {
        const val DEEP_LINK = "washquote:///quote/new"
    }
}
