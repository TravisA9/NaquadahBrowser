

Tags_Default = Dict(

# SHADOW DOM stuff
# <Window>	        Defines a section in a document
"window" => Dict(  "display" => "inline-block",     "padding" => [0,0,4,4],
 								"font" => Dict( "size" => 13, "family" => "Sans",
							 									"weight" => "bold", "color" => "black" )
							),
# h-scroll v-scroll: scrollbar-track scrollbar-thumb
"h-scroll" => Dict( "offset" => 0,
                    "color" => "darkgrey",
										"width" =>  12,
										"height" =>  12,
										"opacity" => 0.3,
                    "hover" => Dict("opacity" => 0.9 ),
										"nodes" => [ Dict(">" => "scrollbar-thumb", "color" => "grey", "height" =>  12,"width" =>  10 ) ]
									),
"v-scroll" => Dict( "offset" => 0,
                    "color" => "darkgrey",
										"width" =>  12,
										"height" =>  12,
										"opacity" => 0.3,
                    "hover" => Dict("opacity" => 0.9 ),
										"nodes" => [ Dict(">" => "scrollbar-thumb", "color" => "grey", "height" =>  12,"width" =>  10 ) ]
									),




# NORMAL DOM stuff
# <a>	        Defines a hyperlink
"a" => Dict(
				     "display" => "inline",
						 "margin" => [0,0,4,4],
				     "font" => Dict(
														"size" => 13,
														"family" => "Sans",
														"weight" => "bold",
														"color" => [0.23,0.2695,0.6757]
						 )
	),
# <abbr>	    Defines an abbreviation or an acronym
"abbr" => Dict("display" => "inline", "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <address>	    Defines contact information for the author/owner of a document
"address" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <area>	    Defines an area inside an image-map
"area" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <article>	    Defines an article
"article" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <aside>	    Defines content aside from the page content
"aside" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <audio>	    Defines sound content
"audio" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <b>	        Defines bold text
"b" => Dict("display" => "inline",  "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <base>	    Specifies the base URL/target for all relative URLs in a document
"base" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <bdi>	        Isolates a part of text that might be formatted in a different direction from other text outside it
"bdi" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <bdo>	        Overrides the current text direction
"bdo" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <blockquote>	Defines a section that is quoted from another source
"blockquote" => Dict("display" => "inline",  "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <body>	    Defines the document's body
"body" => Dict("display" => "block",  "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <br>	        Defines a single line break
"br" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <button>	    Defines a clickable button
"button" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <canvas>	    Used to draw graphics, on the fly, via scripting (usually JavaScript)
"canvas" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <caption>	    Defines a table caption
"caption" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <cite>	    Defines the title of a work
"cite" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <code>	    Defines a piece of computer code
"code" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <col>	        Specifies column properties for each column within a # <colgroup> element
"col" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <colgroup>	Specifies a group of one or more columns in a table f"" => Dict( "font" =>  ""),or formatting
"colgroup" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <datalist>	Specifies a list of pre-defined options for input controls
"datalist" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <dd>	        Defines a description/value of a term in a description list
"dd" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <del>	        Defines text that has been deleted from a document
"del" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <details>	    Defines additional details that the user can view or hide
"details" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <dfn>	        Represents the defining instance of a term
"dfn" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <dialog>	    Defines a dialog box or window
"dialog" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <div>	        Defines a section in a document
"div" => Dict(  "display" => "inline-block",     "margin" => [0,0,4,4],
 								"font" => Dict( "size" => 13, "family" => "Sans",
							 									"weight" => "bold", "color" => "black" )
							),
# <dl>	        Defines a description list
"dl" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <dt>	        Defines a term/name in a description list
"dt" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <em>	        Defines emphasized text
"em" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <embed>	    Defines a container for an external (non-HTML) application
"embed" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <fieldset>	Groups related elements in a form
"fieldset" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <figcaption>	Defines a caption for a # <figure> element
"figcaption" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <figure>	    Specifies self-contained"" => Dict( "font" =>  ""), content
"figure" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <footer>	    Defines a footer for a document or section
"footer" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <form>	    Defines an HTML form for user input
"form" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <h1> to # <h6>	Defines HTML headings
"h1" => Dict( "display" => "block", "margin" => [0,0,9,9],
							"font" => Dict( "size" => 32, "family" => "Sans",
														 "weight" => "bold", "color" => "black" )
							),
"h2" => Dict( "display" => "block", "margin" => [0,0,7,7],
							"font" => Dict( "size" => 24, "family" => "Sans",
														 "weight" => "bold", "color" => "black" )
							),
"h3" => Dict( "display" => "block", "margin" => [0,0,6,6],
							"font" => Dict( "size" => 18, "family" => "Sans",
														 "weight" => "bold", "color" => "black" )
							),
"h4" => Dict( "display" => "block", "margin" => [0,0,5,5],
							"font" => Dict( "size" => 16, "family" => "Sans",
														 "weight" => "bold", "color" => "black" )
							),
"h5" => Dict( "display" => "block", "margin" => [0,0,4,4],
							"font" => Dict( "size" => 13, "family" => "Sans",
														 "weight" => "bold", "color" => "black" )
							),
"h6" => Dict( "display" => "block", "margin" => [0,0,3,3],
							"font" => Dict( "size" => 10, "family" => "Sans",
														 "weight" => "bold", "color" => "black" )
							),
# <head>, Defines information about the document
"head" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <header>	    Defines a header for a document or section
"header" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <hr>	        Defines a thematic change in the content
"hr" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <html>	    Defines the root of an HTML document
"html" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <i>	        Defines a part of text in an alternate voice or mood
"i" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <iframe>	    Defines an inline frame
"iframe" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <img>	        Defines an image
"img" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <input>	    Defines an input control
"input" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <ins>	        Defines a text that has been inserted into a document
"" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <kbd>	        Defines keyboard input
"kbd" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <keygen>	    Defines a key-pair generator field (for forms)
"keygen" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <label>	    Defines a label for an # <input> element
"label" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <legend>	    Defines a caption for a <fieldset> element
"legend" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <li>	        Defines a list item"" => Dict( "font" =>  ""),
"li" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <link>	    Defines the relationship between a document and an external resource (link to style sheets)
"link" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <main>	    Specifies the main content of a document
"main" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <map>	        Defines a client-side image-map
"map" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <mark>	    Defines marked/highlighted text
"mark" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <menu>	    Defines a list/menu of commands
"menu" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <menuitem>	Defines a command/menu item that the user can invoke from a popup menu
"menuitem" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <meta>	    Defines metadata about an HTML document
"meta" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <meter>	    Defines a scalar measurement within a known range (a gauge)
"meter" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <nav>	        Defines navigation l""inks
"nav" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <noscript>	Defines an alternate content for users that do not support client-side scripts
"noscript" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <object>	    Defines an embedded object
"object" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <ol>	        Defines an ordered list
"ol" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <optgroup>	Defines a group of related options in a drop-down list
"optgroup" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <option>	    Defines an option i""n a drop-down list
"option" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <output>	    Defines the result of a calculation
"output" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <p>	        Defines a paragraph
"p" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <param>	    Defines a parameter for an object
"param" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <pre>	        Defines preformatted text
"pre" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <progress>	Represents the progress of a task
"progress" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <q>	        Defines a short quotation
"q" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <rp>	        Defines what to show in browsers that do not support ruby annotations
"rp" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <rt>	        Defines an explanation/pronunciation of characters (for East Asian typography)
"rt" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <ruby>	    Defines a ruby annotation (for East Asian typography)
"ruby" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <s>	        Defines text that is no longer correct
"s" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <samp>	    Defines sample output from a computer program
"samp" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <script>	    Defines a client-side script
"script" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <section>	    Defines a section in a document
"section" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <select>	    Defines a drop-down list
"select" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <small>	    Defines smaller text
"small" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <source>	    Defines multiple media resources for media elements (# <video> and # <audio>)
"source" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <span>	    Defines a section in a document
"span" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <strong>	    Defines important text
"strong" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <style>	    Defines style information for a document
"style" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <sub>	        Defines subscripted text
"sub" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <summary>	    Defines a visible heading for a # <details> element
"summary" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <sup>	        Defines superscripted text""
"sup" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <table>	    Defines a table
"table" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <tbody>	    Groups the body content in a table
"tbody" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <td>	        Defines a cell in a table
"td" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <textarea>	Defines a multiline input control (text area)
"textarea" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <tfoot>	    Groups the footer content in a table
"tfoot" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <th>	        Defines a header cell in a table
"th" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <thead>	    Groups the header content in a table
"thead" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <time>	    Defines a date/time
"time" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <title>	    Defines a title for the document
"title" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <tr>	        Defines a row in a table
"tr" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <track>	    Defines text tracks for media elements (# <video> and # <audio>)
"track" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <u>	        Defines text that should be stylistically om normal text
"u" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <ul>	        Defines an unordered list
"ul" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <var>	        Defines a variable
"var" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <video>	    Defines a video or movie
"video" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" )),
# <wbr>	        Defines a possible line-break
"wbr" => Dict( "font" =>  Dict( "size" => 13, "family" => "Sans", "color" => "black" ))

)



#=type ElementAttributes
		Font
		FontFamily
		FontSize
		FontStyle
		FontVariant 	# Specifies whether or not a text should be displayed in a small-caps font
		FontWeight

		TextAlign  # left center right justify
		TextDecoration  # none overline line-through underline
		TextTransform   # uppercase lowercase capitalize
		TextIndent
		LetterSpacing
		LineHeight
		Direction       # rtl
		WordSpacing
		Color
		TextShadow
		UnicodeBidi
		VerticalAlign
		WhiteSpace
end=#
