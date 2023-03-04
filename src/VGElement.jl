######## VGElements ############################################################
# this is the type for Data, Scale, Signal, (the named elements), other generic
#  tree branches and the final graph definition VG
# - they can implement syntax shortcuts (data.x, scale(...), etc.. ) 
# - they have an id, used for reference in final VG
# - they hold their dependencies to other elements in the tracking field

export VG

struct VGElement{T}
    trie::VGTrie
    tracking
end

# naming algo, to ensure unique and short names
counter = 1
refs = Dict{UInt, String}()

function idof(s::VGElement{T}) where T
    global counter, refs

    oid = objectid(s)
    haskey(refs, oid) && return refs[oid]

    n = counter
    counter += 1
    prefix = String(T)[1:2]
    refs[oid] = "$prefix-$n"
end

# idof(s::VGElement{T}) where T = "$(T)_$(objectid(s))"


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
    mentions::Dict{VGElement, Any}  # named elements mentionned and their lowest common group
    fixeddefs::Dict{VGElement, Any} # named elements defined in a group (not just mentionned)
    dependson::Dict{VGElement, Set}  # for each element the set of other elements they depend on
    grouppaths::Dict{VGElement, Vector} # path leading to each (i.e. group ancestors)
    children::Dict{VGElement, Set}  
end

Tracking() = Tracking(
    Dict{VGElement, Any}(),
    Dict{VGElement, Any}(),
    Dict{VGElement, Set}(),
    Dict{VGElement, Vector}(),
    Dict{VGElement, Set}()
)

function Base.show(io::IO, t::Tracking)
    println(io, "mentions :")
    for (k,v) in t.mentions
        println(io, "  - $k : $v")
    end
    println(io, "fixeddefs :")
    for (k,v) in t.fixeddefs
        println(io, "  - $k : $v")
    end
    println(io, "dependson :")
    for (k,v) in t.dependson
        println(io, "  - $k : $(collect(v))")
    end
    println(io, "grouppaths :")
    for (k,v) in t.grouppaths
        println(io, "  - $k : $v")
    end
    println(io, "children :")
    for (k,v) in t.children
        println(io, "  - $k : $(collect(v))")
    end
end

function updateTracking!(e::VGElement, index::Vector, item::VGElement)
    tracks = e.tracking
    ntracks = item.tracking

    merge!(tracks.grouppaths, ntracks.grouppaths)
    merge!(tracks.children, ntracks.children)
    
    #### update mentions
    for (el, gr) in ntracks.mentions
        if haskey(tracks.mentions, el) # lowest common group is current group
            tracks.mentions[el] = nothing
        else
            tracks.mentions[el] = gr
        end
    end
    # add the item itself to mentions, if named element
    if isnamed(item)
        tracks.mentions[item] = nothing
    end

    #### update depends-on list (for each mentionned element, list all elements they depend on) 
    # first copy dependency info from item
    for (el, els) in ntracks.dependson
        isnamed(el) && (tracks.dependson[el] = els)
    end
    # second, add to the list of what e depends on : item and what item depends on
    haskey(tracks.dependson, e) || ( tracks.dependson[e] = Set() )
    isnamed(item) && push!(tracks.dependson[e], item)
    union!(tracks.dependson[e], ntracks.dependson[item])

    #### update defs
    for (el, pos) in ntracks.fixeddefs
        tracks.fixeddefs[el] = pos
    end
    # add this element if we are in a definition
    if isdef(e, index) && isnamed(item)
        tracks.fixeddefs[item] = nothing
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