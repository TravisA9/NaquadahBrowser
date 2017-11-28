import Base
using JSON, Requests, Gtk

export FetchPage
# ======================================================================================
"""
## CreateDomTree(document::Page, parent::Element)

Generate the DOM by recursively reading the dict conatining all structural and
stylistic data.

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
# ======================================================================================
function CreateDomTree(document::Page, parent::Element)
    DOM = parent.DOM
        if isa(DOM["nodes"], Array)
            DOM_nodes = DOM["nodes"]

            for i in eachindex(DOM_nodes)
                push!(parent.children, Element(DOM_nodes[i]))
                    node = parent.children[end]

                    if haskey(DOM_nodes[i], "nodes") # Instantiate Children
                        CreateDomTree(document, node)
                    end
            end
        end
end

# ======================================================================================
# win::Gtk.GtkWindowLeafGtk.GtkCanvas
"""
## FetchPage(win, URL::String, canvas::Gtk.GtkCanvas)

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/DOM/DomTree.jl#L54)
"""
# ======================================================================================
function FetchPage(win, URL::String, canvas::Gtk.GtkCanvas)
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
            
            node.DOM = Dict( ">" => "window", "display" => "block", "padding" => [0,0,0,0], "nodes" => []	)

                  # node.DOM[1] / tabControls / windowControls / tab
                  # node.DOM[2] / navigation
                  # node.DOM[3] / newPage

# Tabs
                push!( button["nodes"], JuliaIcon)
                push!( tabControls["nodes"], button)
                push!( tabControls["nodes"], tab)
                push!( tabControls["nodes"], NewPageIcon)
            push!(node.DOM["nodes"], tabControls)

# Navagation
                push!( navigation["nodes"], icons)
                push!( navigation["nodes"], downloadIcon)
                push!( navigation["nodes"], navBar)
            push!(node.DOM["nodes"], navigation)


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
