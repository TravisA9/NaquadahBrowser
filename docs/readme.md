
## If you like this project please [give it a star or try it out](https://github.com/TravisA9/NaquadahBrowser/tree/master/src)
![window](/doc/figures/NaquadahMay2018.gif)
---
#### [Leer en español](/Español.md)

## What is Naquadah?

**Short answer**: An experimental web browser that consumes **Scss**-like code instead of **HTML/SVG/CSS**

#### Why would we want that?

Here are some observations on a few languages:

| language | Structured | Expressive | Terse |
| :--- | :--- | :--- | :--- |
| Html | Yes | Yes | No |
| Css | No | Yes | No |
| Json | Yes | So-So | No |
| Scss | Yes | Yes | Yes |

One of the principal experimental features of Naquadah is a consolidation of the many langauges into just one. This should greatly reduce the complexity of both the browser and web site/app design. It also opens up new possibilities for the browser.


Take a look at a more recent image:
![window](figures/Naquadah-sml.png)

## Why You should donate?
A project like this takes many hundreds of hours to get up and running and thousands of hours to polish and mantain. If no one invests the time to develop and test new ideas like this no one will benefit from them. The time I spend on this project could well be spent on other activities, but if you think this project is worth investing in, you can donate so that I can afford to spend more time developing NaquadahBrowser.

https://travisa9.github.io/NaquadahBrowser/

<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick" />
<input type="hidden" name="hosted_button_id" value="6EUBLKUKFAPU8" />
<input type="image" src="https://www.paypalobjects.com/en_US/MX/i/btn/btn_donateCC_LG.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Donate with PayPal button" />
<img alt="" border="0" src="https://www.paypal.com/en_MX/i/scr/pixel.gif" width="1" height="1" />
</form>


### A more detailed description of Naquadah:

Although, Naquadah looks and functions much like a standard web browser, you will find that there are a few interesting differences. Like a normal browser, Naquadah principally consists of a **layout engine** and a **render engine** built from the ground up. So, **it's not a repackaging of some browser engine such as webkit**.

* Naquadah uses **Cairo** for basic graphics and **GTK** for the GUI.

* Written in **julia** programming language. Currently tested in julia v1.04 in linux. Previous versions have been tested on Windows.


#### State of the project

| Features Working |
| :---  |
| **Tags:**  div, p, h1-h6, hr, a, pre, circle, page ( 'path' is currently under development)|
|  **Styles:**   color, opacity, gradients, size, display, position, border, border-radius, radius, padding, margin, font, alignment and more! |
|  **SML:** Classes, Templates, Tags, Variables |
| **Float:** Left, Right |
|  **Display:**  inline, inline-block, block, none |
|  **Position:**  fixed, absolute, relative |
|  **Box-Modal:**  content, padding, border, margin |
|  **Colors:**  Any color (with or without opacity) |
| **Events:**  |
| **julia:** Web browsers usually execute JavaScript. This browser executes julia |
|  **Clipping, Text selection, Gradients, Overflow**  |
| **Shadow DOM:** Scrollbars (partially working), window controls |
|  **Backgrounds:**  color, radial-gradient, linear-gradient, image \(with optional opacity\) |


| Features In Progress |
| :--- |
| **Shadows:** Temporary hack for text/ currently a full implementation is being developed |
| **Links**  |


|  Feature Not Yet Implemented |
| :--- |
| **Transforms, Transitions, Animations, Columns, Media queries, Max/min, Tables, Lists** |
|  **Selectors:**   \(.\),   \#,   \[\],   $=,   \*=,   &gt;  |




### Just in case you didn't notice, here are some cool features of Naquadah:

* **Geometry as Nodes:** SVG is increasingly being mixed in with Html. The objective here is not to mix, but to completely integrate the features of SVG into our markup language. So far circles are set up to work as normal page elements but other common geometries will also soon be added.

* **Tabs, Search bar, etc. are Shadow DOM:**  This makes it possible to move or even completely redesign them. This should help ensure that the browser works with any graphics engine changes and even change the appearance and functionality where needed \(Ex. mobile devices\).

* **Classes, variables and templates:** Templates are often desirable to define structure (and its associated styles) that is repetitive within a web site. This can be done in Sml, an Scss-like language. By declaring a class in Sml you can apply styles to whole structures of elements. You can also create named variables and use them in your Sml.
* **julia:** Web browsers usually execute JavaScript. This browser executes julia

---

# Introducing SML
Initially, I used JSON in place of Html, Svg and Css as web pages. After a lot of thought, I realised that an Scss-like syntax would be much better. It is easier to read and fewer punctuation marks as delimiters. It is way more expressive and looks cleaner. I call it Sml!

### General structure

Example of SML as a Web Page

```scss
	// This is a comment.

div{
    div{ color:white; padding:10;
        div{	display:inline-block; width: 108;
          font-color:0.21 0.26 0.41; font-size:18; font-style:oblique;
        text:"Presenting Naquadah:"}
        div{	display:inline-block; width: 200; padding:8 0 0 0; vertical-align:middle;
          border-width:2 0 0 0;border-color:0.41 0.51 0.82; border-style:solid;
          font-color:black; font-size:14; align:center
        text:"As a test of julia in General Purpose Computing"; }

        div{ class:MenuButton;	text:INFO}
        div{ class:MenuButton;	text:TESTS}
        div{ class:MenuButton;	text:IDEAS}
        div{ class:MenuButton;	text:ABOUT}
        div{ class:MenuButton;	text:HOME}
    }

...

```



**Styles** can be added right in the nodes but you can also create classes and add the class name to your Sml element. The cool thing here is that Sml classes can apply styles to nested structures. In the example below, you can see that ``` .round-button ``` has styles but contains ``` Circle ``` which also has a style. Both get applied to their respective elements.

```scss
.round-button{
    display:inline-block; margin:7; radius:12; color: 0.6 0.6 0.6
    hover{ color: 0.8 0.8 0.8; }
    circle{ radius:12;}
}

div{ height:39; color:0.6 0.6 0.6; padding:2;
    circle{ class:round-button; circle{ image:"Back.png"} }
    ...
    }

```


Styles are great but what if you want to insert new elements or even whole sections into your web page? For that we have **templates**! Let's suppose we want to make a footer for [Slashdot...](https://slashdot.org)

```scss
 @SlashdotGreen:#006666;

 @SlashdotFooter:footer{
    id:fhft;
    class:grid_24 nf;
    div{ id:logo_nf; class:fleft;
        a{ href:"//slashdot.org"; span{Slashdot}}
    }
    nav{ role:"firehose footer"
        ul{ id:pagination-controls;
        ...
	}
    }
    ul{ class:"fright submitstory" 
        li{ class:fright;
            a{ href:"/submit"; span{ class:opt; text:Story; }}
        }
    }
}


```

We can now use ``` @SlashdotGreen ``` as a variable like this: ``` color:@SlashdotGreen; ``` and in a similar manner we can automatically insert a Slashdot footer:
```scss
div{
   ...
   @SlashdotFooter;
}
```
## [Roadmap for Sml](src/DOM/SML.md)

# How To Get Started

* First, install [Julia](http://julialang.org/downloads/) if you haven't already done so.

* To start julia up, go to your terminal and type: `julia`

* Clone NaquadahBrowser thusly:

```julia
  julia> Pkg.clone("https://github.com/TravisA9/NaquadahBrowser.git")
```

* Finally, one way you can start the application is with a REPL command similar to this:

```julia
   julia> include("path/to/NaquadahBrowser.jl")
```
...or run NaquadahBrowser.jl from Juno or another editor.

Note: you may also have to install Xclip for text copy/pasting just run something like `sudo apt install xclip` if you are running linux.

# Code overview: Warning, always changing!

![window](figures/projectMap.png) 

# General Goals

* Maintain modularity in order to be adaptable. If in the future there is good reason to switch out something such as the graphics interface, it should be easy to do so without reworking all the code. Also, if someone wants to use just one module out of Naquadah it should be easy to do so.
* Make Naquadah easy to modify and re-purpose. Naquadah is made with the hopes of being useful. It may be modified for standalone apps, mobile devices, text editors and more. The more it is used, the more it will be developed.

# Wish List:

* Integrated page editor (perhaps WYSIWYG)
* Optimize speed
* Plotting and plot animation utilities \(Ex. force layout functionality\). Since Naquadah is meant to be a layout engine, it may be nice to include more than just the basic browser options.
* Experiment with reactively connecting to databases for real-time page updates.

### Take a look at the old version

![window](figures/browser-1.gif)

travisashworth2007@gmail.com
