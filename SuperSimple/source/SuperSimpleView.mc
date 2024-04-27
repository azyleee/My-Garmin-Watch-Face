import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

import Toybox.SensorHistory;
import Toybox.Application.Storage;

using Toybox.Time.Gregorian as Date;
using Toybox.Weather;


// https://github.com/kevin940726/shy-watch-face/blob/main/source/ShyView.mc#L26

class SuperSimpleView extends WatchUi.WatchFace {

    private var BiggPS;
    private var SmolPS;
    // private var screenWidth;
    // private var screenHeight;
    private var cx;
    private var cy;
    private var isLowPowerMode = false;
    private var isHidden = false;

    function initialize() {
        WatchFace.initialize();
        BiggPS = Application.loadResource(Rez.Fonts.BiggPS);
        SmolPS = Application.loadResource(Rez.Fonts.SmolTT);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        // hard code the screen dimensions
        // screenWidth = 360;//dc.getWidth();
        // screenHeight = 360;//dc.getHeight();
        cx = 180;
        cy = 180;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        isHidden = false;
    }

    // Update the view
    // This function is run every minute (?) to update the watch face contents
    function onUpdate(dc as Dc) as Void {

        View.onUpdate(dc);

        // Draw the UI
        drawHoursMinutes(dc);

        if (!isLowPowerMode && !isHidden) {
            drawHighPower(dc);
        } else {
            drawLowPower(dc);
        }
    }

    private function drawHoursMinutes(dc) {
        var clockTime = System.getClockTime();
        var hours = (clockTime.hour % 12);//.format("%02d"); // 12 hour format hard-coded into watchface
        var minutes = clockTime.min.format("%02d");
        var AMPM = clockTime.hour < 12 ? "AM" : "PM";

        if (hours == 0) {
            hours = 12;
        }

        // Draw full time
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        dc.drawText(
            cx,
            cy,
            BiggPS,
            hours+":"+minutes,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // // Draw hours
        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        // dc.drawText(
        //     cx-14,
        //     cy,
        //     BiggPS,
        //     hours,
        //     Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        // );
        
        // // Draw Colon
        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        // dc.drawText(
        //     cx+14,
        //     cy-8,
        //     BiggPS,
        //     ":",
        //     Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_VCENTER
        // );

        // // Draw minutes
        // dc.drawText(
        //     cx + 16,
        //     cy,
        //     BiggPS,
        //     minutes,
        //     Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        // );

        // Draw AM/PM
        // dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);        
        // dc.drawText(
        //     screenWidth-5,
        //     cy,
        //     SmolPS,
        //     clockTime.hour < 12 ? "AM" : "PM",
        //     Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_VCENTER
        // );
    }

    private function drawHighPower(dc) {

        // date
        var now = Time.now();
        var date = Date.info(now, Time.FORMAT_MEDIUM);

        // Draw Day of the week
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        dc.drawText(
            cx,
            cy-75,
            SmolPS,
            Lang.format("$1$", [date.day_of_week]).toUpper() + "    " + Lang.format("$1$", [date.day]).toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // // Draw Date
        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        // dc.drawText(
        //     cx+8,
        //     cy-75,
        //     SmolPS,
        //     date_str,
        //     Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        // );

        // data below
        var info = ActivityMonitor.getInfo();
		var steps_str = Lang.format ("$1$", [(info.steps / 1000).format("%.1f")]);
        dc.drawText(
            cx,
            cy+75,
            SmolPS,
            steps_str + "K",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        var distance_str = Lang.format ("$1$", [(info.distance * 0.00001).format("%.1f")]);
        dc.drawText(
            cx+100,
            cy+75,
            SmolPS,
            distance_str,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        var temperature_str = Weather.getCurrentConditions().temperature.format("%0.0f");
        dc.drawText(
            cx-100,
            cy+75,
            SmolPS,
            temperature_str+" °C",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        
        // subtitles
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT); 
        dc.drawText(
            cx,
            cy+103,
            SmolPS,
            "STEPS",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            cx+100,
            cy+103,
            SmolPS,
            "KM",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            cx-100,
            cy+103,
            SmolPS,
            "WTHR",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        
        var battery_str = System.getSystemStats().battery.format("%02d");
        dc.drawText(
            cx,
            cy+145,
            SmolPS,
            battery_str + " %",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // data above
        var dataabove_y1 = cy-151;
        var dataabove_y2 = cy-123;
        var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period=>1});
        var bbsample = bbIterator.next(); 
        var stressIterator = Toybox.SensorHistory.getStressHistory({:period=>1});
        if (bbsample != null) { 
            bbsample = bbsample.data.format("%d");
        } else{
            bbsample = "---";
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);   
        dc.drawText(
            cx-65, 
            dataabove_y1,	
            SmolPS, 
            bbsample, 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT); 
        dc.drawText(
            cx-65,
            dataabove_y2,
            SmolPS,
            "BB",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var heartRate = Activity.getActivityInfo().currentHeartRate;
        if (heartRate == null) { 
            if(ActivityMonitor has :getHeartRateHistory) {
                var HRH=ActivityMonitor.getHeartRateHistory(1, true);
                    var HRS=HRH.next();
                    if(HRS!=null && HRS.heartRate!= ActivityMonitor.INVALID_HR_SAMPLE){
                        
                        heartRate = HRS.heartRate;
                        
                    }
                }
        }
        if (heartRate != null) {
            heartRate = heartRate.format("%d");
        } else {
            heartRate = "---";
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);   
        dc.drawText(
            cx, 
            dataabove_y1,	
            SmolPS, 
            heartRate, 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT); 
        dc.drawText(
            cx,
            dataabove_y2,
            SmolPS,
            "HR",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var stIterator = Toybox.SensorHistory.getStressHistory({:period=>1});
        var stsample = stressIterator.next(); 
        if (stsample != null) {
            stsample = stsample.data.format("%d");
        } else{
            stsample = "---";
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);   
        dc.drawText(
            cx+65, 
            dataabove_y1,	
            SmolPS, 
            stsample, 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT); 
        dc.drawText(
            cx+65,
            dataabove_y2,
            SmolPS,
            "ST",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    private function drawLowPower(dc) {
        var now = Time.now();
        var date = Date.info(now, Time.FORMAT_MEDIUM);
        // Draw Day of the week
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);        
        dc.drawText(
            cx,
            cy-75,
            SmolPS,
            Lang.format("$1$", [date.day_of_week]).toUpper() + "    " + Lang.format("$1$", [date.day]).toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function onHide() as Void {
        isHidden = true;
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        isLowPowerMode = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isLowPowerMode = true;
    }

}
