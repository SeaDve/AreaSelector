// SPDX-FileCopyrightText: Copyright 2021 SeaDve
// SPDX-License-Identifier: GPL-3.0-or-later

int main (string[] argv) {

    var app = new Gtk.Application ("com.github.seadve.AreaSelector",
                                   GLib.ApplicationFlags.FLAGS_NONE);

    app.activate.connect (() => {
        var css_provider = new Gtk.CssProvider ();
        Gtk.StyleContext.add_provider_for_display (
            (!) Gdk.Display.get_default (),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        unowned var css_data = (uint8[]) ".transparent { background: rgba(0, 0, 0, 0.004); }";
        css_provider.load_from_data (css_data);

        var window = new AreaSelector.Window (app);

        window.captured.connect ((x, y, w, h) => {
            stdout.printf ("%d, %d, %d, %d\n", x, y, w, h);
            window.close ();
        });

        window.cancelled.connect (() => {
            window.close ();
        });

        window.present ();
    });
    return app.run (argv);
}
