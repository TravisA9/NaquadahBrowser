# Naquadah Browser

---

#### What is Naquadah?

**Short answer**: A browser and _layout engine_ that consumes <s>Json</s>  **Scss** instead of **HTML/CSS**

## Scss-like syntax update in progress :construction_worker:

Making web pages in JSON is working and has been great but after seeing the results it is clear we can still do better. This browser is a big experement and I think it is already proving to be worth the while. Json is great but with an Scss-like syntax we can benefit from a greater expressivness and readability of the code. That will mean less typing and better code highlighting features making the code prettier and easier to read. It will also mean fewer punctuation marks such as quotation marks and such.

Here are some observations on a few languages:

| language | Structured | Expressive | Terse |
| :--- |  :--- |  :--- |  :--- |
| Html | :thumbsup: | :thumbsup: | :x: |
| Css | :x: | :thumbsup: | :interrobang: |
| Json | :thumbsup: | :interrobang: | :x: |
| Scss | :thumbsup: | :thumbsup: | :thumbsup: |




Take a look:
![window](doc/figures/NaquadahMay2018.gif)
![window](doc/figures/Naquadah_June_2017.png)

## Why donate?
A project like this takes many hundreds of hours to get up and running. If no one invests the time to develop and test new ideas like this no one will benefit from them. The time I spend on this project coukd well be spent on other activities but if you think this project is worth investing in you can donate so that I can afford to spend more time developing NaquadahBrowser.

https://travisa9.github.io/NaquadahBrowser/

<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick" />
<input type="hidden" name="hosted_button_id" value="6EUBLKUKFAPU8" />
<input type="image" src="https://www.paypalobjects.com/en_US/MX/i/btn/btn_donateCC_LG.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Donate with PayPal button" />
<img alt="" border="0" src="https://www.paypal.com/en_MX/i/scr/pixel.gif" width="1" height="1" />
</form>


**Longer answer**: Although, Naquadah looks and functions much like a standard web browser, you will find that there are a few interesting differences. Like a normal browser, Naquadah principally consists of a **layout engine** and a **render engine** built from the ground up. So, it's not a repackaging of some browser engine such as webkit. 

* Naquadah uses **Cairo** for graphics and **GTK** for the GUI.

* Written in **julia** programming language. Currently tested in julia v1.04 in linux. Previous versions have been tested on Windows.


#### State of the project

| Feature :construction_worker:|  State of development |
| :--- |  :--- |
|  :white_check_mark: Tags |  div, p, h1-h6, hr, a, pre, circle, page ( 'path' is currently under development)|
|  :white_check_mark: Styles |  color, opacity, gradients, size, display, position, border, radius, padding, margin, font, alignment and more! |
|  :white_check_mark: Classes |  working (as a bonus: can be used as templates) |
| Floats :soon: |  Left is working but I need to finish Right \(I think\) |
|  :white_check_mark: Display |  inline, inline-block, block, none |
|  :white_check_mark: Position |  fixed, absolute, relative |
|  :white_check_mark: Box-Modal |  content, padding, border, margin |
|  :white_check_mark: Colors |  Any color (with or without opacity) |
| Events :soon: | Working  |
| :rocket: julia :rocket: | Web browsers usually execute JavaScript. This browser executes julia |
|  :white_check_mark: Clipping |  Mostly set up and working. |
| Text selection and highlighting :soon: |  Going well |
|  :white_check_mark: Gradients |  Mostly working |
|  :white_check_mark: Border Radius |  Working |
| Overflow :interrobang: |  Don't remember |
| Links :heavy_exclamation_mark: |  Nearly finished |
| Shadow DOM :soon: |  Scrollbars (partially working), window controls |
| Transforms/Transitions/Animations :heavy_exclamation_mark: |  Not yet started |
| Shadows :soon: |  Temporary hack for text/basically not yet begun |
|  :white_check_mark: Backgrounds |  color, radial-gradient, linear-gradient, image \(with optional opacity\) |
| Columns :heavy_exclamation_mark: |  Not yet started |
| Media queries :heavy_exclamation_mark: |  Not yet started |
| Selectors \(.\),   \#,   \[\],   $=,   \*=,   &gt;  :heavy_exclamation_mark: |  Not yet started |
| Max/min :heavy_exclamation_mark: |  Not yet available |
| Tables :heavy_exclamation_mark: |  Not yet |
| Lists :heavy_exclamation_mark: |  Not yet |



| Special Features | :mushroom: :octocat:    :pig2: :dash:|
| :--- |  :--- |
| Geometry as Nodes   :sparkles: |  So far circles are set up to work as normal page elements but other common geometries will soon be added. |
| Tabs and Search bar are Shadow DOM   :sparkles: |  This makes it possible to move or redesign them. This should help ensure that the browser works with any graphics engine changes and even change the appearance and functionality where needed \(Ex. mobile devices\). |
|  Classes/Styles as templates :sparkles: | Templates are often desirable to define structure that is repetitive within a web page/site. This can be done by declaring a class (which normally would only define styles) along with structural characteristics. That structure is now part of the class and gets added along with the associated styles. |
| :rocket: julia :rocket: | Web browsers usually execute JavaScript. This browser executes julia |

---

Initially, I used JSON in place of Html and Css as web pages. After a lot of thought, I realised that an Scss-like syntax would be much better. It is easier to read and fewer punctuation marks as delimiters. It is way more expressive and looks cleaner. I call it Sml!

# General structure

Example of Json as a Web Page

```scss
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



**Styles** can be added right in the nodes but you can also create classes and add the class name to your Sml element. The cool thing here is that unlike Sml classes can apply styles to nested structures. In the example below, you can see that ```Scss .round-button ``` has styles but contains ```Scss Circle ``` which also has a style. Both get applied to their respective elements.

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
			a{ href:"//slashdot.org">span{Slashdot}}
		}
		nav{ role:"firehose footer"
				ul{ id:pagination-controls;
					...
				}
			
			ul{ class:"fright submitstory">
					li{ class:fright;>
						a{ href:"/submit"; Submitspan{ class:opt; text:Story; }}
					}
			}
		}
}
 
```

We can now use ```scss @SlashdotGreen ``` as a variable like this: ``scss color:@SlashdotGreen; ``` and in a similar manner we can automatically insert a Slashdot footer: 
```scss 
div{ 
   ... 
   @SlashdotFooter; 
}
```

As you can see there are three major sections to a Json page and these may be one file or spread across several files. It may be modified (in the future) by script as well.

# How To Get Started

* First, install [Julia](http://julialang.org/downloads/) if you haven't already done so.

* To start julia up go to your terminal and type: `julia`

* Clone NaquadahBrowser thusly:

```julia
  julia> Pkg.clone("https://github.com/TravisA9/NaquadahBrowser.git")
```

* Finally, one way you can start the application is with a REPL command similar to this:

```julia
   $ julia

   julia> include("NaquadahBrowser.jl")
```
...or run NaquadahBrowser.jl from Juno or another editor.

Note: you may also have to install Xclip for text copy/pasting just run something like `sudo apt install xclip` if you are running linux.

# Code overview

* [NaquadahCore](https://github.com/TravisA9/NaquadahBrowser/blob/master/src/Naquadah.md)
    - [DOM](https://github.com/TravisA9/NaquadahBrowser/blob/master/src/DOM/Readme.md)
    - [Events](https://github.com/TravisA9/NaquadahBrowser/blob/master/src/Events/Readme.md)
    - [Graphics](https://github.com/TravisA9/NaquadahBrowser/blob/master/src/Graphics/Readme.md)
    - [Layout](https://github.com/TravisA9/NaquadahBrowser/blob/master/src/Layout/Readme.md)

![window](doc/figures/projectMap.png)

# General Goals

* Maintain modularity in order to be adaptable. If in the future there is good reason to switch out something such as the graphics interface, it should be easy to do so without reworking all the code. Also, if someone wants to use just one module out of Naquadah it should be easy to do so.
* ~~Maintain a measure of compatibility with~~ Learn from principal features of web standards.
* Make Naquadah easy to modify and re-purpose. Naquadah is made with the hopes of being useful. It may be modified for standalone apps, mobile devices, text editors and more. The more it is used, the more it will be developed.

# Wish List:

* sass-like syntax as a cleaner and more descriptive alternative to JSON
* Integrated page editor (perhaps WYSIWYG)
* Optimize speed
* Plotting and plot animation utilities \(Ex. force layout functionality\). Since Naquadah is meant to be a layout engine, it may be nice to include more than just the basic browser options.
* Experiment with reactively connecting to databases for real-time page updates.

##  Naquadah has now been overhauled!

In order to improve the general design and improve modularity I rewrote about 90% of the code. A lot of work you say? Yes, that is roughly 4,250 lines of code as I am writing this. That is in spite of the fact that I have made major simplifications to the code.

**More progress** has been made... As the lines of code increase so does the complexity but as I also continue to learn julia I see better ways of writing. I have simplified a lot of code and cleaned up quite a bit as well. As a result I have removed removed a great number of lines while still increasing functionality. I'm sure this will continue to happen and Naquadah will someday become a polished project ...I hope ;)

### Take a look at the old version

![window](doc/figures/browser-1.gif)

travisashworth2007@gmail.com
