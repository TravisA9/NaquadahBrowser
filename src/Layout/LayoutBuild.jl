export setUpWindow, PushToRow, FinalizeRow
# ======================================================================================
### Types exported from Graphics
# ======================================================================================
function setUpWindow(document::Page, w::Float64,h::Float64)

    n = document.children[1]
    n.shape = NBox()
     n.shape.color = [1,1,1]
     n.shape.padding = BoxOutline(0,0,0,0,0,0)
     n.shape.border = Border(0,0, 0,0, 0,0, "solid",[.5,.5,.5,1],[0,0,0,0])
     n.shape.left    = 0
     n.shape.top     = 0
     n.shape.width   = w # S hould be window width  - controls
     n.shape.height  = h # S hould be window height - controls

    document.fixed.rows = [] #Row(0, 0, w)
    fn = document.fixed
    fn.shape = NBox()
      fn.shape.color = [1,1,1]
      fn.shape.padding = BoxOutline(0,0,0,0,0,0)
      fn.shape.border = Border(0,0, 0,0, 0,0, "solid",[.5,.5,.5,1],[0,0,0,0])
      fn.shape.left    = 0
      fn.shape.top     = 0
      fn.shape.width   = w # S hould be window width  - controls
      fn.shape.height  = h # S hould be window height - controls
end
#======================================================================================#
#======================================================================================#
# Types exported from Graphics
#
# move objects up or down (within row space) depending on layout options.
# Be sure that the heights of all objects have been set.
# Float the floats
# The contents of a container may effect the container itself. Such as height; set that!
# Set any node heights that are % values.

getFlags(node) = isa(node, Text) ? node.parent.font.flags : node.shape.flags
#======================================================================================#
function FinalizeRow(row::Row)
    if row.flags[RowFinalized]
        return 0 # maybe this should return row.y (!?!)
    end



    vertHorizDisplacement(row)
    #..........................................
    # float LEFT: MoveNodeToLeft(row, index)
    #..........................................
    for i in 2:length(row.nodes)
        n = row.nodes[i]
        flags = getFlags(n)
        if flags[FloatLeft] && !flags[Absolute]
            w, h = getSize(n.shape) # we really only need width here.
            MoveAll(n, -(n.shape.left - row.nodes[1].shape.left) ,0.0)
            for j in 1:(i-1)
              MoveAll(row.nodes[j],w,0.0)
            end
            MoveNodeToLeft(row, i)
        end
    end
    #..........................................
    # float RIGHT: MoveNodeToRight(row, index)
    #..........................................
    for i in length(row.nodes):-1:1
        n = row.nodes[i]
        flags = getFlags(n)
        #shape = n.
        if flags[FloatRight] && !flags[Absolute]
            w, h = getSize(n.shape)
            for j in (i+1):length(row.nodes)
                row.nodes[j].shape.left -= w
            end
            wide,high = getSize(row.nodes[end].shape)
            n.shape.left = row.nodes[end].shape.left + wide + row.space
        end

end # for loop
    # Mark row as finalized!
    row.flags[RowFinalized] = true
    return row.top + row.height
end
# ======================================================================================
#
# ======================================================================================
function vertHorizDisplacement(row::Row)
    shiftAll = 0.0
    #..........................................
    # vertical/hirizintal shift
    #..........................................
        X = 0.0
  for i in 1:length(row.nodes)
      node = row.nodes[i]
      flags = getFlags(node) #node.parent.font.flags
      if !flags[Absolute]   # flags[Absolute] && return row.top + row.height
              shape = node.shape #.re ference
              Y = 0
              # set row height: this may need changed to take into account
              if !isa(shape, TextLine)
                  width, height = getSize(shape)
                  if height > row.height
                      row.height = height
                  end
              end

              if flags[TextCenter]
                      X = row.space * .5
              elseif flags[TextRight]
                      X = row.space
                      row.space = 0
              end

              if flags[AlignBase]
                  Y = (row.height - shape.height)
              end
                  # if !parent.shape.flags[FixedHeight]
                  #     parent.shape.height = parent.scroll.contentHeight
                  # end

              if flags[AlignMiddle]  &&  row.height > shape.height
                      Y::Float64 = (row.height - shape.height) *.5
              end

              MoveAll(row.nodes[i], X,Y)
      end # ! Absolute
  end
end
# ======================================================================================
# function rowSpaceToWidth(row, shape, width::Float64)
#     shape.width = width
#     row.space -= width
# end
# rowSpaceToWidth(row, shape) = rowSpaceToWidth(row, shape, row.space)

function PushToRow(document::Page, node, l::Float64,t::Float64,w::Float64) # height not needed
    parent = node.parent
    shape = node.shape
    width, height = getSize(shape)
    #rows = parent.rows
    row = getCreateLastRow(parent.rows, l, t, w) # return the last row (creatig one if nesesary).
    flags = node.shape.flags

    # Fixed /////////////////////////////////////////////////////
    # push to document instead of current parent! Fixed nodes' positions are
    # measured relative to the viewport, not any specific node.
    # TODO: I think Fixed nodes should be left in the tree where they belong but
    #       the document width and height should be fixed first (...not being updated).
    if flags[Fixed]
        row = getCreateLastRow(document.fixed.rows, l, t, w) # Not redundant: (attached to doc).
        setDistanceFromBounds(0,0,document.width, document.height,  shape )
        push!(row.nodes, node)
        return
    end
    # Absolute /////////////////////////////////////////////////////
    # The only way to set an Absolute position is to wait until
    # the parent's extents are calculated and set.
    if flags[Absolute]
        push!(row.nodes, node) # push to row but don't change any Row metrics
        return
    end
     # Inline /////////////////////////////////////////////////////
    if flags[DisplayInline]
        if flags[Marked]
            println("node.shape.width: ", node.shape.width)
            println("typeof(node.shape): ", typeof(node.shape))
            println("node.parent.shape.width: ", node.parent.shape.width)
        end
        shape.width = row.space
    end
    # InlineBlock /////////////////////////////////////////////////////
    if flags[DisplayInlineBlock] && shape.width < 1
        shape.width = parent.rows[end].space # parent.rows[end].width
    end
    # Block /////////////////////////////////////////////////////
    if flags[DisplayBlock]
        if length(row.nodes) > 0
            row = Row(parent)  #row = Row(rows, l, FinalizeRow(row), w)
        end
        shape.width < 1    &&    (shape.width = w - getPackingWidth(shape)) #- getWidth(shape) #(border.width + padding.width + margin.width)
        row.space = 0 # Make sure nothing else gets put on this row.
    elseif row.space < shape.width  # not enough space.. new row!
        row = Row(parent) # row = Row(rows, l, FinalizeRow(row), w)
    end

    feedRow(parent, node)
end
#======================================================================================#
#
#======================================================================================#

#======================================================================================#
#
#======================================================================================#

#======================================================================================#
