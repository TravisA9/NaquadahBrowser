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
macro BorderLeft(box, border, padding)
    return :( $(box).left  - $(padding).left  - ($(border).left *.5))
end
macro BorderTop(box, border, padding)
    return :( $(box).top  - $(padding).top  - ($(border).top *.5))
end
macro BorderRight(box, border, padding)
    return :( $(box).width  + $(padding).width  + ($(border).width))
end
macro BorderBottom(box, border, padding)
    return :( $(box).height  + $(padding).height  + ($(border).height))
end

function getBorderBox(box::Draw, border, padding)
    return ( @BorderLeft(box, border, padding), @BorderTop(box, border, padding),  # t += border.top  *.5
             @BorderRight(box, border, padding), @BorderBottom(box, border, padding)
             #box.width  + (border.width  ), box.height + (border.height )
              )
end

#=function getBorderBox(box::Circle, border, padding)
    return ( @BorderLeft(box, border, padding), @BorderTop(box, border, padding),  # t += border.top  *.5
             @BorderRight(box, border, padding), @BorderBottom(box, border, padding)
             #box.width  + (border.width  ), box.height + (border.height )
              )
end=#

function getContentBox(box::Draw, padding, border, margin)
    return ( box.left, box.top, box.width, box.height )
end


macro ContentLeft(padding, border, margin)
    return :( $(padding).left  + $(border).left  + ($(margin).left))
end
macro ContentTop(padding, border, margin)
    return :( $(padding).top  + $(border).top  + ($(margin).top))
end

function contentOffset(padding, border, margin)
    return ( @ContentLeft(border, padding, margin) ,
             @ContentTop(border, padding, margin)   )
end

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












#=
function getContentBox(circle::Circle, padding, border, margin)
  dia = circle.radius*2+1
    return ( circle.left   + border.left   + padding.left + margin.left   ,
             circle.top    + border.top    + padding.top  + margin.top    ,
             dia + border.width  + margin.width ,
             dia + border.height + margin.height )
end
=#

#=
function getMarginBox(box::NBox)
  border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
  margin = get(box.margin,  BoxOutline(0,0,0,0,0,0))
    return ( box.left - border.left -margin.left,
             box.top  - border.top  -margin.top,
             box.width  + border.width  + margin.width ,
             box.height + border.height + margin.height )
end
function getMarginBox(box::NBox, border, margin)
    return ( box.left - border.left -margin.left,
             box.top  - border.top  -margin.top,
             box.width  + border.width  + margin.width ,
             box.height + border.height + margin.height )
end

function getMarginBox(circle::Circle, border, margin)
    dia = circle.radius*2+1
    return ( circle.left,
             circle.top,
             dia + border.width  + margin.width ,
             dia + border.height + margin.height )
end
function getMarginBox(circle::Circle)
  border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
  margin = get(circle.margin,  BoxOutline(0,0,0,0,0,0))
    dia = circle.radius*2+1
    return ( circle.left,
             circle.top,
             dia + border.width  + margin.width ,
             dia + border.height + margin.height )
end

=#









# ==============================================================================
#=
function topLeft(box::Draw)
    offset = get(box.offset,Point(0,0))
     return Point(box.left + offset.x, box.top + offset.y)
 end
function bottomRight(box::Draw)
    offset = get(box.offset,Point(0,0))
     return Point(box.right + offset.x, box.bottom + offset.y)
 end
 =#
# function Border(box::BoxElement,padding,border,margin)
#     return box.width + padding.left + padding.right + border.left + border.right + margin.left + margin.right
# end
#=
function TotalShapeWidth(box::NBox)
      border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
      margin = get(box.margin,  BoxOutline(0,0,0,0,0,0))
    return box.width + margin.width + border.width
end
function TotalShapeWidth(box::Draw,border,margin)
    return box.width + margin.width + border.width
end
function TotalShapeHeight(box::Draw,border,margin)
    return box.height + border.height + margin.height
end


function topLeft(circle::Circle)
     return Point(origin.x - radius, origin.y - radius)
end
function bottomRight(circle::Circle)
    return Point(origin.x + radius, origin.y + radius)
end
function TotalShapeWidth(circle::Circle,padding,border,margin)
    width = radius*2
    return width + padding.left + padding.right + border.left + border.right + margin.left + margin.right
end
function TotalShapeHeight(circle::Circle,padding,border,margin)
    height = radius*2
    return height + padding.top + padding.bottom + border.top + border.bottom + margin.top + margin.bottom
end
=#
