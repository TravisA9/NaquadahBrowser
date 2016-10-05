# ======================================================================================
# This is to provide some graphics primatives and a means to interact with them.
#
# ======================================================================================
# BoxFromPoints(a,b)      --Create a bounding box from a couple of points
# BoxsOverlap(a,b)        --Test to see if there is overlap between two boxes
# RowsOverlap(a,b)        --Similar to 'BoxsOverlap()' but only for virticle overlap
# PointInArea(box,point)  --test to see if a point is withing the bounds of a box
#   --
#   --
#   --
#   --

# ======================================================================================
# Create a bounding box from a couple of points
# CALLED FROM: BoxFromPoints(a,b) -->  Above
# ======================================================================================
function BoxFromPoints(a,b)
    min, max = Point(0.0,0.0), Point(0.0,0.0)
      if a.y < b.y
        min.y = a.y
        max.y = b.y
      else
        max.y = a.y
        min.y = b.y
      end
      if a.x < b.x
        min.x = a.x
        max.x = b.x
      else
        max.x = a.x
        min.x = b.x
      end

  return Box( min.x, min.y, max.x-min.x, max.y-min.y )
end
# ======================================================================================
# Test to see if there is overlap between two boxes
# CALLED FROM: BoxsOverlap(a,b) -->  Above
# ======================================================================================
function BoxsOverlap(a::Box,b::Box)
  if b.left > a.left+a.width || a.left > b.left+b.width ||  b.top > a.top+a.height || a.top > b.top+b.height
    return false
  else
    return true
  end
end
# ======================================================================================
# Similar to BoxsOverlap(a,b) but only for virticle overlap
# CALLED FROM: RowsOverlap(a,b) -->  Above
# ======================================================================================
function RowsOverlap(a::Box,b::Box)
  if b.top > a.top+a.height || a.top > b.top+b.height
    return false
  else
    return true
  end
end
# ======================================================================================
# test to see if a point is withing the bounds of a box
# CALLED FROM: PointInArea(box,point) -->  Above
# ======================================================================================
#function PointInArea(box,point)

#end
