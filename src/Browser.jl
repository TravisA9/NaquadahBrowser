#======================================================================================#
# FetchPage()
#======================================================================================#

# ======================================================================================
# Fetch the page and build the DOM and Layout Tree  ...then render
# CALLED FROM: BrowserTypes.jl  -->  MakeUserInterface()
# ======================================================================================
#        content::Dict          # dictionary of elements IE. DOM
#           node::Array         # First node in a tree-like data structure representing all elements on page
#            DOM::Any           # Link to dictionary counterpart
#            url::Any           # URL of page
#         events::EventTypes
#      focusNode::Any
#      hoverNode::Any
#         styles::Dict
#           head::Any
#             ui::PageUI
# ======================================================================================
function FetchPage(URL::String)
# println("--:",URL,":--")

    document = Page()

        document.ui = PageUI(0, 0, 0, 0, 0)
        document.url = URL
# For URI parsing see:
#        https://github.com/JuliaWeb/URIParser.jl/blob/master/README.md
       uri = URI(URL)
              if uri.scheme == "file"
                 File = pwd() * uri.path
                       Page_text = readstring(open(File))
              elseif uri.scheme == "http" || uri.scheme == "https"
                  got = get(URL; timeout = 10.0)
                  Page_text = readall(got)
              end


        pageContent = JSON.parse(Page_text)
         if haskey(pageContent, "head")
             document.head = pageContent["head"]
         end
        if haskey(pageContent, "style")
            document.styles = pageContent["style"]
        end

        # Create root node
        document.node = []
        push!(document.node, MyElement())
        # Let's try to always refer to current node as 'node' for simplicity!
        node = document.node[1]
        node.padding = MyBox(10,10, 10,10, 20,20)
        push!(node.rows,Row())
        node.rows[end].height = 0
        node.rows[end].y = 0
        # println(node.content)

        # Give root a dummy parent
        document.parent = MyElement()
        parent = document.parent
        parent.content = Box(0,0, 0,0)
          push!(parent.rows,Row())
          parentRow = parent.rows[end]
          parentRow.height = 0
          parentRow.y = 0
          push!(parentRow.nodes, document.node)
          # println(parent.content)




       # println(node.rows)

        if haskey(pageContent, "body")
            node.DOM = Dict("nodes" => pageContent["body"])
        else
            node.DOM = Dict("nodes" => pageContent)
        end
        node.DOM["nodes"][1]["id"] = "root"
        document.hoverNode = 0
        # document.ui set in this function
        MakeUserInterface(document) # IN: BrowserTypes.jl
        DrawPage(document)
end
