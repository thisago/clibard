# Package

version       = "0.3.2"
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
