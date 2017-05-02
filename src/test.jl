# this file is just for scripting
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
a = Dict( "font"=>"sans", "text"=>Dict("string"=>"Hello dude!", "color"=>"green"))
b = Dict( "font"=>"gorgia", "text"=>Dict("string"=>"Hey man!"), "color"=>"purple")

c = CopyDict(a,b)
println(a)
