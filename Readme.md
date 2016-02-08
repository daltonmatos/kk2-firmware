# KK2.1.x firmware, based on RC911 code

This is a copy of the code originally written by RC911 for the KK2 flight controller board. In this project you will find one branch for each version of his firmware (All-in-one for KK2.1.x) and each receiver type (for the KK2).

I published a series of blog posts as a proof of concept that's possible to mix an AVR Studio 4 Assembly project with an avr-gcc C project. Since the original firmware is almost 13K LOC it is unthinkable to rewrite all code in one pass. That's why the plan is to mix the original code with newer C code and migrate the implementation to C in parts.

The idea behind this migration is that I think having the code written in C will lower the barrier to new contributors for the project.

The research can be found here: http://daltonmatos.com/pages/avrgcc-avrasm2-en.html 

# Building the project

There is a Makefile that builds all necessary parts of the project. Things you need to know brefore running make:

 * You will need to have a working copy of ``avrasm2.exe``. It will run just fine with wine. Remember to edit Makefile and change the line ``AVRASM2 = wine ~/bin/AvrAssembler2/avrasm2.exe`` to point to your copy of ``avrasm2.exe``

To build the project:
 * Clone the project
 * ``cd`` into the cloned project
 * run ``make``

A new binary will be available at ``bin/kk2++.elf`` (if you need to disassembly) and a ``bin/kk2++.hex`` file will be ready to be flashed into the micro-controller's memory. All intermediate objectswill also be avilable inside ``bin/`` folder.


# Migration Roadmap

 * ~~Migrate the interrupt handler vector to C, still keeping all code in AVR Assembly;~~ Change of plans: Will keep the assembly code as the main code (compiling with ``-nostartfiles``).
 * ~~Rewrite the EEPROM driver in C so it will be possible do read and write config values;~~ Not needed, will use ``<avr/eeprom.h>`` functions;
 * ~~Migrate simple logics do C, for example, the ``reset`` interrupt handler; This handler just reads EEPROM values and call the correct ``main`` routine, based on the Receiver type (Standard, CPPM, S.Bus, Satellite);~~ Migrated.
 * ~~Rewrite the LCD display driver and use it from the Assembly code;~~ First attempt: Done. ~~Still does not work, for now the C code uses the original Assembly implementation.~~ The lcd_update() not working was due to gcc optimizing too much. Making some parts of the code ``volatile`` seems to solve the problem. C Implemented screens already uses the lcd_update() implemented in C.
 * Start to migrate each configuration screen to C;

   * Remote Tuning
   * PI Editor
   * ~~Self-level Settings~~
   * ~~Stick Scaling~~
   * ~~Mode Settings~~
   * ~~Misc. Settings~~
   * Gimbal Settings
   * ~~Advanced Settings~~
     * ~~Channel Mapping~~
     * ~~Sensor Settings~~
     * Mixer Editor
     * ~~Board orientation~~
   * AUX Switch Setup
   * ~~DG2 Switch Setup~~
   * ~~Initial Setup~~
     * Load Motor Layout
     * ACC Calibration
     * Trim Battery Voltage
     * ~~Select RX Mode~~
   * Receiver Test
   * Sensor Test
   * ~~Show Motor Layout~~
   * User Profile
   * ~~Extra Features~~
     * Check Motor Outputs
     * ~~Gimbal Controller~~
     * View Serial RX Data
   * ~~ESC Calibration~~
   * ~~Version Screen~~ Migrated
   * ~~LCD Contrast Screen~~ Migrated
   * ~~LCD Display driver~~
     * ~~LcdClear~~
     * ~~LcdUpdate~~
     * ~~PrintChar~~
     * ~~Sprite~~
     * ~~SetPixel~~
 * Reduce overal refresh rate from 400Hz to about 100Hz, if possible. This would leave room for flight loop new implementations to run.
 * Migrate the main loop to C, still calling the routines in Assembly;
 * Start to migrate each mainloop routine to C;
 * ....


Of course, each migration step must leave a code that's able to fly a Quad. Currently the migration is still in the first steps. I will be updating this readme as soon as I evolve in this journey.

If you like AVR micro controllers and would like to help this project, don't hesitate to get in touch and/or start openning pull requests to help make it happen!


Dalton Barreto, http://daltonmatos.com
