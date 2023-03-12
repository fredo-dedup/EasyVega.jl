using DataFrames
N = 100
tb = DataFrame(x=randn(N), y=randn(N), a=rand("ABC", N))


using EasyVega


###########

dat2 = Data(values=tb)
xscale = LinearScale(range="width",     domain=dat2.x)
yscale = LinearScale(range="height",    domain=dat2.y, nice=true, zero=true)
cscale = OrdinalScale(range="category", domain=dat2.a)

smark = SymbolMark(shape="circle", 
    encode_enter=(xc=xscale(dat2.x), yc=yscale(dat2.y), 
    fill=cscale(dat2.a), fillOpacity_value=0.2, 
    stroke=cscale(dat2.a), strokeOpacity_value=1,
    size_value=100)
)

ttt = VG(width=400, height=300, padding=20, background= "#fed",
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [ smark ])

lmark = LineMark(encode_enter=(
    x=xscale(dat2.x), 
    y=yscale(dat2.y), 
))

ttt = VG(width=400, height=300, padding=20, background= "#fed",
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [ smark, lmark ]
)

ttt = VG(width=400, height=300, padding=20, background= "#fed",
    # axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    layout= (columns = 2, padding=20),
    marks= [ GroupMark(marks=[smark]), GroupMark(marks=[lmark]) ]
)


###########

dat = Data(
    values = [
        (x= 0, y= 28, c=0), (x= 0, y= 20, c=1),
        (x= 1, y= 43, c=0), (x= 1, y= 35, c=1),
        (x= 2, y= 81, c=0), (x= 2, y= 10, c=1),
        (x= 3, y= 19, c=0), (x= 3, y= 15, c=1),
        (x= 4, y= 52, c=0), (x= 4, y= 48, c=1),
        (x= 5, y= 24, c=0), (x= 5, y= 28, c=1),
        (x= 6, y= 87, c=0), (x= 6, y= 66, c=1),
        (x= 7, y= 17, c=0), (x= 7, y= 27, c=1),
        (x= 8, y= 68, c=0), (x= 8, y= 16, c=1),
        (x= 9, y= 49, c=0), (x= 9, y= 25, c=1)
      ],
    transform=[
        (type="stack", groupby=[:x], sort_field=:c, field=:y)
    ]
)

xscale = BandScale(range="width",    domain=dat.x)
yscale = LinearScale(range="height", domain=dat.y1, nice=true, zero=true)
cscale = OrdinalScale(range="category", domain=dat.c)

rmark = RectMark(from_data= dat,
    encode_enter=(
        x= xscale(dat.x),
        width= xscale(band=1, offset=-1),
        y= yscale(dat.y0),
        y2 = yscale(dat.y1),
        fill = cscale(dat.c)
    ),
    encode_update=(
        fillOpacity_value = 1,
    ),
    encode_hover=(
        fillOpacity_value=0.5,
))

ttt = VG(width=400, height=300, padding=20, background= "#fed", #:white,
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [ rmark ] )

###########

dat = Data(
    values = [
        (x= 0, y= 28, c=0), (x= 0, y= 20, c=1),
        (x= 1, y= 43, c=0), (x= 1, y= 35, c=1),
        (x= 2, y= 81, c=0), (x= 2, y= 10, c=1),
        (x= 3, y= 19, c=0), (x= 3, y= 15, c=1),
        (x= 4, y= 52, c=0), (x= 4, y= 48, c=1),
        (x= 5, y= 24, c=0), (x= 5, y= 28, c=1),
        (x= 6, y= 87, c=0), (x= 6, y= 66, c=1),
        (x= 7, y= 17, c=0), (x= 7, y= 27, c=1),
        (x= 8, y= 68, c=0), (x= 8, y= 16, c=1),
        (x= 9, y= 49, c=0), (x= 9, y= 25, c=1)
      ],
    transform=[
        (type="stack", groupby=[:x], sort_field=:c, field=:y),
        (type="pie", field=:x)
    ]
)

xscale = BandScale(range="width",    domain=dat.x)
yscale = LinearScale(range="height", domain=dat.y1, nice=true, zero=true)
cscale = OrdinalScale(range="category", domain=dat.c)
rscale = SqrtScale(domain=dat.y1, zero=true, range= [0,120])

rmark = ArcMark(from_data= dat,
    encode_enter=(
        x= (field_group="width", mult=0.5),
        y= (field_group="height", mult=0.5),
        startAngle_field= :startAngle,
        endAngle_field= :endAngle,
        innerRadius_value= 20,
        outerRadius= rscale(dat.y1),
        stroke_value= :black 
    ),
    encode_update=(
        fill_value = cscale(dat.c),
    ),
    encode_hover=(
        fill_value = :pink,
    ))

ttt = VG(width=400, height=300, padding=20, background= "#ddb", #:white,
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [ rmark ] )

################

df = DataFrame(
    x=rand([1,2,3,4],200),
    y=rand([1,2,3,4],200),
    c=rand([:A,:B,:C],200),
)

dat = Data(values = df)

xscale = BandScale(range="width",  domain=dat.x, domain_sort=true)
yscale = BandScale(range="height", domain=dat.y, domain_sort=true)
cscale = OrdinalScale(range="category", domain=dat.c)

fc = Facet(groupby= [:x, :y], data=dat)

minidat = Data(source=fc,
    transform=[
        (type="aggregate", groupby=[:c], ops=["count"], as=[:count], fields=[:x])
        (type="pie", field=:count)
    ]
)

sig1 = Signal(value=15, bind=(input=:range, min=0, max=50, step=1))
sig2 = Signal(value=30, bind=(input=:range, min=0, max=200, step=1))

rmark = ArcMark(from_data=minidat,  # TODO: needs to be specified, otherwise takes facet, improve
    encode_enter=(
        x_signal= "bandwidth('$xscale')/2",
        y_signal= "bandwidth('$xscale')/2",
        startAngle= minidat.startAngle,
        endAngle= minidat.endAngle,
        stroke_value= :black, 
        fill = cscale(minidat.c)),
    encode_update=(
        innerRadius_signal= sig1,
        outerRadius_signal= sig2,
    )        
)
rmark.trie

gm = GroupMark(
    encode_enter_x = xscale(fc.x),
    encode_enter_y = yscale(fc.y),
    marks=[rmark]
)

ttt = VG(width=400, height=400, padding=20, background= "#fed", 
    signals=[sig1, sig2],
    axes = [ 
        xscale(orient="bottom", grid=true, bandPosition=1, title="x"), 
        yscale(orient="left", grid=true, bandPosition=1, title="y") ],
    marks= [ gm ],
    legends=[ (fill = cscale, title="type", titleFontSize=15) ] 
)

io = IOBuffer()
EasyVega.toJSON(io,ttt.trie)
clipboard(String(take!(io)))

#################################################"

tb = DataFrame(t=0:0.1:10)
tb.x = sin.(tb.t) ./ (1 .+ tb.t/10)
tb.y = cos.(tb.t) ./ (1 .+ tb.t/10)

dat = Data(values=tb)
xsc = LinearScale(range="width", domain=dat.x)
ysc = LinearScale(range="height", domain=dat.y)
cscale = OrdinalScale(range="category", domain=dat.c)

lm = LineMark(encode_enter=(x=xsc(dat.x), y=ysc(dat.y)))

dat2 = Data(source=dat,
    transform=[
        (type="identifier", as="id"),
        (type="formula", expr="datum.id + 1", as="id2"),
    ]
)

dat3 = Data(source=dat2,
    transform=[
        (type="lookup", from=dat2, key="id2", fields=["id"], values=["x","y"], as=["x2","y2"]),
        (type="formula", expr="datum.x2 - datum.x", as="dx"),
        (type="formula", expr="datum.y2 - datum.y", as="dy"),
        (type="formula", expr="0.1/sqrt(datum.dx*datum.dx+datum.dy*datum.dy)", as="factor")
        # (type="filter", expr="(id % 1) == 0"),
    ]
)


rm = RuleMark(from_data=dat3,
    encode_enter=(
        x=xsc(field=:x), 
        y=ysc(field=:y),
        x2=xsc(signal="datum.x+datum.dy*datum.factor"), 
        y2=ysc(signal="datum.y-datum.dx*datum.factor"),
    stroke_value=:green
    # x2=xsc(dat.x, offset=10), y2=ysc(dat.y, offset=10),
))

ttt = VG(width=400, height=400, padding=20, background= "#fed", 
    axes = [ 
        xsc(orient="bottom", grid=true, title="x"), 
        ysc(orient="left", grid=true, title="y") 
    ],
    marks= [ lm, rm],
)

io = IOBuffer()
EasyVega.toJSON(io,ttt.trie)
clipboard(String(take!(io)))

# FIXME: order is important for data !!!



###############
using CSV, Glob


flist = readdir("/home/fred/logs/temtop")
flist = flist[ match.(r"^\d{8}\.csv$", flist) .!= nothing ]
histo = DataFrame()
for fn in flist
    tmp = CSV.File(joinpath("/home/fred/logs/temtop",fn), 
        dateformat="yyyy-mm-dd HH:MM:SS", normalizenames=true
        ) |> DataFrame
    append!(histo, tmp)
end
histo
describe(histo)

histdat = Data(values=sort!(histo, :DATE))

tscale = TimeScale(range="width",   domain=histdat.DATE)
yscale = LinearScale(range="height",  domain=histdat.PM2_5, nice=true, zero=true)
y2scale = LinearScale(range="height",  domain=histdat.CO2, nice=true, zero=true)

lmark = LineMark(encode_enter=(
    x=tscale(histdat.DATE), 
    y=yscale(histdat.PM2_5), 
    stroke_value="#d666")
)

lmark2 = LineMark(encode_enter=(
    x=tscale(histdat.DATE), 
    y=y2scale(histdat.CO2), 
    stroke_value="#66d")
)


######

function mkMark(var)
    tsc = TimeScale(range="width", domain=histdat.DATE)
    ysc = LinearScale(range="height",  domain=var, nice=true)
   
    lmark = LineMark(encode_enter=(
        x=tsc(histdat.DATE), 
        y=ysc(var)
    ))

    GroupMark(
        axes = [ tsc(orient="top", grid=true), 
            ysc(orient="left", grid=true)],    
        marks = [lmark]
    )
end


VG(width=800, height=300, padding=20, background= "#fed",
    layout=(columns=1,padding=20),
    marks= [ 
        mkMark(histdat.TEMP),
        mkMark(histdat.CO2) 
    ]
)

VG(width=800, height=300, padding=20, background= "#fed",
    layout=(columns=1,padding=20),
    marks= [ 
        mkMark(histdat.TEMP),
        mkMark(histdat.PM2_5) 
    ]
)




#################

dat = Data(
    values = [
        (x= 0, y= 28, c=0), (x= 0, y= 20, c=1),
        (x= 1, y= 43, c=0), (x= 1, y= 35, c=1),
        (x= 2, y= 81, c=0), (x= 2, y= 10, c=1),
        (x= 3, y= 19, c=0), (x= 3, y= 15, c=1),
        (x= 4, y= 52, c=0), (x= 4, y= 48, c=1),
        (x= 5, y= 24, c=0), (x= 5, y= 28, c=1),
        (x= 6, y= 87, c=0), (x= 6, y= 66, c=1),
        (x= 7, y= 17, c=0), (x= 7, y= 27, c=1),
        (x= 8, y= 68, c=0), (x= 8, y= 16, c=1),
        (x= 9, y= 49, c=0), (x= 9, y= 25, c=1)
      ],
)

xscale = PointScale(range="width",    domain=dat.x)
yscale = LinearScale(range="height",   domain=dat.y, nice=true, zero=true)
cscale = OrdinalScale(range="category", domain=dat.c)

series = Facet(groupby=dat.c)

lmark = LineMark(
    encode_enter_x = xscale(series.x),
    encode_enter_y = yscale(series.y),
    encode_enter_stroke = cscale(series.c)
)

gm = GroupMark(marks=[lmark])

ttt = VG(width=500, height=200, padding=20, background= "#ddb",
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [ gm ] 
)

#################

dat = Data(
    values = [
        (x= 0, y= 28, c=0), (x= 0, y= 20, c=1),
        (x= 1, y= 43, c=0), (x= 1, y= 35, c=1),
        (x= 2, y= 81, c=0), (x= 2, y= 10, c=1),
        (x= 3, y= 19, c=0), (x= 3, y= 15, c=1),
        (x= 4, y= 52, c=0), (x= 4, y= 48, c=1),
        (x= 5, y= 24, c=0), (x= 5, y= 28, c=1),
        (x= 6, y= 87, c=0), (x= 6, y= 66, c=1),
        (x= 7, y= 17, c=0), (x= 7, y= 27, c=1),
        (x= 8, y= 68, c=0), (x= 8, y= 16, c=1),
        (x= 9, y= 49, c=0), (x= 9, y= 25, c=1)
        ],
)

xscale = BandScale(range="width", domain=dat.x)
yscale = LinearScale(range="height",   domain=dat.y, nice=true, zero=true)
cscale = OrdinalScale(range="category", domain=dat.c)

series = Facet(groupby=dat.x)
wsig = Signal(update="[0,0.9*bandwidth('$xscale')]")
ixscale = BandScale(range_signal=wsig,  
    domain = series.c, paddingOuter=0.1)

bars = RectMark(encode_enter=(
    x = ixscale(series.c),
    width = ixscale(band=1.),
    y = yscale(value=0),
    y2 = yscale(series.y),
    fill = cscale(series.c)
))

gm = GroupMark(
    encode_enter_x = xscale(series.x),
    # axes= [ ixscale(orient="top") ],
    marks=[bars]
)

ttt = VG(width=500, height=200, padding=20, background= "#fed",
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [ gm ] 
)


gm1 = GroupMark(
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    encode_enter_x = xscale(series.x),
    marks=[bars]
)


bars2 = RectMark(encode_enter=(
    x = ixscale(series.c),
    width = ixscale(band=1.),
    y = yscale(value=0),
    y2 = yscale(series.y),
    fill = cscale(series.c)
))

gm2 = GroupMark(
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    encode_enter_x = xscale(series.x),
    marks=[bars2]
)


ttt = VG(width=500, height=200, padding=20, background= "#fed",
    layout=(columns=1,),
    marks= [ gm ] 
)



################

using InteractiveUtils
io = IOBuffer()
EasyVega.toJSON(io,ttt.trie)
clipboard(String(take!(io)))


################


io = IOBuffer()
EasyVega.toJSON(io,ttt.trie)

String(take!(io))
