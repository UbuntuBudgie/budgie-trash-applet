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

    public class IconButton : Button {

        private Image? icon_empty = null;
        private Image? icon_full = null;

        private TrashHandler trash_handler;

        public void set_icon_full(bool full) {
            set_image(full ? icon_full : icon_empty);
        }

        public IconButton(TrashHandler trash_handler) {
            this.icon_empty = new Image.from_icon_name("user-trash-symbolic", IconSize.MENU);
            this.icon_full = new Image.from_icon_name("user-trash-full-symbolic", IconSize.MENU);
            this.trash_handler = trash_handler;

            this.set_image(icon_empty);

            this.tooltip_text = "Trash";

            this.get_style_context().add_class("flat");
            this.get_style_context().remove_class("button");
        }
    } // End class
} // End namespace
