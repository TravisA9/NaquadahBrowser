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
function traceElementTree(document::Page,root::MyElement, DOM::Dict)
        if isa(DOM["nodes"], Array)
        # TODO: Integrate   DOM["nodes"] into   root.node[i].DOM before calling  traceElementTree()
        # This is a test comment meant to test some git stuff.
            DOM_nodes = DOM["nodes"]

            # these serve a temp values to aid layout
            root.x      = 0
            root.y      = 0

            root.height = 0
                        # pack all floats


            # i is a node in DOM[Array]
            for i in eachindex(DOM_nodes)
                    # Add this node to parent
                    push!(root.node, MyElement())
                    # link layout node with corresponding DOM node
                    root.node[i].DOM = DOM_nodes[i]
                    # link this node Parent node
                    root.node[i].parent = root

                    CreateDefaultNode(document, root.node[i], DOM_nodes[i])
                    # make sure it's instantiated
                     if length(root.rows) < 1
                       push!(root.rows,Row())
                     end



                    # map into layout... maybe this should be named PositioningAndLayout
                    #if root.node[i].flags[FloatLeft] == false && root.node[i].flags[FloatRight] == false
                      CalculateElements(document, root.node[i], i )



                    if i == 1
                      root.rowstart = 1
                    end



                    #root[i].
                    if haskey(DOM_nodes[i], "nodes")
                        traceElementTree(document, root.node[i] ,DOM_nodes[i])
                    end
            end

            # Still need to calculate contingent on height

        if length(root.floater) > 0
          floatLefts = 0
          floatRights = 0
              for n in root.floater
                    if n.flags[FloatLeft] == true
                      floatLefts += n.area.width
                    elseif n.flags[FloatRight] == true
                      floatRights += n.area.width
                    end
              end
              root.left      = floatLefts
              root.right      = floatRights
              println("left: ",root.left)
        else
              root.left      = 0
              root.right      = 0
        end




        end
        return root.y
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

      # width = contentArea.width - cursor.x - padding.width - parrentborder.width
      # Left = contentArea.left + cursor.x
      widthRemaining =  contentArea.width - cursor.x
      # contentArea.left + contentArea.width - cursor.x - padding.right - parrentborder.width




    if node.flags[Relative] == true
        MakeRelative(parent,node,DOM)
    elseif node.flags[Fixed] == true
        MakeFixed(document,node,DOM)
    else

      if node.flags[Inline] == true

                  # Move to new row (due to lack of space)
                 if node.area.width > widthRemaining
                      if cursor.x != 0
                          cursor.y += cursor.height
                          cursor.x = 0

AddRow(parent,node)
                          cursor.rowstart = index # mark as first in row
                          println(cursor.rowstart)
                      end
                      cursor.height = node.area.height
                  elseif cursor.height < node.area.height
                         cursor.height = node.area.height
                  end
                  LayoutInner(node,Point(cursor.x + contentArea.left,cursor.y + contentArea.top))
                  println("Hello Left...",parent.rows[end].flags," length: ",length(parent.rows))
                  cursor.x += node.area.width


# TODO: fix
          elseif node.flags[InlineBlock] == true

                        # Move to new row (due to lack of space)
                       if node.area.width > widthRemaining
                            if cursor.x != 0 # This condition is for cases where the box is bigger than the entire empty row
                                cursor.y += cursor.height
                                cursor.x = 0

AddRow(parent,node)
                                cursor.rowstart = index # mark as first in row
                                println(cursor.rowstart)
                            end
                            cursor.height = node.area.height
                        elseif cursor.height < node.area.height
                               cursor.height = node.area.height
                        end

                        LayoutInner(node,Point(cursor.x + contentArea.left,cursor.y + contentArea.top))
                        println("Hello Left...",parent.rows[end].flags," length: ",length(parent.rows))
                        cursor.x += node.area.width



            elseif node.flags[Block] == true
                        # Full Row
                        if (margin.width + 20) > widthRemaining
                                cursor.y += cursor.height
                                cursor.x = 0

AddRow(parent,node)

                                cursor.rowstart = index # mark as first in row
                                println(cursor.rowstart)
                            # determine new width
                            newWidth = contentArea.width # - margin.right - border.width
                            node.area.width = newWidth > 5 ? newWidth : 5

                             LayoutInner(node,Point(cursor.x + contentArea.left,cursor.y + contentArea.top)) #  - margin.bottom - border.bottom
                             cursor.height = node.area.height + border.height
                            cursor.y += cursor.height
                        else # size to fit remaining space

                            node.area.width = widthRemaining # - margin.right - border.width

                            LayoutInner(node,Point(cursor.x + contentArea.left,cursor.y + contentArea.top)) # - margin.bottom - border.bottom
                            if cursor.height < node.area.height
                                cursor.height = node.area.height
                            end
                            cursor.y += cursor.height
                            cursor.height = 0
                            AddRow(parent,node)
                        end
                        # TODO: set content area etc.
                        # set up the next row
                        cursor.x = 0

            end
    end


end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function AddRow(parent,node)
    row = parent.rows[end]
    l = length(row.nodes)
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


    push!(parent.rows,Row()) # push new row to parent
    # println("Row contains $(l) nodes. Adding new row...",parent.rows[end].flags)
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
# Set up all inner bounds (can only be done after area size is determined)
# CALLED FROM:
# TODO: eventually remove
# ======================================================================================
#function LayoutInner(node,dom,x,y,w,h)
# ALERT: it would appear that dom is not needed here!
function LayoutInner(node::MyElement,point::NaquadahBrowser.Point)
    # This makes area the outer bounding area (including margin)
    node.area.left, node.area.top = point.x, point.y
    margin  = get(node.margin,MyBox(0,0,0,0,0,0))
    border  = get(node.border,Border(0,0, 0,0, 0,0,0, [],[]))
    padding = get(node.padding,MyBox(0,0,0,0,0,0))

    # WIDTH...... best to establish width before toying with height.
    node.box.left         =   point.x          + margin.left    + border.left
    node.box.width        =   node.area.width  - margin.width   - border.width
    node.content.width    =   node.box.width   - padding.right - padding.left
    node.content.left     =   node.box.left    + padding.left
    node.x                =   node.box.left    + padding.left

    # HEIGHT...... There should be a condition here since some elements have a set height.
    node.box.top          =   point.y          + margin.top     + border.top
    node.box.height       =   node.area.height - margin.height  - border.height
    node.content.height   =   node.box.height  - padding.bottom - padding.top
    node.content.top      =   node.box.top     + padding.top
    node.y                =   node.box.top     + padding.top

    if node.flags[HasVscroll] == true && node.content.width > 12
      node.content.width -= 12
    end

    if node.flags[HasHscroll] == true && node.content.height > 12
      node.content.height -= 12
    end
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
        # May be able to move this to SetAttributes module
        # RowHasFloatLeft RowHasFloatRight
        if !isa(node.parent, Int64) # HACK: fix a little problem with the first node
                rows = node.parent.rows[end]
                push!(rows.nodes,node)

                             if node.flags[FloatLeft] == true
                                 node.parent.rows[end].flags[RowHasFloatLeft] = true
                             end
                             if node.flags[FloatRight] == true
                                 node.parent.rows[end].flags[RowHasFloatRight] = true
                                # println("Hello Right...",node.parent.rows[end].flags)
                             end

        end


end

































# ======================================================================================
# Create a node with default settings
# CALLED FROM: Above traceElementTree()
#   Instead of setting all the default variables it may be more sensible to test for
#   attributes and set defaults if none are explicitly set from the DOM. It would be
#   good to test for and set styles at the same time...
# ======================================================================================
function CreateDefaultNode(document::Page, node::MyElement ,DOM::Dict)

  defaults = Dict()
  # take into account that multiple styles may be applied.
  # Styles should probably be merged...
  styles = Dict()
  # set styles..............................................
  # set defaults..............................................
  # NOTE: move from most important to least. Example:
  #       imediate-styles -> ID-style -> last-class-style -> ... -> first-class-style -> default-style

    if haskey(DOM, ">")
      tag = DOM[">"]
      if haskey(Tags_Default, tag)
          defaults = Tags_Default[tag]
          MergeAttributes(DOM, defaults)
      end

      # These should be set automattically now
      # if tag == "a"
      #   node.flags[IsBox] = true
      #   node.text = Text()
      #   text = get(node.text)
      #   text.color = [0.23,0.2695,0.6757]    # default link color
      #   node.flags[UnderlineOnHover] = true
      # end

    end  # END: haskey(DOM, ">")
    
    if haskey(DOM, "overflow")
      tag = DOM["overflow"]
      if tag == "scroll"
        # add scrollbars to the DOM
        DOM["v-scroll"] = Tags_Default["v-scroll"]
        DOM["h-scroll"] = Tags_Default["h-scroll"]
      end
    end
    BoxDesign(document,node,DOM)
    # scrollbar-track scrollbar-thumb


    # return node
end
# ======================================================================================
# just to keep things clean below. TODO: inline
# ======================================================================================
function Copy(primary::Dict, secondary::Dict, attribute::String)
      if !haskey(primary, attribute) && haskey(secondary, attribute)
          primary[attribute] = secondary[attribute]
      end
end
# ======================================================================================
# Take primary's attributes and fill in gaps with secondary's as fallback/default.
# NOTE: move from most important to least. Example:
#       imediate-styles -> ID-style -> last-class-style -> ... -> first-class-style -> default-style
# CALLED FROM: Above CreateDefaultNode()
#   list, table, text, column, color, border, padding, margin, background, font,
#   position, display, z-index,
#
# nodes:, events:, transforms:,
#
# top-level: { font:, border:, hover:, position, text, href, display, width, height, color, padding, margin, , , ,  }
# font:{ color, size, style, align, lineHeight, weight, family },
# border:{ radius, style, width, color }
# EVENTS: mousedown, mouseup, click, drag, hover
# ======================================================================================
function MergeAttributes(primary::Dict, secondary::Dict)

    # Top-Level........................................
    # hover:, position, text, href, display, width, height, color, padding, margin
    Copy(primary, secondary, "hover")
    Copy(primary, secondary, "position")
    Copy(primary, secondary, "text")
    Copy(primary, secondary, "href")
    Copy(primary, secondary, "display")
    Copy(primary, secondary, "width")
    Copy(primary, secondary, "height")
    Copy(primary, secondary, "color")
    Copy(primary, secondary, "padding")
    Copy(primary, secondary, "margin")
    Copy(primary, secondary, "opacity")
    Copy(primary, secondary, "z-index")
    Copy(primary, secondary, "gradient")


    Copy(primary, secondary, "center")
    Copy(primary, secondary, "radius")
    Copy(primary, secondary, "angle")
    # Copy(primary, secondary, "")

    # FONT.............................................
        if haskey(secondary, "font")
              if !haskey(primary, "font")
                primary["font"] = secondary["font"]
              else
                font = primary["font"]
                defaultfont = secondary["font"]
                # primary does not have attribute but secondary does
                          Copy(font, defaultfont, "color")
                          Copy(font, defaultfont, "size")
                          Copy(font, defaultfont, "style")
                          Copy(font, defaultfont, "weight")
                          Copy(font, defaultfont, "lineHeight")
                          Copy(font, defaultfont, "family")
                          Copy(font, defaultfont, "align")
                          Copy(font, defaultfont, "text-decoration")
              end
        end

    # BORDER.............................................
        if haskey(secondary, "border")
              if !haskey(primary, "border")
                primary["border"] = secondary["border"]
              else
                border = primary["border"]
                defaultborder = secondary["border"]
                # primary does not have attribute but secondary does
                radius, style, width, color
                          Copy(border, defaultborder, "radius")
                          Copy(border, defaultborder, "style")
                          Copy(border, defaultborder, "width")
                          Copy(border, defaultborder, "color")
              end
        end
end

# ======================================================================================
# thicknes-r, thicknes-r, thicknes-r, thicknes-r, sum-x, sum-y
# CALLED FROM:
# ======================================================================================
function BoxDesign(document::Page,node::MyElement,DOM::Dict)
# ELEMENTS:..............................................
# STYLES:................................................
    if haskey(DOM, "class")
        # TODO: Test if is Array and work out selector logic
        class = DOM["class"]
        if haskey(document.styles, class)
            styles = document.styles[class]
            SetAllAttributes(document,node,styles)
        else
            # print("The class: $(class) not found!\n") # content
        end
    end
    # INLINE STYLES:..........................................
    SetAllAttributes(document,node,DOM)
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
#=
         #for word in words
         buffer = ""
         line.text = ""
         line.words = 1
         line.space = node.area.width
         print(node.area.width, ":   ")
         for i in 1:length(words)
       buffer = words[i] * " "


           extents = text_extents(context,buffer);
           # Full or Overflowing
           if extents[3] >= line.space || i == length(words)
                   if i == length(words)
                     line.text = line.text*buffer
                   end
                   push!(text.lines,line)
                   print(text_extents(context,line.text)[3], ":")
                   line = Line("",0,0)
             line.text = ""
             line.words = 1
             line.space = node.area.width
       else # Add another word
         # Recalculate free space
             line.space = line.space - (extents[3]+5)
             # Increment word index
       line.words = line.words + 1
         #buffer = buffer * " " * words[i]
         line.text = line.text*buffer
     end
         end
=#
# HasVscroll HasHscroll
width  =  node.content.width

#height  =
# content = get(node.content,)
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
    # println("allocation",Gtk.allocation(document.ui.scroller))
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

# point = Point(node.box.left,node.box.top)
# LayoutInner(node,DOM,point)




end
