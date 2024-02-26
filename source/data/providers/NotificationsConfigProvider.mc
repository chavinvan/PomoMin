import Toybox.Application.Storage;
import Toybox.Lang;

class NotificationsConfigProvider {

    const NOTIFICATION_SOUND_STORAGE_KEY = "notification_sound";
    const NOTIFICATION_VIBRATION_STORAGE_KEY = "notification_vibration";

    public function setNotificationSound(enabled as Boolean) as Void {
        Storage.setValue(NOTIFICATION_SOUND_STORAGE_KEY, enabled);
    }

    public function getNotificationSound() as Boolean?{
        return Storage.getValue(NOTIFICATION_SOUND_STORAGE_KEY);
    }

    public function setNotificationVibration(enabled as Boolean) as Void {
        Storage.setValue(NOTIFICATION_VIBRATION_STORAGE_KEY, enabled);
    }

    public function getNotificationVibration() as Boolean?{
        return Storage.getValue(NOTIFICATION_VIBRATION_STORAGE_KEY);
    }
}