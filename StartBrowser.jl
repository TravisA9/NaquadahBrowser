
#!/usr/bin/julia


# run with examples:
#                    Windows  include("D:\Browser\StartBrowser.jl")
#                    Linux    include("Browser/StartBrowser.jl")

# https://developer.gnome.org/gdk3/stable/
# http://zetcode.com/gfx/cairo
# https://github.com/JuliaLang/JSON.jl
# ======================================================================================
# using /home/travis/BrowsertTypes.jl
using Gtk, JSON, Cairo, Requests
using Gtk.ShortNames, Graphics
using ImageView, ImageMagick, Images
defaultPage = "http://travis.net16.net/something.json"

# Attatch events
include("Events/Events.jl")            # Drawing stuff

# Mish-mash
include("Browser.jl")            # Drawing stuff


# convert units to pixels
include("GUI/Conversions.jl")
# Types declarations for the browser
include("GUI/BrowserTypes.jl")


# Bit Flags to indicate properties of elements
include("DOM/Flags.jl")            # Flags for elements
# transfere data from Dict(page-data) to build the DOM tree
include("DOM/SetAttributes.jl")
# Functions used to build elements/DOM tree
# WAS: include("BuildElements.jl")
include("DOM/BuildDOM.jl")


# geometric type declarations
include("Rendering/DrawPage.jl")
# geometric type declarations
include("Rendering/GeoTypes.jl")
# A place to put functions as they transition from temporary drawing to permanant functions
# WAS: include("Samples.jl")            # Drawing stuff
include("Rendering/DrawShapes.jl")            # Drawing stuff
# Definitions for web colors ( This may be redundant! )
include("Rendering/ColorDefinitions.jl") # ...appears to already be included
# Coordinate drawing of DOM elements
include("Rendering/Paint.jl")            # Drawing stuff



window = makeWindow(1000,800)
FetchPage(defaultPage)

