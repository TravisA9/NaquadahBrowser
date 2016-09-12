# Naquadah Browser 

####What is Naquadah?

A reconceptualised browser built in Julia programming Language from the ground up. 

>Naquadah currently uses Cairo for graphics and GTK for the GUI.

####What makes it Different?

It does not need multiple Markup Languages such as: HTML, XML, SVG, CSS, etc, to represent content. It can be made with just Json.

![window](doc/figures/Browser-2.png)
# Concept
Although, parsing of HTML, SVG and CSS may eventually be added, this browser was designed to test a new simplified concept for web pages. The Naquadah browser currently downloads and renders pages that are written in Json format. The idea is that by using one language that is well suited for modern web applications much of the bloat and complication can be eliminated, easing and simplifying the design of pages and Apps.

As an example, an App may contain different front end scripts and languages that all need to be parsed, queried and stitched together, This adds complexity to any project and bloat to both the browser and the project itself. Json is a very widely used format and, importantly, is used by JavaScript. Data is also sent and recieved by many servers and databases so it seems to be the best option. HTML was origionally designed for interactive documents on the web and was well designed for that purpose. Due to the way the web is now used, it is my opinion that HTML no longer meets the challange. Put simply, the internet is no longer a web of linked pages but rather, a web of linked applications. Even what appear to be traditional web pages now employ scripts, databiding, querying and so on.

JavaScript is used to query HTML and SVG and modify it on the fly in order to make the web interactive. Templating/data binding engines are also needed because of the often large quantity of repetetive content or content that must be pulled from a database and inserted at the user's request. Instead of makeing endless scripts to interface with HTML, it is my opinion that the solution is to abandon it and use the language that EMCA script already speaks. This will permit templating, restructuring, inserting, seperation of concerns and so much more.

# Sample Web Page

### General structure
```
{
	"head":{...},
	"styles":{...},
	"body":[...]
}	
```

The head may look something like this.
```
	"head":{
			"title":"MyPageTitle",
			"favicon":"http://myapp/favicon.ico"
		   	"charset":"utf-8",
		   	"keywords":"web tech,browser concept,Json Pages",
		   	"author":"Travis Deane Ashworth",
		  	"links":[{"url":"http://myapp/somescript.js"}]
		}
```

The styles section stores frequently used styles (similer to CSS).
```
	"styles":{
			"Button":{styles...},
			"ColoredBox":{styles...}
		}
```

The body describes general structure (similer to HTML and SVG) and may also contain style information.
```
	"body":[
			{">":"div", 
				"class":"Button", 
				"mousedown":"doSomething()",
				"text":"Some text"
			},
			{">":"circle",
				"onhover":"doSomethingElse()",
				"display":"inlineBlock", 
    				"radius":25,		
    				"color":"lightgreen",
				"center":[25,25],
				"border":{"width":"thick", 
					"style":"solid", 
					"color":"blue"},
				"nodes":[...]
			}
	]
```
As you can see there are three major sections to a Json page and these may be one file or spread across several files. It may be modified by script as well.

## How To Install 
First you will need to have  [Julia](http://julialang.org/downloads/) installed.

You will also have to add package dependancies for this project. You can paste the following into the Julia Console and press enter.
```
Pkg.add("Gtk")
Pkg.add("Gtk.ShortNames")
Pkg.add("JSON")
Pkg.add("Cairo")
Pkg.add("Requests")
Pkg.add("Graphics")
Pkg.add("ImageView")
Pkg.add("ImageMagick")
Pkg.add("Images")
```

Finally, you can start the application with one of the following commands:

Windows: ```include("Browser\StartBrowser.jl")```

Linux:   ```include("Browser/StartBrowser.jl")```

similar for Mac.

# Goals
Mantain modularity in order to be adaptable. If in the future there is good reason to switch out something such as the graphics interface, it should be easy to do so without reworking all the code.

Mantain a measure of compatability with principal features of web standards. I believe that a lot of thought was put into the design and functionality of the WWW and that in general it is a good model to follow

Simplify as much as possible while increasing functionality. It is pointless to build another browser if it does not offer good fetures.

Take advantage of opertunities to add select functionality that may not be feasable in an ordinary browser.

Make Naquadah easy to modify and repurpose. Naquadah is made to be used. It may be modified for standalone apps, mobile devices and more. The more it is used, the more it will be developed.

Experiment with reactively connecting to databases for real-time page updates.


# Considerations
### Code
Julia is a great choice for this project because it can be optimized to run very fast. So far, little attention has been given to speed. For instance data types have not yet been specified in many cases and this creates overhead causing much slower code execution. Currently more emphasis has been given to adding broad functionality and to determining the structure of the project So expect much better speed in the future.

### Compatability
Perhaps the reason that no one has attempted to fix the problems with the web is to avoid fragmenting it. If we start doing things differently then we risk end up with two sections of the internet; the HTML version and the Json version. Many large companies have invested great sums of money into developing their web pages and apps and it would be very unfortunate to create a problem in this area. 
Is there a solution? I believe that there are a couple of ways to prevent this. A bridge must be built until a proper transition has been made. To do this, compatability packages need to be made. This would also create some new opertunities for those who wish to write the code needed to build such bridges.
One would be needed to parse the Json to create HTML, SVG and CSS from the Json. There are already some JS libraries that do some of that.
The second, would be to write HTML, SVG and CSS parsers for the Naquadah Browser. This could be in JS and parse them to a Json file or they could be written in Julia as an addition to the browser itself.

# TODO:
Integrate v8 engine

Text and Drop shadows

Clipping

Float

Transitions

Fix Text layout

Generate proper images from blobs

Integrated page editor (perhaps WYSIWYG)

Optimize speed

Compile distributable binaries for major OSs

# Overview

![window](doc/figures/MindMup.png)

travisashworth2007@gmail.com

