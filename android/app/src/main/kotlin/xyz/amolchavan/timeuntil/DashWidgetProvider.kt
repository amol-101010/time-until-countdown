package xyz.amolchavan.timeuntil

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Renders lib/widgets_native/widget_updater.dart's saved image + text
 * into the Android home-screen widget. Tapping it opens the app.
 */
class DashWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.dash_widget_layout).apply {
            setTextViewText(
                R.id.dash_widget_title,
                widgetData.getString("dash_widget_title", null) ?: "Dash",
            )
            setTextViewText(
                R.id.dash_widget_subtitle,
                widgetData.getString("dash_widget_subtitle", null) ?: "",
            )

            val imagePath = widgetData.getString("dash_widget_image", null)
            if (imagePath != null) {
              val bitmap = BitmapFactory.decodeFile(imagePath)
              if (bitmap != null) {
                setImageViewBitmap(R.id.dash_widget_image, bitmap)
                setViewVisibility(R.id.dash_widget_image, View.VISIBLE)
              }
            }

            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.dash_widget_container, pendingIntent)
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
