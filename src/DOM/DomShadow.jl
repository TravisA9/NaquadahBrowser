# Shaddow DOM defaults

s = open(f->read(f, String), "src/Data/tab.sml")
tab = readSml(s)[1]

s = open(f->read(f, String), "src/Data/navigation.sml")
navigation = readSml(s)

s = open(f->read(f, String), "src/Data/tabControls.sml")
tabControls = readSml(s)[1]

newPage = Dict( ">" => "page", "display" => "block", "color" => [0.8,0.8,0.8], "nodes"   => [] )
