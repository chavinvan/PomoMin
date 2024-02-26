import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.Application;

(:typecheck(disableBackgroundCheck))
class PomoMinDelegate extends WatchUi.BehaviorDelegate {

    private var _pomoView as PomoMinView;

    // no se llaman al volver (tampoco la otra)
    function initialize(pomoView as PomoMinView, backgroundRan as PersistableType) {
        BehaviorDelegate.initialize();
        _pomoView = pomoView;
    }

    //! On a select event, create a progress bar
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean {
        return _pomoView.onSelectPressed();
    }

    //! Call the reset method on the parent view when the
    //! back action occurs.
    //! @return true if handled, false otherwise
    public function onBack() as Boolean {
        return _pomoView.onBackPressed();
    }

    public function onMenu() as Boolean {
        return _pomoView.onMenuPressed();
    }
}