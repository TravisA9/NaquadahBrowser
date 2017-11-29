export    getBorderBox, getContentBox, getMarginBox, getSize,
          TotalShapeWidth, TotalShapeHeight,
          DrawANode, InitializeRow, getReal

#=  left, top, right, bottom = content-area
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
# ==============================================================================
# This returns a temporary BoxElement with offset applied
# and Nullables instantiated.
"""
##

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
function getReal(box::Draw)
    return (  get(box.padding, BoxOutline(0,0,0,0,0,0)),
              get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0])),
              get(box.margin,  BoxOutline(0,0,0,0,0,0))    )
end # padding, border, margin

#= The border is drawn on line X but since it has a thickness this must be taken into account!
         ┌──────────────────────────
         │  border------------------ <──────────────────────────┐
         │  ;  ┌─────────────────────                           │
         │  ;  │  padding             }──────────────┐          │
         │  ;  │    ┌───────────┐ <──────── top - padding - (border *.5)
         │  ;  │    │  content  │
         │  ;  │    └───────────┘

=#

"""
##

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
function getBorderBox(shape::Draw, border::Border, padding::BoxOutline)
    return  shape.left   - padding.left   - (border.left *.5),
            shape.top    - padding.top    - (border.top *.5),
            shape.width  + padding.width  + (border.width),
            shape.height + padding.height + (border.height);
end

function getBorderBox(shape::Draw)
    border  = get(shape.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    padding = get(shape.padding,  BoxOutline(0,0,0,0,0,0))
    return  shape.left   - padding.left   - (border.left *.5),
            shape.top    - padding.top    - (border.top *.5),
            shape.width  + padding.width  + (border.width),
            shape.height + padding.height + (border.height);
end

"""
##

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
function getContentBox(box::Draw, padding::BoxOutline, border::Border, margin::BoxOutline)
    return ( box.left, box.top, box.width, box.height )
end


"""
##

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
function contentOffset(padding::BoxOutline, border::Border, margin::BoxOutline)
    return (padding.left + border.left + margin.left) , (padding.top + border.top + margin.top)
    #return ( @ContentLeft(padding, border, margin) , @ContentTop(padding, border, margin)   )
end
"""
##

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
function getSize(box::NBox)
  border  = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
  margin  = get(box.margin,  BoxOutline(0,0,0,0,0,0))
  padding = get(box.padding,  BoxOutline(0,0,0,0,0,0))
    return ( box.width  + border.width  + margin.width  + padding.width,
             box.height + border.height + margin.height + padding.height )
end

function getSize(text::TextLine)
    return ( text.width, text.height )
end

function getSize(circle::Circle)
  border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
  margin = get(circle.margin,  BoxOutline(0,0,0,0,0,0))
    dia = circle.radius*2+1
    return ( dia + border.width  + margin.width ,
             dia + border.height + margin.height )
end

# ==============================================================================
# ==============================================================================
# ==============================================================================


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

macro ContentLeft(pl, bl, ml)
    return :( $(pl) + $(bl) + $(ml) )
end
macro ContentTop(pt, bt, mt)
    return :( $(pt) + $(bt) + $(mt) )
end
#= function getBorderBox(box::Draw, border, padding)
    return ( @BorderLeft(box, border, padding), @BorderTop(box, border, padding),
             @BorderRight(box, border, padding), @BorderBottom(box, border, padding)
              )
end =#
