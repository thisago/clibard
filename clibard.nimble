# Package

version       = "0.2.0"
author        = "Thiago Navarro"
description   = "Command line interface for Google Bard"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["clibard"]
binDir = "build"


# Dependencies

requires "nim >= 1.6.0"

requires "cligen"

requires "bard", "gookie"
