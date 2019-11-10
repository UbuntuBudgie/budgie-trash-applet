using GLib;

namespace TrashApplet.Widgets { 

    public class TrashItem : Gtk.Box {

        /* State */
        private bool restoring = false;

        public string file_path { get; private set; }
        public string file_name { get; private set; }
        public bool is_directory { get; private set; }
        public DateTime deletion_time { get; private set; }

        /* Widgets */
        private Gtk.Box file_container = null;
        private Gtk.Image? file_icon = null;
        private Gtk.Label? display_text = null;
        private Gtk.Button? restore_button = null;
        private Gtk.Button? delete_button = null;

        private Gtk.Revealer? info_revealer = null;
        private Gtk.Box? info_container = null;
        private Gtk.Label? path_label = null;
        private Gtk.Label? date_label = null;

        private Gtk.Revealer? revealer = null;
        private Gtk.Box? revealer_container = null;
        private Gtk.Label? revealer_text = null;
        private Gtk.Box? revealer_buttons = null;
        private Gtk.Button? go_back_button = null;
        private Gtk.Button? confirm_button = null;

        /* Signals */
        public signal void on_delete(string file_name);
        public signal void on_restore(string file_name, string restore_path);

        /**
         * Constructor
         */
        public TrashItem(string file_path, string file_name, Icon glib_icon, DateTime deletion_time, bool is_directory) {
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
            this.file_path = file_path;
            this.file_name = file_name;
            this.deletion_time = deletion_time;
            this.is_directory = is_directory;

            get_style_context().add_class("trash-item");

            /* Create Widget stuff */
            file_container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            file_container.height_request = 32;
            file_icon = new Gtk.Image.from_gicon(glib_icon, Gtk.IconSize.SMALL_TOOLBAR);
            display_text = new Gtk.Label(file_name);
            display_text.max_width_chars = 30;
            display_text.ellipsize = Pango.EllipsizeMode.END;
            display_text.halign = Gtk.Align.START;
            display_text.justify = Gtk.Justification.LEFT;

            restore_button = new Gtk.Button.from_icon_name("edit-undo-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            restore_button.tooltip_text = "Restore item";
            delete_button = new Gtk.Button.from_icon_name("user-trash-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            delete_button.tooltip_text = "Delete item";

            file_container.pack_start(file_icon, false, false, 5);
            file_container.pack_start(display_text, true, true, 0);
            file_container.pack_end(delete_button, false, false, 0);
            file_container.pack_end(restore_button, false, false, 0);

            info_revealer = new Gtk.Revealer();
            info_revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN);
            info_revealer.set_reveal_child(false);
            info_revealer.get_style_context().add_class("trash-info-revealer");
            info_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);

            path_label = new Gtk.Label("Path: %s".printf(file_path));
            path_label.tooltip_text = file_path;
            path_label.ellipsize = Pango.EllipsizeMode.END;
            path_label.halign = Gtk.Align.START;
            path_label.justify = Gtk.Justification.LEFT;

            var time = deletion_time.format("%Y-%m-%d %H:%M %Z");
            date_label = new Gtk.Label("Deleted on: %s".printf(time));
            date_label.halign = Gtk.Align.START;
            date_label.justify = Gtk.Justification.LEFT;

            info_container.pack_start(path_label, true, true, 0);
            info_container.pack_start(date_label, true, true, 0);
            info_revealer.add(info_container);

            revealer = new Gtk.Revealer();
            revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN);
            revealer.set_reveal_child(false);
            revealer_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
            revealer_text = new Gtk.Label("");
            revealer_text.height_request = 20;

            revealer_buttons = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            go_back_button = new Gtk.Button.with_label("No");
            confirm_button = new Gtk.Button.with_label("Yes");
            revealer_buttons.pack_start(go_back_button);
            revealer_buttons.pack_end(confirm_button);

            revealer_container.pack_start(revealer_text, true, true, 0);
            revealer_container.pack_end(revealer_buttons);
            revealer.add(revealer_container);

            apply_button_styles();
            connect_signals();

            pack_start(file_container);
            pack_end(revealer, false, false, 0);
            pack_end(info_revealer, false, false, 0);
            show_all();
        }

        public void toggle_info_revealer() {
            if (info_revealer.get_reveal_child()) { // Currently shown; hide the revealer
                info_revealer.set_reveal_child(false);
            } else { // Show the revealer
                info_revealer.set_reveal_child(true);
            }
        }

        private void apply_button_styles() {
            restore_button.get_style_context().add_class("flat");
            delete_button.get_style_context().add_class("flat");
            go_back_button.get_style_context().add_class("flat");
            confirm_button.get_style_context().add_class("flat");
            confirm_button.get_style_context().add_class("destructive-action");

            restore_button.get_style_context().remove_class("button");
            delete_button.get_style_context().remove_class("button");
            go_back_button.get_style_context().remove_class("button");
            confirm_button.get_style_context().remove_class("button");
        }

        private void connect_signals() {
            delete_button.clicked.connect(() => { // Delete button clicked
                show_confirmation(false);
            });

            restore_button.clicked.connect(() => { // Restore button clicked
                show_confirmation(true);
            });

            confirm_button.clicked.connect(() => { // Confirm button clicked
                if (restoring) { // User clicked the restore button
                    on_restore(file_name, file_path);
                } else { // User clicked the delete button
                    on_delete(file_name);
                }
            });

            go_back_button.clicked.connect(() => { // Go back button clicked
                restore_button.sensitive = true;
                delete_button.sensitive = true;
                revealer.set_reveal_child(false);
            });
        }

        private void show_confirmation(bool restore) {
            this.restoring = restore;

            if (restore) {
                revealer_text.set_markup("<b>%s</b>".printf("Really restore this item?"));
            } else {
                revealer_text.set_markup("<b>%s</b>".printf("Really delete this item?"));
            }

            restore_button.sensitive = false;
            delete_button.sensitive = false;
            revealer.set_reveal_child(true);
        }
    } // End class
} // End namespace
