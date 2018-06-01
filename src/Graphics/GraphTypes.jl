

export
          # Structural:
          Font,
          # General utility:
          Point, Square,
          # Drawable Shapes:
          NBox, Circle, Arc, TextLine,
          # Constructors:
          Border, BoxOutline
# ======================================================================================
# ======================================================================================
abstract type Geo end

mutable struct Point
    x::Float64
    y::Float64
    Point(x,y) = new(x,y)
end



"""
## Types exported from Graphics

# Examples
```julia-repl
# Structural:
Element, Row, LastRow, Font,
# General utility:
Point, Square,
# Drawable Shapes:
NBox, Circle, Arc, TextLine,
# Constructors:
Border, BoxOutline
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L3)
"""
#-------------------------------------------------------------------------------
# currently not being used..
#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
mutable struct BoxOutline <: Geo
    left::Float64
    top::Float64
    right::Float64
    bottom::Float64
    width::Float64
    height::Float64
end
mutable struct Square <: Geo
    left::Float64
    top::Float64
    width::Float64
    height::Float64
end

#-------------------------------------------------------------------------------
abstract type Draw <: Geo end
mutable struct Border <: Geo
    left::Float64
    top::Float64
    right::Float64
    bottom::Float64
    width::Float64
    height::Float64

    style::Any # maybe AbstractString
    color::Vector{Float32} # this may be an array of arrays in the case that each side has a different color
    radius::Nullable{Array}
    Border(left,top, right,bottom, width,height, style,color,radius) = new(left,top, right,bottom, width,height, style,color,radius)
end
# ==============================================================================  <: Shape

mutable struct BasicShape <: Draw
    flags::BitArray{1}
    color::Vector{Any}
    gradient::Vector{Any}
    opacity::Any
    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    left::Float64
    top::Float64
    width::Float64
    height::Float64
    BasicShape() = new(falses(64), [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0)
end
function Shape()
    return (falses(64), [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0)
end
# ==============================================================================
# ==============================================================================
# ==============================================================================
# ============================================================================== TextLine, Circle, NBox
mutable struct NBox <: Draw
    flags::BitArray{1}
    color::Vector{Any}
    gradient::Vector{Any}
    opacity::Any
    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    left::Float64
    top::Float64
    width::Float64
    height::Float64
    NBox() = new( falses(64), [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0 )
end

mutable struct Circle <: Draw
    flags::BitArray{1}
    color::Vector{Any}
    gradient::Vector{Any}
    opacity::Any
    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    left::Float64
    top::Float64
    width::Float64
    height::Float64
    radius::Float64
    Circle() = new(falses(64), [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0,0,)
end
# Box, RoundBox, Arc, Circle, Line, Curve, Text, Ellipse
# Polygon, Polyline, Path
mutable struct Arc <: Draw
    flags::BitArray{1}
    color::Vector{Any}
    gradient::Vector{Any}
    opacity::Any
    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    left::Float64
    top::Float64
    width::Float64
    height::Float64
    radius::Float64
    origin::Point
    startAngle::Float64
    stopAngle::Float64
    Arc() = new(0, Point(0,0), 0,0)
end

#=---------------------------------=#
mutable struct Font #<: Draw
    flags::BitArray{1}
    color::Vector{Any}
    gradient::Vector{Any}
    opacity::Any
    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    size::Float64
    lineHeight::Float16
    family::String
    fill::Vector{Float32}
    lineWidth::Float64
    Font() = new( falses(64),
        [], [], 1, Nullable{BoxOutline}(), Nullable{Border}(), Nullable{BoxOutline}(), Nullable{Point}(),
        12, 1.4,  "Sans", [], 1 )
end
#=---------------------------------=#
# This is inserted as if a normal Element node and yet is also treated as a shape.
mutable struct TextLine <: Draw
    flags::BitArray{1}
    parent::Any # Because Element()s have parents
    text::String #
    left::Float64
    top::Float64
    width::Float64
    height::Float64
    TextLine(parent, text) = new(falses(64), parent, text, 0, 0, 0, 0)
    TextLine(parent, text, left, top, width, height) = new(falses(64), parent, text, left, top, width, height)
    TextLine(parent, text, left, top) = new(falses(64), parent, text, left, top,0,0)
end

#==============================================================================#

#==============================================================================#
