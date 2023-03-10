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
        # look for facets or data 
        # TODO: improve search to only take data/facet that are used for encode (and skip used those in scales for example)
        deps = e.tracking.depgraph
        dorf = [ label_for(deps,i) for i in outneighbors(deps, code_for(deps, e)) ]
        filter!(e -> kindof(e) in [:Facet, :Data], dorf)

        if length(dorf) > 1
            error("multiple data/facets used in this mark : $dorf")
        elseif length(dorf) == 1
            insert!(e, [:from, :data], idof(dorf[1]))
        end
    end
    e
end

### group mark  ###############################################################
const Group = VGElement{:Group}

function GroupMark(;nargs...)
    e = Group(type=:group; nargs...)
    
    # handle the "from" field
    #  - if set by user => use that, do not touch
    #  - if facets present, use first, throw warning if several
    #  - if no facet, use data
    if subtrie(e.trie, [:from]) === nothing
        deps = e.tracking.depgraph
        dorf = [ label_for(deps,i) for i in dfs_parents(deps, code_for(deps, e)) ]
        filter!(e -> kindof(e) in [:Facet, :Data], dorf)

        if length(dorf) > 0
            # use facets over data in priority
            is = findfirst( kindof.(dorf) .== :Facet )
            (is === nothing) && ( is = findfirst( kindof.(dorf) .== :Data ) )

            cfd = label_for(deps, is)
            (length(dorf)>1) && warning("multiple data/facets in this group, using $cfd, explicitly set it if not correct")

            if kindof(cfd) == :Facet
                # insert definition of this facet in the 'from' field
                insert!(e, [:from, :facet, :name], idof(cfd))  # add facet name
                for k in keys(cfd.trie)
                    # correct some misplaced fields in facets (TODO: improve this)
                    if k == [:groupby, :data]
                        insert!(e, [:from, :facet, :data], cfd.trie[k])
                    elseif k == [:groupby, :field]    
                        insert!(e, [:from, :facet, :groupby], cfd.trie[k])
                    else
                        insert!(e, vcat([:from, :facet], k), cfd.trie[k])
                    end
                end
        
                # add new link between this group and this facet 
                addDependency(deps, e, cfd)
                # mark this definition as fixed
                deps[cfd] = true
            else  # Data, insert ref only
                insert!(e, [:from, :data], idof(cfd))
                addDependency(deps, e, cfd)
            end
        end
    end

    e
end

