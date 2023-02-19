#############  Data

export Data

const Data = VGElement{:Data}

# translate  data.sym into {data="dataname", field = "sym"}
function Base.getproperty(d::Data, sym::Symbol)
    # treat VGElement fieldnames as usual
    (sym == :trie) && return getfield(d, :trie)
    (sym == :refs) && return getfield(d, :refs)
    # FIXME : issue if fields are named "refs" or "trie"

    v = VGElement{:generic}(data=idof(d), field=sym)
    push!(v.refs, d) # annotate that there is a new data in the Trie now
    v
end



# idea = populate the from_data field in the parent marks


