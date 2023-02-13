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

