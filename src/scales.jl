########### Scale #############################################################

export LinearScale, LogScale, PowScale, SqrtScale, SymlogScale, TimeScale, UtcScale, 
    SequentialScale, OrdinalScale, BandScale, PointScale, QuantileScale, QuantizeScale, 
    ThresholdScale, BinordinalScale

const Scale = VGElement{:Scale}

#  make scale(...) expand to (scale= scaleid, ...)
function (s::Scale)(t::VGElement)
    t.trie[[:scale]] = idof(s)
    push!(t.refs, s) # annotate that there is a new scale in the Trie now
    t
end

(s::Scale)(; nargs...) = s( VGElement{:generic}(;nargs...) )




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






