 export VmoveAllChildren, MoveAll, MoveNodeToLeft, MoveNodeToRight


#======================================================================================#
#    Similar to MoveAll() in LayoutBuild.jl
#======================================================================================#
# may be: TextLine -or- Element
function VmoveAllChildren(node, y::Float64, moveNode::Bool)

  shape = node.shape
  if shape.flags[Fixed]
    return
  end
  if moveNode
      shape.top  += y
  end
    if isdefined(node, :rows) # ..it has rows of children so let's move them!
      for i in 1:length(node.rows)
        row = node.rows[i]
        row.top += y
        for j in 1:length(row.nodes)
            VmoveAllChildren(row.nodes[j],y, true) # do the same for each child
        end
      end
    end
end
#======================================================================================#
#    This is only to translate a shape with all children by x,y
#    It may also be nesesary to move the node to another location in its row!
#======================================================================================#
# may be: TextLine -or- Element
function MoveAll(node, x::Float64, y::Float64)
  shape = node.shape
  if shape.flags[Fixed]
    return
  end
  shape.left += x # Move this object!
  shape.top  += y
    if isdefined(node, :rows) # ..it has rows of children so let's move them!
      for i in 1:length(node.rows)
        row = node.rows[i]
        row.left += x # ...don't forget to move the actual row
        row.top += y
        for j in 1:length(row.nodes)
            MoveAll(row.nodes[j],x,y) # do the same for each child
        end
      end
    end
end
#======================================================================================#
#======================================================================================#
function MoveNodeToLeft(row::Row, index::Int64)
  node = row.nodes[index]
  for n in index:-1:2
    row.nodes[n] = row.nodes[n-1]
  end
  row.nodes[1] = node
end
#======================================================================================#
function MoveNodeToRight(row::Row, index::Int64)

  node = row.nodes[index]
  for n in index:length(row.nodes)-1
    row.nodes[n] = row.nodes[n+1]
  end
  row.nodes[end] = node
end





