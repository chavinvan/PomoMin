import Toybox.Application.Storage;
import Toybox.Lang;

class IntervalsConfigProvider {

    const INTERVAL_FOCUS_DURATION_STORAGE_KEY = "interval_focus_duration";
    const INTERVAL_BREAK_DURATION_STORAGE_KEY = "interval_break_duration";

    public function setFocusIntervalDuration(duration as Number) as Void {
        Storage.setValue(INTERVAL_FOCUS_DURATION_STORAGE_KEY, duration);
    }

    public function getFocusIntervalDuration() as Number{
        return Storage.getValue(INTERVAL_FOCUS_DURATION_STORAGE_KEY);
    }

    public function setBreakIntervalDuration(duration as Number) as Void {
        Storage.setValue(INTERVAL_BREAK_DURATION_STORAGE_KEY, duration);
    }

    public function getBreakIntervalDuration() as Number{
        return Storage.getValue(INTERVAL_BREAK_DURATION_STORAGE_KEY);
    }
}