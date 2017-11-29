# ======================================================================================

"""
## CreateDefaultNode(document::Page, parent::Element, DOM::Dict)

Create a node with default settings
CALLED FROM: Above traceElementTree()
Instead of setting all the default variables it may be more sensible to test for
attributes and set defaults if none are explicitly set from the DOM. It would be
good to test for and set styles at the same time...

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomBuildDefault.jl#L15)
"""
# ======================================================================================
function CreateDefaultNode(document::Page, parent::Element, DOM::Dict) # node::MyElement ,
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
"""
## Copy(primary::Dict, secondary::Dict, attribute::String)

Copy secondary attribute to primary. Sugar.

# Examples
```julia-repl
julia> prim = Dict( "thing" => "hello" )
julia> sec  = Dict( "thing" => "hello", "otherThing" => "world!")
julia> Copy(prim, sec, "something")
julia>

```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomBuildDefault.jl#L54)
"""
# ======================================================================================
function Copy(primary::Dict, secondary::Dict, attribute::String)
      if !haskey(primary, attribute) && haskey(secondary, attribute)
          primary[attribute] = secondary[attribute]
      end
end
# ======================================================================================
function CopyLoop(primary, secondary, attributelist)
    for attribute in attributelist
        if !haskey(primary, attribute) && haskey(secondary, attribute)
            primary[attribute] = secondary[attribute]
        end
    end
end

#   list, table, text, column, color, border, padding, margin, background, font,
#   position, display, z-index,
#
# nodes:, events:, transforms:,
#
# top-level: { font:, border:, hover:, position, text, href, display, width, height, color, padding, margin, , , ,  }
# font:{ color, size, style, align, lineHeight, weight, family },
# border:{ radius, style, width, color }
# EVENTS: mousedown, mouseup, click, drag, hover
"""
## MergeAttributes(primary::Dict, secondary::Dict)
CALLED FROM: Above CreateDefaultNode()


Take primary's attributes and fill in gaps with secondary's as fallback/default.
Must be carried out in the order from most important to least:
imediate-styles -> ID-style -> last-class-style -> ... -> first-class-style -> default-style

Similat to `Copy()` but more detailed.

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomBuildDefault.jl#L134)
"""
# ======================================================================================
function MergeAttributes(primary::Dict, secondary::Dict)

    # Top-Level........................................
    # hover:, position, text, href, display, width, height, color, padding, margin
    list = ["hover", "position", "text", "href", "display", "width", "height",
            "color", "padding", "margin", "opacity", "z-index", "gradient",
             "text-color", "center", "radius", "angle"]

             CopyLoop(primary, secondary, list)
    # FONT.............................................
        if haskey(secondary, "font")
              if !haskey(primary, "font")
                primary["font"] = secondary["font"]
              else
                font = primary["font"]
                defaultfont = secondary["font"]
                    list = ["color", "size", "style", "weight", "lineHeight", "family", "align", "text-decoration"]
                CopyLoop(font, defaultfont, list)
              end
        end

    # BORDER.............................................
        if haskey(secondary, "border")
              if !haskey(primary, "border")
                primary["border"] = secondary["border"]
              else
                border = primary["border"]
                defaultborder = secondary["border"]
                list = ["color", "radius", "width", "style"]
                CopyLoop(border, defaultborder, list)
              end
        end
end
