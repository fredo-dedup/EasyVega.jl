# Adapted from https://vega.github.io/editor/#/examples/vega/tree-layout

using EasyVega


# some controls on the tree appearance
labels = Signal(
    value= true,
    bind= (input="checkbox",)
)

layout = Signal(
    value= "tidy",
    bind=(input="radio", options= ["tidy", "cluster"])
)

linkshape = Signal(
    value= "diagonal",
    bind= (input="radio", options= ["line", "curve", "diagonal", "orthogonal"])
)

separation = Signal(
    value= false,
    bind= (input="checkbox",)
)


# take the data, stratify it and generate tree
tree = Data(
    url= "https://raw.githubusercontent.com/vega/vega-datasets/next/data/flare.json",
    transform= [
      ( type= "stratify", key= "id", parentKey= "parent" ),
      ( type= "tree",
        method= (signal= layout,),
        size= [(signal= "height",), (signal= "width - 100",)],
        separation= (signal= separation,),
        as= ["y", "x", "depth", "children"]
      )
])

# create link paths from tree data
links = Data(
    source= tree,
    transform= [
      (type= "treelinks",),
      (type= "linkpath", orient= "horizontal", shape= (signal= linkshape,) ),
    ]  
)


color = OrdinalScale(domain = tree.depth, 
    range_scheme= "magma", zero=true)


# text marks
tma = TextMark(
    :text => tree.name,
    :fontSize => 9,
    :baseline => "middle",

    :update_x => tree.x,
    :update_y => tree.y,
    :update_dx => (signal= "datum.children ? -7 : 7",),
    :update_align => (signal= "datum.children ? 'right' : 'left'",),
    :update_opacity => (signal= "$labels ? 1 : 0",)
)    

# dots for graph vertices
sma = SymbolMark(
    :size => 100,
    :stroke => "#fff",

    :update_x => tree.x,
    :update_y => tree.y,
    :update_fill => color(tree.depth),
)

# paths for graph edges
pma = PathMark(
    :update_path => links.path,
    :update_stroke => "#ccc",
)


# EasyVega is not picking up the use of signals in expressions
#  (for example the labels signal used in the TextMark to show/hide labels)
# for this reason, they are explicitly mentionned in VG. 
VG( width=800, height=1600, background= :white, 
  padding=10, autosize="none",
  signals=[labels, layout, linkshape, separation],
  marks = [tma, sma, pma]
)

