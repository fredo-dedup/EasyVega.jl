

# valid value for tree leaves
const LeafType = Union{
	String,
	Symbol,
	Number,
	Date, DateTime, Time,
	Nothing
}

# const VGTree = SymbolTrie{Union{LeafType, Vector}}
struct VGTree
    trie::SymbolTrie{Union{LeafType, Vector}}
end

# general constructor
function VGTree(;nargs...)
    t = VGTree( SymbolTrie{Union{LeafType, Vector}}() )
    # t = SymbolTrie(nothing, Dict{Symbol,VGTreeSymbolTrieUnion{LeafType, Vector}}(), false)
    insert!(t, Symbol[], nargs)
	t
end

function Base.insert!(t::VGTree, index::Vector{Symbol}, item::LeafType)
    t.trie[index] = item
end

function Base.insert!(t::VGTree, index::Vector{Symbol}, items::NamedTuple)
    println(index)
	for (k,v) in pairs(items)
        # split by symbol separated by "_"
        sk = Symbol.(split(String(p1), "_"))
        println(" $sk = $v")
        insert!(t, vcat(index, sk), v)
    end
end


###############################################################################
#  printing / displaying functions
###############################################################################

## conversion to a tree (a dict of dicts)

# function totree(vl::VG)
#     kdict = Dict{String,Any}()
#     for k in sort(keys(vl.trie))
#         ks = split(k, "_")
#         # build dict tree if no set yet
#         pardict = kdict
#         for k2 in ks[1:end-1]
#             if ! haskey(pardict, k2)
#                 pardict[k2] = Dict{String,Any}()
#             end
#             pardict = pardict[k2]
#         end
    
#         pardict[ks[end]] = totree(vl.trie[k])
#     end
#     kdict
# end
# totree(e::LeafType)   = e
# totree(v::Vector) = map(totree, v)
# totree(e::NamedTuple) = e

# ## By default, print the tree of the spec
# function Base.show(io::IO, t::VGTree)
#     printtree(io, t.dict)
# end

# function printtree(io::IO, subtree::SymbolTrie; indent=0)
#     for (k,v) in pairs(subtree.dict)
#         if isa(v, LeafType)
#             println(io, " " ^ indent, k, " : ", v)
            
#         elseif isa(v, Vector) && all( e -> isa(e, LeafType), v ) # vector printable on one line
#             rs = repr(v)
#             if length(rs) > 50
#                 rs = rs[1:50] * "..."
#             end
#             println(io, " " ^ indent, k, " : ", rs)
            
#         else
#             println(io, " " ^ indent, k, " : ")
#             printtree(io, v, indent=indent+2)
#         end
        
#         # escape if long vector
#         if isa(subtree, Vector) && (k > 20)
#             println(io, " " ^ indent, "$k - $(length(subtree)) : ...")
#             break
#         end
#     end
# end

# # for VSCodeServer LimitIO : single char printing
# printtree(io::IO, c::Char; indent=0) = println(io, c)
# printtree(io::IO, s::AbstractString; indent=0) = println(io, s)


