# KK2.1.x firmware, based on RC911 code

This is a copy of the code originally written by RC911 for the KK2 flight controller board. In this project you will find one branch for each version of his firmware (All-in-one for KK2.1.x) and each receiver type (for the KK2).

I published a series of blog posts as a proof of concept that's possible to mix an AVR Studio 4 Assembly project with an avr-gcc C project. Since the original firmware is almost 13K LOC it is unthinkable to rewrite all code in one pass. That's why the plan is to mix the original code with newer C code and migrate the implementation to C in parts.

The idea behind this migration is that I think having the code written in C will lower the barrier to new contributors for the project.

The research can be found here: http://daltonmatos.com/pages/avrgcc-avrasm2-en.html 

The scripts and tools to automate the mixedcode building is in another project in my Github profile: https://github.com/daltonmatos/avrgcc-mixed-with-avrasm2 

The main script is: ``experiments/build-ihex.sh`` inside this repository.

Below you will find a suggestion on the necessary steps to accomplish this migration.

# Possible Migration Roadmap

 * ~~Migrate the interrupt handler vector to C, still keeping all code in AVR Assembly;~~ Change of plans: Will keep the assembly code as the main code (compiling with ``-nostartfiles``).
 * ~~Rewrite the EEPROM driver in C so it will be possible do read and write config values;~~ Not needed, will use ``<avr/eeprom.h>`` functions;
 * ~~Migrate simple logics do C, for example, the ``reset`` interrupt handler; This handler just reads EEPROM values and call the correct ``main`` routine, based on the Receiver type (Standard, CPPM, S.Bus, Satellite);~~ Migrated.
 * ~~Rewrite the LCD display driver and use it from the Assembly code;~~ First attempt: Done. Still does not work, for now the C code uses the original Assembly implementation. Will fully migrate another time
 * Stat to migrate each configuration screen to C;
   * ~~Version Screen~~ Migrated
   * LCD Contrast Screen
   * _More to be added_
 * Migrate the main loop to C, still calling the routines in Assembly;
 * Start to migrate each mainloop routine to C;
 * ....


Of course, each migration step must leave a code that's able to fly a Quad. Currently the migration is still in the first steps. I will be updating this readme as soon as I evolve in this journey.

If you like AVR micro controllers and would like to help this project, don't hesitate to get in touch and/or start openning pull requests to help make it happen!


Dalton Barreto, http://daltonmatos.com
