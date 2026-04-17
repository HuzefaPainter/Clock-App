package com.example.clock_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class ClockWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val date = widgetData.getString("clock_date", "---") ?: "---"

            val views = RemoteViews(context.packageName, R.layout.clock_widget).apply {
                setTextViewText(R.id.widget_date, date)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
