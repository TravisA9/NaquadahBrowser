#======================================================================================#
# traceElementTree()
# CalculateElements()
# BoxDesign()
# LayoutInner()
# MakeRelative()
# MakeFixed()
#======================================================================================#

# ======================================================================================
# Recursively read Dict(data) and build DOM Tree
# CALLED FROM: DrawPage.jl  -->  DrawPage()
# this could be called BuildLayoutTree
# ======================================================================================
function traceElementTree(document,layoutTree, dom)
        if isa(dom["nodes"], Array) 
        # TODO: Integrate   dom["nodes"] into   layoutTree.node[i].DOM before calling  traceElementTree()     
            nodes = dom["nodes"]
            # i is a node in dom[Array]
            for i in eachindex(nodes) 
                    # Add this node to parent
                    push!(layoutTree.node, MyElement())
                    # link layout node with corresponding DOM node
                    layoutTree.node[i].DOM = nodes[i]
                    # link node Parent node
                    layoutTree.node[i].parent = layoutTree
                    # map into layout
                    CalculateElements(document, layoutTree.node[i] )
                    #layoutTree[i].
                    if haskey(nodes[i], "nodes") 
                        traceElementTree(document, layoutTree.node[i] ,nodes[i])
                    end                        
            end 
            layoutTree.x      = 0
            layoutTree.y      = 0
            layoutTree.height = 0
        end
        return layoutTree.y
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
    # padding: thicknesses for calculating content area    content
         cursor = parent          # The parent's content area
    contentArea = parent.content  # The parent's content area        

    # calculate all defaults
     BoxDesign(document,node,E)
      padding = get(parent.padding, Box(0,0,0,0,0,0))
      margin = get(node.margin, Box(0,0,0,0,0,0))
      border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
      parrentborder = get(parent.border, Border(0,0,0,0,0,0,"None",[],[]))
    # local variables PaintBox.content.right
    #contentArea.width
    
    widthRemaining = contentArea.left + contentArea.width - cursor.x - padding.right - parrentborder.width

    if node.flags[Relative] == true
        MakeRelative(parent,node,E)
    elseif node.flags[Fixed] == true
        println("going to fixed")
        MakeFixed(document,node,E)
    else

            if node.flags[Inline] == true 
                        
                        # Move to new row (due to lack of space)
                       if node.total.width > widthRemaining
                            if cursor.x != contentArea.left
                                cursor.y = cursor.y + cursor.height 
                                cursor.x = contentArea.left
                            end
                            cursor.height = node.total.height            
                        elseif cursor.height < node.total.height
                               cursor.height = node.total.height  
                        end

                        LayoutInner(node,E, cursor.x, cursor.y, node.total.width, node.total.height)
                        cursor.x = cursor.x + node.total.width # + border.width + margin.width


            elseif node.flags[Block] == true 
                        # Full Row
                        if (margin.width + 20) > widthRemaining
                                cursor.y = cursor.y + cursor.height
                                cursor.x = contentArea.left
                            # determine new width
                            newWidth = contentArea.width # - margin.right - border.width
                            node.total.width = newWidth>5 ? newWidth : 5

                            LayoutInner(node,E,
                                         cursor.x,
                                         cursor.y, 
                                         node.total.width, #  - margin.right - border.right, 
                                         node.total.height) #  - margin.bottom - border.bottom
                             cursor.height = node.total.height + border.height
                            cursor.y = cursor.y + cursor.height
                        else # size to fit remaining space

                            node.total.width = widthRemaining # - margin.right - border.width


                            LayoutInner(node,E,
                                         cursor.x,
                                         cursor.y, 
                                         node.total.width, # - margin.right - border.right, 
                                         node.total.height) # - margin.bottom - border.bottom
                            if cursor.height < node.total.height 
                                cursor.height = node.total.height
                            end
                            cursor.y = cursor.y + cursor.height
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
        # print("The class: $(class)\n")
        SetAllAttributes(document,node,styles)
    else
        # print("The class: $(class) not found!\n")
    end
 end



# INLINE STYLES:..........................................
SetAllAttributes(document,node,E)

end

# ======================================================================================
# Set up all inner bounds (can only be done after box size is determined)
# CALLED FROM: 
# ======================================================================================
function LayoutInner(node,dom,x,y,w,h)
    margin  = get(node.margin,Box(0,0,0,0,0,0))
    border  = get(node.border,Border(0,0, 0,0, 0,0,0, [],[]))
    padding = get(node.padding,Box(0,0,0,0,0,0))
    # background area
    node.total.left   = x + margin.left + border.left
    node.total.right  = w - margin.width  - border.width
    node.total.top    = y + margin.top  + border.top
    node.total.bottom = h - margin.height - border.height
    # if node.flags[Relative] == true
    #     MakeRelative(node,dom)
    # end

# There was a problem here... I think it's better
    node.content.width  = node.total.right    - padding.right # node.content.right  - node.content.left 
    node.content.height = node.total.bottom   - padding.bottom # node.content.bottom - node.content.top
    node.content.left   = node.total.left     + padding.left
    node.content.top    = node.total.top      + padding.top # 
    node.content.right  = node.content.width  - padding.right # node.total.right    - padding.right  node.total.left     + 
    node.content.bottom = node.content.height - padding.bottom # node.total.top      + 
    node.x = node.content.left
    node.y = node.content.top
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
        #print("\n Relative...", parent.total.top)
        if  node.flags[IsLine] == true
            if  haskey(dom, "x2") && haskey(dom, "y2")
            node.shape = LineNode([
                                    parent.total.left + dom["x1"], parent.total.top + dom["y1"],
                                    parent.total.left + dom["x2"], parent.total.top + dom["y2"]
                                    ],0,0)
            elseif haskey(dom, "length") && haskey(dom, "angle")
                    node.shape = LineNode([ parent.total.left + dom["x1"], parent.total.top + dom["y1"] ],
                                    dom["length"], dom["angle"]
                                    )   

            end
        end
    elseif haskey(dom, "center")
        if  node.flags[IsArc] == true
            node.shape.center[1] += parent.total.left
            node.shape.center[2] += parent.total.top
        end
    end
end
# ======================================================================================
#  MakeFixed(document,layoutElement,E)
# CALLED FROM: 
# ======================================================================================
function MakeFixed(document,node,dom)
    node.total.right, node.total.bottom = dom["width"], dom["height"]

    # viewport = document.node[1].total
    viewport = collect(size(document.ui.scroller))
    println("allocation",Gtk.allocation(document.ui.scroller))
    # println(Gtk.scrolled_window_get_hscrollbar(document.ui.scroller))


    # println("scrollbar",document.ui.scroller)
# println(  ccall(:gtk_scrolled_window_get_hscrollbar, Ptr{GObject})  )



    if haskey(dom, "right")
        node.total.left = (viewport[1] - node.total.right) - dom["right"]
    end
    if haskey(dom, "left")
        node.total.left = 0 + dom["left"]
    end
    if haskey(dom, "top")
        node.total.top = 0 + dom["top"]
    end
    if haskey(dom, "bottom")
        node.total.top = (viewport[2] - node.total.bottom) - dom["bottom"]
    end

end