export setUpWindow, MoveAll, VmoveAllChildren,
        PushToRow, FinalizeRow
# ======================================================================================
#
"""
## Types exported from Graphics

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
# ======================================================================================
function setUpWindow(document::Page, w::Float64,h::Float64)

    println("W: $(w), H: $(h)")


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
"""
## Types exported from Graphics

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
function getShape(item)
      if isa(item, TextLine)
        return item
      else
        return item.shape
      end
end
#======================================================================================#
#thing,
"""
## Types exported from Graphics

move objects up or down (withing row space) depending on layout options.
Be sure that the heights of all objects have been set.
Float the floats
The contents of a container may effect the container itself. Such as height; set that!
Set any node heights that are % values.


# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
#======================================================================================#
function FinalizeRow(row::Row)
    if row.flags[RowFinalized] == true
        return 0 # maybe this should return row.y (!?!)
    end

  shiftAll = 0.0
  #..........................................
  # vertical/hirizintal shift
  #..........................................
      X = 0.0
    for i in 1:length(row.nodes)
        item = row.nodes[i]
        Y = 0

        if isa(item, TextLine)
            shape = item.reference.shape
        else
            shape = item.shape
        end

        if shape.flags[Absolute] == false

        # set row height: this may need changed to take NText into account
        if !isa(shape, NText)
            width, height = getSize(shape)
            if height > row.height
                row.height = height
            end
        end


                if shape.flags[TextCenter] == true
                    X = row.space * .5
                elseif shape.flags[TextRight] == true
                    X = row.space
                    row.space = 0
                end
                if isa(item, TextLine)
                    node = item.reference
                    #f = node.parent.shape.flags
                    #println("one: ", f)
                else
                    node = item
                    #f = node.parent.shape.flags
                    #println("two: ", f)
                end
                #node.parent.shape.flags[AlignBase]    &&  (Y = (row.height - shape.height))
                if node.parent.shape.flags[AlignBase] == true
                    Y = (row.height - shape.height)
                    #println("AlignBase: $Y")
                end
                # if parent.shape.flags[FixedHeight] == false
                #     parent.shape.height = parent.scroll.contentHeight
                # end

                #shape.flags[AlignBase]    &&  (Y = (row.height - shape.height))
                if shape.flags[AlignMiddle]  &&  row.height > shape.height
                    Y::Float64 = (row.height - shape.height) *.5
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
            MoveAll(row.nodes[i], -(shape.left - s.left) ,0.0)
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
"""
## Types exported from Graphics

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Layout/LayoutBuild.jl#L203)
"""
# ======================================================================================
function PushToRow(document::Page, node::Element, thing, shape, l::Float64,t::Float64,w::Float64) # height not needed
 #temp = node.shape ::Draw
 #length(thing.children) > 0   &&   Row(thing.rows, l,t,w)
      # shape = getShape(thing)
      width::Float64, height::Float64 = getSize(shape)
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
function setRowMetrics(shape::Draw, row::Row, x)

end
#======================================================================================#
"""
## Types exported from Graphics

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
function setNodePosition(shape::Draw, row::Row, x::Float64, width::Float64, height::Float64=0.0)

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
"""
## Types exported from Graphics

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
function MoveNodeToLeft(row::Row, index::Int64)
  node = row.nodes[index]
  for n in index:-1:2
    row.nodes[n] = row.nodes[n-1]
  end
  row.nodes[1] = node
end
#======================================================================================#
function MoveNodeToRight(row::Row, index::Int64)

  node = row.nodes[index]
  for n in index:length(row.nodes)-1
    row.nodes[n] = row.nodes[n+1]
  end
  row.nodes[end] = node
end
#======================================================================================#
#    Similar to MoveAll() in LayoutBuild.jl
"""
## Types exported from Graphics

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
#======================================================================================#
# may be: TextLine -or- Element
function VmoveAllChildren(node, y::Float64, moveNode::Bool)

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
"""
## Types exported from Graphics

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
#======================================================================================#
# may be: TextLine -or- Element
function MoveAll(node, x::Float64, y::Float64)
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
"""
## Types exported from Graphics

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
#======================================================================================#
function LineBreak(node::Element) # .rows, parentArea
    row = node.rows[end]
    box = getContentBox(node.shape, getReal(node.shape)... )
    l, t, w, h = box
    return row = Row(rows, l, FinalizeRow(row), w)
end
#======================================================================================#
#
"""
## Types exported from Graphics

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
#======================================================================================#
function fontSlant(shape::NText)
    if shape.flags[TextItalic] == true
        return Cairo.FONT_SLANT_ITALIC
    elseif shape.flags[TextOblique] == true
        return Cairo.FONT_SLANT_OBLIQUE
    else
        return Cairo.FONT_SLANT_NORMAL
    end
end
#======================================================================================#
function fontWeight(shape::NText)
    if shape.flags[TextBold] == true
        return Cairo.FONT_WEIGHT_BOLD
    else
        return Cairo.FONT_WEIGHT_NORMAL
    end
end
#======================================================================================#
# TODO: simplify / clean up
"""
## PushToRow(document::Page, node::Element, MyText::Element, shape::NText, l::Float64, t::Float64, wide::Float64)

Push text to rows.

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
##======================================================================================#
#function textToRows(document::Page, node::Element, MyText::Element, l::Float64, t::Float64, wide::Float64) # .rows, parentArea
function PushToRow(document::Page, node::Element, MyText::Element, shape::NText, l::Float64, t::Float64, wide::Float64) # .rows, parentArea
    if wide == 0
        wide = node.parent.shape.width
    end

      c = CairoRGBSurface(0,0);
      ctx = CairoContext(c);
      slant  = fontSlant(shape)
      weight = fontWeight(shape)
      select_font_face(ctx, shape.family, slant, weight);
      set_font_size(ctx, shape.size);

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
     #lineTop = t + shape.size # Because text is drawn above the line!
     words = split(shape.text, r"(?<=.)(?=[\s])")
     # split(shape.text) # TODO: this needs improved!
     line = words[1]


     firstWordWidth = text_extents(ctx, line )[3]
     #firstWordHeight = text_extents(ctx, line )[4]

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
            textLine = TextLine(MyText, lastLine, lineLeft,   0, textWidth, shape.height)
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
    textLine = TextLine(MyText, line, lineLeft, 0, textWidth, shape.height)
    pushText(document, node, textLine, l, t, wide)
end
#======================================================================================#
# TODO: simplify / clean up
"""
## pushText(document::Page, node::Element, thing::TextLine, l::Float64,t::Float64,w::Float64)

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
#======================================================================================#
function pushText(document::Page, node::Element, thing::TextLine, l::Float64,t::Float64,w::Float64) # height not needed

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
