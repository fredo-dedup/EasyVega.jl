using DataFrames
N = 10
tb = DataFrame(x=randn(N), y=randn(N), a=rand("ABC", N))

using EasyVega

using VegaLite



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
    # transform=[(type="stack",groupby=[:x], sort_field=:c, field=:y)]
)

xscale = Scale(:point,   range="width",    domain=dat.x)
yscale = Scale(:linear,  range="height",   domain=dat.y, nice=true, zero=true)
cscale = Scale(:ordinal, range="category", domain=dat.c)

series = Facet(groupby=dat.c)

ttt = VG(width=500, height=200, padding=5,
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    marks= [
        (
            type= :group,
            from_facet= (name="series", data=EasyVega.ids(dat), groupby=:c),
            marks= [
                (
                    type="line", from_data="series",
                    encode_enter_x = xscale(dat.x),
                    encode_enter_y = yscale(dat.y),
                    encode_enter_stroke = cscale(dat.c),
                    encode_enter_strokeWidth_value = 2,
                )
            ]
        ) ]
)


EasyVega.toJSON(ttt.trie)
