# Convert units to pixels
# CALLED FROM: 
toPercent(percent,ofthis) = ofthis*(percent/100)
em_to_px(em) = em * 0.625
pt_to_px(pt) = pt * 0.75

# TODO: For convenience we could add in inch, cm and many other units
# CALLED FROM: 
function ParseSizeValue(value,ofthis)
	# Parse value epression
	result = match(r"(\d?\.?\d?)(em|px|pt|%)", value)
	# TEST: Em, Pixel, Point or %
	if     result[2] == "em"
		return em_to_px(result[1])
	elseif result[2] == "px" || result[2]==nothing
		return result[1]
	elseif result[2] == "pt"
		return pt_to_px(result[1])
	elseif result[2] == "%"
		return toPercent(percent,ofthis)
	end
end