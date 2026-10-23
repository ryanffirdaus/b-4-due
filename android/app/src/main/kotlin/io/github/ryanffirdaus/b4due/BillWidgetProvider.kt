package io.github.ryanffirdaus.b4due

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget: what is left to pay this month and the most urgent
 * bill. Dart computes and localises every value
 * (lib/features/home_widget/data/home_widget_gateway.dart); this only
 * places them. A tap opens that bill, or Beranda.
 */
class BillWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.bill_widget)
            widgetData.getString("title", null)?.let {
                views.setTextViewText(R.id.widget_title, it)
            }
            views.setTextViewText(
                R.id.widget_remaining,
                widgetData.getString("remaining", "Rp 0"),
            )
            views.setTextViewText(
                R.id.widget_paid_of,
                widgetData.getString("paidOf", ""),
            )
            views.setProgressBar(
                R.id.widget_progress,
                100,
                widgetData.getInt("percent", 0).coerceIn(0, 100),
                false,
            )

            val hasNext = widgetData.getBoolean("hasNext", false)
            views.setViewVisibility(
                R.id.widget_next,
                if (hasNext) View.VISIBLE else View.GONE,
            )
            views.setViewVisibility(
                R.id.widget_empty,
                if (hasNext) View.GONE else View.VISIBLE,
            )
            views.setTextViewText(R.id.widget_next_name, widgetData.getString("nextName", ""))
            views.setTextViewText(R.id.widget_next_due, widgetData.getString("nextDue", ""))
            views.setTextColor(
                R.id.widget_next_due,
                if (widgetData.getBoolean("nextOverdue", false)) OVERDUE else LIME,
            )
            views.setTextViewText(R.id.widget_next_price, widgetData.getString("nextPrice", ""))
            views.setTextViewText(R.id.widget_empty, widgetData.getString("empty", ""))

            val link = widgetData.getString("nextLink", null) ?: "b4due://home"
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse(link),
                ),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private companion object {
        // Palette.dark: accent and danger text on the ink widget.
        const val LIME = 0xFFB6F36B.toInt()
        const val OVERDUE = 0xFFF97066.toInt()
    }
}
