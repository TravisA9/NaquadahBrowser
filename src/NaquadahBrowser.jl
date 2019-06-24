# include("Projects/NaquadahBrowser/src/NaquadahBrowser.jl")
using Gtk, Gtk.ShortNames, Cairo, Graphics   # Colors
println(pwd())

if Sys.islinux()
    if basename(pwd()) != "NaquadahBrowser" # Make sure we're in the right dir
        cd("Projects/NaquadahBrowser")
    end
    defaultPage = "file:///src/SamplePages/test.sml"
    global PATH = pwd() * "/src/SamplePages/"
elseif is_windows() # Do something windows-y here... needs tested by someone with a MS machine
    if basename(pwd()) != "NaquadahBrowser" # Make sure we're in the right dir
        cd("Projects\\NaquadahBrowser")
    end
    defaultPage = "file:///src\\SamplePages\\test.sml"
    global PATH = pwd() * "src\\SamplePages\\"
end
#using NaquadahCore
include("NaquadahCore.jl")
# ======================================================================================
# Win()  Create a window
# ======================================================================================
struct Win
    window::Any #Gtk.GtkWindowLeafGtk.GtkCanvas
    canvas::Any #Gtk.GtkCanvas
    controls::Element # Array{Element,1}
    documents::Vector{Page}
    document::Page
    function Win()
        win = Window("Naquadah: An experimental web browser", 1000, 600) # later we can make it save last page size
        canvas = Canvas()
        push!(win, canvas)
        document = Page(defaultPage)
        document.canvas = canvas
        node = document.children[1]
        node.DOM = Dict( ">" => "window", "width" => 1000, "display" => "block", "padding" => [0,0,0,0], "nodes"=>[])
        FetchPage(document, defaultPage)

        document.win = win
        return new(win, canvas, node, [document], document)
    end
end

# ======================================================================================
# This is where drawing starts after a page is fetched.
# ======================================================================================
function DrawANode(document::Page)
    c = document.canvas
    node = document.children[1] #.children[2]
    page = node.children[3]

        #  This is efectively the resize event.
           @guarded draw(c) do widget

                ScrollY = 0.0
                ctx = getgc(c)
                document.height::Float64   = height(c)
                document.width::Float64    = width(c)

                if page.scroll.y < 0 # Don't scroll above zero/top
                    ScrollY = page.scroll.y
                    page.scroll.y = 0.0
                    VmoveAllChildren(page, abs(ScrollY), false) # FROM: LayoutBuild.jl
                end

                setUpWindow(document, document.width, document.height)    # FROM: LayoutBuild.jl
                allAtributesToLayout(document, node)
                AttatchEvents(document, c)            # FROM: Events.jl
                CreateLayoutTree(document, node)      # FROM: LayoutBegin.jl
                page.scroll.y = ScrollY
                VmoveAllChildren(page, ScrollY, false)
                DrawViewport(ctx, document, node)     # FROM: GraphDraw.jl
           end
    show(c);
end
# ======================================================================================

function main()
    win = Win(); # Win(controls)
    DrawANode(win.document)
end

main()
