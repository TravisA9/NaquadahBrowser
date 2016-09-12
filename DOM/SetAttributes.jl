# ======================================================================================
# Create Modify a node
# A time dependent spudo node function will also be needed for transitions.
# CALLED FROM: 
# ======================================================================================
function ModifyNode(node,origional)
    # Alter node
    if origional == false
            if haskey( node.DOM, "hover")
                hover = node.DOM["hover"]
                if haskey( hover, "color")
                    node.color = GetTheColor(node,hover["color"])
                end
            end
    # clean node
    else
            if haskey( node.DOM, "hover")
                hover = node.DOM["hover"]
                if haskey( hover, "color")
                    node.color = GetTheColor(node,node.DOM["color"])
                end
            end   
    end
end
# ======================================================================================
# Set attributes of source( E ) to node 
# CALLED FROM: 
# ======================================================================================
function SetAllAttributes(document,node,E)
# EVENTS:.................................................
# It may be helpful to backengineer the whole events thing
# I believe Cairo.jl determines events from flags, which would be 
# better to use anyway... cairo.jl's work may just be bloatware
if haskey(E, ">") 
            tag = E[">"]
    if tag == "a"
        push!(document.events.mousedown, Event(node,E["href"],"link"))
        node.href = E["href"]
        node.flags[IsBox] = true
    end
    if tag == "div" ||  tag == "p"
        node.flags[IsBox] = true
    end
    if tag == "clip"
        node.flags[OverflowClip] = true
    end
    if tag == "fill-style"
        node.flags[TestFillStyle] = true
    end
    if tag == "curve"
        node.flags[IsCurve] = true
    end
    if tag == "clip-circle"
        node.flags[ClipCircle] = true
    end
    if tag == "gradient"
        node.flags[IsGradient] = true
    end
    if tag == "text"
        node.flags[IsText] = true
    end
    if tag == "path"
        node.flags[IsPath] = true
    end
    if tag == "line"
        node.flags[IsLine] = true
        # node.shape = LineNode([]) # LineNode(coords)
        # if haskey(E, "x1") # EX: "x1":0, "y1":0, "x2":100, "y2":100,
        #     node.shape.coords = [E["x1"],E["y1"],E["x2"],E["y2"]]
        # end
    end
    if tag == "circle"
        node.flags[IsCircle] = true
        node.shape = Circle([], 0, []) # Circle(center, radius, angle)
        if haskey(E, "center") # "center":[50,50],
            node.shape.center = E["center"]
        end
        if haskey(E, "radius") # "center":50,
            node.shape.radius = E["radius"]
       end
        if haskey(E, "angle") # "angle":[25.0,180.0],
            node.shape.angle = E["angle"]
        end
    end

    if tag == "arc"
        node.flags[IsArc] = true
        node.shape = Circle([], 0, []) # Circle(center, radius, angle)
        if haskey(E, "center") # "center":[50,50],
            node.shape.center = E["center"]
        end
        if haskey(E, "radius") # "center":50,
            node.shape.radius = E["radius"]
       end
        if haskey(E, "angle") # "angle":[25.0,180.0],
            node.shape.angle = E["angle"]
        end
# print("\n SHAPE: ", node.shape)
    end


end




# Event(target, func, subtype)
if haskey(E, "mousedown")
    push!(document.events.mousedown, Event(node,E["mousedown"],"")) 
end
# onmousemove, onmouseover, onmouseout

if haskey(E, "hover")
    push!(document.events.hover, Event(node,"hover","hover")) 
end
if haskey(E, "onmousemove")
    push!(document.events.hover, Event(node,E["onmousemove"],"onmousemove")) 
end
if haskey(E, "onmouseover")
    push!(document.events.hover, Event(node,E["onmouseover"],"onmouseover")) 
end
if haskey(E, "onmouseout")
    push!(document.events.hover, Event(node,E["onmouseout"],"onmouseout")) 
end

if haskey(E, "opacity")
    node.opacity = E["opacity"]
    node.flags[HasOpacity] = true
end
#......................................................................
# TODO: Test if has width/height, if not...
#       Test if has text or content which would implicitly determine width/height
#       By determining how much space is available and how much is needed 
#       to accomodate the node's contents.
            if haskey(E, "width")
                node.total.width  =   E["width"]
            end
            if haskey(E, "height")
                node.total.height  =   E["height"]
            end
            #......................................................................
            # FLAGS: const Absolute = 10, Relative = 11, Fixed = 12
            if haskey(E, "position")
                SetPosition(E["position"], node.flags)
            end 
            #......................................................................
            # FLAGS: 
            if haskey(E, "display")
                SetDisplay(E["display"], node.flags)
            end
            #......................................................................
            # PADDING
                if haskey(E, "padding")
                    SetPadding(E["padding"], node)
                end
            #......................................................................
            # MARGIN
                if haskey(E, "margin")
                    SetMargin(E["margin"], node)
                end
            #......................................................................
            # COLOR
            if haskey(E, "color")      
                    node.flags[HasColor] = true
                     node.color = GetTheColor(node,E["color"])
            end
            #......................................................................
            # BORDER
            if haskey(E, "border")
                    SetBorder(E["border"], node)
            end
            #......................................................................
            # FONT
            if haskey(E, "font") # haskey(E, "text") || 
                    SetFont(E["font"], node)
            end
end

















# ======================================================================================
# Set flags to indicate the Display scheme (see Flags.jl, BrowserTypes.jl -> MyElement.flags)
# CALLED FROM: 
# ======================================================================================
function SetDisplay(display,flags)
            if display == "inline"
                flags[Inline] = true
            elseif display == "block"
                flags[Block] = true
            elseif display == "inline-block"
                flags[InlineBlock] = true
            elseif display == "none"
                flags[None] = true
            elseif display == "hidden"
                flags[Hidden] = true
            # (elseif) No, static will be the default.
            end
end

# ======================================================================================
# Set flags to indicate the positioning scheme (see Flags.jl, BrowserTypes.jl -> MyElement.flags)
# CALLED FROM: 
# ======================================================================================
function SetPosition(pos,flags)
		    if pos == "fixed"
		        flags[Fixed] = true
		    elseif pos == "absolute"
		        flags[Absolute] = true
		    elseif pos == "relative"
		        flags[Relative] = true
 		    # (elseif) No, static will be the default.
		    end
end
# ======================================================================================
# 
# CALLED FROM: 
# ======================================================================================
function SetPadding(padding, node)
        node.flags[HasPadding] = true
        # get --or otherwise create-- Padding
        #P = get(node.padding, Box(0,0, 0,0, 0,0))
        if isa(padding, Array)
            node.padding = Box( padding[1],  padding[2], 
                                padding[3],  padding[4], 
                                padding[1] + padding[2],
                                padding[3] + padding[4]   )
        # assume padding is different...
        else
            node.padding = Box(padding,padding, padding,padding, padding*2,padding*2)
        node.flags[PaddingSame] = true
        end 
end
# ======================================================================================
# 
# CALLED FROM: 
# ======================================================================================
function SetMargin(margin, node)
        node.flags[HasMargin] = true
        if isa(margin, Array)
            node.margin = Box(  margin[1], margin[2], 
                                margin[3], margin[4], 
                                margin[1] + margin[2], margin[3] + margin[4]   )
        else 
            node.margin = Box(margin,margin, margin,margin, margin*2,margin*2)
            node.flags[MarginSame] = true
        end  
    margin = get(node.margin)
    node.total.width  =   node.total.width + margin.width
    node.total.height =   node.total.height + margin.height
    # print("Margin width: $(margin.width) \n")
end
# ======================================================================================
# 
# CALLED FROM: 
# ======================================================================================
function GetTheColor(node,ColorNode)
                if isa(ColorNode, Array)
                    if length(ColorNode) == 3
                        color = [ColorNode[1]+0.0,ColorNode[2]+0.0,ColorNode[3]+0.0]
                    else
                        color = [ColorNode[1]+0.0,ColorNode[2]+0.0,ColorNode[3]+0.0,ColorNode[4]+0.0]
                    end
                else
                    c = collect(color_names[ ColorNode ])
                    color = [c[1]*0.00390625, c[2]*0.00390625, c[3]*0.00390625]
                end
        # Add opacity
        if node.flags[HasOpacity] == true && length(color) == 3
            push!(color,node.opacity)
        end
    return color
end
# ======================================================================================
# 
# ======================================================================================



# ======================================================================================
# 
# ======================================================================================



# ======================================================================================
# 
# ======================================================================================



# ======================================================================================
# 
# CALLED FROM: 
# ======================================================================================
function SetFont(font, node)
        node.flags[HasText] = true

        #if haskey(E, "font")
            #font = E["font"]
        #else haskey(E, "text")
        #    font = E["text"]
        #end
# "font":{ "color":[0, 0, 0],    "size":12,        "style":"italic", 
#          "weight":"normal",    "lineHeight":1.4, "family":"SANS" 
#           "align":"right" },
    node.text = Text()    
    text = get(node.text)
    # lines, top, left,  
    # color, size, lineHeight, align, family, 
    if haskey(font, "color")
        text.color = GetTheColor(node,font["color"])
    end
    if haskey(font, "size")
        text.size = font["size"]
    end
    if haskey(font, "style")
        text.style = font["style"]
    end
    if haskey(font, "weight")
        # if it's a value
        text.weight = font["weight"]
    end
    if haskey(font, "lineHeight")
        text.lineHeight = font["lineHeight"]
    else
        text.lineHeight = 1.4
    end
    if haskey(font, "family")
        text.family = font["family"]
    else
        text.family = "Sans"
    end
    if haskey(font, "align")
        text.align = font["align"]
    end    
end
# ======================================================================================
# 
# CALLED FROM: 
# ======================================================================================
function SetBorder(border, node)
        node.flags[HasBorder] = true
    style  = ""
    color  = []
    radius = Nullable{Array}()
            # border is instantiated below.
            if haskey(border, "style")
                style  = border["style"]
            end

            # print(node.border, ", ")
            if haskey(border, "color")

                BorderColor = border["color"]
                color = GetTheColor(node,BorderColor)
                # print("Border", color, typeof(color))
            end

            if haskey(border, "radius")
                if isa(border["radius"], Array)
                    radius = border["radius"]
                    if radius[1] == 0
                        radius[1] = 0.5 # just a tag
                    end
                else
                    radius = [border["radius"], border["radius"], border["radius"], border["radius"]]
                end 
            end
            width = border["width"]
            node.flags[BordersSame] = true # default
               if isa(width, Array)
                    node.border = Border(width[1],width[2],width[3],width[4],
                                          width[1]+width[2],
                                          width[3]+width[4],
                                          style,color,radius)
                    # assume border is different...
                    node.flags[BordersSame] = false
                elseif width == "thin"
                    node.border = Border(1,1,1,1,2,2,style,color,radius)
                elseif width == "medium"
                    node.border = Border(3,3,3,3,6,6,style,color,radius)
                elseif width == "thick"
                    node.border = Border(6,6,6,6,12,12,style,color,radius)
                end 
    # Update the overall width
     node.total.width  =   node.total.width  + get(node.border).width
     node.total.height =   node.total.height + get(node.border).height
end