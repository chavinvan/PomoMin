//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

const FACTORY_COUNT_24_HOUR = 3;
const FACTORY_COUNT_12_HOUR = 4;
const MINUTE_FORMAT = "%02d";

//! Picker that allows the user to choose a time
class TimePicker extends WatchUi.Picker {

    //! Constructor
    public function initialize() {
        var title = new WatchUi.Text({:text=>"Focus time", :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factories = new Array<PickerFactory or Text>[1];
        factories[0] = new $.NumberFactory(1, 60, 1, {});
        Picker.initialize({:title=>title, :pattern=>factories});
    }

    public function setDefaults(title as WatchUi.Drawable, defaults as Lang.Array<Lang.Number>){
        var factories = new Array<PickerFactory or Text>[1];
        factories[0] = new $.NumberFactory(1, 60, 1, {});
        Picker.setOptions({:title=>title, :pattern=>factories, :defaults=>defaults});
        requestUpdate();
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }

}

//! Responds to a time picker selection or cancellation
class TimePickerDelegate extends WatchUi.PickerDelegate {

    private var _timePickerView as TimePicker?;
    private var _intervalType as String?;

    //! Constructor
    public function initialize(timePickerView as TimePicker, intervalType as String) {
        PickerDelegate.initialize();
        _timePickerView = timePickerView;
        _intervalType = intervalType;

        _setDefaults();
    }

    private function _setDefaults() {
        var defaults = new Array<Number>[1];
        var title = new WatchUi.Text({:text=>"Focus time", :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var intervalsConfigRepository = IntervalsConfigRepository.getInstance();

        if(_intervalType.equals("focustime")){            
            var focusTime = intervalsConfigRepository.getFocusIntervalDuration();
            defaults[0] = focusTime - 1;
            title = new WatchUi.Text({:text=>Application.loadResource($.Rez.Strings.MenuFocusTime) as String, :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        }else if(_intervalType.equals("breaktime")){
            var breakTime = intervalsConfigRepository.getBreakIntervalDuration();
            defaults[0] = breakTime - 1;
            title = new WatchUi.Text({:text=>Application.loadResource($.Rez.Strings.MenuBreakTime) as String, :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        }
        
        _timePickerView.setDefaults(title, defaults);
    }

    //! Handle a cancel event from the picker
    //! @return true if handled, false otherwise
    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    //! Handle a confirm event from the picker
    //! @param values The values chosen in the picker
    //! @return true if handled, false otherwise
    public function onAccept(values as Array) as Boolean {
        var minutes = values[0] as Number;

        // access to repository intervals
        var intervalsConfigRepository = IntervalsConfigRepository.getInstance();

        if(_intervalType.equals("focustime")){
            System.println("focustime");
            intervalsConfigRepository.setFocusIntervalDuration(minutes);
        }else if(_intervalType.equals("breaktime")){
            System.println("breaktime");
            intervalsConfigRepository.setBreakIntervalDuration(minutes);
        }

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

}
