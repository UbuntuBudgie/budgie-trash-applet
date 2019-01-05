namespace TrashApplet { 

    public class TrashItem : Gtk.Box {

        /* State */
        private string file_path;
        private string file_name;

        /* Widgets */
        private Gtk.Image? file_icon = null;
        private Gtk.Label? name_label = null;

        /**
         * Constructor
         */
        public TrashItem(string file_path, string file_name, GLib.Icon glib_icon) {
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);

            this.file_path = file_path;
            this.file_name = file_name;

            /* Create Widget stuff */
            this.file_icon = new Gtk.Image.from_gicon(glib_icon, Gtk.IconSize.DIALOG);
            this.name_label = new Gtk.Label(file_name);
            this.name_label.max_width_chars = 16;
            this.name_label.ellipsize = Pango.EllipsizeMode.END;

            this.tooltip_text = file_path;

            pack_start(file_icon, true, true, 0);
            pack_end(name_label);
            show_all();
        }
    } // End class
} // End namespace
