# Shaddow DOM defaults
s = open(".julia/v0.6/NaquadahBrowser/src/Data/tab.json") do file
    read(file, String)
end
tab = JSON.parse(s)

s = open(".julia/v0.6/NaquadahBrowser/src/Data/tabControls.json") do file
    read(file, String)
end
tabControls = JSON.parse(s)

s = open(".julia/v0.6/NaquadahBrowser/src/Data/navigation.json") do file
    read(file, String)
end
navigation = JSON.parse(s)

newPage = Dict( ">" => "page", "display" => "block", "color" => [0.8,0.8,0.8], "nodes"   => [] )
