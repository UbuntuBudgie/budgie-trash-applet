gnome = import('gnome')

configurationData = configuration_data()
configurationData.set('PACKAGE_NAME', 'budgie-extras')
configurationData.set('LOCALE_DIR', LOCALE_DIR)
configure_file(input: 'config.h.in', output: 'config.h', configuration: configurationData)


custom_target(
    'plugin-file-trash',
    input: 'Trash.plugin.in',
    output: 'Trash.plugin',
    command : [intltool, '--desktop-style', podir, '@INPUT@', '@OUTPUT@'],
    install: true,
    install_dir: APPLET_INSTALL_DIR
)

gresource_file = join_paths(data_dir, 'org.github.ubuntubudgie.budgie-trash-applet.gresource.xml')
res = gnome.compile_resources('bta-resources', gresource_file, source_dir: data_dir)

applet_trash_deps = [
    dep_budgie,
    dep_gtk3,
    dep_glib
]

applet_trash_sources =[
    'TrashApplet.vala',
    'Widgets/MainPopover.vala',
    'Widgets/IconButton.vala',
    'Widgets/SettingsView.vala',
    'Widgets/TrashItem.vala',
    'Widgets/TrashStoreWidget.vala',
    'TrashHandler.vala',
    'TrashStore.vala',
    res
]

bta_vala_args = [
    '--gresources=' + gresource_file,
    '--pkg', 'gtk+-3.0',
    '--pkg', 'glib-2.0',
    '--pkg=config',
    '--vapidir=' + VAPI_DIR,
]

shared_library(
    'trashapplet',
    applet_trash_sources,
    dependencies: applet_trash_deps,
    vala_args: bta_vala_args,
    install: true,
    install_dir: APPLET_INSTALL_DIR
)
