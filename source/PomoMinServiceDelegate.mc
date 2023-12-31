//
// Copyright 2017-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Attention;

//! The Service Delegate is the main entry point for background processes.
//! Our onTemporalEvent() method will run each time our periodic event
//! is triggered by the system. This indicates a set timer has expired, and
//! we should attempt to notify the user.
(:background)
class PomoMinServiceDelegate extends System.ServiceDelegate {

    //! Constructor
    public function initialize() {
        ServiceDelegate.initialize();
    }

    //! If our timer expires, it means the application timer ran out,
    //! and the main application is not open. Prompt the user to let them
    //! know the timer expired.
    public function onTemporalEvent() as Void {

        // Use background resources if they are available
        if (Application has :loadResource) {
            var pomodoroState = Storage.getValue(4);
            if (pomodoroState == 0) {
                Background.requestApplicationWake(Application.loadResource($.Rez.Strings.WorkTimerExpired) as String);
            } else {
                Background.requestApplicationWake(Application.loadResource($.Rez.Strings.BreakTimerExpired) as String);
            }
        } else {
            Background.requestApplicationWake("Your timer has expired!");
        }

        /*
        if (Attention has :vibrate) {
            var vibeData =
            [
                new Attention.VibeProfile(50, 2000), // On for two seconds
            ];
            Attention.vibrate(vibeData);
        }*/
        
        // Write to Storage, this will trigger onStorageChanged() method in foreground app
        if (Application.AppBase has :onStorageChanged) {
            Storage.setValue("1", 1);
        }

        Background.exit(true);
    }
}
