# NaquadahBrowser
A browser built in Julia Language from the ground up. Naquadah currently uses Cairo for graphics and GTK for the GUI.
# Concept
Although, parsing of HTML, SVG and CSS may eventually be added, this browser was designed to test a new simplified concept for web pages. The Naquadah browser currently downloads pages that are written in Json format. The idea is that by using one language that is well suited for modern web applications much of the bloat and complication can be eliminated, easing and simplifying the design of pages and Apps.

As an example, an App may contain different front end scripts and languages that all need to be parsed, queried and stitched together, This adds complexity to any project and bloat to both the browser and the project itself. Json is a very widely used format and, importantly, is used by JavaScript. Data is also sent and recieved by many servers and databases so it seems to be the best option. HTML was origionally designed for interactive documents on the web and was well designed for that purpose. Due to the way the web is now used, it is my opinion that HTML no longer meets the challange. Put simply, the internet is no longer a web of linked doccuments but rather, a web of linked applications. 

JavaScript is used to query HTML and SVG and modify it on the fly in order to make the web interactive. Templating/data binding engines are also build because of the often large quantity of repetetive content or content that must be pulled from a database and inserted at the user's request. Instead of makeing endless scripts to interface with HTML, it is my opinion that the solution is to abandon it and use the language that EMCA script already speaks. This will permit templating, restructuring, inserting, seperation of concerns and so much more.

## How To Install 
First you will need to have  [Julia](http://julialang.org/downloads/) installed.

You will also have to add package dependancies for this project. You can past these into the Julia Console.
'''
Pkg.add("Gtk")
Pkg.add("JSON")
Pkg.add("Cairo")
Pkg.add("Requests")
Pkg.add("Gtk.ShortNames")
Pkg.add("Graphics")
Pkg.add("ImageView")
Pkg.add("ImageMagick")
Pkg.add("Images")
'''

Finally, you can start the application with the corresponding comand:
Windows: '''include("Browser\StartBrowser.jl")'''
Linux: '''include("Browser/StartBrowser.jl")'''
similar for Mac.

