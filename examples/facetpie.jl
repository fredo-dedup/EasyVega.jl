using DataFrames
using EasyVega

# create dummy data
df = DataFrame(
    x=rand([1,2,3,4],200),
    y=rand([1,2,3,4],200),
    c=rand([:A,:B,:C],200),
)

dat = Data(values = df)

xscale = BandScale(range="width",  domain=dat.x, domain_sort=true)
yscale = BandScale(range="height", domain=dat.y, domain_sort=true)
cscale = OrdinalScale(range="category", domain=dat.c)

# Create facetting definition for the group mark
fc = Facet(groupby= [:x, :y], data=dat)

# In each facet, 
#   - count the number of occurences ('aggregate' transform)
#   - calculate angles for the pie ('pie' transform)
fcdata = Data(source=fc,
    transform=[
        (type="aggregate", groupby=[:c], ops=["count"], as=[:count], fields=[:x])
        (type="pie", field=:count)
    ]
)

# let's add some controls to change the chart appearance
sig1 = Signal(value=15, bind=(input=:range, min=0, max=50, step=1))
sig2 = Signal(value=30, bind=(input=:range, min=0, max=200, step=1))

# pie chart for each facet
rmark = ArcMark(
    encode_enter=(
        x= Signal("bandwidth('$xscale')/2"),
        y= Signal("bandwidth('$xscale')/2"),
        startAngle= fcdata.startAngle,
        endAngle= fcdata.endAngle,
        stroke= :black, 
        fill = cscale(fcdata.c)),
    encode_update=(
        innerRadius= sig1,
        outerRadius= sig2,
    )        
)

gm = GroupMark(
    encode_enter_x = xscale(fc.x),
    encode_enter_y = yscale(fc.y),
    marks=[rmark]
)

VG(width=400, height=400, padding=20, background= "#fed", 
    # force signals to be a root level (because they are linked to a control)
    signals=[sig1, sig2],
    axes = [ 
        xscale(orient="bottom", grid=true, bandPosition=1, title="x"), 
        yscale(orient="left", grid=true, bandPosition=1, title="y") ],
    marks= [ gm ],
    # place a legend for the 'c' field
    legends=[ (fill = cscale, title="type", titleFontSize=15) ] 
)