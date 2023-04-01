using EasyVega


# use the movies database from Vega examples
# filter out bad data
movies = Data(
    url = "https://raw.githubusercontent.com/vega/vega-datasets/next/data/movies.json",
    transform= [
        (type= "filter",
         expr= "datum['Rotten Tomatoes Rating'] != null && datum['IMDB Rating'] != null"
        )
    ]
)


# control to change the bandwidth of the loess interpolation
loessBandwidth = Signal(
    value= 0.3,
    bind= (input= "range", min= 0.05, max= 1)
)


# create a loess interpolation
trend = Data(
    source= movies,
    transform= [
        (
          type= "loess",
          # "groupby": [{"signal": "groupby === 'genre' ? 'Major Genre' : 'foo'"}],
          bandwidth= (signal= loessBandwidth,),
          x= "Rotten Tomatoes Rating",
          y= "IMDB Rating",
          as= ["u", "v"]
        )
      ]
)


# define the scale (can't use the movies.xyz shortcut here because the field has spaces)
xscale = LinearScale(range="width", domain=(data=movies, field="Rotten Tomatoes Rating"))
yscale = LinearScale(range="height", domain=(data=movies, field="IMDB Rating"))


sma = SymbolMark(
    from_data= movies,
    :x => (scale= xscale, field="Rotten Tomatoes Rating"),
    :y => (scale= yscale, field="IMDB Rating"),
    :fillOpacity => 0.5,
    :size => 16
)


lma = LineMark(
    :x => xscale(trend.u),
    :y => yscale(trend.v),
    :stroke => :firebrick
)


VG(width=400, height=400, background=:white, padding= 20,
    marks=[sma, lma],
    axes=[xscale(orient="bottom"), yscale(orient="left")]
)
