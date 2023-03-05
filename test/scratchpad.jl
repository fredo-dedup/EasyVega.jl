using DataFrames
N = 100
tb = DataFrame(x=randn(N), y=randn(N), a=rand("ABC", N))


using EasyVega



18.8 + 
50 +
43.38 +

8 +
9 +
8.95 +

9 +
8.94 +
20 + 

7.7 +
8 + 
50 +

11.30 +
8 +

5.50 +
7 +
9 +
8.9 +
7.5



# idea : evaluate variables only at rendering 

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

ttt = VG(width=400, height=300, padding=20, background= "#ccc",
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [ smark ])

lmark = LineMark(encode_enter=(
    x=xscale(dat2.x), 
    y=yscale(dat2.y), 
))

ttt = VG(width=400, height=300, padding=20, background= "#ccc",
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [ smark, lmark ]
)

ttt = VG(width=400, height=300, padding=20, background= "#ccc",
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

ttt = VG(width=400, height=300, padding=20, background= "#ddb", #:white,
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


###########
using CSV

io = IOBuffer( """
DATE,PM25,CO2,TEMP,HUMI,PM25MAX,PM25MIN,CO2MAX,CO2MIN,TEMPMAX,TEMPMIN,HUMIMAX,HUMIMIN,TEMPUNIT
2023-02-18 13:00:00,1.6,720,18,51,2.1,1.3,1075,653,19,17,58,49,C
2023-02-18 14:00:00,3.6,676,19,49,7.0,1.2,1075,601,20,17,58,47,C
2023-02-18 15:00:00,2.4,819,20,49,7.0,1.2,1936,601,20,17,58,47,C
2023-02-18 16:00:00,1.6,603,20,46,7.0,1.0,1936,576,20,17,58,46,C
2023-02-18 17:00:00,1.7,623,20,46,7.0,1.0,1936,565,20,17,58,46,C
2023-02-18 18:00:00,1.6,544,20,46,7.0,1.0,1936,512,20,17,58,46,C
2023-02-18 19:00:00,1.8,532,19,47,7.0,1.0,1936,497,20,17,58,46,C
2023-02-18 20:00:00,2.5,528,19,47,7.0,1.0,1936,497,20,17,58,46,C
2023-02-18 21:00:00,3.0,521,19,47,7.0,1.0,1936,495,20,17,58,46,C
2023-02-18 22:00:00,3.3,624,19,50,7.0,1.0,1936,495,20,17,58,46,C
2023-02-18 23:00:00,3.8,627,19,52,7.0,1.0,1936,495,20,17,58,46,C
2023-02-19 00:00:00,3.1,544,19,50,7.0,1.0,1936,495,20,17,58,46,C
2023-02-19 01:00:00,2.7,607,19,50,3.4,2.1,670,571,19,18,51,50,C
2023-02-19 02:00:00,2.5,581,18,50,3.4,2.0,670,571,19,18,51,50,C
2023-02-19 03:00:00,2.3,575,18,50,3.4,1.8,670,571,19,18,51,50,C
2023-02-19 04:00:00,2.0,574,18,51,3.4,1.4,670,571,19,18,51,50,C
2023-02-19 05:00:00,1.7,571,18,51,3.4,1.2,670,569,19,18,51,50,C
2023-02-19 06:00:00,1.4,568,18,50,3.4,0.9,670,565,19,18,51,50,C
2023-02-19 07:00:00,1.2,565,18,50,3.4,0.9,670,561,19,18,51,50,C
2023-02-19 08:00:00,1.2,577,18,50,3.4,0.8,670,561,19,18,51,50,C
2023-02-19 09:00:00,1.7,622,18,50,3.4,0.8,709,561,19,18,52,50,C
2023-02-19 10:00:00,2.1,694,18,51,3.4,0.8,772,561,19,18,52,50,C
2023-02-19 11:00:00,2.1,741,19,50,3.4,0.8,814,561,19,18,52,49,C
2023-02-19 12:00:00,2.1,659,19,48,3.4,0.8,814,561,19,18,52,48,C
2023-02-19 13:00:00,3.6,641,19,49,5.0,0.8,814,561,19,18,52,47,C
2023-02-19 14:00:00,3.8,849,19,52,5.0,0.8,924,561,19,18,53,47,C
2023-02-19 15:00:00,3.8,831,19,51,5.0,0.8,916,561,19,18,54,47,C
2023-02-19 16:00:00,4.3,763,19,51,8.5,0.8,837,561,19,18,54,47,C
2023-02-19 17:00:00,4.4,719,19,49,8.5,0.8,814,561,19,18,54,47,C
2023-02-19 18:00:00,5.0,763,19,49,8.5,0.8,836,561,19,18,54,47,C
2023-02-19 19:00:00,5.6,710,19,49,8.5,0.8,814,561,19,18,54,47,C
""" )

using CSV
tb = CSV.File(io, dateformat="yyyy-mm-dd HH:MM:SS") |> DataFrame

dattb = Data( values=tb )

# xscale = LinearScale(range="width",   domain=dattb.CO2, nice=true)
tscale = TimeScale(range="width",   domain=dattb.DATE)
yscale = LinearScale(range="height",  domain=dattb.PM25, nice=true, zero=true)
y2scale = LinearScale(range="height",  domain=dattb.CO2, nice=true, zero=true)

cscale = OrdinalScale(range="category", domain=dattb.a)

smark = SymbolMark(shape="circle", from_data= dattb,
    encode_enter=(xc=xscale(dattb.CO2), yc=yscale(dattb.PM25), 
    size_value=100)
)

lmark = LineMark(from_data= dattb,
    encode_enter=(x=tscale(dattb.date), y=yscale(dattb.PM25))
)

lmark2 = LineMark(from_data= dattb,
    encode_enter=(x=tscale(dattb.date), y=y2scale(dattb.CO2))
)


ttt = VG(width=400, height=300, padding=20, background= "#ccc",
    axes = [ tscale(orient="bottom"), yscale(orient="left"), y2scale(orient="right") ],
    marks= [ lmark, lmark2 ])

f2 = Facet(groupby= dat.x)

io = IOBuffer()
EasyVega.toJSON(io,ttt.trie)
String(take!(io))


###############
using CSV
fn = "/home/fred/logs/temtop/compil 02-18 -> 03-03.csv"
histo = CSV.File(fn, dateformat="yyyy-mm-dd HH:MM:SS", normalizenames=true) |> DataFrame

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


ttt = VG(width=800, height=300, padding=20, background= "#ccb",
    axes = [ tscale(orient="bottom"), yscale(orient="left"), y2scale(orient="right") ],
    marks= [ lmark, lmark2 ])

tscale = TimeScale(range="width",   domain=histdat.DATE)
yscale = LinearScale(range="height",  domain=histdat.TEMP, nice=true, zero=true)
y2scale = LinearScale(range="height",  domain=histdat.HUMI, nice=true, zero=true)

lmark = LineMark(from_data= histdat,
    encode_enter=(x=tscale(histdat.DATE), y=yscale(histdat.TEMP), stroke_value="#d666")
)

lmark2 = LineMark(from_data= histdat,
    encode_enter=(x=tscale(histdat.DATE), y=y2scale(histdat.HUMI), stroke_value="#66d")
)

ttt = VG(width=800, height=300, padding=20, background= "#ccb",
    axes = [ tscale(orient="bottom"), yscale(orient="left"), y2scale(orient="right") ],
    marks= [ lmark, lmark2 ])


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

gm2 = GroupMark(
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    encode_enter_x = xscale(series.x),
    marks=[bars]
)


ttt = VG(width=500, height=200, padding=20, background= "#fed",
    # layout=(columns=1,),
    marks= [ gm1, gm2 ] 
)



################

using InteractiveUtils
io = IOBuffer()
EasyVega.toJSON(io,ttt.trie)
clipboard(String(take!(io)))

##############  alternative syntax (groups/root are predeclared, and objects specifically placed)

plt = VG(width=500, height=200, padding=20, background= "#fed")

xscale = plt.BandScale(range="width", domain=dat.x)
yscale = plt.LinearScale(range="height",   domain=dat.y, nice=true, zero=true)
cscale = plt.OrdinalScale(range="category", domain=dat.c)

gm = plt.GroupMark( encode_enter_x = xscale(series.x) )

series = gm.Facet(groupby=dat.x)
ixscale = gm.BandScale(range_signal="[0,width / 10]", domain = series.c, paddingOuter=0.1)

bars = gm.RectMark(encode_enter=(
    x = ixscale(series.c),
    width = ixscale(band=1.),
    y = yscale(value=0),
    y2 = yscale(series.y),
    fill = cscale(series.c)
))

render(plt)

ttt = VG(width=500, height=200, padding=20, background= "#fed",
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [ gm ] )



################


io = IOBuffer()
EasyVega.toJSON(io,ttt.trie)

String(take!(io))
