

export
          # Structural:
          Element, Row, NText,
          # General utility:
          Point, Square,
          # Drawable Shapes:
          NBox, Circle, Arc, TextLine,
          # Constructors:
          Border, BoxOutline



abstract Geo


macro import_fields(t)
  tt = eval(t)
  fields = fieldnames(tt)
  ex = :()
  for i = 1:length(fields)
    ft = fieldtype(tt, fields[i])
    if i==1
      ex = :($(fields[i])::$(ft))
    else
      ex = :($ex ; $(fields[i]) :: $(ft))
    end
  end
  return ex
end






type Scroller <: Geo
    x::Float32
    y::Float32
    contentWidth::Float32
    contentHeight::Float32
    Scroller() = new(0,0,0,0)
end
#-------------------------------------------------------------------------------
type Point <: Geo
    x::Float32
    y::Float32
    Point(x,y) = new(x,y)
end
#-------------------------------------------------------------------------------
type Row
    flags::BitArray{1} #Any
    nodes::Array{Any}
    height::Float32
    width::Float32 # because elements could be wider than the parent
    space::Float32 # Space remaining 'til full
    x::Float32
    y::Float32
    # Row() = new(falses(32),[],0,0,0,0,0)
    # Row(x, wide) = new(falses(32),[],0,0,wide,x,0)
    Row(x, y, wide) = new(falses(32),[],0,0,wide,x,y)
    function Row(rows, x, y, w)
        r = Row(x, y, w)
        push!(rows,r)
        return r
    end
end
#-------------------------------------------------------------------------------
type Element
    DOM::Dict       # Reference to dictionary counterpart of this node
    parent::Any               # This node's parent
    children::Array{Element,1} # Children in order they appear in DOM
    rows::Array{Row,1} # A layout property
    shape::Any # link to layout representation of node
    scroll::Scroller # Since shape get's destroyed we need the scroll-offsets here (prabably should be Nullable).
        function Element(DOM=Dict())
            parent = nothing
            children::Array{Element,1} = []
            new(DOM, parent, children, [], nothing, Scroller())
        end
end
#-------------------------------------------------------------------------------
type BoxOutline <: Geo
    left::Float32
    top::Float32
    right::Float32
    bottom::Float32
    width::Float32
    height::Float32
end
type Square <: Geo
    left::Float32
    top::Float32
    width::Float32
    height::Float32
end

#-------------------------------------------------------------------------------
abstract Draw <: Geo
type Border <: Geo
    left::Float32
    top::Float32
    right::Float32
    bottom::Float32
    width::Float32
    height::Float32

    style::Any
    color::Array # this may be an array of arrays in the case that each side has a different color
    radius::Nullable{Array}
    Border(left,top, right,bottom, width,height, style,color,radius) = new(left,top, right,bottom, width,height, style,color,radius)
end
# ==============================================================================  <: Shape

type BasicShape <: Draw
    flags::BitArray{1}
    color::Array
    gradient::Array
    opacity::Float32
    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    left::Float32
    top::Float32
    width::Float32
    height::Float32
    BasicShape() = new(falses(64), [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0)
end
function Shape()
    return (falses(64), [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0)
end
# ==============================================================================
# ==============================================================================
# ==============================================================================
# ==============================================================================
type NBox <: Draw
     @import_fields(BasicShape)
    NBox() = new( falses(64), [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0 )
end

type Circle <: Draw
     @import_fields(BasicShape)
    radius::Float32
    Circle() = new(falses(64), [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0,
                    0,)
end
# Box, RoundBox, Arc, Circle, Line, Curve, Text, Ellipse
# Polygon, Polyline, Path
type Arc <: Draw
     @import_fields(BasicShape)
    radius::Float32
    origin::Point
    startAngle::Float32
    stopAngle::Float32
    Arc() = new(0, Point(0,0), 0,0)
end

#=---------------------------------=#
type NText <: Draw
   @import_fields(BasicShape)
    text::String
    size::Float32
    lineHeight::Float16
    family::String
    fill::Array
    lineWidth::Float32
    NText() = new(falses(64), [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0,
                   "", 12, 1.4,  "Sans", [], 1 )
end
#=---------------------------------=#
type TextLine <: Draw
    flags::BitArray{1}
    reference::Any
    text::String
    left::Float32
    top::Float32
    width::Float32
    height::Float32
    TextLine(MyText,   text, left, top, width, height) = new(falses(64),   MyText, text, left, top, width, height)
    TextLine(MyText, text, left, top) = new(falses(64), MyText, text, left, top,0,0)
end

#==============================================================================#

#==============================================================================#
