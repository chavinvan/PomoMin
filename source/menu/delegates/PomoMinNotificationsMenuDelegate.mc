import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! This is the menu input delegate for the main menu of the application
class PomoMinNotificationsMenuDelegate extends WatchUi.Menu2InputDelegate {

    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) as Void {
        var id = item.getId() as String;

        var notificationsConfigRepository = NotificationsConfigRepository.getInstance();
        if(id.equals("notificationvibration")){
            notificationsConfigRepository.toggleNotificationVibration();
        }else if(id.equals("notificationsound")){
            notificationsConfigRepository.toggleNotificationSound();
        }
        
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}