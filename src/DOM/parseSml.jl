# TODO: rewrite in a better and more julian way.
#
# This is just kind of thrown together without any real planning but it seems to
# work. An obviouse design improvement would be to drop the string identifiers
# and use types or something instead. Conssider this as a functional outline for
# a future product.
#-==============================================================================


mutable struct Vars
    name::String
    Vars(name) = new(name)
end
mutable struct Templ
    name::String
    Templ(name) = new(name)
end
#-==============================================================================
# TODO! Integrate selectors...
# https://www.w3schools.com/cssref/css_selectors.asp

# include("Documents/code/parseScss.jl")
#-==============================================================================
# Tokenize Sml text
#-==============================================================================
function tokens(s)
	toks = []
from,i = 1,1
while i < length(s)
    from = i
        if s[from] == '/'
    # Comment-------------------------
            if s[i+1] == '*'
                i+=1
                while !(s[i] == '/' && s[i-1] == '*')
                    i+=1
                end
				push!(toks, ["Comment", s[from:i]])
    # Comment-------------------------
            elseif s[i+1] == '/'
	              i+=1
                while s[i+1] != '\n'
                    i+=1
                end
				push!(toks, ["Comment", s[from:i]])
    # Divide-------------------------
            else
				push!(toks, ["Math", s[from:i]])
            end
    # Var-------------------------
		elseif s[from] == '@'
            i+=1
            while isletter(s[i+1]) || s[i+1] == '-'
                i+=1
            end
			push!(toks, ["Vars", Vars(s[from+1:i])])
	# Text-------------------------
		elseif s[from] == '"'
			if s[i+1] == '"' &&  s[i+2] == '"'
				i+=3
				while !(s[i] == '"' && s[i-1] == '"' && s[i-2] == '"' && s[i-3] != '\\')
					 i+=1
				end
				push!(toks, ["Text", s[from+3:i-3]])
			else
			     i+=1
			     while s[i] != '"'
					 if s[i] == '\\' && s[i+1] == '"'
						 i+=2
					 else
				         i+=1
					 end
			     end

				 push!(toks, ["Text", replace(s[from+1:i-1], "\\\"" => "\"" )])
		 	end
    # Identifier-------------------------
        elseif isletter(s[from])
			if !(isletter(s[i+1]) || s[i+1] == '-' || isdigit(s[i+1]))
				push!(toks, ["Identifier", s[from:i]]) # i+=1
			else
	            while isletter(s[i+1]) || s[i+1] == '-' || isdigit(s[i+1])
	                i+=1
				end
				push!(toks, ["Identifier", s[from:i]])
			end
    # Class-------------------------
        elseif s[from] == '.'
            i+=1
            while isletter(s[i+1]) || s[i+1] == '-'
                i+=1
            end
		push!(toks, ["Class", s[from+1:i]])
	# Number------------------------
		elseif s[from] == '-' || isdigit(s[i]) || s[i] == '.'
	    	while isdigit(s[i+1]) || s[i+1] == '.'
		        i+=1
	        end
			push!(toks, ["Number", parse(Float64, s[from:i])])
			if s[i+1] == '%'
				i+=1
				push!(toks, ["Unit", s[i]])
			end
	# Math------------------------
	        elseif s[from] == '+' || s[i] == '-' || s[i] == '/' || s[i] == '*' || s[i] == '%'
				push!(toks, ["Math", s[i]])
    # Hex-------------------------
        elseif s[from] == '#'
            i+=1
            while isdigit(s[i+1]) || 'a' <= s[i+1] <= 'f'
                i+=1
            end
			push!(toks, ["Hex", s[from:i]])
    # Space-------------------------
        elseif s[from] == ' ' || s[i] == '\t'
            while s[i+1] == ' ' || s[i+1] == '\t'
                i+=1
            end
			push!(toks, ["Space", s[from:i]])
    # Comma-------------------------
        elseif s[from] == ','
			push!(toks, ["Comma", s[i]])
    # Instance-------------------------
        elseif s[from] == ':'
			push!(toks, ["Instance", s[i]])
    # OpenBl-------------------------
        elseif s[from] == '{'
			push!(toks, ["OpenBl", s[i]])
    # CloseBl-------------------------
        elseif s[from] == '}'
			push!(toks, ["CloseBl", s[i]])
    # EndLine-------------------------
		elseif s[from] == '\r' ||  s[from] == '\n' ||  s[i] == ';'
			push!(toks, ["EndLine", s[i]])
    # CatchAll-------------------------
        else
             println("CatchAll: " * s[i], UInt8(s[i]))
        end
    i+=1
  end
  return toks
end
#-==============================================================================
# "Class" "Identifier" "Vars" "Comment" "Comma" "Instance"  "OpenBl" "CloseBl"
#-==============================================================================
function crunch(toks)
	stack = []
	push!(toks, ["EndLine",';'], ["EndLine",';']);

# Remove whitspace and other nodes
push!(stack, toks[1])
	for t in 2:length(toks)
		if  !((toks[t][1] == "EndLine" && toks[t-1][1] == "EndLine") || toks[t][1] == "Space" || toks[t][1] == "Comma" || toks[t][1] == "Comment")
		   push!(stack, toks[t])
		end
	end

	# find Attributes
	toks = stack
	stack = []
	t=1
	push!(toks, ["telemer",';'],["telemer",';'],["telemer",';'],["telemer",';'],["telemer",';']);
	while t < length(toks)
		if  toks[t][1] == "Identifier" && toks[t+1][1] == "Instance"
			toks[t][1] = "Attribute"
			push!(stack, toks[t])
			t+=2
		else
			push!(stack, toks[t])
			t+=1
		end
	end

	# Make numbers
	toks = stack
	stack = []
	t=1
	while t <= length(toks)
		if  toks[t][1] == "Number" && (toks[t+1][1] == "Identifier" || toks[t+1][1] == "Unit") # Unit
			push!(stack, ["Identifier", [toks[t][2], toks[t+1][2]]])
			t+=2
		else
			push!(stack, toks[t])
			t+=1
		end
	end

	# Make Arrays      {[\n\s]+}    [^{}]+
	# Hex Number Text Var Identifier
	toks = stack
	stack = []
	t=1
	while t < length(toks)
		b, c = toks[t][1], toks[t+1][1]
		if (b == "Hex" || b == "Number" || b == "Text" || b == "Vars" || b == "Identifier") && (c == "Hex" || c == "Number" || c == "Text" || c == "Vars" || c == "Identifier")
			a = [toks[t][2], toks[t+1][2]]
			t+=2
			while t < length(toks) && (toks[t][1] == "Hex" || toks[t][1] == "Number" || toks[t][1] == "Text" || toks[t][1] == "Vars" || toks[t][1] == "Identifier")
				push!(a, toks[t][2])
				t+=1
			end
			push!(stack, ["Identifier", a])
		else
			push!(stack, toks[t])
			t+=1
		end
	end


t = stack
push!(t, ["EndLine",';'], ["EndLine",';'], ["EndLine",';']);

stack = []
i=1
	while i < length(t)-3
		one, two, three, four = t[i],t[i+1],t[i+2],t[i+3]
		if  one[1] == "Vars"
			if two[1] == "Instance"
				if three[1] == "Identifier" || three[1] == "Hex" || three[1] == "Vars"
					if four[1] == "OpenBl" # @temp:div{
						push!(stack, [Templ(one[2].name), three[2]])
					else
						push!(stack, [one[1], one[2], "Identifier", three[2]])
					end
					i+=3
				end
			elseif two[1] == "EndLine"
				push!(stack, ["Template", one[2]])
				i+=2
			end
		# Attribute
		elseif  one[1] == "Attribute" #&& two[1] == "Identifier"
			if two[1] == "Vars" || two[1] == "Text" || two[1] == "Hex" || two[1] == "Identifier" || two[1] == "Number"
				push!(stack, [one[1], one[2], two[1], two[2]])
			i+=2
			end
		elseif  one[1] == "CloseBl"
			push!(stack, one)
			i+=1
		elseif  one[1] == "EndLine" || one[1] == "Space"
			i+=1
		elseif  one[1] == "Identifier" && two[1] == "OpenBl"
			one[1] = "Tag"
			push!(stack, one)
			push!(stack, two)
			i+=2
		else
			push!(stack, one)
			i+=1
		end
	end

	return stack
end
#-==============================================================================
# EndLine CloseBl OpenBl Instance Comma Space Hex Math Unit Number Class Identifier Text Vars Comment
# Identifier
# Text Hex Math
# Class Vars Tag
#-==============================================================================

#-==================================OUTLINE=====================================
#                                               # structure, content, styles
# element: ["div", Dict(atributes), []]         #    yes       yes     yes
# variable: ["MyTemplate", Dict(atributes), []] #    yes     default   yes
# variable: ["Mycolor", Value]                  # ---- just store a value ----
# class: ["div", Dict(atributes), []]           #    no        no      yes
#-==============================================================================
#  [ element/variable/class(name: , Dict(atributes), []) ]
function nest(toks)
	this = Dict("styles"=>Dict(), "templates"=>Dict(), "nodes"=>[])
	t = 1

	function element(toks, named=true)
		name = toks[t][2]
		node = Dict()
		node["nodes"] = []
		t+=1  #["Vars", "template", []] & ["OpenBl", '{']
			while toks[t][1] != "CloseBl"
				if toks[t+1][1] == "OpenBl"
					newname = toks[t][2]
					attributeStructs = ["mousedown", "click", "font", "hover",
					"border", "linear-gradient", "radial-gradient"]
					if newname in attributeStructs
						node[newname] = element(toks, false)
					else # Child element
						push!(node["nodes"], element(toks))
					end
				elseif toks[t][1] == "Attribute" || toks[t][1] == "Text"
					if length(toks[t])<4
						println(toks[t])
					else
						node[toks[t][2]] = toks[t][4]
					end
				elseif toks[t][1] == "OpenBl"
					;
				elseif toks[t][1] == "Template"
					node["Template"] = toks[t][2]
				else
					# println("Error!", toks[t])
				end
				t+=1
			end
			if named==true
				node[">"] = name
			end
				return node #
	end

	while t < length(toks)
		if isa(toks[t][1], Templ)#toks[t][1] == "Template"
			push!(this["templates"], toks[t][1].name => element(toks))
		elseif toks[t][1] == "Vars"
				push!(this["templates"], toks[t][2].name => toks[t][4]) # Plain vanilla Variable
		elseif toks[t][1] == "Tag"
			push!(this["nodes"], element(toks))
		elseif toks[t][1] == "Class"
			push!(this["styles"], toks[t][2] => element(toks, false))
			# println(this["styles"])
		else
			# println("Error! ", toks[t])
		end
		t+=1
	end
	return this
end
#-==============================================================================
#
#-==============================================================================
function addAttributes(node, style)  classname, stylesDict

		attrs = collect(keys(style))
		for a in attrs
			if a == "nodes"
				for n in node["nodes"]
					for st in style["nodes"]
						if n[">"] == st[">"]
							addAttributes(n, st)
						end
					end
				end
			elseif !haskey(node, a) && a != ">"
				node[a] = style[a]
			end
		end
end
#-==============================================================================
#
#-==============================================================================
function compile(classes, templates, nodes)
	for st in nodes
		if haskey(st, "Template")
			if haskey(text["templates"], st["Template"].name)
				push!(st["nodes"], text["templates"][st["Template"].name])
			end
		end
		if haskey(st, "class")
			# WARNING: class could be an array!
			if haskey(classes, st["class"])
				style = classes[st["class"]]
				addAttributes(st, style)
			end
		end
		if length(st["nodes"]) > 0
			compile(classes, templates, st["nodes"])
			# println("has kids!")
		end
	end

	return nodes[1]
end
#-==============================================================================
#
#-==============================================================================
function readSml(text)
	t = nest(crunch(tokens(text)))
	if length(t["templates"]) > 0 || length(t["styles"]) > 0
		return compile(t["styles"],t["templates"],t["nodes"])
	end
	return t["nodes"]
end
#-==============================================================================
#
#-==============================================================================
function writeSml(text)

	function printSml(node, depth)
		if haskey(node,">")
			space = " " ^ ((depth-1)*4)
			println( space * node[">"] * "{")
		end
		attrs = collect(keys(node))
		space = " "^(depth*4)
		for a in attrs
			value = ""
			if a == "font"
			end
			if isa(node[a], Dict)
				# value = node[a][">"]
				# println("-------> ", a,node[a])
				print( space * a * "{ ")
				for (key, val) in node[a]
					if key != "nodes" && key != ">"
						print(key, ":", val, "; ")
					end
				end
				print(" }\n")
			else
				if isa(node[a], Array)
					for n in node[a]
						value *=  " " * string(n)
					end
				elseif isa(node[a], Float64)
					value = string(node[a])
				else
					value = node[a]
				end
				if a != "nodes" && a != ">"
					println( space * a * ":" * value * ";")
				end
			end
		end
		if haskey(node,"nodes")
			for n in node["nodes"]
				printSml(n, depth+1)
			end
		end
		println(space * "}")
	end
	printSml(text, 1)
end

#=
include("/home/travis/Projects/NaquadahBrowser/src/DOM/parseSml.jl")
s = open(f->read(f, String), "/home/travis/Projects/NaquadahBrowser/src/SamplePages/test.sml")
text = readSml(s)
writeSml(text)

include("/home/travis/Projects/NaquadahBrowser/src/DOM/parseSml.jl")
s = open(f->read(f, String), "/home/travis/Projects/NaquadahBrowser/src/SamplePages/test.sml")
print( crunch(tokens(s)) )


print(nest( crunch(tokens(s)) ))

writeSml(text)
=#
