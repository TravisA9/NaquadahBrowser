export  textWidth, DrawText, DrawSelectedText, setTextContext,
        PushToRow, fontSlant, fontWeight
#======================================================================================#
#
#======================================================================================#
function fontSlant(shape::Font)
    if shape.flags[TextItalic]
        return Cairo.FONT_SLANT_ITALIC
    elseif shape.flags[TextOblique]
        return Cairo.FONT_SLANT_OBLIQUE
    else
        return Cairo.FONT_SLANT_NORMAL
    end
end
#======================================================================================#
function fontWeight(shape::Font)
    if shape.flags[TextBold]
        return Cairo.FONT_WEIGHT_BOLD
    else
        return Cairo.FONT_WEIGHT_NORMAL
    end
end# ======================================================================================
#  This is to tell text_extents() how to measure text
# ======================================================================================
function setTextContext(ctx::CairoContext, node::TextElement)
    font = node.parent.font
    slant  = fontSlant(font)
    weight = fontWeight(font)
    select_font_face(ctx, font.family, slant, weight);
    set_font_size(ctx, font.size);
end
#======================================================================================#
function TextWidth(node::TextElement)
    ctx = CairoContext( CairoRGBSurface(0,0) )
    setTextContext(ctx, node)
    return text_extents(ctx, node.shape.text )[3]
end
#======================================================================================#
# TODO: simplify / clean up
# Called from: LayoutBegin.jl ~30
# PushToRow(document, node, l,t,w)
# l,t,w   define the content area of the parent
##======================================================================================#
function PushToRow(document::Page, node::TextElement, l::Float64, t::Float64, wide::Float64)
    #set up all variables...
    text = node.shape.text # Entire unbroken string
    ctx = CairoContext( CairoRGBSurface(0,0) )
    setTextContext(ctx, node)
    fontheight = text_extents(ctx, text )[4]
    # clean out old text.
    node.parent.rows = []

    function textToNode(line, textWidth)
        parent = node.parent # This would be like say a 'p' element
        textLine = TextLine(parent, line, l, t, textWidth, parent.font.lineHeight*fontheight)
        textNode = TextElement(parent, textLine)
        flags = getFlags(parent)
        feedRow(parent, textNode)
    end

    ls = split(text, r"[\r\n]+")
    # vcat([ i.match.offset+1 for i in eachmatch(r"[\r\n]*", text)], length(text))
    for lines in ls
         # TODO: make faster.
         breaks = vcat([ i.match.offset+1 for i in eachmatch(r" ", lines)], length(lines))
         lastbreak = 1
         lineWidth = wide
         if length(breaks) > 1
             for i in 2:length(breaks)
                 extetents = text_extents(ctx, lines[lastbreak:breaks[i]])
                 if extetents[3] >= lineWidth # Too long ...cut!
                     brk = breaks[i-1]
                     line = lines[lastbreak:brk]
                     textToNode(line, text_extents(ctx, line)[3])
                     lastbreak = brk
                     lineWidth = wide
                 end
             end
         end
         line = lines[lastbreak:length(lines)]
         textToNode(line, text_extents(ctx,line )[3])
         Row(node.parent)
     end


     destroy(ctx)
end
# ======================================================================================
#
# ======================================================================================
function DrawSelectedText(ctx::CairoContext, nodeList::Array{Any,1}, l::Float64,r::Float64,t::Float64,b::Float64) #, clipPath

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

        # rectangle(ctx,  clipPath... )
        # clip(ctx)
        #
        # reset_clip(ctx)
    end
end
# ======================================================================================
# Draw text.
# ======================================================================================
# -extents[4] is the top of the text
# ======================================================================================
function DrawText(ctx::CairoContext, node::TextElement) # , clipPath
    font = node.parent.font
    shape = node.shape
    left = node.shape.left
    set_antialias(ctx,6)
    slant  = fontSlant(font)
    weight = fontWeight(font)
    select_font_face(ctx, font.family, slant, weight);
    set_font_size(ctx, font.size);
    text = shape.text


# Trim leading space because it causes text to be offset.
if length(text)>0 && text[1] == ' '
    text = text[2:end]
end

    if !font.flags[TextPath]
        move_to(ctx, shape.left, shape.top + font.size);
        setcolor(ctx, font.color...)
        show_text(ctx, text);

    else  # shaddow
          move_to(ctx, shape.left+4, shape.top + font.size+4);
          text_path(ctx, text);
          setcolor(ctx,  0,0,0,0.4) # fill color
          fill_preserve(ctx);
          setcolor(ctx,  0,0,0,0.1) # outline color
          set_line_width(ctx,  4 ); # 2.56 MyText.lineWidth
          stroke(ctx);

          move_to(ctx, shape.left+4, shape.top + font.size+4);
          text_path(ctx, text);
          setcolor(ctx,  0,0,0,0.2) # fill color
          fill_preserve(ctx);
          setcolor(ctx,  0,0,0,0.1) # outline color
          set_line_width(ctx,  2 ); # 2.56 MyText.lineWidth
          stroke(ctx);

          move_to(ctx, shape.left, shape.top + font.size);
          text_path(ctx, text);
          setcolor(ctx, font.fill...) # fill color
          fill_preserve(ctx);
          setcolor(ctx, font.color...) # outline color
          set_line_width(ctx, font.lineWidth ); # 2.56 MyText.lineWidth
          stroke(ctx);
    end

end
