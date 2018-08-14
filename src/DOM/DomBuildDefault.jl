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
