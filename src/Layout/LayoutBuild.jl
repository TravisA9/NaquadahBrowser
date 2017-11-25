export setWindowSize, MoveAll, VmoveAllChildren,
        PushToRow, textToRows, FinalizeRow
# ======================================================================================
#
# ======================================================================================
function setWindowSize(w,h, n)
  n.shape = NBox()
     n.shape.color = [1,1,1]
     n.shape.padding = BoxOutline(0,0,0,0,0,0)
     n.shape.border = Border(0,0, 0,0, 0,0, "solid",[.5,.5,.5,1],[0,0,0,0])
     n.shape.left    = 0
     n.shape.top     = 0
     n.shape.width   = w # S hould be window width  - controls
     n.shape.height  = h # S hould be window height - controls
end
#======================================================================================#
function getShape(item)
      if isa(item, TextLine)
        return item
      else
        return item.shape
      end
end
#======================================================================================#
#thing,
#======================================================================================#
function FinalizeRow(row)
    if row.flags[RowFinalized] == true
        return 0
    end

    # move objects up or down (withing row space) depending on layout options.
    # Be sure that the heights of all objects have been set.
    # Float the floats
    # The contents of a container may effect the container itself. Such as height; set that!
    # Set any node heights that are % values.
  # thing.width
  shiftAll = 0
  #..........................................
  # vertical/hirizintal shift
  #..........................................
      X = 0
    for i in 1:length(row.nodes)
        item = row.nodes[i]
        Y = 0

        if isa(item, TextLine)
            shape = item.reference.shape
        else
            shape = item.shape
        end

        if shape.flags[Absolute] == false

        # set row height
        if shape.height > row.height
            width, height = getSize(shape)
            row.height = height
        end


                if shape.flags[TextCenter] == true
                    X = row.space * .5
                elseif shape.flags[TextRight] == true
                    X = row.space
                    row.space = 0
                end

                shape.flags[AlignBase]    &&  (Y = (row.height - shape.height))
                if shape.flags[AlignMiddle]  &&  row.height > shape.height
                    Y = (row.height - shape.height) *.5
                end


              MoveAll(row.nodes[i], X,Y)
      end
      end

    #..........................................
    # float LEFT: MoveNodeToLeft(row, index)
    #..........................................
    for i in 2:length(row.nodes)
        # item = row.nodes[i].shape
          shape = getShape(row.nodes[i])
        if shape.flags[FloatLeft] == true && shape.flags[Absolute] == false
            w, h = getSize(shape)
            s = getShape(row.nodes[1])
            MoveAll(row.nodes[i], -(shape.left - s.left) ,0)
            for j in 1:(i-1)
              MoveAll(row.nodes[j],w,0)
            end
            MoveNodeToLeft(row, i)
        end
    end
    #..........................................
    # float RIGHT: MoveNodeToRight(row, index)
    #..........................................
    for i in length(row.nodes):-1:1
      # row.space
      shape = getShape(row.nodes[i])
        if shape.flags[FloatRight] == true && shape.flags[Absolute] == false
            w, h = getSize(shape)
            for j in (i+1):length(row.nodes)
                row.nodes[j].shape.left -= w
            end
            wide,high = getSize(row.nodes[end].shape)
            shape.left = row.nodes[end].shape.left + wide + row.space
        end
    end

    # Mark row as finalized!
    row.flags[RowFinalized] = true

    return row.y + row.height
end













# ======================================================================================
# PushToRow(document, Current node, the shape, (bounds->) l,t,w,h)
# ======================================================================================
function PushToRow(document, node, thing, l,t,w) # height not needed
 #temp = node.shape
      shape = getShape(thing)
      width, height = getSize(shape)
      rows = node.rows
      row = LastRow(rows, l, t, w) #rows[end]



    # Fixed /////////////////////////////////////////////////////
    # push to document instead of current node! Fixed nodes' positions are
    # measured relative to the viewport, not any specific node.
    if shape.flags[Fixed] == true
        rows = document.fixed.rows
        row = LastRow(rows, l, t, w)
                  canvas = document.canvas
                  if shape.flags[Bottom] == true
                          h = document.height # height(canvas)
                          shape.top =  h - (shape.top + height)
                  else
                          shape.top =  h + shape.top
                  end
                  if shape.flags[Right] == true
                          w = document.width # width(canvas)
                          shape.left =  w - (shape.left + width)
                  else
                          shape.left =  w + shape.left
                  end
                    push!(row.nodes, thing)
                    return
    end
    # Absolute /////////////////////////////////////////////////////
    # I think the only way to set an Absolute position is to wait until the parent is totaly finished
     if shape.flags[Absolute] == true
                 node.shape.flags[HasAbsolute] = true
                 ## push to row but do not change any Row metrics
                 push!(row.nodes, thing)
                 return
     end

     # Inline /////////////////////////////////////////////////////
     if shape.flags[DisplayInline] == true
         # TODO: there is a problem! I have the width arbitrarily set because a button
         #       does not have a width even though it has a child. The error must be
         #       somewhere else! ...I think.
             shape.width = 25
             padding, border, margin = getReal(shape)
             width = shape.width + (border.width + padding.width + margin.width)
             # row.height < height && (row.height = height)
             # row.y == 0 && (row.y = t)
             setNodePosition(shape, row, row.x, width, height)
             push!(row.nodes, thing)
             return
     end
    # InlineBlock /////////////////////////////////////////////////////
    if shape.flags[DisplayInlineBlock] == true && shape.width < 1
               w = node.rows[end].width
              # scroll.contentWidth
               shape.width = w
               push!(row.nodes, thing)
               setNodePosition(shape, row, row.x, w)
               return
        # else not enough space
    end
    # Block /////////////////////////////////////////////////////
    if shape.flags[DisplayBlock] == true
                if length(row.nodes) > 0
                    row = Row(rows, l, FinalizeRow(row), w)
                    #row = Row(rows, l, row.y + row.height, w)
                end
                padding, border, margin = getReal(shape)
            if shape.width < 1
                shape.width = w - (border.width + padding.width + margin.width)
            end

                #row.height < height && (row.height = height)
                row.y == 0 && (row.y = t)
                b = get(shape.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
                setNodePosition(shape, row, row.x, width, height)
                row.space = 0
                push!(row.nodes, thing)
                return
        else # not enough space.. new row!
            if row.space < width
                row = Row(rows, l, FinalizeRow(row), w)
            end
        end

    #row.height < height && (row.height = height)
    row.y == 0 && (row.y = t)
    setNodePosition(shape, row, row.x, width, height)
    push!(row.nodes, thing)

end


#======================================================================================#
#
#======================================================================================#
function setRowMetrics(shape, row, x)

end
#======================================================================================#
function setNodePosition(shape, row, x, width, height=0)
        if !isa(shape, TextLine)
            c = get(shape.padding, BoxOutline(0,0,0,0,0,0))
            b = get(shape.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
            m = get(shape.margin,  BoxOutline(0,0,0,0,0,0))


            # OffsetX, OffsetY = contentOffset( getReal(shape)... )
            OffsetX, OffsetY = contentOffset( c, b, m )
            shape.top = row.y + OffsetY
            shape.left = x + OffsetX
        else
            shape.top = row.y
            shape.left = x
        end
        row.space -= width
        row.x += width
        row.height < height && (row.height = height)
end
#======================================================================================#
function MoveNodeToLeft(row, index)
  node = row.nodes[index]
  for n in index:-1:2
    row.nodes[n] = row.nodes[n-1]
  end
  row.nodes[1] = node
end
#======================================================================================#
function MoveNodeToRight(row, index)
  node = row.nodes[index]
  for n in index:length(row.nodes)-1
    row.nodes[n] = row.nodes[n+1]
  end
  row.nodes[end] = node
end
#======================================================================================#
#    Similar to MoveAll() in LayoutBuild.jl
#======================================================================================#
function VmoveAllChildren(node, y, moveNode)
  shape = getShape(node)
  if shape.flags[Fixed] == true
    return
  end
  if moveNode == true
      shape.top  += y
  end
    if isdefined(node, :rows) # ..it has rows of children so let's move them!
      for i in 1:length(node.rows)
        row = node.rows[i]
        row.y += y
        for j in 1:length(row.nodes)
            VmoveAllChildren(row.nodes[j],y, true) # do the same for each child
        end
      end
    end
end
#======================================================================================#
#    This is only to translate a shape with all children by x,y
#    It may also be nesesary to move the node to another location in its row!
#======================================================================================#
function MoveAll(node,x,y)
  shape = getShape(node)
  if shape.flags[Fixed] == true
    return
  end
  shape.left += x # Move this object!
  shape.top  += y
    if isdefined(node, :rows) # ..it has rows of children so let's move them!
      for i in 1:length(node.rows)
        row = node.rows[i]
        row.x += x # ...don't forget to move the actual row
        row.y += y
        for j in 1:length(row.nodes)
            MoveAll(row.nodes[j],x,y) # do the same for each child
        end
      end
    end
end
#======================================================================================#
#======================================================================================#
function LineBreak(node) # .rows, parentArea
    row = node.rows[end]
    box = getContentBox(node.shape, getReal(node.shape)... )
    l, t, w, h = box
    #FinalizeRow(row)
    #return Row(node.rows,  l,  row.y + row.height,  w)
    return row = Row(rows, l, FinalizeRow(row), w)
end
#======================================================================================#
#
#======================================================================================#
function fontSlant(shape)
    if shape.flags[TextItalic] == true
        return Cairo.FONT_SLANT_ITALIC
    elseif shape.flags[TextOblique] == true
        return Cairo.FONT_SLANT_OBLIQUE
    else
        return Cairo.FONT_SLANT_NORMAL
    end
end
#======================================================================================#
function fontWeight(shape)
    if shape.flags[TextBold] == true
        return Cairo.FONT_WEIGHT_BOLD
    else
        return Cairo.FONT_WEIGHT_NORMAL
    end
end
#======================================================================================#
# TODO: simplify / clean up
#======================================================================================#
function textToRows(document, node, MyText, l, t, wide) # .rows, parentArea
    if wide == 0
        wide = node.parent.shape.width
    end
      shape = node.shape
      MyTextShape = MyText.shape
      c = CairoRGBSurface(0,0);
      ctx = CairoContext(c);
      slant  = fontSlant(MyTextShape)
      weight = fontWeight(MyTextShape)
      select_font_face(ctx, MyTextShape.family, slant, weight);
      set_font_size(ctx, MyTextShape.size);

      # when we want to add text to a row that already has content
      rows = node.rows
      if length(rows) == 0 # no row!
        Row(rows, l, t, wide)
      end
      row = rows[end]
      if length(row.nodes) > 0 # Already has nodes!
          lineWidth = row.space
          lineLeft = row.x
          isPartRow = true
      else
          lineWidth = wide
          lineLeft = l
          isPartRow = false
      end


     # set up some variables to get started
     lines = []
     lastLine = ""
     lineTop = t + MyTextShape.size # Because text is drawn above the line!
     words = split(MyTextShape.text, r"(?<=.)(?=[\s])")
     # split(MyTextShape.text) # TODO: this needs improved!
     line = words[1]


     firstWordWidth = text_extents(ctx, line )[3]
     if firstWordWidth > lineWidth
         Row(rows,  l,  FinalizeRow(row),  wide)
     end




    for w in 2:length(words)
        lastLine = line
        line = lastLine * words[w]
        extetents = text_extents(ctx,line )
        # long enough ...cut!
        if extetents[3] >= lineWidth
            lastLine = split(lastLine, r"^[\s]+")[end]

            textWidth = text_extents(ctx, lastLine )[3]
            textLine = TextLine(MyText, lastLine, lineLeft,   0, textWidth, MyTextShape.height)
            #          TextLine(MyText,     text,     left, top,     width, height)
            pushText(document, node, textLine, l, t, wide)
            line = words[w]
            # reset default values
            if isPartRow == true
                lineWidth = wide
                lineLeft = l
                isPartRow = false
            end
        end

    end
    # Make sure we flush out the last row!
    line = split(line, r"^[\s]+")[end]

    textWidth = text_extents(ctx,line )[3]
    textLine = TextLine(MyText, line, lineLeft, 0, textWidth, MyTextShape.height)
    pushText(document, node, textLine, l, t, wide)
end
#======================================================================================#
# TODO: simplify / clean up
#======================================================================================#
function pushText(document, node, thing, l,t,w) # height not needed
       shape = getShape(thing)
      width, height = getSize(shape)
      rows = node.rows
      row = LastRow(rows, l, t, w)

      if row.space < width
          row = Row(rows, l, FinalizeRow(row), w)
      end

    #row.height < height && (row.height = height)
    row.y == 0 && (row.y = t)

    setNodePosition(shape, row, row.x, width, height)
    push!(row.nodes, thing)

end
