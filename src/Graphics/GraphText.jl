export    DrawText, DrawSelectedText, setTextContext, PushToRow, fontSlant, fontWeight
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
end# ======================================================================================
#  This is to tell text_extents() how to measure text
# ======================================================================================
function setTextContext(ctx::CairoContext, node::Text)
    font = node.parent.font
    slant  = fontSlant(font)
    weight = fontWeight(font)
    select_font_face(ctx, font.family, slant, weight);
    set_font_size(ctx, font.size);
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

      # force/empty this for now to avoid reinserting text copies.
      # Later this will have to be changed.

      if parent.shape.width < 1 && flags[DisplayInlineBlock]
          wide = parent.parent.rows[end].space #- getPackingWidth(parent.shape)
          #parent.shape.width = wide
      end


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
      # DisplayInlineBlock, DisplayInline
     # if parent.shape.width < 1 && (flags[DisplayInlineBlock] || flags[DisplayInline])
     #     wide = parent.parent.rows[end].space #- getPackingWidth(parent.shape)
     #     parent.shape.width = wide
     #     # if flags[DisplayInline] && totalWidth < wide
     #     #     #wide = totalWidth
     #     #     parent.shape.width = totalWidth
     #     #     node.shape.width = totalWidth
     #     # end
     #     # if flags[DisplayInline] && (totalWidth + getPackingWidth(parent.shape)) < wide
     #     #     node.shape.width = totalWidth
     #     # end
     #
     # end
      if flags[Marked] && flags[DisplayInline]
          println("DOM: ", parent.DOM[">"])
          println("parent.parent.rows[end].space: ", parent.parent.rows[end].space)
          #println("parent.rows[1].space: ", parent.rows[1].space)
          println("parent.shape.width: ", parent.shape.width)
          println("node.shape.width: ", node.shape.width)
          println("totalWidth: ", totalWidth)
          #println("parent.parent width: ", parent.parent.rows.space)
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
    row = getCreateLastRow(rows, l, t, w)

    if row.space < width
        row = Row(rows, l, FinalizeRow(row), w)
    end

    row.top == 0 && (row.top = t)
    setNodePosition(shape, row, row.left, width, height) # in LayoutBuild.jl
    push!(row.nodes, text)

end
# ======================================================================================
#
# ======================================================================================
function DrawSelectedText(ctx::CairoContext, nodeList, l,r,t,b, clipPath)
last = length(nodeList)
width,left = 0,0
allSelectedText = ""


    function PaintBox(ctx, color, l,t,r,b)
        setcolor( ctx, color...)
        rectangle(ctx,  l,t,r,b )
        fill(ctx)
    end

offset = 0
    for n in 1:last
        chunkStart, chunkEnd = 0,0
        s = nodeList[n].shape #n.shape
        setTextContext(ctx, nodeList[n]) # this is to tell text_extents() how to measure text

        # TODO: make this work when start and end are on the same line!
        if n == 1 # First selected line!
            offset = 0
            newLeft = 0
            start = l-s.left
            for i in 1:length(s.text)
                extents = text_extents(ctx, s.text[1:i] )[3];
                if extents < start
                    offset = i
                    newLeft = extents
                else
                    break
                end
            end
            allSelectedText *= s.text[offset+1:end] * "\n"
            left, width = s.left+newLeft,  s.width-newLeft
            if newLeft > 0 # how much to redraw before selection start
                color = inheritColor(nodeList[n].parent) #nodeList[n].parent.shape.color
                if length(color) == 0
                    color = [0,0,0]
                end
                PaintBox(ctx, color, s.left,  s.top, newLeft,  s.height)
            end
        elseif  n == last # Last selected line!
            newRight = 0
            offset = 0
            ending = r-s.left # actual selected width.
            for i in length(s.text):-1:1
                extents = text_extents(ctx, s.text[1:i] )[3];
                if extents > ending
                    offset = i
                    newRight = extents
                else
                    break
                end
            end

            allSelectedText *= s.text[1:offset] * "\n"
            left, width = s.left,  newRight
            if newRight > 0 # how much to redraw after selection end
                #chunkStart, chunkEnd = left+width, s.left+s.width
                color = inheritColor(nodeList[n].parent) #nodeList[n].parent.shape.color
                PaintBox(ctx, color, left+width,  s.top, s.width-width,  s.height+1)
            end
        else
            allSelectedText *= s.text * "\n"
            left, width = s.left,  s.width+1
        end
clipboard(allSelectedText)

        rectangle(ctx,  clipPath... )
        clip(ctx)
        # if chunkStart == 0 # how much to redraw before/after selection
        #     # this does not take into considderation the posibility that the parent could have an image, gradiant or transparency.
        #     # It may be best to redraw the parent and use this rectangle as a clipping area to reduce the time consumed.
        #     color = nodeList[n].parent.shape.color
        #     println(color)
        #
        #     PaintBox(ctx, color, chunkStart,  s.top, chunkEnd,  s.height+1)
        # end
        PaintBox(ctx, [0.956357, 0.95884, 0.188998], left,  s.top, width,  s.height+1)
        DrawText(ctx, nodeList[n], clipPath)
    end
end
# ======================================================================================
# Draw text.
# ======================================================================================
# -extents[4] is the top of the text
# ======================================================================================
function DrawText(ctx::CairoContext, node, clipPath)
    font = node.parent.font
    shape = node.shape
    #println(font.color)
    left = node.shape.left
    set_antialias(ctx,6)
    slant  = fontSlant(font)
    weight = fontWeight(font)
    select_font_face(ctx, font.family, slant, weight);
    set_font_size(ctx, font.size);

    if !font.flags[TextPath]
        move_to(ctx, shape.left, shape.top + font.size);
        setcolor(ctx, font.color...)
        show_text(ctx, shape.text);

    else  # shaddow
          move_to(ctx, shape.left+4, shape.top + font.size+4);
          text_path(ctx, shape.text);
          setcolor(ctx,  0,0,0,0.4) # fill color
          fill_preserve(ctx);
          setcolor(ctx,  0,0,0,0.1) # outline color
          set_line_width(ctx,  4 ); # 2.56 MyText.lineWidth
          stroke(ctx);

          move_to(ctx, shape.left+4, shape.top + font.size+4);
          text_path(ctx, shape.text);
          setcolor(ctx,  0,0,0,0.2) # fill color
          fill_preserve(ctx);
          setcolor(ctx,  0,0,0,0.1) # outline color
          set_line_width(ctx,  2 ); # 2.56 MyText.lineWidth
          stroke(ctx);

          move_to(ctx, shape.left, shape.top + font.size);
          text_path(ctx, shape.text);
          setcolor(ctx, font.fill...) # fill color
          fill_preserve(ctx);
          setcolor(ctx, font.color...) # outline color
          set_line_width(ctx, font.lineWidth ); # 2.56 MyText.lineWidth
          stroke(ctx);
    end
end
