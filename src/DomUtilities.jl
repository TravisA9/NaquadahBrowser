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
# Print out Element's DOM but not children
# CALLED FROM:
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

#=
function printDict(DOM)

    dict = copy(DOM)
    if haskey(dict, "nodes")
        dict["nodes"] = "[...]"
    end

       keyList = sort(collect(keys(dict)))
       str, key, value = "","",""
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
=#
