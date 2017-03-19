KK2.1++ All-in-One R8 firmware by RC911


Features (Revision 8)
=====================
This custom firmware is based on the original KK2.0 1V6 firmware by Rolf Bakke. It has the following additional features:
- Supports traditional receivers, CPPM (aka. PPM), Futaba S.Bus (normal and HS mode) and Spektrum Satellite (DSM2/DSMX) units.
- SL Mix flight mode with adjustable rate setting gives a soft transition from Self-level to Acro mode based on aileron/elevator stick input.
- ESC calibration is done without a transmitter and it is sufficient to hold down a single button. This will help users with slow binding receivers do ESC calibration in a simple and safe way. ESC calibration must be enabled through the menu before it can be accessed.
- Board orientation can be set to 0 (default), 90, 180 or 270 degrees. This setting is found on the 'Advanced' sub-menu. Some code was borrowed from Steveis.
- Supports boards with reversed button order.
- Multiple user profiles selectable from the SAFE screen allow separate settings for aerobatics, aerial photo, battery types and more.
- Customizable AUX switch functions with support for 5 switch positions. Available functions: Flight Mode, Lost Model Alarm, Motor Spin and Stick Scaling Offset.
- In S.Bus mode, a switch assigned to DG2 (aka. channel 18) can control the following functions: Motor Spin and Digital Output.
- The Motor Spin feature will keep motors spinning at zero throttle and prevent disarming in mid-air. Controlled from the AUX switch.
- TPA (Throttle PI Adjustment) with separate factors for P and I at 5 throttle levels.
- TSSA (Throttle Stick Scaling Adjustment) at 5 throttle levels. Can, for instance, be used to perform fast flips at zero throttle.
- Remote tuning of PI gains, ACC trim and gimbal gains using AUX2 and AUX3. PS: This feature is available for CPPM, S.Bus and Satellite only.
- Quick Tuning lets you edit several settings on an alternative "SAFE" screen. You can arm and test-fly your settings from the TUNING screen. PS: This feature is available for standard receivers only and it even supports remote tuning if you map the AUX channel to AUX2.
- Channel mapping configurable for 8 input channels (in all RX modes). This enables receivers with less than 8 channels to access AUX2, AUX3 and AUX4 features.
- Quiet ESCs while browsing the KK2 menu and editing settings.
- Servo jitter has been reduced on M7 and M8 and motor layouts for Dualcopter and Tricopter were modified to take advantage of this.
- Servo limits/endpoints can be set for M7 and M8.
- Servo refresh rate can be set to 50, 57, 67, 80, 100, 133 or 200Hz in LOW rate mode. HIGH rate is still 400Hz.
- Servo oscillations can be eliminated/reduced by using a new filter parameter named "Osc. Damping".
- PWM output resolution has increased from 555 to 625 steps on M1 - M6 and from 555 to 2500 steps on M7 and M8. You may have to increase all Stick Scaling values by 10 - 15% because of this.
- Motors and ESCs can be easily checked for correct wiring by using the 'Check Motor Outputs' feature.
- WS2812 RGB LED support with output on M6 or M7 for up to 25 RGB LEDs.
- Stand-alone (servo) gimbal controller mode.
- Remote gimbal offset control using AUX2 and AUX3. Based on Steveis' firmware, but with some changes of my own. PS: In standard RX mode you can map the AUX input to AUX2 or AUX3 to control a single gimbal axis.
- Support for gimbals with differential mixing. Differential mixing code was borrowed from Brontide's firmware.
- Adjustable stick 'dead zone' for the aileron, elevator and yaw input channels.
- Flight timer (displayed on the SAFE screen) runs while armed and throttle is above idle.
- An alternative home/SAFE screen with large font can be selected for better readability on small screens.
- A Version Info screen is accessible from the main menu and is not displayed during start-up. The selected RX mode is displayed here as well.
- Button and arming beeps can be turned off individually.
- Adjustable LCD contrast.
- Battery voltage is logged and displayed on the SAFE screen.
- Adjustable battery voltage offset with presets available for KK2.1 and KK2.1.5 (default). The voltage offset can be adjusted in 0.025V steps.
- The KK2 LED will flash rapidly for a few seconds after arming if the Low Voltage Alarm value is set too low.
- Serious errors, like RX signal problems, will be logged to EEPROM and displayed when disarmed or after a reboot.
- Adjustable sensor settings (i.e. LP filter, gyro rate and ACC range).
- Using Steveis' improved 8.32 maths library and self-adjusting "magic number" code. Thanks Steveis :)

See the whatsnew.txt document to learn what has changed since the previous version.
See the tips.txt document for a few tips and tricks regarding setup, tuning and crash investigation. 


Connections
===========
For standard receivers you'll need to connect aileron, elevator, throttle, rudder and aux (optional) cables to the corresponding input connectors.
For CPPM (aka. PPM) you'll only use the throttle input connector.
For S.Bus you must use the throttle input connector. This requires a special inverter cable to be used (HobbyKing PRODUCT ID: 297000004).
For Satellite units you must use the throttle input connector. This requires a special converter cable to be used (HobbyKing PRODUCT ID: 297000005).

An experimental 'Serial Link' mode is also available where the throttle pin is used for serial input and the aileron pin is used for serial output. An external KK2 controller, running my 'Port Expander' firmware, is required.

The correct RX mode must be selected to match your receiver's output mode. Select "Initial Setup" from the KK2 menu and then choose "Select RX Mode" from the SETUP screen to access this setting. A restart will be required after an RX mode change.


Satellite binding
=================
Binding (TX and Satellite unit linking) will be necessary if you see a "No satellite input" or "Sat protocol error" message on the 'SAFE' screen with your satellite unit connected. The following procedure should work for most Spektrum equipment, but you might want to check your TX/Sat manual as well:

1. Make sure your transmitter (TX) is powered OFF and that your Satellite unit is connected via a converter cable to the KK2 Throttle input pin.
2. Hold down button 2 and 3 on your KK2 board while connecting the flight battery.
3. The Satellite LED will blink rapidly to indicate that it is in bind mode so you should release the KK2 buttons now.
4. Power ON your TX in binding mode (as described in your TX manual). You may need to engage a Bind switch/button on your TX for several seconds.
5. Binding is done when the Satellite LED stops flashing.

This should bind/link the satellite unit to your transmitter and configure it to output the correct serial data format for the selected RX mode (i.e. 10 bit DSM2 or 11 bit DSMX).


Initial setup
=============
A SETUP menu is displayed after a factory reset and whenever user profile #1 is reset. It is also accessible from the KK2 menu (select "Initial Setup"). This screen acts like a sub-menu where you can access the most basic settings like "Load Motor Layout", "ACC Calibration", "Trim Battery Voltage" and "Select RX Mode". Some of these menu items can only be accessed from user profile #1 though.


Battery voltage offset
======================
Because of hardware changes between the KK2.1 and KK2.1.5 boards I had to make the battery voltage offset adjustable. Measuring the battery voltage with a voltmeter is recommended for calibration, but if you don't have one you can pick the default offset value by selecting "Use KK2.1 Offset" or "Use KK2.1.5 Offset". No other steps need to be taken, but please observe that the battery voltage sensed by your KK2 board may be a bit off and will then affect the Low Voltage Alarm so that it is trigged sooner or later relative to your alarm setting.

If you have a voltmeter you can input the voltage directly with 1/10V accuracy. No need to select one of the default offsets first. For maximum accuracy you can correct the offset in 0.025V steps afterwards.
If, for example, your KK2 board shows 12.3V while your voltmeter reads 12.55V you should select "Modify Voltage (1/10)" and input 125 as the value (for 12.5V), then select "Adjust Offset Value" and increase this value by 2 (every increment adds 0.025V). This will trim the battery voltage offset with maximum accuracy and the monitored battery voltage is then read as 12.55V although it will be displayed as 12.5V.

Some KK2 boards may have an unlinear ADC input circuit and this can make it impossible to get an accurate voltage reading for both 11.1V (3S) and 14.8V (4S) batteries. This problem can quite easily be solved by using one user profile for 3S batteries and another user profile for 4S batteries. You will then have to calibrate the battery voltage offset for each user profile.


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


Board orientation:
==================
If necessary, the controller board can be mounted at 90, 180 or 270 degrees offset. This setting is found on the Advanced sub-menu and has a dedicated screen where the on-screen arrow points to the front of the copter. For the KK2.1 HC board you must first align the top of your display unit to the arrow imprinted on the main unit.

ATTENTION:
Your copter will flip instantly on take-off and may get damaged (it can even cause damage to people/objects nearby) if your board is mounted incorrectly! To prevent this from happening you should use the Sensor Test screen to verify that the board is mounted correctly. Tilting your copter forward should display the text "Forward" next to the ACC values and banking your copter left should display "Left".
It is also important that motors and ESCs remain connected according to the selected motor layout. On the "Show Motor Layout" screen the image doesn't reflect the board rotation in any way, so "Front" of the displayed layout is still at the top of the LCD screen.


Checking motor outputs
======================
Motors and ESCs connected to M1 - M8 can be checked for correct wiring. If your model flips immediately on take-off you can use this feature to check if the problem is caused by incorrect wiring, or better yet, run this featur BEFORE the very first take-off and also after rewiring your ESCs and motors.
Each motor will spin at relatively low speed (configurable, 0 to 20%) for one second in sequence M1 - M8. If your motors don't spin up in the correct order (see the Show Motor Layout screen) then you must swap two or more ESC connections on M1 - M8.

ATTENTION:
Motors will start spinning when the 5 second countdown is over so immediately take a few steps back and wait until the sequence is complete (i.e. all motors have stopped spinning)! For an Octocopter the full procedure will take 17 seconds (5 sec countdown + 8 sec run time + 4 sec pause). A quad will need 11 seconds. When finished, you're automatically sent back to the Extra Features menu.

Observe:
- ESC calibration should be done before using this feature.
- The motor speed is set from the Minimum Throttle parameter on the 'Misc. Settings' screen. Its value range is 0 - 20% so make sure it is set at a level where all motors will spin.
- Servos are not affected by this feature.
- For the "V-Tail Hunter" motor layout the motors should spin up in a "Z" pattern.


User profiles
=============
Four user profiles are available in this firmware version. This allows most settings (including MPU6050 sensor settings) to be adjusted for different flying styles, batteries, weather conditions and more.
User profiles are selected using the two middle buttons at the SAFE screen and there's an indicator for selected user profile in the upper right corner of the screen (P1 - P4). There's also a menu item called "User Profile" where you can specify the default start-up profile, import data from a different user profile and reset the current user profile.

ATTENTION:
A user profile can be configured so that your model behaves very differently from the profile you normally use, so before take-off always make sure that you have the correct profile selected! Also remember that the default user profile is selected on every start-up!

Observe:
- The very first time you select a new user profile it will need a second or two to initialize, but after that it will change instantly.
- The "Factory Reset" menu item has been removed since the "Reset active profile" function on the User Profile screen now does the same thing for the active user profile.
- Resetting profile #1 will affect all user profiles since this one holds a few important settings (i.e. Mixer values, RX mode and LCD contrast).
- A few menu items can only be accessed from user profile #1. A "No access" message will be displayed if you do try.
- Importing data to profile #1 from other user profiles is not allowed. This profile can only be edited manually.
- The LED on the KK2 board will flash to indicate which profile is currently active while in the menu. It will flash twice for profile #2, three times for #3 and four times for #4. For profile #1 the LED will remain off.


AUX switch setup
================
From the AUX Switch Setup screen you can select which flight mode (Acro, SL Mixing, Normal SL, Alarm, Acro!, SL Mix! or Normal SL!) should be active depending on the AUX switch position. You can also activate Motor Spin (indicated by a special exclamation mark behind the flight mode) and assign a stick scaling offset (aileron, elevator and rudder +0, +20, +30 or +50) for each position. Select the item you want to modify and then press the CHANGE button to cycle through the available settings.
The selected flight mode and stick scaling offset is displayed on the SAFE screen.

Observe:
- The current AUX switch position will be displayed as a black dot in the first column to help you assign the wanted function to the preferred switch position. The Receiver Test screen can also be used to observe the AUX switch position values.
- To access position #2 and #4 you might need to use mixing on your transmitter.
- The same function can be assigned to several positions of your AUX switch.
- A confirmation beep is produced by the buzzer when the flight mode or stick scaling offset is changed using the AUX switch (not while browsing the KK2 menus though).
- If you use a 4-channel receiver you can only use the function assigned to position 3 and this function will be active all the time.
- Selecting "Alarm" will also activate SL Mix mode. In S.Bus mode the flight mode change can be avoided by using the switch assigned to DG1 (channel 17) to activate the Lost Model Alarm.
- The selected stick scaling offset is not displayed on the SAFE screen when set to zero (default).


Motor Spin
==========
This feature will keep motors spinning at zero throttle input and also prevent accidental disarming in mid-air. It is controlled from the AUX switch (or the DG2 switch in S.Bus mode). On the AUX Switch Setup screen you specify which switch position(s) should activate the Motor Spin feature. This will be indicated by a special excamation mark behind the selected flight mode. The following flight modes will activate the Motor Spin feature: Acro!, SL Mix! and Normal SL!
See the 'AUX switch setup' section above for more information.

When the Motor Spin feature is used in conjunction with aggressive TSSA settings it is possible to perform fast flips at low (or zero) throttle, but for this to work best the Motor Spin Level parameter (see 'Misc. Settings') must be set so that your motors spin relatively fast at zero throttle. It is best to keep Motor Spin Level below the hover point though, as it otherwise can cause a fly-away situation if radio communication is lost! Also remember to increase your gyro rate and ACC range before doing extreme aerobatics.

ATTENTION:
Although the Motor Spin Level parameter can be used to make your copter descend slowly in a fail-safe situation, this is not something I'd recommend doing. Finding a good "descend" value for Motor Spin Level parameter will be difficult as it depends on battery voltage and other factors like weight and wind. You also risk making your copter fly away instead of descending!

Observe:
- The Motor Spin feature will prevent arming and disarming. This requires at least one position on your AUX switch where Motor Spin is disabled and this position must be selected to arm/disarm.
- A status message will be displayed on the home/SAFE screen when the Motor Spin feature is active.
- The lowest motor speed is set from the Minimum Throttle parameter on the 'Misc. Settings' screen. Its value range is 0 - 20% so make sure it is set at a level where all motors will spin.
- S.Bus users can choose to activate the Motor Spin feature from the DG2 switch as before and doing so will override any Motor Spin setting on the AUX Switch Setup screen.


SL Mix
======
The SL Mix flight mode can be activated from a switch assigned to the AUX input channel and the mixing rate is set from the Self-level Settings screen. The mixing rate parameter is linked to your SL P-gain setting so you should tune the SL P-gain first. A value of 5 corresponds to the LOW setting used in the old KK2.0 version, 10 corresponds to MEDIUM and 20 to HIGH, but you can even go as high as 50 if your SL P-gain is very high.

SL Mix mode is great for practicing aerobatics. If you get in trouble (e.g. lose orientation) you can just center the aileron/elevator stick and the model will level itself. Another advantage is that you don't have to ramp up your 'Stick Scaling' values or mess with PI limits for flying around (compared to Normal Self-level mode).

Observe:
- A 3-way switch should be assigned to the AUX channel to select flight mode - Acro, SL Mix or Normal SL. The selected flight mode will be displayed on the SAFE screen.
- You should tune your model as best as you can in both acro and normal SL mode before trying the SL Stick Mixing mode.
- Don't count on this mode saving your model if you perform extreme aerobatics and exceed the gyro limitation. It may actually make it worse! 
- If your model has built up any momentum, it will not stop moving immediately after centering the aileron/elevator stick! Take it slow if you're at beginner level.
- This mode will work best for transmitters configured to use mode 2 or 3 (i.e. with aileron and elevator on the same stick).
- Avoid using this mode if your model requires excessive stick trimming (e.g. when center of gravity is too far off). This will affect the SL mixing. In other words: You should only use this mode on a well-balanced model.


TPA (Throttle PI Adjustment)
============================
TPA can be used to remove oscillations or wobbles at certain throttle stick positions.
The TPA settings are accessed from the Expert Settings sub-menu and has one factor for P-gain and one factor for I-gain for each of the five throttle stick positions: Minimum (0-20%), Low (20-40%), Medium (40-60%), High (60-80%) and Maximum (80-100%). Factors can be set from 0.1 to 1.5 in steps of 0.1. The default setting is 1.0 for all TPA factors.

ATTENTION:
Do normal PI tuning (with all TPA factors set to 1.0) first! Only if normal PI tuning fails to remove oscillations or wobbles at certain throttle stick levels should you try editing the TPA factors. You should always be careful when modifying the TPA factors as very low or high P-gains can make your model difficult to control!

Observe:
- The current throttle stick position is indicated by a black dot in the leftmost column on the settings screen and will help you determine which setting to modify.
- The TPA factors will only affect aileron, elevator and rudder PI gains. SL P-gain is not affected.
- Remote Tuning and Quick Tuning will be affected by TPA, so beware of this when using those features to tune your model.


TSSA (Throttle Stick Scaling Adjustment)
========================================
TSSA can be used to increase or lower stick sensitivity (i.e. stick scaling) at certain throttle stick positions. To perform fast flips at low (or zero) throttle you should also set the Motor Spin Level parameter to a suitable value (see the Motor Spin section above for more information).

The TSSA settings are accessed from the Expert Settings sub-menu and has one stick scaling factor for each of the five throttle stick positions. Factors can be set from 0.1 to 1.5 in steps of 0.1. The default setting is 1.0 for all TSSA factors.
TSSA and TPA share the same throttle position ladder and have a similar user interface, so read the TPA section above for more information regarding this.

Formula: Total stick scaling = (Original stick scaling + Aux stick scaling offset) * TSSA factor

ATTENTION:
For safety reasons, TSSA is linked to the Motor Spin feature. This means that TSSA will be disabled when Motor Spin is off so that arming can be done safely even when using a high TSSA factor at minimum throttle position. When using the TSSA feature it is recommended to wait until your model is hovering at a safe distance and height before switching Motor Spin (and TSSA) on and off. 

Observe:
- The current throttle stick position is indicated by a black dot in the leftmost column on the settings screen and will help you determine which setting to modify.
- You may have to increase the MPU sensor settings (gyro and ACC range) when using TSSA factors above 1.0.
- Avoid doing extreme aerobatics in SL-Mix mode!


Lost model alarm
================
The Lost Model alarm can be trigged from a switch assigned to the AUX input channel, but only if you have assigned the Alarm function to an available slot on the AUX Switch Setup screen. You should test the alarm at the SAFE screen to verify that it is working.

An alternative way to activate the Lost Model Alarm is to wait 20 seconds for the Auto Disarm feature (must be active) to disarm your KK2 board. The alarm will not sound if you disarm your KK2 manually and the alarm will stop when you arm your board again.

Observe:
- The alarm will still be trigged after 30 minutes counted from the last arm/disarm operation, just like in the original KK2.0 1V6 firmware.
- In S.Bus mode the alarm can be activated by using a switch assigned to DG1 (channel 17).


Channel mapping
===============
A few CPPM, S.Bus and Satellite receivers/units don't follow the standard channel order so to fix this the Channel Mapping feature will let you rearrange all 8 input channels. If your S.Bus receiver outputs Throttle, Aileron, Elevator, Rudder, Aux and Aux2 instead of Aileron, Elevator, Throttle, Rudder, Aux and Aux2 you should change the mapping for Aileron from 1 to 2, Elevator from 2 to 3 and Throttle from 3 to 1.

If your receiver outputs less than 8 channels you can even use the Channel Mapping feature to access features normally controlled from AUX2, AUX3 or AUX4. If you have only 5 real channels (as you usually do in Standard RX mode) you can exchange your AUX channel (and all its features) for one of the virtual channels (AUX2, AUX3 or AUX4). Sacrificing the AUX features will only be a problem if you need to change flight mode while flying, but if you normally stay in one flight mode you can use the AUX Switch Setup screen to lock the controller in the desired mode. Remember that you can use one user profile for aerobatics and the next profile for SL mode so that you can quite easily switch flight modes from the SAFE screen. The Lost Model Alarm will still be activated if you let the Auto Disarm counter time out (keeping throttle at idle position for 20 seconds).

To better understand how the channel mapping works it might help to look at the items in the first column (i.e. Aileron, Elevator, Throttle...) as "functions" and the values in the second column as channel numbers going from 1 through 8 in the order your receiver is outputting them. If the throttle channel is output first (i.e. channel 1) then the Throttle "function" value should be set to 1. If throttle is output third then you should set the value to 3.
In standard RX mode this is a bit different as the numbers in the second column now represents the physical input pins on the KK2 board where 1 = Aileron, 2 = Elevator, 3 = Throttle, 4 = Rudder and 5 = AUX. To swap the Rudder and AUX inputs you would simply swap the numbers behind Rudder and Aux, but you may also think of this as setting the Rudder "function" to get its input from the AUX pin (5) and the AUX "function" to get its input from the Rudder pin (4). Oh, and don't forget: With a standard RX you would also need to swap the signal cables physically.

ATTENTION:
After modifying the channel mapping, go to the Receiver Test screen and verify that aileron, elevator, throttle and rudder respond correctly to your stick input!

Observe:
- The 'Channel Mapping' menu item is located on the 'Advanced Settings' sub-menu.
- Mapping the AUX input (standard RX only) to AUX2, AUX3 or AUX4 will print "No signal" on the Receiver Test screen for Aux. This is perfectly normal as the Aux "function" now has no valid input.
- Changing RX mode won't reset the channel mapping so keep this in mind and check the Channel Mapping screen if your channels are "messed up" on the Receiver Test screen.
- You cannot map the same input channel to multiple functions. Duplicates are not allowed and will produce an error message if you attempt to exit without correcting mistakes.
- See the Tips.txt document for more examples and more ways to use the channel mapping feature. You can even fix a defective input pin...


Servo settings
==============
The 'Servo Filter' setting will reduce fast oscillations/jitter on all servo outputs, but you may have to set this value quite high for it to have any effect. Avoid setting the Servo Filter value to 100 as this will stop all servo motion.

The 'Osc. Damping' parameter works in conjunction with the Servo Filter value to eliminate/reduce servo oscillations. Try increasing the Osc. Damping value step by step until the oscillations disappear. Increasing the Servo Filter value will also have a positive effect.

Endpoints can be set for servos on M7 and M8 to avoid hitting mechanical obstructions. The default setting (-100, 100) will allow full servo travel in both directions. Finding the endpoints is quite easy if you assign potentiometers on your transmitter to Aux2 and Aux3. See the Tips.txt document for further instructions.

The 'Low PWM Rate' parameter allows you to select a refresh rate (50, 57, 67, 80, 100, 133 or 200Hz) for servo outputs that are set to LOW rate in Mixer Editor. All outputs that are set to HIGH rate will run at 400Hz as usual. 400Hz is recommended for digital servos.


Remote gimbal offset control
============================
Gimbal offsets can be controlled from your transmitter channels assigned to AUX2 (pitch) and AUX3 (roll). Potentiometers are recommended, but you can also use switches if you only want to change between a few fixed offset positions. This feature is based on Steveis' firmware, but I did some changes to make it utilize the full input control range.

Observe:
- Roll and pitch gains are set from the Gimbal Settings screen. Values in the range of 500 to 600 are common. A negative value will reverse the servo direction.
- Select gimbal mixing mode according to your gimbal type. 'Diff' is used for SSG (Super Simple Gimbal) and 'None' is for normal gimbal with one servo for roll and one for pitch.
- Offsets cannot be adjusted while navigating the KK2 menus. This can only be done during flight and at the SAFE screen.
- Most Mixer Editor values (e.g. Offset) for M7 and M8 have no effect on the gimbal, but the Type and Rate parameters will.
- To access this feature using a standard RX you will have to map the AUX input to either AUX2 (pitch) or AUX3 (roll).


Other gimbal features
=====================
The gimbal Lock and Home features are controlled from a 3-way switch assigned to AUX4. Position #1 activates the Lock feature while position #3 activates the Home feature. Both features are inactive when the switch is in the middle position, making the gimbal operate normally. The second page on the Receiver Test screen can be used to find which feature is assigned to which switch position (AUX4).

When activated, the Lock feature will make the gimbal stop responding to self-level corrections, but gimbal offsets can still be adjusted remotely.

When the Home feature is activated the gimbal will go to a user-defined position and stay there until this feature is switched off again. In this mode it will not respond to self-level corrections nor remote offset adjustments. The Home Roll and Pitch positions are set from the second Gimbal Settings screen. Valid range is -1000 to 1000.

Observe:
- To access these features using a standard RX or Satellite unit you will have to map an existing channel (e.g. AUX) to AUX4.


Stand-alone gimbal controller mode
==================================
The KK2.1 boards can also be used as a stand-alone (servo) gimbal controller. When this feature is active the board will boot into Gimbal Controller mode directly and servos will run without arming the KK2 controller.

This feature is enabled by selecting 'Gimbal Controller' from the Extra Features sub-menu and then pushing the YES button. To exit this feature and return to normal flight controller mode, select "Exit Gimbal Mode" from the KK2 main menu. The KK2 controller must be restarted after the Gimbal Controller mode has been changed.

Observe:
- Servos must be connected to M7 (roll) and M8 (pitch).
- A motor layout must be selected. Selecting the QuadroCopter X layout is recommended.
- ACC calibration should be performed on all user profiles that you will be using.
- Gimbal offset can be controlled from the transmitter in this mode also. If necessary, use the Channel Mapping feature to assign input channels/pins to the AUX2, AUX3 and AUX4 functions.
- The Low Voltage Alarm feature can be used in this mode also (as long as a buzzer is attached and the battery is connected to the battery sense/monitor connector).
- ESC outputs will not be disabled, but instead a minimum PWM signal (1.0 ms) will be output.
- Arming is disabled, the SAFE screen will be static (with less information) and quite a few menu items/settings are hidden when this mode is active.


Remote tuning (for CPPM. S.Bus and Satellite)
=============================================
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


Quick tuning (for standard RX)
==============================
Quick Tuning lets you edit several settings without having to return to the SAFE screen repeatedly as you can arm and test-fly your settings directly from the TUNING screen. Remote tuning is also supported, but this requires the AUX channel to be mapped to AUX2.

On the TUNING screen you'll find two numbers where the first one is the current value of the selected parameter and the second value (labeled "Remote Input") shows the scaled input from the Aux2 channel. The sum of these two values will be calculated and fed to the "Edit" box when you press the CHANGE button. Even when using remote tuning you can edit this value manually before saving.

This is the recommended procedure for using remote tuning with the Quick Tuning feature:
1. Go to the 'Quick Tuning' screen and select the parameter that needs tuning by pressing the NEXT button.
2. Select a suitable input rate (if necessary) by pressing the RATE button. The selected input rate is displayed on the TUNING screen.
3. You can now try adjusting your potentiometer to see how much the parameter value will change based on your input rate selection, but remember to center it before continuing.
4. Arm normally from the TUNING screen and fly/hover while adjusting the potentiometer to find the best setting.
5. Land, disarm and press the CHANGE button to save this value.
6. Center your potentiometer and verify that the Remote Input value actually is zero.
7. Repeat from step #4 (with a different input rate) if required.

ATTENTION:
Flight mode is changed automatically according to the selected tuning parameter so pay attention to its state and don't attempt to do aerobatics while tuning (unless you know what you're doing)!

Observe:
- There's no way to select the previous tuning parameter. You'll actually have to browse through all available parameters (9 or 11) to get there.
- Holding down the NEXT button will let you cycle quickly through the available parameters.
- Status messages will be displayed only when something is wrong. The message will flash slowly.
- Gimbal servo offsets are centered while tuning.
- The chosen input/tuning rate will be saved.


Button/Arming beeps
===================
The Mode Settings screen has independent settings for "Button Beep" and "Arming Beeps". Setting Button Beep to NO will remove the short 'clicking' sound produced when you push a button on the KK2 board. Setting Arming Beeps to NO will remove the loud beep produced during arming and disarming.

Observe:
- Do not disable the arming beeps if your KK2 board is covered by a canopy (or anything else) that blocks the view of the LED or LCD display.
- The start-up beep is not affected by these settings. It is there to test the buzzer.
- Alarms and other beeps are unaffected as well (e.g. short beeps while throttle is idle).


Stick dead zone
===============
To counteract RX signal instability/drift you can add a 'dead zone' to the aileron, elevator and rudder input channels. The 'Stick Dead Zone' parameter value range is 0 - 100 where 100 corresponds to 10% (approx.) on the Receiver Test screen.

Observe:
- The 'Stick Dead Zone' parameter is found on the 'Misc. Settings' screen.
- Throttle stick input is not affected by this parameter.
- Set this parameter value to zero (default) before adjusting sub-trims on your transmitter.
- Endpoints should be adjusted on your transmitter after changing this parameter value.


RGB LED (WS2812)
================
A WS2812 RGB LED strip with up to 25 LEDs can be connected to M6 or M7 on your KK2 controller. The red, green and blue components of each LED can be set to any level between 0 and 255 in the editor, giving a total of 16777216 combinations per LED. The RGB LED strip will not be animated nor updated during flight, but you can define up to 4 different light patterns and assign one of them to each user profile.

A common brightness value can be used to adjust the brightness level of all active LEDs. This makes it possible to re-use the same pattern, but with different brightness levels in multiple user profiles. The brightness value range is -100 to 100 where a positive value will increase all non-zero RGB values and a negative value will reduce the all non-zero RGB values. The WS2812 RGB LED strip will be updated as you adjust the brightness parameter.

This is the recommended procedure for RGB LED setup:
1. First select Output Pin (M6 or M7). This setting is common for all user profiles.
2. Select an LED pattern (1 - 4) to be used for the active user profile. The same pattern can be used in multiple user profiles.
3. If you want to edit the selected LED pattern, open the editor by selecting "Edit RGB LED Data". Observe: This will affect all user profiles using this LED pattern.
4. Adjusting the Brightness value is optional, but is a lot faster than editing all RGB values manually. This parameter is linked to the active user profile.

ATTENTION:
Only 5V WS2812(b) LED strips should be used. DO NOT connect other types of LED strips to your KK2 board as this will most likely destroy/damage your controller and other components connected to the M2-M8 ports!
The WS2812 LED strip can be cut into smaller sections and extended with wires, but pay close attention to the markings on the LED strip and avoid crossing the +5V and GND connections. Serial data must be linked from output (DO) to input (DIN).

Observe:
- The WS2812 RGB LED settings can be found on the 'Extra Features' sub-menu.
- The RGB LED editor cannot be accessed until an output pin has been selected.
- The set brightness value (if any) will be ignored while editing the LED pattern.
- Setting the Output Pin parameter to "None" will disable the RGB LED feature, but the LED strip may stay lit until it is disconnected or the power is switched off.
- The RGB LED data will not be affected by a user profile reset, but resetting user profile #1 will set the WS2812 'Output Pin' parameter to "None" (Disabled).
- The RGB LED feature will automatically be disabled if the chosen pin is configured for ESC or Servo usage at a later point.


LCD contrast
============
The LCD contrast can be adjusted within a limited range. Go to the LCD Contrast screen and use the UP and DOWN buttons to adjust, then press the SAVE button to save your new setting and exit.

Observe:
- Pushing the BACK button will reload the last saved contrast setting.
- If you should end up with an unreadable screen, you can hold down button #1 while connecting your flight battery to reset the LCD contrast value.


Sensor settings
===============
The MPU6050 sensor has a few settings that can be changed to suit your flying style. The default settings are suitable for normal flying or slow loops/rolls and the behavior is comparable to the KK2.0 board.
For extreme aerobatics you should increase the gyro rate to 2000 degrees/second and set the ACC range to 16g. This might have a slightly negative effect on self-level and the input control.
For slow AP flying you can lower the gyro rate to 250 degrees/second to get smoother input control and a better self-level effect.

The LP filter setting can be lowered to make the controller less sensitive to vibrations, but you should only adjust this setting if vibrations cannot be removed completely by balancing props and/or motors. You might have to adjust your PI gains after changing this filter setting.

Observe:
- The 'Sensor Settings' menu item is located on the 'Advanced Settings' sub-menu.
- Adjusting the ACC range will require a recalibration of the accelerometers. An error message will be displayed on the SAFE screen and arming is refused until ACC calibration is performed.
- You can save different sensor settings in each user profile so that you can have one user profile for AP, one for normal flying and one for extreme aerobatics.


Error logging
=============
Serious RX signal problems will be logged to EEPROM and displayed when disarmed or after a reboot. Saving to EEPROM will preserve the error code in case the KK2 controller is reset from a crash landing. The flight timer value will also be logged to help identify the first occurrence. All subsequent errors will be ignored.

This feature can be disabled (or enabled) by holding down button #4 while powering up your KK2 controller. From the Error Log screen that then appears you can choose to toggle this setting or abort the operation (if you just wanted to check the current setting). Disabling this feature is not recommended unless you keep getting errors very often or you just want to ignore them.

The following errors are logged:
1. "RX signal was lost!" (for all receiver modes).
2. "FAILSAFE!" (for S.Bus only).
3. "Sat protocol error!" (for DSM2/DSMX only).
4. "CPPM sync was lost!" (for CPPM only).
5. "Loop time error!" (for all receiver modes).
6. "Unknown error!" (for all receiver modes, but you will most likely never see this error message).

Observe:
- This feature is enabled by default.
- Resetting user profile #1 won't affect this setting.
- The error code will be cleared (and the Error Log window closed) when you push the CLEAR button so you might want to take a picture or write down the information shown on this screen first.


Default settings
================
These are the default parameter values that will be set initially and during a user profile reset:

PI gains/limits:    50, 100, 25, 20 (for aileron and elevator) and 50, 20, 50, 10 (for rudder)
Self-level:         60, 20, 0, 0, 10
Stick scaling:      30, 30, 50, 90
Mode settings:      Yes, Yes, Yes, Yes, No
Misc. settings:     10, 0, 0, 0
Channel mapping:    1, 2, 3, 4, 5, 6, 7, 8 (for std. RX, CPPM and S.Bus) and 2, 3, 1, 4, 5, 6, 7, 8 (for DSM2 and DSMX)
MPU settings:       256 Hz, 500 deg/s, 4 g
TPA settings:       P=1.0 and I=1.0 for all 5 throttle positions
TSSA settings:      SS=1.0 for all 5 throttle positions.
Servo settings:     50, 0, -100, 100, -100, 100, 80Hz
Gimbal settings:    0, 0, 0, 0, None, 0, 0
AUX switch setup:   Acro SS +0, Alarm SS +0, SL Mix SS +0, Alarm SS +0, Normal SL SS +0
DG2 switch setup:   No, No (for S.Bus only)
Battery offset:     2 (default value for KK2.1.5, HC and Mini)
Tuning rate:        Medium
WS2812 LED Pattern: 1
WS2812 Brightness:  0

For user profile #1 a few other settings are reset as well:

LCD contrast:       36
RX mode:            Standard RX
Controller mode:    Normal (Stand-alone gimbal mode is disabled)
Board offset:       0 degrees
WS2812 output pin:  None (feature disabled)

Observe:
- RGB LED data will not be cleared.


Have fun! 
=========
Please read the information above carefully before using this firmware.
Upgrading from revision 7 (R7) won't erase your settings, but I still recommend writing them down first. Data from older versions will be lost!
