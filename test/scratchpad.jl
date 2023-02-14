using DataFrames
N = 10
tb = DataFrame(x=randn(N), y=randn(N), a=rand("ABC", N))

using EasyVega

st = EasyVega.SymbolTrie{Int}()
st[[:abc]] = 456
st[[:abc, :x, :y]] = 456

keys(st)
st2 = EasyVega.subtrie(st, [:abc])
keys(st2)

t = EasyVega.VGTree()


t = EasyVega.VGTree(a="abcd", b_tu=1, b_do=0)


t


t = EasyVega.VGTrie()

t = EasyVega.VGTrie(a=12, d="abcd", d_by=4, d_no=:sss)  # FIXME both d="abcd" and d=(by=..,no=..) exist

t = EasyVega.VGTrie(a=12, d=[1,2,(a=:gr, b=45)])  # FIXME both d="abcd" and d=(by=..,no=..) exist


first(eltype(Dict{Symbol, Any}))


t = EasyVega.VGTrie(
    value = 32,
    transform=[(type="stack",groupby=[:x], sort_field=:c, field=:y, sort="abcd")]
)


keys(t)
t
t.value
t.is_key


sort(keys(t))

keytype(::Dict{A,B}) where {A,B} = A

keytype(Dict{Symbol, Any}())


dat = EasyVega.Data(
    value = 32,
    transform=[(type="stack",groupby=[:x], sort_field=:c, field=:y)]
);


dat

dat.abcd

EasyVega.VGTree

[1,2,3] isa AbstractString


abc = EasyVega.Data(abc=456)



[ k for k in st ]


function ttt(pargs...; nargs...)
    println(typeof(nargs))
    for (p1,p2) in nargs
        println(Symbol.(split(String(p1), "_")))
        println(p1, " ", p2, " ", typeof(p2))
    end
end


ttt(a_ahkjh=456, b_aa="abcd")

