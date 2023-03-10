######## VGElements ############################################################
# this is the type for Data, Scale, Signal, (the named elements), other generic
#  tree branches and the final graph definition VG
# - they can implement syntax shortcuts (data.x, scale(...), etc.. ) 
# - they have an id, used for reference in final VG
# - they hold their dependencies to other elements in the tracking field

elements_counter::Int = 1

struct VGElement{T}
    trie::VGTrie
    tracking
    id::Int
    function VGElement{T}(trie, tracking) where {T}
        global elements_counter
        elements_counter += 1
        new(trie, tracking, elements_counter)
    end
end

function idof(s::VGElement{T}) where T
    prefix = String(T)[1:2]
    n = s.id
    "$prefix$n"
end

kindof(::VGElement{T}) where T = T

# valid value for tree leaves
const LeafType = Union{
    AbstractString,
    Symbol,
    Char,
    Number,
    Date, DateTime, Time,
    Nothing
}

# general constructor
function VGElement{T}(;nargs...) where T 
    e = VGElement{T}( VGTrie{LeafType}(Symbol), Tracking() )
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

function Base.insert!(e::VGElement, index::Vector, item::VGElement{T}) where {T}
    if isnamed(item)  # only insert reference to it, not the whole thing
        insert!(e, index, idof(item))
    else
        # add the trie to the trie of e 
        for k in keys(item.trie)
            insert!(e, vcat(index, k), item.trie[k])
        end
    end
    updateTracking!(e, index, item)
end

# catch remaining types
function Base.insert!(e::VGElement, index::Vector, item::T) where T
    if Tables.istable(item) 
        # do not use insert! here because we don't want to split table field names
        # on  '_' as insert! does by default
        for (i,row) in enumerate(Tables.rowtable(item))
            for (k,v) in pairs(row)
                insert!(e, [index; i; k], v)
            end
        end
    else
        error("type $T not allowed")
    end
end


## By default, print the id of the spec
function Base.show(io::IO, t::VGElement)
    print(io, idof(t))
end


################ named VGElements   ###########################################

# map from VGElement type to field map for final VGElement
DefName = Dict(
    :Mark => :marks,
    :Signal => :signals,
    :Scale => :scales,
    :Data => :data,
    :Facet => nothing,  # this one goes in GroupMarks, no def necessary
    :Group => :marks,
)

isnamed(e::VGElement{T}) where {T} = T in keys(DefName)


#######   reference and group tracking  #########################################

struct Tracking
    depgraph::MetaGraph # dependency graph between elements
    # groupgraph::MetaGraph
end

Tracking() = Tracking(
    MetaGraph(DiGraph(), Label=VGElement, VertexData=Bool),
    # MetaGraph(DiGraph(), Label=VGElement, VertexData=Set)
)

function Base.show(io::IO, t::Tracking)
    deps = t.depgraph
    labs = [ "$(label_for(deps, i))" for i in 1:nv(deps) ]
    println(io, "nodes :")
    println(io, labs)

    println(io, "dependencies :")
    println(io, [ "$(labs[e.src]) -> $(labs[e.dst])" for e in edges(t.depgraph)])
end


function addDependency(g::MetaGraph, a::VGElement, b::VGElement)
    haskey(g, a) || add_vertex!(g, a, false)
    haskey(g, b) || add_vertex!(g, b, false)
    add_edge!(g, a, b, nothing)
end


function updateTracking!(e::VGElement, index::Vector, item::VGElement)
    depg = e.tracking.depgraph
    ndepg = item.tracking.depgraph

    #### update dependency graph with depgraph of item
    for edg in edges(ndepg)
        a = label_for(ndepg, edg.src)
        b = label_for(ndepg, edg.dst)
        if (a == item) && !isnamed(item) # link to e directly
            addDependency(depg, e, b)
        else
            addDependency(depg, a, b)
        end
    end
    # add the item itself to dependencies of e
    isnamed(item) && addDependency(depg, e, item)

    #### update fixed flag
    for iel in vertices(ndepg)
        el = label_for(ndepg, iel)
        haskey(depg, el) && (depg[el] = ndepg[el])
    end
    # mark this item as fixed if we are in a definition
    if isdef(e, index) && isnamed(item)
        depg[item] = true
    end
end


function isdef(e::VGElement, index::Vector, allowedtypes=values(DefName))
    (length(index) == 2) || return false
    isa(index[end], Int) || return false
    (index[end-1] in allowedtypes) || return false
    # check now that we are in root node or a GroupMark
    (kindof(e) == :prefinal) && return true
    (kindof(e) == :Group) && return true
    return false
end