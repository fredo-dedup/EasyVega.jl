using EasyVega

# create a Data element with dummy numbers
dat = Data(
    values = [
        (x= 0, y= 28), 
        (x= 1, y= 43), 
        (x= 2, y= 81), 
        (x= 3, y= 19), 
        (x= 4, y= 52), 
      ]
)

# create the horizontal scale, mapping the width of the plotting area to
#  the extent of the 'x' field values in Data element 'dat'
xscale = LinearScale(range="width",  domain=dat.x)
# same for the vertical scale
yscale = LinearScale(range="height", domain=dat.y)

# create the mark, of type 'line', mapping the x of the mark to 
#  the scaled field 'x' of data and the y to the scaled 'y' field of data
lmark = LineMark(
    encode_enter=(
        x= xscale(dat.x),
        y= yscale(dat.y),
    ),
)

# wrap up everything and render with the VG() function
VG(
    width=300, height=200, background="white",
    # add axes at the bottom and left side of the graph
    axes = [ xscale(orient="bottom"), yscale(orient="left") ], 
    # specify the mark to show 
    marks= [ lmark ] 
)
