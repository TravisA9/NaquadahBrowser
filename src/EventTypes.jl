
type EventType
    pressed::Point
    released::Point
    EventType() = new(Point(0,0),Point(0,0))
end

#-------------------------------------------------------------------------------

type Event
    node::Element
    copy::Element # save a copy of the origional node when overwritten by new data
    action::AbstractString # an event should generally result in an action!
   Event(node, action) = new(node, nothing, action)
end

#-------------------------------------------------------------------------------
# onkeydown onkeypress onkeyup
# onclick ondblclick onmousedown onmousemove onmouseout onmouseover onmouseup onwheel
# ondrag ondragend ondragenter ondragleave ondragover ondragstart ondrop onscroll
# oncopy oncut onpaste
#-------------------------------------------------------------------------------

type AttachedEvents
    click::Array
    mousedown::Array
    mousemove::Array
    mouseover::Array
    mouseup::Array
    mouseout::Array

    drag::Array
    drop::Array

    keydown::Array
    keypress::Array
    keyup::Array
    # onload::Array
end
