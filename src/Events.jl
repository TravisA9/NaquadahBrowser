
# module NaquadahEvents
using Cairo, Gtk, Gtk.ShortNames#, Naquadraw # Graphics,

export AttatchEvents

export EventType

type EventType
  pressed::Point
  released::Point
  EventType() = new(Point(0,0),Point(0,0))
end

function AttatchEvents(document)
	    canvas = document.canvas

    canvas.mouse.button1press = @guarded (widget, event) -> begin

        document.event.pressed = Point(event.x, event.y)
    end

    canvas.mouse.button1release = @guarded (widget, event) -> begin
    ctx = getgc(widget)
           if -5 < (document.event.pressed.x - event.x) < 5 &&
              -5 < (document.event.pressed.y - event.y) < 5
             splotch(ctx,event,1.0,0.0,0.0)
             reveal(widget)
           end
    end

    # SEE: https://people.gnome.org/~gcampagna/docs/Gdk-3.0/Gdk.EventScroll.html
canvas.mouse.scroll = @guarded (widget, event) -> begin
    ctx = getgc(widget)
    node = document.children[1].children[3] # TODO: fix! ..test to see if mouse is over object.

    Unit = 75

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

    Shape = getShape(node)
    #clipPath = (0, 0, 1000, 1000)
    #if Shape.flags[Clip] == true
                #border = get(Shape.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
                #padding = get(Shape.padding, BoxOutline(0,0,0,0,0,0))
                #clipPath = getBorderBox(Shape, border, padding)
    #end

    DrawContent(ctx, document, node)
    reveal(widget)

    end



end

#======================================================================================#
#    Similar to MoveAll() in LayoutBuild.jl
#======================================================================================#
function VmoveAll(node,y)
  shape = getShape(node)
  if shape.flags[Fixed] == true
    return
  end
  shape.top  += y
    if isdefined(node, :rows) # ..it has rows of children so let's move them!
      for i in 1:length(node.rows)
        row = node.rows[i]
        row.y += y
        for j in 1:length(row.nodes)
            VmoveAll(row.nodes[j],y) # do the same for each child
        end
      end
    end
end
# ======================================================================================
# Draw a splotch
# CALLED FROM:
# ======================================================================================
function splotch(ctx,event,r,g,b)
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


end



# end # module
