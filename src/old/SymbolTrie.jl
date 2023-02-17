# Trie but with symbols instead of chars / Strings
# adapted from DataStructures.jl

mutable struct SymbolTrie{T}
    value::T
    children::Dict{Symbol,SymbolTrie{T}}
    is_key::Bool

    function SymbolTrie{T}() where T
        self = new{T}()
        self.children = Dict{Symbol,SymbolTrie{T}}()
        self.is_key = false
        return self
    end
end

SymbolTrie() = SymbolTrie{Any}()

# SymbolTrie(ks::AbstractVector{K}, vs::AbstractVector{V}) where {K<:AbstractString,V} = SymbolTrie{V}(ks, vs)
# SymbolTrie(kv::AbstractVector{Tuple{K,V}}) where {K<:AbstractString,V} = SymbolTrie{V}(kv)
# SymbolTrie(kv::AbstractDict{K,V}) where {K<:AbstractString,V} = SymbolTrie{V}(kv)
# SymbolTrie(ks::AbstractVector{K}) where {K<:AbstractString} = SymbolTrie{Nothing}(ks, similar(ks, Nothing))

function Base.setindex!(t::SymbolTrie{T}, val, key::Vector{Symbol}) where T
    value = convert(T, val) # we don't want to iterate before finding out it fails
    node = t
    for sym in key
        if !haskey(node.children, sym)
            node.children[sym] = SymbolTrie{T}()
        end
        node = node.children[sym]
    end
    node.is_key = true
    node.value = value
end

function Base.getindex(t::SymbolTrie, key::Vector{Symbol})
    node = subtrie(t, key)
    if (node != nothing) && node.is_key
        return node.value
    end
    throw(KeyError("key not found: $key"))
end

function subtrie(t::SymbolTrie, prefix::Vector{Symbol})
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

function Base.haskey(t::SymbolTrie, key::Vector{Symbol})
    node = subtrie(t, key)
    (node != nothing) && node.is_key
end

function Base.get(t::SymbolTrie, key::Vector{Symbol}, notfound)
    node = subtrie(t, key)
    if (node != nothing) && node.is_key
        return node.value
    end
    return notfound
end

function Base.keys(t::SymbolTrie, prefix::Vector{Symbol}=Symbol[], found=Vector{Symbol}[])
    if t.is_key
        push!(found, prefix)
    end
    for (sym,child) in t.children
        keys(child, [prefix; sym], found)
    end
    return found
end

function keys_with_prefix(t::SymbolTrie, prefix::Vector{Symbol})
    st = subtrie(t, prefix)
    (st != nothing) ? keys(st,prefix) : []
end

# The state of a SymbolTrieIterator is a pair (t::SymbolTrie, i::Int),
# where t is the SymbolTrie which was the output of the previous iteration
# and i is the index of the current character of the string.
# The indexing is potentially confusing;
# see the comments and implementation below for details.
struct SymbolTrieIterator
    t::SymbolTrie
    str::Vector{Symbol}
end

# At the start, there is no previous iteration,
# so the first element of the state is undefined.
# We use a "dummy value" of it.t to keep the type of the state stable.
# The second element is 0
# since the root of the trie corresponds to a length 0 prefix of str.
function Base.iterate(it::SymbolTrieIterator, (t, i) = (it.t, 0))
    if i == 0
        return it.t, (it.t, 1)
    elseif i == length(it.str) + 1 || !(it.str[i] in keys(t.children))
        return nothing
    else
        t = t.children[it.str[i]]
        return (t, (t, i + 1))
    end
end

# partial_path(t::SymbolTrie, str::AbstractString) = SymbolTrieIterator(t, str)
Base.IteratorSize(::Type{SymbolTrieIterator}) = Base.SizeUnknown()
