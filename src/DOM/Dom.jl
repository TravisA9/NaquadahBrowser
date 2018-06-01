# export GetTheColor, printDict

# ======================================================================================
# EX: GetTheColor(border["color"])
# CALLED FROM:
"""
## GetTheColor(node, DOMColor)

Get color depending on format and add opacity to it.

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomUtilities.jl#L12)
"""
# ======================================================================================
function GetTheColor(shape, DOMColor)
                if isa(DOMColor, Array)
                    color = DOMColor
                else
                    color = collect(color_names[ DOMColor ]).*0.00390625
                end

                if shape.flags[HasOpacity] && length(color) == 3
                    color = [color... , shape.opacity]
                    #push!(color, shape.opacity)
                    println("opacity: ", typeof(color))
                    println("opacity: ", color)
                end

    return color
end
# ======================================================================================
# Print out Element's DOM but not children
# CALLED FROM:
"""
## printDict(DOM)

Print out Element's DOM but not children

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomUtilities.jl#L43)
"""
# ======================================================================================
function printDict(DOM)

    dict = copy(DOM)
    dict["nodes"] = "[...]"
    #contents = []

       keyList = sort(collect(keys(dict)))
       str, key, value = "H","",""
           for k in 1:length(keyList)
             key = keyList[k]
               if isa(dict[key], Dict)
                 value = "{ $(printDict(dict[key])) } "
               else
                 value = dict[keyList[k]]
               end
               if k != 1; key = ", $(key)"; end
            str =   "$(str)$(key):$(value)"
           end
    println(str)
    # return str
end


include("ElementDefaults.jl")
include("DomTree.jl")
include("DomBuildDefault.jl")
include("DomShadow.jl")
include("DomToLayout.jl")
#include("DomUtilities.jl")
