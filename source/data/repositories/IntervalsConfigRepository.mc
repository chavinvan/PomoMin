import Toybox.Application.Storage;
import Toybox.Lang;

class IntervalsConfigRepository {

    private var intervalConfigProvider as IntervalsConfigProvider;
    private static var instance;

    public function initialize() {
        // initialize the interval config provider
        intervalConfigProvider = new IntervalsConfigProvider();
    }

    static function getInstance() {
        if (instance == null) {
            instance = new IntervalsConfigRepository();
        }
        return instance;
    }

    public function setFocusIntervalDuration(duration as Number) as Void {
        intervalConfigProvider.setFocusIntervalDuration(duration);
    }

    public function getFocusIntervalDuration() as Number{
        var focusIntervalDuration = intervalConfigProvider.getFocusIntervalDuration();
        if(focusIntervalDuration == null){
            focusIntervalDuration = 25;
        }
        return focusIntervalDuration;
    }

    public function setBreakIntervalDuration(duration as Number) as Void {
        intervalConfigProvider.setBreakIntervalDuration(duration);
    }

    public function getBreakIntervalDuration() as Number{
        var breakIntervalDuration = intervalConfigProvider.getBreakIntervalDuration();
        if(breakIntervalDuration == null){
            breakIntervalDuration = 5;
        }
        return breakIntervalDuration;
    }
}