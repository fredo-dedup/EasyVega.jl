########### Scale #############################################################

export LinearScale, LogScale, PowScale, SqrtScale, SymlogScale, TimeScale, UtcScale, 
    SequentialScale, OrdinalScale, BandScale, PointScale, QuantileScale, QuantizeScale, 
    ThresholdScale, BinordinalScale

const Scale = VGElement{:Scale}

# Scales insertion 
# function Base.insert!(e::VGElement, index::Vector, item::Scale) 
#     insert!(e, index, idof(item)) # only reference at construction stage
#     updateTracking!(e, index, item)

#     # # either we are in a definition field (.. scales = [  item, .. ] or it is just mentioned in a field

#     # # first case : we are in a definition : insert the whole element definition
#     # if isdef(e, index, [:scales])
#     #     error("issue #1 : definition insertion")
#     #     # # hard insert to skip tracking
#     #     # for k in keys(item.trie)
#     #     #     insert!(e, vcat(index, k), item.trie[k])
#     #     # end
#     #     # # insert!(e, index, VGElement{:generic}(item.trie, Tracking())) # to avoid self calling
#     #     # insert!(e, [index; :name], idof(item))
#     #     # # TODO update defs of e.tracking ?

#     # else # second case : it is a mention : insert only the reference to the element
#     #     insert!(e, index, idof(item))
#     #     updateTracking!(e, index, item)
#     # end
# end


#  make scale(...) expand to (scale= scaleid, ...)
function (s::Scale)(e::VGElement)
    f = VGElement{:generic}()
    insert!(f, [], e)
    insert!(f, [:scale], s)
    f
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






