
#module NaquadahEvents
# using Cairo, Gtk, Gtk.ShortNames

export  splotch, ScrollEvent, # not sure all this needs exported (?)
        DragEvent, MouseDownEvent, ClickEvent #, Event,

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
onArea(x, y,  shape ) = onArea(x, y,  getBorderBox(shape)... ) # WAS: getContentBox

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
    shape = node.shape
    box = getContentBox(shape)
    started = false

    # TODO: also include some test to exclude "unselectable" nodes.
    function looper(rows)
        for r in rows
            for n in r.nodes
                        if isdefined(n, :rows)
                            looper(n.rows)
                        else
                                s = n.shape
                                if onArea(left, top, s)         # ¡Selection Start
                                    push!(items, n)
                                    started = true
                                    if onArea(right, bottom, s)
                                        started = false
                                        return items
                                    end
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

    return items
end
# ======================================================================================
#
# a,b,c,d = [1],[2],[3],[4]
# l = [a b b c d a a]
# same(list, object) = list .=== object
# ======================================================================================
function selectText(ctx, document, pressed, released)

    left, right, top, bottom = order2(pressed.x,released.x, pressed.y,released.y)
    selected = findNodesInBox(document.children[1].children[3], left, top, right, bottom)

    clipPath = getContentBox(document.children[1].children[3].shape)
    # Objective here is to remove duplicates and also repaint tainted rows
    selectedNodes = document.event.selectedNodes

    found = false
for oldnode in selectedNodes
    for node in selected
        found = false
         if node ===  oldnode
             found = true
         end
    end
    if !found
        c = inheritColor(oldnode.parent)

        setcolor( ctx, c...)
        rectangle(ctx,  oldnode.shape.left-1, oldnode.shape.top-1, oldnode.shape.width+2, oldnode.shape.height+2 )
        fill(ctx)
        DrawText(ctx, oldnode, clipPath)
    end
end


    # buffer = []
    # for shape in selected
    #     if shape.top > bottom || (shape.top+shape.height) < top # outside range and needs removed
    #         setcolor( ctx, shape.parent.shape.color...)
    #         rectangle(ctx,  shape.left, shape.top, shape.width, shape.height )
    #         fill(ctx)
    #         DrawText(ctx, shape, clipPath)
    #     else
    #         push!(buffer,shape)
    #     end
    # end
    # selected = buffer

    if pressed.y < released.y # just in case the selection is made from bottom to top
        DrawSelectedText(ctx, selected, pressed.x, released.x, pressed.y, released.y, clipPath)
    else
        DrawSelectedText(ctx, selected, released.x, pressed.x, released.y, pressed.y, clipPath)
    end
    document.event.selectedNodes = selected

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
    clicked = document.eventsList.click
    splotch(widget, event, 1.0,0.0,0.0)
    document.event.pressed = []
    for node in clicked
        if onArea(event.x, event.y, node.shape ) && insideParentClip( event.x, event.y, node)
            if haskey(node.DOM, "click")
                click = node.DOM["click"]
                if haskey(click, "code")

                    code = parse(click["code"])
                    ex = :($(Expr(:toplevel, :(document = $document), :($code))))
                    eval(ex)



                    # WAS: eval(parse(click["code"]))
                end
            end
            #"click":{"code":"println(\"This is some code!\")", "preventDefault":true}

        end
    end

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

  Unit = 70.0

  # I am scrolling(jumping) by 30px here but Opera scrolls by about 50px
  # Opera lacks smoothness too but it seems to transition-scroll by the 50px
  # ...so using the mouse wheel it is impossible to move less than that increment.
  function drawTwice()
      setcolor(ctx, node.shape.color...)
      rectangle(ctx,  node.shape.left,  node.shape.top, node.shape.width,  node.shape.height )
      fill(ctx);

      DrawViewport(ctx, document, node)
      reveal(widget)
  end

  # SCROLL UP!
  if event.direction == 0 && node.scroll.y < node.shape.top # was: 0
    diff = abs(node.scroll.y)
    if diff < Unit
      Unit = diff
    end
    node.scroll.y += (Unit*.5)
    VmoveAllChildren(node, (Unit*.5), false)
    drawTwice()
    node.scroll.y += (Unit*.5)
    VmoveAllChildren(node, (Unit*.5), false)
    drawTwice()
    # SCROLL DOWN!
elseif event.direction == 1 && (node.scroll.contentHeight + node.scroll.y + node.shape.top) > node.shape.height
      diff = (node.scroll.contentHeight + node.scroll.y + node.shape.top) - node.shape.height
      if diff < Unit
        Unit = diff
      end
      node.scroll.y -= (Unit*.5)
      VmoveAllChildren(node, -(Unit*.5), false) # -30
      drawTwice()
      node.scroll.y -= (Unit*.5)
      VmoveAllChildren(node, -(Unit*.5), false) # -30
      drawTwice()
  end

  # #set_source_rgb(ctx, 1,1,1)
  # setcolor( ctx, node.shape.color...)
  # rectangle(ctx,  node.shape.left,  node.shape.top, node.shape.width,  node.shape.height )
  # fill(ctx);
  #
  # DrawViewport(ctx, document, node)
  # reveal(widget)

end

function drawTwice()
    setcolor( ctx, node.shape.color...)
    rectangle(ctx,  node.shape.left,  node.shape.top, node.shape.width,  node.shape.height )
    fill(ctx);

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
