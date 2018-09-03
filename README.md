# avrdude-autoreset-wrapper
Wrapper for avrdude performing automatic reset to bootloader in arduino usb devices like leonardo and lilypad usb

Version: 1.0<br/>
Date: 3.9.2018<br/>
Author: Javanaut<br/>

Based on arduino-leonardo-uploader from p1ne found here:<br/>
https://github.com/p1ne/arduino-leonardo-uploader

In arduino-leonardo-uploader user p1ne realized the brilliant idea to use WMIC to allocate the com port of a connected arduino device and its bootloader. I just added some generalization to the script in order to make it usuable with arduino devices other than leonardo. Consider the following license to the parts added from me:

THE BEER-WARE LICENSE (Revision 42):<br/>
<javanaut2018@gmail.com> wrote this file. As long as you retain this notice you can do whatever you want with this stuff. If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.

Todo:<br/>
Add device identifiers of remaining usb arduinos

Description
-----------

This wrapper enables avrdude to perform the necessary steps to bring the target device into bootloader mode. The autoreset feature is triggered by programmer id "avr109" enabling it for arduino types leonardo and lilypad usb. Other arduino devices like micro or yun are to be implemented yet. This should be easy as two lines has to be added per devices at marked locations in .bat file.

This wrapper is designed to work with Eclipse C++ IDE for Arduino 3.0 to remove the "butterfly_recv(): programmer is not responding" bug that occurs when a usb based arduino device using the avr109 protocol is to be programmed. Compiling + flashing on single click to Button "Launch in 'Run' mode" shall then be possible.

Mode of operation
-----------------

Arguments passed to batch file are parsed and stored. WMIC is then used to check if a arduino avr109 device is present, reset the device and finding the bootloader port that appears after reset. The new port and stored arguments are then passed to avrdude to start the regular flashing process.

The wrapper needs at least the programmer id, com port and device id (partno) to work correctly.

In case another programmer id is passed the wrapper will behave transparent doing nothing but passing the arguments to avrdude.

Modifying Eclipse C++ IDE for Arduino 3.0
-----------------------------------------

Locate the arduino base directory, per default this is:

C:\Users\<Username>\.arduinocdt

In this directory perform the following steps:

1. Place .bat file here:

\packages\arduino\tools\avrdude\<latest version>\bin

2. Modify platform.txt located here:

\packages\arduino\hardware\avr\<latest version>\platform.txt

#tools.avrdude.cmd.path={path}/bin/avrdude
tools.avrdude.cmd.path={path}/bin/avrdude_wrapper.bat

3. Restart Eclipse
