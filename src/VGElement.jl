######## VGElements ############################################################
# this is the type for Data, Scale, Signal, and the VG graph definition
# - they can implement syntax shortcuts (data.x, scale(...), etc.. ) 
# - they have an id, used for reference in final VG
# - they hold their dependencies to other elements in the refs field

export VG

struct VGElement{T}
    trie::VGTrie
    refs::Set
end

idof(s::VGElement{T}) where T = "$(T)_$(objectid(s))"
kindof(::VGElement{T}) where T = T

# valid value for tree leaves
const LeafType = Union{
    AbstractString,
    Symbol,
    Char,
    Number,
    Date, DateTime, Time,
    Nothing
}

# general constructor
function VGElement{T}(;nargs...) where T 
    e = VGElement{T}( VGTrie{LeafType}(Symbol), Set() )
    for (k,v) in nargs
        sk = Symbol.(split(String(k), "_")) # split by symbol separated by "_"
        insert!(e, sk, v)
    end
    e
end


function Base.insert!(e::VGElement, index::Vector, item::LeafType)
    e.trie[index] = item
end


function Base.insert!(e::VGElement, index::Vector, items::NamedTuple)
    for (k,v) in pairs(items)
        sk = Symbol.(split(String(k), "_")) # split by symbol separated by "_"
        insert!(e, vcat(index, sk), v)
    end
end


function Base.insert!(e::VGElement, index::Vector, items::Vector)
    for (i,v) in enumerate(items)
        insert!(e, vcat(index, [i]), v)
    end
end


function Base.insert!(e::VGElement, index::Vector, item::VGElement{T}) where {T}
    if T in [:Data, :Signal, :Scale] # add the reference if Specialized Element
        insert!(e, index, idof(item))

    else # add to tree for other kinds of elements
        for k in keys(item.trie)
            insert!(e, vcat(index, k), item.trie[k])
        end
        for r in item.refs
            push!(e.refs, r)
        end
    end
end

# catch remaining types
function Base.insert!(e::VGElement, index::Vector, item::T) where T
    if Tables.istable(item)
        insert!(e, index, Tables.rowtable(item))
    else
        error("type $T not allowed")
    end
end


## By default, print the tree of the spec
function Base.show(io::IO, t::VGElement)
    println(io, "VGElement{$(kindof(t))}")
    printtrie(io, t.trie)
    println(io, length(t.refs), " refs")
end


#############  Data
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

# src.abcd
# kindof(src)

################# VG ##################
# final Element, collects refs (as other VGElement), but also
# builds the data, scale fields to have a final representation

const VG = VGElement{:final}

# VGElement type to field map for final VGElement
fmap = Dict(:Data => :data, :Scale => :scales, :Signal => :signals )


function VG(;nargs...)
    f = VGElement{:generic}(;nargs...) # not :final otherwise the function calls itself
    defs = Dict{Symbol, Vector}()
    for r in f.refs
        t = kindof(r)
        haskey(defs, t) || (defs[t] = VGElement[])

        if ! haskey(r.trie, [:name])  # assign the name if not there
            r.trie[[:name]] = idof(r)
        end

        push!(defs[t], r)
    end

    for t in keys(defs)
        goodname = fmap[t]
        for (i,e) in enumerate(defs[t])
            # all Data, .. elements have to be expanded and not default to their names
            #  hence they are cast in generic subtypes
            insert!(f, [goodname; i], VGElement{:generic}(e.trie, Set()) )
        end
    end
    VGElement{:final}(f.trie, Set())
end

# VG( marks_encoding_x= src.y, axes= scalex(src.b), height=15 ).trie

