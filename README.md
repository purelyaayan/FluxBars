# FluxBars - README

## Overview

This is a real-time audio visualizer built using lua.
It captures system/microphone audio and displays it as animated mirrored bars that react dynamically to sound.

The visualizer is designed to be lightweight, customizable, and responsive, with smooth animations and multiple display modes.

---

## Features

• Real-time Audio Visualization

* Captures live audio input
* Converts audio into frequency-based bar animations

• Mirror Mode (Default)

* Bars are mirrored from the center for a balanced, symmetrical look

• Smooth Animation System

* Uses interpolation for fluid bar movement
* Prevents jitter and harsh transitions

• RGB Mode

* Dynamic color cycling effect across bars
* Creates a vibrant, animated look

• Custom Colors

* Set your own bar color using HEX values
* Set background color independently

• Adjustable Bar Count

* Control how many bars are displayed
* Lower values = bigger bars
* Higher values = more detailed visualization

• Resizable Window

* Freely resize the application window
* Visualization adapts automatically

• Borderless Mode

* Toggle window borders for a cleaner look

• Settings System

* Built-in settings menu
* Saves preferences automatically

• Clipboard Support

* Paste HEX colors directly using keyboard

---

## Controls / Shortcuts

CTRL + S
→ Open / Close Settings Menu

TAB
→ Switch between input fields

ENTER
→ Apply and save settings

BACKSPACE
→ Delete last character in input

CTRL + V
→ Paste value into selected field

CTRL + R
→ Toggle RGB Mode

CTRL + B
→ Toggle Borderless Window

---

## Settings Menu

The settings menu allows you to modify:

• Bar Color

* Accepts HEX format (e.g. #ff0000)

• Background Color

* Accepts HEX format

• Number of Bars

* Range: 4 to 256
* Affects performance and visual density

All settings are saved automatically and loaded on next launch.

---

## Notes

• Make sure your system has an active audio input device
• Higher bar counts may impact performance on low-end systems
• HEX color format must be valid (#RRGGBB)

---

## Credits

Built using the programming language lua
Custom implementation inspired by modern audio visualizers

---

Enjoy the visualizer!
