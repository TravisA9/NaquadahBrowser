export
        FloatLeft,   FloatRight,
        Relative, Fixed, Absolute, HasAbsolute,
        Bottom, Right,
        HasOpacity, HasImage,
        TextPath, LinearGrad, RadialGrad,
        RowFinalized,
        HasBorder,   BordersSame,  Clip, IsRoundBox,
        FixedHeight,
        DisplayBlock, DisplayInlineBlock, DisplayInline, DisplayNone, DisplayTable, DisplayFlex,
        LineBreakBefore, LineBreakAfter,
        IsHidden,
        AlignBase,   AlignMiddle,
        TextCenter,  TextRight,    TextJustify,
        TextItalic,  TextOblique,  TextBold,
        IsHScroll, IsVScroll

const FloatLeft     = 1
const FloatRight    = 2
const RowFinalized  = 3

const Absolute      = 4
const HasAbsolute   = 5
const Relative      = 6
const Fixed         = 7

const Bottom        = 8
const Right         = 9

const HasOpacity    = 10
# position: static, relative, fixed, absolute
const HasBorder     = 11
const BordersSame   = 12
const Clip          = 13
const IsRoundBox    = 14
const FixedHeight   = 15
# https://developer.mozilla.org/en-US/docs/Web/CSS/display
const DisplayBlock   = 16
const DisplayInlineBlock   = 17
const DisplayInline   = 18
const DisplayNone   = 19
const DisplayTable   = 20
const DisplayFlex   = 21

# visibility: visible|hidden|collapse|initial|inherit;
const IsHidden     = 22


const AlignBase      = 23
const AlignMiddle    = 24

const TextCenter     = 25
const TextRight      = 26
const TextJustify    = 27

const TextItalic     = 28
const TextOblique    = 29

const TextBold       = 30

const IsHScroll      = 31
const IsVScroll      = 32

const HasImage      = 33
const TextPath      = 34
const LinearGrad    = 35
const RadialGrad    = 36


const LineBreakBefore      = 37
const LineBreakAfter      = 38


#.==============================================================================

#=
const HasGradient    = 26

const HasOpacity    = 7
const HasColor      = 8
const HasText       = 9

const Absolute      = 10
const Relative      = 11
const Fixed         = 12

const FloatLeft = 40
const FloatRight = 41
const HasVscroll = 42
const HasHscroll = 43
const Inline        = 13
const Block         = 14
const InlineBlock   = 15
const None          = 16
const Hidden        = 17

const IsDashed = 31
const CapBut = 32
const CapRound = 33
const CapSquare = 34
const Clip = 35
const OverflowScrollx = 36
const OverflowScrolly = 37

const IsUnderlined = 38
const UnderlineOnHover = 39
=#
