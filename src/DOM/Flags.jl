# inheritable flags should go first
# This includes atributes that are toggled before and after drawing all children
#=
const OpacityAll =
const Antialias =
const FillWinding =
const FillEvenOdd =
# fill-rule:nonzero
const IsDashed =
const CapBut =
const CapRound =
const CapSquare =

const Clip =

const Scale =
const Transform =
const Translate =
=#
# Flags for Elements
# TODO: reorder, renumber and regroup...
const HasBorder     = 1
const BordersSame   = 2
const HasMargin     = 3
const MarginSame    = 4
const HasPadding    = 5
const PaddingSame   = 6

const HasOpacity    = 7
const HasColor      = 8
const HasText       = 9

const Absolute      = 10
const Relative      = 11
const Fixed         = 12

const FloatLeft = 40
const FloatRight = 41
#=
inline, block, flex, inline-block, inline-flex, inline-table, list-item, run-in, table, table-caption, table-column-group, table-header-group, table-footer-group, table-row-group, table-cell, table-column, table-row, none, initial, inherit
=#
const Inline        = 13
const Block         = 14
const InlineBlock   = 15
const None          = 16
const Hidden        = 17

const IsBox         = 18
const IsArc         = 19
const IsCircle      = 20
const IsLine        = 21
const IsCurve       = 24
const IsText        = 27
const IsEllipse     = 28
const IsPolygon     = 29 # points="220,10 300,210 170,250 123,234"
const IsPolyline    = 30 #  points="20,20 40,25 60,40 80,120 120,140 200,180"
const TestFillStyle = 23
const ClipCircle    = 25
const IsGradient    = 26
const IsPath        = 22
				#   M = moveto                  L = lineto
				#   H = horizontal lineto       V = vertical lineto
				#   C = curveto                 S = smooth curveto
				#   Q = quadratic Bézier curve  T = smooth quadratic Bézier curveto
				#   A = elliptical Arc          Z = closepath



const IsDashed = 31
const CapBut = 32
const CapRound = 33
const CapSquare = 34
const OverflowClip = 35
const OverflowScrollx = 36
const OverflowScrolly = 37

const IsUnderlined = 38
const UnderlineOnHover = 39

#=
const  = 31
const NoSelect = 32

=#
