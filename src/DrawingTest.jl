#=
include("GraphDraw.jl")
include("Events.jl")
using Gtk.ShortNames, Cairo, Colors #  Graphics,
using Naquadraw, NaquadahEvents


c = @Canvas()
win = @Window("Canvas", 1000, 800)
push!(win, c)

type Doc
  # document
  event::EventType
  canvas::Any
  Doc() = new(EventType(), 0)
end

# ==============================================================================
@guarded draw(c) do widget

document = Doc()
  document.canvas = c
  AttatchEvents(document)
    ctx = getgc(c)
    h = height(c)
    w = width(c)
    set_antialias(ctx,1)
    # BoxElement(flags,left,top,width,height, color,opacity,padding,border,margin,offset)

    box = NBox()
    box.flags[IsRoundBox] = true # IsRoundBox IsBox
    # box.flags[BordersSame] = true
      box.color = [.5,.8,.8]
      box.margin = BoxOutline(10,20,8,3,18,23)
      box.offset = Point(30,40)
      box.left    = 100
      box.top     = 50
      box.width   = 450
      box.height  = 400
      box.padding = BoxOutline(1,1,1,1,2,2)
      box.border  = Border(1,1,1,1, 2,2, 0,[.0,.3,.6],[17,17,17,17])
    # box.border  = Border(1,3,4,10, 5,13, 0,[.0,.3,.6],[17,17,17,17])




    circle = Circle()
        circle.color   = [.2,.5,.5]
        circle.radius  = 18
        circle.border  = Border(1,1,1,1,2,2, 0,[.0,.3,.6],[17,7,7,7])


    MyText = NText()
        MyText.flags[TextBold] = true
        #MyText.flags[TextCenter] = true # TextCenter TextRight
        MyText.flags[AlignBase] = true # AlignBase, AlignMiddle
        MyText.size = 15.0
        MyText.lineHeight = 1.4
        MyText.height = MyText.size * MyText.lineHeight
        MyText.family = "Sans"
        MyText.color = [0,0,0]
        MyText.opacity = 1
        MyText.text = "This is some sample text for testing the text printing capabilities of cairo. This is some sample text for testing the text printing capabilities of cairo. This is some sample text for testing the text printing capabilities of cairo. This is some sample text for testing the text printing capabilities of cairo.. . "



 parentArea = getContentBox(box, getReal(box)... )

    rows = []

    #l, t, circleHeight, circleWidth = getMarginBox(circle)
    PushToRow(rows, parentArea, circle)

    box2 = NBox()
    box2.flags[IsRoundBox] = true # IsRoundBox IsBox
    # box.flags[BordersSame] = true
    box2.flags[FloatLeft] = true # FloatLeft, FloatRight
      box2.color = [.7,.5,.5]
      box2.margin = BoxOutline(10,10,10,10,20,20)
      box2.width   = 50
      box2.height  = 40
      box2.border  = Border(1,1,1,1, 2,2, 0,[0,0,0],[3,3,3,3])

      #  l, t, h, w = getMarginBox(box2)
  PushToRow(rows, parentArea, box2)

    circle2 = deepcopy(circle)
    circle2.color = [.5,.7,.5]
    circle2.flags[FloatRight] = true # FloatLeft, FloatRight
    PushToRow(rows, parentArea, circle2)

    row = textToRows(rows, parentArea, MyText)
    circle3 = deepcopy(circle)
    circle3.color = [.5,.5,.7]
    circle3.radius = 10
        #p, b, m = getReal(circle3)
    #l, t, circleHeight, circleWidth = getMarginBox(circle3)
    PushToRow(rows, parentArea, circle3)
    FinalizeRow(parentArea, rows[end])

l, t, w, h = getContentBox(box, getReal(box)... )
 p = get(box.padding, BoxOutline(0,0,0,0,0,0))
    box.height = rows[end].y - t + rows[end].height + p.height
            if isa(box, NBox)
              if box.flags[IsRoundBox] == true
                DrawRoudedBox(ctx, 1, box)
            else
                DrawBox(ctx, box)
              end
            end


        for i in 1:length(rows)
            row = rows[i]
            println("Row ", i)
            for j in 1:length(row.nodes)
                node = row.nodes[j]
                 if isa(node, TextLine)
                     DrawText(ctx, row, node)
                     println("text top: ", node.top)
                 end
                 if isa(node, Circle) #getContentBox(box::NBox, padding, border, margin)
                     DrawCircle(ctx, parentArea, node)
                 end
                 if isa(node, NBox)
                   if node.flags[IsRoundBox] == true
                     DrawRoudedBox(ctx, 1, node)
                   else
                     DrawBox(ctx, node)
                   end
                 end
            end
        end

println("Rows: ",length(rows))
end
show(c)
=#
