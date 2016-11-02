# Naquadah Browser

---

#### What is Naquadah?

Naquadah principally consists of a **layout engine** and a **rendering engine** built from the ground up. For convenience, it includes a basic GUI as well. It is writen in the awesome **Julia language** and serves as a test of julia's value as a general purpose language. 

> Naquadah currently uses **Cairo** for graphics and **GTK** for the GUI.

Naquadah will soon be devided into **modules** for seperation of concerns, to make them usable as stand-alone packages and to facilitate swapping out parts in the future if desired.

Although, Naquadah looks and functions like a browser, there are several differences.

![window](doc/figures/browser-1.gif)

![window](doc/figures/Browser-2.png)

Yes, Naquadah is the name of a mineral from the sci-fi series Stargate. The browser named after that great series is not yet any more stable than the mineral itself. The objective is to build a browser capable of simplifying web design \(front and back end\) and removing unneeded complications.

As the www developed and changed many things were added in order to fill in the gaps. For each new piece added to the puzzle there were more complications introduced ...as if it were a big patch-work quilt where each piece has to be stitched together. If you want a traditional web page with only text, images and links then you can stick to HTML. However, if you want any real functionality you have to code. That usually means that the HTML has to be queried and modified, triggering a series of changes such as re-flow and repaint in the browser. But it is not that simple at all because HTML is not the only language being parsed in most cases. In many web pages XML, SVG, etc. are also used. Then there are other considerations such as what version of the markup is being used. Don't forget the CSS too! It is no surprise then that there are so many languages and packages for querying, parsing, patching or generating pages. They are mostly attempts at data binding and stitching the parts together.

Unfortunately, it is usually necessary to use, not just one, but several of these tools on any given project. This means that there is much overhead... more code, more languages, greater development costs, more complicated setup. The costs effect the server, the browser, the developer, the owner, and the user.

## Here is Naquadah's solution:

* Code in EMCA script \(JavaScript\)
* Data in Json
* That's all!

# Example of a Web Page as Json

### General structure

```JSON
{
    "head":{...},
    "styles":{...},
    "body":[...]
}    
```

The head may look something like this.

```JSON
    "head":{
            "title":"MyPageTitle",
            "favicon":"http://myapp/favicon.ico",
               "charset":"utf-8",
               "keywords":"web tech,browser concept,Json Pages",
               "author":"Travis Deane Ashworth",
              "links":[{"url":"http://myapp/somescript.js"}]
        }
```

The styles section stores frequently used styles \(similer to CSS\).

```JSON
    "styles":{
            "Button":{styles...},
            "ColoredBox":{styles...}
        }
```

The body describes general structure \(similer to HTML and SVG\) and may also contain style information.

```JSON
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

## How To Get Started

* First install [Julia](http://julialang.org/downloads/). To start julia up go to your terminal and type:

  ```
  $  julia
  ```

* Clone NaquadahBrowser thusly:

  ```julia
  julia> Pkg.clone("https://github.com/TravisA9/NaquadahBrowser.git") 
  ```

* You may also have to add package **dependancies** for this project. You can paste the following into the Julia Console and press enter.

  ```julia
  Pkg.add("Gtk")
  Pkg.add("JSON")
  Pkg.add("Cairo")
  Pkg.add("Requests")
  Pkg.add("Graphics")
  Pkg.add("ImageMagick")
  Pkg.add("Images") 
  ```

* Finally, you can start the application with the following command:


```julia
julia> using NaquadahBrowser 
```

If you close the window you can restart it like this:

```julia
julia> Start()
```

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

Integrated page editor \(perhaps WYSIWYG\)

Optimize speed

Compile distributable binaries for major OSs

# Overview

![window](doc/figures/MindMup.png)

travisashworth2007@gmail.com

