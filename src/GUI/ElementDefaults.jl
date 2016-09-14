type ElementAttributes
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
end

Tags_Default = Dict(
# <a>	        Defines a hyperlink
"a" => Dict("display" => "inline", "text-decoration" => "underline", "color" => "blue"
	"font" => "Sans", "font-weight" => "bold", "font-size" => 13, "margin" => [0,0,4,4]),
# <abbr>	    Defines an abbreviation or an acronym
"abbr" => Dict("display" => "inline", "font" =>  ""),
# <address>	    Defines contact information for the author/owner of a document
"address" => Dict( "font" =>  ""),
# <area>	    Defines an area inside an image-map
"area" => Dict( "font" =>  ""),
# <article>	    Defines an article
"article" => Dict( "font" =>  ""),
# <aside>	    Defines content aside from the page content
"aside" => Dict( "font" =>  ""),
# <audio>	    Defines sound content
"audio" => Dict( "font" =>  ""),
# <b>	        Defines bold text
"b" => Dict("display" => "inline",  "font" =>  ""),
# <base>	    Specifies the base URL/target for all relative URLs in a document
"base" => Dict( "font" =>  ""),
# <bdi>	        Isolates a part of text that might be formatted in a different direction from other text outside it
"bdi" => Dict( "font" =>  ""),
# <bdo>	        Overrides the current text direction
"bdo" => Dict( "font" =>  ""),
# <blockquote>	Defines a section that is quoted from another source
"blockquote" => Dict("display" => "inline",  "font" =>  ""),
# <body>	    Defines the document's body
"body" => Dict("display" => "block",  "font" =>  ""),
# <br>	        Defines a single line break
"br" => Dict( "font" =>  ""),
# <button>	    Defines a clickable button
"button" => Dict( "font" =>  ""),
# <canvas>	    Used to draw graphics, on the fly, via scripting (usually JavaScript)
"canvas" => Dict( "font" =>  ""),
# <caption>	    Defines a table caption
"caption" => Dict( "font" =>  ""),
# <cite>	    Defines the title of a work
"cite" => Dict( "font" =>  ""),
# <code>	    Defines a piece of computer code
"code" => Dict( "font" =>  ""),
# <col>	        Specifies column properties for each column within a # <colgroup> element 
"col" => Dict( "font" =>  ""),
# <colgroup>	Specifies a group of one or more columns in a table f"" => Dict( "font" =>  ""),or formatting
"colgroup" => Dict( "font" =>  ""),
# <datalist>	Specifies a list of pre-defined options for input controls
"datalist" => Dict( "font" =>  ""),
# <dd>	        Defines a description/value of a term in a description list
"dd" => Dict( "font" =>  ""),
# <del>	        Defines text that has been deleted from a document
"del" => Dict( "font" =>  ""),
# <details>	    Defines additional details that the user can view or hide
"details" => Dict( "font" =>  ""),
# <dfn>	        Represents the defining instance of a term
"dfn" => Dict( "font" =>  ""),
# <dialog>	    Defines a dialog box or window
"dialog" => Dict( "font" =>  ""),
# <div>	        Defines a section in a document
"div" => Dict( "font" =>  ""),
# <dl>	        Defines a description list
"dl" => Dict( "font" =>  ""),
# <dt>	        Defines a term/name in a description list
"dt" => Dict( "font" =>  ""),
# <em>	        Defines emphasized text 
"em" => Dict( "font" =>  ""),
# <embed>	    Defines a container for an external (non-HTML) application
"embed" => Dict( "font" =>  ""),
# <fieldset>	Groups related elements in a form
"fieldset" => Dict( "font" =>  ""),
# <figcaption>	Defines a caption for a # <figure> element
"figcaption" => Dict( "font" =>  ""),
# <figure>	    Specifies self-contained"" => Dict( "font" =>  ""), content
"figure" => Dict( "font" =>  ""),
# <footer>	    Defines a footer for a document or section
"footer" => Dict( "font" =>  ""),
# <form>	    Defines an HTML form for user input
"form" => Dict( "font" =>  ""),
# <h1> to # <h6>	Defines HTML headings
"h1" => Dict( "display" => "block", "font" => "Sans", "font-weight" => "bold", "font-size" => 32, "margin" => [0,0,9,9]),
"h2" => Dict( "display" => "block", "font" => "Sans", "font-weight" => "bold", "font-size" => 24, "margin" => [0,0,7,7]),
"h3" => Dict( "display" => "block", "font" => "Sans", "font-weight" => "bold", "font-size" => 18, "margin" => [0,0,6,6]),
"h4" => Dict( "display" => "block", "font" => "Sans", "font-weight" => "bold", "font-size" => 16, "margin" => [0,0,5,5]),
"h5" => Dict( "display" => "block", "font" => "Sans", "font-weight" => "bold", "font-size" => 13, "margin" => [0,0,4,4]),
"h6" => Dict( "display" => "block", "font" => "Sans", "font-weight" => "bold", "font-size" => 10, "margin" => [0,0,3,3]),
# <head>, Defines information about the document
"head" => Dict( "font" =>  ""),
# <header>	    Defines a header for a document or section
"header" => Dict( "font" =>  ""),
# <hr>	        Defines a thematic change in the content
"hr" => Dict( "font" =>  ""),
# <html>	    Defines the root of an HTML document
"html" => Dict( "font" =>  ""),
# <i>	        Defines a part of text in an alternate voice or mood
"i" => Dict( "font" =>  ""),
# <iframe>	    Defines an inline frame
"iframe" => Dict( "font" =>  ""),
# <img>	        Defines an image
"img" => Dict( "font" =>  ""),
# <input>	    Defines an input control
"input" => Dict( "font" =>  ""),
# <ins>	        Defines a text that has been inserted into a document
"" => Dict( "font" =>  ""),
# <kbd>	        Defines keyboard input
"kbd" => Dict( "font" =>  ""),
# <keygen>	    Defines a key-pair generator field (for forms)
"keygen" => Dict( "font" =>  ""),
# <label>	    Defines a label for an # <input> element
"label" => Dict( "font" =>  ""),
# <legend>	    Defines a caption for a <fieldset> element
"legend" => Dict( "font" =>  ""),
# <li>	        Defines a list item"" => Dict( "font" =>  ""),
"li" => Dict( "font" =>  ""),
# <link>	    Defines the relationship between a document and an external resource (link to style sheets)
"link" => Dict( "font" =>  ""),
# <main>	    Specifies the main content of a document
"main" => Dict( "font" =>  ""),
# <map>	        Defines a client-side image-map
"map" => Dict( "font" =>  ""),
# <mark>	    Defines marked/highlighted text
"mark" => Dict( "font" =>  ""),
# <menu>	    Defines a list/menu of commands
"menu" => Dict( "font" =>  ""),
# <menuitem>	Defines a command/menu item that the user can invoke from a popup menu
"menuitem" => Dict( "font" =>  ""),
# <meta>	    Defines metadata about an HTML document
"meta" => Dict( "font" =>  ""),
# <meter>	    Defines a scalar measurement within a known range (a gauge)
"meter" => Dict( "font" =>  ""),
# <nav>	        Defines navigation links
"nav" => Dict( "font" =>  ""),
# <noscript>	Defines an alternate content for users that do not support client-side scripts
"noscript" => Dict( "font" =>  ""),
# <object>	    Defines an embedded object
"object" => Dict( "font" =>  ""),
# <ol>	        Defines an ordered list
"ol" => Dict( "font" =>  ""),
# <optgroup>	Defines a group of related options in a drop-down list
"optgroup" => Dict( "font" =>  ""),
# <option>	    Defines an option in a drop-down list
"option" => Dict( "font" =>  ""),
# <output>	    Defines the result of a calculation
"output" => Dict( "font" =>  ""),
# <p>	        Defines a paragraph
"p" => Dict( "font" =>  ""),
# <param>	    Defines a parameter for an object
"param" => Dict( "font" =>  ""),
# <pre>	        Defines preformatted text
"pre" => Dict( "font" =>  ""),
# <progress>	Represents the progress of a task
"progress" => Dict( "font" =>  ""),
# <q>	        Defines a short quotation
"q" => Dict( "font" =>  ""),
# <rp>	        Defines what to show in browsers that do not support ruby annotations
"rp" => Dict( "font" =>  ""),
# <rt>	        Defines an explanation/pronunciation of characters (for East Asian typography)
"rt" => Dict( "font" =>  ""),
# <ruby>	    Defines a ruby annotation (for East Asian typography)
"ruby" => Dict( "font" =>  ""),
# <s>	        Defines text that is no longer correct
"s" => Dict( "font" =>  ""),
# <samp>	    Defines sample output from a computer program
"samp" => Dict( "font" =>  ""),
# <script>	    Defines a client-side script
"script" => Dict( "font" =>  ""),
# <section>	    Defines a section in a document
"section" => Dict( "font" =>  ""),
# <select>	    Defines a drop-down list
"select" => Dict( "font" =>  ""),
# <small>	    Defines smaller text
"small" => Dict( "font" =>  ""),
# <source>	    Defines multiple media resources for media elements (# <video> and # <audio>)
"source" => Dict( "font" =>  ""),
# <span>	    Defines a section in a document
"span" => Dict( "font" =>  ""),
# <strong>	    Defines important text
"strong" => Dict( "font" =>  ""),
# <style>	    Defines style information for a document
"style" => Dict( "font" =>  ""),
# <sub>	        Defines subscripted text
"sub" => Dict( "font" =>  ""),
# <summary>	    Defines a visible heading for a # <details> element
"summary" => Dict( "font" =>  ""),
# <sup>	        Defines superscripted text"" 
"sup" => Dict( "font" =>  ""),
# <table>	    Defines a table
"table" => Dict( "font" =>  ""),
# <tbody>	    Groups the body content in a table
"tbody" => Dict( "font" =>  ""),
# <td>	        Defines a cell in a table
"td" => Dict( "font" =>  ""),
# <textarea>	Defines a multiline input control (text area)
"textarea" => Dict( "font" =>  ""),
# <tfoot>	    Groups the footer content in a table
"tfoot" => Dict( "font" =>  ""),
# <th>	        Defines a header cell in a table
"th" => Dict( "font" =>  ""),
# <thead>	    Groups the header content in a table
"thead" => Dict( "font" =>  ""),
# <time>	    Defines a date/time
"time" => Dict( "font" =>  ""),
# <title>	    Defines a title for the document
"title" => Dict( "font" =>  ""),
# <tr>	        Defines a row in a table
"tr" => Dict( "font" =>  ""),
# <track>	    Defines text tracks for media elements (# <video> and # <audio>)
"track" => Dict( "font" =>  ""),
# <u>	        Defines text that should be stylistically om normal text
"u" => Dict( "font" =>  ""),
# <ul>	        Defines an unordered list
"ul" => Dict( "font" =>  ""),
# <var>	        Defines a variable
"var" => Dict( "font" =>  ""),
# <video>	    Defines a video or movie
"video" => Dict( "font" =>  ""),
# <wbr>	        Defines a possible line-break
"wbr" => Dict( "font" =>  "")

)
