import Base
using JSON, Gtk, HTTP # Requests

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
#
# ======================================================================================
# function newPage(document, name)
#         node = document.children[1]
#         parent = document.parent
#
# end
# ======================================================================================
# win::Gtk.GtkWindowLeafGtk.GtkCanvas
# ======================================================================================
# function FetchPage(win, URL::String, canvas::Gtk.GtkCanvas, wide)
function FetchPage(document, URL::String)

    node = document.children[1]
       # .......................................................................
       # get the file...
       uri = HTTP.parse(HTTP.URI, URL)
              if uri.scheme == "file"
                 File = pwd() * uri.path
                       Page_text = open(f->read(f, String), File)
              elseif uri.scheme == "http" || uri.scheme == "https"
                  got = HTTP.request("GET", URL; verbose=3).body
                  Page_text = readall(got)
              end

        pageContent = readSml(Page_text)
        # ......................................................................
        document.styles = Dict("charset"=>"utf-8")
        document.head = Dict("charset"=>"utf-8","author"=>"Travis Deane Ashworth","links"=>Dict("url"=>"http://travis.net16.net/test.sml"),"keywords"=>"web tech,browser concept,sml Pages,fragmented web tech","title"=>"MyPage")

                push!(node.DOM["nodes"], tabControls)
                push!(node.DOM["nodes"], navigation)

                tab["nodes"][2]["text"] = document.head["title"]
                plus = pop!(tabControls["nodes"][1]["nodes"]) # Take button off end.
                push!(tabControls["nodes"][1]["nodes"], tab)  # Add new tab.
                push!(tabControls["nodes"][1]["nodes"], plus) # put button back on.
                # Page content
                newPage["nodes"] = [pageContent]
                push!(node.DOM["nodes"], newPage)
        # ......................................................................
        CreateDomTree(document, node)
end
# ======================================================================================
