# export GetTheColor, printDict
# ======================================================================================
# EX: GetTheColor(border["color"])
# Get color depending on format and add opacity to it.
# ======================================================================================
function GetTheColor(shape, DOMColor)
    shape == nothing && return [0,0,0,1]
    if isa(DOMColor, Array)
        color = DOMColor
                # elseif isa(DOMColor, Float64)
    elseif isa(DOMColor, String)
        if DOMColor[1:1] == "#"
            if length(DOMColor) == 7
                color = [ parse(Int, DOMColor[2:3], base = 16)*0.00390625,
                parse(Int, DOMColor[4:5], base = 16)*0.00390625,
                parse(Int, DOMColor[6:7], base = 16)*0.00390625 ]
            elseif length(DOMColor) == 4
                color = [ parse(Int, DOMColor[2:2]^2, base = 16)*0.00390625,
                parse(Int, DOMColor[3:3]^2, base = 16)*0.00390625,
                parse(Int, DOMColor[4:4]^2, base = 16)*0.00390625 ]
            end
        else
            color = collect(color_names[ DOMColor ]).*0.00390625
        end
                    # println("Color is $DOMColor")
    end

    if shape.flags[HasOpacity] && length(color) == 3
        color = [color... , shape.opacity]
                    #push!(color, shape.opacity)
    end

    return color
end
# ======================================================================================
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


include("parseSml.jl")
include("ElementDefaults.jl")
include("DomTree.jl")
include("DomBuildDefault.jl")
include("DomShadow.jl")
include("DomToLayout.jl")
