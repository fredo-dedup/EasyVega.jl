using DataFrames
N = 10
tb = DataFrame(x=randn(N), y=randn(N), a=rand("ABC", N))

using EasyVega

EasyVega.VG

abc = EasyVega.Data(abc=456)

VG