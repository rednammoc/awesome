#!/usr/bin/env python
# -*- coding: iso-8859-15 -*-

import gtk, random, gobject, time

# The QixWindow class that holds variables specific to each window:
class LoginScreen :

    def __init__(self) :
        self.win = gtk.Window()
        color = gtk.gdk.color_parse('#000000')
        self.win.modify_bg(gtk.STATE_NORMAL, color)

    # Called whenever any key is pressed:
    def key_press_event(self, widget, event) :
        if event.string == "q" :
            gtk.main_quit()

    def set_label(self, color, text):
        self.label.set_markup('<span color="' + color + '" size="38000"><b>' + text + '</b></span>')

    def make_window(self) :
        # Create the main window.
        self.win.fullscreen()

        # Handle events.
        self.win.connect("key-press-event", self.key_press_event)
        self.win.connect("destroy", gtk.main_quit)

        # Center widget.
        vbox = gtk.VBox()
        hbox = gtk.HBox()
        vbox.add(hbox)

        # Create welcome-message.
        self.text = " (◣_◢) "
        self.label = gtk.Label()
        self.label_color = '#ffffff'
        self.label.set_use_markup(True)
        self.set_label(self.label_color, self.text)
        hbox.add(self.label)

        # Create window
        self.win.add(vbox)
        self.win.show_all()

        gtk.timeout_add(7000, do_quit_application, self)
        gtk.timeout_add(500, do_label_glow_darker, self)
        gtk.main()


def subtract_hex(hex1, hex2):
    return hex(int(hex1, 16) - int(hex2, 16))

def add_hex(hex1, hex2):
    return hex(int(hex1, 16) + int(hex2, 16))

def do_quit_application(self):
    gtk.main_quit()

def do_label_glow_lighter(self):
    if w.label_color == '#ffffff' :
        gtk.timeout_add(100, do_label_glow_darker, self)
    else:
        color = add_hex(('0x' + w.label_color[1:]), '0x020202')
        w.label_color = '#' + color[2:]
        gtk.timeout_add(10, do_label_glow_lighter, self)

    self.set_label(w.label_color, w.text)


def do_label_glow_darker(self):
    if w.label_color == '#111111' :
        gtk.timeout_add(100, do_label_glow_lighter, self)
    else:
        color = subtract_hex(('0x' + w.label_color[1:]), '0x020202')
        w.label_color = '#' + color[2:]
        gtk.timeout_add(10, do_label_glow_darker, self)

    self.set_label(w.label_color, w.text)

w = LoginScreen()
w.make_window()
