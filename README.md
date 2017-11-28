# Naquadah Browser

---

#### What is Naquadah?

**Short answer**: A browser and _layout engine_ that consumes **Json** instead of HTML

> Naquadah currently uses **Cairo** for graphics and **GTK** for the GUI.

**Long answer**: Although, Naquadah looks and functions like a browser, there are a few differences. Naquadah principally consists of a **layout engine** and a **rendering engine** built from the ground up. For convenience, it includes a basic GUI as well. It is written in the awesome **Julia language** and serves as a test of julia's value as a general purpose language. It is being developed for fun and for the purpose of displaying my work but if it proves to be useful, that would be great too.

## \* Warning this project is being overhualed!

In order to improve the general design and improve modularity I am making some breaking changes.

### ...Update:

I have now moved the old version of NaquadahBrowser to a folder. The current version of Naquadah is the updated version although some functionality is still missing.

Take a look at at an example page in the new version of Naquadah!  
![window](doc/figures/Naquadah_2017.png)  
Progress Report

| Feature |  :construction_worker:|  State of development |
| :--- | :--- |  :--- |
| Tags |   :white_check_mark: |  div, p, circle, page |
| Styles |  :white_check_mark: |  color, opacity, gradients, size, display, position, border, radius, padding, margin, font, alignment and more! |
| Classes |  :white_check_mark: |  Not yet finished |
| Floats | :soon: |  Left is working but I need to finish Right \(I think\) |
| Display |  :white_check_mark: |  inline, inline-block, block \(mostly all working\) |
| Position |  :white_check_mark: |  fixed, absolute, relative |
| Box-Modal |  :white_check_mark: |  content, padding, border, margin |
| Colors |  :white_check_mark: |  Any color with or without opacity |
| Events | :soon: |  mousedown, mouseup, click, drag, scroll and hover fire but do not yet trigger meaningfull actions. |
| Clipping |  :white_check_mark: |  Mostly set up and working. |
| Text selection and highlighting | :soon: |  Not yet started |
| Gradients |  :white_check_mark: |  Mostly working |
| Border Radius |  :white_check_mark: |  Working fine |
| Overflow |  :interrobang: |  Don't remember |
| Links |  :heavy_exclamation_mark: |  Not yet finished |
| Shadow DOM | :soon: |  Scrollbars, window controls |
| Transforms/Transitions/Animations |  :heavy_exclamation_mark: |  Not yet started |
| Shadows | :soon: |  Temporary hack for text/basically not yet begun |
| Backgrounds |  :white_check_mark: |  color, radial-gradient, linear-gradient, image \(most all with optional opacity\) |
| Columns |  :heavy_exclamation_mark: |  Not yet started |
| Media queries |  :heavy_exclamation_mark: |  Not yet started |
| Selectors \(.\),   \#,   \[\],   $=,   \*=,   &gt; |  :heavy_exclamation_mark: |  Not yet started |
| Max/min |  :heavy_exclamation_mark: |  Not yet available |
| Tables |  :heavy_exclamation_mark: |  Not yet |
| Lists |   :heavy_exclamation_mark: |  Not yet |



| Special Features |  :construction_worker:|   |
| :--- |  :---|  :--- |
| Geometry as Nodes |  :sparkles: |  So far circles are set up to work as normal page elements but other common geometries will soon be added. |
| Tabs and Search bar are Shadow DOM |  :sparkles: |  This makes it possible to move or redesign them. This should help ensure that the browser works with any graphics engine changes and even change the appearance and functionality where needed \(Ex. mobile devices\). |
|  |  |

A few things that are missing from the current version that worked in the previous:

* Most events
* Controls' functionality
* Text selection
* Compilation of styles section

### Take a look at the old version

![window](doc/figures/browser-1.gif)



---

# General structure

Example of Json as a Web Page

```JSON
{
    "head":{...},
    "styles":{...},
    "body":[...]
}
```

The **head** may look something like this.

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

The **styles** section stores frequently used styles \(similar to CSS\). Styles can also be used as color swatches or as templates adding structure or other default aspects to a node.

```JSON
    "styles":{
            "Button":{styles...},
            "ColoredBox":{styles...}
        }
```

The **body** describes general structure \(similar to HTML and SVG\) and may also contain style information.

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

# How To Get Started

* First install [Julia](http://julialang.org/downloads/). To start julia up go to your terminal and type:

  ```
  $  julia
  ```

* Clone NaquadahBrowser thusly:

  ```julia
  julia> Pkg.clone("https://github.com/TravisA9/NaquadahBrowser.git")
  ```

* You may also have to add package **dependencies** for this project. You can paste the following into the Julia Console and press enter.

  ```julia
  Pkg.add("Gtk")
  Pkg.add("JSON")
  Pkg.add("Cairo")
  Pkg.add("Requests")
  ```

* Finally, one way you can start the application is with the following command:

```julia
julia> using NaquadahBrowser
```

If you close the window you can restart it like this:

```julia
julia> Start()
```

# General Goals

* Maintain modularity in order to be adaptable. If in the future there is good reason to switch out something such as the graphics interface, it should be easy to do so without reworking all the code. Also, if someone wants to use just one module out of Naquadah it should be easy to do so.
* Maintain a measure of compatibility with principal features of web standards. I believe that a lot of thought was put into the design and functionality of the WWW and that in general it is a good model to follow.
* Simplify as much as possible while increasing functionality. It is pointless to build another browser if it does not offer good features.
* Take advantage of opportunities to add select functionality that may not be feasible in an ordinary browser.
* Make Naquadah easy to modify and re-purpose. Naquadah is made to be used. It may be modified for standalone apps, mobile devices, text editors and more. The more it is used, the more it will be developed.
* Experiment with reactively connecting to databases for real-time page updates.

# Wish List:

* Generate proper images from blobs
* Integrated page editor \(perhaps WYSIWYG\)
* Optimize speed
* Compile distributable binaries for major OSs
* Plotting and plot animation utilities \(Ex. force layout functionality\). Since Naquadah is meant to be a layout engine, it may be nice to include more than just the basic browser options.





travisashworth2007@gmail.com
