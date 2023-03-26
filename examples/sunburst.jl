# Adapted from https://vega.github.io/editor/#/examples/vega/sunburst

using EasyVega



tree = Data(
    url= "https://raw.githubusercontent.com/vega/vega-datasets/next/data/flare.json",
    transform= [
      ( type= "stratify", key= "id", parentKey= "parent" ),
      ( type= "partition",
        field= "size",
        sort= (field= "value",),
        size= [(signal= "2 * PI",), (signal= "width / 2",)],
        as= ["a0", "r0", "a1", "r1", "depth", "children"]
      )
])

color = OrdinalScale(domain = tree.depth, range_scheme= "tableau20")

rma = ArcMark(
    :x => (signal= "width / 2",),
    :y => (signal= "height / 2",),
    :fill => color(tree.depth),
    :tooltip => (signal= "datum.name + (datum.size ? ', ' + datum.size + ' bytes' : '')",),

    :update_startAngle => tree.a0,
    :update_endAngle => tree.a1,
    :update_innerRadius => tree.r0,
    :update_outerRadius => tree.r1,
    :update_stroke => "#222",
    :update_strokeWidth => 1,
    :update_strokeOpacity => 0.2,
    :update_zindex => 0,

    # on hover highlight perimeter in red
    :hover_stroke => "red",
    :hover_strokeWidth => 2,
    :hover_zindex => 1
)


VG( width=400, height=400, background= :white, 
  padding=5, #autosize="none",
  maks = [rma]
)


{
    "$schema": "https://vega.github.io/schema/vega/v5.json",
    "description": "An example of a space-fulling radial layout for hierarchical data.",
    "width": 600,
    "height": 600,
    "padding": 5,
    "autosize": "none",

    