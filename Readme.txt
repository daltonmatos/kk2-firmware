KK2.0 v1.6++ CPPM R5 firmware by RC911


Features (Revision 5)
=====================
This custom firmware is based on the original KK2.0 1V6 firmware by Rolf Bakke. It has the following features:
- This version is for CPPM (aka. PPM) only. All code related to standard receiver input has been removed.
- SL Stick Mixing mode with adjustable rate setting. This will give a soft transition from Self-level to ACRO mode based on aileron/elevator stick deflection. It will be displayed on the SAFE screen as "SL Mix" when active. Read the instructions below.
- ESC calibration is done without a transmitter and it is sufficient to hold down a single button. This will help users with slow binding receivers do ESC calibration in a simple and safe way. This feature must be enabled through the KK2 menu before it can be accessed. Read the instructions below to learn the new ESC calibration routine.
- Customizable AUX switch functions with support for 5 switch positions. Read the instructions below.
- Remote tuning of PI gains, ACC trim and gimbal gains using potentiometers assigned to AUX2 and AUX3.
- Channel mapping with support for AUX2, AUX3 and AUX4 features. Read more about this feature below.
- Quiet ESCs while browsing the KK2 menu and editing settings. This feature can be switched on/off from the Mode Settings screen.
- Servo jitter has been reduced on M7 and M8 and motor layouts for Dualcopter and Tricopter were changed to take advantage of this.
- PWM output resolution has increased from 555 to 625 steps on M1 - M6 and from 555 to 2500 steps on M7 and M8. You may have to increase all Stick Scaling values by 10 - 15% because of this.
- Alarm (i.e. 'Lost Model Alarm') can be activated from the AUX switch. It will also sound after 20 seconds at zero throttle (i.e. after the Auto Disarm countdown).
- Remote gimbal offset control using AUX2 and AUX3. Based on Steveis' firmware, but with some of my own changes.
- Support for gimbals with differential mixing (in addition to normal gimbals). Differential mixing code borrowed from Brontide's firmware.
- Two gimbal modes, LOCK and HOME, are controlled from a 3-way switch assigned to Aux 4. Home position is configurable from the Gimbal Settings screen.
- Flight timer (displayed on the SAFE screen) runs while armed and throttle is above idle.
- The Version Info screen is accessible from the main menu and is not displayed during start-up.
- Button and arming beeps can be turned off individually.
- Adjustable LCD contrast.
- Battery voltage is logged and displayed on the SAFE screen.
- The KK2 LED is flashing in sync with the LVA (Low Voltage Alarm) beeps.
- The KK2 LED will flash rapidly for a few seconds after arming if the Low Voltage Alarm value is set too low.
- A Factory Reset will clear the mixer table instead of loading the QUAD+ motor layout. This feature was borrowed from Brontide's firmware and further improved by me. An error message (i.e. "No motor layout") is displayed on the SAFE screen and arming is refused until a motor layout has been loaded.
- Gyro limits have been expanded to let boards with slightly damaged gyros arm. Values borrowed from Steveis' firmware.

See the whatsnew.txt document to learn what has changed since the previous version.
See the tips.txt document for a few tips and tricks regarding setup, tuning and crash investigation. 


Connections
===========
The CPPM signal (aka. PPM) must be connected to the aileron input connector on your KK2 board. The other input pins should remain disconnected.
If your receiver takes a long time binding to the transmitter, the status message on the SAFE screen will first read "No CPPM input!", but it will change to "OK" as soon as a valid CPPM signal is detected (unless there are other, more important messages to display).

PS: Arming is refused unless the status text on the SAFE screen reads "OK" or "OK. Tuning ...".


ESC calibration routine (no transmitter required)
=================================================
This procedure is now a lot safer since ESC calibration no longer can be trigged by a damaged button. This is achieved by forcing you to temporarily activate the ESC calibration feature through the KK2 menu before using it. If any button is damaged you will not be able to navigate the KK2 menus without noticing it. The ESC calibration state is checked on every start-up and automatically disabled if it is found to be active.

Here is the improved ESC calibration procedure:
1. Power up your KK2 board normally. The ESC calibration feature is now disabled by default to prevent accidental activation.
2. From the KK2 menu, select the "ESC calibration" item to activate ESC calibration temporarily.
3. Disconnect the battery. This is actually required since there is no exit from this screen.
4. Remove all propellers, but leave the motors connected so that you can hear the ESC confirmation beeps!
5. Disconnect servos if they cannot handle a sudden travel from endpoint to endpoint.
6. Hold down any button (i.e. a single button) while connecting the flight battery.
7. Keep holding the button down while waiting for the 'High throttle' level beep(s) and then release it to set the 'Low throttle' level.
8. Push button 1 (EXIT) after the final ESC confirmation beeps to return to the SAFE screen. The ESC calibration feature is now disabled again.

Observe:
- If you fail to trigger the ESC calibration you'll have to repeat the procedure from step #2 above to activate it again.
- Upper throttle level will be set to 2.0 ms and the lower throttle level to 1.02 ms, which are the exact same values used by the original KK2.0 1V6 firmware (Don't be fooled by the "Throttle pass-through" message).
- The 'Version Information' screen and its one second delay has been removed from the start-up sequence. This will make the ESC calibration routine safer because your ESCs will now see the 'full throttle' signal one second sooner (compared to the original KK2.0 1V6 firmware) and this reduces the risk for having motors going full throttle while doing the ESC calibration.


AUX switch setup
================
From the AUX Switch Setup screen you can select which function (Acro, SL Mixing, Normal SL or Alarm) should be active depending on the AUX switch position. Select the item you want to modify and then press the CHANGE button to cycle through the available settings.

Observe:
- The current AUX switch position will be displayed as a black dot in the first column to help you assign the wanted function to the preferred switch position. The Receiver Test screen can also be used to observe the AUX switch position values.
- To access position #2 and #4 you will need to use mixing on your transmitter.
- The same function can be assigned to several positions of your AUX switch.
- A confirmation beep is produced by the buzzer every time you change flight mode (not while browsing the KK2 menus though).
- Selecting "Alarm" position will also activate SL Mix mode.


SL stick mixing
===============
SL Mix mode can be activated from a switch assigned to the AUX input channel and the mixing rate is set from the Self-level Settings screen. The mixing rate parameter is still related to your SL P-gain setting so you should tune the SL P-gain first. A value of 5 corresponds to the LOW setting used in the first KK2.0 version, 10 corresponds to MEDIUM and 20 to HIGH, but you can even go as high as 50 if your SL P-gain is very high.

The Stick Scaling parameter called "SL Mixing" lets you adjust the stick input sensitivity for SL Mix mode relative to Acro or normal SL mode. If you feel that SL Mix mode is less responsive compared to Acro mode you can increase this value. To make SL Mix mode act more like normal SL mode you should lower this value. In any case you should adjust the stick scaling parameters to suit your flying style in Acro or Normal SL mode before adjusting the "SL Mixing" parameter. Leave it at 100% (default) if you only use SL Mix mode.

I use this mode all the time now and found that it is great for practicing aerobatics. If you get in trouble (e.g. lose orientation) you can just center the aileron/elevator stick and the model will level itself. Another advantage is that you don't have to ramp up your 'Stick Scaling' values or mess with PI limits for flying around (compared to the original Self-level mode).

BEWARE! If you center your aileron/elevator stick while your model is upside-down it will remain inverted until you add some more stick input. This is a "feature" of the original KK2 firmware and not something that I've implemented. 

Observe:
- A 3-way switch should be assigned to the AUX channel to select flight mode - Acro, SL Mix or Normal SL. The selected flight mode will be displayed on the SAFE screen.
- You should tune your model as best as you can in both acro and normal SL mode before trying the SL Stick Mixing mode.
- Don't count on this mode saving your model if you perform acrobatic stunts and exceed the 440 degrees/second gyro limitation. It may actually make it worse! 
- If your model has built up any momentum, it will not stop moving immediately after centering the aileron/elevator stick! Take it slow if you're at beginner level.
- This mode will work best for transmitters configured to use mode 2 or 3 (i.e. with aileron and elevator on the same stick).
- Avoid using this mode if your model requires excessive stick trimming (e.g. when center of gravity is too far off). This will affect the SL mixing. In other words: You should only use this mode on a well-balanced model.


Lost model alarm
================
The Lost Model alarm can be trigged from a switch assigned to the AUX input channel, but only if you have activated the Alarm function on the AUX Switch Setup screen.

An alternative way to activate the Lost Model Alarm is to wait 20 seconds for the Auto Disarm feature (must be active) to disarm your KK2 board. The alarm will not sound if you disarm your KK2 manually and the alarm will stop when you arm your board again.

Observe:
- The alarm will still be trigged after 30 minutes counted from the last arm/disarm operation, just like in the original KK2.0 1V6 firmware.


Channel mapping
===============
A few CPPM receivers don't follow the default channel order so to fix this the Channel Mapping feature will let you rearrange all input channels.

If your receiver outputs less than 8 channels you can use the Channel Mapping feature to access features normally controlled from AUX2, AUX3 or AUX4. If you have only 6 real channels you can exchange your AUX channel (and all its features) for one of the virtual channels (AUX2, AUX3 or AUX4). Sacrificing the AUX features will only be a problem if you need to change flight mode while flying, but if you normally stay in one flight mode you can use the AUX Switch Setup screen to lock the controller in the desired mode. Remember that you can use one user profile for aerobatics and the next profile for SL mode so that you can quite easily switch flight modes from the SAFE screen. The Lost Model Alarm will still be activated if you let the Auto Disarm counter time out (keeping throttle at idle position for 20 seconds).

To better understand how the channel mapping works it might help to look at the items in the first column (i.e. Aileron, Elevator, Throttle...) as "functions" and the values in the second column as channel numbers going from 1 through 8 in the order your receiver is outputting them. If the throttle channel is output first (i.e. channel 1) then the Throttle "function" value should be set to 1. If throttle is output third then you should set this value to 3.

ATTENTION:
After modifying the channel mapping, go to the Receiver Test screen and verify that aileron, elevator, throttle and rudder respond correctly to your stick input!

Observe:
- Mapping the same input channel to multiple functions is allowed, but should be avoided unless you know what you're doing. In any case, DO NOT map the same input channel to multiple flight critical functions!!!
- See the Tips.txt document for more examples on how to use the channel mapping feature.


Remote gimbal offset control
============================
Gimbal offsets can be controlled from your transmitter channels assigned to AUX2 (pitch) and AUX3 (roll). Potentiometers are recommended, but you can also use switches if you only want to change between a few fixed offset positions. This feature is based on Steveis' firmware, but I did some changes to make it utilize the full input control range.

Observe:
- Offsets cannot be adjusted while navigating the KK2 menus. This can only be done during flight and at the SAFE screen.


Other gimbal features
=====================
The gimbal Lock and Home features are controlled from a 3-way switch assigned to AUX4. Position #1 activates the Lock feature while position #3 activates the Home feature. Both features are inactive when the switch is in the middle position, making the gimbal operate normally. The second page on the Receiver Test screen can be used to find which feature is assigned to which switch position (AUX4).

When activated, the Lock feature will make the gimbal stop responding to self-level corrections, but gimbal offsets can still be adjusted remotely.

When the Home feature is activated the gimbal will go to a user-defined position and stay there until this feature is switched off again. It will not respond to self-level corrections nor remote offset adjustments in this mode. The Home Roll and Pitch positions are set from the second Gimbal Settings screen. Valid range is -1000 to 1000.


Remote tuning
=============
This feature allows you to adjust several parameters from your transmitter (even while flying). This requires potentiometers assigned to AUX2 and AUX3 on your transmitter. Use the Receiver Test (2nd) screen to make sure that the input range for AUX2 and AUX3 goes from -100 to +100 with zero at center.
You can adjust PI gains for aileron, elevator and rudder using this feature. If aileron and elevator is linked (see the Mode Settings screen) you will be able to adjust P and I gains for both axes simultaneously. You can also adjust self-level P gain, ACC trim values and roll and pitch gains for camera gimbal remotely.

This is the recommended procedure for aileron, elevator and rudder PI gain tuning:
1. Center your potentiometers (AUX2 and AUX3).
2. Go to the 'Remote Tuning' screen and select aileron, elevator or rudder tuning mode and a suitable input rate.
3. You can now try adjusting your potentiometers to learn which one is for P and which one is for I gain, but remember to center them before leaving. You will also see how much the gain values will change based on your input rate selection.
4. Return to the SAFE screen by pressing the BACK button twice. The status text will show the selected tuning mode.
5. Now you can fly in ACRO/MANUAL mode and adjust your potentiometers until you have found the best setting.
6. Land and go to 'Remote Tuning' screen again.
7. Press the SAVE button to save the tuned values and then center your potentiometers.
8. Repeat from step #4 (with a different input rate) if required.

This is the recommended procedure for SL P gain tuning:
1. Center your potentiometer assigned to AUX2.
2. Go to the 'Remote Tuning' screen and select SL gain tuning mode and a suitable input rate.
3. You can now try adjusting your potentiometers to learn which one controls the P gain, but remember to center it before leaving. You will also see how much the gain value will change based on your input rate selection.
4. Return to the SAFE screen by pressing the BACK button twice. The status text will show the selected tuning mode.
5. Now you can fly in normal SL mode (using 'SL Stick Mixing' mode will have no effect) and adjust your potentiometer until you have found the best setting.
6. Land and go to 'Remote Tuning' screen again.
7. Press the SAVE button to save the tuned gain value and then center your potentiometer.
8. Repeat from step #4 (with a different input rate) if required.

This is the recommended procedure for ACC trim tuning:
1. Center your potentiometers (AUX2 and AUX3).
2. Go to the 'Remote Tuning' screen and select ACC trim tuning mode and a suitable input rate. TIP: Start with input rate set to HIGH.
3. You can now try adjusting your potentiometers to learn which one is for pitch (P) and which one is for roll (R) trim, but remember to center them before leaving. You will also see how much the gain values will change based on your input rate selection.
4. Return to the SAFE screen by pressing the BACK button twice. The status text will show the selected tuning mode.
5. Now you can fly in normal SL mode and adjust your potentiometers until drifting is reduced to a minimum.
6. Go to the 'Remote Tuning' screen again.
7. Press the SAVE button to save the tuned trim values and then center your potentiometers.
8. Repeat from step #4 (with a different input rate) if required.

This is the recommended procedure for gimbal gain tuning:
1. Connect your camera to an external screen so you can observe the image while tilting your copter.
2. Center your potentiometers (AUX2 and AUX3).
3. Go to the 'Gimbal Settings' screen and set both gains to 500 (use -500 if you need to reverse the servo direction). Also set the mixing mode to match your gimbal type.
4. Go to the 'Remote Tuning' screen and select gimbal tuning mode and a suitable input rate. TIP: Start with input rate set to HIGH.
5. You can now try adjusting your potentiometers to learn which one is for pitch (P) and which one is for roll (R) gain, but remember to center them before leaving. You will also see how much the gain values will change based on your input rate selection.
6. Return to the SAFE screen by pressing the BACK button twice. The status text will show the selected tuning mode. Arming is not recommended.
7. Move your copter around while watching the image on the external screen and adjust the potentiometers until the image appears as stable as possible.
8. Go to the 'Remote Tuning' screen again.
9. Press the SAVE button to save the tuned gain values and then center your potentiometers.
10.Repeat from step #6 (with a different input rate) if required.
11.Set Tuning Mode to OFF when done. This will let you use the potentiometers to control gimbal offsets again.

Observe:
- You can still use the original/manual input method to adjust all parameters.
- If you find it difficult to adjust the potentiometers while flying you can always land your model, adjust the potentiometers and take off again.
- Gimbal servo offsets are centered while tuning.
- ACC trim values must be tuned in NORMAL SL mode only. Using "SL Mix" mode will have no visual effect.
- The selected tuning mode will not be saved. Power cycling will make it return to normal mode.
- The chosen input/tuning rate will be saved.


Button/Arming beeps
===================
The Mode Settings screen has independent settings for "Button Beep" and "Arming Beeps". Setting Button Beep to NO will remove the short 'clicking' sound produced when you push a button on the KK2 board. Setting Arming Beeps to NO will remove the loud beep produced during arming and disarming.

Observe:
- Do not disable the arming beeps if your KK2 board is covered by a canopy (or anything else) that blocks the view of the LED or LCD display.
- The start-up beep is not affected by these settings. It is there to test the buzzer.
- Alarms and other beeps are unaffected as well (e.g. short beeps while throttle is idle).


LCD contrast
============
The LCD contrast can be adjusted within a limited range. Go to the LCD Contrast screen and use the UP and DOWN buttons to adjust, then press the SAVE button to save your new setting and exit.

Observe:
- Pushing the BACK button will reload the last saved contrast setting.
- If you should end up with an unreadable screen, you can hold down button 1 while connecting your flight battery to reset the LCD contrast value.


Have fun! 
=========
Please read the information above carefully before using this firmware.
Remember to write down your settings if you want to keep them. They might get overwritten by flashing this firmware.
