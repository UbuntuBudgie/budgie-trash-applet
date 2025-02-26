/*
 * This file is part of UbuntuBudgie
 *
 * Copyright 2019 Evan Maddock, 2021 Ubuntu Budgie Developers
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

using Gtk;

namespace TrashApplet.Widgets { 
    
    public class TrashStoreWidget : Box {

        private TrashStore trash_store;
        private HashTable<string, TrashItem> trash_items;
        private bool restoring = false;

        /* Widgets */
        private Box? store_header = null;
        private Image? drive_icon = null;
        private Label? store_label = null;
        private Button? restore_button = null;
        private Button? delete_button = null;

        private Revealer? revealer = null;
        private Box? revealer_container = null;
        private Label? revealer_text = null;
        private Box? revealer_buttons = null;
        private Button? go_back_button = null;
        private Button? confirm_button = null;

        private ListBox? file_box = null;

        public TrashStoreWidget(TrashStore trash_store, SortType sort_type) {
            Object(orientation: Orientation.VERTICAL, spacing: 0);
            this.trash_store = trash_store;
            trash_items = new HashTable<string, TrashItem>(str_hash, str_equal);
            get_style_context().add_class("trash-store-widget");

            /* Widget initialization */
            store_header = new Box(Orientation.HORIZONTAL, 0);
            store_header.get_style_context().add_class("trash-store-header");
            store_header.height_request = 32;
            store_header.tooltip_text = trash_store.get_drive_name();
            drive_icon = new Image.from_gicon(trash_store.get_drive_icon(), IconSize.SMALL_TOOLBAR);
            store_label = new Label(trash_store.get_drive_name());
            store_label.max_width_chars = 30;
            store_label.ellipsize = Pango.EllipsizeMode.END;
            store_label.halign = Align.START;
            store_label.justify = Justification.LEFT;
            store_header.pack_start(drive_icon, false, false, 10);
            store_header.pack_start(store_label, true, true, 0);

            restore_button = new Button.from_icon_name("edit-undo-symbolic", IconSize.SMALL_TOOLBAR);
            restore_button.tooltip_text = _("Restore all items");
            delete_button = new Button.from_icon_name("list-remove-all-symbolic", IconSize.SMALL_TOOLBAR);
            delete_button.tooltip_text = _("Delete all items");
            set_buttons_sensitive(false);
            store_header.pack_end(delete_button, false, false, 0);
            store_header.pack_end(restore_button, false, false, 0);

            revealer = new Revealer();
            revealer.set_transition_type(RevealerTransitionType.SLIDE_DOWN);
            revealer.set_reveal_child(false);
            revealer_container = new Box(Orientation.VERTICAL, 5);
            revealer_text = new Label("");
            revealer_text.height_request = 20;

            revealer_buttons = new Box(Orientation.HORIZONTAL, 0);
            go_back_button = new Button.with_label(_("No"));
            confirm_button = new Button.with_label(_("Yes"));
            revealer_buttons.pack_start(go_back_button);
            revealer_buttons.pack_end(confirm_button);

            revealer_container.pack_start(revealer_text, true, true, 0);
            revealer_container.pack_end(revealer_buttons);
            revealer.add(revealer_container);

            file_box = new ListBox();
            file_box.get_style_context().add_class("trash-file-box");
            file_box.get_style_context().add_class("empty");
            file_box.activate_on_single_click = true;
            file_box.selection_mode = SelectionMode.NONE;
            set_sort_type(sort_type);

            apply_button_styles();
            connect_signals();

            pack_start(store_header);
            pack_start(revealer, false, false, 0);
            pack_start(file_box);
            show_all();
        }

        /**
         * Add a new trash item.
         * 
         * @param info The FileInfo for the newly trashed file
         * @param old_path The path that the file came from
         */
        public void add_trash_item(string file_name, string file_path, GLib.Icon file_icon, DateTime deletion_time, bool is_directory) {
            var item = new TrashItem(file_path, file_name, file_icon, deletion_time, is_directory);
            trash_items.insert(file_name, item);
            file_box.insert(item, -1);
            file_box.get_style_context().remove_class("empty");
            set_buttons_sensitive(true);

            item.on_delete.connect((file_name) => {
                trash_store.delete_file(file_name);
            });

            item.on_restore.connect((file_name, restore_path) => {
                trash_store.restore_file(file_name, restore_path);
            });
        }

        /**
         * Remove an item from the trash view.
         * 
         * @param file_name The name of the file to remove
         */
        public void remove_trash_item(string file_name, bool is_empty) {
            var item = trash_items.get(file_name);
            file_box.remove(item.get_parent());
            trash_items.remove(file_name);

            //set_count_label();
            if (trash_items.size() == 0) { // No items in trash; buttons should no longer be sensitive
                file_box.get_style_context().add_class("empty");
                set_buttons_sensitive(false);
            }
        }

        public string get_name() {
            return store_label.get_label();
        }

        public void set_sort_type(SortType type) {
            switch (type) {
            case TYPE:
                file_box.set_sort_func(sort_by_type);
                break;
            case ALPHABETICAL:
                file_box.set_sort_func(sort_by_name);
                break;
            case NEWEST_FIRST:
                file_box.set_sort_func(sort_by_newest);
                break;
            case OLDEST_FIRST:
                file_box.set_sort_func(sort_by_oldest);
                break;
            case REVERSE_ALPHABETICAL:
                file_box.set_sort_func(sort_by_name_reverse);
                break;
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
            trash_store.trash_added.connect(add_trash_item);
            trash_store.trash_removed.connect(remove_trash_item);

            delete_button.clicked.connect(() => { // Delete button clicked
                show_confirmation(false);
            });

            restore_button.clicked.connect(() => { // Restore button clicked
                show_confirmation(true);
            });

            confirm_button.clicked.connect(() => { // Confirm button clicked
                if (restoring) { // User clicked the restore button
                    trash_items.get_values().foreach((item) => {
                        trash_store.restore_file(item.file_name, item.file_path);
                    });
                } else { // User clicked the delete button
                    trash_items.get_values().foreach((item) => {
                        trash_store.delete_file(item.file_name);
                    });
                }

                revealer.set_reveal_child(false);
            });

            go_back_button.clicked.connect(() => { // Go back button clicked
                restore_button.sensitive = true;
                delete_button.sensitive = true;
                revealer.set_reveal_child(false);
            });

            file_box.row_activated.connect((row) => {
                var widget = (TrashItem) row.get_child();
                widget.toggle_info_revealer();
            });
        }

        private void set_buttons_sensitive(bool is_sensitive) {
            restore_button.sensitive = is_sensitive;
            delete_button.sensitive = is_sensitive;
        }

        private void show_confirmation(bool restore) {
            this.restoring = restore;

            if (restore) {
                revealer_text.set_markup("<b>%s</b>".printf(_("Really restore all items?")));
            } else {
                revealer_text.set_markup("<b>%s</b>".printf(_("Really delete all items?")));
            }

            restore_button.sensitive = false;
            delete_button.sensitive = false;
            revealer.set_reveal_child(true);
        }

        /**
         * sort_by_name will determine the order that two given rows should be in 
         * using pure alphabetical order.
         * 
         * @param row1 The first row to use for comparison
         * @param row2 The second row to use for comparison
         * @return < 0 if row1 should be before row2, 0 if they are equal and > 0 otherwise
         */
        private int sort_by_name(ListBoxRow row1, ListBoxRow row2) {
            var trash_item_1 = row1.get_child() as TrashItem;
            var trash_item_2 = row2.get_child() as TrashItem;

            return trash_item_1.file_name.collate(trash_item_2.file_name);
        }

        /**
         * sort_by_name_reverse will determine the order that two given rows should be in 
         * using reverse alphabetical order.
         * 
         * @param row1 The first row to use for comparison
         * @param row2 The second row to use for comparison
         * @return < 0 if row1 should be before row2, 0 if they are equal and > 0 otherwise
         */
        private int sort_by_name_reverse(ListBoxRow row1, ListBoxRow row2) {
            var trash_item_1 = row1.get_child() as TrashItem;
            var trash_item_2 = row2.get_child() as TrashItem;

            return trash_item_2.file_name.collate(trash_item_1.file_name);
        }

        /**
         * sort_by_type will determine the order that two given rows should be in.
         * 
         * Directories should be above files, and both types should be sorted alphabetically.
         * 
         * @param row1 The first row to use for comparison
         * @param row2 The second row to use for comparison
         * @return < 0 if row1 should be before row2, 0 if they are equal and > 0 otherwise
         */
        private int sort_by_type(ListBoxRow row1, ListBoxRow row2) {
            var trash_item_1 = row1.get_child() as TrashItem;
            var trash_item_2 = row2.get_child() as TrashItem;

            if (trash_item_1.is_directory && trash_item_2.is_directory) { // Both items are directories, sort by name
                return trash_item_1.file_name.collate(trash_item_2.file_name);
            } else if (trash_item_1.is_directory && !trash_item_2.is_directory) { // First item is a directory
                return -1; // First item should be above the second
            } else if (!trash_item_1.is_directory && trash_item_2.is_directory) { // First item is a file, second is a directory
                return 1; // Second item should be above the first
            } else { // Both items are files, sort by file name
                return trash_item_1.file_name.collate(trash_item_2.file_name);
            }
        }

        private int sort_by_newest(ListBoxRow row1, ListBoxRow row2) {
            var trash_item_1 = row1.get_child() as TrashItem;
            var trash_item_2 = row2.get_child() as TrashItem;

            return trash_item_2.deletion_time.compare(trash_item_1.deletion_time);
        }

        private int sort_by_oldest(ListBoxRow row1, ListBoxRow row2) {
            var trash_item_1 = row1.get_child() as TrashItem;
            var trash_item_2 = row2.get_child() as TrashItem;

            return trash_item_1.deletion_time.compare(trash_item_2.deletion_time);
        }
    }
}
