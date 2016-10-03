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
function traceElementTree(document,layoutTree, dom)
        if isa(dom["nodes"], Array)
        # TODO: Integrate   dom["nodes"] into   layoutTree.node[i].DOM before calling  traceElementTree()
        # This is a test comment meant to test some git stuff.
            nodes = dom["nodes"]
            # i is a node in dom[Array]
            for i in eachindex(nodes)
                    # Add this node to parent
                    # CreateNode(nodes[i])
                    # WAS: push!(layoutTree.node, MyElement())
                    push!(layoutTree.node, CreateDefaultNode(nodes[i]))
                    # link layout node with corresponding DOM node
                    layoutTree.node[i].DOM = nodes[i]
                    # link this node Parent node
                    layoutTree.node[i].parent = layoutTree
                    # map into layout
                    CalculateElements(document, layoutTree.node[i] )
                    #layoutTree[i].
                    if haskey(nodes[i], "nodes")
                        traceElementTree(document, layoutTree.node[i] ,nodes[i])
                    end
            end
            # these serve a temp values to aid layout
            layoutTree.x      = 0
            layoutTree.y      = 0
            layoutTree.height = 0
        end
        return layoutTree.y
end
# ======================================================================================
# Create a node with default settings
# CALLED FROM: Above traceElementTree()
# ======================================================================================
function CreateDefaultNode(DOM)
  node = MyElement()

    if haskey(DOM, ">")
      tag = DOM[">"]

      if tag == "a"
        # push!(document.events.mousedown, Event(node,E["href"],"link"))
        # node.href = E["href"]
        node.flags[IsBox] = true
# new([],   0,  0,   [],   0,   "normal","normal",0,        "left","SANS")
#     lines,top,left,color,size,style,   weight, lineHeight,align, family
        # node.text = Text([],   0,  0,   [],   0,   "normal","normal",0,        "left","SANS")
        # [],0,0,[0.23,0.2695,0.6757],0,"normal","normal",0,"left","SANS"
        node.text = Text()
        text = get(node.text)
        text.color = [0.23,0.2695,0.6757]    # default link color
      #  println("  .........",node.text,".........  ")
        node.flags[UnderlineOnHover] = true
      end
      # if tag == "a"
      # end

    end  # END: haskey(DOM, ">")
    return node
end
# ======================================================================================
# Inteded to be called recursively on any element to map tree for drawing
# CALLED FROM: Above traceElementTree()
# ======================================================================================
# ( parent,element,  parent,currnt_element )
# function CalculateElements(document, E,  parent,node)
function CalculateElements(document, node)
    E = node.DOM
    parent = node.parent
    contentArea = parent.content
    # padding: thicknesses for calculating content area    content
         cursor = parent          # The parent's content area

    # calculate all defaults
     BoxDesign(document,node,E)
      padding = get(parent.padding, MyBox(0,0,0,0,0,0))
      margin = get(node.margin, MyBox(0,0,0,0,0,0))
      border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
      parrentborder = get(parent.border, Border(0,0,0,0,0,0,"None",[],[]))



    # contentArea = MyBox(  parent.box.left   + padding.left
    #                     , parent.box.width  - padding.width
    #                     , parent.box.top    + padding.top
    #                     , parent.box.height - padding.height
    #                     , parent.area.width  - margin.width
    #                     , parent.area.height - margin.height )

 # println("......box......", content)
 # println("...contentArea...", contentArea)



    # local variables PaintBox.content.right
    #contentArea.width

    widthRemaining = contentArea.left + contentArea.width - cursor.x - padding.right - parrentborder.width

    if node.flags[Relative] == true
        MakeRelative(parent,node,E)
    elseif node.flags[Fixed] == true
        # println("going to fixed")
        MakeFixed(document,node,E)
    else

            if node.flags[Inline] == true

                        # Move to new row (due to lack of space)
                       if node.area.width > widthRemaining
                       #if node.box.width > widthRemaining
                            if cursor.x != contentArea.left
                                cursor.y += cursor.height
                                cursor.x = contentArea.left
                            end
                            cursor.height = node.area.height
                        elseif cursor.height < node.area.height #node.box.height
                               cursor.height = node.area.height #node.box.height
                        end

                        LayoutInner(node,E,cursor)
                        # cursor.x += node.box.width # + border.width + margin.width
                        cursor.x += node.area.width # + border.width + margin.width



            elseif node.flags[Block] == true
                        # Full Row
                        if (margin.width + 20) > widthRemaining
                                cursor.y += cursor.height
                                cursor.x = contentArea.left
                            # determine new width
                            newWidth = contentArea.width # - margin.right - border.width
                            node.area.width = newWidth>5 ? newWidth : 5

                             LayoutInner(node,E,cursor) #  - margin.bottom - border.bottom
                             cursor.height = node.area.height + border.height
                            cursor.y += cursor.height
                        else # size to fit remaining space

                            node.area.width = widthRemaining # - margin.right - border.width

                            LayoutInner(node,E,cursor) # - margin.bottom - border.bottom
                            if cursor.height < node.area.height
                                cursor.height = node.area.height
                            end
                            cursor.y += cursor.height
                            cursor.height = 0
                        end
                        # TODO: set content area etc.
                        # set up the next row
                        cursor.x = contentArea.left

            end
    end
end
# ======================================================================================
# thicknes-r, thicknes-r, thicknes-r, thicknes-r, sum-x, sum-y
# CALLED FROM:
# ======================================================================================
function BoxDesign(document,node,E)
# ELEMENTS:..............................................
# STYLES:................................................
    if haskey(E, "class")
        # TODO: Test if is Array and work out selector logic
        class = E["class"]
        if haskey(document.styles, class)
            styles = document.styles[class]
            SetAllAttributes(document,node,styles)
        else
            # print("The class: $(class) not found!\n") # content
        end
    end
    # INLINE STYLES:..........................................
    SetAllAttributes(document,node,E)
end

# ======================================================================================
# Set up all inner bounds (can only be done after area size is determined)
# CALLED FROM:
# TODO: eventually remove
# ======================================================================================
#function LayoutInner(node,dom,x,y,w,h)
function LayoutInner(node,dom,point)
    # This makes area the outer bounding area (including margin)
    node.area.left, node.area.top = point.x, point.y
    margin  = get(node.margin,MyBox(0,0,0,0,0,0))
    border  = get(node.border,Border(0,0, 0,0, 0,0,0, [],[]))
    padding = get(node.padding,MyBox(0,0,0,0,0,0))

    # WIDTH...... best to establish width before toying with height.
    node.box.left         =   point.x          + margin.left    + border.left
    node.box.width        =   node.area.width  - margin.width   - border.width
    node.content.width    =   node.box.width   - padding.right
    node.content.left     =   node.box.left    + padding.left
    node.x                =   node.box.left    + padding.left

    # HEIGHT...... There should be a condition here since some elements have a set height.
    node.box.top          =   point.y          + margin.top     + border.top
    node.box.height       =   node.area.height - margin.height  - border.height
    node.content.height   =   node.box.height  - padding.bottom
    node.content.top      =   node.box.top     + padding.top
    node.y                =   node.box.top     + padding.top


        if !isnull(node.text)
           textHeight = calculateTextArea(node)
           if textHeight > node.content.height
             node.content.height   = textHeight
             node.box.height       = node.content.height + padding.top + padding.bottom
             node.area.height      = node.box.height     + margin.top  + margin.bottom

           end
        end

end
# ======================================================================================
# calculateTextArea: devide text into rows and determin how much space it will take up.
# Important because for many nodes you have to know the height of its content (such as text).
# CALLED FROM: LayoutInner() rendered in: drawText(context,node) in Paint.jl
# ======================================================================================
function calculateTextArea(node)
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

# content = get(node.content,)
extents = []

         for i in 1:length(words)
                 if buffer == ""
                   testString = words[i]
                 else
                     testString = buffer * " " * words[i]
                 end
           extents = text_extents(context,testString );# CALLED FROM: DrawNode()

           if extents[3] < node.content.width # (extents[3]*.63)
             line.space = ( node.content.width ) - extents[3]
       buffer = testString
       line.words = line.words + 1
     elseif i == length(words) # Flush out buffer
       push!(text.lines,line) # Flush
       # print("end of line.")
                   line = Line("",0,0)    # Renew

       line.words = line.words + 1
       line.text = testString
             line.space = ( node.content.width ) - extents[3]

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
#
# CALLED FROM:
# ======================================================================================
function MakeRelative(parent,node,dom)
     #   vOffset, hOffset
    if haskey(dom, "right")
        node.hOffset  -= dom["right"]
    elseif haskey(dom, "left")
        node.hOffset  += dom["left"]
    elseif haskey(dom, "top")
        node.vOffset  += dom["top"]
    elseif haskey(dom, "bottom")
        node.vOffset  += dom["bottom"]
    elseif haskey(dom, "x1") && haskey(dom, "y1")
        # TODO: don't be reading dom all the time...
        #print("\n Relative...", parent.box.top)
        if  node.flags[IsLine] == true
            if  haskey(dom, "x2") && haskey(dom, "y2")
            node.shape = LineNode([
                                    parent.box.left + dom["x1"], parent.box.top + dom["y1"],
                                    parent.box.left + dom["x2"], parent.box.top + dom["y2"]
                                    ],0,0)
            elseif haskey(dom, "length") && haskey(dom, "angle")
                    node.shape = LineNode([ parent.box.left + dom["x1"], parent.box.top + dom["y1"] ],
                                    dom["length"], dom["angle"]
                                    )

            end
        end
    elseif haskey(dom, "center")
        if  node.flags[IsArc] == true
            node.shape.center[1] += parent.box.left
            node.shape.center[2] += parent.box.top
        end
    end
end
# ======================================================================================
#  MakeFixed(document,layoutElement,E)
# CALLED FROM:
# ======================================================================================
function MakeFixed(document,node,dom)
    node.box.width, node.box.height = dom["width"], dom["height"]

    viewport = collect(size(document.ui.scroller))
    # println("allocation",Gtk.allocation(document.ui.scroller))
    padding = get(node.padding,MyBox(0,0,0,0,0,0))


      if !isnull(node.text)
         node.content.width    =   node.box.width   - padding.right
         textHeight = calculateTextArea(node)

         if textHeight > node.box.height
           node.box.height = textHeight
         end
      end





    if haskey(dom, "right")
        node.box.left = (viewport[1] - node.box.width) - dom["right"]
    end
    if haskey(dom, "left")
        node.box.left = 0 + dom["left"]
    end
    if haskey(dom, "top")
        node.box.top = 0 + dom["top"]
    end
    if haskey(dom, "bottom")
        node.box.top = (viewport[2] - node.box.height) - dom["bottom"]
    end

    node.content.left = node.box.left + padding.left
    node.content.top = node.box.top + padding.top

# point = Point(node.box.left,node.box.top)
# LayoutInner(node,dom,point)




end
