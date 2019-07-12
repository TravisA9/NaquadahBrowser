# include("Projects/NaquadahBrowser/src/NaquadahBrowser.jl")
using Gtk, Gtk.ShortNames, Cairo, Graphics   # Colors


if Sys.islinux()
    if basename(pwd()) != "NaquadahBrowser" # Make sure we're in the right dir
        cd("Projects/NaquadahBrowser")
    end
    defaultPage = "http://travis.x10host.com/test.sml"
    # defaultPage = "file:///src/SamplePages/test.sml"
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
    document::Page
    function Win()
        win = Window("Naquadah: An experimental web browser", 1000, 600); # later we can make it save last page size
        canvas = Canvas();
        push!(win, canvas);
        document = Page(defaultPage, 1000, 600);
        document.canvas = canvas;
        FetchPage(document);
        document.content = document.controls.children[3].children;

        document.win = win;
        return new(win, canvas, document);
    end
end
# ======================================================================================
# Scroll page or a node: moves all children as needed
# ======================================================================================
function scrollnode(node)
    ScrollY = 0.0
    if node.scroll.y > 0 # Don't scroll above zero/top
        ScrollY = node.scroll.y
        node.scroll.y = 0.0
    end
    VmoveAllChildren(node, abs(ScrollY), false) # FROM: LayoutBuild.jl
    node.scroll.y = ScrollY
end
# ======================================================================================
# This is where drawing starts after a page is fetched.
# ======================================================================================
function DrawANode(document::Page)
    c = document.canvas;
    node = document.controls
        #  This is efectively the resize event.
           @guarded draw(c) do widget

               ctx = getgc(c);
               document.height::Float64 = height(c);
               document.width::Float64  = width(c);
               ScrollY = document.content[1].scroll.y
               # scrollnode(document.content[1])
               # if node.scroll.y > 0 # Don't scroll above zero/top
               #     ScrollY = node.scroll.y
               #     node.scroll.y = 0.0
               # end
               document.fixed.rows = [] #Row(0, 0, w)
               document.eventsList = AttachedEvents()
               node.shape = NBox(document.width, document.height)
               document.fixed.shape = NBox(document.width, document.height)

               AttatchEvents(document, c)  # FROM: Events.jl
               allAtributesToLayout(document, node)
               document.content[1].shape.height = document.height-74
               CreateLayoutTree(document, node)      # FROM: LayoutBegin.jl

               VmoveAllChildren(document.content[1], abs(ScrollY), false)
               document.content[1].scroll.y = ScrollY
               document.content[1].parent.shape.top = 74.0
               DrawContent(ctx, document, node) # FROM: GraphDraw.jl
           end
    show(c);
end

# ======================================================================================
# ======================================================================================
function main()
    win = Win(); # Win(controls)
    DrawANode(win.document);
end

main();
