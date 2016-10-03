# Values can transition but options/settings can logically only change
# Values that can change or transition
# color, width, height, top, left, right, bottom box area
#
#=---------------------------------=#
type Event
  target::Any
  func::String
  subtype::String
  Event(target,func,subtype) = new(target,func,subtype)
end
#=---------------------------------=#
type EventTypes
  mousedown::Array
  mouseup::Array
  click::Array
  hover::Array
  #oncontextmenu
  EventTypes() = new([],[],[],[])
end


# ======================================================================================
# Attatch mouse (and other) events
# CALLED FROM:
# ======================================================================================
function AttatchEvents(document)
	    canvas = document.ui.canvas

    canvas.mouse.button1press = @guarded (widget, event) -> begin
    document.flags[ButtonPressed] = true
    println("pressed: ",document.flags[ButtonPressed])

        ctx = getgc(widget)
        splotch(ctx,event,1.0,0.0,0.0)
        reveal(widget)
        #document.mousedown.x, document.mousedown.y = event.x, event.y
        document.mousedown =  Point(event.x, event.y)
        document.mouseup   =  Point(0, 0)

#  img = ImageFromBlob("http://travis.net16.net/octocat.png")
# @Image(@Pixbuf(data=img,has_alpha=true))
#     println("this is img...",img)
#     paint(ctx);
        # ...also when a node is clicked it should have focus.
        # could just be a pointer to the node to make things easy.
        for e in document.events.mousedown
             if OverTarget(event,e.target)
                 if e.subtype == "link"
                    # This may later be used to open page in another tab
                    #document = MakePage((window)..., e.target.href)
                    # ccall((:gtk_widget_queue_draw,liboxtk), Void, (Ptr{GObject},), document.canvas)
                    FetchPage(get(e.target.href,""))
                #   reveal(widget)
                else
                    warn_dialog(e.func, document.ui.window)
                end
                focusNode = e.target
            end
        end
    end
    canvas.mouse.button1release = @guarded (widget, event) -> begin
       #document.mouseup.x, document.mouseup.y = event.x, event.y
       document.flags[ButtonPressed] = false
       println("pressed: ",document.flags[ButtonPressed])
       document.mouseup =  NaquadahBrowser.Point(event.x, event.y)
       # ctx = getgc(widget)
       # MouseDragged(ctx, document)
    end
    canvas.mouse.button2press = @guarded (widget, event) -> begin
       # print("Button 2 Released( $(event.x), $(event.y) ) ")
    end
    canvas.mouse.button2release = @guarded (widget, event) -> begin
       # print("Button 2 Released( $(event.x), $(event.y) ) ")
    end
    canvas.mouse.button3press = @guarded (widget, event) -> begin
       # print("Button 3 Released( $(event.x), $(event.y) ) ")
    end
    canvas.mouse.button3release = @guarded (widget, event) -> begin
       # print("Button 3 Released( $(event.x), $(event.y) ) ")
    end


    # this works but I am muting it for the moment
    canvas.mouse.motion = @guarded (widget, event) -> begin
        # this flag is used to determin if any mouseover event fires
        flag = false # so far nothing found
        ctx = getgc(widget)
      #  if document.flags[ButtonPressed] == true
      #    document.mouseup =  NaquadahBrowser.Point(event.x, event.y)
      #    MouseDragged(ctx, document)
      #  end

            for e in document.events.hover
                # Either onmousemove || onmouseover
                if OverTarget(event,e.target)
                    flag = true #something was found
                    # onmousemove
                    if e.subtype == "onmousemove"
                            #document.hoverNode = e.target
                            #print(", onmousemove ", e.func)
                    # onmouseover
                    else
                        if e.subtype == "onmouseover"
                            # document.hoverNode = e.target
                            # print(", onmouseover ", e.func)
                        end
                        if e.subtype == "hover" && document.hoverNode == 0
                          # toggle underñline if "normal" link
                          if e.target.flags[UnderlineOnHover] == true
                            e.target.flags[IsUnderlined] = true
                          end

                            ModifyNode(e.target,false)
                            DrawNode(ctx,document,e.target)
                            reveal(widget)
                            #print(", onmouseover ", e.func)
                            #print(", event.x ", event.x)


        # splotch(ctx,widget,event,0.0,0.0,1.0)




                        end
                    end
                    document.hoverNode = e.target
                end
            end


                # onmouseout
                if !flag && document.hoverNode != 0
                    # print(", onmouseout ", e.func)
                    # if e.subtype == "onmouseout"
                    #print(", onmouseout") # document.hoverNode
                    # DrawNode(document.hoverNode)
                    # end
                    #if == "hover" end

                        # println(document.hoverNode)

                        # toggle underñline if "normal" link
                        if document.hoverNode.flags[UnderlineOnHover] == true
                          document.hoverNode.flags[IsUnderlined] = false
                        end
                        ModifyNode(document.hoverNode,true)
                        DrawNode(ctx,document,document.hoverNode)
                        reveal(widget)
                    #splotch(ctx,widget,event,0.0,1.0,0.0)
                    document.hoverNode = 0

                end


    end
    # document.canvas.on_signal_scroll = @guarded (widget, event) -> begin
    #    print("scrolling")
    # end
    # something like a DRAG event

    canvas.mouse.button1motion = @guarded (widget, event) -> begin
          ctx = getgc(widget)
          document.mouseup =  NaquadahBrowser.Point(event.x, event.y)
          MouseDragged(ctx, document)
          reveal(widget)
    end
    # Trying to get mousewheel working...
    #id = signal_connect(document.canvas, "scroll-event")do object
    #    print("Scroll( $(event) ) ")
    #end
    #function on_signal_scroll(scroll_cb::Function, widget::GtkWidget, vargs...)
    # add_events(widget, GdkEventMask.SCROLL)
    # signal_connect(scroll_cb, widget, "scroll-event", Cint, (Ptr{GdkEventScroll},), vargs...)
    #end

end
# ======================================================================================
# Test if mouse is in bounds
# CALLED FROM:
# ======================================================================================
function OverTarget(event,target)
    t = target.box
    return event.x > t.left && event.x < t.left+t.width && event.y > t.top && event.y < t.height+t.top
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


#=
            for e in document.events.hover
           		flag = false # so far nothing found
                # One of onmousemove || onmouseover
                if OverTarget(event,e.target)
                    flag = true #something was found
                    document.hoverNode = e.target
                    # onmousemove
                    if isequal(document.hoverNode, e.target)
                        if e.subtype == "onmousemove"
                            #document.hoverNode = e.target
                            #print(", onmousemove ", e.func)
                        end
                    else # onmouseover
                            # document.hoverNode = e.target
                            # print(", onmouseover ", e.func)
                        if e.subtype == "onmouseover"
                            print(", onmouseover ", e.func)
                        end
                    end
                end
                # onmouseout
                if !flag && document.hoverNode != 0
                    document.hoverNode = 0
                    # print(", onmouseout ", e.func)
                    if e.subtype == "onmouseout"
                        print(", onmouseout ", e.func)
                    end
                end
            end
=#
