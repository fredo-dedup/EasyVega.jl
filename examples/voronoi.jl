using DataFrames
using EasyVega

# Data with dummy color categories
dat = Data( values= DataFrame(color= rand("ABCD", 30)) )

cscale = OrdinalScale(range="category", 
    domain=dat.color, domain_sort= true)

# create points, with forces for collision avoidance, and attracted
# to plot center 
pointmark = SymbolMark(
    clip=true, zindex=1,
    :size => 10, :fill => :black,
    :cellColor => cscale(dat.color),
    transform=[
        (
            type= "force",
            static= false,
            forces= [
              (force= "collide", iterations= 2, radius=25),
              (force= "center", x= 200, y= 200),
            ]
          )
      
    ]
)

# Show voronoi cells based point marks
vormark = PathMark(from_data=pointmark,
    clip= true, zindex=0,
    :update_strokeWidth => 1,
    :update_strokeOpacity => 0.5, 
    :update_stroke => :black,
    :fill => (signal= "datum.cellColor",),
    transform= [( type="voronoi", 
        x= "datum.x", y="datum.y",
        size=[(signal= "width",), (signal= "height",)]
    )]
)


vgspec = VG(width=400, height=400, background=:white, padding=10,
    legends=[ (fill = cscale, title="color", titleFontSize=15) ], 
    marks= [pointmark, vormark ]
)