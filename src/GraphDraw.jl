

include("DomUtilities.jl")

module Naquadraw

global PATH = pwd() * "/src/SamplePages/"
using Cairo, Gtk.ShortNames
using Gtk

  include("GraphTypes.jl")
  include("GraphMethods.jl")


export
          DrawContent, DrawClippedContent, DrawBox, DrawCircle, DrawRoundedBox,
          DrawText, setcolor

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



  if clipPath !== nothing
      rectangle(ctx, clipPath... )
      clip(ctx)
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
        if node.shape.flags[IsVScroll] == true
                    Shape = getShape(node)
          VScroller(ctx, document, node, Shape, clipPath)
      end
  if Shape.flags[Clip] == true #|| clipPath === nothing
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
#
# CALLED FROM:
# ======================================================================================
#=
inline_png2 = b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00d\x00\x00\x00d\x08\x02\x00\x00\x00\xff\x80\x02\x03\x00\x00\x00\x06bKGD\x00\xff\x00\xff\x00\xff\xa0\xbd\xa7\x93\x00\x00\x01=IDATx\x9c\xed\xdc\xc1i\x85@\x14@\xd1IH!\x96bi\x96f)\x96\x92E@!\x01\x7f\xeeF\xfdp\xce\xca\x9d\xc3\xe5\xb9{\xce\xc7\xb2,\x83\xff\xf9\xbc\xfb\x00\xefD\xac@\xac@\xac@\xac@\xac@\xac@\xac@\xac\xe0\xeb\xee\x03\xfc\xb1\xaec]\xc7\x18c\x9e\xc7<\xdf{\x96_LV V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V\xf0j[\xf9gq\xf8J\xdbv<\\\xff\xf6\xd3\xfd\xe8\xe7\xc5\xdam\xdb\x11\xee2\xa7\xb1|\x86\xc1\xab\xc9\xba~m\x7f\x1f\xa8i\x1a\xd3t\xf5\xdbO=/\xd6\xba\x1e\xb1\xfca\xf1\xbe\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\xc4\n\x9ew\x1f\xfc\xf3\xae\x81\xdf\x99\xac@\xac@\xac@\xac@\xac@\xac@\xac@\xac@\xac\xe0\x1b\xaf\xef\x1c\xd4\x17\xfe\xcaX\x00\x00\x00\x00IEND\xaeB`\x82"
png_stream = IOBuffer();
write(png_stream,inline_png2);
seekstart(png_stream);

imagesurface = read_from_png(png_stream);
set_source_surface(cr, imagesurface, 0, 0);
paint(cr);
=#
# ======================================================================================
# Examples
# Stream: https://github.com/JuliaGraphics/Cairo.jl/blob/master/samples/sample_imagestream.jl
# Alpha:  https://github.com/JuliaGraphics/Cairo.jl/blob/master/samples/sample_alpha_paint.jl
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
# ======================================================================================
function linearGrad(ctx::CairoContext, left,top, rad, gradient)
    pat = pattern_create_linear(left+0.0, top+180.0, left+180.0, top+0.0 );
    for i in 1:length(gradient)
            pattern_add_color_stop_rgba(pat, gradient[i] ...);
    end
    move_to(ctx, left+rad, top)
    arc(ctx, left, top, rad, 0, 2*pi);
    set_source(ctx, pat);
    fill(ctx);

    #Circle(ctx, left,top, rad, [1,1,1])
    destroy(pat);#return pat
end
# ======================================================================================
# http://www.nongnu.org/guile-cairo/docs/html/Patterns.html
# CALLED FROM:
# ======================================================================================
function DrawCircle(ctx::CairoContext, node, circle::Circle, clipPath)
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
            if haskey(DOM, "image")
                path = PATH * DOM["image"] # "Mountains.png"
            end
            BackgroundImage(ctx, wide, wide, circle.left, circle.top, path)

  elseif  circle.flags[LinearGrad] == true
         #pat = pattern_create_linear(l+0.0, t+180.0, l+180.0, t+0.0 );
         #for i in 1:length(circle.gradient)
         #         pattern_add_color_stop_rgba(pat, circle.gradient[i] ...);
         #end
        linearGrad(ctx, l,t, radius, circle.gradient)
            #Circle(ctx, l,t, radius, circle.color)
            #destroy(pat);

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
            Circle(ctx, l,t, radius, circle.color)
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

                  stroke(ctx)
                  new_path(ctx);
                  reset_clip(ctx)

          end
end
#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function Circle(ctx::CairoContext, left,top, rad, color)

        move_to(ctx, left+rad, top)
        arc(ctx, left, top, rad, 0, 2*pi);
        setcolor( ctx, color...)
        fill(ctx);
end

macro Circle(ctx::CairoContext, left,top, rad, color)
    quote
        #setcolor(left  - $(padding).left  - ($(border).left *.5))

        setcolor( ctx, color...)
        move_to(ctx, left, top)
        arc(ctx, left, top, rad, 0, 2*pi);
    end
end
#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function DrawBox(ctx::CairoContext, box::NBox, clipPath)
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    padding = get(box.padding, BoxOutline(0,0,0,0,0,0))
    l,t,w,h = getBorderBox(box, border, padding)
    r, b = l+w, t+h
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
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    padding = get(box.padding, BoxOutline(0,0,0,0,0,0))
    l,t,w,h = getBorderBox(box, border, padding)
    l -= (border.left*.5)
    t -= (border.top*.5)
    r, b = l+w, t+h
    set_antialias(ctx,1)

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
