include("EventsWiring.jl")

using Cairo, Gtk, Gtk.ShortNames, Graphics

export AttatchEvents

function AttatchEvents(document, canvas)
  #= Example of keypress output:
Gtk.GdkEventKey(
      event_type::GEnum          8,
      gdk_window::Ptr{Void}      Ptr{Void} @0x0000000006f761d0,
      send_event::Int8           0,
      time::UInt32               0x2bd9c220,
      state::UInt32              0x00000000,
      keyval::UInt32              0x00000061,
      length::Int32              1,
      string::Ptr{UInt8}         Ptr{UInt8} @0x000000001d32c310,
      hardware_keycode::UInt16   0x0041,
      group::UInt8               0x00,
      flags::UInt32              0x00000000
)
=#
# for signals: https://developer.gnome.org/gtk3/stable/GtkWidget.html#GtkWidget-accel-closures-changed
    signal_connect(document.win, "key-press-event") do widget, event
      println("You pressed key ", event) #.keyval
    end
    signal_connect(document.win, "key-release-event") do widget, event
      println("You pressed key ", event) #.keyval
    end
    #.............................................................
    canvas.mouse.button1motion = @guarded (widget, event) -> begin
        #DrawEvent(document, widget, event)
        push!(document.event.pressed, Point(event.x, event.y) )
        #println("move x$(event.x) y$(event.y)")
        #println.(document.event.pressed)
        #DragEvent(document, widget, event)
        pressed, released = document.event.pressed[1], document.event.pressed[end]
        ctx = getgc(widget)
        selectText(ctx, document, pressed, released)
        reveal(widget)
    end
    #.............................................................
    canvas.mouse.motion = @guarded (widget, event) -> begin
        # mouseover #####################################
        hovers = document.eventsList.mouseover
        for node in hovers
            if onArea( event.x, event.y, node.shape) && insideParentClip(event.x, event.y, node) && node !== document.focusNode
                ctx = getgc(widget)
                page = document.children[1].children[3]
                node.temp = deepcopy(node.shape)

                #"hover":{"color":"yellow"},
                if haskey(node.DOM, "hover")
                        hover = node.DOM["hover"]
                        if haskey(hover, "color")
                            node.shape.color = hover["color"]
                                #node.shape.color = [0.996094, 0.5, 0.5]
                        end
                end

                drawNode(ctx, document, node)
                reveal(widget)
                # (1) register hovered object
                document.focusNode = node
            end
        end
        # mousemove #####################################
        # hovers = document.eventsList.mousemove
        # for node in hovers
        #     if onArea(node.shape, event.x, event.y)
        #         println("X: $(event.x), Y: $(event.y), ")
        #     end
        # end
        # mouseout #####################################
        # (1) get registered hover object
         #drawNode(ctx, document, document.focusNode)
         #reveal(widget)
        # # () unregister un-hovered object
        node = document.focusNode
        if node != nothing
                if !onArea( event.x, event.y, node.shape) # && insideParentClip( node , event.x, event.y)
                        if haskey(node.DOM, "hover")
                                hover = node.DOM["hover"]
                                if haskey(hover, "color")
                                    if haskey(node.DOM, "color")
                                           node.shape.color = GetTheColor(node.shape, node.DOM["color"])
                                    else
                                           node.shape.color = inheritColor(node.parent)
                                    end
                                end
                        end
                        ctx = getgc(widget)
                        drawNode(ctx, document, node)
                        reveal(widget)
                        document.focusNode = document.parent
                end
        end


        #  unhovers = document.eventsList.mouseout
        #  found = false
        #  for n in unhovers
        #          if node !== n
        #          end
        #
        # #     if onArea( event.x, event.y,node.shape)
        # #         println("X: $(event.x), Y: $(event.y), ")
        # #     end
    end
    # Record to later test for click event
    #.............................................................
    canvas.mouse.button1press = @guarded (widget, event) -> begin
        document.event.pressed = [] # Test code to be removed!
        document.event.pressed = [Point(event.x, event.y)]
        #push!(document.event.pressed, Point(event.x, event.y) )
        MouseDownEvent(document, widget, event)
    end

    #.............................................................
    canvas.mouse.button1release = @guarded (widget, event) -> begin
        push!(document.event.pressed, Point(event.x, event.y) )
        pressed, released = document.event.pressed[1], document.event.pressed[end]
        # Click Event fired!
           if -5 < (pressed.x - released.x) < 5 && -5 < (pressed.y - released.y) < 5
             ClickEvent(document, widget, event)
           end
           document.event.pressed = []
    end
    #.............................................................
    canvas.mouse.scroll = @guarded (widget, event) -> begin
        ScrollEvent(document, widget, event)
    end

end

#======================================================================================#
#    Similar to MoveAll() in LayoutBuild.jl
#======================================================================================#
function VmoveAll(node,y)
  shape = node.shape
  if shape.flags[Fixed]
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
