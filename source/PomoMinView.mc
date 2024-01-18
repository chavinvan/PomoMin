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

    private enum TimerKeys {
        TIMER_KEY_DURATION,
        TIMER_KEY_START_TIME,
        TIMER_KEY_PAUSE_TIME,
        TIMER_KEY_TIMER_STATE,
        TIMER_KEY_POMODORO_STATE
    }

    private enum TimerState {
        TIMER_STATE_RUNNING,
        TIMER_STATE_STOPPED,
        TIMER_STATE_PAUSED,
    }

    private enum PomodoroState {
        POMODORO_STATE_WORK,
        POMODORO_STATE_BREAK,
       // POMODORO_STATE_LONG_BREAK,
    }

    private var _timerState = TIMER_STATE_STOPPED;
    private var _pomodoroState = POMODORO_STATE_WORK;

    private const TIMER_DURATION_DEFAULT = (25 * 60);

    var _count as Number = 0;
    
    private var _timerDuration as Number?;
    private var _timerStartTime as Number?;
    private var _timerPauseTime as Number?;

    private var _timer as Timer.Timer;
    private var _timerController as PomoMinTimerController;

    //! Initialize variables for this view
    //! @param backgroundRan Contains background data if background ran
    function initialize(backgroundRan as PersistableType) {
        View.initialize();

        // create timer controller
        _timerController = new PomoMinTimerController(self, backgroundRan);

        System.println("VIEW initialize");
        
        // Create our timer object that is used to drive display updates
        _timer = new Timer.Timer();

        // Fetch the current state from storage
        _timerState = Storage.getValue(TIMER_KEY_TIMER_STATE);
        
        // Fetch the persisted values from storage
        if (backgroundRan != null) {
            // If we got an expiration event from the background process
            // when we started up, reset the timer back to the default value.
            initializeTimerData();
        }else{
            // Otherwise, we must know if the timer is running or not.

            if(_timerState == TIMER_STATE_RUNNING){
                initializeTimerRunningData();
            }else if(_timerState == TIMER_STATE_STOPPED){
                initializeStoppedTimerData();
            }else if(_timerState == TIMER_STATE_PAUSED){
                initializeTimerPausedData();
            }else{
                _timerState = TIMER_STATE_STOPPED;
                initializeStoppedTimerData();
            }

        }
        /*
        // Fetch the current state from storage
        var pomodoroState = Storage.getValue(TIMER_KEY_POMODORO_STATE);
        if (pomodoroState instanceof Number) {
            _pomodoroState = pomodoroState;
        } else {
            _pomodoroState = POMODORO_STATE_WORK;
            _timerDuration = TIMER_DURATION_DEFAULT;
            Storage.setValue(TIMER_KEY_DURATION, _timerDuration);
        }

        // If we got a timer state from storage, use it. Otherwise, default.
        if (timerState instanceof Number) {
            _timerState = timerState;
            if(_timerState == TIMER_STATE_RUNNING){
                _timerStartTime = Storage.getValue(TIMER_KEY_START_TIME);
                _timerPauseTime = Storage.getValue(TIMER_KEY_PAUSE_TIME);
                _timerDuration = Storage.getValue(TIMER_KEY_DURATION);
                _timer.start(method(:requestUpdate), 1000, true);
            }
        } else {
            _timerState = TIMER_STATE_STOPPED;
        }

        // Check if the timer is stopped.
        if (_timerState == TIMER_STATE_STOPPED) {
            // If the timer is stopped, then reset the timer values.
            resetDefaultTimer();
        }*/

    }

    public function onSelectPressed() as Boolean {
        return _timerController.onSelectPressed();
    }

    public function onBackPressed() as Boolean {
        return _timerController.onBackPressed();
    }
    
    // Use this when a message indicating that the timer has expired
    // is received from the background process. This will reset the
    // timer back to the default value.
    function initializeTimerData() as Void {
        _timerState = TIMER_STATE_STOPPED;

        // Fetch the current state from storage
        var lastPomodoroState = Storage.getValue(TIMER_KEY_POMODORO_STATE);

        if(lastPomodoroState == POMODORO_STATE_WORK){
            _timerDuration = 5 * 60;
            _pomodoroState = POMODORO_STATE_BREAK;
        }else if(lastPomodoroState == POMODORO_STATE_BREAK){
            _timerDuration = 25 * 60;
            _pomodoroState = POMODORO_STATE_WORK;
        }

        _timerStartTime = null;
        _timerPauseTime = null;
    }

    function initializeTimerRunningData() as Void {

        // Fetch the current state from storage
        var lastPomodoroState = Storage.getValue(TIMER_KEY_POMODORO_STATE);

        if(lastPomodoroState == POMODORO_STATE_WORK){
            _timerDuration = 25 * 60;
        }else if(lastPomodoroState == POMODORO_STATE_BREAK){
            _timerDuration = 5 * 60;
        }

        _pomodoroState = lastPomodoroState;
        _timerStartTime = Storage.getValue(TIMER_KEY_START_TIME);
        _timerPauseTime = Storage.getValue(TIMER_KEY_PAUSE_TIME);
        _timerDuration = Storage.getValue(TIMER_KEY_DURATION);
        _timer.start(method(:requestUpdate), 1000, true);
    }

    function initializeTimerPausedData() as Void {

        // Fetch the current state from storage
        var lastPomodoroState = Storage.getValue(TIMER_KEY_POMODORO_STATE);

        if(lastPomodoroState == POMODORO_STATE_WORK){
            _timerDuration = 25 * 60;
        }else if(lastPomodoroState == POMODORO_STATE_BREAK){
            _timerDuration = 5 * 60;
        }
        _pomodoroState = lastPomodoroState;
        _timerStartTime = Storage.getValue(TIMER_KEY_START_TIME);
        _timerPauseTime = Storage.getValue(TIMER_KEY_PAUSE_TIME);
        _timerDuration = Storage.getValue(TIMER_KEY_DURATION);
    }

    function initializeStoppedTimerData() as Void {

        // Fetch the current state from storage
        var lastPomodoroState = Storage.getValue(TIMER_KEY_POMODORO_STATE);
        if(lastPomodoroState == POMODORO_STATE_WORK){
            _timerDuration = 25 * 60;
        }else if(lastPomodoroState == POMODORO_STATE_BREAK){
            _timerDuration = 5 * 60;
        }else{
            _timerDuration = 25 * 60;
            lastPomodoroState = POMODORO_STATE_WORK;
        }
        _pomodoroState = lastPomodoroState;
        _timerStartTime = null;
        _timerPauseTime = null;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function finishTimerFromForeground() as Void {
        _timerState = TIMER_STATE_STOPPED;
        _timerStartTime = null;
        _timerPauseTime = null;
        if(_pomodoroState == POMODORO_STATE_WORK){
            _timerDuration = 5 * 60;
            _pomodoroState = POMODORO_STATE_BREAK;
        }else if(_pomodoroState == POMODORO_STATE_BREAK){
            _timerDuration = 25 * 60;
            _pomodoroState = POMODORO_STATE_WORK;
        }

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

        
        saveProperties();
        WatchUi.requestUpdate();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var elapsed = 0;
        if(_pomodoroState == POMODORO_STATE_WORK){
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        }else if(_pomodoroState == POMODORO_STATE_BREAK){
            dc.setColor(0xffaa55, Graphics.COLOR_BLACK);
        }

        dc.clear();

        if(_timerState == TIMER_STATE_STOPPED){
            // only draw
            
        }else if(_timerState == TIMER_STATE_RUNNING){
           elapsed = Time.now().value() - _timerStartTime;
           if(elapsed >= _timerDuration) {
                elapsed = _timerDuration;
                _timerPauseTime = Time.now().value();
                _timer.stop();
                finishTimerFromForeground();
                return;
           }

        }else if(_timerState == TIMER_STATE_PAUSED){
            elapsed = _timerPauseTime - _timerStartTime;
            dc.setColor(0x9db8cf, Graphics.COLOR_BLACK);
        }
        

        // If the timer is running, then calculate the elapsed time
        // since the timer started. If the timer is paused, then
        // calculate the elapsed time since the timer was paused.
        /*if(_timerState == TIMER_STATE_RUNNING) {
            

            if(elapsed >= _timerDuration) {

                _timerState = TIMER_STATE_STOPPED;

                // The timer has expired. Stop the timer and reset the
                // timer values.
                elapsed = _timerDuration;

                // Draw the time in red if the timer has expired
                textColor = Graphics.COLOR_RED;

                _timerPauseTime = Time.now().value();
                _timer.stop();

                resetDefaultTimer();
                WatchUi.requestUpdate();
                return;
            }
        } else if(_timerState == TIMER_STATE_PAUSED) {
            textColor = Graphics.COLOR_YELLOW;
            elapsed = _timerPauseTime - _timerStartTime;
        }*/
        
        var timerValue = _timerDuration - elapsed;

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
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // A function to update the arc
    function updateArc(dc as Dc, angle as Number) as Void {
        //dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        //dc.clear();
        
        dc.setPenWidth(1);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2-19, Graphics.ARC_CLOCKWISE, 90, 90);

        dc.setPenWidth(10);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2-20, Graphics.ARC_CLOCKWISE, 90, angle);
        //dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        //dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, "25:00", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //! Set up a background event to occur when the timer expires. This
    //! will alert the user that the timer has expired even if the
    //! application does not remain open.
    public function setBackgroundEvent() as Void {
        
        // if ((_timerStartTime != null) && (_timerPauseTime == null)) {
        if (_timerState == TIMER_STATE_RUNNING) {
            var time = new Time.Moment(_timerStartTime);
            time = time.add(new Time.Duration(_timerDuration));
            try {
                var info = Time.Gregorian.info(time, Time.FORMAT_SHORT);
                Background.registerForTemporalEvent(time);
            } catch (e instanceof Background.InvalidBackgroundTimeException) {
                // We shouldn't get here because our timer is 5 minutes, which
                // matches the minimum background time. If we do get here,
                // then it is not possible to set an event at the time when
                // the timer is going to expire because we ran too recently.
            }
        }
    }

    //! If we do receive a background event while the application is open,
    //! go ahead and reset to the default timer.
    public function backgroundEvent() as Void {
        _timerState = TIMER_STATE_STOPPED;
        resetDefaultTimer();
        WatchUi.requestUpdate();
    }

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
    }

    //! Save all the persisted values into the object store. This gets
    //! called by the Application base before the application shuts down.
    public function saveProperties() as Void {
        Storage.setValue(TIMER_KEY_DURATION, _timerDuration);
        Storage.setValue(TIMER_KEY_START_TIME, _timerStartTime);
        Storage.setValue(TIMER_KEY_PAUSE_TIME, _timerPauseTime);
        Storage.setValue(TIMER_KEY_TIMER_STATE, _timerState);
        Storage.setValue(TIMER_KEY_POMODORO_STATE, _pomodoroState);
    }

    //! Delete the background event. We can get rid of this event when the
    //! application opens because now we can see exactly when the timer
    //! is going to expire. We will set it again when the application closes.
    public function deleteBackgroundEvent() as Void {
        Background.deleteTemporalEvent();
    }

    //! This is the callback method we use for our timer. It is
    //! only needed to request display updates as the timer counts
    //! down so we see the updated time on the display.
    public function requestUpdate() as Void {
        WatchUi.requestUpdate();
    }
}
