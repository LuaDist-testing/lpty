-- This file was automatically generated for the LuaDist project.

package = "lpty"
version = "0.8-1"
-- LuaDist source
source = {
  tag = "0.8-1",
  url = "git://github.com/LuaDist-testing/lpty.git"
}
-- Original source
-- source = {
-- 	url = "http://www.tset.de/downloads/lpty-0.8-1.tar.gz"
-- }
description = {
	summary = "A simple facility for lua to control other programs via PTYs.",
	detailed = [[
		This is a simple wrapper around unix PTYs. PTYs can be opened, lua
		controls the master side of the PTY. Programs can be started with the
		client side of those PTYs as their controlling terminals.
	]],
	homepage = "http://www.tset.de/lpty/",
	license = "MIT/X11",
	maintainer = "Gunnar Zötl <gz@tset.de>"
}
supported_platforms = {
	"unix", "mac"
}
dependencies = {
	"lua >= 5.1"
}

build = {
	type = "builtin",
	modules = {
		lpty = {
			sources = { "lpty.c" },
		},
	},
	copy_directories = { 'doc', 'samples' },
}
