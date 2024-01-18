import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.Application;

(:typecheck(disableBackgroundCheck))
class PomoMinTimerController {

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

    private var _pomoView as PomoMinView;
    private var _timer as Timer.Timer;
    private var _timerState as TimerState;
    private var _pomodoroState as PomodoroState;

    function initialize(pomoView as PomoMinView, backgroundRan as PersistableType) {
        _pomoView = pomoView;

        // Create our timer object that is used to drive display updates
        _timer = new Timer.Timer();

        // Fetch the current state from storage
        _timerState = Storage.getValue(TIMER_KEY_TIMER_STATE);

        if(_timerState == null)
            _timerState = TIMER_STATE_STOPPED;

        // Fetch the persisted values from storage
        if (backgroundRan != null) {
            // If we got an expiration event from the background process
            // when we started up, reset the timer back to the default value.
            initializeTimerDataFromBackground();
        }
        // otherwise, the app was started manually
        else{
            // we must know if the timer is running or not.

            if(_timerState == TIMER_STATE_RUNNING){
                initializeTimerDataPausedOrRunning();
                // start timer
                _timer.start(method(:secondPassed), 1000, true);

                // call saveProperties
                saveProperties();
            }else if(_timerState == TIMER_STATE_STOPPED){
                initializeTimerDataStopped();
            }else if(_timerState == TIMER_STATE_PAUSED){
                initializeTimerDataPausedOrRunning();
            }

        }
    }

    public function onSelectPressed() as Boolean {
        //_pomoView.startStopTimer();

        // get current time
        var now = Time.now().value();

        // check state
        // if the timer was stopped, it should start
        if(_timerState == TIMER_STATE_STOPPED){
            // change timer state to running
            _timerState = TIMER_STATE_RUNNING;

            // define start time
            _timerStartTime = now;

            // start timer
            _timer.start(method(:secondPassed), 1000, true);
        }
        // if it was paused, it should restart
        else if(_timerState == TIMER_STATE_PAUSED){
            // change timer state to running
            _timerState = TIMER_STATE_RUNNING;

            // define start time using also pause time
            _timerStartTime = _timerStartTime + (now - _timerPauseTime);

            // reset pause time
            _timerPauseTime = null;

            // start timer
            _timer.start(method(:secondPassed), 1000, true);
        }
        // if it was already running, it should pause
        else if(_timerState == TIMER_STATE_RUNNING){
            // change timer state to paused
            _timerState = TIMER_STATE_PAUSED;

            // define pause time
            _timerPauseTime = now;

            // stop timer
            _timer.stop();
        }

        // save current properties because there was a change
        saveProperties();

        // update view. Maybe needed only when paused?
        _pomodoroView.requestUpdate();
        return true;
    }


    public function onBackPressed() as Boolean {
        // check current state
        // if it's already running, it should exit from the app
        if(_timerState == TIMER_STATE_RUNNING)
            return false;
        
        // if it is paused or stopped, it should restart
        _timerState = TIMER_STATE_STOPPED
        initializeTimerDataManually()

        // save current properties because there was a change
        saveProperties();

        // update view
        _pomoView.requestUpdate();
        return true;
    }

    // Use this when a message indicating that the timer has expired
    // is received from the background process. This will reset the
    // timer back to the default value.
    function initializeTimerDataFromBackground() as Void {
        
        // Fetch the current state from storage
        var lastPomodoroState = Storage.getValue(TIMER_KEY_POMODORO_STATE);

        // define next state and duration
        if(lastPomodoroState == POMODORO_STATE_WORK){
            changeStateToBreak();
        }else if(lastPomodoroState == POMODORO_STATE_BREAK){
            changeStateToWork();
        }

        // reset variables
        _timerState = TIMER_STATE_STOPPED;
        _timerStartTime = null;
        _timerPauseTime = null;
    }

    // Use this when the timer has been manually reset.
    function initializeTimerDataManually() as Void {
        
        // Fetch the current state from storage
        var lastPomodoroState = _pomodoroState;

        // define next state and duration
        if(lastPomodoroState == POMODORO_STATE_WORK){
            changeStateToBreak();
        }else if(lastPomodoroState == POMODORO_STATE_BREAK){
            changeStateToWork();
        }

        // reset variables
        _timerState = TIMER_STATE_STOPPED;
        _timerStartTime = null;
        _timerPauseTime = null;
    }

    function initializeTimerDataPausedOrRunning() as Void {

        // Fetch the current state from storage
        var lastPomodoroState = Storage.getValue(TIMER_KEY_POMODORO_STATE);

        // I think the following is useless because I'm already
        // taking _timerDuration from Storage
        // TODO: test
        if(lastPomodoroState == POMODORO_STATE_WORK){
            changeStateToWork();
        }else if(lastPomodoroState == POMODORO_STATE_BREAK){
            changeStateToBreak();
        }
        
        // reset variables
        _timerStartTime = Storage.getValue(TIMER_KEY_START_TIME);
        _timerPauseTime = Storage.getValue(TIMER_KEY_PAUSE_TIME);
        _timerDuration = Storage.getValue(TIMER_KEY_DURATION);
    }

    function initializeTimerDataStopped() as Void {

        // Fetch the current state from storage
        var lastPomodoroState = Storage.getValue(TIMER_KEY_POMODORO_STATE);
        
        if(lastPomodoroState == null)
            lastPomodoroState = POMODORO_STATE_WORK;

        // define next state and duration
        if(lastPomodoroState == POMODORO_STATE_WORK){
            changeStateToWork();
        }else if(lastPomodoroState == POMODORO_STATE_BREAK){
            changeStateToBreak();
        }

        // reset variables
        _timerStartTime = null;
        _timerPauseTime = null;
    }

    private function secondPassed(){

        var elapsed = 0;

        // Check if timer state is running
        if (_timerState == TIMER_STATE_RUNNING){

            // calculate elapsed time
            var currentTime = Time.now().value();
            elapsed = currentTime - _timerStartTime;

            // check if timer has finished
            if(elapsed >= _timerDuration){
                elapsed = _timerDuration;
                _timerPauseTime = currentTime;
                finishTimerFromForeground();
                
                // TODO: should the method end here with a return? probably yes
            }
        } else if (_timerState == TIMER_STATE_PAUSED) {
            // TODO: it shouldn't arrive here because when timer is paused, it shouldn't be called the timer callback
            elapsed = _timerPauseTime - _timerStartTime;
        }

        // calculate timer value
        var timerValue = _timerDuration - elapsed;

        // TODO: send the timer value to the view, where it must calculate seconds, minutes, string and angle
        // TODO: request update of the view
    }

    private function finishTimerFromForeground() as Void{
        // stop timer
        _timer.stop();

        // check current state and change it
        if(_pomodoroState == POMODORO_STATE_WORK){
            changeStateToBreak();
        }else if(_pomodoroState == POMODORO_STATE_BREAK){
            changeStateToWork();
        }

        // TODO: voy por este método
    }

    private changeStateToWork() as Void {
        _timerDuration = 25 * 60; // TODO: minutes from config
        _pomodoroState = POMODORO_STATE_WORK;
    }

    private changeStateToBreak() as Void {
        _timerDuration = 5 * 60; // TODO: minutes from config
        _pomodoroState = POMODORO_STATE_BREAK;
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
}