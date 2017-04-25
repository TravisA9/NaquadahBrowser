# ======================================================================================
# Create a node with default settings
# CALLED FROM: Above traceElementTree()
#   Instead of setting all the default variables it may be more sensible to test for
#   attributes and set defaults if none are explicitly set from the DOM. It would be
#   good to test for and set styles at the same time...
# ======================================================================================
function CreateDefaultNode(document::Page, parent::MyElement, DOM::Dict) # node::MyElement ,
    node = BuildElement(parent, DOM)
    #node = parent.node[end]
    SameThing(node, parent.node[end], "CreateDefaultNode(), file: BuildDefaultNode.jl")

  defaults = Dict()
  # take into account that multiple styles may be applied.
  # Styles should probably be merged...
  styles = Dict()
  # set styles..............................................
  # set defaults..............................................
  # NOTE: move from most important to least. Example:
  #       imediate-styles -> ID-style -> last-class-style -> ... -> first-class-style -> default-style
 # if haskey(DOM, "class")
#      # TODO: Test if is Array and work out selector logic
#      class = DOM["class"]
#      if haskey(document.styles, class)
#          styles = document.styles[class]
#          SetAllAttributes(document,node,styles)
#      else
          # print("The class: $(class) not found!\n") # content
#      end
  #else
  #end
    if haskey(DOM, "class")
      tag = DOM["class"]
      if isa(tag,Array)
          for i in 1:length(tag)
              class = tag[i]
              if haskey(document.styles, class)
                  style = document.styles[class]
                  MergeAttributes(DOM, style)
              end
          end
      else
          if haskey(document.styles, tag)
              style = document.styles[tag]
              MergeAttributes(DOM, style)
          end
      end
    end  # END:

    if haskey(DOM, ">")
      tag = DOM[">"]
      if haskey(Tags_Default, tag)
          defaults = Tags_Default[tag]
          MergeAttributes(DOM, defaults)
      end
    end  # END: haskey(DOM, ">")


    if haskey(DOM, "overflow")
      tag = DOM["overflow"]

      # SHADDOW DOM:..............................................

      if tag == "scroll"
            if !haskey(DOM,"nodes")
              DOM["nodes"] = []
            end
            nodes = DOM["nodes"]
            hScrollbar = Tags_Default["h-scroll"]
            hScrollbar[">"] = "h-scroll"
            push!(nodes,hScrollbar)
            vScrollbar = Tags_Default["v-scroll"]
            vScrollbar[">"] = "v-scroll"
            push!(nodes,vScrollbar)
      end
    end
    # BoxDesign(document,node,DOM)
    SetAllAttributes(document,node,DOM)
    # scrollbar-track scrollbar-thumb

    #return node
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
    Copy(primary, secondary, "text-color")



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
                # radius, style, width, color
                          Copy(border, defaultborder, "radius")
                          Copy(border, defaultborder, "style")
                          Copy(border, defaultborder, "width")
                          Copy(border, defaultborder, "color")
              end
        end
end
