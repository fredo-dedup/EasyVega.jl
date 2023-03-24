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


# group 1
grp1 = begin  
    xscale = LinearScale(range="width",  domain=dat.x)
    yscale = LinearScale(range="height", domain=dat.y)

    lmark = LineMark( :x => xscale(dat.x), :y => yscale(dat.y))

    GroupMark( width=300, height=200, background="white",
        axes = [ xscale(orient="bottom"), yscale(orient="left") ], 
        marks= [ lmark ] 
    )
end

# group 2 
grp2 = begin 
    xscale = Band(range="width",  domain=dat.x)
    yscale = LinearScale(range="height", domain=dat.y)

    lmark = RectMark( 
        :x => xscale(dat.x), :width => xscale(band=1, offset=-1),
        :y => yscale(0), :y2 => yscale(dat.y),
        :fill => :orange
    )

    GroupMark( width=200, height=300, background="white",
        axes = [ xscale(orient="bottom"), yscale(orient="left") ], 
        marks= [ lmark ] 
    )
end

# group 3
grp3 = begin 
    xscale = BandScale(range="width",  domain=dat.x, domain_sort=true)
    yscale = BandScale(range="height", domain=dat.y, domain_sort=true)
    cscale = OrdinalScale(range="category", domain=dat.y)

    # In each facet, 
    #   - count the number of occurences ('aggregate' transform)
    #   - calculate angles for the pie ('pie' transform)
    fcdata = Data(source=dat,
        transform=[
            (type="pie", field=:y)
        ]
    )

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

    GroupMark( width=100, height=100, background="white",
        axes = [ xscale(orient="bottom"), yscale(orient="left") ], 
        marks= [ lmark ] 
    )
end




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