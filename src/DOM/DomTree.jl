import Base
using Gtk, HTTP # Requests

export FetchPage
# ======================================================================================
# Generate the DOM by recursively reading the dict conatining all structural and
# stylistic data.
# ======================================================================================
function CreateDomTree(parent::Element)
    DOM = parent.DOM

    if haskey(DOM, "overflow")
        overflow = DOM["overflow"]
        if overflow == "scroll" || overflow == "scroll-y"
            push!(DOM["nodes"], Tags_Default["v-scroll"])
        end
    end

    if isa(DOM["nodes"], Array)
        for DOM_node in DOM["nodes"]
            push!(parent.children, Element(DOM_node)) # node = parent.children[end]
            if DOM_node[">"] == "v-scroll"
                println(DOM_node[">"])
            end
            if haskey(DOM_node, "nodes") # Instantiate Children
                CreateDomTree(parent.children[end])
            end
        end
    end
end
# ======================================================================================
#
# ======================================================================================
function url2Dict(URL::String)
        uri = HTTP.parse(HTTP.URI, URL)
              if uri.scheme == "file"
                 File = pwd() * uri.path
                 f = open(f->read(f, String), File)
              elseif uri.scheme == "http" || uri.scheme == "https"
                  File = HTTP.request("GET", URL; verbose=3).body
                  f = String(Char.(File)) # Fix: ugly hack
              end
     return readSml(f)
end
# ======================================================================================
# Get/parse SML, create node and insert into document
# ======================================================================================
newpage = "file:///src/SamplePages/test.sml"
        # newpage = "file:///src/SamplePages/newtab.sml"
function FetchPage(document, URL::String = newpage)

        e = Element()
        e.DOM = url2Dict(URL)
        # ......................................................................
        push!(document.controls.children, e)
        push!(document.controls.DOM["nodes"], e.DOM)
        CreateDomTree(e)
end
# ======================================================================================
# win::Gtk.GtkWindowLeafGtk.GtkCanvas
# ======================================================================================
