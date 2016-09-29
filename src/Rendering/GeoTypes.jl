#======================================================================================#
# Border
# Line, Circle, LineNode
# Text
# MyBox
# MyElement
# Row
#======================================================================================#

# THOUGHTS: it may be best to only store esential data like left, top, right, bottom
#           and create methods to derive width, height, center, etc.
#
# BoundingMyBox from graphics.jl
#=---------------------------------=#
type Border
    left::Float32
    right::Float32
    top::Float32
    bottom::Float32
    width::Float32
    height::Float32

    style::Any
    color::Array # this may be an array of arrays in the case that each side has a different color
    radius::Nullable{Array}
    Border(left,right, top,bottom, width,height,style, color,radius) = new(left,right, top,bottom, width,height,style, color,radius)
end
#=---------------------------------=#
type Line
     text::String # The actual line of text
    space::Float16     # The extra space left in the line
    words::Float16     # Number of words in the line
    Line(text,space,words) = new(text,space,words)
end
#=---------------------------------=#
type Text
     lines::Array
     top::Float32
     left::Float32

     color::Array
     size::Float16
     style::String
     weight::String
     lineHeight::Float16
     align::String # TODO: this should really be a flag to make things go faster!
     family::String
     Text() = new([],0,0,[],1,"normal","normal",1,"left","SANS")
     #Text(lines,top,left,color,size,style,weight,lineHeight,align,family) = new(lines,top,left,color,size,style,weight,lineHeight,align,family)
    # Text(lines,top, left,color) = new(left,right, top,bottom, width,height, [],[])
end
#=---------------------------------=#
type Circle # also use for ark...
    center::Array{Float32,1}
    radius::Float32
    angle::Array{Float32,1}
    Circle(center, radius, angle) = new(center, radius, angle)
end
#=---------------------------------=#
type LineNode # data to draw line
    coords::Array{Float32,1}
    length::Float32
    angle::Float32
    LineNode(coords, length, angle) = new(coords, length, angle)
end
#=---------------------------------=#
type MyBox
    left::Float32
    right::Float32
    top::Float32
    bottom::Float32
    width::Float32
    height::Float32
    MyBox(left,right, top,bottom, width,height) = new(left,right, top,bottom, width,height)
end
#=---------------------------------=#
# Not unlike GdkRectangle in cairo's gdk.jl
type Box
    left::Float32
    width::Float32
    top::Float32
    height::Float32
    Box(left,width, top,height) = new(left,width, top,height)
end
 #get(area) = area.xmax
 #getheight(area) = area.ymax
 getcenterx(area::Box) = area.left + (area.width /2)
 getcentery(area::Box) = area.top  + (area.height /2)

 Right(area::Box)  = area.left + area.width
 Bottom(area::Box) = area.top  + area.height

#=---------------------------------=#
type Walls
    left::Float32
    right::Float32
    top::Float32
    bottom::Float32
    Walls(left,right, top,bottom) = new(left,right, top,bottom)
end

#=---------------------------------=#
type Point
    x::Float32
    y::Float32
    Point(x,y) = new(x,y)
end
# This type and its compoents vary greatly.
# I am still deciding which is the best way to deal with the variability
# without slowing or complicating things.
# Nullable is ok but I'm not yet convinced...
type MyElement
    area::Box   # We will derive all our positioning values from here.
    box::Box         # Background area and box width and height (the two should probably be seperated!)
    content::Box       # Content area Values

    margin::Nullable{MyBox}        # Margin Values
    padding::Nullable{MyBox}       # Padding values
    border::Nullable{Border}     # Border Values
    text::Nullable{Text}         # This is an uninstantiated text PsudoNode
    href::Nullable{String}   # Link?

    shape::Any

    x::Float32           # Current x offset
    y::Float32           # Current y offset
    height::Float32      # Row height
    vOffset::Float32     # Offset from default position
    hOffset::Float32     # Offset from default position

    flags::Any

    opacity::Float32     # node opacity
    color::Array{Float32,1}         # background color

        parent::Any        # parent MyElement
        node::Array        # children of type MyElement
        DOM::Any        # Link to dictionary counterpart
    MyElement()  = new( Box(0,0,0,0), Box(0,0,0,0), Box(0,0,0,0),
                        Nullable{MyBox}(), Nullable{MyBox}(),
                        Nullable{Border}(), Nullable{Text}(),
                        Nullable{String}(),
                        0,
                        0,0,0, 0,0,
                        falses(64),
                        0,[],
                        0,[],0)
    # BoundingMyBox() = BoundingMyBox(NaN, NaN, NaN, NaN)
end
#=---------------------------------=#
# I think that 'Row' is only needed temporarily and could be pushed and popped
#=---------------------------------=#
type Row
    left::Array
    right::Array
    Row(left,right, top,bottom, width,height) = new(left,right, top,bottom, width,height)
end
