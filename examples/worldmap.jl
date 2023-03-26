using EasyVega

tx = Signal("width / 2")
ty = Signal("height / 2")

# Projections define how the lat / longitude coordinates should be
# translated 2d coordinates
# see https://vega.github.io/vega/docs/projections/
proj = Projection(
    type=  "orthographic",
    scale= 220,
    rotate=  [0, 0, 0],
    center=  [40, 32],
    translate=  [(signal= tx,), (signal= ty,)]
)


# Graticules are the reference grid for maps
graticule = Data(
    transform= [ (type= "graticule", step= [15,15]) ]
    )
    
    gratm = ShapeMark(
        from_data = graticule,
        :strokeWidth => 2,
        :stroke => "#ddd",
        :fill => nothing,
        transform = [ (type="geoshape", projection= proj) ]
)

# pull up a world map from vega example data
world = Data(
    url= "https://raw.githubusercontent.com/vega/vega-datasets/next/data/world-110m.json",
    format= (
        type= "topojson",
        feature= "countries"
    )
)  

worldm = ShapeMark(
    from_data = world,
    :strokeWidth => 2,
    :stroke => "#999",
    :fill => "#efd",
    transform = [ (type="geoshape", projection= proj) ]
)

VG(width=300, height=300, background=:white, autosize="none",
    marks=[gratm, worldm]
)

