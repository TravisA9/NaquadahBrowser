
export CreateLayoutTree
# ======================================================================================
"""
## CreateLayoutTree(document::Page, node::Element)

Generate a layout tree starting at `node` in `document`. This should be callable
starting at any point in the document tree.

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/NaquadahCore.jl#L70)
"""
# ======================================================================================, shape::Draw
function CreateLayoutTree(document::Page, parent::Element)

    isa(parent.shape, NText) && return # TODO: may be able to make this part of multiple dispatch later

    parent.rows  = []  # Clean out old data (?)
    #l,t,w,h = getContentBox(parent.shape, getReal(parent.shape)...)
    l,t,w,h = getContentBox(parent.shape)

    children = parent.children

    for child in children
                child.parent = parent # attach to parent
                AtributesToLayout(document, child) # Create Child's DOM
            if child.shape.flags[DisplayNone] == false # only draw if not "display: none"
                PushToRow(document, parent, child, child.shape, l,t,w) # Put child into row
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

        if parent.shape.flags[FixedHeight] == false
            parent.shape.height = parent.scroll.contentHeight
        end
        # This is to be done after the parent node's size is finalised!
        if parent.shape.flags[HasAbsolute] == true
          # get node metrics again since the height etc. might have changed.
          l,t,w,h = getContentBox(parent.shape)
          for child in children
            if !isa(child.shape, NText)
                shape = child.shape
                width, height = getSize(shape)
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
                  # all children of "absolute" parent need moved to correct location.
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
