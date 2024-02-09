import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;


(:background)
class PomoMinApp extends Application.AppBase {

    private var _pomoView as PomoMinView?;
    private var _backgroundData as PersistableType;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        var pomoView = _pomoView;
        if (pomoView != null) {
            pomoView.saveProperties();
            pomoView.setBackgroundEvent();
        }
    }

    //! Handle data passed from a background service delegate to the app
    //! @param data The data passed from the background process
    public function onBackgroundData(data as PersistableType) as Void {
        if (_pomoView != null) {
            _pomoView.backgroundEvent();
        } else {
            _backgroundData = data;
        }
    }

    //! Return the initial view for the app
    //! @return Array Pair [View, Delegate]
    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        _pomoView = new $.PomoMinView(_backgroundData);
        _pomoView.deleteBackgroundEvent();
        if (_pomoView != null) {
            return [_pomoView, new $.PomoMinDelegate(_pomoView, _backgroundData)] as Array<Views or InputDelegates>?;
        }
        return null;
    }

    //! Get service delegates to run background tasks for the app
    //! @return An array of service delegates to run background tasks
    public function getServiceDelegate() as Array<ServiceDelegate> {
        return [new $.PomoMinServiceDelegate()] as Array<ServiceDelegate>;
    }

    //! Handle a storage update
    public function onStorageChanged() as Void {
        if (_pomoView != null) {
            $.handleStorageUpdate();
        }
    }

}

(:typecheck(disableBackgroundCheck))
function handleStorageUpdate() as Void {
    WatchUi.pushView(new $.PomoMinStorageChangedAlertView(), null, WatchUi.SLIDE_IMMEDIATE);
}

function getApp() as PomoMinApp {
    return Application.getApp() as PomoMinApp;
}