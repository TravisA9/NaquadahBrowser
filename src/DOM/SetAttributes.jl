
# ======================================================================================
#=
macro has(DOM, key)
       quote
         if haskey( DOM, key)
             hover = DOM[key]

       end
end
=#
# ======================================================================================

# ======================================================================================
# Create Modify a node
# A time dependent spudo node function will also be needed for transitions.
# CALLED FROM: Events.jl
# xmin left   ymin top   width width   height height box area text-color
# ======================================================================================
function ModifyNode(node::MyElement,origional::Bool)
    # Alter node
    if origional == false
            if haskey( node.DOM, "hover")
                hover = node.DOM["hover"]

                if haskey( hover, "color")
                    node.color = GetTheColor(node,hover["color"])
                end

                if haskey( hover, "border")
                  border = hover["border"]
                  if haskey( border, "color")
                      b = get(node.border)
                      b.color = GetTheColor(node,border["color"])
                  end
                end

                if haskey(hover, "text-decoration")
                  if hover["text-decoration"] == "underline"
                    node.flags[IsUnderlined] = true
                  end
                end


            end
    # clean node
    else
            if haskey( node.DOM, "hover")
                hover = node.DOM["hover"]

                if haskey( hover, "color")
                    node.color = GetTheColor(node,node.DOM["color"])
                end

                if haskey( hover, "border") && haskey( node.DOM, "border")
                  border = hover["border"]
                  if haskey( border, "color") && haskey( node.DOM, "color")
                    b = get(node.border)
                    b.color = GetTheColor(node,node.DOM["border"]["color"])
                  end
                end

                if haskey(hover, "text-decoration") # || haskey(node.DOM["font"]["text-decoration"],"underline")
                  if !haskey(node.DOM["font"], "text-decoration")
                    node.flags[IsUnderlined] = false
                  end
                end

            end
    end


end
# ======================================================================================
# Set attributes of source( E ) to node
# CALLED FROM: BoxDesign(document,node,E) in BuildDOM.jl
# ======================================================================================
function SetAllAttributes(document::Page,node::MyElement,DOM::Dict)
# EVENTS:.................................................
# It may be helpful to backengineer the whole events thing
# I believe Cairo.jl determines events from flags, which would be
# better to use anyway... cairo.jl's work may just be bloatware
if haskey(DOM, ">")
            tag = DOM[">"]
    if tag == "a"
        push!(document.events.mousedown, Event(node,DOM["href"],"link"))
        node.href = DOM["href"]
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
    end
    if tag == "circle"
        node.flags[IsCircle] = true
        node.shape = Circle([], 0, []) # Circle(center, radius, angle)
        if haskey(DOM, "center") # "center":[50,50],
            node.shape.center = DOM["center"]
        end
        if haskey(DOM, "radius") # "center":50,
            node.shape.radius = DOM["radius"]
       end
        if haskey(DOM, "angle") # "angle":[25.0,180.0],
            node.shape.angle = DOM["angle"]
        end
    end

    if tag == "arc"
        node.flags[IsArc] = true
        node.shape = Circle([], 0, []) # Circle(center, radius, angle)
        if haskey(DOM, "center") # "center":[50,50],
            node.shape.center = DOM["center"]
        end
        if haskey(DOM, "radius") # "center":50,
            node.shape.radius = DOM["radius"]
       end
        if haskey(DOM, "angle") # "angle":[25.0,180.0],
            node.shape.angle = DOM["angle"]
        end
    end


end




# Event(target, func, subtype)
if haskey(DOM, "mousedown")
    push!(document.events.mousedown, Event(node,DOM["mousedown"],""))
end
# onmousemove, onmouseover, onmouseout

if haskey(DOM, "hover")
    push!(document.events.hover, Event(node,"hover","hover"))
end
if haskey(DOM, "onmousemove")
    push!(document.events.hover, Event(node,DOM["onmousemove"],"onmousemove"))
end
if haskey(DOM, "onmouseover")
    push!(document.events.hover, Event(node,DOM["onmouseover"],"onmouseover"))
end
if haskey(DOM, "onmouseout")
    push!(document.events.hover, Event(node,DOM["onmouseout"],"onmouseout"))
end

if haskey(DOM, "opacity")
    node.opacity = DOM["opacity"]
    node.flags[HasOpacity] = true
end
#......................................................................
# TODO: Test if has width/height, if not...
#       Test if has text or content which would implicitly determine width/height
#       By determining how much space is available and how much is needed
#       to accomodate the node's contents.
            if haskey(DOM, "width")
                node.area.width  =   DOM["width"]
            end
            if haskey(DOM, "height")
                node.area.height  =   DOM["height"]
            end
            #......................................................................
            # FLAGS: const Absolute = 10, Relative = 11, Fixed = 12
            if haskey(DOM, "position")
                SetPosition(DOM["position"], node.flags)
            end
            #......................................................................
            # FLAGS:
            if haskey(DOM, "display")
                SetDisplay(DOM["display"], node.flags)
            end
            #......................................................................
            # PADDING
                if haskey(DOM, "padding")
                    SetPadding(DOM["padding"], node)
                end
            #......................................................................
            # MARGIN
                if haskey(DOM, "margin")
                    SetMargin(DOM["margin"], node)
                end
            #......................................................................
            # COLOR
            if haskey(DOM, "color")
                    node.flags[HasColor] = true
                     node.color = GetTheColor(node,DOM["color"])
            end
            #......................................................................
            # BORDER
            if haskey(DOM, "border")
                    SetBorder(DOM["border"], node)
            end
            #......................................................................
            # FONT
            if haskey(DOM, "font") # haskey(DOM, "text") ||
                    SetFont(DOM["font"], node)
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
function SetPadding(padding, node::MyElement)
        node.flags[HasPadding] = true
        # get --or otherwise create-- Padding
        #P = get(node.padding, Box(0,0, 0,0, 0,0))
        if isa(padding, Array)
            node.padding = MyBox( padding[1],  padding[2],
                                padding[3],  padding[4],
                                padding[1] + padding[2],
                                padding[3] + padding[4]   )
        # assume padding is different...
        else
            node.padding = MyBox(padding,padding, padding,padding, padding*2,padding*2)
        node.flags[PaddingSame] = true
        end
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function SetMargin(margin, node::MyElement)
        node.flags[HasMargin] = true
        if isa(margin, Array)
            node.margin = MyBox(  margin[1], margin[2],
                                margin[3], margin[4],
                                margin[1] + margin[2], margin[3] + margin[4]   )
        else
            node.margin = MyBox(margin,margin, margin,margin, margin*2,margin*2)
            node.flags[MarginSame] = true
        end
    margin = get(node.margin)
    # node.bg.width  =   node.bg.width + margin.width
    # node.bg.height =   node.bg.height + margin.height
    node.area.width  +=   margin.width
    node.area.height  +=   margin.height
    # print("Margin width: $(margin.width) \n")
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function GetTheColor(node::MyElement,ColorNode)
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
# CALLED FROM:
# ======================================================================================
function SetFont(font, node::MyElement)

  # node.flags[HasText] = true
  # node.text = Text()
  # text = get(node.text)

    node.flags[HasText] = true
    #node.text = Text()
    text = get(node.text,Text())


    # lines, top, left,
    # color, size, lineHeight, align, family,
    if haskey(font, "size")
        text.size = font["size"]
    end
    if haskey(font, "color")
        text.color = GetTheColor(node,font["color"])
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
    if haskey(font, "text-decoration")
        node.flags[IsUnderlined] = true
    end
    # println("Attributes...........",node.text)
node.text = text
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function SetBorder(border, node::MyElement)
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
     # node.bg.width  =   node.bg.width  + get(node.border).width
     # node.bg.height =   node.bg.height + get(node.border).height
     node.area.width  +=   get(node.border).width
     node.area.height  +=   get(node.border).height

end
