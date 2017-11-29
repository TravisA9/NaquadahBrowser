
export LastRow
export Page, Scroller, Row, Element, Event, Page

begin

    type EventType
        pressed::Point
        released::Point
        EventType() = new(Point(0,0),Point(0,0))
    end
#-==============================================================================
mutable struct Scroller
    x::Float64
    y::Float64
    contentWidth::Float64
    contentHeight::Float64
    Scroller() = new(0,0,0,0)
end
#-==============================================================================
mutable struct Row
    flags::BitArray{1} #Any
    nodes::Array{Any,1} # cant't say Element because it's not yet defined
    height::Float64
    width::Float64 # because elements could be wider than the parent
    space::Float64 # Space remaining 'til full
    x::Float64
    y::Float64
    # Row() = new(falses(32),[],0,0,0,0,0)
    # Row(x, wide) = new(falses(32),[],0,0,wide,x,0)
    Row(x, y, wide) = new(falses(32),[],0,0,wide,x,y)
    function Row(rows::Array{Row,1}, x::Float64, y::Float64, w::Float64)
        r = Row(x, y, w)
        push!(rows,r)
        return r
    end
end
function LastRow(rows::Array{Row,1}, l, t, w)
    if length(rows) < 1
        Row(rows, l, t, w)
    end
    return rows[end]
end
#-==============================================================================
mutable struct Element
    DOM::Dict       # Reference to dictionary counterpart of this node
    parent::Any               # This node's parent
    children::Array{Element,1} # Children in order they appear in DOM
    rows::Array{Row,1} # A layout property
    shape::Any # link to layout representation of node
    scroll::Scroller # Since shape get's destroyed we need the scroll-offsets here (prabably should be Nullable).
        function Element(DOM=Dict())
            parent = nothing
            children::Array{Element,1} = []
            new(DOM, parent, children, [], nothing, Scroller())
        end
end
#-==============================================================================
mutable struct AttachedEvents
    click::Array{Element,1}
    mousedown::Array{Element,1}
    mousemove::Array{Element,1}
    mouseover::Array{Element,1}
    mouseup::Array{Element,1}
    mouseout::Array{Element,1}

    drag::Array{Element,1}
    drop::Array{Element,1}

    keydown::Array{Element,1}
    keypress::Array{Element,1}
    keyup::Array{Element,1}
    AttachedEvents() = new()
    # onload::Array
end
# document.event
mutable struct Event
    node::Element
    copy::Element # save a copy of the origional node when overwritten by new data
    action::AbstractString # an event should generally result in an action!
    Event(node, action) = new(node, nothing, action)
end
#-==============================================================================
mutable struct Page
         parent::Any  # First node needs a Psudo-parent too ..maybe!
         children::Array{Element,1} # First node in a tree-like data structure representing all elements on page
         fixed::Element # First node in a tree-like data structure representing all elements on page
         styles::Dict
         head::Dict
         width::Float64
         height::Float64

         win::Any
         url::Any         # URL of page
         flags::BitArray{1}        #  buttonPressed
         mousedown::Point       # These may be better than trying to copy the nodes
         mouseup::Point
         focusNode::Any
         hoverNode::Any
         canvas::Any
         event::EventType
         eventsList::AttachedEvents
         # ui::PageUI   # Window
             function Page(url::String)
                     children::Array{Element,1} = [Element()]
                     parent = children[1]
                     children[1].parent = parent
                 new(parent, children, Element(), Dict(), Dict(), 0,0, nothing, url, falses(8),
                    Point(0, 0), Point(0, 0), 0, 0, 0, EventType(), AttachedEvents())
             end
end




end
