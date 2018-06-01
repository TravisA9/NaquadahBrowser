
export LastRow, Page, Scroller, Row, Element, Text, Page #Event,

begin

# if this structure doesn't grow it should be elimenated. Pointless to have a structure for one member...
    type EventType
        pressed::Vector{Point}
        selectedNodes::Any
        EventType() = new([],[])
        EventType(x,y) = new([Point(x,y)],[])
        EventType(a) = new(a)
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
    nodes::Vector{Any} # cant't say Element because it's not yet defined
    height::Float64
    width::Float64 # because elements could be wider than the parent
    space::Float64 # Space remaining 'til full
    left::Float64  # TODO: change these to left/top for cmpatability
    top::Float64
    # Row() = new(falses(32),[],0,0,0,0,0)
    # Row(x, wide) = new(falses(32),[],0,0,wide,x,0)
    Row(left, top, wide) = new(falses(32),[],0,0,wide,left,top)
    function Row(rows::Vector{Row}, left::Float64, top::Float64, w::Float64)
        r = Row(left, top, w)
        push!(rows,r)
        return r
    end
end
# maybe rename: GetNewRow or something similar.
function LastRow(rows::Vector{Row}, l, t, w)
    if length(rows) < 1
        Row(rows, l, t, w)
    end
    return rows[end]
end
#-==============================================================================
mutable struct Element
    DOM::Dict       # Reference to dictionary counterpart of this node
    parent::Any               # This node's parent
    children::Vector{Any} # Children in order they appear in DOM
    rows::Vector{Row} # A layout property
    font::Any  # Font definition to be applied to all rows and children unless overriden.
    shape::Any # link to layout representation of node
    temp::Any  # Temporary copy of node to preserve data for when visual changes take place
    scroll::Scroller # Since shape get's destroyed we need the scroll-offsets here (prabably should be Nullable).
    Element(DOM) = new(DOM, nothing, [], [], nothing, nothing, nothing, Scroller())
    Element() = new(Dict(), nothing, [], [], nothing, nothing, nothing, Scroller())
end
#-==============================================================================
mutable struct Text
    DOM::Dict       # Reference to dictionary counterpart of this node
    parent::Any               # This node's parent
    shape::Any # link to layout representation of node
    Text(parent, shape) = new(Dict(), parent, shape)
    Text(shape) = new(Dict(), nothing, shape)
    Text() = new(Dict(), nothing, nothing)
end
#-==============================================================================
mutable struct AttachedEvents
    click::Vector{Element}
    mousedown::Vector{Any}
    mousemove::Vector{Any}
    mouseover::Vector{Any}
    mouseup::Vector{Any}
    mouseout::Vector{Any}

    drag::Vector{Any}
    drop::Vector{Any}

    keydown::Vector{Any}
    keypress::Vector{Any}
    keyup::Vector{Any}
    AttachedEvents() = new([], [], [], [], [], [], [], [], [], [], [])
    # onload::Array
end
# document.event
# mutable struct Event
#     node::Element
#     copy::Element # save a copy of the origional node when overwritten by new data
#     action::AbstractString # an event should generally result in an action!
#     Event(node, action) = new(node, nothing, action)
# end
#-==============================================================================
mutable struct Page
         parent::Any  # First node needs a Psudo-parent too ..maybe!
         children::Vector{Any} # First node in a tree-like data structure representing all elements on page
         fixed::Element # First node in a tree-like data structure representing all elements on page
         styles::Dict
         head::Dict
         width::Float64
         height::Float64

         win::Any
         url::Any         # URL of page
         flags::BitArray{1}        #  buttonPressed
         focusNode::Any
         canvas::Any
         event::EventType
         eventsList::AttachedEvents
             function Page(url::String)
                     children::Vector{Element} = [Element()]
                     parent = children[1]
                     children[1].parent = parent
                 new(parent, children, Element(), Dict(), Dict(), 0,0, nothing, url, falses(8),
                    nothing, 0, EventType(), AttachedEvents())
             end
end




end
