# Naquadah Browser

#### Files

#### [Events.jl]()

Contains the includes
```julia
MouseSetBoth(document, px, py, rx, ry)

AttatchEvents(document, canvas)

signal_connect(document.win, "key-press-event")

signal_connect(document.win, "key-release-event")

canvas.mouse.button1motion = @guarded (widget, event)

canvas.mouse.motion = @guarded (widget, event)

canvas.mouse.button1press = @guarded (widget, event)

canvas.mouse.button1release = @guarded (widget, event)

VmoveAll(node,y)

```

#### [EventsWiring.jl]()

```julia
DragEvent(document, widget, event)

DrawEvent(document, widget, event)

onArea( shape , x, y)

MouseDownEvent(document, widget, event)

setAttribute(d, key::String, attribute::String)

ClickEvent(document, widget, event)

ScrollEvent(document, widget, event)

splotch(widget,event,r,g,b)

```
