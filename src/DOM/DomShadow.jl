"""
## Shaddow DOM defaults

Default styling for the following shadow DOM items:

icons, downloadIcon, downloadIcon, NewPageIcon, JuliaIcon, button, tab,
tabControls, navigation, navBar, newPage


[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomShadow.jl#L13)
"""
# export windowControls, newPage
icons = Dict(     ">"       => "div", "display" => "inline-block", "height"  => 27, "width"=>145,
                  "nodes"   => [
                  Dict(">"=>"circle", "margin"=>[5,3,4,4], "radius"=>12, "image"=>"Back.png",
                  "border"  => Dict( "width"=>"thin", "style"=>"solid", "color"=>[0.4,0.4,0.4] )),
                  Dict(">"=>"circle", "margin"=>[5,3,4,4], "radius"=>12, "image"=>"Reload.png"),
                  Dict(">"=>"circle", "margin"=>[5,3,4,4], "radius"=>12, "image"=>"Forward.png"),
                  Dict(">"=>"circle", "margin"=>[5,3,4,4], "radius"=>12, "image"=>"Start.png")
                  ]
)
# Dict(">"=>"div", "display" => "inline-block", "width"=>20, "height"=>20, "image"=>"Search.png", "color"=>"lightgreen"),
downloadIcon = Dict(">"=>"circle","display" => "inline-block", "float"=>"right", "margin"=>[5,5,4,4], "radius"=>10, "image"=>"Download.png")
NewPageIcon = Dict(">"=>"circle","display" => "inline-block", "margin"=>[5,2,4,4], "radius"=>12, "image"=>"NewPage.png")
JuliaIcon = Dict(">"=>"circle","display" => "inline", "color"=> [1,1,1], "margin"=>[5,1,4,0], "radius"=>8, "image"=>"JuliaIcon.png")

button = Dict(  ">" => "div", "display" => "inline", "height"  => 15, "color"=>[0.3,0.3,0.3],
                "margin"=>[5,3,6,2],
                "border"  => Dict( "radius"=>[9,3,9,3], "width"=>[1,1,1,1], "style"=>"solid", "color"=>[0.2,0.2,0.2] ),
                "nodes"   => [] )

tab = Dict(       ">"       => "div",
                  "display" => "inline-block",
                  "height"  => 21,
                  "padding" => 3,
                  "width"   => 100,
                  "color"   => [0.6,0.6,0.6],
                  "border"  => Dict( "radius"=>[7,0,0,3], "width"=>[0,2,0,0], "style"=>"solid", "color"=>[0.2,0.6,0.99] ),
                  "nodes"   => [
                          Dict(">"=>"circle","display" => "inline-block", "margin"=>2, "radius"=>8, "color"=>"pink", "image"=>"Atlantis.png"                         ),
                          Dict(">"=>"p",
    							"font"=> Dict( "color"=>"black", "size"=>15, "align" => "center", "lineHeight"=>1.4, "family"=>"sans" ),
    							"text"=>"Tab!" ),
                          Dict(">"=>"circle","display" => "inline-block", "position" => "absolute", "right" => 0,
                                "top"=>5, "radius"=>5, "image"=>"close.png")
                  ]
)

tabControls = Dict(
                  ">"       => "div",
                  "display" => "block",
                  "padding" => [2,2,2,0],
                  "height"  => 27,
                  "color"   => [0.4,0.4,0.4],
                  "border"  => Dict( "width"=>[0,0,0,1], "style"=>"solid", "color"=>[0.3,0.3,0.3] ),
                  "nodes"   => []
)
navigation = Dict(
                  ">"       => "div",
                  "display" => "block",
                  "padding" => [4,4,4,4],
                  "height"  => 30,
                  "color"   => [0.6,0.6,0.6],
                  "border"  => Dict("width"=>[0,0,0,1], "style"=>"solid", "color"=>[0.5,0.5,0.5] ),
                  "nodes"   => []
)
navBar = Dict(    ">"       => "div", "display" => "inline-block", "height" => 22, "padding"=> [3,4,3,3], "width"=> 300,
                  "color"   => [0.9,0.9,0.9],
                  "border"  => Dict( "radius"=>[5,5,5,5], "width"=>"thin", "style"=>"solid", "color"=>[0.3,0.3,0.3] ),
                  "nodes"   => [
                        Dict(">"=>"div", "width"=>20, "height"=>20, "image"=>"Search.png", "color"=>"lightgreen"),
                      Dict(">"=>"p","display" => "inline",
                          "font"=> Dict( "color"=>"black", "size"=>15, "align"=>"left", "lineHeight"=>1.4, "family"=>"sans" ),
                          "text"=>"file:///src/SamplePages/test.json" )
                  ]
)

newPage = Dict(   ">"       => "page", "display" => "block", "color" => [0.8,0.8,0.8], "nodes"   => [] )
