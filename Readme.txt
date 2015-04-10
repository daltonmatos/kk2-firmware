KK2.1++ All-in-One firmware by RC911


Features
========
This custom firmware is based on the original KK2.0 1V6 firmware by Rolf Bakke. It has the following features:
- Supports traditional receivers, CPPM (aka. PPM), Futaba S.Bus and Spektrum Satellite (DSM2) units.
- SL Stick Mixing mode with adjustable rate setting. This will give a soft transition from Self-level to ACRO mode based on aileron/elevator stick deflection. It will be displayed on the SAFE screen as "SL Mix" when active. Read the instructions below.
- ESC calibration is done without a transmitter and it is sufficient to hold down a single button. This will help users with slow binding receivers do ESC calibration in a simple and safe way. This feature is now a lot safer since ESC calibration must be enabled through the menu before it can be accessed. Read the instructions below to learn the new ESC calibration routine.
- Multiple user profiles. Read the instructions below.
- Customizable AUX switch functions with support for 5 switch positions. Read the instructions below.
- Remote tuning of PI gains, ACC trims and gimbal gains using channel 6 and 7. PS: This feature is available for CPPM, S.Bus and Satellite only.
- Quick Tuning feature lets you edit several settings on an alternative "SAFE" screen. You can arm and test-fly your settings from the TUNING screen. PS: This feature is available for traditional receivers only.
- Quiet ESCs while browsing the KK2 menu and editing settings. This feature can be switched on/off from the Mode Settings screen.
- Servo jitter has been reduced on M7 and M8 and motor layouts for Dualcopter and Tricopter were changed to take advantage of this.
- PWM output resolution has increased from 555 to 625 steps on M1 - M6 and from 555 to 2500 steps on M7 and M8. You may have to increase all Stick Scaling values by 10 - 15% because of this.
- Alarm (i.e. 'Lost Model Alarm') can be activated from the AUX switch. It will also sound after 20 seconds (i.e. after the Auto Disarm countdown).
- Remote gimbal offset control using channel 6 and 7. Based on Steveis' firmware, but with some of my own changes. PS: This feature is available for CPPM, S.Bus and Satellite only.
- Support for gimbals with differential mixing (in addition to normal gimbals). Differential mixing code borrowed from Brontide's firmware.
- The 'Version Info' screen is accessible from the main menu and is not displayed during start-up.
- Button and arming beeps can be turned off individually.
- Adjustable LCD contrast.
- Battery voltage is logged and displayed on the SAFE screen.
- Adjustable battery voltage offset with presets available for KK2.1 and KK2.1.5 (default). The voltage offset can be adjusted in 0.025V steps.
- The KK2 LED will flash rapidly for a few seconds after arming if the Low Voltage Alarm value is set too low.
- Adjustable sensor settings (i.e. LP filter, gyro rate and ACC range).
- The sensor reading and self levelling code was borrowed from Steveis' latest firmware. This includes his improved 8.32 maths library and self-adjusting magic number code. Thanks Steveis :)


Connections
===========
For traditional receivers you'll need to connect aileron, elevator, throttle, rudder and aux (optional) cables to the corresponding input connectors.
For CPPM (aka. PPM) you'll only use the aileron input connector.
For S.Bus you must use the elevator input connector. This requires a special inverter cable to be used.
For Satellite units you must use the throttle input connector. This requires a special converter cable to be used.

The correct RX mode must be selected to match your receiver's output mode. Select "Initial Setup" from the KK2 menu and then choose "Select RX Mode" from the SETUP screen to access this setting. A restart will be required after changing this setting.


Satellite binding
=================
Binding will be necessary if you see a "Sat protocol error" message on the 'SAFE' screen. Hold down button 2 and 3 on your KK2 board while connecting the flight battery. This should configure the Satellite unit to use the DSM2 protocol.


Initial setup
=============
A SETUP screen is displayed after a factory reset and whenever user profile #1 is reset. It is also accessible from the KK2 menu (select "Initial Setup"). This screen acts like a sub-menu where you can access the most basic settings like "Load Motor Layout", "ACC Calibration", "Trim Battery Voltage" and "Select RX Mode". Most of these menu items can only be accessed while user profile #1 is active.


ESC calibration routine (no transmitter required)
=================================================
This procedure is now a lot safer since ESC calibration no longer can be trigged by a damaged button. This is achieved by forcing you to temporarily activate the ESC calibration feature through the KK2 menu before using it. If any button is damaged you will not be able to navigate the KK2 menus without noticing it. The ESC calibration state is checked on every start-up and automatically disabled if it is found to be active.

Here is the improved ESC calibration procedure:
1. Power up your KK2 board normally. The ESC calibration feature is now disabled by default to prevent accidental activation.
2. From the KK2 menu, select the "ESC calibration" item to activate ESC calibration temporarily.
3. Disconnect the battery. This is actually required since there is no way to return from the previous screen.
4. Remove all propellers, but leave the motors connected so that you can hear the ESC confirmation beeps!
5. Disconnect servos if they cannot handle a sudden travel from endpoint to endpoint.
6. Hold down any button (i.e. a single button) while connecting the flight battery.
7. Keep holding the button down while waiting for the 'High throttle' level beep(s) and then release it to set the 'Low throttle' level.
8. Push button 1 (EXIT) after the final ESC confirmation beeps to return to the SAFE screen. The ESC calibration feature is now disabled again.

Observe:
- If you fail to trigger the ESC calibration you'll have to repeat the procedure from step #2 above to activate it again.
- Upper throttle level will be set to 2.0 ms and the lower throttle level to 1.02 ms, which are the exact same values used by the original KK2.0 1V6 firmware (Don't be fooled by the "Throttle pass-through" message).
- The 'Version Information' screen and its one second delay has been removed from the start-up sequence. This will make the ESC calibration routine safer because your ESCs will now see the 'full throttle' signal one second sooner (compared to the original KK2.0 1V6 firmware) and this reduces the risk for having motors going full throttle while doing the ESC calibration.


User Profiles
=============
Four user profiles are available in this firmware version. This allows different PI gain settings as well as other parameters to be adjusted for different flying styles, different batteries, different weather conditions and more.
User profiles are selected using the two middle buttons at the SAFE screen and there's an indicator for selected user profile in the upper right corner of the screen. There's also a new menu item called "User Profile" where you can specify the default start-up profile, import data from a different user profile and reset the current user profile.

Observe:
- The very first time you select a new user profile it will need a second or two to initialize, but after that it will change instantly.
- The "Factory Reset" menu item has been removed since the "Reset active profile" function on the User Profile screen now does the same thing for the active user profile.
- Resetting profile #1 will affect all user profiles since this one holds all important settings (i.e. Mixer values, RX mode, battery voltage offset and LCD contrast).
- A few menu items can only be accessed from user profile #1.
- Importing data to profile #1 from other user profiles is not allowed. This profile can only be edited manually.
- The LED on the KK2 board will flash to indicate which profile is currently active while in the menu. It will flash twice for profile #2, three times for #3 and four times for #4.


AUX Switch Setup
================
From the AUX Switch Setup screen you can select which function (Acro, SL Mixing, Normal SL or Alarm) should be active depending on the AUX switch position. Select the item you want to modify and then press the CHANGE button to cycle through the available settings.

Observe:
- The current AUX switch position will be displayed as a black dot in the first column to help you assign the wanted function to the preferred switch position. The Receiver Test screen can also be used to observe the AUX switch position values.
- To access position #2 and #4 you will need to use mixing on your transmitter.
- The same function can be assigned to several positions of your AUX switch.
- A confirmation beep is produced by the buzzer every time you move the AUX switch to a new position.
- If you use a 4-channel receiver you can only use the function assigned to position 1 and this function will be active all the time.


SL Stick Mixing
===============
The SL Stick Mixing mode can be activated from a switch assigned to the AUX input channel, but the mixing rate is now set from the Self-level Settings screen. The mixing rate parameter is still related to your SL P-gain setting so you should tune the SL P-gain first. A value of 5 corresponds to the LOW setting used in the previous version, 10 corresponds to MEDIUM and 20 to HIGH.

I use this mode all the time now and found that it is great for practicing aerobatics and if you get in trouble (e.g. lose orientation) you can just center the aileron/elevator stick and the model will level itself. Another advantage is that you don't have to ramp up your 'Stick Scaling' values for flying around (compared to the original Self-level mode in KK2.0 1V6).

The new Stick Scaling parameter called "SL Mixing" lets you adjust the stick input sensitivity for SL mixed mode relative to acro or normal SL. If you never use acro or normal SL mode you might as well leave this new setting at 100% and adjust the stick scaling values for roll and pitch instead, but if you do use the other modes then you should adjust the stick scaling parameters for roll and pitch to suit your flying style in those modes first.

Observe:
- A 3-way switch should be assigned to channel 5 (AUX) to select flight mode - Acro, SL Mixing or Normal SL. The selected flight mode will be displayed on the SAFE screen.
- You should tune your model as best as you can in both acro and normal SL mode before trying the SL Stick Mixing mode.
- Don't count on this mode saving your model if you perform acrobatic stunts and exceed the gyro limitation. It may actually make it worse! 
- If your model has built up any momentum, it will not stop moving immediately after centering the aileron/elevator stick! Take it slow if you're at beginner level.
- This mode will work best for transmitters configured to use mode 2 or 3 (i.e. with aileron and elevator on the same stick).
- Avoid using this mode if your model requires excessive stick trimming (e.g. when center of gravity is too far off). This will affect the SL mixing. In other words: You should only use this mode on a well-balanced model.


Lost Model Alarm
================
The Lost Model alarm can be triggered from a switch assigned to the AUX input channel, but only if you have activated the Alarm function on the AUX Switch Setup screen.

An alternative way to activate the Lost Model Alarm is to wait 20 seconds for the Auto Disarm feature (must be active) to disarm your KK2 board. The alarm will not sound if you disarm your KK2 manually and the alarm will stop when you arm your board again.

Observe:
- The alarm will still be triggered after 30 minutes counted from the last arm/disarm operation, just like in the original KK2.0 1V6 firmware.


Remote Gimbal Offset Control (for CPPM, S.Bus and Satellite)
============================================================
Gimbal offsets can be controlled from your transmitter on channel 6 (pitch) and 7 (roll). Potentiometers are recommended, but you can also use switches if you only want to change between a few fixed offset positions. This feature is based on Steveis' firmware, but I did some changes to make it utilize the full input control range.

Observe:
- Roll and pitch gains are set from the Gimbal Settings screen. Values in the range of 500 to 600 are common. A negative value will reverse the servo direction.
- Select gimbal mixing mode according to your gimbal type. 'Diff' is used for SSG (Super Simple Gimbal) and 'None' is for normal gimbal with one servo for roll and one for pitch.
- Offsets cannot be adjusted while navigating the KK2 menus. This can only be done during flight and at the SAFE screen.
- Most Mixer Editor values (e.g. Offset) for M6 and M7 have no effect on the gimbal, but output type and rate will.


Other gimbal features (for CPPM and S.Bus)
==========================================
The gimbal Lock and Home features are controlled from a 3-way switch assigned to channel 8. Position #1 activates the Lock feature while position #3 activates the Home feature. Both features are inactive when the switch is in the middle position, making the gimbal operate normally. The second page on the Receiver Test screen can be used to find which feature is assigned to which switch position (AUX 4).

When activated, the Lock feature will make the gimbal stop responding to self-level corrections, but gimbal offsets can still be adjusted remotely.

When the Home feature is activated the gimbal will go to a user-defined position and stay there until this feature is switched off again. It will not respond to self-level corrections or remote offset adjustments in this mode. Home roll and pitch positions are set from the Gimbal Settings screen. Valid range is -1000 to +1000.


Remote Tuning (for CPPM. S.Bus and Satellite)
=============================================
This feature allows you to adjust several parameters from your transmitter (even while flying). This requires potentiometers assigned to channel 6 and 7 on your transmitter. Use the Receiver Test (2nd) screen to make sure that the input range for Aux 2 and 3 goes from -100 to +100 with zero at center.
You can adjust PI gains for aileron, elevator and rudder using this feature. If aileron and elevator is linked (see the 'Mode Settings' screen) you will be able to adjust P and I gains for both axes simultaneously. You can also adjust self-level P gain, ACC trim values and roll and pitch gains for camera gimbal remotely.

This is the recommended procedure for aileron, elevator and rudder PI gain tuning:
1. Center your potentiometers (channel 6 and 7).
2. Go to the 'Remote Tuning' screen and select aileron, elevator or rudder tuning mode and a suitable input rate.
3. You can now try adjusting your potentiometers to learn which one is for P and which one is for I gain, but remember to center them before leaving. You will also see how much the gain values will change based on your input rate selection.
4. Return to the SAFE screen by pressing the BACK button twice. The status text will show the selected tuning mode.
5. Now you can fly in ACRO/MANUAL mode and adjust your potentiometers until you have found the best setting.
6. Land and go to 'Remote Tuning' screen again.
7. Press the SAVE button to save the tuned values and then center your potentiometers.
8. Repeat from step #4 (with a different input rate) if required.

This is the recommended procedure for SL P gain tuning:
1. Center your potentiometer on channel 6.
2. Go to the 'Remote Tuning' screen and select SL gain tuning mode and a suitable input rate.
3. You can now try adjusting your potentiometers to learn which one controls the P gain, but remember to center it before leaving. You will also see how much the gain value will change based on your input rate selection.
4. Return to the SAFE screen by pressing the BACK button twice. The status text will show the selected tuning mode.
5. Now you can fly in normal SL mode (using 'SL Stick Mixing' mode will have no effect) and adjust your potentiometer until you have found the best setting.
6. Land and go to 'Remote Tuning' screen again.
7. Press the SAVE button to save the tuned gain value and then center your potentiometer.
8. Repeat from step #4 (with a different input rate) if required.

This is the recommended procedure for ACC trim tuning:
1. Center your potentiometers (channel 6 and 7).
2. Go to the 'Remote Tuning' screen and select ACC trim tuning mode and a suitable input rate. TIP: Start with input rate set to HIGH.
3. You can now try adjusting your potentiometers to learn which one is for pitch (P) and which one is for roll (R) trim, but remember to center them before leaving. You will also see how much the gain values will change based on your input rate selection.
4. Return to the SAFE screen by pressing the BACK button twice. The status text will show the selected tuning mode.
5. Now you can fly in normal SL mode and adjust your potentiometers until drifting is reduced to a minimum.
6. Go to the 'Remote Tuning' screen again.
7. Press the SAVE button to save the tuned trim values and then center your potentiometers.
8. Repeat from step #4 (with a different input rate) if required.

This is the recommended procedure for gimbal gain tuning:
1. Connect your camera to an external screen so you can observe the image while tilting your copter.
2. Center your potentiometers (channel 6 and 7).
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
- ACC trim values must be tuned in NORMAL SL mode only. Using "SL Mix" mode will have no effect.
- The selected tuning mode will not be saved. Power cycling will make it return to normal mode.
- The chosen input/tuning rate will be remembered.


Button/Arming Beeps
===================
The Mode Settings screen now has independent settings for "Button Beep" and "Arming Beeps". Setting Button Beep to NO will remove the short 'clicking' sound produced when you push a button on the KK2 board. Setting Arming Beeps to NO will remove the loud beep produced during arming and disarming.

Observe:
- Do not disable the arming beeps if your KK2 board is covered by a canopy (or anything else) that blocks the view of the LED or LCD display.
- The start-up beep is not affected by these settings. It is there to test the buzzer.
- Alarms and other beeps are unaffected as well (e.g. short beeps while throttle is idle).


LCD Contrast
============
The LCD contrast can now be adjusted within a limited range. Go to the LCD Contrast screen and use the UP and DOWN buttons to adjust, then press the SAVE button to save your new setting and exit.

Observe:
- Pushing the BACK button will reload the last saved contrast setting.
- If you should end up with an unreadable screen, you can hold down button 1 while connecting your flight battery to reset the LCD contrast value.


Sensor settings
===============
The MPU6050 sensor has a few settings that can be changed to suit your flying style. The default settings are suitable for normal flying or slow loops/rolls and the bahavior is comparable to the KK2.0 board.
For extreme aerobatics you should increase the gyro rate to 2000 degrees/second and set the ACC range to 16g. This might have a slightly negative effect on self-level and the input control.
For slow AP flying you can lower the gyro rate to 250 degrees/second to get smoother input control and a better self-level effect.

The LP filter setting can be lowered to make the controller less sensitive to vibrations, but you should only adjust this setting if vibrations cannot be removed completely by balancing props and/or motors. You might have to adjust your PI gains after changing this filter setting.

Observe:
- Adjusting the ACC range will require a recalibration of the accelerometers. An error message will be displayed on the SAFE screen and arming is refused until ACC calibration is performed.
- You can save different sensor settings in each user profile so that you can have one user profile for AP, one for normal flying and one for extreme aerobatics.


Have fun! 
=========
Please read the information above carefully before using this firmware.
Remember to write down your settings, for this firmware will erase them all!