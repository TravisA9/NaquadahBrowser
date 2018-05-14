include("EventsWiring.jl")

using Cairo, Gtk, Gtk.ShortNames

export AttatchEvents





function MouseSetBoth(document, px, py, rx, ry)
  document.event.pressed = Point(px, py)
      #document.event.released = Point(rx, ry)
end

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
        #MouseSetBoth(document, event.x, event.y, -1, -1)
        #DrawEvent(document, widget, event)
        push!(document.event.pressed, Point(event.x, event.y) )
        #println("move x$(event.x) y$(event.y)")
        #println.(document.event.pressed)
        #DragEvent(document, widget, event)
    end
    #.............................................................
    canvas.mouse.motion = @guarded (widget, event) -> begin
        # mouseover #####################################
        hovers = document.eventsList.mouseover
        for node in hovers
            if onArea(node.shape, event.x, event.y) && node !== document.focusNode
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
                if !onArea(node.shape, event.x, event.y)
                        if haskey(node.DOM, "hover")
                                hover = node.DOM["hover"]
                                if haskey(hover, "color")
                                    if haskey(node.DOM, "color")
                                            node.shape.color = GetTheColor(node, node.DOM["color"])
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
        # #     if onArea(node.shape, event.x, event.y)
        # #         println("X: $(event.x), Y: $(event.y), ")
        # #     end
    end
    # Record to later test for click event
    #.............................................................
    canvas.mouse.button1press = @guarded (widget, event) -> begin
        push!(document.event.pressed, Point(event.x, event.y) )
        #MouseSetBoth(document, event.x, event.y, -1, -1)
        MouseDownEvent(document, widget, event)
    end

    #.............................................................
    canvas.mouse.button1release = @guarded (widget, event) -> begin
      push!(document.event.pressed, Point(event.x, event.y) )
      #document.event.released = Point(event.x, event.y)
      pressed, released = document.event.pressed[1], document.event.pressed[end]
    # Click Event fired!
           if -5 < (pressed.x - released.x) < 5 && -5 < (pressed.y - released.y) < 5
             ClickEvent(document, widget, event)
    # Drag Event fired!
           else
             DragEvent(document, widget, document.event)
           end
    end
    #.............................................................
    canvas.mouse.scroll = @guarded (widget, event) -> begin
        ScrollEvent(document, widget, event)
    end

end

#======================================================================================#
#    Similar to MoveAll() in LayoutBuild.jl
"""
##

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
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
