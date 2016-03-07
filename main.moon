-- load the core
require "vendor"
require "lib"
lpeg = require "lpeglj"
package.loaded.lpeg = lpeg
require "globals"
require "moonscript"
moon = require "moon"

moon.p _G.arg

