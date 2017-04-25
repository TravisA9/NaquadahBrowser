import Base
using Gtk, JSON, Cairo, Requests
using Gtk.ShortNames
using ImageMagick, Images
# defaultPage = "https://travisa9.github.io/NaquadahBrowser/src/SamplePages/Naquadah.json"
# defaultPage = "file:///.julia/v0.5/NaquadahBrowser/src/SamplePages/Landing.json"
defaultPage = "file:///SamplePages/Landing.json"
global PATH = pwd() * "/data/"
global PAGES = "file://.julia/v0.5/NaquadahBrowser/src/SamplePages/Naquadah.json"


# ======================================================================================
# ======================================================================================
type Point
    x::Float32
    y::Float32
end
# ======================================================================================
# ======================================================================================
        const RowHasFloatLeft = 1
        const RowHasFloatRight = 2
        const IncompleteRow = 3

type Row
    flags::BitArray{1} #Any
    nodes::Array{Any}
    height::Float32
    x::Float32
    y::Float32
    Row() = new(falses(8),[],0,0,0)
end
# ======================================================================================
# ======================================================================================
type Element
        #.......................................................................
        #==#  DOM::Dict       # Reference to dictionary counterpart of this node
        #.......................................................................
        #==#  parent::Any               # This node's parent
        #==#  children::Array{Element,1} # Children in order they appear in DOM
    #...........................................................................
    # Layout dependant details
    rows::Array{Row,1}  # references to children by row
    floater::Array      # list of float type children
    flags::BitArray{1} # Boolean information about the DOM/Layout
    shape::Any # link to layout representation of node

        function Element(DOM=Dict())
            parent = nothing
                rows::Array{Row,1} = []
                children::Array{Element,1} = []
                floater::Array{Element,1} = []
                push!(rows, Row())
            new(DOM, parent, children, rows, floater, falses(64), nothing)
        end
end
# ======================================================================================
# ======================================================================================
type Page
         parent::Any  # First node needs a Psudo-parent too ..maybe!
         children::Array{Element,1} # First node in a tree-like data structure representing all elements on page
         styles::Dict
         head::Dict

         url::Any         # URL of page
         # events::EventTypes  # All registered events
         flags::BitArray{1}        #  buttonPressed
         mousedown::Point       # These may be better than trying to copy the nodes
         mouseup::Point
         focusNode::Any
         hoverNode::Any
         # ui::PageUI   # Window
             function Page(url::String)
                 #parent::Element = Element()
                 children::Array{Element,1} = [Element()]
                     parent = children[1]
                     children[1].parent = parent
                 styles, head = Dict(), Dict()
                 flags = falses(8)
                 mousedown, mouseup =  Point(0, 0), Point(0, 0)
                 focusNode, hoverNode = 0, 0
                 new(parent, children, styles, head, url, flags, mousedown, mouseup, focusNode, hoverNode)
             end
end
# ======================================================================================
# Print out Dict but not children
# CALLED FROM: Below, third button event line 100+
# ======================================================================================
function printDict(DOM)

    dict = copy(DOM)
    dict["nodes"] = "[...]"
    #contents = []

       keyList = sort(collect(keys(dict)))
       str, key, value = "","",""
           for k in 1:length(keyList)
             key = keyList[k]
               if isa(dict[key], Dict)
                 value = "{ $(printDict(dict[key])) } "
               else
                 value = dict[keyList[k]]
               end
               if k != 1; key = ", $(key)"; end
            str =   "$(str)$(key):$(value)"
           end
    println(str)
    # return str
end
# ======================================================================================
#
# ======================================================================================
function CreateDomTree(document::Page, parent::Element)
    DOM = parent.DOM
    if isa(DOM["nodes"], Array)
            DOM_nodes = DOM["nodes"]
            for i in eachindex(DOM_nodes)
                push!(parent.children, Element(DOM_nodes[i]))
                node = parent.children[end]
                printDict(node.DOM)
                if haskey(DOM_nodes[i], "nodes") # Instantiate Children
                    CreateDomTree(document, node)
                end
            end
    end
end
# ======================================================================================
#
# ======================================================================================
function FetchPage(URL::String)
       # .......................................................................
       # get the file...
       uri = URI(URL)
              if uri.scheme == "file"
                 File = pwd() * uri.path
                       Page_text = readstring(open(File))
              elseif uri.scheme == "http" || uri.scheme == "https"
                  got = get(URL; timeout = 10.0)
                  Page_text = readall(got)
              end

        pageContent = JSON.parse(Page_text)
        # ......................................................................
        document = Page(URL)
        node = document.children[1]
        parent = document.parent

        if haskey(pageContent, "head")
            document.head = pageContent["head"]
        end
        if haskey(pageContent, "style")
            document.styles = pageContent["style"]
        end
        if haskey(pageContent, "body")
            node.DOM = Dict( ">" => "window", "nodes" => [Dict()] )
            push!(node.DOM["nodes"], Dict("nodes" => pageContent["body"]))
        end
        # ......................................................................
        # ParseDictionary(document, node)  # maybe some extra preproccessing.
        # SetDOMdefaults(document, node) # Set tag, class and style attributes.
        CreateDomTree(document, node)
        # SetConstantAtributes(document, node) # this is to set layout attributes that will not change
end
# ======================================================================================
# ======================================================================================
   FetchPage(defaultPage)
# ======================================================================================
#
# ======================================================================================
