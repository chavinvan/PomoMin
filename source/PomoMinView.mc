import Toybox.Background;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;
import Toybox.Application;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Attention;

//! The main view for the timer application. This displays the
//! remaining time on the countdown timer
(:typecheck(disableBackgroundCheck))
class PomoMinView extends WatchUi.View {

    private var _timerDuration as Number?;
    private var _timerValue as Number?;
    private var _timerController as PomoMinTimerController;
    private var _timerColor as Graphics.ColorType?;

    private enum PomodoroState {
        POMODORO_STATE_WORK,
        POMODORO_STATE_BREAK,
       // POMODORO_STATE_LONG_BREAK,
    }

    const TIMER_WORK_COLOR = Graphics.COLOR_BLUE;
    const TIMER_BREAK_COLOR = 0xffaa55;

    //! Initialize variables for this view
    //! @param backgroundRan Contains background data if background ran
    function initialize(backgroundRan as PersistableType) {
        View.initialize();

        // create timer controller
        _timerController = new PomoMinTimerController(self, backgroundRan);
    }

    public function initializeTimerValues(timerDuration as Number, pomodoroState as Number) as Void {
        _timerValue = timerDuration;
        _timerDuration = timerDuration;
        _timerColor = _getTimerColor(pomodoroState);
    }

    private function _getTimerColor(pomodoroState as Number) as Graphics.ColorType{
        if(pomodoroState == POMODORO_STATE_WORK){
            return TIMER_WORK_COLOR;
        }else if(_pomodoroState == POMODORO_STATE_BREAK){
            return TIMER_BREAK_COLOR;
        }
    }

    public function onSelectPressed() as Boolean {
        return _timerController.onSelectPressed();
    }

    public function onBackPressed() as Boolean {
        return _timerController.onBackPressed();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function vibrate() as Void {

        // Vibrate
        if (Attention has :vibrate) {
            var vibeData =
            [
                new Attention.VibeProfile(50, 1000), // On for two seconds
                new Attention.VibeProfile(0, 500),  // Off for two seconds
                new Attention.VibeProfile(50, 1000), // On for two seconds
                new Attention.VibeProfile(0, 1000),  // Off for two seconds
                new Attention.VibeProfile(50, 1000), // On for two seconds
                new Attention.VibeProfile(0, 1000),  // Off for two seconds
            ];

            Attention.vibrate(vibeData);
        }

        if (Attention has :ToneProfile) {
            var toneProfile =
            [
                new Attention.ToneProfile( 2500, 250),
                new Attention.ToneProfile( 0, 250),
                new Attention.ToneProfile( 2500, 250),
                new Attention.ToneProfile( 0, 250),
                new Attention.ToneProfile( 2500, 250),
                new Attention.ToneProfile( 0, 250),
            ];
            Attention.playTone({:toneProfile=>toneProfile});
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        /*
        var elapsed = 0;
        if(_pomodoroState == POMODORO_STATE_WORK){
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        }else if(_pomodoroState == POMODORO_STATE_BREAK){
            dc.setColor(0xffaa55, Graphics.COLOR_BLACK);
        }

        dc.clear();

        if(_timerState == TIMER_STATE_PAUSED){
            elapsed = _timerPauseTime - _timerStartTime;
            dc.setColor(0x9db8cf, Graphics.COLOR_BLACK);
        }*/
        dc.setColor(_timerColor, Graphics.COLOR_BLACK);
        dc.clear();
        var timerValue = _timerValue;

        var seconds = timerValue % 60;
        var minutes = timerValue / 60;

        var angle = 90-(timerValue*360/_timerDuration);

        var timerString = minutes + ":" + seconds.format("%02d");

        //dc.clear();
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_NUMBER_THAI_HOT,
            timerString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        updateArc(dc, angle);

    }

    /*
    //! If the timer is running, pause it. Otherwise, start it up.
    public function startStopTimer() as Void {
        var now = Time.now().value();

        if(_timerState == TIMER_STATE_STOPPED) {
            _timerState = TIMER_STATE_RUNNING;
            _timerStartTime = now;
            _timer.start(method(:requestUpdate), 1000, true);
        } else if(_timerState == TIMER_STATE_RUNNING) {
            _timerState = TIMER_STATE_PAUSED;
            _timerPauseTime = now;
            _timer.stop();
            WatchUi.requestUpdate();
        } else if(_timerState == TIMER_STATE_PAUSED) {
            _timerState = TIMER_STATE_RUNNING;
            _timerStartTime = _timerStartTime + (now - _timerPauseTime);
            _timerPauseTime = null;
            _timer.start(method(:requestUpdate), 1000, true);
        }

    }
    */
    /*
    //! If the timer is paused, then go ahead and reset it back to the default time.
    //! @return true if timer is reset, false otherwise
    public function resetTimer() as Boolean {
        if(_timerState == TIMER_STATE_RUNNING) {
            return false;
        }else if(_timerState == TIMER_STATE_PAUSED) {
            _timerState = TIMER_STATE_STOPPED;
            resetDefaultTimer();
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }*/

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // A function to update the arc
    function updateArc(dc as Dc, angle as Number) as Void {
        // draw background ring
        dc.setPenWidth(1);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2-19, Graphics.ARC_CLOCKWISE, 90, 90);

        // draw foreground ring
        dc.setPenWidth(10);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2-20, Graphics.ARC_CLOCKWISE, 90, angle);
    }

    //! Set up a background event to occur when the timer expires. This
    //! will alert the user that the timer has expired even if the
    //! application does not remain open.
    public function setBackgroundEvent() as Void {
        _timerController.setBackgroundEvent();
    }

    //! If we do receive a background event while the application is open,
    //! go ahead and reset to the default timer.
    public function backgroundEvent() as Void {
        _timerController.backgroundEvent();
    }
    /*
    private function resetDefaultTimer() as Void {
        _timerDuration = TIMER_DURATION_DEFAULT;
        _timerStartTime = null;
        _timerPauseTime = null;
        if(_pomodoroState == POMODORO_STATE_WORK){
            _timerDuration = 5 * 60;
            _pomodoroState = POMODORO_STATE_BREAK;
        }else if(_pomodoroState == POMODORO_STATE_BREAK){
            _timerDuration = 25 * 60;
            _pomodoroState = POMODORO_STATE_WORK;
        }
        Storage.setValue(TIMER_KEY_POMODORO_STATE, _pomodoroState);
        Storage.setValue(TIMER_KEY_DURATION, _timerDuration);
    }*/

    

    //! Save all the persisted values into the object store. This gets
    //! called by the Application base before the application shuts down.
    public function saveProperties() as Void {
        _timerController.saveProperties();
    }

    //! Delete the background event. We can get rid of this event when the
    //! application opens because now we can see exactly when the timer
    //! is going to expire. We will set it again when the application closes.
    public function deleteBackgroundEvent() as Void {
        _timerController.deleteBackgroundEvent();
    }

    //! This is the callback method we use for our timer. It is
    //! only needed to request display updates as the timer counts
    //! down so we see the updated time on the display.
    public function requestUpdate(timerValue as Number?, timerDuration as Number?) as Void {
        // update values only if received
        if(timerValue != null){
            _timerValue = timerValue;
        }
        if(timerDuration != null){
            _timerDuration = _timerDuration;
        }
        WatchUi.requestUpdate();
    }
}
