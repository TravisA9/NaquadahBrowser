
#module NaquadahEvents
# using Cairo, Gtk, Gtk.ShortNames

export  splotch, ScrollEvent, # not sure all this needs exported (?)
        DragEvent, MouseDownEvent, ClickEvent #, Event,


"""
##

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
# ======================================================================================
#
# ======================================================================================
function DragEvent(document, widget, event)
    pressed, released = document.event.pressed[1], document.event.pressed[end]
    splotch(widget, pressed,1.0,0.0,0.0)

    ctx = getgc(widget)
    move_to(ctx,pressed.x, pressed.y)
    line_to(ctx,released.x, released.y)
    stroke(ctx)

    splotch(widget, released,1.0,0.0,0.0)
    println("drag from X $(pressed.x), Y $(pressed.y) to X $(released.x), Y $(released.y)")
    document.event.pressed = []
end

# ======================================================================================
#
# ======================================================================================
onArea(x, y,  shape ) = onArea(x, y,  getContentBox(shape)... )

function onArea(x, y,    l, t, w, h)
        return x > l && x < l+w && y > t && y < t+h ? true : false
end
# ======================================================================================
function insideParentClip(x, y, node)
    return onArea( x, y,  lastClipParent(node).shape )
end
# ======================================================================================
function order(a,b)
    a<b ? (a,b) : (b,a)
end
# ======================================================================================
function order2(l,r,t,b)
    l, r = order(l,r)
    t, b = order(t,b)
    return (l,r,t,b)
end
# ======================================================================================
function boxesOverlap(shape, l,r,t,b)
    return onArea(l, t, shape) || onArea(l, b, shape) || onArea(r, t, shape) || onArea(r, b, shape)
end
# ======================================================================================
# Also create: function findNodesAtPoint(node, x, y)
# ======================================================================================
function findNodesInBox(node, left, top, right, bottom)
    items = []
    shape = getShape(node)
    #box = (shape.left, shape.top, shape.width, shape.height)
    box = getContentBox(shape)
    started = false

    # TODO: also include some test to exclude "unselectable" nodes.
    function looper(rows)
        for r in rows
            for n in r.nodes
                        if isdefined(n, :rows)
                            looper(n.rows)
                        else
                                s = getShape(n)
                                if onArea(left, top, s)         # ¡Selection Start
                                    push!(items, n)
                                    started = true
                                elseif onArea(right, bottom, s) # Selection End!
                                    push!(items, n)
                                    started = false
                                    return items
                                elseif started
                                    push!(items, n)
                                end

                        end
            end
        end
        return items
    end

looper(node.rows)

    # Yup, it's in the designated area so we will push this to our vector
    # if onArea(left, top, shape) #boxesOverlap(shape, left,right,top,bottom)
    #     if onArea(right, bottom, shape)
    #         if isdefined(node, :rows) #&& length(node.rows) > 0
    #             eat(node)
    #         else
    #                 println("end")
    #                 push!(items, node)
    #         end
    #     end
    #
    # end
    return items
end
# ======================================================================================
#
# ======================================================================================
function selectText(ctx, document, pressed, released)

    println("Select all text from X $(pressed.x), Y $(pressed.y) to X $(released.x), Y $(released.y)")
    left, right, top, bottom = order2(pressed.x,released.x, pressed.y,released.y)

    selected = findNodesInBox(document.children[1].children[3], left, top, right, bottom)
    println(length(selected), " items selected!")

    clipPath = getContentBox(document.children[1].children[3].shape)
    if pressed.y < released.y # just in case the selection is made from bottom to top
        DrawSelectedText(ctx, selected, pressed.x, released.x, pressed.y, released.y, clipPath)
    else
        DrawSelectedText(ctx, selected, released.x, pressed.x, released.y, pressed.y, clipPath)
    end


end
# ======================================================================================
#
# ======================================================================================
function DrawEvent(document, widget, event)
    println("move x$(event.x) y$(event.y)")
end
# ======================================================================================
#
# ======================================================================================
function MouseDownEvent(document, widget, event)
    down = document.eventsList.mousedown
    #println("clicked: ", event.x, event.y)
    for node in down

        if onArea(event.x, event.y, node.shape ) && insideParentClip( event.x, event.y, node)
            ctx = getgc(widget)
            page = document.children[1].children[3]

            if node.shape.color[2] > 0.9
                node.temp = deepcopy(node.shape)
                node.shape.color = [0.996094, 0.5, 0.5]
            else
                node.shape = deepcopy(node.temp)
            end
            drawNode(ctx, document, node)
            reveal(widget)
        end
    end
end
#setAttribute(node, "color", "red")
#AtributesToLayout(document, node, false)

# ======================================================================================

# ======================================================================================
function setAttribute(d, key::String, attribute::String)
    println(d.DOM)
    d.DOM[key] = attribute
end
# ======================================================================================
#
# ======================================================================================
function ClickEvent(document, widget, event)
    splotch(widget, event,1.0,0.0,0.0)
    document.event.pressed = []
end
# ======================================================================================
#
# ======================================================================================
function OnObject(document, x, y, all=true)


end
# ======================================================================================
#
# ======================================================================================
function ScrollEvent(document, widget, event)
  ctx = getgc(widget)
  node = document.children[1].children[3] # TODO: fix! ..test to see if mouse is over object.

  Unit = 50.0

  # I am scrolling(jumping) by 30px here but Opera scrolls by about 50px
  # Opera lacks smoothness too but it seems to transition-scroll by the 50px
  # ...so using the mouse wheel it is impossible to move less than that increment.

  # SCROLL UP!
  if event.direction == 0 && node.scroll.y < node.shape.top # was: 0
    diff = abs(node.scroll.y)
    if diff < Unit
      Unit = diff
    end
      node.scroll.y += Unit
      VmoveAllChildren(node, Unit, false)
    # SCROLL DOWN!
elseif event.direction == 1 && (node.scroll.contentHeight + node.scroll.y + node.shape.top) > node.shape.height
      diff = (node.scroll.contentHeight + node.scroll.y + node.shape.top) - node.shape.height
      if diff < Unit
        Unit = diff
      end
       node.scroll.y -= Unit
          VmoveAllChildren(node, -Unit, false) # -30
  end

  #set_source_rgb(ctx, 1,1,1)
  setcolor( ctx, node.shape.color...)
  rectangle(ctx,  node.shape.left,  node.shape.top, node.shape.width,  node.shape.height )
  fill(ctx);

  #Shape = getShape(node)
  DrawViewport(ctx, document, node)
  reveal(widget)

end
# ======================================================================================
# Draw a splotch
# CALLED FROM:
# ======================================================================================
function splotch(widget,event,r,g,b)
      ctx = getgc(widget)
            deg = (pi/180.0)
        s1, e1 = 1 * deg, 100 * deg
        s2, e2 = 120 * deg, 220 * deg
        s3, e3 = 240 * deg, 340 * deg
        move_to(ctx, event.x, event.y)
        set_line_width(ctx, 2.56);
        set_antialias(ctx,4)
        set_source_rgb(ctx, r, g, b)
        arc(ctx, event.x, event.y, 2, 0, 2pi) # 0, 2pi
        stroke(ctx)

        #set_line_width(ctx, 3);
        set_source_rgba(ctx, r, g, b, 0.7)
        arc(ctx, event.x, event.y, 5, s1, e1) # 0, 2pi
        stroke(ctx)
        arc(ctx, event.x, event.y, 5, s2, e2) # 0, 2pi
        stroke(ctx)
        arc(ctx, event.x, event.y, 5, s3, e3) # 0, 2pi
        stroke(ctx)
        # arc_negative(cr, xc, yc, node.shape.radius,
        #     node.shape.angle[1] * (pi/180.0),
        #     node.shape.angle[2] * (pi/180.0));

        #set_line_width(ctx, 2);
        set_source_rgba(ctx, r, g, b, 0.5)
        arc(ctx, event.x, event.y, 8, s1, e1)
        stroke(ctx)
        arc(ctx, event.x, event.y, 8, s2, e2)
        stroke(ctx)
        arc(ctx, event.x, event.y, 8, s3, e3)
        stroke(ctx)

        #set_line_width(ctx, 1);
        set_source_rgba(ctx, r, g, b, 0.3)
        arc(ctx, event.x, event.y, 11, s1, e1)
        stroke(ctx)
        arc(ctx, event.x, event.y, 11, s2, e2)
        stroke(ctx)
        arc(ctx, event.x, event.y, 11, s3, e3)
        stroke(ctx)
        reveal(widget)
    end
#end # module
