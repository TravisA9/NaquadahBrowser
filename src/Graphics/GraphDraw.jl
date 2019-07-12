if Sys.islinux()
    global PATH = pwd() * "/src/SamplePages/BrowserImages/"
elseif is_windows() # Do something windows-y here
    global PATH = pwd() * "/src\\SamplePages\\BrowserImages\\"
end


using Cairo, Gtk, Gtk.ShortNames, Graphics

export  DrawViewport, DrawContent, DrawShape, setcolor, drawNode,
        lastClipParent, inheritColor, getClipContext,
        setClip, resetClip
# ======================================================================================
function setClip(ctx, from, saverestore = true)
    saverestore && save(ctx)
    clip(ctx)
end
# ======================================================================================
function resetClip(ctx, from, saverestore = true)
    reset_clip(ctx)
    saverestore && restore(ctx)
end
# ======================================================================================
# These should go somewhere else.
# ======================================================================================
function getClipContext(node)
    list = []
    while node.parent !== node
        if node.shape.flags[Clip]
            push!(list, node)
        end
        node = node.parent
    end
    return list
end
# ======================================================================================
function inheritColor(node)
    while !isdefined(node.shape, :color) || length(node.shape.color) < 3
         node = node.parent
    end
    return node.shape.color
end
# ======================================================================================
function inheritFont(node)
    while !isdefined(node, :font) #|| length(node.font)
         node = node.parent
    end
    return node.font
end
# ======================================================================================
# Accept color values with or without alpha
# ======================================================================================
setcolor( ctx::Cairo.CairoContext, r, g, b) = set_source_rgb(ctx, r, g, b);
setcolor( ctx::Cairo.CairoContext, r, g, b, a) = set_source_rgba(ctx, r, g, b, a);
# setcolor( ctx::Cairo.CairoContext, color) = set_source_rgba(ctx, color...);
# setcolor( ctx::Cairo.CairoContext, node::Element) = set_source_rgba(ctx, node.shape.color...);
# setcolor( ctx::Cairo.CairoContext, shape::Draw) = set_source_rgba(ctx, shape.color...);

# ======================================================================================
# First draw all page elements (not controls) that flow and then draw "fixed" elements
# ======================================================================================
function DrawViewport(ctx::Cairo.CairoContext, document::Page, node::Element)
          DrawContent(ctx, document, node)
          DrawContent(ctx, document, document.fixed)
end
function DrawViewport(ctx::Cairo.CairoContext, document::Page, node::Element, clipPath)
          DrawContent(ctx, document, node, clipPath)
          DrawContent(ctx, document, document.fixed, clipPath)
end
# ======================================================================================
# This takes a node and draws it along with all its children.
# ======================================================================================

# ======================================================================================
function DrawContent(ctx::Cairo.CairoContext, document::Page, node::Element, clipPath=nothing)
    Shape = node.shape

    if Shape.flags[Clip]
        clipPath = getBorderBox(Shape)
    end
    if clipPath !== nothing
        rectangle(ctx, clipPath... )
        setClip(ctx, "DrawContent", false)
    end
    DrawShape(ctx, node, Shape) #, clipPath

  for row in node.rows
      for child in row.nodes
          if row.top < (Shape.top + Shape.height) # && !node.shape.flags[DisplayNone]

              if isa(child.shape, TextLine)
                  DrawText(ctx, child) #, clipPath
              else
                  DrawContent(ctx, document, child, clipPath)     # Now draw children
              end

          end
      end
  end




      # Scroll bars.......... TODO: fix
      if Shape.flags[IsVScroll]
          VScroller(ctx, document, node, Shape)
      end
      if Shape.flags[Clip]
         resetClip(ctx, "DrawContent", false)
      end

end
# ======================================================================================
# ======================================================================================

#...............................................................................
function lastClipParent(node)
    while node.parent !== node
        if node.shape.flags[Clip]
            return node
        end
        node = node.parent
    end
    return node
end




# linpat = cairo_pattern_create_linear(0, 0, 1, 1);
# pattern_add_color_stop_rgb(linpat, 0, 0, 0.3, 0.8);
# pattern_add_color_stop_rgb(linpat, 1, 0, 0.8, 0.3);

# radpat = cairo_pattern_create_radial(0.5, 0.5, 0.25, 0.5, 0.5, 0.75);
# pattern_add_color_stop_rgba(radpat, 0, 0, 0, 0, 1);
# pattern_add_color_stop_rgba(radpat, 0.5, 0, 0, 0, 0);

# set_source(cr, linpat);
# mask(cr, radpat);


# ======================================================================================
# http://www.nongnu.org/guile-cairo/docs/html/Patterns.html
# Draw a circle.
# TODO: remove node from function
# ======================================================================================
function DrawShape(ctx::CairoContext, node::Element, shape::Draw) #, clipPath
    path = GetPath(shape)
    setPath(ctx, path)

  if shape.flags[HasImage]
      setClip(ctx, "DrawShape");
        DOM =  node.DOM
            if haskey(DOM, "image")
                imagePath = PATH * DOM["image"] # "Mountains.png"
            end

            BackgroundImage(ctx, path.wide, path.tall, shape.left, shape.top, imagePath)
    resetClip(ctx, "DrawShape")
  else
      setClip(ctx, "DrawShape");
      if shape.flags[LinearGrad]
          linearGrad(ctx, path, shape.gradient)
      elseif shape.flags[RadialGrad]
          radialGrad(ctx, path, shape.gradient)
      elseif isdefined(shape, :color) &&  length(shape.color) > 2
          setPath(ctx, path)
          setcolor(ctx, shape.color...)
          fill(ctx);
      end
      resetClip(ctx, "DrawShape")
  end


          if isdefined(path.border, :color) && length(path.border.color) > 2
              thickness = setClipPath(ctx, GetPath(shape))
              # setPath(ctx, path)
              # rectangle(ctx, getBorderOuter(shape)...)
              setClip(ctx, "DrawShape")
              setcolor( ctx, path.border.color...)
                # TODO: add clipping for the border path as well to clean up edges.
                        set_line_type(ctx, path.border.style)
                        set_line_width(ctx, thickness);
                        setborderPath(ctx, path)
                        stroke(ctx)
              resetClip(ctx, "DrawShape")
          end
end
# ======================================================================================
# Temporary shortcut: draw the virticle scroll bar
# ======================================================================================
function VScroller(ctx::CairoContext, document::Page, node::Element, shape::Draw)

    ctx = getgc(document.canvas)
    l,t,w,h = getBorderBox(shape)


        r, b = l+w-12, t+h-12

        setcolor(ctx, .3, .3, .3, .3)
        rectangle(ctx,r,t,12,h )
        fill(ctx);


        contentHeight = node.shape.height #- node.shape.top
         scrollHeight = node.scroll.contentHeight     # Height of the content
         scrollTop    = node.scroll.y      # Scrolled position of the content from the top
         #.............................................................
         scrollButHeight = contentHeight / (scrollHeight/contentHeight)
         y = -(scrollTop / (scrollHeight/contentHeight))
         #.............................................................
         #.............................................................
        setcolor(ctx, .4,.4,.4, 1)
        rectangle(ctx,r+1,t-y,10, scrollButHeight )
        fill(ctx);

end
# ======================================================================================
# Temporary shortcut: draw the virticle scroll bar
# ======================================================================================
#type
# ('m',1,2)
# ('m',1,2) M = moveto
# ('l',1,2) L = lineto                   H = horizontal lineto                 V = vertical lineto
# ('c',1,2) C = curveto                  S = smooth curveto
# ('q',1,2) Q = quadratic Bézier curve   T = smooth quadratic Bézier curveto
# ('a',1,2) A = elliptical Arc
# ('z',1,2) Z = closepath


    # close_path,
    # move_to, line_to, rel_line_to, rel_move_to,
    # arc, arc_negative,
    # curve_to, rel_curve_to,

function drawPath(ctx, path)
    startPoint = nothing
    for step in path
        if step[1] == 'm'
            startPoint = step[1]
            move_to(ctx, step[2], step[3])
        elseif step[1] == 'l'
            line_to(ctx, step[2], step[3])
        elseif step[1] == 'c'
            curve_to(ctx, )
        elseif step[1] == 'q'
            curve_to(ctx, )
        elseif step[1] == 'a'
            arc(ctx, )
        elseif step[1] == 'z'
            close_path(ctx, )
        end
    end
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



#-======================================================================================
# The advantage, I guess, is that there is an instance of the needed values.
# I suspect this needs rethinking...
#-======================================================================================
mutable struct NQCircle
    border::Border
    radius::Float64
    left::Float64
    top::Float64
    wide::Float64
    tall::Float64
    NQCircle() = new()
end
mutable struct NQBox
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
# Draw the background image at 100% width and height.
# ======================================================================================
function BackgroundImage(ctx::CairoContext, wide::Float64, tall::Float64, l::Float64, t::Float64, path)

     image = read_from_png(path);
     w = image.width;  # w = (image.width/2);
     h = image.height; # h = (image.height/2);
     scX, scY = wide/w, tall/h

     scale(ctx, scX, scY);
     translate(ctx,  l/scX -l, t/scY-t ); # 1029 >= w*2   l + l*(wide/w) + wide*(wide/w) =1014
     set_source_surface(ctx, image, l, t);
     paint(ctx);
     reset_transform(ctx)
end
# ======================================================================================
# Draw a linear gradient
# ======================================================================================
function linearGrad(ctx::CairoContext, path, gradient)
    pat = pattern_create_linear(path.left+0.0, path.top+180.0, path.left+180.0, path.top+0.0 );
    for i in 1:length(gradient)
            pattern_add_color_stop_rgba(pat, gradient[i] ...);
    end
    setPath(ctx, path)
    set_source(ctx, pat);
    fill(ctx);
    destroy(pat);
end
# ======================================================================================
# Draw a radial gradient.
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
# ======================================================================================
function GetPath(shape::NBox)
    b = NQBox()
    border  = get(shape.border,  Border(0,0,0,0,0,0, "solid",[],[0,0,0,0]))
    padding = get(shape.padding, BoxOutline(0,0,0,0,0,0))
    b.border, b.padding = border, padding

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
# Set path for
# ======================================================================================#
function setPath(ctx::CairoContext, shape::NQBox)
    if shape.border != nothing #!isnull(shape.border.radius) #(TR + BR + BL + TL) > 0
        radius = shape.border.radius
        TR,BR,BL,TL = radius
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

  if shape.border.radius != nothing # !isnull(shape.border.radius) #(TR + BR + BL + TL) > 0
      radius = shape.border.radius
      TR,BR,BL,TL = radius
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
function setborderPath(ctx::CairoContext, shape::NQBox)

  # TODO: see if curveTo() will work to simplify this.
  # b  = get(shape.border,  Border(0,0,0,0,0,0, "solid",[],[0,0,0,0]))
  borderWidth = max(shape.border.left,shape.border.top,shape.border.right,shape.border.bottom)
line = (borderWidth/2)
t = shape.top - (line - shape.border.top)
l = shape.left - (line - shape.border.left)
r = shape.right - (shape.border.right - line)
b = shape.bottom - (shape.border.bottom - line)

  # l,t,r,b = getBorderBox(shape)
  # r += l
  # b += t
# l,t,r,b = getContentBox(shape)
  # borderWidth = max(shape.border.left,shape.border.top,shape.border.right,shape.border.bottom)
  # borderHeight = max(shape.border.top,shape.border.right,shape.border.bottom)
  Xline = (shape.border.width/2)
  Yline = (shape.border.height/2)
  # t = shape.top - (Xline - shape.border.top)
  # l = shape.left - (Yline - shape.border.left)
  # r = ceil(shape.width - (shape.border.width - Xline))
  # b = ceil(shape.height - (shape.border.height - Yline))

    if shape.border.radius != nothing # !isnull(shape.border.radius) #(TR + BR + BL + TL) > 0
      TR,BR,BL,TL = shape.border.radius
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
function drawNode(ctx, document, node)

    clipPaths = getClipContext(node)

        for p in length(clipPaths):-1:1
            rectangle(ctx, getBorderBox(clipPaths[p].shape)... )
            setClip(ctx, "drawNode")
        end

                     DrawContent(ctx, document, node) # Now draw children

        for p in length(clipPaths):-1:2
            resetClip(ctx, "drawNode")
        end

end
