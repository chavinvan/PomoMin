import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! This is the menu input delegate for the main menu of the application
class PomoMinIntervalsMenuDelegate extends WatchUi.Menu2InputDelegate {

    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) as Void {
        var id = item.getId() as String;

        /*if(id.equals("intervals")){

            
            WatchUi.pushView(intervalsMenu, new $.Menu2SampleSubMenuDelegate(), WatchUi.SLIDE_UP);
        }*/
        var timePickerView = new $.TimePicker();
        WatchUi.pushView(timePickerView, new $.TimePickerDelegate(timePickerView, id), WatchUi.SLIDE_IMMEDIATE);
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}