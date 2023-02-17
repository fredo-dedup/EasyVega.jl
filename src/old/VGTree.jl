

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
    for (k,v) in nargs
        sk = Symbol.(split(String(k), "_")) # split by symbol separated by "_"
        println(" $sk = $v")
        insert!(t, sk, v)
    end
	t
end

function Base.insert!(t::VGTree, prefix::Vector{Symbol}, item::LeafType)
    t.trie[prefix] = item
end

function Base.insert!(t::VGTree, prefix::Vector{Symbol}, items::NamedTuple)
    println(prefix)
	for (k,v) in pairs(items)
        # split by symbol separated by "_"
        sk = Symbol.(split(String(p1), "_"))
        println(" $sk = $v")
        insert!(t, vcat(prefix, sk), v)
    end
end


_process(item::LeafType) = item
_process(item::VGTree) = item
function _process(items::Vector)
    arr = Union{LeafType, VGTree, Vector}[]
    for e in items
        push!(arr, _process(e))
    end
    arr
end
function _process(items::NamedTuple)
    t = VGTree( SymbolTrie{Union{LeafType, Vector}}() )
    for (k,v) in pairs(items)
        sk = Symbol.(split(String(k), "_")) # split by symbol separated by "_"
        insert!(t, sk, v)
    end
	t
end

function Base.insert!(t::VGTree, prefix::Vector{Symbol}, items::Vector)
    t.trie[prefix] = _process(items)
end

###############################################################################
#  printing / displaying functions
###############################################################################

# ## By default, print the tree of the spec
function Base.show(io::IO, t::VGTree)
    printtree(io, t.trie)
end

function printtree(io::IO, subtree::SymbolTrie; indent=0)
    last = Symbol[]
    for k in sort(keys(subtree))
        v = subtree[k]

        if (length(k)>1) && (k[1:end-1] != last)  # print parent
            println(io, " " ^ (indent+length(k)-1), k[end-1], " : ")
            last = k[1:end-1]
        end

        if v isa LeafType
            println(io, " " ^ (indent+length(k)), k[end], " = ", v)
            
        elseif (v isa Vector) && all( e -> isa(e, LeafType), v ) # vector printable on one line
            rs = repr(v)
            if length(rs) > 50
                rs = rs[1:50] * "..."
            end
            println(io, " " ^ (indent+length(k)), k[end], " = ", rs)
            
        elseif v isa Vector
            println(io, " " ^ (indent+length(k)), k[end], " = [")
            for e in v
                if e isa LeafType
                    println(io, " " ^ (indent+length(k)+1), "̇- ",  e)
                elseif e isa Vector                
                    rs = repr(e)
                    if length(rs) > 50
                        rs = rs[1:50] * "..."
                    end
                    println(io, " " ^ (indent+length(k)+1), "- ", rs)
                elseif e isa VGTree
                    println(io, " " ^ (indent+length(k)+1), "- (")
                    printtree(io, e.trie, indent= indent+length(k)+1)
                    println(io, " " ^ (indent+length(k)+1), ")")
                else
                    println(io, " " ^ (indent+length(k)+1), "- ## not printable ")
                end
            end
            println(io, " " ^ (indent+length(k)), "]")
        elseif v isa VGTree
            printtree(io, v.trie, indent=length(k))
        else
            @error "not printable : $v"
        end
        
        # escape if long vector
        # if isa(subtree, Vector) && (k > 20)
        #     println(io, " " ^ indent, "$k - $(length(subtree)) : ...")
        #     break
        # end
    end
end

# # for VSCodeServer LimitIO : single char printing
# printtree(io::IO, c::Char; indent=0) = println(io, c)
# printtree(io::IO, s::AbstractString; indent=0) = println(io, s)


# idea : treat array elements as keys (#1, #2, ..) in a VGTree to simplify
