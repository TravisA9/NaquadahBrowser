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
        IsHScroll, IsVScroll,
        Percent,
        Marked
        

const FloatLeft, FloatRight, RowFinalized = 1, 2, 3
const Absolute, HasAbsolute, Relative, Fixed = 4, 5, 6, 7
const Bottom, Right = 8, 9
const HasOpacity    = 10
# position: static, relative, fixed, absolute
const HasBorder, BordersSame, Clip, IsRoundBox, FixedHeight    = 11, 12, 13, 14, 15
# https://developer.mozilla.org/en-US/docs/Web/CSS/display
const DisplayBlock, DisplayInlineBlock, DisplayInline,
      DisplayNone, DisplayTable, DisplayFlex = 16, 17, 18, 19, 20, 21
# visibility: visible|hidden|collapse|initial|inherit;
const IsHidden     = 22
const AlignBase, AlignMiddle = 23, 24
const TextCenter, TextRight, TextJustify = 25, 26, 27
const TextItalic, TextOblique = 28, 29
const TextBold       = 30
const IsHScroll, IsVScroll = 31, 32

const HasImage      = 33
const TextPath      = 34
const LinearGrad, RadialGrad = 35, 36

const LineBreakBefore, LineBreakAfter = 37, 38

const Percent      = 39
const Marked      = 39


#.==============================================================================
