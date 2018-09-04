
export getCreateLastRow, Page, Scroller, Row, Element, TextElement,
       feedRow #Event,

#begin

# if this structure doesn't grow it should be elimenated. Pointless to have a structure for one member...
    mutable struct EventType
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
    space::Float64 # Space remaining 'til full
    height::Float64
    width::Float64 # because elements could be wider than the parent
    left::Float64  # TODO: change these to left/top for cmpatability
    top::Float64

    Finalize(n) = length(n.rows) > 0 ? FinalizeRow(n.rows[end]) : n.shape.top

    Row(left, top, width) = new(falses(32),[],width,0,width,left,top)
    function Row(node)
        top = Finalize(node)
        r = Row(node.shape.left, top, node.shape.width)
        push!(node.rows, r ) # There were no rows. Create one!
        return r
    end

    function Row(rows::Vector{Row}, left::Float64, top::Float64, width::Float64)
        r = Row(left, top, width)
        push!(rows, r)
        return r
    end
end
# maybe rename: GetNewRow or something similar.
getCreateLastRow(n) = length(n.rows) < 1 ? Row(n) : n.rows[end]

function getCreateLastRow(rows::Vector{Row}, l, t, w)
    if length(rows) < 1
        r = Row(l, t, w)
        push!(rows, r) # WAS: Row(rows, l, t, w)
    end
    return rows[end]
end

#-==============================================================================
#-==============================================================================
function feedRow(parent, node)



     width, height = getSize(node.shape)

    if parent.shape.width < 1 # set parent width
        parent.shape.width = width
    end

    row = getCreateLastRow(parent)

    if node.shape.flags[Marked]
        println("parrent.row.space: $(row.space) , node.width: $(width)")

    end

    if row.space < width # Not enough room for node!
        row = Row(parent) # This automatically finalises the row and returns a new one.
    end

    row.space -= width
    row.height = max(row.height, height)

    OffsetX, OffsetY = contentOffset( node.shape )
    node.shape.left = row.left + OffsetX
    row.left += width
    node.shape.top = row.top + OffsetY

    push!(row.nodes, node)
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
mutable struct TextElement
    DOM::Dict       # Reference to dictionary counterpart of this node
    parent::Any               # This node's parent
    shape::Any # link to layout representation of node
    TextElement(parent, shape) = new(Dict(), parent, shape)
    TextElement(shape) = new(Dict(), nothing, shape)
    TextElement() = new(Dict(), nothing, nothing)
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




# end
