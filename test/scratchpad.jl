using DataFrames
N = 200
tb = DataFrame(x=randn(N), y=randn(N), a=rand("ABC", N))

using EasyVega


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



################

using InteractiveUtils



################


io = IOBuffer()
EasyVega.toJSON(io,ttt.trie)

String(take!(io))


using PkgTemplates

t = Template(plugins=[GitHubActions()])
t("EasyVega2")
