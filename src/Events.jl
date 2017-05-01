
# module NaquadahEvents
using Cairo, Gtk, Gtk.ShortNames

export AttatchEvents, EventType



include("EventTypes.jl")
include("EventsWiring.jl")
function MouseSetBoth(document, px, py, rx, ry)
      document.event.pressed = Point(px, py)
      document.event.released = Point(rx, ry)
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
        MouseSetBoth(document, event.x, event.y, -1, -1)
        DrawEvent(document, widget, event)
    end
    # Record to later test for click event
    #.............................................................
    canvas.mouse.button1press = @guarded (widget, event) -> begin
        MouseSetBoth(document, event.x, event.y, -1, -1)
        MouseDownEvent(document, widget, document.event)
    end

    #.............................................................
    canvas.mouse.button1release = @guarded (widget, event) -> begin
      document.event.released = Point(event.x, event.y)
      pressed, released = document.event.pressed, document.event.released
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

# end # module
