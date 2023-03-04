########### Marks  #########################################################""

export ArcMark, AreaMark, GroupMark, ImageMark, LineMark, PathMark, RectMark, 
    RuleMark, ShapeMark, SymbolMark, TextMark, TrailMark

const Mark = VGElement{:Mark}

ArcMark(;nargs...)    = Mark(type=:arc; nargs...)
AreaMark(;nargs...)   = Mark(type=:area; nargs...)
ImageMark(;nargs...)  = Mark(type=:image; nargs...)
LineMark(;nargs...)   = Mark(type=:line; nargs...)
PathMark(;nargs...)   = Mark(type=:path; nargs...)
RectMark(;nargs...)   = Mark(type=:rect; nargs...)
RuleMark(;nargs...)   = Mark(type=:rule; nargs...)
ShapeMark(;nargs...)  = Mark(type=:shape; nargs...)
SymbolMark(;nargs...) = Mark(type=:symbol; nargs...)
TextMark(;nargs...)   = Mark(type=:text; nargs...)
TrailMark(;nargs...)  = Mark(type=:trail; nargs...)

# Mark specific processing
function VGElement{:Mark}(;nargs...)
    e = VGElement{:Mark}( VGTrie{LeafType}(Symbol), Tracking() )
    for (k,v) in nargs
        sk = Symbol.(split(String(k), "_")) # split by symbol separated by "_"
        insert!(e, sk, v)
    end

    # if no "from" is specified, create it 
    if ! haskey(e.trie, [:from, :data])
        # look for facets first
        cd = findfirst( (kindof(p[1]) == :Facet) && (p[2] === nothing) for p in pairs(e.tracking.mentions) )
        # and data next
        if cd === nothing
            cd = findfirst( (kindof(p[1]) == :Data) && (p[2] === nothing) for p in pairs(e.tracking.mentions) )
        end

        (cd === nothing) || insert!(e, [:from, :data], idof(cd))
    end
    e
end

### group mark  ###############################################################
const Group = VGElement{:Group}

function GroupMark(;nargs...)
    e = Group(type=:group; nargs...)
    
    #  compared to tracking of common elements we need : 
    tracks = e.tracking
    
    # handle the "from" field
    #  - if set by user => use that, do not touch
    #  - if 1 facet present, use it
    #  - if several facets present, throw error
    #  - if no facet, use data
    if subtrie(e.trie, [:from]) === nothing
        fcs = filter( f -> kindof(f) == :Facet, keys(tracks.mentions) )
        (length(fcs) > 1) && error("multiple facets used in this group") 
        if length(fcs) == 1
            fc = first(fcs)
            insert!(e, [:from, :facet, :name], idof(fc))  # add facet name
            for k in keys(fc.trie)
                # correct some misplaced fields  (TODO: improve this)
                if k == [:groupby, :data]
                    insert!(e, [:from, :facet, :data], fc.trie[k])
                elseif k == [:groupby, :field]    
                    insert!(e, [:from, :facet, :groupby], fc.trie[k])
                else
                    insert!(e, vcat([:from, :facet], k), fc.trie[k])
                end
            end

            # remove facet from mentions
            pop!(tracks.mentions, fc)
        else
            cd = findfirst( (kindof(p[1]) == :Data) && (p[2] === nothing) for p in pairs(tracks.mentions) )
            (cd === nothing) || insert!(e, [:from, :data], idof(cd))
        end
    end
    # Facets should be resolved at this stage not propagated

    wraplevel!(e)
    e
end


# used in GroupMark and VG : 
#    - to update the group paths by appending the current group
#    - updating the children of this group element
function wraplevel!(e::VGElement)
    tracks = e.tracking

    # assign orphan mentions to this group
    for (el, gr) in tracks.mentions
        if gr === nothing
            tracks.mentions[el] = e
        end
    end

    # assign orphan fixeddefs to this group
    for (el, gr) in tracks.fixeddefs
        if gr === nothing
            tracks.fixeddefs[el] = e
        end
    end

    # update the grouppaths
    for (el, pos) in tracks.grouppaths
        tracks.grouppaths[el] = (pos === nothing) ? [e] : [e; pos]
    end
    tracks.grouppaths[e] = []  # add this group too

    # all those groups are children of current group
    tracks.children[e] = keys(tracks.children)
end