include("ColorDefinitions.jl")
export AtributesToLayout
# ======================================================================================
# EX: GetTheColor(border["color"])
# CALLED FROM:
# ======================================================================================
function GetTheColor(node, DOMColor)
                if isa(DOMColor, Array)
                    if length(DOMColor) == 3
                        color = [DOMColor[1]+0.0,DOMColor[2]+0.0,DOMColor[3]+0.0]
                    else
                        color = [DOMColor[1]+0.0,DOMColor[2]+0.0,DOMColor[3]+0.0,DOMColor[4]+0.0]
                    end
                else
                    c = collect(color_names[ DOMColor ])
                    color = [c[1]*0.00390625, c[2]*0.00390625, c[3]*0.00390625]
                end
        # Opacity
          if node.shape.flags[HasOpacity] == true && length(color) == 3
            DOM = node.DOM
            if haskey(DOM, "opacity")
                push!(color, DOM["opacity"])
            end
          end
    return color
end
# ======================================================================================
function AtributesToLayout(document, node)
    DOM = node.DOM

    h, w = document.height ,document.width

    if haskey(DOM, ">")
      E = DOM[">"]
      if E == "div"
          node.shape = NBox()
      end

      if E == "circle"
          node.shape = Circle()
      end
      if E == "p"
          node.shape = NText()
      end
      if E == "arc"
          node.shape = Arc()
      end
      if E == "page"
          node.shape = NBox()
            node.shape.color = [1,1,1]
            node.shape.border = Border(0,0, 0,0, 0,0, "solid",[.8,.8,.8,1],[0,0,0,0])
            node.shape.width   = w
            node.shape.height  =  h
            node.shape.flags[IsVScroll] = true # IsHScroll, IsVScroll
            node.shape.flags[FixedHeight] = true # Because it's the window!
            node.shape.flags[Clip] = true
      end
      #.........................................................................""
      # if isa(node.shape, TextLine)
      #     shape = item.reference.shape
      # else
      #     shape = item.shape
      # end

      if haskey(DOM, "float")
          if DOM["float"] == "right"
              node.shape.flags[FloatRight] = true
          elseif DOM["float"] == "left"
              node.shape.flags[FloatLeft] = true
          end
      end


      if haskey(DOM, "image")
                    node.shape.flags[HasImage] = true
      end
      if haskey(DOM, "radius")
                    node.shape.radius = DOM["radius"]
      end
      if haskey(DOM, "text")
                    node.shape.text = DOM["text"]
      end
      if haskey(DOM, "opacity")

                    node.shape.flags[HasOpacity] = true
      end
      if haskey(DOM, "color")
                    node.shape.color = GetTheColor(node, DOM["color"])
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
                  color = GetTheColor(node, grad["colors"][i])
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
                # node.shape. = GetTheColor(node, DOM["gradient"])
                node.shape.flags[RadialGrad] = true
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
      if haskey(DOM, "display")
          # like a <span> ...height/width are ignored
         if DOM["display"] == "inline"
              node.shape.width = 0
              node.shape.height = 0
              node.shape.flags[FixedHeight] = false
              node.shape.flags[DisplayInline] = true
         end
         # LineBreakBefore, LineBreakAfter,
          # set width has it's own row and set width/max-width ...default width is 100%
          if DOM["display"] == "block"
              node.shape.flags[DisplayBlock] = true
              node.shape.flags[LineBreakBefore] = true
              node.shape.flags[LineBreakAfter] = true
          end
          # Like inline but with height/width
          if DOM["display"] == "inline-block"
              node.shape.flags[DisplayInlineBlock] = true
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
         end
         if DOM["position"] == "relative"
              node.shape.flags[Relative] = true
         end
     end

       #.........................................................................
if haskey(DOM, "border")
          border = DOM["border"]
             color = [0,0,0]
             radius = [0,0,0,0]
             style = "solid"
             width = [0,0,0,0, 0,0]
          if haskey(border, "color")
            color = GetTheColor(node, border["color"]) # only works for: [.5,.8,.8]
          end
          if haskey(border, "radius")
               r = border["radius"]
              if isa(r, Array)
                radius = r
              else
                radius = [r,r,r,r]
              end
              node.shape.flags[IsRoundBox] = true # IsRoundBox
          end
          if haskey(border, "style")
              style = border["style"]
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
      if haskey(DOM, "font")
        font = DOM["font"]



        if haskey(font, "fill")
                node.shape.fill = GetTheColor(node, font["fill"])
                node.shape.flags[TextPath] = true
        end
        if haskey(font, "linewidth")
                node.shape.lineWidth = font["linewidth"]
                node.shape.flags[TextPath] = true
        end
        if haskey(font, "color")
                node.shape.color = GetTheColor(node, font["color"])
        end
        if haskey(font, "align")
            if font["align"] == "center"
                node.shape.flags[TextCenter] = true
            elseif font["align"] == "right"
                node.shape.flags[TextRight] = true
            #else node.shape.flags[TextJustify] = true
            end
        end

        if haskey(font, "vertical-align")
            if font["vertical-align"] == "bottom"
                node.shape.flags[AlignBase] = true
            elseif font["vertical-align"] == "middle"
                node.shape.flags[AlignMiddle] = true
            #else node.shape.flags[TextJustify] = true
            end
        end
        if haskey(font, "style")
                if font["style"] == "italic"
                    node.shape.flags[TextItalic] = true
                elseif font["style"] == "oblique"
                    node.shape.flags[TextOblique] = true
                end
        end
        if haskey(font, "size")
                node.shape.size = font["size"]
        end
        if haskey(font, "lineHeight")
                node.shape.lineHeight = font["lineHeight"]
                node.shape.height = node.shape.size * node.shape.lineHeight
        end
        if haskey(font, "weight")
          if font["weight"] == "bold"
              node.shape.flags[TextBold] = true
          end
        end
        if haskey(font, "family")
                node.shape.family = font["family"]
        end
      end





      #"font":{"color":"black", "size":12,
      #  "style":"italic",
      #  "align":"left",
      #  "lineHeight":1.4,
      #  "weight":"bold",
      #  "family":"Georgia" },









    end



end # function
# ======================================================================================
