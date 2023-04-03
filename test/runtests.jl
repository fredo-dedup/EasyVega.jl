using Test

using EasyVega
import EasyVega: VGTrie, insert!, VGElement, kindof, idof, depgraph, trie
import EasyVega: code_for, label_for, outneighbors, inneighbors
import EasyVega: nv, ne, isdef, isnamed

@testset "VGTrie" begin
    t = VGTrie{String}(Symbol)
    t[[:abc,3]] = "xyx"
    @test t[[:abc,3]] == "xyx"
    @test_throws KeyError t[[:abc]]
    @test t.is_key == false
    @test t.children[:abc].is_key == false
    @test t.children[:abc].children[3].is_key == true

    @test EasyVega.subtrie(t, [:abc]) isa EasyVega.VGTrie
    @test haskey(t, [:abc]) == false
    @test haskey(t, [:abc,3]) == true

    @test keys(t) == [[:abc, 3]]
end


@testset "VGElement" begin
    e = VGElement{:test}()
    @test kindof(e) == :test
    @test match(r"^te\d*$", idof(e)) !== nothing 
    insert!(e, [:abcd, 3, :xyz], 456)
    @test trie(e)[[:abcd, 3, :xyz]] == 456
    insert!(e, [:abcd, 3], (i=4, j=:sym))
    @test trie(e)[[:abcd, 3, :i]] == 4
    @test trie(e)[[:abcd, 3, :j]] == :sym
    @test_throws ErrorException("type DataType not allowed") insert!(e, [:abcd, 3], Int)

    @test_throws ErrorException("invalid key type : xy is not a Int64") insert!(e, [:abcd, :xy], 1.5)
    
    m = Data(values=[(a=4,b="a"), (a=5,b="b")])
    n = GroupMark(:x => m.a, marks = [ 456, :abcd])
    
    deps = depgraph(n)
    @test nv(deps) == 2
    @test ne(deps) == 1
    
    deps2 = depgraph(m)
    @test nv(deps2) == 0
    
    @test outneighbors(deps, code_for(deps, n)) == [ code_for(deps, m) ]
    @test inneighbors(deps, code_for(deps, n)) == Int64[]
    
    @test isdef(n, [:encode]) == false
    @test isdef(n, [:marks, 1]) == true
    
    @test isnamed(m) == true
    @test isnamed(n) == true
    @test isnamed(e) == false

end





