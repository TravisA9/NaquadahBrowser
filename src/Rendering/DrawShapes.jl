#======================================================================================#
# TODO: Make one universal function integrating all drawing operations as a DrawPath(node.p).
#       Modify the Shape Type in a way that is compatible with the DrawPath(node.p).
#       This should serve to consolidate and simplify all/most drawing operations.
#======================================================================================#
# xmin left   ymin top   width width   height height box area
## header to provide surface and context
# # using Cairo
# # c = CairoRGBSurface(256,256);
# # cr = CairoContext(c);




#======================================================================================#
#
# CALLED FROM:
#======================================================================================#
function HorizontalScrollbar(cr, node)


end
#======================================================================================#
#
# CALLED FROM:
#======================================================================================#
function VerticleScrollbar(cr, node)
  l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height

  set_source_rgb(cr, 0.5, 0.5, 0.5);
  rectangle(cr,r,t,12,b); # background WAS: 0,0,256,256
  fill(cr);

end
#======================================================================================#
function VerticleScrollbarTrack(cr, node, offset, )
  l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height
  space = b - 12
  height = node.contentheight - space
  set_source_rgb(cr, 0.3, 0.3, 0.3);
  rectangle(cr,r,offset,10,height); # background WAS: 0,0,256,256
  fill(cr);

end
#======================================================================================#
#
# CALLED FROM:
#======================================================================================#
function sample_clip(cr::CairoContext,node::MyElement)
    l,t,r,b = node.content.left, node.content.top, node.content.width, node.content.height
    r = (r-l)/2
    set_antialias(cr,4)
    arc(cr, l+128.0, t+128.0, r, 0, 2*pi);
    clip(cr);
    new_path(cr); # path not consumed by clip
     path = PATH * "Tree.png"
     image = read_from_png(path); # mulberry.png

     w = image.width;
     h = image.height;

     scale(cr, 256.0/w, 256.0/h);

     set_source_surface(cr, image, l, t);
     paint(cr);

     reset_transform(cr)
     reset_clip(cr)
end
#======================================================================================#
#
# CALLED FROM:
#======================================================================================#

# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function sample_fill_style(cr::CairoContext,node::MyElement)
    l,t,r,b = node.content.left, node.content.top, node.content.width, node.content.height
         # set_source_rgb(cr,0.8,0.8,0.8);    # light gray
         #  HasAlpha(context, node.color)
                if length(node.color) > 3
                     set_source_rgba(cr, node.color[1], node.color[2], node.color[3], node.color[4]);
                else
                     set_source_rgb(cr, node.color[1], node.color[2], node.color[3]);
                end

         rectangle(cr,l,t,r,b); # background WAS: 0,0,256,256
         fill(cr);

        #   ## original example, following here
        set_line_width(cr, 3);
         set_antialias(cr,4)
         rectangle(cr, l+12, t+12, 232, 70);
         new_sub_path(cr); arc(cr, l+64, t+64, 40, 0, 2*pi);
         new_sub_path(cr); arc_negative(cr, l+192,t+64, 40, 0, -2*pi);

         set_fill_type(cr, Cairo.CAIRO_FILL_RULE_EVEN_ODD); # should be set_fill_rule
         set_source_rgb(cr, 0, 0.7, 0); fill_preserve(cr);
         set_source_rgb(cr, 0, 0, 0); stroke(cr);

        translate(cr, 0, 128);
         rectangle(cr, l+12, t+12, 232,70);
         new_sub_path(cr); arc(cr, l+64, t+64, 40, 0, 2*pi);
         new_sub_path(cr); arc_negative(cr, l+192, t+64, 40, 0, -2*pi);

         set_fill_type(cr, Cairo.CAIRO_FILL_RULE_WINDING);
         set_source_rgb(cr, 0, 0, 0.9); fill_preserve(cr);
         set_source_rgb(cr, 0, 0, 0); stroke(cr);
         translate(cr, 0, -128);
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function DrawCircle(cr::CairoContext, node::MyElement)
    border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
  # print("DrawCircle \n",border.color)
    l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height
    wide = node.content.width
    radius = node.shape.radius
                if length(node.color) > 3
                     set_source_rgba(cr, node.color[1], node.color[2], node.color[3], node.color[4]);
                else
                     set_source_rgb(cr, node.color[1], node.color[2], node.color[3]);
                end

        set_antialias(cr,6)
        # set_fill_type(cr, Cairo.CAIRO_FILL_RULE_EVEN_ODD);
          # set_source_rgb(cr, 0, 0.7, 0); #
        move_to(cr, l+wide, t+radius)
        arc(cr, l+radius, t+radius, radius, 0, 2*pi);
        fill(cr);

                 if length(border.color) > 3
                     set_source_rgba(cr, border.color[1], border.color[2], border.color[3], border.color[4]);
                 else
                     set_source_rgb(cr, border.color[1], border.color[2], border.color[3]);
                 end
        arc(cr, l+radius, t+radius, radius, 0, 2*pi);
        set_line_width(cr, border.width);
        stroke(cr);
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function sample_arc(cr::CairoContext, node::MyElement)
          border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
    l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height
     xc = node.box.left + node.shape.center[1]
     yc = node.box.top  + node.shape.center[2]

     node.shape.angle
        set_antialias(cr,6)
        if length(border.color) > 3
                set_source_rgba(cr, border.color[1], border.color[2], border.color[3], border.color[4]);
        else
                set_source_rgb(cr, border.color[1], border.color[2], border.color[3]);
        end


        set_line_width(cr, border.width);
        arc_negative(cr, xc, yc, node.shape.radius, node.shape.angle[1] * (pi/180.0), node.shape.angle[2] * (pi/180.0));
        stroke(cr);
end

# ======================================================================================
# sample_line
# CALLED FROM:
# ======================================================================================
function sample_line(cr::CairoContext, node::MyElement)
          border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
    l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height
        set_antialias(cr,4)
        if length(border.color) > 3
                set_source_rgba(cr, border.color[1], border.color[2], border.color[3], border.color[4]);
        else
                set_source_rgb(cr, border.color[1], border.color[2], border.color[3]);
        end


        set_line_width(cr, border.width);
          move_to(cr, l+ node.shape.coords[1], t+ node.shape.coords[2])

        if length(node.shape.coords) == 4
          line_to(cr, l+ node.shape.coords[3], t+ node.shape.coords[4]);
        else
          theta = node.shape.angle  * (pi/180.0);  # angles are specified

        line_to(cr,
                    l+ node.shape.coords[1] + (node.shape.length * cos( theta )),
                    t+ node.shape.coords[2] + (node.shape.length * sin( theta )) );

        end
        stroke(cr);
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function sample_Curve(cr::CairoContext,node::MyElement)
    border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
    l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height

                if length(node.color) > 3
                     set_source_rgba(cr, node.color[1], node.color[2], node.color[3], node.color[4]);
                else
                     set_source_rgb(cr, node.color[1], node.color[2], node.color[3]);
                end
        set_antialias(cr,6)
        set_line_width(cr, 1);
        rectangle(cr,l,t,r,b); # background
        stroke(cr);

        x=15+l;  y=28.0+t;
        x1=-30.4+l; y1=200.4+t;
        x2=153.6+l; y2=25.6+t;
        x3=200.4+l; y3=128.0+t;

        move_to(cr, x, y);
        curve_to(cr, x1, y1, x2, y2, x3, y3);
        # curve_to(cr, x3, y3, x4, y4, x5, y5);

        if length(border.color) > 3
                set_source_rgba(cr, border.color[1], border.color[2], border.color[3], border.color[4]);
        else
                set_source_rgb(cr, border.color[1], border.color[2], border.color[3]);
        end
        set_line_width(cr, border.width);
        stroke(cr);

        set_source_rgba(cr, 1, 0.2, 0.2, 0.6);
        set_line_width(cr, 1.0);
        move_to(cr,x,y);   line_to(cr,x1,y1);
        move_to(cr,x2,y2); line_to(cr,x3,y3);
        stroke(cr);
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function sample_ClipCircle(cr::CairoContext,node::MyElement)
# print("sample_ClipCircle \n")
    # border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
    l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height
    wide = node.content.width
    radius = wide/2
        # Cairo.CAIRO_FILL_RULE_WINDING
        # Cairo.CAIRO_FILL_RULE_EVEN_ODD
        # set_operator(cr,Cairo.OPERATOR_DEST_OVER)

        path = PATH * "Mountains.png"


        image = read_from_png(path); # "D:/Browser/data/mulberry.png"
        w = image.width;
        h = image.height;
        imageScale = w/wide

        set_antialias(cr,6)
        set_source_rgb(cr, 0, 0, 0);
        set_fill_type(cr, Cairo.CAIRO_FILL_RULE_EVEN_ODD);
          # set_source_rgb(cr, 0, 0.7, 0); #
          move_to(cr, l+wide, t+radius)
         arc(cr, l+radius, t+radius, radius, 0, 2*pi);
         # rectangle(cr,l,t,r,b);
         # print("        l: $(l), w: $(w), wide: $(wide), wide/w: $(wide/w), w/wide: $(w/wide)\n")
         # print("scaled  l: $(l/imageScale), w: $(w/imageScale), wide: $(wide/imageScale), wide/w: $(wide/w), w/wide: $(w/wide)\n")
 # clip(cr);
         # rectangle(cr,l,t,r,b); # background

          scale(cr, wide/w, wide/w);
          xoffs = (l*(w/wide))-(l)
          yoffs = (t*(w/wide))-(t)
         translate(cr,  xoffs,  yoffs); # 1029 >= w*2   l + l*(wide/w) + wide*(wide/w) =1014

        set_source_surface(cr, image, l, t);
         fill(cr);
        reset_transform(cr)


end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function  sample_Gradient(cr::CairoContext,node::MyElement)
    border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
    l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height
    center = node.content.width/2
    offsetX = 25
    offsetY = 25
                if length(node.color) > 3
                     set_source_rgba(cr, node.color[1], node.color[2], node.color[3], node.color[4]);
                else
                     set_source_rgb(cr, node.color[1], node.color[2], node.color[3]);
                end
        set_antialias(cr,6)
        set_line_width(cr, 1);
        rectangle(cr,l,t,r,b); # background
        stroke(cr);


        ## original example, following here

pat = pattern_create_linear(l+0.0, t+180.0,  l+180.0, t+0.0);
        # pat = pattern_create_linear(t, t, t, b);
        pattern_add_color_stop_rgba(pat, 1, 0, 0, 0, 1);
        pattern_add_color_stop_rgba(pat, 0, 1, 1, 1, 1);
        rectangle(cr, l, t, r, b);
        set_source(cr, pat);
        fill(cr);
        destroy(pat);

        pat = pattern_create_radial(l+center, t+center, 1.6,
                                    l+center+offsetX, t+center+offsetY, 128.0);
        pattern_add_color_stop_rgba(pat, 0, 0, 1, 0, 1);
        pattern_add_color_stop_rgba(pat, 1, 0, 0, 0, 1);
        set_source(cr, pat);
        arc(cr, l+center, t+center, center, 0, 2 * pi);
        fill(cr);
        destroy(pat);
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function  sample_Text(cr::CairoContext,node::MyElement)
    border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
    l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height
                if length(node.color) > 3
                     set_source_rgba(cr, node.color[1], node.color[2], node.color[3], node.color[4]);
                else
                     set_source_rgb(cr, node.color[1], node.color[2], node.color[3]);
                end
        set_antialias(cr,6)
        set_line_width(cr, 1);
        rectangle(cr,l,t,r,b); # background
        stroke(cr);


        select_font_face(cr, "Sans", Cairo.FONT_SLANT_NORMAL,
                         Cairo.FONT_WEIGHT_BOLD);
        set_font_size(cr, 90.0);

        move_to(cr, l+10.0, t+135.0);
        show_text(cr, "Hello");

        move_to(cr, l+70.0, t+165.0);
        text_path(cr, "Browser");
        set_source_rgb(cr, 0.5, 0.5, 1);
        fill_preserve(cr);
        set_source_rgb(cr, 0, 0, 0);
        set_line_width(cr, 2.56);
        stroke(cr);

        # draw helping lines
        set_source_rgba(cr, 1, 0.2, 0.2, 0.6);
        arc(cr, l+10.0, t+135.0, 5.12, 0, 2*pi);
        close_path(cr);
        arc(cr, l+70.0, t+165.0, 5.12, 0, 2*pi);
        fill(cr);
end
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
type PathStep
    points::Float32
    drawMode::Int8
end

function  ParsePath(path)
    data = []
# split path into seperate drawing steps
          group = split(path, r"(?=[MLHVCSQTAZmlhvcsqtaz])")
    # Parse steps
    for g in group

            seperate = split(g, r"(?<=[MLHVCSQTAZmlhvcsqtaz])") # on second thought, split might work here
            seperate[1] = lowercase(seperate[1])

        if seperate[1] == "m";    drawMode =  1;    end
        if seperate[1] == "l";    drawMode =  2;    end
        if seperate[1] == "h";    drawMode =  3;    end
        if seperate[1] == "v";    drawMode =  4;    end
        if seperate[1] == "c";    drawMode =  5;    end
        if seperate[1] == "s";    drawMode =  6;    end
        if seperate[1] == "q";    drawMode =  7;    end
        if seperate[1] == "t";    drawMode =  8;    end
        if seperate[1] == "a";    drawMode =  9;    end
        if seperate[1] == "z";    drawMode = 10;    end
        numbers = []
            if length(seperate) > 1
                println("seperate")
                nums = split(seperate[2]," ")
                println("nums ")
                for n in nums
                    println("String ",n, endof(n) > 0)
                    if endof(n) > 0
                        println("push! ",parse(Float32, n))
                        push!(numbers, parse(Float32, n))
                    end
                end
                println("End of nums loop.")
            end
        println("numbers: ",numbers,"drawMode: ",drawMode)
        step = PathStep(numbers,drawMode)
        println("push! ",step)
        push!(data,step)
    end
    return data
end
#  path = "M150 0 L75 20.0 L225 200 Z"   ParsePath(path)
#  group = split(path, r"(?=[MLHVCSQTAZmlhvcsqtaz])")
# > "M150 0 "
# > "L75 20.0 "
# > "L225 200 "
# > "Z"
#  seperate = split(group[2], r"(?<=[MLHVCSQTAZmlhvcsqtaz])")
#
#
#
#
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function  DrawPath(cr::CairoContext,node::MyElement)
    border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
    l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height
    center = node.content.width/2
    halfBorder = border.width
                if length(node.color) > 3
                     set_source_rgba(cr, node.color[1], node.color[2], node.color[3], node.color[4]);
                else
                     set_source_rgb(cr, node.color[1], node.color[2], node.color[3]);
                end
        set_antialias(cr,6)
        set_line_width(cr, 1);
        rectangle(cr,l,t,r,b); # background
        stroke(cr);

        dashes = [50.0,  # ink
                  10.0,  # skip
                  10.0,  # ink
                  10.0   # skip
                  ];
        #ndash = length(dashes); not implemented as ndash on set_dash
        offset = -25.0;

        set_dash(cr, dashes, offset);
        set_line_width(cr, border.width);

        move_to(cr, l+center, t);
        line_to(cr, l+r-halfBorder, t+b-(halfBorder*.5));
        rel_line_to(cr, -102.4, 0.0);
        curve_to(cr, l, t+b-(halfBorder*.5), l, t+center, l+center, t+center);

        stroke(cr);
                set_dash(cr, [1.0,0.0], 1);

end

# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function  sample_Path(cr::CairoContext,node::MyElement)
    border = get(node.border, Border(0,0,0,0,0,0,"None",[],[]))
    l,t,r,b = node.box.left, node.box.top, node.box.width, node.box.height
    center = node.content.width/2
    halfBorder = border.width
                if length(node.color) > 3
                     set_source_rgba(cr, node.color[1], node.color[2], node.color[3], node.color[4]);
                else
                     set_source_rgb(cr, node.color[1], node.color[2], node.color[3]);
                end
        set_antialias(cr,6)
        set_line_width(cr, 1);
        rectangle(cr,l,t,r,b); # background
        stroke(cr);

        dashes = [50.0,  # ink
                  10.0,  # skip
                  10.0,  # ink
                  10.0   # skip
                  ];
        #ndash = length(dashes); not implemented as ndash on set_dash# content
        offset = -25.0;

        set_dash(cr, dashes, offset);
        set_line_width(cr, border.width);

        move_to(cr, l+center, t);
        line_to(cr, l+r-halfBorder, t+b-(halfBorder*.5));
        rel_line_to(cr, -102.4, 0.0);
        curve_to(cr, l, t+b-(halfBorder*.5), l, t+center, l+center, t+center);

        stroke(cr);
                set_dash(cr, [1.0,0.0], 1);

end

# IsBox, IsArc, IsCircle, IsLine, IsPath, TestFillStyle,
# IsCurve, ClipCircle, IsGradient, IsText,
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
