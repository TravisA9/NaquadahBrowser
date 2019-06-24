
export allAtributesToLayout, AtributesToLayout, CopyDict, DomToLayout

# boxes = [ "div", "aside", "audio", "button", "canvas", "form", "header", "img",
#           "input", "ul", "ol", "li", "menu", "menuitem", "progress", "textarea",
#           "table", "tbody", "td", "th", "thead", "tr", "tfoot", "video"]
# textboxes = [  "p", "a", "em", "h1", "h2", "h3", "h4", "h5", "h6",
#           "i", "s", "span", "small", "strong", "title", "abbr", "address",
#           "b", "blockquote", "q", "title", "sub", "sup"]
# ======================================================================================
# Test for string in array (this probably already exists somewhere).
# ======================================================================================
function isAny(key::String, strings::Array{String})
     for str in strings
       if key == str
         return str
       end
     end
     return nothing
end
# ======================================================================================
#
# ======================================================================================
function allAtributesToLayout(document::Page, parent)
    isa(parent.shape, TextLine) && return # TODO: may be able to make this part of multiple dispatch later

    parent.rows  = []  # Clean out old data (?)
        for child in parent.children
                child.parent = parent # attach to parent
                AtributesToLayout(document, child) # Create Child's DOM (DomToLayout.jl)
                allAtributesToLayout(document, child) # Create child's children
        end
end
# ======================================================================================
# Copy an entire nested dictionary to another giving preference to values of "primary"
# ======================================================================================
function CopyDict(primary::Dict, secondary::Dict)
   allKeys = union([key for key in keys(primary)],[key for key in keys(secondary)])
    for key in allKeys
          if haskey(primary, key) && haskey(secondary, key)
                if isa(primary[key], Dict) # its a sub-Dict
                    CopyDict(primary[key], secondary[key])
                end
          elseif haskey(secondary, key) # secondary must have key. Just copy it!
                primary[key] = secondary[key]
          end
    end
end
# ======================================================================================
# Generate a layout Tree from the data stored in the DOM. This does not position the nodes
# in the page but only parses the DOM attributes to the Layout tree.
# ======================================================================================
function CreateShape(form::String, node::Element, h, w)

    if form == "circle"
        node.shape = Circle()
    # elseif form == "path"
    elseif form == "arc"
        node.shape = Arc()
    elseif form == "page" # alternatively I could use the familiar "body" tag for this!
        node.shape = NBox()
          node.shape.color = [1,1,1]
          node.shape.border = Border(0,0, 0,0, 0,0, "solid",[.8,.8,.8,1],[0,0,0,0])
          node.shape.width   = w
          node.shape.height  = h
          node.shape.flags[IsVScroll] = true # IsHScroll, IsVScroll
          node.shape.flags[FixedHeight] = true # Because it's the window!
          node.shape.flags[Clip] = true
    # elseif isAny(tag, boxes) !== nothing
    #             node.shape = NBox()
            # end
    else
        node.shape = NBox()
        if haskey(node.DOM, "text")
            # println(node.DOM["text"])
                node.font = Font()
                textnode = TextElement()
                textnode.shape = TextLine(node, node.DOM["text"])
                push!(node.children, textnode)
                # TODO: set text width as a default
                # something like this:
                    # ctx = CairoContext( CairoRGBSurface(0,0) )
                    # setTextContext(ctx, node)
                    # text_extents(ctx, node.shape.text )[3]
        end
    end
    # if  isAny(form, text) !== nothing # Any from the list
    #     #node.shape = NText()
    #     node.font = Font() # The actual text nodes are created later.
    # end
end
# ======================================================================================
# Parse something like this:   "M-2,2 L8,2.8"   to   [('M', [-2,2]),('L', [8,2.8])]
# WAS: ([A-Za-z])+([\s\d\.,-]*)
# ======================================================================================
function parsePathData(str)
           steps = matchall(r"([a-zA-Z] *(?:(?:-?\d*(?:\.\d+)?(?: *|,?)))*)", str)
           s = []
    for step in steps
        values = matchall(r"[\d\.-]+", step)
        fvals = map(x->parse(Float64,x), values)
        l = step[1]
        push!(s, (l, fvals))
    end
    return s
end
# ======================================================================================
#
# ======================================================================================
function DomToLayout(document::Page, node)

          DOM = node.DOM
          PageStyles = document.styles
          h, w = document.height ,document.width

      if haskey(DOM, "float")
          if DOM["float"] == "right"
              node.shape.flags[FloatRight] = true
          elseif DOM["float"] == "left"
              node.shape.flags[FloatLeft] = true
          end
      end
# "path":"M2,2 L8,2 L2,5 L8,5 L2,8 L8,8"
# b = "M2,2 L-8,2 L2,5 L8,5 L2,8 L8,8"

        # display:inline-block; height:21; padding:3;
        # width:100; color:0.6 0.6 0.6; margin:0 1 0 0;
        # border-radius:7 0 0 3; border-width:0 2 0 0; border-style:solid;
        # border-color:0.2 0.6 0.99;

      if haskey(DOM, "path")
                    node.shape.flags[HasPath] = true
                    properties
      end

      if haskey(DOM, "image")
                    node.shape.flags[HasImage] = true
      end
      if haskey(DOM, "radius")
          r =  DOM["radius"]
                    node.shape.radius = r
                    node.shape.width  = r*2
                    node.shape.height = r*2
      end

      if haskey(DOM, "opacity")
                    node.shape.opacity = DOM["opacity"]
                    node.shape.flags[HasOpacity] = true
      end
      if haskey(DOM, "color")
                    node.shape.color = GetTheColor(node.shape, DOM["color"])
      end

      if haskey(DOM, "linear-gradient")
        grad = DOM["linear-gradient"]
      #  "linear-gradient":{ "start":"left" "stops":[30,60,90], "colors":["red","green","blue"] },
        colorstops = []

              if haskey(grad, "start")
                str = grad["start"]
              end
              if haskey(grad, "colors")
                    steps = length(grad["colors"])
                    stops = []
                    if haskey(grad, "stops")
                        stops = fill(1.0, steps)
                        for j in 1:steps
                           stops[j] = grad["stops"][j]
                        end
                    else # automatically generate stop points
                        X = 1/(steps+1) # y = X/2
                        stops = collect(X:X:1)
                    end

                for i in 1:steps
                  color = GetTheColor(node.shape, grad["colors"][i])
                  if length(color) == 3
                    push!(color, 1.0)
                  end
                 push!(colorstops, [stops[i], color...]   )

                end
              end
              node.shape.gradient = colorstops
                node.shape.flags[LinearGrad] = true
      end
      if haskey(DOM, "radial-gradient")
                node.shape.flags[RadialGrad] = true
      end
      # This is for testing purposes!
      if haskey(DOM, "marked")
              node.shape.flags[Marked] = true
      end
      if haskey(DOM, "top")
              node.shape.top = DOM["top"]
      end
      if haskey(DOM, "left")
              node.shape.left = DOM["left"]
      end
      if haskey(DOM, "bottom")
              node.shape.top = DOM["bottom"]
              node.shape.flags[Bottom] = true
      end
      if haskey(DOM, "right")
              node.shape.left = DOM["right"]
              node.shape.flags[Right] = true
      end
      if haskey(DOM, "width")
              node.shape.width = DOM["width"]
      end
      if haskey(DOM, "height")
              node.shape.height = DOM["height"]
              node.shape.flags[FixedHeight] = true
      end

      if haskey(DOM, "vertical-align")
          if DOM["vertical-align"] == "bottom"
              node.shape.flags[AlignBase] = true
          elseif DOM["vertical-align"] == "middle"
              node.shape.flags[AlignMiddle] = true
          #else node.shape.flags[TextJustify] = true
          end
      end

      if haskey(DOM, "display")
          # like a <span> ...height/width are ignored
         if DOM["display"] == "inline"
              node.shape.width = 0
              node.shape.height = 0
              node.shape.flags[FixedHeight] = false
              node.shape.flags[DisplayInline] = true
         end
         # Like inline but with height/width
         if DOM["display"] == "inline-block"
             node.shape.flags[DisplayInlineBlock] = true
             node.shape.flags[LineBreakAfter] = true
         end
          # LineBreakBefore, LineBreakAfter,
          # set width has it's own row and set width/max-width ...default width is 100%
          if DOM["display"] == "block"
              node.shape.flags[DisplayBlock] = true
              node.shape.flags[LineBreakBefore] = true
              node.shape.flags[LineBreakAfter] = true
          end

          if DOM["display"] == "none"
              node.shape.flags[DisplayNone] = true
          end
          if DOM["display"] == "table"
              node.shape.flags[DisplayTable] = true
          end
         # DisplayBlock, DisplayInlineBlock, DisplayNone, DisplayTable, DisplayFlex,

      end
      #.........................................................................
      if haskey(DOM, "position")
          # like a <span> ...height/width are ignored
         if DOM["position"] == "fixed"
              node.shape.flags[Fixed] = true
         end
         if DOM["position"] == "absolute"
              node.shape.flags[Absolute] = true
              node.parent.shape.flags[HasAbsolute] = true
         end
         if DOM["position"] == "relative"
              node.shape.flags[Relative] = true
         end
     end

       #.........................................................................
#        b = false
#        bcolor = [0,0,0]
#        bradius = [0,0,0,0]
#        bstyle = "solid"
#        bwidth = [0,0,0,0, 0,0]
# if haskey(DOM, "border-color")
#     bcolor = GetTheColor(node.shape, DOM["border-color"]) #DOM["border-color"]
#     b=true
# end
# if haskey(DOM, "border-radius")
#     r = DOM["border-radius"]
#    if isa(r, Array)
#      bradius = r
#    else
#      bradius = [r,r,r,r]
#    end
#    node.shape.flags[IsRoundBox] = true # IsRoundBox
#     b=true
# end
#
# if haskey(DOM, "border-width")
#     w = DOM["border-width"]
#    if isa(w, Array) && length(w) == 4
#      bwidth = [ w[1],w[2],w[3],w[4],  w[1]+w[3], w[2]+w[4] ]
#    elseif isa(w, Number)
#      bwidth = [ w,w,w,w,  w*2, w*2 ]
#    else
#      if w == "thin"
#        bwidth = [1,1,1,1,  2,2]
#      end
#      if w == "medium"
#        bwidth = [3,3,3,3,  6,6]
#      end
#      if w == "thick"
#        bwidth = [4,4,4,4,  8,8]
#      end
#    end
#
#     b=true
# end
# if haskey(DOM, "border-style")
#     bstyle = DOM["border-style"]
#     b=true
# end
# if b == true
#     node.shape.border  = Border(bwidth... , bstyle, bcolor, bradius)
# end


if haskey(DOM, "border")
          border = DOM["border"]

          if haskey(border, "color")
            color = GetTheColor(node.shape, border["color"]) # only works for: [.5,.8,.8]
          end
          if haskey(border, "radius")
               r = border["radius"]
              if isa(r, Array)
                radius = r
            else
                radius = [r,r,r,r]
              end
              node.shape.flags[IsRoundBox] = true # IsRoundBox
          else
              radius = [0,0,0,0]
          end

          if haskey(border, "style")
              style = border["style"]
          else
              style = border["solid"] # default
          end

          if haskey(border, "width")
                  w = border["width"]
                 if isa(w, Array) && length(w) == 4
                   width = [ w[1],w[2],w[3],w[4],  w[1]+w[3], w[2]+w[4] ]
                 elseif isa(w, Number)
                   width = [ w,w,w,w,  w*2, w*2 ]
                 else
                   if w == "thin"
                     width = [1,1,1,1,  2,2]
                   end
                   if w == "medium"
                     width = [3,3,3,3,  6,6]
                   end
                   if w == "thick"
                     width = [4,4,4,4,  8,8]
                   end
                 end
          end
          node.shape.border  = Border(width... , style, color, radius)
      end
      #.........................................................................
      if haskey(DOM, "padding")
        p = DOM["padding"]
        padding = []
               if isa(p, Array)
                     if length(p) == 4
                       padding = [ p[1],p[2],p[3],p[4],  p[1]+p[3], p[2]+p[4] ]
                     end
                     if length(p) == 2
                       padding = [ p[1],p[2],p[1],p[2],  p[1]*2, p[2]*2 ]
                     end
               else
                 padding = [ p,p,p,p,  p*2, p*2 ]
               end
        node.shape.padding = BoxOutline(padding...)
      end
      #.........................................................................
      if haskey(DOM, "margin")
        p = DOM["margin"]
        margin = []
               if isa(p, Array)
                     if length(p) == 4
                       margin = [ p[1],p[2],p[3],p[4],  p[1]+p[3], p[2]+p[4] ]
                     end
                     if length(p) == 2
                       margin = [ p[1],p[2],p[1],p[2],  p[1]*2, p[2]*2 ]
                     end
               else
                 margin = [ p,p,p,p,  p*2, p*2 ]
               end
        node.shape.margin = BoxOutline(margin...)
      end
      #.........................................................................
# font-color:black; font-size:15; align:left; lineHeight:1.4; font-family:sans;

if haskey(DOM, "font-color") || haskey(DOM, "font-size") || haskey(DOM, "font-family")
    node.font = Font()

    if haskey(DOM, "font-color")
        node.font.color = GetTheColor(node.font, DOM["font-color"])
    end
    if haskey(DOM, "font-size")
        node.font.size = DOM["font-size"]
    end
    if haskey(DOM, "font-family")
        node.font.family = DOM["font-family"]
    end
    if haskey(DOM, "lineHeight")
        node.font.lineHeight = DOM["lineHeight"]
    end
    if haskey(DOM, "align")
        if DOM["align"] == "center"
            node.font.flags[TextCenter] = true
        elseif DOM["align"] == "right"
            node.font.flags[TextRight] = true
        end
    end


end
# "font-weight"  "font-size"  "font-family"  "font-style"  "font-color"  "font-gradient"
# "font-opacity"  "font-padding"  "font-border"  "font-margin"  "font-offset"
# "font-lineHeight"  "font-lineWidth"  "font-fill"  "vertical-align"  "align"
      if haskey(DOM, "font") # && isa(node.shape, F o n t)

          if !isdefined(node, :font)
              node.font = Font()
          end
        font = DOM["font"]
# "fill" "linewidth" "color" "align" "vertical-align" "style" "size" "lineHeight" "weight" "family"
        if haskey(font, "fill")
                node.font.fill = GetTheColor(node.shape, font["fill"])
                node.font.flags[TextPath] = true
        end
        if haskey(font, "linewidth")
                node.font.lineWidth = font["linewidth"]
                node.font.flags[TextPath] = true
        end
        if haskey(font, "color")
                node.font.color = GetTheColor(node.font, font["color"])
        end
        if haskey(font, "align")
            if font["align"] == "center"
                node.font.flags[TextCenter] = true
            elseif font["align"] == "right"
                node.font.flags[TextRight] = true
            #else node.shape.flags[TextJustify] = true
            end
        end

        if haskey(font, "vertical-align")
            if font["vertical-align"] == "bottom"
                node.font.flags[AlignBase] = true
            elseif font["vertical-align"] == "middle"
                node.font.flags[AlignMiddle] = true
            #else node.shape.flags[TextJustify] = true
            end
        end
        if haskey(font, "style")
                if font["style"] == "italic"
                    node.font.flags[TextItalic] = true
                elseif font["style"] == "oblique"
                    node.font.flags[TextOblique] = true
                end
        end
        if haskey(font, "size")
                node.font.size = font["size"]
        end
        if haskey(font, "lineHeight")
                node.font.lineHeight = font["lineHeight"]
                #node.font.height = node.shape.size * node.shape.lineHeight
        end
        if haskey(font, "weight")
          if font["weight"] == "bold"
              node.font.flags[TextBold] = true
          end
        end
        if haskey(font, "family")
                node.font.family = font["family"]
        end
      end

#...............Event Registration..................
      if haskey(DOM, "hover")
          #  = DOM["hover"]
      end
end # function

# ======================================================================================
#
# ======================================================================================
function AtributesToLayout(document::Page, node, generative::Bool=true)

    DOM = node.DOM # PageStyles = document.styles
    h, w = document.height, document.width

    if haskey(DOM, ">")
        tag = DOM[">"]

        # Attach events:
        # TODO: expound and move to separate function.
        if haskey(DOM, "mousedown")
            push!(document.eventsList.mousedown, node)
        end
        if haskey(DOM, "click")
            push!(document.eventsList.click, node)
        end
        if haskey(DOM, "hover")
            push!(document.eventsList.mouseover, node)
            push!(document.eventsList.mouseout, node)
        end
        # Create actual node.
        if generative
            if isa(tag, Array)
                println(DOM)
            else
                CreateShape(tag, node, h, w)
            end
        end

        # Add user defined styles to node's DOM.
        # if haskey(DOM, "style")
        #     style = DOM["style"]
        #     CopyDict(DOM, PageStyles[style])
        # end

        # Add default values generally associated with this tag
        CopyDict(DOM, Tags_Default[tag])
        DomToLayout(document, node)
    end
end
# ======================================================================================
#
# ======================================================================================

# ======================================================================================
# Dict{Any,Any}("nodes"=>Any[],">"=>Any["h", 1.0],"font"=>Dict{Any,Any}("nodes"=>Any[],"color"=>"white","align"=>"center"),"text"=>"Why reinvent the wheel?")
