using Gtk # https://github.com/lobingera/Gtk.jl.git # branch = new_canvas
using Cairo #  https://github.com/lobingera/Cairo.jl.git # branch = new_canvas
#include("CTM.jl")

module CTM


import Base
type ctm
    matrix
    stack
end

function init()
    ctm(eye(3),Any[]::Vector)
end

function transform(c::ctm,p::Array{Float64,2})
    # concat 3rd column
    p1 = hcat(p[:,1:2],ones(size(p)[1],1))
    q1 = c.matrix * p1'
    q1[1:2,:]'
end

function scale!(c::ctm,s::Real)
    d = eye(3)
    d[1,1] = s
    d[2,2] = s
    c.matrix = d * c.matrix
    c
end

function scale!(c::ctm,sx::Real,sy::Real)
    d = eye(3)
    d[1,1] = sx
    d[2,2] = sy
    c.matrix = d * c.matrix
    c
end

function translate!(c::ctm,tx::Real,ty::Real)
    d = eye(3)
    d[1,3] = tx
    d[2,3] = ty
    c.matrix = d * c.matrix
    c
end

function push!(c::ctm)
    Base.push!(c.stack,c.matrix)
    c
end

function pop!(c::ctm)
    d = Base.pop!(c.stack)
    c.matrix = d
    c
end

function inv(c::ctm)
    c.matrix = Base.inv(c.matrix)
    c
end

function rezoom(c::ctm,x::Real,y::Real,f::Real)
    translate!(c,-x,-y)
    scale!(c,f,f)
    translate!(c,x,y)
    c
end

function transform_single(c::ctm,x::Real,y::Real)
    p = c.matrix * [x;y;1.0]
    p[1],p[2]
end

end # module

type rgba_color
    r::Float64
    g::Float64
    b::Float64
    a::Float64
end

type pgraph
    p::Int32
    x::Real 
    y::Real
    c::Gtk.GtkWidget
    inSelect::Bool
    startSelect::Bool
    button1::Bool
    button2::Bool
    x_sel::Real
    y_sel::Real
    x_esel::Real
    y_esel::Real
    inMove::Bool
    startMove::Bool
    x_move::Real
    y_move::Real
    x_emove::Real
    y_emove::Real
    ctm::CTM.ctm
    #imageStore::CairoSu
    get_data::Function
    draw_data::Function
    col::rgba_color
    show_timing::Bool
    selection_index::Array{Int64,1}
end


#include("plotting-tools.jl")
# plotting tools

#using CTM
#using Cairo

function plot_line(cr::CairoContext,c::CTM.ctm,x::Array{Float64,1},y::Array{Float64,1})

    Cairo.save(cr)  
    x0,y0 = CTM.transform_single(c,x[1],y[1])
    Cairo.move_to(cr,x0,y0)

    for i in 2:length(x)
        x1,y1 = CTM.transform_single(c,x[i],y[i])
        Cairo.line_to(cr,x1,y1)
    end

    Cairo.stroke(cr)
    Cairo.restore(cr)   
end

function plot_dot(cr::CairoContext,c::CTM.ctm,x::Array{Float64,1},y::Array{Float64,1})
    radius = 3.0
    Cairo.save(cr)  
    for i in 1:length(x)
        x0,y0 = CTM.transform_single(c,x[i],y[i])
        Cairo.new_path(cr)
        Cairo.move_to(cr,x0,y0)
        Cairo.rel_move_to(cr,radius,0)
        Cairo.arc(cr, x0, y0, radius, 0, 2*pi)
        Cairo.close_path(cr)
        Cairo.fill(cr)
    end
    Cairo.restore(cr)   
end

function plot_marker(cr::CairoContext,c::CTM.ctm,x::Array{Float64,1},y::Array{Float64,1})
    radius = 6.0
    Cairo.save(cr)  
    for i in 1:length(x)
        x0,y0 = CTM.transform_single(c,x[i],y[i])
        Cairo.new_path(cr)
        Cairo.rectangle(cr,x0-radius/2,y0-radius/2,radius,radius)
        Cairo.fill(cr)
    end
    Cairo.restore(cr)   
end

#include("rrotate.jl")
function rrotate(r0::Real,r1::Real,w::Range{Float64})

x = zeros(length(w))
y = zeros(length(w))

for (i,o) in enumerate(w)
    x[i] = (r0+r1)*cos(o) - (r1 * cos(((r0+r1)/r1)*o))
    y[i] = (r0+r1)*sin(o) - (r1 * sin(((r0+r1)/r1)*o))
    end
x,y
end

function hrotate(r0::Real,r1::Real,w::Range{Float64})

x = zeros(length(w))
y = zeros(length(w))

for (i,o) in enumerate(w)
    x[i] = (r0-r1)*cos(o) - (r1 * cos(((r0-r1)/r1)*o))
    y[i] = (r0-r1)*sin(o) + (r1 * sin(((r0-r1)/r1)*o))
    end
x,y
end


function erotate(r0::Real,r1::Real,d::Real,w::Range{Float64})

x = zeros(length(w))
y = zeros(length(w))

for (i,o) in enumerate(w)
    x[i] = (r0-r1)*cos(o) + (d * cos(((r0+r1)/r1)*o))
    y[i] = (r0-r1)*sin(o) - (d * sin(((r0+r1)/r1)*o))
    end
x,y
end


function sample3()
    w = linspace(0,100*pi,1000)
    hrotate(1.0,0.222,w)
end

function sample4()
    w = linspace(0,100*pi,10000)
    rrotate(0.33,0.1501,w)    
end

function sample5()
    w = linspace(0,100*pi,10000)
    erotate(0.33,0.1501,0.2,w)    
end

function sample6()
    w = linspace(0,100*pi,10000)
    erotate(0.33,0.1501,0.2,w)    
end

function sample7()
    x = [0.0,1.0,1.0,-1.0,-1.0,1.0]
    y = [0.0,1.0,-1.0,-1.0,1.0,1.0]
    x,y
end
function clear_back(cr::CairoContext)
    Cairo.set_source_rgb(cr,1.0,1.0,1.0)
    Cairo.paint(cr)
    nothing
end    

function test_box(x::Array{Float64,1},y::Array{Float64,1},x0,y0,x1,y1)
    t = Array(Bool,length(x))
    t[:] = false
    for k=1:length(x)
        if x[k] <= x0
            continue
        end
        if x[k] >= x1
            continue
        end
        if y[k] <= y0
            continue
        end
        if y[k] >= y1
            continue
        end

        t[k] = true
    end
    t
end

function prep1(n::Int=0,show_timing::Bool=false)
    c = Gtk.@GtkCanvas(true);
    w = Gtk.@GtkWindow(c,"a1");
    c1 = CTM.init()
    CTM.scale!(c1,128.0,-128.0)
    CTM.translate!(c1,128.0,128.0)
    if n==0
        f = sample3
        g = plot_line
        col = rgba_color(0.0,0.0,0.3,1.0)
    elseif n==1
        f = sample4
        g = plot_line
        col = rgba_color(0.0,0.0,0.3,1.0)        
    elseif n==2
        f = sample5
        g = plot_line
        col = rgba_color(0.0,0.0,0.3,1.0)        
    elseif n==3
        f = sample7
        g = plot_line
        col = rgba_color(1.0,0.0,0.0,1.0)        
    else 
        f = sample6
        g = plot_dot
        col = rgba_color(0.0,0.0,0.3,0.3)        
    end

    p = pgraph(0,0.0,0.1,c,false,false,false,false,0.0,0.0,0.0,0.0,
        false,false,0.0,0.0,0.0,0.0,c1,f,g,col,show_timing,[])
    
    signal_connect(on_draw_event,c,:draw,Cint,(Ptr{Void},),true,p)
    signal_connect(on_motion_event,c,"motion-notify-event",Cint,(Ptr{Gtk.GdkEventMotion},),true,p)
    signal_connect(button_press,c,"button-press-event",Cint,(Ptr{Gtk.GdkEventButton},),true,p)
    signal_connect(button_release,c,"button-release-event",Cint,(Ptr{Gtk.GdkEventButton},),true,p)
    signal_connect(scroll,c,"scroll-event",Cint,(Ptr{Gtk.GdkEventScroll},),true,p)

    add_events(c, Gtk.GdkEventMask.POINTER_MOTION | 
                Gtk.GdkEventMask.BUTTON_PRESS | 
                Gtk.GdkEventMask.BUTTON_RELEASE | 
                Gtk.GdkEventMask.SCROLL |
                Gtk.GdkEventMask.KEY_PRESS | 
                Gtk.GdkEventMask.KEY_RELEASE )


    #signal_connect(key_press,w,"key-press-event",Cint,(Ptr{Gtk.GdkEventKey},),true,p)

    #add_events(w, Gtk.GdkEventMask.KEY_PRESS | 
    #            Gtk.GdkEventMask.KEY_RELEASE )

    show(c);
    #w,c,p
    nothing
end

function key_press(w::Ptr{Gtk.GObject},e::Ptr{Gtk.GdkEventKey},p::pgraph)
    e1 = unsafe_load(e)
    display(e1)    
    Int32(false) # propagate the event further
end


function on_draw_event(w::Ptr{Gtk.GObject},cc::Ptr{Void},p::pgraph) 
    #print("draw ",cc," ",p.p," win",w,"\n")

    if p.show_timing
        tic();
    end    

    r = Gtk.allocation(p.c)
    cr = Cairo.CairoContext(cc)

    Cairo.save(cr)
    #Cairo.scale(cr,r.width/256.0,r.height/256.0)

    if p.inMove
        #Cairo.translate(cr,(p.x_emove - p.x_move)*(256.0/r.width),
        #    (p.y_emove - p.y_move)*(256.0/r.height))
        Cairo.translate(cr,(p.x_emove - p.x_move),
            (p.y_emove - p.y_move))

    end

    x,y = p.get_data()
    clear_back(cr)
    Cairo.set_source_rgba(cr,p.col.r,p.col.g,p.col.b,p.col.a)
    p.draw_data(cr,p.ctm,x,y)
        
    if p.selection_index != []
        Cairo.set_source_rgba(cr,0.0,0.8,0.5,0.8)
        plot_marker(cr,p.ctm,x[p.selection_index],y[p.selection_index])
    end

    Cairo.restore(cr)

    if p.show_timing
        t = toq()
        Cairo.set_source_rgb(cr,0.0,0.0,0.0)        
        t1 = @sprintf("%010.6fs",t)
        Cairo.text(cr,0,18,t1)        
    end

    if p.inSelect
        Cairo.set_source_rgba(cr,0.0,0.8,0.5,0.5)
        Cairo.set_operator(cr,Cairo.OPERATOR_OVER)
        Cairo.rectangle(cr,p.x_sel,p.y_sel,p.x_esel-p.x_sel,p.y_esel-p.y_sel)
        Cairo.fill(cr)
    end
    Int32(false) # propagate the event further
end

function button_press(w::Ptr{Gtk.GObject},e::Ptr{Gtk.GdkEventButton},p::pgraph)
    e1 = unsafe_load(e)
    #display(e1)

    if e1.button == 3
        if !p.inSelect
            p.startSelect = true
            p.x_sel = trunc(e1.x)
            p.y_sel = trunc(e1.y)
        end
        p.selection_index = []
    end
    if e1.button == 1
        if !p.inMove
            p.startMove = true
            p.x_move = trunc(e1.x)
            p.y_move = trunc(e1.y)
        end
    end

    #CTM.push!(p.ctm)
    #CTM.inv(p.ctm)
    #x0,y0 = CTM.transform_single(p.ctm,e1.x,e1.y)
    #@printf("%f %f %f %f\n",e1.x,e1.y,x0,y0)        
    #CTM.pop!(p.ctm)        


    Int32(false)
end

function scroll(w::Ptr{Gtk.GObject},e::Ptr{Gtk.GdkEventScroll},p::pgraph)
    e1 = unsafe_load(e)

    x = trunc(e1.x)
    y = trunc(e1.y)

    r = Gtk.allocation(p.c)

    if e1.direction == 0
        #CTM.rezoom(p.ctm,x*(256.0/r.width),y*(256.0/r.height),0.90)
        CTM.rezoom(p.ctm,x,y,0.90)
    else
        #CTM.rezoom(p.ctm,x*(256.0/r.width),y*(256.0/r.height),1/0.90)
        CTM.rezoom(p.ctm,x,y,1/0.90)
    end
    reveal(p.c)
    #display(e1)
    Int32(false)
end

function button_release(w::Ptr{Gtk.GObject},e::Ptr{Gtk.GdkEventButton},p::pgraph)
    e1 = unsafe_load(e)
    #display(e1)
    if p.inSelect
        p.inSelect = false
        #@printf("end image")
        #@printf("%f %f %f %f\n",p.x_sel,p.y_sel,p.x_esel,p.y_esel)
        r = Gtk.allocation(p.c)
        CTM.push!(p.ctm)
        #CTM.scale!(p.ctm,(256.0/r.width),(256.0/r.height))
        CTM.inv(p.ctm)
        x0,y0 = CTM.transform_single(p.ctm,p.x_sel,p.y_sel)
        x1,y1 = CTM.transform_single(p.ctm,p.x_esel,p.y_esel)
        #@printf("%f %f %f %f\n",x0,y0,x1,y1)  
        if x0 > x1
            x0,x1 = x1,x0
        end
        if y0 > y1
            y0,y1 = y1,y0
        end

        x,y = p.get_data()
        t = test_box(x,y,x0,y0,x1,y1)
        p.selection_index = find(t)
        CTM.pop!(p.ctm)        
        reveal(p.c)
    end
    if p.inMove
        p.inMove = false
        #@printf("end move")

        r = Gtk.allocation(p.c)
    
        #CTM.translate!(p.ctm,(p.x_emove - p.x_move)*(256.0/r.width),
        #    (p.y_emove - p.y_move)*(256.0/r.height))        
        CTM.translate!(p.ctm,(p.x_emove - p.x_move),
            (p.y_emove - p.y_move))        

        reveal(p.c)
    end
    Int32(false)
end

function on_motion_event(w::Ptr{Gtk.GObject},e::Ptr{Gtk.GdkEventMotion},p::pgraph)
    e1 = unsafe_load(e)
    #display(e1)
    #display(typeof(e1.state))
    x = trunc(e1.x)
    y = trunc(e1.y)

    if (e1.state & UInt32(0x400)) != 0 # button 3
        #@printf("move %d %d %d\n",e1.x,e1.y,e1.state)
        if p.startSelect
            #@printf("copy image")
            p.inSelect = true
            p.startSelect = false
            p.x_esel = p.x_sel
            p.y_esel = p.y_sel
        else
            #@printf("move %d %d %d\n",e1.x,e1.y,e1.state)
            p.x_esel = x
            p.y_esel = y
            Gtk.reveal(p.c)
        end

    elseif (e1.state & UInt32(0x100)) != 0 # button 3
        #@printf("move %d %d %d\n",e1.x,e1.y,e1.state)
        if p.startMove
            #@printf("copy image")
            p.inMove = true
            p.startMove = false
            p.x_emove = p.x_move
            p.y_emove = p.y_move
        else
            #@printf("move %d %d %d\n",e1.x,e1.y,e1.state)
            p.x_emove = x
            p.y_emove = y
            Gtk.reveal(p.c)
        end
    end

    Int32(false)
end


