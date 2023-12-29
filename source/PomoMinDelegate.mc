import Toybox.Lang;
import Toybox.WatchUi;

(:typecheck(disableBackgroundCheck))
class PomoMinDelegate extends WatchUi.BehaviorDelegate {

    private var _pomoView as PomoMinView?;

    function initialize(pomoView as PomoMinView) {
        BehaviorDelegate.initialize();
        _pomoView = pomoView;
    }


    //! On a select event, create a progress bar
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean {
        _pomoView.startStopTimer();
        return true;
    }

    //! Call the reset method on the parent view when the
    //! back action occurs.
    //! @return true if handled, false otherwise
    public function onBack() as Boolean {
        return _pomoView.resetTimer();
    }

}