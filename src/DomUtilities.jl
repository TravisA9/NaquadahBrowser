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
