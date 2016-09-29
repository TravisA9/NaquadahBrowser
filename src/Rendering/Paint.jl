#======================================================================================#
# HasAlpha()
# DrawNode()
#   VariednBorderdBox()
#   EvenBorderdBox()
#   NoBorderdBox()
#   RoudedBox()
#   drawText()
#======================================================================================#

# xmin left   ymin top   width width   height height box area
#======================================================================================#
# set color with or without alpha
# This should be a macro
# CALLED FROM:
#======================================================================================#
#macro
function HasAlpha(context,color)
                 if length(color) > 3
                     set_source_rgba(context, color[1], color[2], color[3], color[4]);
                 elseif length(color) == 3
                     set_source_rgb(context, color[1], color[2], color[3]);
                 else # No color set...
                   # Draw in red to alert you of a problem
                   set_source_rgb(context, 1.0, 0.0, 0.0);
                 end
end
# ======================================================================================
# Draw a node
# CALLED FROM: DrawPage.jl ---> drawAllElements()
# http://zetcode.com/gfx/cairo/
# ======================================================================================
function DrawNode(context,document,node)

    set_antialias(context,4)
    if node.flags[IsBox] == true
        if node.flags[HasBorder] == true # !isnull(node.border)
            # TestFillStyle
        	border = get(node.border)
         				if !isnull(border.radius)
         				 	RoudedBox(context,node,border)

         				elseif node.flags[BordersSame] == true
                            # (  border.left == border.top && border.left == border.bottom && border.left == border.right)
                            EvenBorderdBox(context,node,border)
        				else
                        VariednBorderdBox(context,node,border)
         				end
        else
            NoBorderdBox(context,node)
        end
    end
    # TODO: Consolidate and remove sample_x() functions
    # The following functions are in: DrawShapes.jl
    if node.flags[TestFillStyle] == true
        sample_fill_style(context, node)
    end
    if node.flags[IsCurve] == true
        sample_Curve(context,node)
    end
    if node.flags[ClipCircle] == true
        sample_ClipCircle(context,node)
    end
    if node.flags[IsGradient] == true
        sample_Gradient(context,node)
    end
    if node.flags[IsText] == true
        sample_Text(context,node)
    end
    if node.flags[IsPath] == true
        sample_Path(context,node)
    end

    if node.flags[IsLine] == true
          sample_line(context, node)
    end

    if node.flags[IsArc] == true
          sample_arc(context, node)
    end

    if node.flags[IsCircle] == true
          DrawCircle(context, node)
    end
    if node.flags[OverflowClip] == true
          sample_clip(context, node)
    end

#=======================================================================#
			if !isnull(node.text) # haskey(E, "text") #E[">"] == "p"
				drawText(context,document,node)
			end


end

#
#======================================================================================#
# Draw node text
# Cairo tutorial: https://www.cairographics.org/tutorial/
# CALLED FROM: DrawNode()
#======================================================================================#
function drawText(context,document,node)
      #=---------------------------------=#
      # Text=  lines, top, left, color, size, style, weight
      #        lineHeight, align, family
      #=---------------------------------=#
      # TODO: perhaps these should be changes from strings to flags and values!


        text = get(node.text)
      if text.style == "italic"
      slant = Cairo.FONT_SLANT_ITALIC
      elseif text.style == "oblique"
      slant = Cairo.FONT_SLANT_OBLIQUE
      else
      slant = Cairo.FONT_SLANT_NORMAL
      end

      if text.weight == "normal"
              weight = Cairo.FONT_WEIGHT_NORMAL
          elseif text.weight == "bold"
              weight = Cairo.FONT_WEIGHT_BOLD
          end
      select_font_face(context, text.family, slant, weight);
        set_font_size(context, text.size);
        # set text color to draw
        textcolor = text.color
                if length(textcolor) > 3
                    set_source_rgba(context, textcolor[1], textcolor[2], textcolor[3], textcolor[4]);
                else
                    set_source_rgb(context, textcolor[1], textcolor[2], textcolor[3]);
                end








                set_antialias(context,0)
               # extents = text_extents(context,E["text"]);
				x = node.content.left
				y = node.content.top + text.size #extents[4]
				move_to(context, x, y);
			                       # HasAlpha(context, textcolor)
                    #  set_source_rgb(context, textcolor[1], textcolor[2], textcolor[3]);
#text.align = "center"
			    # select_font_face(context, "Sans", Cairo.FONT_SLANT_OBLIQUE, Cairo.FONT_WEIGHT_BOLD);
	            # set_font_size(context, 16.0);
		for line in text.lines # lines
                # justify Still not working very well
				if text.align == "justify"
				            	# we'll need spacers to insert between words
				            	#      We should also make a spacer-length to line-length
				            	# contingency to keep the last line pretty!
				            	# spacers = line.space/line.words
				            words = split(line.text)
				            left = x
				            if line.words > 2
				            	spacer = (line.space/(line.words-1))
				            elseif line.words == 2
				            	spacer = line.space
				            elseif line.words == 1
				            	spacer = line.space/2
				            end
				        #for word in words
				        for i in eachindex(words) #

				        	#TODO: put a condition on the last word here
				        	if i == length(words)
				        		w = words[i]
				        	else
				        		w = words[i] * " "
				        		# print(w)
				        	end

				        	#width = textwidth(context,w) + spacer
				        	width = text_extents(context,w );
				            # print(width[3], ", ")
				        	# text_extents(context,E["text"]);
						    move_to(context, left, y);
							show_text(context,w);
				            left = left + width[3] + spacer
						end

							y = y + ( text.size * text.lineHeight) # WAS: extents[4]
							if y >=  node.box.top + node.area.height
                                # print("drop out")
								break
							end

				else
						    #extents = text_extents(context,line.text );
			            	# print(extents)
			            	if text.align == "left"
				            	left = x
				            elseif text.align == "right"
				            	left = x + line.space
				            elseif text.align == "center"
				            	left = x + (line.space/2)
			            	end




Highlight(context,document,text,line,left,y)







			            	# print(extents,": ")
						    move_to(context, left, y);
							show_text(context,line.text);
              stroke(context);

              # let's see if we can underline the text
              if node.flags[IsUnderlined] == true
                set_antialias(context,0)
                set_line_width(context, 1);
                extents = text_extents(context, line.text );
                move_to(context, left, y+2);
                rel_line_to(context, extents[3], 0);
                # rel_line_to(context, extents[3], 0);
                # rel_line_to(context, extents[1], -extents[2]);
                stroke(context);
              end



							y = y + ( text.size * text.lineHeight) # WAS: extents[4]
							if y >= node.box.top + node.area.height - 3
                                # print(" drop out: ",node.area.height, " ", y)
								break
							end
				end #end of not-justify
		end
set_antialias(context,1)
			    # show_text(context,E["text"]);  left
#reveal(widget) content
stroke(context);

	# print(text)

end
#======================================================================================#
# Highlight selected text
# CALLED FROM: DrawText()
#======================================================================================#
function Highlight(context,document,text,line,left,y)


  # If selected draw background
  # print("drag: $(document.mousedown.x), $(document.mousedown.y) ---to--> $(document.mouseup.x), $(document.mouseup.y)... ")
        if document.mousedown.x > 0 && document.mousedown.y > 0
          # if condition ? if_true : if_false
          # document.mousedown.y<document.mouseup.y   ?   minY = document.mousedown.y : minY = document.mouseup.y
          if document.mousedown.y < document.mouseup.y
            min = document.mousedown # min/max are points
            max = document.mouseup
          else
            min = document.mouseup # min/max are points
            max = document.mousedown
          end

          extents = text_extents(context, line.text );
          # WAS: lineHeight = extents[2]*text.lineHeight
          lineHeight = text.size*text.lineHeight
            offset =  (lineHeight - text.size)/2
            width  =  extents[3]
            top    =  y - offset + extents[2]
            height =  lineHeight + 1
            bottom =  top + height
            #text.size + offset + offset

           startX, endX = left, width # default
           # Is selected: this may be reworked to create fewer conditions or whatever...
    if bottom < max.y    &&    bottom > min.y    ||    top < max.y    &&      top > min.y  ||  max.y < bottom   &&     max.y > top      ||  min.y < bottom   &&    min.y > top

          # Middle selected lines:  This line is within but not on the bounds
          if bottom < max.y && top > min.y
            #min.x < left ? startX = left :
            startX = left
            endX = width

            # Portion of one line:
          elseif min.y > top     &&     min.y < bottom     &&     max.y > top     &&     max.y < bottom
            #startX = min.x
            min.x < left ? startX = left : startX = min.x
            endX = max.x-startX #-left

            # First selected line:
          elseif min.y > top  &&  min.y < bottom
            min.x < left ? startX = left : startX = min.x
            endX = width-(startX-left)

            # Last selected line:
          elseif max.y > top  &&  max.y < bottom

            endX = max.x-left

          end


          # this could be a shaddow DOM thing... where you can restyle it.
          if endX > 1
              set_source_rgb(context, 0.273, 0.507, 0.703); #steelblue aproximation
              rectangle(context,  startX,  top,   endX,  height); # background
              fill(context);
          end
            end
            # set text color to draw
            textcolor = text.color
                    if length(textcolor) > 3
                        set_source_rgba(context, textcolor[1], textcolor[2], textcolor[3], textcolor[4]);
                    else
                        set_source_rgb(context, textcolor[1], textcolor[2], textcolor[3]);
                    end

    end



end
#======================================================================================#
# Draw an area with Borders of varying same widths
# CALLED FROM: DrawNode()
#======================================================================================#
function VariednBorderdBox(context,node,border)
                                        # HasAlpha(context, border.color)
                      # set_source_rgb(context, border.color[1], border.color[2], border.color[3]);
                 if length(border.color) > 3
                     set_source_rgba(context, border.color[1], border.color[2], border.color[3], border.color[4]);
                 else
                     set_source_rgb(context, border.color[1], border.color[2], border.color[3]);
                 end
                    left   = node.box.left   - (border.left*.5)
                    right  = node.box.width  + node.box.left + (border.right*.5)
                    bottom = node.box.height + node.box.top + (border.bottom*.5)
                    top    = node.box.top    - (border.top*.5)
                    set_line_cap(context, Cairo.CAIRO_LINE_CAP_BUTT); # default

                    set_line_width(context, border.top);
                    move_to(context, left- (border.left*.5), top);
                    line_to(context, right+ (border.right*.5), top);
                    stroke(context);

                    set_line_width(context, border.right);
                    move_to(context, right, top);
                    line_to(context, right, bottom);
                    stroke(context);

                    set_line_width(context, border.bottom);
                    move_to(context, right+ (border.right*.5), bottom);
                    line_to(context, left- (border.left*.5), bottom);
                    stroke(context);

                    set_line_width(context, border.left);
                    move_to(context, left, bottom);
                    line_to(context, left, top);
                    stroke(context);

                    rectangle(context,
                        node.box.left,  node.box.top,
                        node.box.width, node.box.height)


                                        HasAlpha(context, node.color)
                    #  set_source_rgb(context, node.color[1], node.color[2], node.color[3])
                    fill(context)

end
#======================================================================================#
# Draw a area with Borders of the same width
# CALLED FROM: DrawNode()
#======================================================================================#
function EvenBorderdBox(context,node,border)
                    rectangle(context,
                                node.box.left   - (border.left*.5), node.box.top    - (border.top*.5),
                                node.box.width  + (border.right), node.box.height + (border.bottom)     )
                    HasAlpha(context, node.color)
                    #  set_source_rgb(context, node.color[1], node.color[2], node.color[3]);
                    fill_preserve(context);
                    set_line_width(context, border.left);

                    HasAlpha(context, border.color)
                    #  set_source_rgb(context, border.color[1], border.color[2], border.color[3]);
                    stroke(context);
end
#======================================================================================#
# Draw a area with no borders
# CALLED FROM: DrawNode()
#======================================================================================#
function NoBorderdBox(context,node)

            rectangle(context,
                node.box.left + node.hOffset,  node.box.top + node.vOffset,
                node.box.width + node.hOffset, node.box.height + node.vOffset)
                                    HasAlpha(context, node.color)
                    #  set_source_rgb(context, node.color[1], node.color[2], node.color[3])
                 fill(context)
end
#======================================================================================#
# Draw a area with rounded corners
# CALLED FROM: DrawNode()
#======================================================================================#
function RoudedBox(context,node,border)
	radius = get(border.radius)
                    x = node.box.left   - 1 # minus 1 while the sides are being
                    y = node.box.top    - 1 # expanded by antialias-ing
                    h = node.box.height - 1
                    w = node.box.width  - 1

                    borderWidth = border.top[1]

                    TR = radius[1]
                    BR = radius[2]
                    BL = radius[3]
                    TL = radius[4]


	set_antialias(context,6)
		degrees = pi / 180.0;
        w = w + borderWidth
        h = h + borderWidth
		new_sub_path(context);
		     #  arc(ctx,    event.x,   event.y,   5,   0,   2pi)
       # stroke(ctx)

		arc(context, x + w - TR, y + TR, TR, -90 * degrees, 0 * degrees);    # topRight
		arc(context, x + w - BR, y + h - BR, BR, 0 * degrees, 90 * degrees); # bottomRight
		arc(context, x + BL, y + h - BL, BL, 90 * degrees, 180 * degrees);   # bottomLeft
		arc(context, x + TL, y + TL, TL, 180 * degrees, 270 * degrees);      # topLeft
		close_path(context);
                    # HasAlpha(context, node.color)
                    #
        if length(node.color) > 0
			                    HasAlpha(context, node.color)
                    #  set_source_rgb(context, node.color[1], node.color[2], node.color[3]);
			fill_preserve(context);
		end
		# Borders...
		if length(border.color) > 0
	    	                    HasAlpha(context, border.color)
                    #  set_source_rgb(context, border.color[1], border.color[2], border.color[3]);
                 if length(border.color) > 3
                     set_source_rgba(context, border.color[1], border.color[2], border.color[3], border.color[4]);
                 else
                     set_source_rgb(context, border.color[1], border.color[2], border.color[3]);
                 end
			set_line_width(context, borderWidth);
			stroke(context);
			set_antialias(context,1)
		end
end
