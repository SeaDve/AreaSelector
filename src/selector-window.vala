[GtkTemplate (ui = "/io/github/seadve/AreaSelector/selector-window.ui")]
public class AreaSelector.Window : Gtk.Window {
    public signal void captured (int x, int y, int w, int h);
    public signal void cancelled ();

    private bool dragging { get; set; }
    private Point start_point { get; set; }
    private Point end_point { get; set; }

    [GtkChild]
    public unowned Gtk.DrawingArea drawing_area;

    public Window (Gtk.Application app) {
        Object (application: app);
    }

    construct {
        this.add_css_class ("transparent");
        this.deletable = false;
        this.decorated = false;
        this.fullscreen ();
        this.set_cursor(new Gdk.Cursor.from_name("crosshair", null));
    }

    struct Point {
        public double x;
        public double y;
    }

    struct Area {
        public double w;
        public double h;
    }

    [GtkCallback]
    private void on_pressed_notify (int n_press, double x, double y) {
        this.dragging = true;
        this.start_point = { x, y };
    }

    [GtkCallback]
    private void on_released_notify (int n_press, double x, double y) {
        this.dragging = false;
        this.end_point = { x, y };

        var topleft_point = this.get_topleft_point (this.start_point, this.end_point);
        var area = this.get_area (this.start_point, this.end_point);

        if (area.w == 0 && area.h == 0) {
            area.w = topleft_point.x;
            area.h = topleft_point.y;
            topleft_point.x = 0;
            topleft_point.y = 0;
        };

        this.captured ((int) topleft_point.x, (int) topleft_point.y, (int) area.w, (int) area.h);

    }

    [GtkCallback]
    private void on_motion_notify (double x, double y) {
        if (!dragging) {
            return;
        };

        var w = x - this.start_point.x;
        var h = y - this.start_point.y;

        this.drawing_area.set_draw_func ((da, ctx, da_w, da_h) => {
            ctx.rectangle (start_point.x, start_point.y, w, h);
            ctx.set_source_rgba (0.1, 0.45, 0.8, 0.3);
            ctx.fill ();

            ctx.rectangle (start_point.x, start_point.y, w, h);
            ctx.set_source_rgb (0.1, 0.45, 0.8);
            ctx.set_line_width (1);
            ctx.stroke ();
        });

    }

    [GtkCallback]
    private bool on_key_pressed_notify (uint keyval, uint keycode) {
        if (keyval == 65307) {
            this.close ();
        };
        return true;
    }

    private Point get_topleft_point (Point p1, Point p2) {
        var min_x = p1.x > p2.x ? p2.x : p1.x;
        var min_y = p1.y > p2.y ? p2.y : p1.y;
        return { min_x, min_y };
    }

    private Area get_area (Point p1, Point p2) {
        var w = (p1.x - p2.x).abs ();
        var h = (p1.y - p2.y).abs ();
        return {w, h};
    }
}
