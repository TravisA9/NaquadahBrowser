# Naquadah Browser

#### Files


#### [Graphics.jl]()

Includes

#### [ColorDefinitions.jl]()

Possibly redundant to julia's color defs

#### [GraphDraw.jl]()

```julia
setcolor( ctx::Cairo.CairoContext, r, g, b, a)

setcolor( ctx::Cairo.CairoContext, r, g, b)

DrawViewport(ctx::Cairo.CairoContext, document::Page, node::Element)

DrawContent(ctx::Cairo.CairoContext, document::Page, node::Element, clipPath=nothing)

drawNode(ctx, document, row, shape, child, clipPath)

drawNode(ctx, document, node)

lastClipParent(node)

DrawShape(ctx::CairoContext, node::Element, shape::Draw, clipPath)

VScroller(ctx::CairoContext, document::Page, node::Element, shape::Draw, clipPath)

BackgroundImage(ctx::CairoContext, wide::Float64, tall::Float64, l::Float64, t::Float64, path)

linearGrad(ctx::CairoContext, shape, gradient)

radialGrad(ctx::CairoContext, path, gradient)

GetPath(shape::NBox)

GetPath(shape::Circle)

setPath(ctx::CairoContext, shape::NQBox)

setClipPath(ctx::CairoContext, shape::NQCircle)

setClipPath(ctx::CairoContext, shape::NQBox)

setborderPath(ctx::CairoContext, shape::NQBox)

setborderPath(ctx::CairoContext, shape::NQCircle)

DrawText(ctx::CairoContext, row::Row, node::TextLine, clipPath)



```

#### [GraphFlags.jl]()

Bit flags for specifying various attributes of nodes.

Example:
```julia
    FloatLeft,   FloatRight,
    Relative, Fixed, Absolute, HasAbsolute,
    Bottom, Right,
    HasOpacity, HasImage...
 ```


#### [GraphMethods.jl]()

```julia
export    getBorderBox, getContentBox, getMarginBox, getSize,
          TotalShapeWidth, TotalShapeHeight,
          DrawANode, InitializeRow, getReal
```

#### [GraphTypes.jl]()

```julia
export
          # Structural:
          NText,
          # General utility:
          Point, Square,
          # Drawable Shapes:
          NBox, Circle, Arc, TextLine,
          # Constructors:
          Border, BoxOutline
```
