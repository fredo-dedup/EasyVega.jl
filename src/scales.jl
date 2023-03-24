########### Scale #############################################################

export LinearScale, LogScale, PowScale, SqrtScale, SymlogScale, TimeScale, UtcScale, 
    SequentialScale, OrdinalScale, BandScale, PointScale, QuantileScale, QuantizeScale, 
    ThresholdScale, BinordinalScale

const Scale = VGElement{:Scale}

#  make scale(...) expand to (scale= scaleid, ...)
function (s::Scale)(e::VGElement)
    f = VGElement{:generic}()
    insert!(f, [], e)
    insert!(f, [:scale], s)
    f
end

(s::Scale)(; nargs...)  = s( VGElement{:generic}(;nargs...) )
(s::Scale)(x::LeafType) = s( VGElement{:generic}(;value=x) )

"""
    LinearScale(), LogScale(), PowScale(), SqrtScale(), SymlogScale(), TimeScale(), UtcScale(), 
    SequentialScale(), OrdinalScale(), BandScale(), PointScale(), QuantileScale(), QuantizeScale(), 
    ThresholdScale(), BinordinalScale()

Create a scale of a specific type. [Vega docs](https://vega.github.io/vega/docs/scales/)

# Examples
```julia
yscale = BandScale(range="height", domain=dat.y, domain_sort=true)
cscale = OrdinalScale(range="category", domain=dat.c)
```
"""
LinearScale, LogScale, PowScale, SqrtScale, SymlogScale, TimeScale, UtcScale, SequentialScale, OrdinalScale, BandScale, PointScale, QuantileScale, QuantizeScale, ThresholdScale, BinordinalScale

LinearScale(;nargs...) = Scale(type=:linear; nargs...)
LogScale(;nargs...) = Scale(type=:log; nargs...)
PowScale(;nargs...) = Scale(type=:pow; nargs...)
SqrtScale(;nargs...) = Scale(type=:sqrt; nargs...)
SymlogScale(;nargs...) = Scale(type=:symlog; nargs...)
TimeScale(;nargs...) = Scale(type=:time; nargs...)
UtcScale(;nargs...) = Scale(type=:utc; nargs...)

SequentialScale(;nargs...) = Scale(type=:sequential; nargs...)
OrdinalScale(;nargs...) = Scale(type=:ordinal; nargs...)
BandScale(;nargs...) = Scale(type=:band; nargs...)
PointScale(;nargs...) = Scale(type=:point; nargs...)
QuantileScale(;nargs...) = Scale(type=:quantile; nargs...)
QuantizeScale(;nargs...) = Scale(type=:quantize; nargs...)
ThresholdScale(;nargs...) = Scale(type=:threshold; nargs...)
BinordinalScale(;nargs...) = Scale(type="bin-ordinal"; nargs...)






