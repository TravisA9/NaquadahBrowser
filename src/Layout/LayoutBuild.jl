export setUpWindow, PushToRow, FinalizeRow, fontSlant, fontWeight
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

  shiftAll = 0.0
  #..........................................
  # vertical/hirizintal shift
  #..........................................
      X = 0.0
    for i in 1:length(row.nodes)
        node = row.nodes[i]
        shape = node.shape #.re ference
        Y = 0

        flags = getFlags(node) #node.parent.font.flags


        if !flags[Absolute]

            # set row height: this may need changed to take  into account
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
          end
      end

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
    end

    # Mark row as finalized!
    row.flags[RowFinalized] = true

    return row.top + row.height
end
# ======================================================================================
# Types exported from Graphics
# ======================================================================================
# From: CreateLayoutTree in LayoutBegin.jl
# ======================================================================================
function PushToRow(document::Page, node, l::Float64,t::Float64,w::Float64) # height not needed
    parent = node.parent
    shape = node.shape
    width, height = getSize(shape)
    rows = parent.rows
    row = LastRow(rows, l, t, w) # return the last row (creatig one if nesesary).
    flags = node.shape.flags

    # Fixed /////////////////////////////////////////////////////
    # push to document instead of current parent! Fixed nodes' positions are
    # measured relative to the viewport, not any specific node.
    # TODO: I think Fixed nodes should be left in the tree where they belong but
    #       the document width and height should be fixed first (...not being updated).
    if flags[Fixed]
        rows = document.fixed.rows
        row = LastRow(rows, l, t, w)
                  canvas = document.canvas
                  if flags[Bottom]
                          h = document.height # height(canvas)
                          shape.top =  h - (shape.top + height)
                  else
                          shape.top =  h + shape.top
                  end
                  if flags[Right]
                          w = document.width # width(canvas)
                          shape.left =  w - (shape.left + width)
                  else
                          shape.left =  w + shape.left
                  end
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
         shape.width = row.space
     end
    # InlineBlock /////////////////////////////////////////////////////
    if flags[DisplayInlineBlock] && shape.width < 1
               w = parent.rows[end].width
               shape.width = w
    end
    # Block /////////////////////////////////////////////////////
    if flags[DisplayBlock]
            length(row.nodes) > 0    &&    (row = Row(rows, l, FinalizeRow(row), w))
            shape.width < 1    &&    (shape.width = w) #- getWidth(shape) #(border.width + padding.width + margin.width)
            row.space = 0 # Make sure nothing else gets put on this row.
    else # not enough space.. new row!
        row.space < width    &&    (row = Row(rows, l, FinalizeRow(row), w))
    end

    #row.height < height && (row.height = height)
    row.top == 0 && (row.top = t)
    push!(row.nodes, node)
    setNodePosition(shape, row, row.left, width, height)

end
#======================================================================================#
# Types exported from Graphics
#======================================================================================#
function setNodePosition(shape::Draw, row::Row, x::Float64, width::Float64, height::Float64=0.0)
    if !isa(shape, TextLine)
        OffsetX, OffsetY = contentOffset( shape )
        shape.top = row.top + OffsetY
        shape.left = x + OffsetX
    else
        shape.top = row.top
        shape.left = x
    end
        row.space -= width
        row.left += width
        row.height < height && (row.height = height)
end
#======================================================================================#
## Types exported from Graphics
#======================================================================================#
function LineBreak(node::Element) # .rows, parentArea
    row = node.rows[end]
    box = getContentBox(node.shape, getReal(node.shape)... )
    l, t, w, h = box
    return row = Row(rows, l, FinalizeRow(row), w)
end
#======================================================================================#
#
#======================================================================================#
function fontSlant(shape)
    if shape.flags[TextItalic]
        return Cairo.FONT_SLANT_ITALIC
    elseif shape.flags[TextOblique]
        return Cairo.FONT_SLANT_OBLIQUE
    else
        return Cairo.FONT_SLANT_NORMAL
    end
end
#======================================================================================#
function fontWeight(shape)
    if shape.flags[TextBold]
        return Cairo.FONT_WEIGHT_BOLD
    else
        return Cairo.FONT_WEIGHT_NORMAL
    end
end
#======================================================================================#
# TODO: simplify / clean up
# Called from: LayoutBegin.jl ~30
# PushToRow(document, node, l,t,w)
##======================================================================================#
function PushToRow(document::Page, node::Text, l::Float64, t::Float64, wide::Float64)
    parent = node.parent # This would be like say a 'p' element
    font = parent.font
    text = node.shape.text # Entire unbroken string
    flags = parent.shape.flags
    ctx = CairoContext( CairoRGBSurface(0,0) )
    setTextContext(ctx, node)
    totalWidth = text_extents(ctx, text )[3]

if flags[Marked]
    println("width: ", parent.shape.width)
    println(" flags[DisplayInlineBlock]: ", flags[DisplayInlineBlock])
    println(" flags[DisplayBlock]: ", flags[DisplayBlock])
    println(" flags[DisplayInline]: ", flags[DisplayInline])
end

    # if wide == 0
    #     if parent.shape.width == 0
    #         row = parent.parent.rows[end]
    #         if row.space == 0
    #             top = FinalizeRow(row)
    #             pLeft, pTop = contentOffset(parent.shape)
    #             ppLeft, ppTop = contentOffset(parent.parent.shape)
    #             row = Row(parent.parent.rows, parent.parent.shape.left, top, parent.parent.shape.width)
    #             parent.shape.width = row.space
    #         else
    #             parent.shape.width = row.space # get container width f not set
    #             row.space = 0
    #         end
    #     end
    #     wide = parent.shape.width # get container width f not set
    #     if flags[DisplayInlineBlock] || flags[DisplayBlock]
    #         if totalWidth < wide
    #             parent.shape.width = totalWidth
    #             wide = totalWidth
    #         end
    #     end
    # end


      # force/empty this for now to avoid reinserting text copies.
      # Later this will have to be changed.
      parent.rows = []
      # when we want to add text to a row that already has content
      rows = parent.rows
      if length(rows) == 0 # no row!
          Row(rows, l, t, wide)
      end
      row = rows[end]
      if length(row.nodes) > 0 # Already has nodes!
          lineWidth = row.space
          lineLeft = row.left
          isPartRow = true
      else
          lineWidth = wide
          lineLeft = l
          isPartRow = false
      end

     # set up some variables to get started
     lines = []
     lastLine = "" #lineTop = t + shape.size # Because text is drawn above the line!
     words = split(text, r"(?<=.)(?=[\s])") # split(shape.text) # TODO: this needs improved!
     line = words[1]
     firstWordWidth = text_extents(ctx, line )[3] #
     fontheight = text_extents(ctx, line )[4]
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
            # font = re ference ...which should eventually/soon be removed!
            textLine = TextLine(parent, lastLine, lineLeft, 0, textWidth, font.lineHeight*fontheight)
            textNode = Text(parent, textLine)
            pushText(document, parent, textNode, l, t, wide)
            line = words[w]
            # reset default values
            if isPartRow
                lineWidth = wide
                lineLeft = l
                isPartRow = false
            end
        end

    end
    # Make sure we flush out the last row!
    line = split(line, r"^[\s]+")[end]

    textWidth = text_extents(ctx,line )[3]
    textLine = TextLine(parent, line, lineLeft, 0, textWidth, font.lineHeight*fontheight)
    textNode = Text(parent, textLine)
    pushText(document, parent, textNode, l, t, wide) #    pushText(document, parent, Text(textLine), l, t, wide)
end
#======================================================================================#
# TODO: simplify / clean up
##
#======================================================================================#
function pushText(document::Page, node::Element, text::Text, l::Float64,t::Float64,w::Float64) # height not needed

    shape = text.shape
    width, height = getSize(shape)
    rows = node.rows
    row = LastRow(rows, l, t, w)

    if row.space < width
        row = Row(rows, l, FinalizeRow(row), w)
    end

    row.top == 0 && (row.top = t)
    setNodePosition(shape, row, row.left, width, height)
    push!(row.nodes, text)

end
