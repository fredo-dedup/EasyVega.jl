using EasyVega

# create dummy data and use the 'stack' transform to generate
#  the coordinates (y0, y1) for the stacked objects
dat = Data(
    values = [
        (x= 0, y= 28, c='A'), (x= 0, y= 20, c='B'),
        (x= 1, y= 43, c='A'), (x= 1, y= 35, c='B'),
        (x= 2, y= 81, c='A'), (x= 2, y= 10, c='B'),
        (x= 3, y= 19, c='A'), (x= 3, y= 15, c='B'),
        (x= 4, y= 52, c='A'), (x= 4, y= 48, c='B'),
        (x= 5, y= 24, c='A'), (x= 5, y= 28, c='B'),
      ],
    transform=[
        (type="stack", groupby=[:x], sort_field=:c, field=:y)
    ]
)

xscale = BandScale(range="width",    domain=dat.x)
yscale = LinearScale(range="height", domain=dat.y1, nice=true, zero=true)
cscale = OrdinalScale(range="category", domain=dat.c)

# Rect mark, with some reactivity on hover
rmark = RectMark(
    :x                  => xscale(dat.x),
    :width              => xscale(band=1, offset=-1),
    :y                  => yscale(dat.y0),
    :y2                 => yscale(dat.y1),
    :fill               => cscale(dat.c),
    :update_fillOpacity => 1,
    :hover_fillOpacity  => 0.5,
)

VG(width=400, height=300, padding=30, background= "#fed", 
    axes = [ 
        xscale(orient="bottom", offset=10), 
        yscale(orient="left", offset=10) 
    ],
    marks= [ rmark ] )
