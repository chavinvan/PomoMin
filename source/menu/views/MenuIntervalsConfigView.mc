using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Lang;

class MenuIntervalsConfigView extends WatchUi.Menu2 {

    function initialize(options) {
        Menu2.initialize(options);
    }

    function onShow() {
        // get focus time interval
        var intervalsConfigRepository = IntervalsConfigRepository.getInstance();
        var focusTime = intervalsConfigRepository.getFocusIntervalDuration();
        var breakTime = intervalsConfigRepository.getBreakIntervalDuration();
        updateItem(new WatchUi.MenuItem(Application.loadResource($.Rez.Strings.MenuFocusTime) as Lang.String, Lang.format("$1$ min", [focusTime]), "focustime", null), 0);
        updateItem(new WatchUi.MenuItem(Application.loadResource($.Rez.Strings.MenuBreakTime) as Lang.String, Lang.format("$1$ min", [breakTime]), "breaktime", null), 1);
        System.println("MyMenu2.onShow");
    }
}