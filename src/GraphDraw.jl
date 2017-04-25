

include("DomUtilities.jl")

module Naquadraw

using Cairo, Gtk.ShortNames # , NaquadahEvents # Graphics,
using Gtk

  include("GraphTypes.jl")
  include("GraphMethods.jl")


export
        DrawContent, DrawClippedContent,
          # get real data (margin, padding, border) instead of Nullables
          getReal, DrawBox, DrawCircle, DrawRoundedBox, textToRows, DrawText,
          PushToRow, FinalizeRow,
          # get calculated metrics
          getBorderBox, getContentBox, getMarginBox, getSize,
          TotalShapeWidth, TotalShapeHeight,
          DrawANode, InitializeRow,

          setcolor

          include("Events.jl")
          include("GraphFlags.jl")
include("LayoutBuild.jl")
# ======================================================================================
setcolor( ctx, r, g, b, a) = set_source_rgba(ctx, r, g, b, a);
setcolor( ctx, r, g, b) = set_source_rgb(ctx, r, g, b);
# ======================================================================================
# ======================================================================================
function DrawContent(ctx, document, node, clipPath=nothing)
  rows = node.rows
  border = get(node.shape.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
  padding = get(node.shape.padding, BoxOutline(0,0,0,0,0,0))
  parentArea = getContentBox(node.shape, getReal(node.shape)... )
  Shape = getShape(node)

  if Shape.flags[Clip] == true
      clipPath = getBorderBox(Shape, border, padding)
  end



  for i in 1:length(rows)
      row = rows[i]
      for j in 1:length(row.nodes)
          child = row.nodes[j]
          shape = getShape(child)
          # Only draw if visible! node.shape.flags[FixedHeight] == true &&
          if row.y < (node.shape.top + node.shape.height) && node.shape.flags[DisplayNone] == false
                 isa(shape, TextLine) && DrawText(ctx, row, shape, clipPath)
                 isa(shape, Circle) && DrawCircle(ctx, child, shape, clipPath)
                 isa(shape, NBox) &&
                   if child.shape.flags[IsRoundBox] == true
                     DrawRoundedBox(ctx, shape, clipPath)
                   else
                     DrawBox(ctx, shape, clipPath)
                   end

                !isa(child, TextLine) && DrawContent(ctx, document, child, clipPath)

                l,t,r,b = parentArea
                y = row.y + row.height
         end
      end
  end

  # Scroll bars..........
  #=
          type Scroller <: Geo
              x::Float32
              y::Float32
              contentWidth::Float32
              contentHeight::Float32
              Scroller() = new(0,0,0,0)
          end
  =#
  if node.shape.flags[IsVScroll] == true
                Shape = getShape(node)


      VScroller(ctx, document, node, Shape, clipPath)

  end
  if Shape.flags[Clip] == true
     reset_clip(ctx)
     clipPath = nothing
  end
#reset_clip(ctx)
end
# ======================================================================================
# ======================================================================================
function VScroller(ctx::CairoContext, document, node, shape, clipPath)

    canvas = document.canvas
    ctx = getgc(canvas)
    winHeight = height(canvas)

        border = get(shape.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
        padding = get(shape.padding, BoxOutline(0,0,0,0,0,0))
        #clipPath = getBorderBox(shape, border, padding)
        l,t,w,h = getBorderBox(shape, border, padding)
        h/node.scroll.contentHeight
        r, b = l+w-12, t+h-12

        realTop = abs(t)

        setcolor(ctx, .3,.3,.3, .8)
        rectangle(ctx,r,t,12,h )
        fill(ctx);
        diff = node.scroll.contentHeight - node.shape.height
        unit = (node.shape.height - 20)/diff
        y = (unit*node.scroll.y)

        setcolor(ctx, .6,.6,.6, 1)
        rectangle(ctx,r+1,t-y,10,20 )
        fill(ctx);
end




















# ======================================================================================
function Clippedfill(ctx, path)
    rectangle(ctx, path... )
    clip(ctx)
    fill(ctx)
end
# ======================================================================================
function Clippedstroke(ctx, path)
    rectangle(ctx, path... )
    clip(ctx)
    stroke(ctx)
    new_path(ctx);
    reset_clip(ctx)
end

# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
# ======================================================================================
function BackgroundImage(ctx::CairoContext, wide, tall, l, t, path)

     image = read_from_png(path);
     w = (image.width/2);
     h = (image.height/2);

     scale(ctx, wide/w, tall/h);
     translate(ctx,  (l*((w/wide)))-(l),  (t*(w/tall))-(t)); # 1029 >= w*2   l + l*(wide/w) + wide*(wide/w) =1014
     set_source_surface(ctx, image, l, t);
     paint(ctx);
     reset_transform(ctx)

end
# ======================================================================================
# http://www.nongnu.org/guile-cairo/docs/html/Patterns.html
# CALLED FROM:
# ======================================================================================
function DrawCircle(ctx::CairoContext, node, circle::Circle, clipPath)
    if clipPath !== nothing
        rectangle(ctx, clipPath... )
        clip(ctx)
    end
    border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    radius = circle.radius + (border.width*0.25)
    wide = radius - (border.width*0.25)
    l = circle.left + radius - (border.left*.5)
    t = circle.top  + radius - (border.top*.5)
    set_antialias(ctx,4)

    move_to(ctx, l, t)
    arc(ctx, l, t, wide, 0, 2*pi);
     clip(ctx);

  if circle.flags[HasImage] == true
DOM =  node.DOM
            #path = "C:\\Users\\Coloquio 11\\.julia\\v0.5\\NaquadahCore\\src\\SamplePages\\" # Win:
            path = "/home/travis/.julia/v0.5/NaquadahCore/src/SamplePages/"
            if haskey(DOM, "image")
                path = path * DOM["image"] # "Mountains.png"
            end
            # Example:
            # BackgroundImage(ctx, wide*0.4, wide, circle.left+20, circle.top, path)
            BackgroundImage(ctx, wide, wide, circle.left, circle.top, path)

  elseif  circle.flags[LinearGrad] == true
    pat = pattern_create_linear(l+0.0, t+180.0,
                                l+180.0, t+0.0 );
        for i in 1:length(circle.gradient)
                pattern_add_color_stop_rgba(pat, circle.gradient[i] ...);
        end
        # pattern_add_color_stop_rgba(pat, 1, 0, 0, 0, 1);
            # pattern_add_color_stop_rgba(pat, 0.5, 1, 1, 1, 0.4);
            # pattern_add_color_stop_rgba(pat, 0, 1, 0, 0, 1);
            move_to(ctx, l, t)
            arc(ctx, l, t, radius, 0, 2*pi);
            set_source(ctx, pat);
            fill(ctx);
            destroy(pat);

  elseif  circle.flags[RadialGrad] == true
    offsetX, offsetY = 0, 0 #This can be added later to the second x,y coords
    # color, offset, start
    pat = pattern_create_radial(l,         t,         1,
                                l+offsetX, t+offsetY, radius);
            pattern_add_color_stop_rgba(pat, 0, 0, 1, 0, 1);
            pattern_add_color_stop_rgba(pat, .5, 0, 0, 0, 1);
            pattern_add_color_stop_rgba(pat, 1, 0, 0, 1, 1);
            set_source(ctx, pat);
            move_to(ctx, l, t)
            arc(ctx, l, t, radius, 0, 2 * pi);
            fill(ctx);
            destroy(pat);
  else
          set_antialias(ctx,6)
          setcolor( ctx, circle.color...)

            move_to(ctx, l, t)
            arc(ctx, l, t, radius, 0, 2*pi);
            fill(ctx);
  end
       new_path(ctx); # path not consumed by clip
       reset_clip(ctx)

          if isdefined(border, :color) && length(border.color) > 2
            setcolor( ctx, border.color...)

            if clipPath !== nothing
                rectangle(ctx, clipPath... )
                clip(ctx)
            end
            set_line_width(ctx, border.top);
            arc(ctx, l, t, radius, 0, 2*pi);
                  # Clippedstroke(ctx, clipPath) #stroke(ctx);



                  stroke(ctx)
                  new_path(ctx);
                  reset_clip(ctx)

          end
end
#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function DrawBox(ctx::CairoContext, box::NBox, clipPath)
    if clipPath !== nothing
        rectangle(ctx, clipPath... )
        clip(ctx)
    end
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    padding = get(box.padding, BoxOutline(0,0,0,0,0,0))
    l,t,w,h = getBorderBox(box, border, padding)
    r, b = l+w, t+h
#= Draw a frame around outside of box!=#
    #setcolor(ctx, border.color...)
    #set_line_width(ctx, 1);
    #rectangle(ctx,l-1,t-1,w+1,h+1 )
    #stroke(ctx);
    if box.flags[BordersSame] == true
      if isdefined(box, :color) &&  length(box.color) > 2
        rectangle(ctx,l,t,w,h )
        setcolor(ctx, box.color...)
        fill(ctx);
      end

        setcolor(ctx, border.color...)
        set_line_width(ctx, border.left);
        rectangle(ctx,l,t,w,h )
        stroke(ctx);
    else
          borderWidth = max(border.left,border.top,border.right,border.bottom)
          if  box.flags[LinearGrad] == true
            pat = pattern_create_linear(l+0.0, t+180.0,
            l+180.0, t+0.0 );

            for i in 1:length(box.gradient)
                pattern_add_color_stop_rgba(pat, box.gradient[i] ...);
            end
            rectangle(ctx,l,t,w,h )
            set_source(ctx, pat);
            fill(ctx);
            destroy(pat);
          else
          rectangle(ctx,l,t,w,h )
          clip(ctx)

                line = (borderWidth/2)
                t -= (line - border.top)
                l -= (line - border.left)
                w += (line - border.left)+(line - border.right)
                h += (line - border.left)+(line - border.bottom)
              if isdefined(box, :color) &&  length(box.color) > 2
                rectangle(ctx,l,t,w,h )
                setcolor(ctx, box.color...)
          		  fill_preserve(ctx);
              end
    end

              # Borders...
              if isdefined(border, :color) && length(border.color) > 2
                  setcolor(ctx, border.color...)
          		    set_line_width(ctx, borderWidth);
              end


          		stroke(ctx);
          		set_antialias(ctx,1)
          reset_clip(ctx)
      end
end

#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function DrawRoundedBox(ctx::CairoContext, box::NBox, clipPath)
    if clipPath !== nothing
        rectangle(ctx, clipPath... )
        clip(ctx)
    end
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    padding = get(box.padding, BoxOutline(0,0,0,0,0,0))
    l,t,w,h = getBorderBox(box, border, padding)
    l -= (border.left*.5)
    t -= (border.top*.5)
    r, b = l+w, t+h
    set_antialias(ctx,1)
#= Draw a frame around outside of box!=#
    #setcolor(ctx, 0,0,0)
    #rectangle(ctx, l-1,t-1,w+3,h+3 )
    #set_line_width(ctx, 1);
    #stroke(ctx);

        set_antialias(ctx,6)
        borderWidth = max(border.left,border.top,border.right,border.bottom)
  radius = get(border.radius,[0,0,0,0])
                    TR = radius[1]
                    BR = radius[2]
                    BL = radius[3]
                    TL = radius[4]

        rot   =   1.5707963    # 90 * degrees

    new_sub_path(ctx);
   		arc(ctx, r - TR, t + TR, TR,     -rot,   0   );    # topRight
   		arc(ctx, r - BR, b - BR, BR,     0,      rot ); # bottomRight
   		arc(ctx, l + BL, b - BL, BL,     rot,    pi  );   # bottomLeft
   		arc(ctx, l + TL, t + TL, TL,     pi,     -rot);      # topLeft
 		close_path(ctx);

clip(ctx)
# border.left, border.top, border.right, border.bottom
line = (borderWidth/2)
t -= (line - border.top)
l -= (line - border.left)
r -= (border.right - line)
b -= (border.bottom - line)
		new_sub_path(ctx);
		arc(ctx, r - TR, t + TR, TR,     -rot,   0   );    # topRight
		arc(ctx, r - BR, b - BR, BR,     0,      rot ); # bottomRight
		arc(ctx, l + BL, b - BL, BL,     rot,    pi  );   # bottomLeft
		arc(ctx, l + TL, t + TL, TL,     pi,     -rot);      # topLeft
		close_path(ctx);

		# setcolor( cr, box.color...)
      #fill(ctx);
      setcolor(ctx, box.color...)
		fill_preserve(ctx);

		# Borders...
    setcolor(ctx, border.color...)
			set_line_width(ctx, borderWidth);
			stroke(ctx);
			set_antialias(ctx,1)
reset_clip(ctx)
end
#======================================================================================#
function DrawText(ctx, row, node, clipPath)
    if clipPath !== nothing
        rectangle(ctx, clipPath... )
        clip(ctx)
    end
  MyText = node.reference.shape
  left = node.left
set_antialias(ctx,6)
    slant  = fontSlant(MyText)
    weight = fontWeight(MyText)
    select_font_face(ctx, MyText.family, slant, weight);
    set_font_size(ctx, MyText.size);
    if MyText.flags[TextPath] == false
        move_to(ctx, node.left, node.top + MyText.size);
        setcolor(ctx, MyText.color...)
        show_text(ctx, node.text);
    else

      move_to(ctx, node.left+4, node.top + MyText.size+4);
      text_path(ctx, node.text);
      setcolor(ctx,  0,0,0,0.4) # fill color
      fill_preserve(ctx);
      setcolor(ctx,  0,0,0,0.1) # outline color
      set_line_width(ctx,  4 ); # 2.56 MyText.lineWidth
      stroke(ctx);

      move_to(ctx, node.left+4, node.top + MyText.size+4);
      text_path(ctx, node.text);
      setcolor(ctx,  0,0,0,0.2) # fill color
      fill_preserve(ctx);
      setcolor(ctx,  0,0,0,0.1) # outline color
      set_line_width(ctx,  2 ); # 2.56 MyText.lineWidth
      stroke(ctx);

      #move_to(ctx, node.left+4, node.top + MyText.size+4);
      #setcolor(ctx, 0,0,0,0.5) # shaddow color
      #show_text(ctx, node.text);

        move_to(ctx, node.left, node.top + MyText.size);
        text_path(ctx, node.text);
        setcolor(ctx, MyText.fill...) # fill color
        fill_preserve(ctx);
        setcolor(ctx, MyText.color...) # outline color
        set_line_width(ctx, MyText.lineWidth ); # 2.56 MyText.lineWidth
        stroke(ctx);
    end


end

#======================================================================================#
# Draw node text
# Cairo tutorial: https://www.cairographics.org/tutorial/
# CALLED FROM: DrawNode()
#======================================================================================#






end # module
