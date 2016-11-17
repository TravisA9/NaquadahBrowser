#======================================================================================#
# HasAlpha()
# DrawNode()
#   VariednBorderdBox()
#   EvenBorderdBox()
#   NoBorderdBox()
#   RoudedBox()
#   drawText()
#======================================================================================#
# setcolor( cr, r, g, b, a) = set_source_rgba(cr, r, g, b, a);
# setcolor( cr, r, g, b) = set_source_rgb(cr, r, g, b);

# ======================================================================================
# Draw a node
# CALLED FROM: DrawPage.jl ---> drawAllElements()
# http://zetcode.com/gfx/cairo/
# ======================================================================================
function DrawNode(cr::CairoContext,document::Page,node::MyElement)

    set_antialias(cr,4)
    if node.flags[IsBox] == true
        if node.flags[HasBorder] == true # !isnull(node.border)
            # TestFillStyle
        	border = get(node.border)
         				if !isnull(border.radius)
         				 	RoudedBox(cr,node,border)

         				elseif node.flags[BordersSame] == true
                            # (  border.left == border.top && border.left == border.bottom && border.left == border.right)
                            EvenBorderdBox(cr,node,border)
        				else
                        VariednBorderdBox(cr,node,border)
         				end
        else
            NoBorderdBox(cr,node)
        end
    end
    # TODO: Consolidate and remove sample_x() functions
    # The following functions are in: DrawShapes.jl
    if node.flags[TestFillStyle] == true
        sample_fill_style(cr, node)
    end
    if node.flags[IsCurve] == true
        sample_Curve(cr,node)
    end
    if node.flags[ClipCircle] == true
        sample_ClipCircle(cr,node)
    end
    if node.flags[IsGradient] == true
        sample_Gradient(cr,node)
    end
    if node.flags[IsText] == true
        sample_Text(cr,node)
    end
    if node.flags[IsPath] == true
        sample_Path(cr,node)
    end

    if node.flags[IsLine] == true
          sample_line(cr, node)
    end

    if node.flags[IsArc] == true
          sample_arc(cr, node)
    end

    if node.flags[IsCircle] == true
          DrawCircle(cr, node)
    end
    if node.flags[OverflowClip] == true
          sample_clip(cr, node)
    end

    if node.flags[HasVscroll] == true
          VerticleScrollbar(cr, node)
    end
#=======================================================================#
			if !isnull(node.text) # haskey(E, "text") #E[">"] == "p"
				drawText(cr,document,node)
			end


end

#
#======================================================================================#
# Draw node text
# Cairo tutorial: https://www.cairographics.org/tutorial/
# CALLED FROM: DrawNode()
#======================================================================================#
function drawText(cr::CairoContext,document::Page,node::MyElement)
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
      select_font_face(cr, text.family, slant, weight);
        set_font_size(cr, text.size);
        # set text color to draw
        textcolor = text.color
        setcolor( cr, textcolor...)


                set_antialias(cr,0)
               # extents = text_extents(cr,E["text"]);
				x = node.content.left
				y = node.content.top + text.size #extents[4]
				move_to(cr, x, y);

#text.align = "center"
			    # select_font_face(cr, "Sans", Cairo.FONT_SLANT_OBLIQUE, Cairo.FONT_WEIGHT_BOLD);
	            # set_font_size(cr, 16.0);
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

				        	#width = textwidth(cr,w) + spacer
				        	width = text_extents(cr,w );
				            # print(width[3], ", ")
				        	# text_extents(cr,E["text"]);
						    move_to(cr, left, y);
							show_text(cr,w);
				            left = left + width[3] + spacer
						end

							y = y + ( text.size * text.lineHeight) # WAS: extents[4]
							if y >=  node.box.top + node.area.height
                                # print("drop out")
								break
							end

				else
						    #extents = text_extents(cr,line.text );
			            	# print(extents)
			            	if text.align == "left"
				            	left = x
				            elseif text.align == "right"
				            	left = x + line.space
				            elseif text.align == "center"
				            	left = x + (line.space/2)
			            	end




Highlight(cr::CairoContext,document::Page,text,line,left,y)







			            	# print(extents,": ")
						    move_to(cr, left, y);
							show_text(cr,line.text);
              stroke(cr);

              # let's see if we can underline the text
              if node.flags[IsUnderlined] == true
                set_antialias(cr,0)
                set_line_width(cr, 1);
                extents = text_extents(cr, line.text );
                move_to(cr, left, y+2);
                rel_line_to(cr, extents[3], 0);
                stroke(cr);
              end



							y = y + ( text.size * text.lineHeight) # WAS: extents[4]
							if y >= node.box.top + node.area.height - 3
								break
							end
				end #end of not-justify
		end
set_antialias(cr,1)
stroke(cr);
end
#======================================================================================#
# Highlight selected text
# CALLED FROM: DrawText()
#======================================================================================#
function Highlight(cr::CairoContext,document::Page,text,line,left,y)


  # If selected draw background
        if document.mousedown.x > 0 && document.mousedown.y > 0
            if document.mousedown.y < document.mouseup.y
            min = document.mousedown # min/max are points
            max = document.mouseup
          else
            min = document.mouseup # min/max are points
            max = document.mousedown
          end

          extents = text_extents(cr, line.text );
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
            setcolor( cr, 0.273, 0.507, 0.703)
              # set_source_rgb(cr, 0.273, 0.507, 0.703); #steelblue aproximation
              rectangle(cr,  startX,  top,   endX,  height); # background
              fill(cr);
          end
            end
            # set text color to draw
            textcolor = text.color
            setcolor( cr, textcolor...)
    end



end
#======================================================================================#
# Draw an area with Borders of varying same widths
# CALLED FROM: DrawNode()
#======================================================================================#
function VariednBorderdBox(cr::CairoContext,node::MyElement,border)
                setcolor( cr, border.color...)
                    left   = node.box.left   - (border.left*.5)
                    right  = node.box.width  + node.box.left + (border.right*.5)
                    bottom = node.box.height + node.box.top + (border.bottom*.5)
                    top    = node.box.top    - (border.top*.5)
                    set_line_cap(cr, Cairo.CAIRO_LINE_CAP_BUTT); # default

                    set_line_width(cr, border.top);
                    move_to(cr, left- (border.left*.5), top);
                    line_to(cr, right+ (border.right*.5), top);
                    stroke(cr);

                    set_line_width(cr, border.right);
                    move_to(cr, right, top);
                    line_to(cr, right, bottom);
                    stroke(cr);

                    set_line_width(cr, border.bottom);
                    move_to(cr, right+ (border.right*.5), bottom);
                    line_to(cr, left- (border.left*.5), bottom);
                    stroke(cr);

                    set_line_width(cr, border.left);
                    move_to(cr, left, bottom);
                    line_to(cr, left, top);
                    stroke(cr);

                    rectangle(cr,
                        node.box.left,  node.box.top,
                        node.box.width, node.box.height)

                                        setcolor( cr, node.color...)
                    fill(cr)

end
#======================================================================================#
# Draw a area with Borders of the same width
# CALLED FROM: DrawNode()
#======================================================================================#
function EvenBorderdBox(cr::CairoContext,node::MyElement,border)
                    rectangle(cr,
                                node.box.left   - (border.left*.5), node.box.top    - (border.top*.5),
                                node.box.width  + (border.right), node.box.height + (border.bottom)     )
                    setcolor( cr, node.color...)
                    fill_preserve(cr);
                    set_line_width(cr, border.left);

                    setcolor( cr, border.color...)
                    stroke(cr);
end
#======================================================================================#
# Draw a area with no borders
# CALLED FROM: DrawNode()
#======================================================================================#
function NoBorderdBox(cr::CairoContext,node::MyElement)

            rectangle(cr,
                node.box.left + node.hOffset,  node.box.top + node.vOffset,
                node.box.width + node.hOffset, node.box.height + node.vOffset)
                setcolor( cr, node.color...)
                 fill(cr)
end
#======================================================================================#
# Draw a area with rounded corners
# CALLED FROM: DrawNode()
#======================================================================================#
function RoudedBox(cr::CairoContext,node::MyElement,border)
	radius = get(border.radius)
                    x = node.box.left   # minus 1 while the sides are being
                    y = node.box.top     # expanded by antialias-ing
                    h = node.box.height
                    w = node.box.width

                    borderWidth = border.top[1]
                    # w += border.width
                    # h += border.height

                    TR = radius[1]
                    BR = radius[2]
                    BL = radius[3]
                    TL = radius[4]
		degrees = pi / 180.0;
rotOne = -90 * degrees
rotTwo = 90 * degrees
rotThree = 180 * degrees
rotFour = 270 * degrees

	set_antialias(cr,6)

		new_sub_path(cr);
		arc(cr, x + w - TR, y + TR, TR,     rotOne,    0);    # topRight
		arc(cr, x + w - BR, y + h - BR, BR, 0,         rotTwo); # bottomRight
		arc(cr, x + BL, y + h - BL, BL,     rotTwo,    rotThree);   # bottomLeft
		arc(cr, x + TL, y + TL, TL,         rotThree,  rotFour);      # topLeft
		close_path(cr);

    if length(node.color) > 0
			                    setcolor( cr, node.color...)
      # fill(cr);
		fill_preserve(cr);
		end
		# Borders...
		if length(border.color) > 0

    # x = node.box.left  - border.left # minus 1 while the sides are being
    # y = node.box.top   - border.top # expanded by antialias-ing
    # h = node.box.height + border.height
    # w = node.box.width  + border.width

      # # new_sub_path(cr);
  		# # arc(cr, x + w - TR, y + TR, TR,     rotOne,    0);    # topRight
  		# # arc(cr, x + w - BR, y + h - BR, BR, 0,         rotTwo); # bottomRight
  		# # arc(cr, x + BL, y + h - BL, BL,     rotTwo,    rotThree);   # bottomLeft
  		# # arc(cr, x + TL, y + TL, TL,         rotThree,  rotFour);      # topLeft
  		# # close_path(cr);

      setcolor( cr, border.color...)
			set_line_width(cr, borderWidth);
			stroke(cr);
			set_antialias(cr,1)
		end
end
