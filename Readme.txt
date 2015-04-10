KK2.0 v1.6++ R4 firmware by RC911


Features (Revision 4)
=====================
This custom firmware is based on the original KK2.0 1V6 firmware by Rolf Bakke. It has the following features:
- This version is for standard receivers only. Minimum 4 PWM signals (aileron, elevator, throttle and rudder) are required for arming and flying.
- SL Stick Mixing mode with adjustable rate setting. This will give a soft transition from Self-level to ACRO mode based on aileron/elevator stick deflection. It will be displayed on the SAFE screen as "SL Mix" when active. Read the instructions below.
- ESC calibration is done without a transmitter and it is sufficient to hold down a single button. This will help users with slow binding receivers do ESC calibration in a simple and safe way. This feature is now a lot safer since ESC calibration must be enabled through the menu before it can be accessed. Read the instructions below to learn the new ESC calibration routine.
- Multiple user profiles selectable from the SAFE screen allow separate settings for aerobatics, aerial photo, battery types and more. Read the instructions below.
- Customizable AUX switch functions with support for 5 switch positions. Read the instructions below.
- Quick Tuning lets you edit several settings on an alternative "SAFE" screen. You can arm and test-fly your settings from the TUNING screen.
- Channel mapping with support for AUX2, AUX3 and AUX4 features. Read more about this feature below.
- Quiet ESCs while browsing the KK2 menu and editing settings. This feature can be switched on/off from the Mode Settings screen.
- Servo jitter has been reduced on M7 and M8 and motor layouts for Dualcopter and Tricopter were changed to take advantage of this.
- PWM output resolution has increased from 555 to 625 steps on M1 - M6 and from 555 to 2500 steps on M7 and M8. You may have to increase all Stick Scaling values by 10 - 15% because of this.
- Alarm (i.e. 'Lost Model Alarm') can be activated from the AUX switch. It will also sound after 20 seconds at zero throttle (i.e. after the Auto Disarm countdown).
- Support for gimbals with differential mixing (in addition to normal gimbals). Differential mixing code borrowed from Brontide's firmware.
- Flight timer (displayed on the SAFE screen) runs while armed and throttle is above idle.
- A setup menu is displayed after a factory reset and whenever user profile #1 is reset. This menu is also accessible from the KK2 main menu (select "Initial Setup").
- The 'Version Info' screen is accessible from the main menu and is not displayed during start-up.
- Button and arming beeps can be turned off individually.
- Adjustable LCD contrast.
- Battery voltage is logged and displayed on the SAFE screen.
- The KK2 LED will flash rapidly for a few seconds after arming if the Low Voltage Alarm value is set too low.
- Gyro limits have been expanded to let boards with slightly damaged gyros arm. Values borrowed from Steveis' firmware.

See the whatsnew.txt document to learn what has changed since the previous version.
See the tips.txt document for a few tips and tricks regarding setup, tuning and crash investigation. 


Initial setup
=============
A SETUP menu is displayed after a factory reset and whenever user profile #1 is reset. It is also accessible from the KK2 menu (select "Initial Setup"). This screen acts like a sub-menu where you can access the most basic settings like "Load Motor Layout", "ACC Calibration", "Receiver Test" and "Reverse Channels". Most of these menu items can only be accessed from user profile #1 though.


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


User profiles
=============
Four user profiles are available in this firmware version. This allows most settings to be adjusted for different flying styles, batteries, weather conditions and more.
User profiles are selected using the two middle buttons at the SAFE screen and there's an indicator for selected user profile in the upper right corner of the screen (P1 - P4). There's also a new menu item called "User Profile" where you can specify the default start-up profile, import data from a different user profile and reset the current user profile.

ATTENTION:
A user profile can be configured so that your model behaves very differently from the profile you normally use, so before take-off always make sure that you have the correct profile selected! Also remember that the default user profile is selected on every start-up!

Observe:
- The very first time you select a new user profile it will need a second or two to initialize, but after that it will change instantly.
- The "Factory Reset" menu item has been removed since the "Reset active profile" function on the User Profile screen now does the same thing for the active user profile.
- Resetting profile #1 will affect all user profiles since this one holds all important settings (i.e. Mixer values and LCD contrast).
- A few menu items can only be accessed from user profile #1. A "No access" message will be displayed if you do try.
- Importing data to profile #1 from other user profiles is not allowed. This profile can only be edited manually.
- The LED on the KK2 board will flash to indicate which profile is currently active while in the menu. It will flash twice for profile #2, three times for #3 and four times for #4.


AUX switch setup
================
From the AUX Switch Setup screen you can select which function (Acro, SL Mixing, Normal SL or Alarm) should be active depending on the AUX switch position. Select the item you want to modify and then press the CHANGE button to cycle through the available settings.
The selected flight mode and alarm state is displayed on the SAFE screen.

Observe:
- The current AUX switch position will be displayed as a black dot in the first column to help you assign the wanted function to the preferred switch position. The Receiver Test screen can also be used to observe the AUX switch position values.
- To access position #2 and #4 you will need to use mixing on your transmitter.
- The same function can be assigned to several positions of your AUX switch.
- A confirmation beep is produced by the buzzer every time you move the AUX switch to a new position (not while browsing the KK2 menus though).
- If you use a 4-channel receiver you can only use the function assigned to position 3 and this function will be active all the time.
- Selecting "Alarm" position will also activate SL Mix mode.


SL stick mixing
===============
The SL Stick Mixing mode can be activated from a switch assigned to the AUX input channel and the mixing rate is set from the Self-level Settings screen. The mixing rate parameter is still related to your SL P-gain setting so you should tune the SL P-gain first. A value of 5 corresponds to the LOW setting used in the old KK2.0 version, 10 corresponds to MEDIUM and 20 to HIGH, but you can even go as high as 50 if your SL P-gain is very high.

The Stick Scaling parameter called "SL Mixing" lets you adjust the stick input sensitivity for SL Mix mode relative to Acro or normal SL mode. If you feel that SL Mix mode is less responsive compared to Acro mode you can increase this value. To make SL Mix mode act more like normal SL mode you should lower this value. In any case you should adjust the stick scaling parameters to suit your flying style in Acro or Normal SL mode before adjusting the "SL Mixing" parameter. Leave it at 100% (default) if you only use SL Mix mode.

I use this mode all the time now and found that it is great for practicing aerobatics. If you get in trouble (e.g. lose orientation) you can just center the aileron/elevator stick and the model will level itself. Another advantage is that you don't have to ramp up your 'Stick Scaling' values or mess with PI limits for flying around (compared to the original Self-level mode).

BEWARE! If you center your aileron/elevator stick while your model is upside-down it will remain inverted until you add some more stick input. This is a "feature" of the original KK2 firmware and not something that I've implemented. 

Observe:
- A 3-way switch should be assigned to channel 5 (AUX) to select flight mode - Acro, SL Mixing or Normal SL. The selected flight mode will be displayed on the SAFE screen.
- You should tune your model as best as you can in both acro and normal SL mode before trying the SL Stick Mixing mode.
- Don't count on this mode saving your model if you perform acrobatic stunts and exceed the 440 degrees/second gyro limitation. It may actually make it worse! 
- If your model has built up any momentum, it will not stop moving immediately after centering the aileron/elevator stick! Take it slow if you're at beginner level.
- This mode will work best for transmitters configured to use mode 2 or 3 (i.e. with aileron and elevator on the same stick).
- Avoid using this mode if your model requires excessive stick trimming (e.g. when center of gravity is too far off). This will affect the SL mixing. In other words: You should only use this mode on a well-balanced model.


Lost model alarm
================
The Lost Model alarm can be triggered from a switch assigned to the AUX input channel, but only if you have activated the Alarm function on the AUX Switch Setup screen.

An alternative way to activate the Lost Model Alarm is to wait 20 seconds for the Auto Disarm feature (must be active) to disarm your KK2 board. The alarm will not sound if you disarm your KK2 manually and the alarm will stop when you arm your board again.

Observe:
- The alarm will still be trigged after 30 minutes counted from the last arm/disarm operation, just like in the original KK2.0 1V6 firmware.


Channel mapping
===============
You can use the Channel Mapping feature to access features normally controlled from AUX2, AUX3 or AUX4. Since you have only 5 real channels you only exchange your AUX channel (and all its features) for one of the virtual channels (AUX2, AUX3 or AUX4). Sacrificing the AUX features will only be a problem if you need to change flight mode while flying, but if you normally stay in one flight mode you can use the AUX Switch Setup screen to lock the controller in the desired mode. Remember that you can use one user profile for aerobatics and the next profile for SL mode so that you can quite easily switch flight modes from the SAFE screen. The Lost Model Alarm will still be activated if you let the Auto Disarm counter time out (keeping throttle at idle position for 20 seconds).

On the Channel Mapping screen the numbers in the second column represents the physical input pins on the KK2 board where 1 = Aileron, 2 = Elevator, 3 = Throttle, 4 = Rudder and 5 = AUX. To swap the Rudder and AUX inputs you would simply swap the numbers behind Rudder and Aux, but you may also think of this as setting the Rudder "function" to get its input from the AUX pin (5) and the AUX "function" to get its input from the Rudder pin (4). Remember to visit the Receiver Test screen to verify that all channels respond as expected to your stick input.

Observe:
- Mapping the AUX input to AUX2, AUX3 or AUX4 will print "No signal" on the Receiver Test screen for Aux. This is perfectly normal as the Aux "function" now has no valid input.
- You cannot map the same input channel to multiple functions. Duplicates are not allowed and will produce an error message if you attempt to exit without correcting mistakes.
- See the Tips.txt document for more examples and more ways to use the channel mapping feature. You can even fix a defective input pin...


Remote gimbal offset control
============================
One of the gimbal offsets (pitch or roll) can be controlled from your transmitter. A potentiometer is recommended, but you can also use a switch if you only want to change between a few fixed offset positions. This feature is based on Steveis' firmware, but I did some changes to make it utilize the full input control range.

Observe:
- Offsets cannot be adjusted while navigating the KK2 menus. This can only be done during flight and at the SAFE screen.
- To access this feature you will have to map the AUX input to either AUX2 (pitch) or AUX3 (roll) by using the Channel Mapping feature.


Other gimbal features
=====================
The gimbal Lock and Home features are controlled from a 3-way switch assigned to AUX4. Position #1 activates the Lock feature while position #3 activates the Home feature. Both features are inactive when the switch is in the middle position, making the gimbal operate normally. The second page on the Receiver Test screen can be used to find which feature is assigned to which switch position (Aux4).

When activated, the Lock feature will make the gimbal stop responding to self-level corrections, but gimbal offsets can still be adjusted remotely.

When the Home feature is activated the gimbal will go to a user-defined position and stay there until this feature is switched off again. It will not respond to self-level corrections nor remote offset adjustments in this mode. The Home Roll and Pitch positions are set from the second Gimbal Settings screen. Valid range is -1000 to 1000.

Observe:
- To access these features you will have to map the AUX input to AUX4 by using the Channel Mapping feature.


Quick tuning
============
Quick Tuning lets you edit several settings without having to return to the SAFE screen repeatedly as you can arm and test-fly your settings directly from the TUNING screen.

This is the recommended procedure for using the Quick Tuning feature:
1. Go to the 'Quick Tuning' screen and select the parameter that you want to tune by using the navigation (PREV/NEXT) buttons.
2. Edit the setting by pressing the CHANGE button, press UP/DOWN to modify and press DONE when finished editing.
3. Arm normally from the TUNING screen and fly/hover to test your setting.
4. Land and disarm when done testing.
5. Repeat from step #2 if required.

Observe:
- Holding down a navigation (PREV/NEXT) button will let you cycle through the available parameters.
- Status messages will be displayed when something is wrong (arming will be refused). The message will flash slowly.


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
Remember to write down your settings, for this firmware will erase them all!
