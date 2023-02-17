
###########  Data struct  #####################################################

struct VG{T}
    trie::VGTrie
    refs::Set
end

function VG{:root}(; nargs...)
    trie, refs = VGTrie(;nargs...)
    VG{:root}(trie, refs)
end

ids(s::VG{T}) where T = "$(T)_$(objectid(s))"


function Base.insert!(t::VGTrie, index::Vector, item::VG, refs=Set()) where T
    for k in keys(item.trie)
        insert!(t, vcat(index, k), v, refs)
    end
    append!(found, item.refs)
end


########## Scale
const Scale2 = VG{:Scale}

function Scale2(typ::Symbol; nargs...)
    trie, refs = VGTrie(;nargs...)
    trie[[:type]] = typ
    Scale2(trie, Set())
end

scalex = Scale2(:linear, sort=true, group_by=:x, domain=[0,12])

function (s::Scale2)(t::VG)
    t.trie[[:scale]] = ids(s)
    # annotate that there is a new scale in the Trie now
    push!(t.refs, s)
    t
end

(s::Scale2)(; nargs...) = s( VG{:root}( VGTrie(;nargs...)... ) )

t, _ = VGTrie(field=:ab)
scalex(field= :u)
scalex(t)
typeof(t)

############  Data
const Data2 = VG{:Data}

function Data2(; nargs...)
    trie, refs = VGTrie(;nargs...)
    Data2(trie, refs)
end

src = Data2(values= [(a=4, b="A"), (a=9, b="B"),(a=2, b="C"), ])

# translate  data.sym into {data="dataname", field = "sym"}
function Base.getproperty(d::Data2, sym::Symbol)
    # treat VG fieldnames as usual
    (sym == :trie) && return getfield(vl, :trie)
    (sym == :refs) && return getfield(vl, :refs)
    # FIXME : issue if fields are named "refs" or "trie"

    v = VG{:root}(data=ids(d), field=sym)
    push!(v.refs, d)
    v
end

src.abcd



VG{:root}( encoding_x = src.x)



#############################################################################






t = VG2{:root}(a="abcd", b_tu=1, b_do=0,
    transform=[(a=456, sort_by=[:x], field=(x=12,))])


t = VG2{:root}(a="abcd", b_tu=1, b_do=0,
    encode_x= scalex(field=:x),
    transform=[(a=456, sort_by=[:x], field=(x=12,))])
