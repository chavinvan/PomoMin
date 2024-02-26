import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! This is the menu input delegate for the main menu of the application
class PomoMinMenuDelegate extends WatchUi.Menu2InputDelegate {

    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) as Void {
        var id = item.getId() as String;

        if(id.equals("intervals")){

            var intervalsMenu = new MenuIntervalsConfigView({:title => Application.loadResource($.Rez.Strings.MenuIntervals) as String});
            var intervalsConfigRepository = IntervalsConfigRepository.getInstance();
            var focusTime = intervalsConfigRepository.getFocusIntervalDuration();
            var breakTime = intervalsConfigRepository.getBreakIntervalDuration();

            intervalsMenu.addItem(new WatchUi.MenuItem(Application.loadResource($.Rez.Strings.MenuFocusTime) as String, Lang.format("$1$ min", [focusTime]), "focustime", null));
            intervalsMenu.addItem(new WatchUi.MenuItem(Application.loadResource($.Rez.Strings.MenuBreakTime) as String, Lang.format("$1$ min", [breakTime]), "breaktime", null));
            WatchUi.pushView(intervalsMenu, new $.PomoMinIntervalsMenuDelegate(), WatchUi.SLIDE_UP);
        }else if(id.equals("notifications")){
            var toggleMenu = new WatchUi.Menu2({:title=>Application.loadResource($.Rez.Strings.MenuNotifications) as String});

            var notificationsConfigRepository = NotificationsConfigRepository.getInstance();
            var notificationSound = notificationsConfigRepository.getNotificationSound();
            var notificationVibration = notificationsConfigRepository.getNotificationVibration();

            toggleMenu.addItem(new WatchUi.ToggleMenuItem(Application.loadResource($.Rez.Strings.MenuNotificationsSound) as String, {}, "notificationsound", notificationSound, null));
            toggleMenu.addItem(new WatchUi.ToggleMenuItem(Application.loadResource($.Rez.Strings.MenuNotificationsVibration) as String, {}, "notificationvibration", notificationVibration, null));
            WatchUi.pushView(toggleMenu, new $.PomoMinNotificationsMenuDelegate(), WatchUi.SLIDE_UP);
        }
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}