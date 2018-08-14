# Shaddow DOM defaults
# s = open("src/Data/tab.json") do file read(file, String) end

s = open(f->read(f, String), "src/Data/tab.json")
tab = JSON.parse(s)

s = open(f->read(f, String), "src/Data/tabControls.json")
tabControls = JSON.parse(s)

s = open(f->read(f, String), "src/Data/navigation.json")
navigation = JSON.parse(s)

newPage = Dict( ">" => "page", "display" => "block", "color" => [0.8,0.8,0.8], "nodes"   => [] )
