
export CreateLayoutTree, getInheritWidth
function getInheritWidth(document::Page, p)
        while p.shape.width < 1
            p == p.parent && (return document.width)
            p = p.parent
        end
        return p.shape.width
end
# width, h = getSize(p.shape)
# return width
# ======================================================================================
## CreateLayoutTree(document::Page, node::Element)
# Generate a layout tree starting at `node` in `document`. This should be callable
# starting at any point in the document tree.
# ======================================================================================, shape::Draw
function CreateLayoutTree(document::Page, parent)

    isa(parent.shape, TextLine) && return # TODO: may be able to make this part of multiple dispatch later

    parent.rows  = []  # Clean out old data (?)
    l,t,w,h = getContentBox(parent.shape)
    w = getInheritWidth(document::Page, parent) # because width may not be set
    children = parent.children

    for child in children
                child.parent = parent # attach to parent
                if isdefined(child, :children) && length(child.children) > 0
                    child.rows = []
                end
                #AtributesToLayout(document, child) # Create Child's DOM (DomToLayout.jl)
            if !child.shape.flags[DisplayNone] # only draw if not "display: none"
                PushToRow(document, child, l,t,w) # Put child into row
                CreateLayoutTree(document, child) # Create child's children
            end
    end

    # Clean-up! Generally the last row of each child is not yet finalized.
    if length(parent.rows) > 0
        lastRow = parent.rows[end]
        FinalizeRow(lastRow)
        # Set content height and width for scroller
        parent.scroll.contentHeight = lastRow.top + lastRow.height - parent.shape.top
        parent.scroll.contentWidth  = lastRow.left + lastRow.width  - parent.shape.left

        if !parent.shape.flags[FixedHeight]
            parent.shape.height = parent.scroll.contentHeight
        end
        # This is to be done after the parent node's size is finalised!
        if parent.shape.flags[HasAbsolute]
          # get node metrics again since the height etc. might have changed.
          l,t,w,h = getContentBox(parent.shape)
          for child in children
                shape = child.shape
                width, height = getSize(shape)
                if shape.flags[Absolute]
                  top,left = shape.top, shape.left # temp variables
                  setDistanceFromBounds(l,t,w,h,  shape )
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
