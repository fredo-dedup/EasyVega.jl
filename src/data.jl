#############  Data  ##########################################################

export Data, Facet

const Data = VGElement{:Data}
const Facet = VGElement{:Facet}

# Data insertion 
# function Base.insert!(e::VGElement, index::Vector, item::Data) 
#     # insert!(e, index, idof(item)) # only reference at construction stage
#     # updateTracking!(e, index, item)
#     insert!(e, index, item)
# end


# translate  data.sym into {data="dataname", field = "sym"}
function Base.getproperty(d::Union{Data,Facet}, sym::Symbol)
    # treat VGElement fieldnames as usual
    (sym == :trie) && return getfield(d, :trie)
    (sym == :tracking) && return getfield(d, :tracking)
    # FIXME : issue if fields are named "tracking" or "trie"

    f = VGElement{:generic}()
    insert!(f, [:field], sym)
    insert!(f, [:data], d)

    f
end

# idea = populate the from_data field in the parent marks


##### facet ###################################################################
#  they will populate the "from : { facet : {...}}" def in the group mark


# Data insertion 
# function Base.insert!(e::VGElement, index::Vector, item::Facet) 
#     insert!(e, index, idof(item)) # only reference at construction stage
#     updateTracking!(e, index, item)
# end

# translate  data.sym into {data="dataname", field = "sym"}
# function Base.getproperty(d::Facet, sym::Symbol)
#     # treat VGElement fieldnames as usual
#     (sym == :trie) && return getfield(d, :trie)
#     (sym == :tracking) && return getfield(d, :tracking)
#     # FIXME : issue if fields are named "tracking" or "trie"

#     f = VGElement{:generic}()
#     insert!(f, [:field], sym)
#     insert!(f, [:data], d)

#     f
# end