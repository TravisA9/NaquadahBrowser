global PATH = pwd() * "/src/SamplePages/BrowserImages/"

using Cairo, Gtk, Gtk.ShortNames


export
          DrawViewport, DrawContent, DrawClippedContent, DrawBox, DrawShape,
          DrawRoundedBox, DrawText, setcolor

"""
## Graphics: exported functions

```julia-repl
DrawViewport, DrawContent, DrawClippedContent, DrawBox, DrawShape,
DrawRoundedBox, DrawText, setcolor
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L6)
"""
#          include("Events.jl")
#          include("GraphFlags.jl")
#          include("LayoutBuild.jl")

# dashes_by_name = [  "solid", "dot", "dotdashed", "longdashed", "dash", "dotdotdashed", "dotdotdotdashed"   ]
# ======================================================================================
# As I aquire a better understanding of how Cairo works, no doubt, this file will change
# drastically!
# ======================================================================================



# ======================================================================================
# Accept color values with or without alpha
# ======================================================================================
setcolor( ctx::Cairo.CairoContext, r, g, b, a) = set_source_rgba(ctx, r, g, b, a);
setcolor( ctx::Cairo.CairoContext, r, g, b) = set_source_rgb(ctx, r, g, b);
# ======================================================================================
# First draw all page elements (not controls) that flow and then draw "fixed" elements
# ======================================================================================
function DrawViewport(ctx::Cairo.CairoContext, document::Page, node::Element)
    DrawContent(ctx, document, node)
    DrawContent(ctx, document, document.fixed)
end
# ======================================================================================
"""
## DrawContent(ctx, document, node, clipPath=nothing)

This takes a node and draws it along with all its children.

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
# ======================================================================================
function DrawContent(ctx::Cairo.CairoContext, document::Page, node::Element, clipPath=nothing)
      rows = node.rows
      border = get(node.shape.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
      padding = get(node.shape.padding, BoxOutline(0,0,0,0,0,0))
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
                   if isa(shape, TextLine)
                       DrawText(ctx, row, shape, clipPath)
                   else
                       DrawShape(ctx, child, shape, clipPath)
                   end
                # Now draw children
                !isa(child, TextLine) && DrawContent(ctx, document, child, clipPath)
         end
      end
  end

      # Scroll bars.......... TODO: fix
        if node.shape.flags[IsVScroll] == true
                    Shape = getShape(node)
          VScroller(ctx, document, node, Shape, clipPath)
      end
      if Shape.flags[Clip] == true #|| clipPath === nothing
         reset_clip(ctx)
         clipPath = nothing
      end
end
# ======================================================================================
# http://www.nongnu.org/guile-cairo/docs/html/Patterns.html
# Draw a circle.
# TODO: remove node from function
"""
## DrawShape(ctx::CairoContext, node, shape, clipPath)

Draw ...


[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
# ======================================================================================
function DrawShape(ctx::CairoContext, node::Element, shape::Draw, clipPath)
    Cairo.save(ctx)
    path = GetPath(shape)
    # set_antialias(ctx,4)
    setPath(ctx::CairoContext, path)
    clip(ctx);
  if shape.flags[HasImage] == true
        DOM =  node.DOM
            if haskey(DOM, "image")
                imagePath = PATH * DOM["image"] # "Mountains.png"
            end
            BackgroundImage(ctx, path.wide, path.tall, shape.left, shape.top, imagePath)

  elseif  shape.flags[LinearGrad] == true
        linearGrad(ctx, path, shape.gradient)
  elseif  shape.flags[RadialGrad] == true
        radialGrad(ctx, path, shape.gradient)
  else
          # set_antialias(ctx,6)
          if isdefined(shape, :color) &&  length(shape.color) > 2
            setPath(ctx::CairoContext, path)
            setcolor(ctx, shape.color...)
            fill(ctx);
          end
  end
  restore(ctx)
  #reset_clip(ctx)
     thickness = setClipPath(ctx::CairoContext, path)
     clip(ctx)
          if isdefined(path.border, :color) && length(path.border.color) > 2
                setcolor( ctx, path.border.color...)
                # TODO: add clipping for the border path as well to clean up edges.
                #if clipPath !== nothing
                    # rectangle(ctx, clipPath... )
                    # clip(ctx)
                #end
                #clip_preserve()
                # save(ctx)
                        set_line_type(ctx, path.border.style)
                        set_line_width(ctx, thickness);
                        setborderPath(ctx::CairoContext, path)
                        stroke(ctx)
                # restore(ctx)

                # reset_clip(ctx)
          end
        reset_clip(ctx)
end
# ======================================================================================
# Temporary shortcut: draw the virticle scroll bar
"""
## VScroller(ctx::CairoContext, document, node, shape, clipPath)

Temporary hack: draw the virticle scroll bar

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
# ======================================================================================
function VScroller(ctx::CairoContext, document::Page, node::Element, shape::Draw, clipPath)

    canvas = document.canvas
    ctx = getgc(canvas)
    winHeight = document.height # height(canvas)

        border = get(shape.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
        padding = get(shape.padding, BoxOutline(0,0,0,0,0,0))
        l,t,w,h = getBorderBox(shape, border, padding)
        h/node.scroll.contentHeight
        r, b = l+w-12, t+h-12

        realTop = abs(t)

        setcolor(ctx, .3,.3,.3, .3)
        rectangle(ctx,r,t,12,h )
        fill(ctx);
        #.............................................................
         height       = node.shape.height - node.shape.top    # Height of the viewport and of the scrollbarArea
         scrollHeight = node.scroll.contentHeight     # Height of the content
         scrollTop    = node.scroll.y      # Scrolled position of the content from the top
         #.............................................................
         scrollButHeight = height / (scrollHeight / height)
         y = scrollTop / (scrollHeight / height)
         #.............................................................
         #.............................................................

        setcolor(ctx, .4,.4,.4, 1)
        rectangle(ctx,r+1,t-y,10,scrollButHeight )
        fill(ctx);
end




















#  (from Cairo/src/cairo.jl):
#  function CairoImageSurface(img::Array{Uint32,2}, format::Integer; flipxy::Bool = true)
# CairoImageSurface(ary, fmt) copies the input array, but you can access the raw pixels
#  (R/W) by using the .data attribute of the surface.
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




type NQCircle
    border::Border
    radius::Float64
    left::Float64
    top::Float64
    wide::Float64
    tall::Float64
    NQCircle() = new()
end
type NQBox
    border::Border
    padding::BoxOutline
    left::Float64
    top::Float64
    wide::Float64
    tall::Float64
    right::Float64
    bottom::Float64
    NQBox() = new()
end

# ======================================================================================
"""
## BackgroundImage(ctx::CairoContext, wide::Float64, tall::Float64, l::Float64, t::Float64, path)

Draw the background image at 100% width and height.
# Examples
 Stream: https://github.com/JuliaGraphics/Cairo.jl/blob/master/samples/sample_imagestream.jl
 Alpha:  https://github.com/JuliaGraphics/Cairo.jl/blob/master/samples/sample_alpha_paint.jl


[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
# ======================================================================================
function BackgroundImage(ctx::CairoContext, wide::Float64, tall::Float64, l::Float64, t::Float64, path)

     image = read_from_png(path);
     w = image.width;  # w = (image.width/2);
     h = image.height; # h = (image.height/2);

     scale(ctx, wide/w, tall/h);
     translate(ctx,  (l*((w/wide)))-(l),  (t*(w/tall))-(t)); # 1029 >= w*2   l + l*(wide/w) + wide*(wide/w) =1014
     set_source_surface(ctx, image, l, t);
     paint(ctx);
     reset_transform(ctx)
end
# ======================================================================================
# Draw a linear gradient
"""
## linearGrad(ctx::CairoContext, shape, gradient)

Draw a linear gradient.

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
# ======================================================================================
function linearGrad(ctx::CairoContext, shape, gradient)
    pat = pattern_create_linear(shape.left+0.0, shape.top+180.0, shape.left+180.0, shape.top+0.0 );
    for i in 1:length(gradient)
            pattern_add_color_stop_rgba(pat, gradient[i] ...);
    end
    setPath(ctx, shape)
    set_source(ctx, pat);
    fill(ctx);
    destroy(pat);
end
"""
## radialGrad(ctx, path, gradient)

Draw a radial gradient.

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
# ======================================================================================
function radialGrad(ctx::CairoContext, path, gradient)
    offsetX, offsetY = 0, 0 #This can be added later to the second x,y coords
    # color, offset, start
    pat = pattern_create_radial(path.left,         path.top,         1,
                                path.left+offsetX, path.top+offsetY, path.wide*.5);
            pattern_add_color_stop_rgba(pat, 0, 0, 1, 0, 1);
            pattern_add_color_stop_rgba(pat, .5, 0, 0, 0, 1);
            pattern_add_color_stop_rgba(pat, 1, 0, 0, 1, 1);
            set_source(ctx, pat);
            setPath(ctx, path)
            fill(ctx);
            destroy(pat);
end
# ======================================================================================
"""
## GetPath(shape::NBox)

...

## GetPath(shape::Circle)
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
# ======================================================================================
function GetPath(shape::NBox)
    b = NQBox()
    b.border  = get(shape.border,  Border(0,0,0,0,0,0, "solid",[],[0,0,0,0]))
    b.padding = get(shape.padding, BoxOutline(0,0,0,0,0,0))


        # b.left = shape.left   - b.padding.left   - (b.border.left *.5)
        # b.top  = shape.top    - b.padding.top    - (b.border.top *.5)
        # b.wide = shape.width  + b.padding.width  + (b.border.width)
        # b.tall = shape.height + b.padding.height + (b.border.height)

    b.left, b.top, b.wide, b.tall = getBorderBox(shape, b.border, b.padding)
    b.left  -= (b.border.left*.6)
    b.top   -= (b.border.top*.6)
    b.right  = b.left + b.wide
    b.bottom = b.top + b.tall
    return b
end

function GetPath(shape::Circle)
        c = NQCircle()
        border   = get(shape.border,  Border(0,0,0,0,0,0, "solid",[],[0,0,0,0]))
        c.border = border
        c.wide   = shape.radius*2
        c.tall   = shape.radius*2
        c.radius = shape.radius + (border.width*0.25)
        c.left   = shape.left + c.radius - (border.left*.5)
        c.top    = shape.top  + c.radius - (border.top*.5)
    return c
end
# ======================================================================================#
# Set circle path and fill with color
"""
## setPath(ctx::CairoContext, shape::NQBox)

...


[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
# ======================================================================================#
function setPath(ctx::CairoContext, shape::NQBox)
    if !isnull(shape.border.radius) #(TR + BR + BL + TL) > 0
        radius = get(shape.border.radius,[0,0,0,0])
        TR = radius[1]
        BR = radius[2]
        BL = radius[3]
        TL = radius[4]
              rot   =   1.5707963    # 90 * degrees
          # TODO: see if curveTo() will work to simplify this.
                new_sub_path(ctx);
         		arc(ctx, shape.right - TR, shape.top    + TR, TR,     -rot,   0   );    # topRight
         		arc(ctx, shape.right - BR, shape.bottom - BR, BR,     0,      rot ); # bottomRight
         		arc(ctx, shape.left  + BL, shape.bottom - BL, BL,     rot,    pi  );   # bottomLeft
         		arc(ctx, shape.left  + TL, shape.top    + TL, TL,     pi,     -rot);      # topLeft
       	        close_path(ctx);
    else
        rectangle(ctx, shape.left, shape.top, shape.wide, shape.tall )
    end
end
function setPath(ctx, shape::NQCircle)
        move_to(ctx, shape.left, shape.top)
        arc(ctx, shape.left, shape.top, shape.wide*.5, 0, 2*pi);
end
# ======================================================================================
"""
## setClipPath(ctx::CairoContext, shape::NQCircle)

...

# Examples
```julia-repl
```
[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
function setClipPath(ctx::CairoContext, shape::NQCircle)
    b  = shape.border.top #*.5
        move_to(ctx, shape.left + shape.radius, shape.top)
        arc(ctx, shape.left, shape.top, shape.radius+b, 0, 2*pi);
  return b
end

function setClipPath(ctx::CairoContext, shape::NQBox)
  bw  = shape.border.width*.5
  bh  = shape.border.height*.5
  borderWidth = max(shape.border.left, shape.border.top, shape.border.right,shape.border.bottom)

  if !isnull(shape.border.radius) #(TR + BR + BL + TL) > 0
      radius = get(shape.border.radius,[0,0,0,0])
      TR = radius[1]
      BR = radius[2]
      BL = radius[3]
      TL = radius[4]
            rot   =   1.5707963    # 90 * degrees
        # TODO: see if curveTo() will work to simplify this.
        borderWidth = max(shape.border.left, shape.border.top, shape.border.right,shape.border.bottom)
        line = (borderWidth/2)
        t = shape.top  #- (line - shape.border.top)
        l = shape.left  #- (line - shape.border.left)
        r = shape.right       #(shape.border.right - line)
        b = shape.bottom      #(shape.border.bottom - line)
            new_sub_path(ctx);
              arc(ctx, r - TR, t + TR, TR,     -rot,   0   );    # topRight
              arc(ctx, r - BR, b - BR, BR,     0,      rot ); # bottomRight
              arc(ctx, l + BL, b - BL, BL,     rot,    pi  );   # bottomLeft
              arc(ctx, l + TL, t + TL, TL,     pi,     -rot);      # topLeft
            close_path(ctx);
  else
      rectangle(ctx, shape.left, shape.top, shape.wide, shape.tall )
  end
  return borderWidth
end
# ======================================================================================
"""
## setborderPath(ctx::CairoContext, shape::NQBox)

...

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
function setborderPath(ctx::CairoContext, shape::NQBox)

  # TODO: see if curveTo() will work to simplify this.
  borderWidth = max(shape.border.left,shape.border.top,shape.border.right,shape.border.bottom)
  line = (borderWidth/2)
  t = shape.top - (line - shape.border.top)
  l = shape.left - (line - shape.border.left)
  r = shape.right - (shape.border.right - line)
  b = shape.bottom - (shape.border.bottom - line)

    if !isnull(shape.border.radius) #(TR + BR + BL + TL) > 0
      radius = get(shape.border.radius,[0,0,0,0])
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
    else
        rectangle(ctx, l, t, r, b )
    end
end
function setborderPath(ctx::CairoContext, shape::NQCircle)
        move_to(ctx, shape.left + shape.radius, shape.top)
        arc(ctx, shape.left, shape.top, shape.radius, 0, 2*pi);
end





# ======================================================================================
# Draw text.
"""
## DrawText(ctx, row, node, clipPath)

Draw text.

[Source](https://github.com/TravisA9/NaquadahBrowser/blob/39c41cbb1ac28fe94876fe01beaa6e046c8b63d3/src/Graphics/GraphDraw.jl#L54)
"""
# ======================================================================================
# -extents[4] is the top of the text
# ======================================================================================
function DrawText(ctx::CairoContext, row::Row, node::TextLine, clipPath)
    MyText = node.reference.shape
    left = node.left
    set_antialias(ctx,6)
    slant  = fontSlant(MyText)
    weight = fontWeight(MyText)
    select_font_face(ctx, MyText.family, slant, weight);
    set_font_size(ctx, MyText.size);

    if MyText.flags[TextPath] == false
          move_to(ctx, node.left, node.top + (MyText.size*1.14)); #  + MyText.size
          setcolor(ctx, MyText.color...)
          show_text(ctx, node.text);

    else  # shaddow
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

          move_to(ctx, node.left, node.top + MyText.size);
          text_path(ctx, node.text);
          setcolor(ctx, MyText.fill...) # fill color
          fill_preserve(ctx);
          setcolor(ctx, MyText.color...) # outline color
          set_line_width(ctx, MyText.lineWidth ); # 2.56 MyText.lineWidth
          stroke(ctx);
    end


end
