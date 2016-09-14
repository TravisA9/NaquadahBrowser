#======================================================================================#
# drawAllElements()
# DrawPage()
#======================================================================================#


# ======================================================================================
# Draw Elements from Layout Tree
# CALLED FROM: DrawPage(document) -->  Below
# ======================================================================================
#  drawAllElements(context,document.node[1]) # document.DOM
function drawAllElements(context,node)

    nodes = node.node

            for n in nodes
                     # This will limit which nodes are drawn but clipping still needs to be done...
                     # it may be possible to do so with draw_surface-type functions
                     # https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-t
                    if n.total.top < (node.total.height + node.total.top) || 
                       n.total.left < (node.total.width + node.total.right)
                       # IN: Paint.jl
                        DrawNode(context,n)
                        drawAllElements(context,n)                                                                   
                    end
            # Flop 
            #if node.flags[OverflowClip] == true;    reset_clip(context);    end
            end
end
# ======================================================================================
# Fetch the page and build the DOM and Layout Tree, then render
# CALLED FROM: 
# ======================================================================================
function DrawPage(document)
    # println("Draw Page...")
    canvas = document.ui.canvas

# https://developer.gnome.org/gtkmm-tutorial/stable/chapter-drawingarea.html.en
  @guarded draw(canvas) do widget

        context = getgc(canvas)
        document.events = EventTypes()
        node = document.node[1]
        LayoutInner(node,node.DOM ,0,0,width(context),height(context))

            # 0.604285 seconds (947.99 k allocations: 38.454 MB, 0.76% gc time)
            traceElementTree(document,node, node.DOM)

            # Erase all previous
            rectangle(context,  0,  0,  node.total.right, node.total.bottom )
            set_source_rgb(context, 1,1,1); 
            fill(context);
            # Draw all 
            set_line_width(context, 1);
            rectangle(context, (node.content.left),  (node.content.top), 
                 node.content.right, node.content.bottom )
            set_source_rgb(context, 0.95,0.95,0.95); stroke(context);

            #  0.722697 seconds (1.09 M allocations: 49.415 MB, 2.02% gc time)
            @time   drawAllElements(context,node)


                # corner thingie
                select_font_face(context, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL);
                set_font_size(context, 12.0);
                set_source_rgba(context, 0,0,0,0.5);
                rectangle(context, 0,  height(context)-20, 
                  node.content.width/4,  20 )
                fill(context)

                move_to(context,010,height(context)-5);
                set_source_rgb(context, 1,1,1);
                show_text(context,Libc.strftime(time()));

stroke(context)

end
   show(canvas)
    AttatchEvents(document)

end
