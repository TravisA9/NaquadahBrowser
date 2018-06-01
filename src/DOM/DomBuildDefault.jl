# ======================================================================================
# ======================================================================================
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
# """
# ## MergeAttributes(primary::Dict, secondary::Dict)
# CALLED FROM: Above CreateDefaultNode()
#
#
# Take primary's attributes and fill in gaps with secondary's as fallback/default.
# Must be carried out in the order from most important to least:
# imediate-styles -> ID-style -> last-class-style -> ... -> first-class-style -> default-style
#
# Similat to `Copy()` but more detailed.
#
# [Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomBuildDefault.jl#L134)
# """
# ======================================================================================
# function MergeAttributes(primary::Dict, secondary::Dict)
#
#     # Top-Level........................................
#     # hover:, position, text, href, display, width, height, color, padding, margin
#     list = ["hover", "position", "text", "href", "display", "width", "height",
#             "color", "padding", "margin", "opacity", "z-index", "gradient",
#              "text-color", "center", "radius", "angle"]
#
#              CopyLoop(primary, secondary, list)
#     # FONT.............................................
#         if haskey(secondary, "font")
#               if !haskey(primary, "font")
#                 primary["font"] = secondary["font"]
#               else
#                 font = primary["font"]
#                 defaultfont = secondary["font"]
#                 list = ["color", "size", "style", "weight", "lineHeight", "family",
#                 "align", "text-decoration"]
#                 CopyLoop(font, defaultfont, list)
#               end
#         end
#
#     # BORDER.............................................
#         if haskey(secondary, "border")
#               if !haskey(primary, "border")
#                 primary["border"] = secondary["border"]
#               else
#                 border = primary["border"]
#                 defaultborder = secondary["border"]
#                 list = ["color", "radius", "width", "style"]
#                 CopyLoop(border, defaultborder, list)
#               end
#         end
# end
