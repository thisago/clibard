# Package

version       = "0.5.1"
author        = "Thiago Navarro"
description   = "Command line interface for Google Bard"
license       = "GPL-3.0"
srcDir        = "src"
bin           = @["clibard"]
binDir = "build"


# Dependencies

requires "nim >= 1.6.0"

requires "cligen"

requires "bard >= 0.7.0"
requires "gookie >= 0.5.0"
