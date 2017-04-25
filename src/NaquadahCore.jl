# module NaquadahCore
#   package code goes here
# end # module
defaultPage = "file:///src/SamplePages/test.json"
global PATH = pwd() * "/data/"

include("GraphDraw.jl")
include("DomUtilities.jl")
include("DomTree.jl")
include("GraphFlags.jl")

using Gtk, Gtk.ShortNames, Cairo   # Colors
using NaquadahDOM, Naquadraw



# ======================================================================================
# ======================================================================================
# ======================================================================================
function CreateLayoutTree(document, node)
    isa(node.shape, NText) && return

    node.rows  = []
    #if node.shape === nothing
    #    AtributesToLayout(document, node)
    #end
        l,t,w,h = getContentBox(node.shape, getReal(node.shape)...)

    children = node.children

    for child in children
                # Create rows in child if it has children (I wonder if this could be done while setting DOM? )
                length(child.children) > 0   &&   Row(child.rows, l,t,w)
                # Create Child's DOM
                AtributesToLayout(document, child)

                # Put child into row
                if isa(child.shape, NText) #node.shape.flags[] == true row =
                    textToRows(document, node, child, l,t,w)
                else
                    PushToRow(document, node, child, l,t,w)
                end
                # Create child's children
                CreateLayoutTree(document, child)
    end
    # Clean-up! Generally the last row of each child is not yet finalized.
    if length(node.rows) > 0    lastRow = node.rows[end]
        FinalizeRow(lastRow)
        # Set content height and width for scroller
        node.scroll.contentHeight = lastRow.y + lastRow.height - node.shape.top
        node.scroll.contentWidth  = lastRow.x + lastRow.width  - node.shape.left

        if node.shape.flags[FixedHeight] == false
            node.shape.height = node.scroll.contentHeight
        end
        # This is to be done after the parent node's size is finalised!
        if node.shape.flags[HasAbsolute] == true
          # get node metrics again since the height etc. might have changed.
          l,t,w,h = getContentBox(node.shape, getReal(node.shape)...)
          for child in children
            if !isa(child.shape, NText)
                shape = child.shape
                width,height = getSize(shape)
                # padding, border, margin = getReal(shape)
                if shape.flags[Absolute] == true
                  top,left = shape.top, shape.left
                  if shape.flags[Bottom] == true
                        shape.top =  t + h - (height + shape.top)
                  else
                        shape.top =  t + shape.top
                  end
                  if shape.flags[Right] == true
                        shape.left =  l + w - (width + shape.left)
                  else
                        shape.left =  l +  shape.left
                  end
                  # all children of "absolute" node need moved to correct location.
                  # contents = child.children
                  rows = child.rows
                  for row in rows         # row.nodes[i]
                    for n in row.nodes
                      MoveAll(n, shape.left - left, shape.top - top)
                    end
                  end
              end
            end
          end
        end


    end
end
# ======================================================================================
function DrawANode(document)
    c = document.canvas
    node = document.children[1] #.children[2]

   @guarded draw(c) do widget
       ScrollY = 0
        ctx = getgc(c)
        h   = height(c)
        w   = width(c)
        document.height ,document.width = h, w

        if node.children[3].scroll.y < 0
            ScrollY = node.children[3].scroll.y
            node.children[3].scroll.y = 0
            println("scroll ", abs(ScrollY))
            VmoveAllChildren(node.children[3], abs(ScrollY), false)
            #MoveAll(node,node.scroll.x, abs(ScrollY))
        end
       setWindowSize(w,h, node)
       AtributesToLayout(document, node)
       AttatchEvents(document)
       CreateLayoutTree(document, node)
       #println("Children: ", node.children[3].shape.height)
       node.children[3].scroll.y = ScrollY
       #MoveAll(node.children[3],node.children[3].scroll.x,ScrollY)
       VmoveAllChildren(node.children[3], ScrollY, false)
       DrawContent(ctx, document, node)
   end
show(c)

end
# ======================================================================================
c = @Canvas()
win = @Window("Naquadah", 1000, 600)
push!(win, c)
document = FetchPage(defaultPage, c) # DomTree.jl
DrawANode(document)
