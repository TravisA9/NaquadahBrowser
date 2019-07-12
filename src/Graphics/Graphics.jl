
 #= The border is drawn on line X but since it has a thickness this must be taken into account!
 ┌──────────────────────────
 |  margin
 |    ┌──────────────────────────
 |    │  border------------------ <──────────────────────────┐
 |    │  :  ┌─────────────────────                           │
 |    │  :  │  padding             }──────────────┐          │
 |    │  :  │    ┌───────────┐ <──────── top - padding - (border * 0.5)
 |    │  :  │    │  content  │
 |    │  :  │    └───────────┘

 left, top, right, bottom = content-area
 ...padding, border and margin are added to that!
 ┌───────────────────────────────┐
 │  margin                       │
 │    ┌─────────────────────┐    │
 │    │  padding            │    │
 │    │    ┌───────────┐    │    │
 │    │    │  content  │    │    │
 │    │    └───────────┘    │    │
 │    │                     │    │
 │    └─border──────────────┘    │
 │                               │
 └───────────────────────────────┘

                                                                              =#

export setDistanceFromBounds, getBorderBox, getContentBox, getMarginBox, getSize,
       TotalShapeWidth, getPackingWidth, TotalShapeHeight,
       DrawANode, InitializeRow, getReal
# ==============================================================================
# To set absolute position
function setDistanceFromBounds(l,t,w,h,  shape )
    shape.flags[Bottom] ? (shape.top = t+h - (shape.height+shape.top)) : (shape.top = t+shape.top)
    shape.flags[Right] ? (shape.left = l+w - (shape.width+shape.left)) : (shape.left = l+shape.left)
end
# ==============================================================================
function getReal(box::Draw)
     return (  get(box.padding, BoxOutline(0,0,0,0,0,0)),
               get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0])),
               get(box.margin,  BoxOutline(0,0,0,0,0,0))    )
 end
 # ==============================================================================
function getBorderBox(shape::Draw, border::Border, padding::BoxOutline)
     return  shape.left   - padding.left   - (border.left *.5),
             shape.top    - padding.top    - (border.top *.5),
             shape.width  + padding.width  + (border.width *.5),
             shape.height + padding.height + (border.height *.5);
end

getBorderBox(shape::TextLine) = getContentBox(shape)
 #getBorderBox(shape, get(shape.border, Border()), get(shape.padding, BoxOutline()))

getBorderBox(shape) = getBorderBox(shape, get(shape.border, Border()),
                       get(shape.padding, BoxOutline()))

getContentBox(box) = ( box.left, box.top, box.width, box.height )

function getBorderOuter(shape::Draw, border::Border, padding::BoxOutline)
     return  shape.left   - padding.left   - (border.left),
             shape.top    - padding.top    - (border.top),
             shape.width  + padding.width  + (border.width),
             shape.height + padding.height + (border.height);
end

getBorderOuter(shape) = getBorderBox(shape, get(shape.border, Border()),
                       get(shape.padding, BoxOutline()))

function getBorderInner(shape::Draw, border::Border, padding::BoxOutline)
     return  shape.left   - padding.left,
             shape.top    - padding.top,
             shape.width  + padding.width,
             shape.height + padding.height;
end

getBorderInner(shape) = getBorderBox(shape, get(shape.border, Border()),
                       get(shape.padding, BoxOutline()))
# ==============================================================================
contentOffset(padding::BoxOutline, border::Border, margin::BoxOutline) =
   (padding.left + border.left + margin.left) , (padding.top + border.top + margin.top)

contentOffset(shape::TextLine) = (0,0)

macro ContentLeft(pl, bl, ml)
    return :( $(pl) + $(bl) + $(ml) )
end
macro ContentTop(pt, bt, mt)
    return :( $(pt) + $(bt) + $(mt) )
end

function contentOffset(shape::Draw)
    padding, border ,margin = getReal(shape)
      return (padding.left + border.left + margin.left) , (padding.top + border.top + margin.top)
  end
# ==============================================================================
function getSize(box::NBox)
     padding, border ,margin = getReal(box)
       return ( box.width  + border.width  + margin.width  + padding.width,
                box.height + border.height + margin.height + padding.height )
end
function getWidthfromContentLeft(box)
     padding, border ,margin = getReal(box)
       return ( box.width  + border.right  + margin.right  + padding.right )
end
getSize(text::TextLine) = ( text.width, text.height )

function getPackingWidth(box) # should be getOutersWidth
     padding, border ,margin = getReal(box)
       return ( box.width  + border.width  + margin.width  + padding.width )
end

function getSize(circle::Circle)
     border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
     margin = get(circle.margin,  BoxOutline(0,0,0,0,0,0))
       dia = circle.radius*2+1
       return ( dia + border.width  + margin.width ,
                dia + border.height + margin.height )
end

macro BorderLeft(box::Draw, border::Border, padding::BoxOutline)
    return :( $(box).left  - $(padding).left  - ($(border).left *.5))
end
macro BorderTop(box::Draw, border::Border, padding::BoxOutline)
    return :( $(box).top  - $(padding).top  - ($(border).top *.5))
end
macro BorderRight(box::Draw, border::Border, padding::BoxOutline)
    return :( $(box).width  + $(padding).width  + ($(border).width))
end
macro BorderBottom(box::Draw, border::Border, padding::BoxOutline)
    return :( $(box).height  + $(padding).height  + ($(border).height))
end




using Colors
color_names = Colors.color_names
include("GraphDraw.jl")
include("GraphText.jl")
include("GraphFlags.jl")
