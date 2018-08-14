p = "M12.5,25a.5.5,0,0,1-.34-.13,6.31,6.31,0,0,0-3.84-1.44,6.66,6.66,0,0,1-6-4.49c-.08-.19-.15-.38-.22-.58l-1.46.39A.5.5,0,0,1,0,18.13l1.78-6a.5.5,0,0,1,.81-.23l4.76,4.14a.5.5,0,0,1-.21.86L6,17.2l.16.25c.6,1,1.32,1.56,1.94,1.56h.19C9.45,19,10,18.41,10,17.2V13H8.55a1.56,1.56,0,0,1-1.19-.54A1.48,1.48,0,0,1,7,11.24,1.55,1.55,0,0,1,8.61,10H10V8.22a4.5,4.5,0,1,1,5,0V10h1.47a1.56,1.56,0,0,1,1.19.54A1.48,1.48,0,0,1,18,11.76,1.55,1.55,0,0,1,16.41,13H15v4.2c0,1.21.55,1.8,1.67,1.8h.19c.73,0,1.52-.9,2.1-1.85L17.88,17a.5.5,0,0,1-.26-.87L22.39,12a.5.5,0,0,1,.81.23l1.78,6a.5.5,0,0,1-.12.49.51.51,0,0,1-.49.13l-1.46-.4c-1.34,3.73-4.16,5.07-6.23,5.07a6.26,6.26,0,0,0-3.84,1.44A.5.5,0,0,1,12.5,25ZM2.42,17.25a.5.5,0,0,1,.48.35,10,10,0,0,0,.34.95c1.19,2.86,3.41,3.88,5.09,3.88a7.2,7.2,0,0,1,4.17,1.43,7.2,7.2,0,0,1,4.17-1.43c2,0,4.39-1.49,5.43-4.82a.5.5,0,0,1,.61-.33l1,.29-1.3-4.34-3.35,2.94.71.1a.5.5,0,0,1,.38.72c-.46.91-1.7,3-3.34,3h-.19A2.52,2.52,0,0,1,14,17.2V12.5a.5.5,0,0,1,.5-.5h1.91a.56.56,0,0,0,.59-.41.49.49,0,0,0-.11-.41.56.56,0,0,0-.43-.19h-2a.5.5,0,0,1-.5-.5V7.94a.5.5,0,0,1,.25-.43A3.46,3.46,0,0,0,16,4.5a3.5,3.5,0,0,0-7,0,3.46,3.46,0,0,0,1.75,3,.5.5,0,0,1,.25.43V10.5a.5.5,0,0,1-.5.5H8.61a.56.56,0,0,0-.59.41.49.49,0,0,0,.11.41.56.56,0,0,0,.43.19H10.5a.5.5,0,0,1,.5.5v4.7A2.52,2.52,0,0,1,8.33,20H8.14a3.6,3.6,0,0,1-2.79-2l-.22-.33a4.4,4.4,0,0,1-.33-.54.5.5,0,0,1,.33-.71l.85-.2-3.44-3-1.3,4.37,1.05-.28ZM12.5,7A2.5,2.5,0,1,1,15,4.5,2.5,2.5,0,0,1,12.5,7Zm0-4A1.5,1.5,0,1,0,14,4.5,1.5,1.5,0,0,0,12.5,3Z"
q =  "M23.75,1H1.25A1.25,1.25,0,0,0,0,2.25v15.5A1.25,1.25,0,0,0,1.25,19H7v3H5v1H20V22H18V19h5.75A1.25,1.25,0,0,0,25,17.75V2.25A1.25,1.25,0,0,0,23.75,1ZM17,22H8V19h9Zm7-4.25a.25.25,0,0,1-.25.25H1.25A.25.25,0,0,1,1,17.75V15H24ZM24,14H1V2.25A.25.25,0,0,1,1.25,2h22.5a.25.25,0,0,1,.25.25Z"

#t = "M50,50A30,50 0 0,1 100,100"
a = "M23.75,1H1.25A1.25,1.25,0,0,0,0,2.25v15.5A1.25,1.25,0,0,0,1.25,19H7v3H5"
#   "M23.75,1H1.25A1.25,1.25,0,0,0,0,2.25v15.5A1.25,1.25,0,0,0,1.25,19H7v3H5v1H20V22H18
#V19h5.75A1.25,1.25,0,0,0,25,17.75V2.25A1.25,1.25,0,0,0,23.75,1Z"b = "M17,22H8V19h9Z"
c = "m7-4.25a.25.25,0,0,1-.25.25H1.25A.25.25,0,0,1,1,17.75V15H24Z"
d = "M24,14H1V2.25A.25.25,0,0,1,1.25,2h22.5a.25.25,0,0,1,.25.25Z"
# ======================================================================================
# Adapted from: https://gitlab.gnome.org/GNOME/librsvg/blob/master/rsvg_internals/src/path_builder.rs
# ======================================================================================
approx_eq(a,b) = (abs(a-b) < 0.00390625) #

function elliptic_arc( ctx, x1::Float64, y1::Float64, rx::Float64, ry::Float64,
                   x_axis_rotation::Float64, is_large_arc::Float64, sweep::Float64,
                   x2::Float64, y2::Float64)

    approx_eq(x1, x2) && approx_eq(y1, y2) &&  return

    is_positive_sweep = (sweep == 1.0)

    # X-axis
    f = x_axis_rotation * pi / 180.0
    sinf, cosf = sin(f), cos(f)
    rx, ry = abs(rx), abs(ry)

    # A bit further down we divide by the square of the radii. Check that we won't divide by zero.
    if ((rx * rx) < 2) || ((ry * ry) < 2)
        line_to(ctx, x2, y2)
        return
    end

    k1 = (x1 - x2) / 2.0
    k2 = (y1 - y2) / 2.0

    x1_ =  cosf * k1 + sinf * k2
    y1_ = -sinf * k1 + cosf * k2

    gamma = (x1_ * x1_) / (rx * rx) + (y1_ * y1_) / (ry * ry)
    if gamma > 1.0
        rx *= sqrt(gamma)
        ry *= sqrt(gamma)
    end

    # Compute the center
    k1 = rx * rx * y1_ * y1_ + ry * ry * x1_ * x1_
    approx_eq(k1, 0.0) && return
    k1 = abs(sqrt(((rx * rx * ry * ry) / k1 - 1.0)))
    #println(k1)
    # println(is_positive_sweep == is_large_arc)
    # println(is_positive_sweep)
    # println(is_large_arc)
    is_positive_sweep == is_large_arc && (k1 = -k1)

    cx_ =  k1 * rx * y1_ / ry
    cy_ = -k1 * ry * x1_ / rx

    cx = cosf * cx_ - sinf * cy_ + (x1 + x2) / 2.0
    cy = sinf * cx_ + cosf * cy_ + (y1 + y2) / 2.0

    # Compute start angle
    k1 = (x1_ - cx_) / rx
    k2 = (y1_ - cy_) / ry
    k3 = (-x1_ - cx_) / rx
    k4 = (-y1_ - cy_) / ry

    k5 = abs(sqrt((k1 * k1 + k2 * k2)))
    approx_eq(k5, 0.0) && return

    k5 = k1 / k5
    k5 = clamp(k5, -1.0, 1.0)
    theta1 = acos(k5)
    k2 < 0.0 && (theta1 = -theta1)


    # Compute delta_theta
    k5 = abs(sqrt(((k1 * k1 + k2 * k2) * (k3 * k3 + k4 * k4))))
    approx_eq(k5, 0.0) && return

    k5 = (k1 * k3 + k2 * k4) / k5
    k5 = clamp(k5, -1.0, 1.0)
    delta_theta = acos(k5)
    if k1 * k4 - k3 * k2 < 0.0
        delta_theta = -delta_theta
    end

    if is_positive_sweep && delta_theta < 0.0
        delta_theta += pi * 2.0
    elseif !is_positive_sweep && delta_theta > 0.0
        delta_theta -= pi * 2.0
    end

    # Now draw the arc
    n_segs::Int32 = abs(ceil((delta_theta / (pi * 0.5 + 0.001)))) # as i32
    n_segs_dbl::Float64 = n_segs

    for i in 0:n_segs-1
        f::Float64 = i
        arc_segment(ctx, cx, cy,
            theta1 + f * delta_theta / n_segs_dbl,
            theta1 + (f + 1.0) * delta_theta / n_segs_dbl,
            rx, ry,
            x_axis_rotation )
    end
end
# ======================================================================================
# .
# ======================================================================================
function arc_segment( ctx, xc::Float64, yc::Float64, th0::Float64, th1::Float64,
                        rx::Float64, ry::Float64, x_axis_rotation::Float64)

    f = x_axis_rotation * pi / 180.0
    sinf = sin(f)
    cosf = cos(f)

    th_half = 0.5 * (th1 - th0)
    t = (8.0 / 3.0) * sin(th_half * 0.5) * sin(th_half * 0.5) / sin(th_half)
    x1 = rx * (cos(th0) - t * sin(th0))
    y1 = ry * (sin(th0) + t * cos(th0))
    x3 = rx * cos(th1)
    y3 = ry * sin(th1)
    x2 = x3 + rx * (t * sin(th1))
    y2 = y3 + ry * (-t * cos(th1))

    curve_to(ctx,   xc + cosf * x1 - sinf * y1,
                    yc + sinf * x1 + cosf * y1,
                    xc + cosf * x2 - sinf * y2,
                    yc + sinf * x2 + cosf * y2,
                    xc + cosf * x3 - sinf * y3,
                    yc + sinf * x3 + cosf * y3 )
end
#///////////////////////////////////////////////////////////////////////////////
function parsePathData(str)
           steps = matchall(r"([a-zA-Z][,\s-\.\d]*)", str)
           s = []
    for step in steps
        values = matchall(r"(-?\d*\.*\d+)", step)
        fvals = map(x->parse(Float64,x), values)
        l = step[1]
        push!(s, (l, fvals))
    end
    return s
end
#///////////////////////////////////////////////////////////////////////////////
# "M50,50   # Start x/y
#  A30,50   # arc (rx/ry)
#  0        # x-axis-rotation
#  0,1      # large-arc/sweep flags
#  100,100" # End
#///////////////////////////////////////////////////////////////////////////////
function drawPath(ctx, path)
    here = nothing

    for step in path
        l = step[1]
        if length(step[2]) > 0
            data = step[2]
        else
            data = [0,0]
        end
        if l == 'M'
            move_to(ctx, data[1], data[2])
            here = data[end-1:end]
        elseif l == 'm'
            rel_move_to(ctx, data[1], data[2])
            here = [here[1]+data[end-1] here[2]+data[end]]

        elseif l == 'L'
            for i in 1:2:length(data)-2
                line_to(ctx, data[i], data[i+1])
                here = data[end-1:end]
            end
        elseif l == 'l'
            for i in 1:2:length(data)-2
                rel_line_to(ctx, data[i], data[i+1])
                here = [here[1]+data[end-1] here[2]+data[end]]
            end

        elseif l == 'H'
                line_to(ctx, data[1], here[2])
                here[1] = data[1]
        elseif l == 'h'
                rel_line_to(ctx, data[1], 0)
                here[1] = here[1]+data[1]


        elseif l == 'V'
                line_to(ctx, here[1], data[1])
                here[2] = data[1]
        elseif l == 'v'
                rel_line_to(ctx, 0, data[1])
                here[2] = here[2]+data[1]


        elseif l == 'C'
            curve_to(ctx, data... );
            here = data[end-1:end]
        elseif l == 'c'
            rel_curve_to(ctx, data... );
            here = [here[1]+data[end-1] here[2]+data[end]]

        # elseif step[1] == 'q' curve_to(ctx, )
    elseif l == 'A'
            for i in 1:7:length(data)
                elliptic_arc( ctx, here[1], here[1],
                    data[i  ], data[i+1],
                    data[i+2], data[i+3], data[i+4],
                    data[i+5], data[i+6])
            end
            here = data[end-1:end]
        elseif l == 'a'
            for i in 1:7:length(data)
                elliptic_arc( ctx, here[1], here[1],
                    here[1]+data[i  ], here[2]+data[i+1],
                    data[i+2], data[i+3], data[i+4],
                    here[1]+data[i+5], here[2]+data[i+6])
            end
            here = [here[1]+data[end-1] here[2]+data[end]]

        elseif l == 'z' ||  l == 'Z'
            close_path(ctx) # stroke(ctx)
        end

    end

end
#///////////////////////////////////////////////////////////////////////////////
function ScalePath(path, scale)
    newpath = copy(path)

    for step in newpath
        l, data = step[1], step[2]
        if (l == 'M' || l == 'm' || l == 'L' || l == 'l' || l == 'C' || l == 'c' ||
           l == 'V' || l == 'v' || l == 'Q' || l == 'q' || l == 'S' || l == 's')
            data .*= scale
        elseif l == 'a' ||  l == 'A'
            for i in 1:7:length(data) # print(b[i:i+6])
                data[i  ] *= scale
                data[i+1] *= scale
                data[i+5] *= scale
                data[i+6] *= scale
            end
        end

    end
    return newpath
end

#///////////////////////////////////////////////////////////////////////////////
#
#///////////////////////////////////////////////////////////////////////////////
path = parsePathData(q)
#path = ScalePath(path, 2)
using Gtk, Graphics, Cairo, Colors


function get_current_point(ctx::CairoContext)
#    ccall((:cairo_get_current_point, Cairo._jl_libcairo), nothing, (Ptr{nothing},Ptr{Cdouble},Ptr{Cdouble}), ctx.ptr, x, y)
    w::Vector{Cdouble,2} = []
    w = ccall((:cairo_get_current_point, Cairo._jl_libcairo), Vector{Cdouble,2}, (Ptr{nothing},), ctx.ptr)
    return w
end

c = @GtkCanvas()
win = GtkWindow(c, "Canvas")
@guarded draw(c) do widget
    ctx = getgc(c)
    h = height(c)
    w = width(c)
    rectangle(ctx, 50,50, 50, 50)
    set_source_rgb(ctx, 1, 1, 1)
    fill(ctx)

    set_line_width(ctx, 1)
    set_source_rgb(ctx, 0, 0, 0)
    # stroke(ctx)
    drawPath(ctx, path)
    println(get_current_point(ctx))
    #println(copy_path_flat(ctx))

    stroke(ctx)
end
show(c)
