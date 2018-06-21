import Base
using JSON, Requests, Gtk

export FetchPage
# ======================================================================================
# Generate the DOM by recursively reading the dict conatining all structural and
# stylistic data.
# ======================================================================================
function CreateDomTree(document::Page, parent::Element)
    DOM = parent.DOM
    if isa(DOM["nodes"], Array)
        for DOM_node in DOM["nodes"]
            push!(parent.children, Element(DOM_node))
            node = parent.children[end]
            if haskey(DOM_node, "nodes") # Instantiate Children
                CreateDomTree(document, node)
            end
        end
    end
end
# ======================================================================================
# win::Gtk.GtkWindowLeafGtk.GtkCanvas
# ======================================================================================
function FetchPage(win, URL::String, canvas::Gtk.GtkCanvas, wide)
    # Gtk.GtkWindowLeafGtk.GtkCanvas
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
        document.win = win # Circular reference
        document.canvas = canvas
        node = document.children[1]
        parent = document.parent

        if haskey(pageContent, "head")
            document.head = pageContent["head"]
        end
        if haskey(pageContent, "style")
            document.styles = pageContent["style"]
        end
        if haskey(pageContent, "body")
                CreateControls(node,wide)
                tab["nodes"][2]["text"] = document.head["title"]
                plus = pop!(tabControls["nodes"][1]["nodes"]) # Take button off end.
                push!(tabControls["nodes"][1]["nodes"], tab)  # Add new tab.
                push!(tabControls["nodes"][1]["nodes"], plus) # put button back on.
                # Page content
                newPage["nodes"] = pageContent["body"] # add this way because it is an array!
                push!(node.DOM["nodes"], newPage)

        end
        # ......................................................................
        # ParseDictionary(document, node)  # maybe some extra preproccessing.
        # SetDOMdefaults(document, node) # Set tag, class and style attributes.
        CreateDomTree(document, node)
        # SetConstantAtributes(document, node) # this is to set layout attributes that will not change
        return document, node
end
# ======================================================================================
function CreateControls(node, wide)
        # node.DOM[1] / tabControls / windowControls / tab
        # node.DOM[2] / navigation
        # node.DOM[3] / newPage

        # Tabs
        node.DOM = Dict( ">" => "window", "width" => wide, "display" => "block", "padding" => [0,0,0,0], "nodes" => []	)

            #push!( button["nodes"], JuliaIcon)
            #push!( tabControls["nodes"], button)

            #push!( tabControls["nodes"], tab)
            #push!( tabControls["nodes"], NewPageIcon)
        push!(node.DOM["nodes"], tabControls)

        # Navagation
            #push!( navigation["nodes"], icons)
            #push!( navigation["nodes"], downloadIcon)
            #push!( navigation["nodes"], navBar)
        push!(node.DOM["nodes"], navigation)

end
