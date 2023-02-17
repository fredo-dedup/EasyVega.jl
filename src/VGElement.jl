######## VGElements ############################################################
# this is the type for Data, Scale, Signal, and the VG graph definition
# - they can implement syntax shortcuts (data.x, scale(...), etc.. ) 
# - they have an id, used for reference in final VG
# - they hold their dependencies to other elements in the refs field


struct VGElement{T}
    trie::VGTrie
    refs::Set
end

ids(s::VGElement{T}) where T = "$(T)_$(objectid(s))"
kindof(::VGElement{T}) where T = T

# valid value for tree leaves
const LeafType = Union{
    String,
    Symbol,
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

function Base.insert!(e::VGElement, index::Vector, item::VGElement)
    for k in keys(item.trie)
        insert!(e, vcat(index, k), item.trie[k])
    end
    for r in item.refs
        push!(e.refs, r)
    end
end


# catch non valid items to throw clear error message
function Base.insert!(e::VGElement, index::Vector, items::T) where T
    error("type $T not allowed in VGTrie")
end



########### Scale
const Scale = VGElement{:Scale}

Scale(typ::Symbol; nargs...) = Scale(type=typ; nargs...)

scalex = Scale(:linear, sort=true, group_by=:x, domain=[0,12])

Scale(a=32)

function (s::Scale)(t::VGElement)
    t.trie[[:scale]] = ids(s)
    push!(t.refs, s) # annotate that there is a new scale in the Trie now
    t
end

(s::Scale)(; nargs...) = s( VGElement{:generic}(;nargs...) )

ttt = VGElement{:generic}(field=:ab)
scalex(ttt)

scalex(field= :u)
kindof(scalex)

#############  Data
const Data = VGElement{:Data}

src = Data(values= [(a=4, b="A"), (a=9, b="B"),(a=2, b="C"), ])

# translate  data.sym into {data="dataname", field = "sym"}
function Base.getproperty(d::Data, sym::Symbol)
    # treat VGElement fieldnames as usual
    (sym == :trie) && return getfield(d, :trie)
    (sym == :refs) && return getfield(d, :refs)
    # FIXME : issue if fields are named "refs" or "trie"

    v = VGElement{:generic}(data=ids(d), field=sym)
    push!(v.refs, d) # annotate that there is a new data in the Trie now
    v
end

src.abcd
kindof(src)

################# VG ##################
# final Element, collects refs (as other VGElement), but also
# builds the data, scale fields to have a final representation

const VG = VGElement{:final}

function VG(;nargs...)
f = VGElement{:generic}(;nargs...) # not :final otherwise the function calls itself
defs = Dict{Symbol, Vector}()
for r in f.refs
    t = kindof(r)
    haskey(defs, t) || (defs[t] = VGElement[])

    if ! haskey(r.trie, [:name])  # assign the name if not there
        r.trie[[:name]] = ids(r)
    end

    push!(defs[t], r)
end

for t in keys(defs)
    insert!(f, [t], defs[t])
end
VGElement{:final}(f.trie, Set())
end

VG( marks_encoding_x= src.y, axes= scalex(src.b), height=15 ).trie

