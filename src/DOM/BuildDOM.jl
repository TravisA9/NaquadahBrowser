#======================================================================================#
# traceElementTree()
# CalculateElements()
# BoxDesign()
# LayoutInner()
# MakeRelative()
# MakeFixed()


#======================================================================================#
# xmin left   top top   width width   height height box area text-color
# ======================================================================================
# Recursively read Dict(data) and build DOM Tree
# CALLED FROM: DrawPage.jl  -->  DrawPage()
# this could be called BuildLayoutTree
# ======================================================================================
function traceElementTree(document::Page,parent::MyElement, DOM::Dict, depth::Int64)
        if isa(DOM["nodes"], Array)

            DOM_nodes = DOM["nodes"]
            parent.x      = 0
            parent.y      = 0
            parent.contentHeight = 0
            for i in eachindex(DOM_nodes)
                    CreateDefaultNode(document, parent, DOM_nodes[i]) # ...line 400
                        node = parent.node[end]
                    # Map horizontally into layout ...Then vertically.
                      CalculateElements(document, node, i )
                    # Instantiate Children
                    if haskey(DOM_nodes[i], "nodes")
                        traceElementTree(document, node ,DOM_nodes[i], depth + 1)
                    end
            end
        end
end
# ======================================================================================
# Flush out remaining row data
# CALLED FROM:
# TODO: add a variable indicating how much space is left and do floats
# ======================================================================================
function dumpRow(parent,node,startnewrow::Bool)
    row = parent.rows[end]
    floatlefts = []
    floatrights = []
    # parent.contentHeight += row.height
    # This is to set all nodes' heights and find/set the row height
        for k = 1:length(row.nodes)
            CalculateElementsV(row.nodes[k], parent.y)
             SetNodeTop(row.nodes[k],parent.y)
        end
     #row.y = parent.y + row.height
     parent.contentHeight = 0
     for j = 1:length(parent.rows)

         parent.contentHeight += parent.rows[j].height
         #CalculateElementsV(row.nodes[k], parent.y)
     end
    #parent.contentHeight += row.height
    # mark row as having been completed
    row.flags[IncompleteRow] = false

end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function AddRow(parent,node,startnewrow::Bool)
    row = parent.rows[end]
    floatlefts = []
    floatrights = []
    # float'em Left.......................................................
    if row.flags[RowHasFloatLeft] == true
            for i = 1:length(row.nodes)
                if row.nodes[i].flags[FloatLeft] == true
                  push!(floatlefts,i)
                end
            end

            for j = 1:length(floatlefts)
              FloatNodeLeft(row, floatlefts[j])
            end
    end
    # float'em Right.......................................................
    if row.flags[RowHasFloatRight] == true
            for i = 1:length(row.nodes)
                if row.nodes[i].flags[FloatRight] == true
                  push!(floatrights,i)
                end
            end

            for j = 1:length(floatrights)
              FloatNodeRight(row, floatrights[j])
            end
    end

    # This is to set all nodes' heights and find/set the row height
        for k = 1:length(row.nodes)
          thisNode = row.nodes[k]
            CalculateElementsV(thisNode, parent.y)
            SetNodeTop(thisNode,parent.y)
        end
     row.y = parent.y + row.height

     if row.height == 0 # node.parent.rows[end].y == 0
       println("row.height: ", row.height)
     end


    # parent.contentHeight += row.height
    # mark row as having been completed
    row.flags[IncompleteRow] = false

    #...........................................................................
    # New row............
    if startnewrow == true
        push!(parent.rows,Row()) # push new row to parent
        newRow = parent.rows[end]
        newRow.height = 0
        parent.x = 0
        parent.y += row.height
        newRow.y = parent.y
        # Mark new row as incomplete
        newRow.flags[IncompleteRow] = true
    end

end
# ======================================================================================
# Inteded to be called recursively on any element to map tree for drawing
# CALLED FROM: Above traceElementTree()
# TODO: Clean this up!
# ======================================================================================
function CalculateElementsV(node::MyElement, y::Float32)
  parent = node.parent

  node.area.top = y
  margin  = get(node.margin,MyBox(0,0,0,0,0,0))
  #border  = get(node.border,Border(0,0, 0,0, 0,0,0, [],[]))
  border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
 padding = get(node.padding,MyBox(0,0,0,0,0,0))
  # HEIGHT...... There should be a condition here since some elements have a set height.
      node.box.top          =   y            + margin.top  + border.top
      node.content.top      =   node.box.top + padding.top
      node.y                =   node.box.top + padding.top

      node.box.height       =   node.area.height - margin.height  - border.height
      node.content.height   =   node.box.height  - padding.bottom - padding.top

      if !isnull(node.text) && haskey(node.DOM, "text")
         textHeight = calculateTextArea(node)

         # Reset node Height
         # TODO: make it reset height Only if needed
         if textHeight > node.content.height && node.flags[InlineBlock] == false
           node.content.height   = textHeight
           node.box.height       = node.content.height + padding.top + padding.bottom
           node.area.height      = node.box.height     + margin.top  + margin.bottom

         end
      end

      if node.contentHeight > 0
          margin  = get(node.parent.margin,MyBox(0,0,0,0,0,0))
          border  = get(node.parent.border, Border(0,0,0,0,0,0,"None",[],[]))
          padding = get(node.parent.padding,MyBox(0,0,0,0,0,0))
           node.content.height = node.contentHeight
           node.box.height     = node.contentHeight + padding.height
           node.area.height    = node.box.height    + margin.height  + border.height
      end
      if node.flags[HasVscroll] == true && node.box.height == 0
        node.box.left = parent.box.width
        node.box.top = parent.box.top
        node.box.width = node.area.width
        node.box.height = parent.box.height
      end
      if node.flags[HasHscroll] == true && node.box.height == 0
        node.box.left = parent.box.left
        node.box.top = parent.box.height
        node.box.width = parent.box.width
        node.box.height = node.area.height
      end
      row = parent.rows[end]
      if node.area.height > row.height
          row.height = node.area.height
      end

end
# ======================================================================================
# Inteded to be called recursively on any element to map tree for drawing
# CALLED FROM: Above traceElementTree()
# ======================================================================================
# ( parent,element,  parent,currnt_element )
# function CalculateElements(document, E,  parent,node)
function CalculateElements(document::Page, node::MyElement, index)
      DOM = node.DOM
      parent = node.parent
      contentArea = parent.content
      cursor = parent          # The parent's content area
      padding = get(parent.padding, MyBox(0,0,0,0,0,0))
      margin = get(node.margin, MyBox(0,0,0,0,0,0))
      border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
      parrentborder = get(parent.border, Border(0,0,0,0,0,0,"None",[],[]))

      widthRemaining =  contentArea.width - cursor.x

     # if node.flags[HasVscroll] == true  end
     # if node.flags[HasHscroll] == true  end

    if node.flags[Relative] == true
        MakeRelative(parent,node,DOM)
    elseif node.flags[Fixed] == true
        MakeFixed(document,node,DOM)
    else

#...............................................................................
      if node.flags[Inline] == true

                  # Move to new row (due to lack of space)
                 if node.area.width > widthRemaining
                      if cursor.x != 0
                        AddRow(parent,node,true)
                      end
                  end
                  LayoutInner(node, cursor.x + contentArea.left)
                  # cursor.x += node.area.width

#...............................................................................
# inline-block elements are like inline elements but they can have a width and a height.
          elseif node.flags[InlineBlock] == true
                # println("InlineBlock...",node.area.width)
                    if !haskey(node.DOM,"width") || node.area.width < 9
                      # println("W < 9...")
                      node.area.width = widthRemaining
                    end
                        # Move to new row (due to lack of space)
                        # may need to recalculate widthRemaining: widthRemaining = contentArea.width - cursor.x
                       if node.area.width > widthRemaining
                            if cursor.x != 0 # This condition is for cases where the box is bigger than the entire empty row
                                AddRow(parent,node,true)
                            end
                        end

                        LayoutInner(node, cursor.x + contentArea.left)

#...............................................................................
# Block starts on a new line and fills it up
            elseif node.flags[Block] == true
                        # Add row ...then node
                        if (margin.width + 20) > widthRemaining
                            AddRow(parent,node,true)
                            node.area.width = contentArea.width - cursor.x
                            LayoutInner(node, cursor.x + contentArea.left)

                        # Add node ...then row
                        else # size to fit remaining space
                            node.area.width = widthRemaining
                            LayoutInner(node, cursor.x + contentArea.left)
                        end

            end
    end
    #.....................................
    # Flush out remaining row data
    row = node.rows[end]
    if row.flags[IncompleteRow] == false
      dumpRow(parent,node,false)
    end

end
# ======================================================================================
# Set up all inner bounds (can only be done after area size is determined)
# CALLED FROM:
# TODO: eventually remove
# ======================================================================================
#function LayoutInner(node,dom,x,y,w,h)
# ALERT: it would appear that dom is not needed here!
function LayoutInner(node::MyElement, x::Float32)

    # This makes area the outer bounding area (including margin)
    node.area.left = x
    margin  = get(node.margin,MyBox(0,0,0,0,0,0))
    border  = get(node.border,Border(0,0, 0,0, 0,0,0, [],[]))
    padding = get(node.padding,MyBox(0,0,0,0,0,0))

    # WIDTH...... best to establish width before toying with height.
    node.box.left         =   x          + margin.left    + border.left
    node.box.width        =   node.area.width  - margin.width   - border.width

      node.content.width    =   node.box.width   - padding.right - padding.left
      node.content.left     =   node.box.left    + padding.left

    node.x                =   node.box.left    + padding.left

         if !isa(node.parent, Int64) # HACK: fix a little problem with the first node
                rows = node.parent.rows[end]
                push!(rows.nodes,node)

                             if node.flags[FloatLeft] == true
                                 node.parent.rows[end].flags[RowHasFloatLeft] = true
                             end
                             if node.flags[FloatRight] == true
                                 node.parent.rows[end].flags[RowHasFloatRight] = true
                             end

                             node.parent.x += node.area.width
         end
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function FloatNodeLeft(row::NaquadahBrowser.Row, index::Int64)
   thisNode = row.nodes[index]
   nodes    = row.nodes

                    first = nodes[1].area.left - thisNode.area.left # find distance to start (as a negative value)
                    width = thisNode.area.width # width of node as value for moving all other nodes
                    MoveNodeBy(thisNode, first) # move node by value
                    for k = index:-1:2 # move each forward...
                      MoveNodeBy(nodes[k-1], width) # move node forward by value
                      nodes[k] = nodes[k-1] # move node in array
                    end
                    nodes[1] = thisNode # move node in array
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function FloatNodeRight(row::NaquadahBrowser.Row, index::Int64)
   thisNode = row.nodes[index]
   nodes    = row.nodes

                    width = thisNode.area.width # width of node as value for moving all other nodes
                    first = nodes[end].area.left + nodes[end].area.width - thisNode.area.left - width # offset = farRight - node.width
                    for k = index:length(nodes)-1 # move each forward...
                      MoveNodeBy(nodes[k+1], -width) # move node forward by value
                      nodes[k] = nodes[k+1] # move node in array
                      print(index, " to ", index+1, ", ")
                    end
                    n = thisNode.area.left
                    MoveNodeBy(thisNode, first) # move node by value
                    nodes[end] = thisNode # move node in array
end
# ======================================================================================
# Set up all inner bounds (can only be done after area size is determined)
# CALLED FROM:
# ======================================================================================
#function LayoutInner(node,dom,x,y,w,h)
# ALERT: it would appear that dom is not needed here!
function MoveNodeBy(node::MyElement, offset::Float32)
    node.area.left += offset
    margin  = get(node.margin,MyBox(0,0,0,0,0,0))
    border  = get(node.border,Border(0,0, 0,0, 0,0,0, [],[]))
    padding = get(node.padding,MyBox(0,0,0,0,0,0))

    node.box.left         =   node.area.left + margin.left  + border.left
    node.content.left     =   node.box.left  + padding.left
end





































# ======================================================================================
# calculateTextArea: devide text into rows and determin how much space it will take up.
# Important because for many nodes you have to know the height of its content (such as text).
# CALLED FROM: LayoutInner() rendered in: drawText(context,node) in Paint.jl
# ======================================================================================
function calculateTextArea(node::MyElement)
  if !haskey(node.DOM, "text")
    return nothing
  end
   # For now it seems we may have to create a surface to get the context to get the extents...
   # I make the size 0X0 because we will not actually draw to it.
   c = CairoRGBSurface(0,0);
   context = CairoContext(c);
   # CAIRO_FT_SYNTHESIZE_BOLD      Embolden the glyphs (redraw with a pixel offset)
   # CAIRO_FT_SYNTHESIZE_OBLIQUE   Slant the glyph outline by 12 degrees to the right.
   # (context,node,E)
   #=---------------------------------=#
   # Text=  lines, top, left, color, size, style, weight
   #        lineHeight, align, family
   #=---------------------------------=#
         text = get(node.text)
   if text.style == "italic"
       slant = Cairo.FONT_SLANT_ITALIC
   elseif text.style == "oblique"
       slant = Cairo.FONT_SLANT_OBLIQUE
   else
       slant = Cairo.FONT_SLANT_NORMAL
   end

   if text.weight == "normal"
               weight = Cairo.FONT_WEIGHT_NORMAL
           elseif text.weight == "bold"
               weight = Cairo.FONT_WEIGHT_BOLD
           end
     select_font_face(context, text.family, slant, weight);
         set_font_size(context, text.size);
        # if !isnull(node.text)  print("Had no Text node")end
           #node.text = Text()

       # Todo: Fix this so we aren't playing arround with spaces
           # one of the following may be perfect for keeping the spaces...
           # words = split(path, r"(?=[some-identifier])")
           # words = split(path, r"(?<=[some-identifier])")
           text.lines = []
         words = split(node.DOM["text"])

         buffer = ""
           line = Line("",0,0)

width  =  node.content.width


extents = []

         for i in 1:length(words)
                 if buffer == ""
                   testString = words[i]
                 else
                     testString = buffer * " " * words[i]
                 end
           extents = text_extents(context,testString );# CALLED FROM: DrawNode()

           if extents[3] < width # (extents[3]*.63)
             line.space = ( width ) - extents[3]
       buffer = testString
       line.words = line.words + 1
     elseif i == length(words) # Flush out buffer
       push!(text.lines,line) # Flush
       # print("end of line.")
                   line = Line("",0,0)    # Renew

       line.words = line.words + 1
       line.text = testString
             line.space = ( width ) - extents[3]

                  push!(text.lines,line)
     else
       line.text = buffer
                   push!(text.lines,line)
                   buffer = words[i]
                   line = Line("",0,0)
     end
         end
         # return the height of text area so that node heights can be adjusted!
         return length(text.lines) * extents[4]
end
# ======================================================================================
# Set node's possition reletive to parrent
# CALLED FROM: CalculateElements()  above
# ======================================================================================
function MakeRelative(parent::MyElement,node::MyElement,DOM::Dict)
     #   vOffset, hOffset
    if haskey(DOM, "right")
        node.hOffset  -= DOM["right"]
    elseif haskey(DOM, "left")
        node.hOffset  += DOM["left"]
    elseif haskey(DOM, "top")
        node.vOffset  += DOM["top"]
    elseif haskey(DOM, "bottom")
        node.vOffset  += DOM["bottom"]
    elseif haskey(DOM, "x1") && haskey(DOM, "y1")
        # TODO: don't be reading DOM all the time...
        #print("\n Relative...", parent.box.top)
        if  node.flags[IsLine] == true
            if  haskey(DOM, "x2") && haskey(DOM, "y2")
            node.shape = LineNode([
                                    parent.box.left + DOM["x1"], parent.box.top + DOM["y1"],
                                    parent.box.left + DOM["x2"], parent.box.top + DOM["y2"]
                                    ],0,0)
            elseif haskey(DOM, "length") && haskey(DOM, "angle")
                    node.shape = LineNode([ parent.box.left + DOM["x1"], parent.box.top + DOM["y1"] ],
                                    DOM["length"], DOM["angle"]
                                    )

            end
        end
    elseif haskey(DOM, "center")
        if  node.flags[IsArc] == true
            node.shape.center[1] += parent.box.left
            node.shape.center[2] += parent.box.top
        end
    end
end
# ======================================================================================
# make node position fixed
# CALLED FROM:
# ======================================================================================
function MakeFixed(document::Page,node::MyElement,DOM::Dict)
    node.box.width, node.box.height = DOM["width"], DOM["height"]

    viewport = collect(size(document.ui.scroller))
    padding = get(node.padding,MyBox(0,0,0,0,0,0))

      if !isnull(node.text) && haskey(node.DOM, "text")
         node.content.width    =   node.box.width   - padding.right
         textHeight = calculateTextArea(node)

         if textHeight > node.box.height
           node.box.height = textHeight
         end
      end

    if haskey(DOM, "right")
        node.box.left = (viewport[1] - node.box.width) - DOM["right"]
    end
    if haskey(DOM, "left")
        node.box.left = 0 + DOM["left"]
    end
    if haskey(DOM, "top")
        node.box.top = 0 + DOM["top"]
    end
    if haskey(DOM, "bottom")
        node.box.top = (viewport[2] - node.box.height) - DOM["bottom"]
    end

    node.content.left = node.box.left + padding.left
    node.content.top = node.box.top + padding.top
end



#======================================================================================#
# Dead code
# ======================================================================================
function ResetYoffset(parent::MyElement, flags::BitArray{1})
    return
  isdefined(parent, :y) ? top = parent.y : top = 0
  newflags = falses(1)
  # set this to pass to all children
  if parent.flags[InlineBlock] == true || parent.flags[Block] == true || flags[hasUnsetParent] == true
    newflags[hasUnsetParent] = true
  end

    for i = 1:length(parent.node)
      newNode = parent.node[i]
      if haskey(newNode.DOM, "id")
        println("ID: ", newNode.DOM["id"],", top: ",top)
      end
          if newflags[hasUnsetParent] == true
            SetNodeTop(newNode,top)
          end

      ResetYoffset(newNode,newflags)
    end

end
#======================================================================================#
# Dead Code
# ======================================================================================
function SetNodeTop(node::MyElement,top)

    if node.flags[Absolute] == false && node.flags[Fixed] == false
      if !isdefined(node.parent, :content)
          # TODO: Was trying to set top of nonexistant node ...fix!
      else
          parent = node.parent

          t = parent.content.top
              padding = get(parent.padding, MyBox(0,0,0,0,0,0))
              margin = get(parent.margin, MyBox(0,0,0,0,0,0))
              border = get(parent.border, Border(0,0,0,0,0,0,"None",[],[]))

              node.area.top    += t
              node.box.top     =  node.area.top + margin.top  + border.top
              node.content.top =  node.box.top  + padding.top
            end
    end
end
