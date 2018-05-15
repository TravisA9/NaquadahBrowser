# Naquadah Browser

#### Files

#### [Dom.jl]()

Contains the includes

#### [DomBuildDefualts.jl]()

```julia
CreateDefaultNode(document::Page, parent::Element, DOM::Dict)

Copy(primary::Dict, secondary::Dict, attribute::String)

MergeAttributes(primary::Dict, secondary::Dict)
```

#### [DomShadow.jl]()

 Default styling for the following shadow DOM items:

```julia
 icons, downloadIcon, downloadIcon, NewPageIcon, JuliaIcon, button, tab,
 tabControls, navigation, navBar, newPage
 ```

#### [DomTagDefaults.jl]()

Default styles for all standard and non-standard elements (div, p, body, circle...)

#### [DomToLayout.jl]()

```julia
isAny(key::String, strings::Array{String})

CopyDict(primary::Dict, secondary::Dict)

AtributesToLayout(document::Page, node::Element)

CreateShape(form::String, node::Element, h, w)
```

#### [DomTree.jl]()

```julia
CreateDomTree(document::Page, parent::Element)

FetchPage(win, URL::String, canvas::Gtk.GtkCanvas)
```

#### [DomUtilities.jl]()

GetTheColor(node, DOMColor)

```julia
printDict(DOM)
```

#### [ElementsDefault.jl]()

Possibly redundant to: DomTagDefault.jl !
