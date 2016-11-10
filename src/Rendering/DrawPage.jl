#======================================================================================#
# drawAllElements()
# DrawPage()
#======================================================================================#


# ======================================================================================
# Draw Elements from Layout Tree
# CALLED FROM: MouseDragged(document) -->  Events.jl
# ======================================================================================
function MouseDragged(context::CairoContext, document::Page)
  #  drawAllElements(context,document,document.node[1])
  #  document.mousedown =  Point(event.x, event.y)
  #  document.mouseup   =  Point(0, 0)

  bounds = BoxFromPoints(document.mousedown, document.mouseup)
  DrawAllInArea(context,document,document.node[1],bounds)
end

# ======================================================================================
# Draw Elements from Layout Tree that are within X bounds
# CALLED FROM: DrawAllInArea() -->  Above
#
# ALERT: the problem here is that children of parents are effected!
#        ...parrents are redrawn but not all their children
# ======================================================================================
function DrawAllInArea(context::CairoContext, document::Page, node::MyElement, bounds::Box)
    nodes = node.node



            for n in nodes
              ClipPath(context, n);
                    if RowsOverlap(n.box, bounds)
                        DrawNode(context,document,n)
                        drawAllElements(context,document,n)
                    else
                        DrawAllInArea(context,document,n,bounds)
                    end
              reset_clip(context)
            end

end
# xmin left   ymin top   width width   height height box area
# ======================================================================================
# Draw Elements from Layout Tree
# CALLED FROM: DrawPage(document) -->  Below
# ======================================================================================
function drawAllElements(context::CairoContext,document::Page,node::MyElement)

    nodes = node.node

    # clip(context);
     #drawStuff()


            for n in nodes
                     # This will limit which nodes are drawn but clipping still needs to be done...
                     # it may be possible to do so with draw_surface-type functions
                     # https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-t
                    ClipPath(context, n);
                    if n.box.top < (node.area.height + node.box.top) ||
                       n.box.left < (node.area.width + node.box.width)
                       # IN: Paint.jl
                        DrawNode(context,document,n)
                        drawAllElements(context,document,n)
                    end
                    reset_clip(context)
            # Flop
            #if node.flags[OverflowClip] == true;    reset_clip(context);    end
            end

end
# ======================================================================================
# Fetch the page and build the DOM and Layout Tree, then render
# CALLED FROM: Browser.jl
# ======================================================================================
function ClipPath(cr, node)
	set_antialias(cr,6)

  if node.flags[IsBox] == true
    border = get(node.border, Border(0,0,0,0,0,0,"None",[],[0.0,0.0,0.0,0.0]))

          if isnull(border.radius)
            x = node.box.left   - border.left # minus 1 while the sides are being
            y = node.box.top    - border.top # expanded by antialias-ing
            h = node.box.height + border.height  # + 0.5
            w = node.box.width  + border.width   # + 0.5
             rectangle(cr, x, y, w, h)
          else # RoudedBox(cr,node,border)
            x = node.box.left   - (border.left* 0.5) # minus 1 while the sides are being
            y = node.box.top    - (border.top* 0.5) # expanded by antialias-ing
            h = node.box.height + (border.height* 0.5)  # + 0.5
            w = node.box.width  + (border.width* 0.5)   # + 0.5
               radius = get(border.radius)

                               borderWidth = border.top[1]

                               TR = radius[1]
                               BR = radius[2]
                               BL = radius[3]
                               TL = radius[4]

           		degrees = pi / 180.0;
                   #w = w + borderWidth
                   #h = h + borderWidth
           		new_sub_path(cr);
           		arc(cr, x + w - TR, y + TR, TR, -90 * degrees, 0 * degrees);    # topRight
           		arc(cr, x + w - BR, y + h - BR, BR, 0 * degrees, 90 * degrees); # bottomRight
           		arc(cr, x + BL, y + h - BL, BL, 90 * degrees, 180 * degrees);   # bottomLeft
           		arc(cr, x + TL, y + TL, TL, 180 * degrees, 270 * degrees);      # topLeft
           		close_path(cr);
           end

  #elseif node.flags[ClipCircle] == true
  # elseif node.flags[IsPath] == true
  end

  clip(cr)
end
# ======================================================================================
# Fetch the page and build the DOM and Layout Tree, then render
# CALLED FROM: Browser.jl
# ======================================================================================
function DrawPage(document::Page)
    # println("Draw Page...")
    canvas = document.ui.canvas

# https://developer.gnome.org/gtkmm-tutorial/stable/chapter-drawingarea.html.en
  @guarded draw(canvas) do widget

        context = getgc(canvas)
        document.events = EventTypes()
        node = document.node[1]
        document.mousedown =  Point(0, 0)
        document.mouseup   =  Point(0, 0)
        document.flags = falses(8)
        #p = Point(0,0)


         #println(node.rows)
        #      push!(node.rows,Row())
        #      node.rows[end].height = 0
        #      println(node.rows)
        #node.box.width, node.box.height = width(context), height(context) # content
        node.area.width, node.area.height = width(context), height(context)
        # LayoutInner(node,node.DOM ,0,0,width(context),height(context))
        x::Float32 = 0
        LayoutInner(node, x)

            # OnInitialize: 0.649740 seconds (359.77 k allocations: 15.420 MB, 1.01% gc time)
            # OnResize:     0.005325 seconds (6.80 k allocations: 339.750 KB)

            @time    traceElementTree(document,node, node.DOM,0)
            flags = falses(8)
            # flags[] =     ## if you need to pass something in, do it here.
                      ResetYoffset(node,flags)
            # Erase all previous
            rectangle(context,  0,  0,  node.box.width, node.box.height )
            set_source_rgb(context, 1,1,1);
            fill(context);
            # Draw all
            set_line_width(context, 1);
            rectangle(context, (node.box.left),  (node.box.top),
                 node.box.width, node.box.height )
            set_source_rgb(context, 0.95,0.95,0.95); stroke(context);

            # 0.621208 seconds (444.03 k allocations: 19.054 MB, 1.00% gc time)
            print("drawAllElements: ")
           drawAllElements(context,document,node)


                # corner thingie
                select_font_face(context, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL);
                set_font_size(context, 12.0);
                set_source_rgba(context, 0,0,0,0.5);
                rectangle(context, 0,  height(context)-20,
                  node.box.width/4,  20 )
                fill(context)

                move_to(context,010,height(context)-5);
                set_source_rgb(context, 1,1,1);
                show_text(context,Libc.strftime(time()));

stroke(context)

end
   show(canvas)
    AttatchEvents(document)

end
