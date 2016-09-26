#======================================================================================#
# PageUI
# Page
#======================================================================================#
# MakeUserInterface()
# ImageFromBlob()
# makeWindow()
# DestroyWindow()
#======================================================================================#

type PageUI
         window::Any   # Window
         canvas::Any   # Canvas that page is drawn on
        omnibar::Any   # URL of page
            tab::Any
       scroller::Any
end
#=---------------------------------=#
type Page
       # content::Dict  # dictionary of elements IE. DOM
           node::Array # First node in a tree-like data structure representing all elements on page
            DOM::Dict        # Link to dictionary counterpart
            url::Any   # URL of page
         events::EventTypes
      focusNode::Any
      hoverNode::Any
         styles::Dict
           head::Any
             ui::PageUI   # Window
             Page() = new()
end
#=---------------------------------=#
#Page_request = ""
# TODO: rewrite!
# ======================================================================================
# add tab and initiate session...
# CALLED FROM:
# ======================================================================================

function MakeUserInterface(win, doc)   # win, notebook
    # SEE: https://github.com/tknopp/Julietta.jl/blob/master/src/maintoolbar.jl

    a = @Entry()  # a widget for entering text
    setproperty!(a, :margin, 5)
    setproperty!(a, :text, doc.url)
    #setproperty!(document.ui.omnibar, :text, Page_request)

    canvas = @Canvas(100,2800)
    g = @Grid() # Maybe @Box(:v) instead

    scroller = Gtk.@ScrolledWindow(canvas);
#vadjustment() = ccall((:gtk_get_vadjustment),Ptr{GObject}))
#maximize(win::GtkWindow) = ccall((:gtk_window_maximize,libgtk),Void,(Ptr{GObject},),win)
#a = getproperty(scroller, :vadjustment, true)
#println("Scrolling... ",a) #window.handle.get_vadjustment()


    g[2,1] = a    # Cartesian coordinates, g[x,y] hexpand=FALSE
    g[1:2,2] = scroller  # spans both columns
    setproperty!(canvas, :expand, true)
    setproperty!(g, :column_homogeneous, false) # setproperty!(g,:homogeoneous,true) for gtk2
    setproperty!(g, :column_spacing, 15)  # introduce a 15-pixel gap between columns
    result = match(r"(\w+:\/\/)([-a-zA-Z0-9.]+)", doc.url)
#----------------------------------------
# Temporary image while I figure out how to fix the icon problem that was
# created with julia 0.5 changes
label = @Label(doc.head["title"]) # result[2]
#println(typeof(@__FILE__()))
  f = split(@__FILE__(),r"src/")
  imagePath = string(f[1], "src/data/close.png")
# Produces: /path/to/.julia/v0.5/NaquadahBrowser/src/data/close.png

#...............................................................................
# WARNING! the images library broke on the 0.5 release so this is going to
# be messy until they get it fixed or I find another solution.
     closeImg = load(imagePath)
     data = convert(Array, closeImg.data)   # say, dat is a Matrix of size (256, 256)
    # new_dat = Images.imresize(data, (25,25))
    # pageIcon = @Image(@Pixbuf(data=img, has_alpha=true))

    imClose = @Image(@Pixbuf(data=closeImg.data, has_alpha=true))
    closeButton = @Button()
    setproperty!(closeButton, :margin, 3)
    setproperty!(closeButton, :padding, 1)
    push!(closeButton,imClose)
    #----------------------------------------
    # Outline for close tab event!
    #----------------------------------------
    #  b = @Button("Press me")
    #  win = @Window(b, "Callbacks")
    #  id = signal_connect(b, "clicked") do widget
    #      println("Button was clicked!")
    #  end

    # AND: signal_handler_disconnect(b, id)
    #----------------------------------------

# "https://assets-cdn.github.com/favicon.ico"
# "http://travis.net16.net/GitHub.png"
# "Browser/data/Tonajli.png"
# https://cairographics.org/manual/cairo-Image-Surfaces.html

#img1 = load("Browser/data/octocat.png")
    #println(img1)
    img = ImageFromBlob("http://travis.net16.net/GitHub.png")
    #println("My Blob...",img.properties)
    # println("colorspace...",img.properties.colorspace)
    # println("spatialorder...",img.properties.spatialorder)
#GdkPixbuf(data=img,has_alpha=true)
#==#
# image = CairoRGBSurface(img.data, 26, 26); img.data,
# image = CairoARGBSurface(26, 26);
# println(image)
#println("My Blob...",img.properties)

#### https://www.ossramblings.com/loading_jpg_into_cairo_surface_python
#    pixbuf = gtk.gdk.pixbuf_new_from_file(filename)
#    x = pixbuf.get_width()
#    y = pixbuf.get_height()
#    ''' create a new cairo surface to place the image on '''
#    surface = cairo.ImageSurface(0,x,y)
#    ''' create a context to the new surface '''
#    ct = cairo.Context(surface)
#    ''' create a GDK formatted Cairo context to the new Cairo native context '''
#    ct2 = gtk.gdk.CairoContext(ct)
#    ''' draw from the pixbuf to the new surface '''
#  ct2.set_source_pixbuf(pixbuf,0,0)
#  ct2.paint()
#    ''' surface now contains the image in a Cairo surface '''

    # b = readall(get("http://travis.net16.net/octocat.jpg"; timeout = 5.0))
    # blob = convert(Vector{UInt8}, b)
    # img = readblob(blob)
    # IObuffer():  http://stackoverflow.com/questions/24229984/reading-data-from-url
    dat = convert(Array, img.data)   # say, dat is a Matrix of size (256, 256)
    new_dat = Images.imresize(dat, (25,25))
    # pageIcon = @Image(@Pixbuf(data=new_dat, has_alpha=true))

#     @Pixbuf(data=dat, has_alpha=true)
# set_source_rgba(ctx, r::Real, g::Real, b::Real, a::Real) =
# image(ctx, s::CairoSurface, x, y, w, h)

    hbox = @Box(:h)
    # push!(hbox,pageIcon)
    push!(hbox,label)
    push!(hbox,closeButton)
    push!(win.notebook, g, hbox)
    showall(scroller)
    # showall(pageIcon)
    # showall(imClose)
    showall(closeButton)
    showall(label)
    showall(win.handle)
#----------------------------------------
    push!(win.tabs,PageUI(win.handle,canvas,a,label,scroller))
    handler_id = signal_connect(a, "activate")do object
        # println("From event")
        Page_request = getproperty(object,:text,AbstractString)
        FetchPage(Page_request)
    end
    doc.ui = win.tabs[end]
    win.activeTab = win.tabs[end]
end
# ======================================================================================
# FIX: Attempt to Create an image from blob
# CALLED FROM:
# ======================================================================================
function ImageFromBlob(URL)
    fetch = get(URL; timeout = 5.0)
    # println(fetch)

    data = readall(fetch)
    blob = convert( Vector{UInt8}, data )
    img = readblob(blob)
    # println(img.data)
    return img
end
