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
        #document.node = []
        #document.content = Dict()

       #  result = match(r"(\w+:\/\/)([-a-zA-Z0-9:@;?&=\/%\+\.\*!'\(\),\$_\{\}\^~\[\]`#|]+)", document.url)
       #
       #  if result[1] == "file://"
       #      f = open(result[2])
       #      Page_text = readall(f)
       #  else         end
            println("document.url:   ",document.url)
            println("URL:   ",URL)
             got = get(URL; timeout = 10.0)
             Page_text = readall(got)

        pageContent = JSON.parse(Page_text)
         if haskey(pageContent, "head")
             document.head = pageContent["head"]
         end
        if haskey(pageContent, "style")
            document.styles = pageContent["style"]
        end

        document.node = []
        push!(document.node, MyElement())
        document.node[1].padding = MyBox(10,10, 10,10, 20,20)

        if haskey(pageContent, "body")
            document.node[1].DOM = Dict("nodes" => pageContent["body"])
        else
            document.node[1].DOM = Dict("nodes" => pageContent)
        end
        document.hoverNode = 0
        # document.ui set in this function
        MakeUserInterface(document)
        DrawPage(document)
end
