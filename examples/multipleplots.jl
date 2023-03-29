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

    # note that width and height have to be set in order for the group 
    #  to render correctly
    GroupMark( 
        axes = [ xscale(orient="bottom"), yscale(orient="left") ], 
        marks= [ lmark ],
		:width => (signal="width",),
		:height => (signal="height",), 
    )
end

# group 2 
grp2 = begin 
    xscale = BandScale(range="width",  domain=dat.x)
    yscale = LinearScale(range="height", domain=dat.y)

    lmark = RectMark( 
        :x => xscale(dat.x), :width => xscale(band=1, offset=-1),
        :y => yscale(0), :y2 => yscale(dat.y),
        :fill => :orange
    )

    GroupMark( 
        axes = [ xscale(orient="bottom"), yscale(orient="left") ], 
        marks= [ lmark ] ,
		:width => (signal="width",),
		:height => (signal="height",), 
    )
end

# group 3
grp3 = begin 
    # translate y value to angles for the pie chart
    fcdata = Data(source=dat,
        transform=[ (type="pie", field=:y) ] )

    rmark = ArcMark(
		:x => (signal="width/2",),
		:y => (signal="height/2",), 
        :startAngle => fcdata.startAngle,
        :endAngle => fcdata.endAngle,
        :stroke => :black, 
        :fill  => :lightgreen,
        :outerRadius => 100,
    )

    GroupMark(  
        marks= [ rmark ] 
    )
end


VG(width=200, height=200, padding=20, background= "white", 
	layout= (columns=2, padding=20),
    marks= [ grp1, grp2, grp3 ],
)

