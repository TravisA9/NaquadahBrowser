# Naquadah Browser

#### Files

#### [Layout.jl]()

Contains the includes

#### [LayoutBegin.jl]()

Generate a layout tree starting at `node` in `document`. This should be callable starting at any point in the document tree.

```julia
CreateLayoutTree(document::Page, parent::Element)
```

#### [LayoutBuild.jl]()

```julia
setUpWindow(document::Page, w::Float64,h::Float64)

getShape(item)

FinalizeRow(row::Row)

PushToRow(document::Page, node::Element, thing, shape, l::Float64,t::Float64,w::Float64)

setNodePosition(shape::Draw, row::Row, x::Float64, width::Float64, height::Float64=0.0)

MoveNodeToLeft(row::Row, index::Int64)

MoveNodeToRight(row::Row, index::Int64)

VmoveAllChildren(node, y::Float64, moveNode::Bool)

MoveAll(node, x::Float64, y::Float64)

LineBreak(node::Element)

fontSlant(shape::NText)

fontWeight(shape::NText)

PushToRow(document::Page, node::Element, MyText::Element, shape::NText, l::Float64, t::Float64, wide::Float64)

pushText(document::Page, node::Element, thing::TextLine, l::Float64,t::Float64,w::Float64)
 ```
