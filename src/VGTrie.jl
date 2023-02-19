# Like a Trie but with indexing that is either a symbol (for named fields)
#   or an Int (for vectors)
#   --  adapted from DataStructures.jl --

mutable struct VGTrie{T}
    value::T
    children::Union{ Dict{Symbol,VGTrie{T}}, Dict{Int,VGTrie{T}}}
    is_key::Bool

    function VGTrie{T}(typ::DataType) where T
        self = new{T}()
        self.children = Dict{typ,VGTrie{T}}()
        self.is_key = false
        return self
    end
end

keytype(::Dict{A,B}) where {A,B} = A

function Base.setindex!(t::VGTrie{T}, val, key::Vector) where T
    value = convert(T, val) # we don't want to iterate before finding out it fails
    node = t
    for (i, token) in enumerate(key)
        # check that token is of the right type (Symbol / Int) for the node
        # println(eltype(node.children))
        ctyp = keytype(node.children)
        if typeof(token) != ctyp
            error("invalid key type : $token is not a $ctyp")
        end

        if !haskey(node.children, token)
            nexttyp = (i < length(key)) ? typeof(key[i+1]) : Symbol # FIXME
            node.children[token] = VGTrie{T}(nexttyp)
        end
        node = node.children[token]
    end
    node.is_key = true
    node.value = value
end

function Base.getindex(t::VGTrie, key::Vector)
    node = subtrie(t, key)
    if (node != nothing) && node.is_key
        return node.value
    end
    throw(KeyError("key not found: $key"))
end

function subtrie(t::VGTrie, prefix::Vector)
    node = t
    for sym in prefix
        if !haskey(node.children, sym)
            return nothing
        else
            node = node.children[sym]
        end
    end
    return node
end

function Base.haskey(t::VGTrie, key::Vector)
    node = subtrie(t, key)
    (node != nothing) && node.is_key
end

function Base.get(t::VGTrie, key::Vector, notfound)
    node = subtrie(t, key)
    if (node != nothing) && node.is_key
        return node.value
    end
    return notfound
end

function Base.keys(t::VGTrie, prefix::Vector=[], found=[])
    if t.is_key
        push!(found, prefix)
    end
    for (sym,child) in t.children
        keys(child, [prefix; sym], found)
    end
    return found
end

function keys_with_prefix(t::VGTrie, prefix::Vector)
    st = subtrie(t, prefix)
    (st != nothing) ? keys(st, prefix) : []
end

#####  printing  #######################################

## By default, print the tree of the spec
function Base.show(io::IO, t::VGTrie)
    print(io, "VGTrie")
    printtrie(io, t)
end

function printtrie(io::IO, t::VGTrie; indent=0)
    spaces = " " ^ indent
    t.is_key && print(io, " = ", t.value)
    
    if length(t.children) > 0
        print(io, " →")
    end
    println(io)

    for k in keys(t.children)
        print(io, spaces, "  ", k)
        printtrie(io, t.children[k], indent=indent+2)
    end
end


