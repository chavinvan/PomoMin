import Toybox.Application.Storage;
import Toybox.Lang;

class NotificationsConfigRepository {

    private var notificationConfigProvider as NotificationsConfigProvider;
    private static var instance;

    public function initialize() {
        // initialize the interval config provider
        notificationConfigProvider = new NotificationsConfigProvider();
    }

    static function getInstance() {
        if (instance == null) {
            instance = new NotificationsConfigRepository();
        }
        return instance;
    }

    public function toggleNotificationSound() as Void {
        var notificationSoundEnabled = getNotificationSound();
        notificationSoundEnabled = !notificationSoundEnabled;
        notificationConfigProvider.setNotificationSound(notificationSoundEnabled);
    }

    public function getNotificationSound() as Boolean{
        var notificationSoundEnabled = notificationConfigProvider.getNotificationSound();
        if(notificationSoundEnabled == null) {
            notificationSoundEnabled = true;
        }
        return notificationSoundEnabled;
    }

    public function toggleNotificationVibration() as Void {
        var notificationVibrationEnabled = getNotificationVibration();
        notificationVibrationEnabled = !notificationVibrationEnabled;
        notificationConfigProvider.setNotificationVibration(notificationVibrationEnabled);
    }

    public function getNotificationVibration() as Boolean{
        var notificationVibrationEnabled = notificationConfigProvider.getNotificationVibration();
        if(notificationVibrationEnabled == null) {
            notificationVibrationEnabled = true;
        }
        return notificationVibrationEnabled;
    }
}