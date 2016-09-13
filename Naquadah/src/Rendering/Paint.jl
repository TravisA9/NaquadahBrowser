#======================================================================================#
# HasAlpha()
# DrawNode()
#   VariednBorderdBox()
#   EvenBorderdBox()
#   NoBorderdBox()
#   RoudedBox()
#   drawText()
#======================================================================================#


#======================================================================================#
# set color with or without alpha
# This should be a macro
# CALLED FROM: 
#======================================================================================#
#macro 
function HasAlpha(context,color)
                 if length(color) > 3
                     set_source_rgba(context, color[1], color[2], color[3], color[4]);                     
                 else
                     set_source_rgb(context, color[1], color[2], color[3]); 
                 end
end
# ======================================================================================
# Draw a node
# CALLED FROM: DrawPage.jl ---> drawAllElements()
# http://zetcode.com/gfx/cairo/
# ======================================================================================
function DrawNode(context,node)

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
# TODO: Seperate the calculation of text metrics and the drawing of text.
#       Move metrics calculation to DOM or Layout section.
			if !isnull(node.text) # haskey(E, "text") #E[">"] == "p"
        E = node.DOM
				drawText(context,node,E)
			end


end









#======================================================================================#
# Draw a box with Borders of varying same widths
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
                    left   = node.total.left   - (border.left*.5)
                    right  = node.total.right  + node.total.left + (border.right*.5)
                    bottom = node.total.bottom + node.total.top + (border.bottom*.5)
                    top    = node.total.top    - (border.top*.5)
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
                        node.total.left,  node.total.top, 
                        node.total.right, node.total.bottom)
 

                                        HasAlpha(context, node.color)  
                    #  set_source_rgb(context, node.color[1], node.color[2], node.color[3])
                    fill(context)

end
#======================================================================================#
# Draw a box with Borders of the same width
# CALLED FROM: DrawNode()
#======================================================================================#
function EvenBorderdBox(context,node,border) 
                    rectangle(context, 
                                node.total.left   - (border.left*.5), node.total.top    - (border.top*.5), 
                                node.total.right  + (border.right), node.total.bottom + (border.bottom)     )
                    HasAlpha(context, node.color)   
                    #  set_source_rgb(context, node.color[1], node.color[2], node.color[3]); 
                    fill_preserve(context);
                    set_line_width(context, border.left);                

                    HasAlpha(context, border.color) 
                    #  set_source_rgb(context, border.color[1], border.color[2], border.color[3]); 
                    stroke(context);  
end
#======================================================================================#
# Draw a box with no borders
# CALLED FROM: DrawNode()
#======================================================================================#
function NoBorderdBox(context,node) 
            rectangle(context, 
                node.total.left + node.hOffset,  node.total.top + node.vOffset, 
                node.total.right + node.hOffset, node.total.bottom + node.vOffset)
                                    HasAlpha(context, node.color)    
                    #  set_source_rgb(context, node.color[1], node.color[2], node.color[3])
                 fill(context) 
end
#======================================================================================#
# Draw a box with rounded corners
# CALLED FROM: DrawNode()
#======================================================================================#
function RoudedBox(context,node,border) 
	radius = get(border.radius)
                    x = node.total.left   - 1 # minus 1 while the sides are being 
                    y = node.total.top    - 1 # expanded by antialias-ing
                    h = node.total.bottom - 1
                    w = node.total.right  - 1

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



















#======================================================================================#
# calculate and draw text
# Cairo tutorial: https://www.cairographics.org/tutorial/
# CALLED FROM: DrawNode()
#======================================================================================#
function drawText(context,node,E)
			# CAIRO_FT_SYNTHESIZE_BOLD      Embolden the glyphs (redraw with a pixel offset)	 
    		# CAIRO_FT_SYNTHESIZE_OBLIQUE   Slant the glyph outline by 12 degrees to the right.
    		# (context,node,E)
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
	           # if !isnull(node.text)  print("Had no Text node")end
	            	#node.text = Text()

	        	# Todo: Fix this so we aren't playing arround with spaces
                # one of the following may be perfect for keeping the spaces...
                # words = split(path, r"(?=[some-identifier])") 
                # words = split(path, r"(?<=[some-identifier])") 
	            words = split(E["text"])
                
	            buffer = "" 
                line = Line("",0,0)
#=
	            #for word in words
	            buffer = ""
	            line.text = ""
	            line.words = 1
	            line.space = node.content.width
	            print(node.content.width, ":   ")
	            for i in 1:length(words)
 						buffer = words[i] * " "

			      	
	            	extents = text_extents(context,buffer);
	            	# Full or Overflowing
	            	if extents[3] >= line.space || i == length(words)
                        if i == length(words)
                        	line.text = line.text*buffer 
                        end	            	
                        push!(text.lines,line)
                        print(text_extents(context,line.text)[3], ":")
                        line = Line("",0,0)
			            line.text = ""
			            line.words = 1
			            line.space = node.content.width
  					else # Add another word
  						# Recalculate free space
	            		line.space = line.space - (extents[3]+5)
	            		# Increment word index
 						line.words = line.words + 1
  						#buffer = buffer * " " * words[i]
  						line.text = line.text*buffer
 					end
	            end
=#

# content = get(node.content,)


	            for i in 1:length(words)
				            	if buffer == "" 
				            		testString = words[i]
				            	else
				                	testString = buffer * " " * words[i]
				            	end
	            	extents = text_extents(context,testString );

	            	if extents[3] < node.content.width # (extents[3]*.63)
	            		line.space = ( node.content.width ) - extents[3]
 						buffer = testString
 						line.words = line.words + 1
 					elseif i == length(words) # Flush out buffer
 						push!(text.lines,line) # Flush
						# print("end of line.")
                        line = Line("",0,0)    # Renew

 						line.words = line.words + 1
 						line.text = testString
 	            		line.space = ( node.content.width ) - extents[3]

                       push!(text.lines,line)
					else
 						line.text = buffer
                        push!(text.lines,line)
                        buffer = words[i]
                        line = Line("",0,0)
 					end

	            end



                set_antialias(context,0)
               # extents = text_extents(context,E["text"]);
				x = node.content.left
				y = node.content.top + text.size #extents[4]
				move_to(context, x, y);
				textcolor = text.color 
                if length(textcolor) > 3
                    set_source_rgba(context, textcolor[1], textcolor[2], textcolor[3], textcolor[4]);                     
                else
                    set_source_rgb(context, textcolor[1], textcolor[2], textcolor[3]); 
                end
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
				            X = x
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
						    move_to(context, X, y);
							show_text(context,w);
				            X = X + width[3] + spacer
						end

							y = y + ( text.size * text.lineHeight) # WAS: extents[4]
							if y >=  node.content.top + node.content.height
                                # print("drop out")
								break
							end

				else
						    #extents = text_extents(context,line.text );
			            	# print(extents)
			            	if text.align == "left"
				            	X = x
				            elseif text.align == "right"
				            	X = x + line.space
				            elseif text.align == "center"
				            	X = x + (line.space/2)
			            	end
			            	# print(extents,": ")
						    move_to(context, X, y);
							show_text(context,line.text);
							y = y + ( text.size * text.lineHeight) # WAS: extents[4]
							if y >= node.content.top + node.content.height - 3
                                # print(" drop out: ",node.content.height, " ", y)
								break
							end
				end #end of not-justify
		end
set_antialias(context,1)
			    # show_text(context,E["text"]);  left
#reveal(widget)
stroke(context);

	# print(text)

end
