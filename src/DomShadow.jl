
# export windowControls, newPage
icons = Dict(     ">"       => "div", "display" => "inline-block", "height"  => 27, "width"=>145,
                  "nodes"   => [
                  Dict(">"=>"circle", "margin"=>[5,3,4,4], "radius"=>12, "image"=>"Back.png"),
                  Dict(">"=>"circle", "margin"=>[5,3,4,4], "radius"=>12, "image"=>"Reload.png"),
                  Dict(">"=>"circle", "margin"=>[5,3,4,4], "radius"=>12, "image"=>"Forward.png"),
                  Dict(">"=>"circle", "margin"=>[5,3,4,4], "radius"=>12, "image"=>"Start.png")
                  ]
)
downloadIcon = Dict(">"=>"circle", "margin"=>[5,5,4,4], "radius"=>10, "image"=>"Download.png")
NewPageIcon = Dict(">"=>"circle", "margin"=>[5,2,4,4], "radius"=>12, "image"=>"NewPage.png")
JuliaIcon = Dict(">"=>"circle", "color"=> [1,1,1], "margin"=>[5,2,4,4], "radius"=>10, "image"=>"JuliaIcon.png")

tab = Dict(       ">"       => "div",
                  "display" => "inline-block",
                  "height"  => 25,
                  "padding" => 3,
                  "width"   => 100,
                  "color"   => [0.8,0.8,0.8],
                  "border"  => Dict( "radius"=>[11,0,0,5], "width"=>[1,1,1,0], "style"=>"solid", "color"=>[0.3,0.3,0.3] ),
                  "nodes"   => [
                          Dict(">"=>"circle","display" => "inline-block", "margin"=>2, "radius"=>8, "color"=>"pink", "image"=>"Atlantis.png"                         ),
                          Dict(">"=>"p","display" => "inline-block",
    							"font"=> Dict( "color"=>"black", "size"=>15, "align"=>"left", "lineHeight"=>1.4, "family"=>"sans" ),
    							"text"=>"Tab!" ),
                          Dict(">"=>"circle","display" => "inline-block", "position" => "absolute", "right" => 0,
                                "top"=>5, "radius"=>5, "image"=>"close.png")
                  ]
)

tabControls = Dict(
                  ">"       => "div",
                  "display" => "block",
                  "padding" => [2,2,2,0],
                  "height"  => 26,
                  "color"   => [0.6,0.6,0.6],
                  "border"  => Dict( "width"=>[0,0,0,1], "style"=>"solid", "color"=>[0.3,0.3,0.3] ),
                  "nodes"   => []
)
navigation = Dict(
                  ">"       => "div",
                  "display" => "block",
                  "padding" => [4,4,4,4],
                  "height"  => 30,
                  "color"   => [0.8,0.8,0.8],
                  "border"  => Dict("width"=>[0,0,0,1], "style"=>"solid", "color"=>[0.5,0.5,0.5] ),
                  "nodes"   => []
)
navBar = Dict(    ">"       => "div", "display" => "inline-block", "height"  => 22, "width"=> 300, "padding"=> [3,4,3,3],
                  "color"   => [1,1,1],
                  "border"  => Dict( "radius"=>[5,5,5,5], "width"=>"thin", "style"=>"solid", "color"=>[0.3,0.3,0.3] ),
                  "nodes"   => [
                      Dict(">"=>"circle","display" => "inline-block", "margin"=>2, "radius"=>10, "image"=>"Search.png"                         ),
                      Dict(">"=>"p","display" => "inline-block",
                          "font"=> Dict( "color"=>"black", "size"=>15, "align"=>"left", "lineHeight"=>1.4, "family"=>"sans" ),
                          "text"=>"file:///src/SamplePages/test.json" )
                  ]
)

newPage = Dict(   ">"       => "page", "display" => "block", "color" => [0.8,0.8,0.8], "nodes"   => [] )
