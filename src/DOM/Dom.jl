# export GetTheColor, printDict

# ======================================================================================
# EX: GetTheColor(border["color"])
# Get color depending on format and add opacity to it.
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
                    # println("opacity: ", typeof(color))
                    # println("opacity: ", color)
                end

    return color
end
# ======================================================================================
# Print out Element's DOM but not children
# Print out Element's DOM but not children
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
