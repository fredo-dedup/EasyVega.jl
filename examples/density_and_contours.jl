# generate values from a distribution
using Distributions, LinearAlgebra
using DataFrames

Σ = let X = randn(2,2); X * X' + I; end
d = MvNormal([1,1], Σ)
draws = rand(d, 100)
df = DataFrame(x = draws[1,:], y=draws[2,:])


# create Data object
dat = Data( values= df )

xscale = LinearScale(range="width",  domain=dat.x, padding= 20)
yscale = LinearScale(range="height", domain=dat.y, padding= 20)

# create a Data object derived from 'dat' to calculate the density
density = Data(source=dat,
    transform= [( 
        type= "kde2d",
        x_expr = "scale('$xscale', datum.x)",  # convert to pixel coordinates
        y_expr = "scale('$yscale', datum.y)",
        size= [(signal= "width",), (signal= "height",)], # output size
        as= "grid"
    )]
)

# create a Data object, derived from 'density', that will generate 
#  the iso contours 
contours = Data(source=density,
    transform= [( type= "isocontour",
        field= "grid",
        levels= 6
    )]
)


# this mark shows a dot for each sample
pointmark = SymbolMark(
    :x => xscale(dat.x),
    :y => yscale(dat.y),
    :size => 4,
)

# this mark plots an image, based on the density data
# the "heatmap" transform translates the density grid to an image
# (by default, it is the image opacity that varies with density, but 
#    color can be used as well)
densmark = ImageMark(from_data=density,
    :x => 0, 
    :y => 0, 
    :width => (signal="width",), 
    :height => (signal="height",),
    :aspect => false,
    transform= [
        (type="heatmap", field="datum.grid", color= :lightblue)
    ]
)

# this mark shows the density contours
contourmark = PathMark(from_data=contours,
    clip= true,
    :strokeWidth => 1,
    :strokeOpacity => 0.5, 
    :stroke => :blue,
    transform= [
        (type="geopath", field="datum.contour")
    ]
)


vgspec = VG(width=400, height=400, background=:white, padding=10,
    axes=[xscale(orient="bottom"), yscale(orient="left")],
    marks= [pointmark, densmark, contourmark]
)