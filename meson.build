project('budgie-trash',
        ['vala', 'c'],
        version: '1.2.1'
)

am_cflags = [
    '-fstack-protector',
    '-pedantic',
    '-Wstrict-prototypes',
    '-Wundef',
    '-Werror-implicit-function-declaration',
    '-Wformat',
    '-Wformat-security',
    '-Werror=format-security',
    '-Wconversion',
    '-Wunused-variable',
    '-Wunreachable-code',
    '-Wall',
    '-W'
]

add_global_arguments(am_cflags, language: 'c')
add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

# Dependencies
dep_budgie = dependency('budgie-1.0', version: '>= 2')
dep_gtk3 = dependency('gtk+-3.0', version: '>= 3.22.0')
dep_glib = dependency('glib-2.0', version: '>= 2.46.0')

intltool = find_program('intltool-merge')

# Global stuff
prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))
LOCALE_DIR = join_paths(prefix, get_option('localedir'))
podir = join_paths(meson.source_root(), 'po')
VAPI_DIR = join_paths(meson.source_root(),
                      'vapi')

SRC_DIR = meson.source_root()
APPLET_INSTALL_DIR = join_paths(libdir, 'budgie-desktop', 'plugins', meson.project_name())
data_dir = join_paths(SRC_DIR, 'data')

subdir('src')
