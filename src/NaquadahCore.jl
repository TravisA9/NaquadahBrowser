using Gtk, Gtk.ShortNames, Cairo   # Colors
# ==============================================================================
module NaquadahCore
                        include("Graphics/GraphTypes.jl")
                        include("NaquadahTypes.jl")
                        include("Events/Events.jl")
                        include("Graphics/Graphics.jl")
                        include("DOM/Dom.jl")
                        include("Layout/Layout.jl")
end
# ==============================================================================







using NaquadahCore
# LOAD_PATH, Base.LOAD_CACHE_PATH, @__FILE__, @__DIR__
defaultPage = "file:///.julia/v0.6/NaquadahBrowser/src/SamplePages/test.json"
global PATH = pwd() * "/.julia/v0.6/NaquadahBrowser/src/SamplePages/"
# ======================================================================================
# """
# ## Win()
# Create a window
# ```julia-repl
# mutable struct Win
#     window::Any #Gtk.GtkWindowLeafGtk.GtkCanvas
#     canvas::Any #Gtk.GtkCanvas
#     controls::Element # Array{Element,1}
#     documents::Array{Page,1}
#     document::Page
# end
# ```
# [Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/NaquadahCore.jl#L46)
# """
# ======================================================================================
mutable struct Win
    window::Any #Gtk.GtkWindowLeafGtk.GtkCanvas
    canvas::Any #Gtk.GtkCanvas
    controls::Element # Array{Element,1}
    documents::Array{Page,1}
    document::Page
    function Win()
        c = Canvas();
        win = Window("Naquadah: An experimental web browser", 1000, 600); # later we can make it save last page size
        push!(win, c);

            # STRUCTURE:
            #            node.DOM[1] / tabControls / windowControls / tab
            #            node.DOM[2] / navigation
            #            node.DOM[3] / newPage
        document, controls = FetchPage(win, defaultPage, c, 1000) # Let's start out with a default page
        return new(win, c, controls, [document], document)
    end
end
# ======================================================================================
# """
# ## DrawANode(document::Page)
#
# This is where drawing starts after a page is fetched.
#
# [Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/NaquadahCore.jl#L73)
# """
# ======================================================================================
function DrawANode(document::Page)
    c = document.canvas


           @guarded draw(c) do widget
               node = document.children[1] #.children[2]
               page = node.children[3]

                ScrollY = 0.0
                ctx = getgc(c)
                document.height::Float64   = height(c)
                document.width::Float64   = width(c)

                if page.scroll.y < 0 # Don't scroll above zero/top
                    ScrollY = page.scroll.y

                    page.scroll.y = 0.0

                    VmoveAllChildren(page, abs(ScrollY), false) # FROM: LayoutBuild.jl
                end

                setUpWindow(document, document.width, document.height)    # FROM: LayoutBuild.jl
                AtributesToLayout(document, node)     # FROM: DomToLayout.jl
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
