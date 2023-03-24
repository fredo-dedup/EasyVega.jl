########### Marks  #########################################################""

export ArcMark, AreaMark, GroupMark, ImageMark, LineMark, PathMark, RectMark, 
    RuleMark, ShapeMark, SymbolMark, TextMark, TrailMark

const Mark = VGElement{:Mark}

"""
    ArcMark(), AreaMark(), GroupMark(), ImageMark(), LineMark(), PathMark(), RectMark(), 
    RuleMark(), ShapeMark(), SymbolMark(), TextMark(), TrailMark()

Create a mark of a specific type. [Vega docs](https://vega.github.io/vega/docs/marks/)

Arguments can be named arguments describing the mark structure. Pairs can be passed as 
positional arguments to define channel encodings : `:x => scale(data.a)`. 

# Examples
```julia
sm = SymbolMark(shape="circle", 
    :xc            => xscale(dat.x), 
    :yc            => dat.y, 
    :stroke        => cscale(dat.a), 
)
```
"""
ArcMark, AreaMark, GroupMark, ImageMark, LineMark, PathMark, RectMark, RuleMark, ShapeMark, SymbolMark, TextMark, TrailMark



ArcMark(pargs...;nargs...)    = preMark(pargs...;type=:arc, nargs...)
AreaMark(pargs...;nargs...)   = preMark(pargs...;type=:area, nargs...)
ImageMark(pargs...;nargs...)  = preMark(pargs...;type=:image, nargs...)
LineMark(pargs...;nargs...)   = preMark(pargs...;type=:line, nargs...)
PathMark(pargs...;nargs...)   = preMark(pargs...;type=:path, nargs...)
RectMark(pargs...;nargs...)   = preMark(pargs...;type=:rect, nargs...)
RuleMark(pargs...;nargs...)   = preMark(pargs...;type=:rule, nargs...)
ShapeMark(pargs...;nargs...)  = preMark(pargs...;type=:shape, nargs...)
SymbolMark(pargs...;nargs...) = preMark(pargs...;type=:symbol, nargs...)
TextMark(pargs...;nargs...)   = preMark(pargs...;type=:text, nargs...)
TrailMark(pargs...;nargs...)  = preMark(pargs...;type=:trail, nargs...)



### specialized inserts for Marks
# translates encodings to valid Vega spec
function Base.insert!(e::Union{Mark,Group}, index::Vector, item::VGElement)
    # println(index, " -- ", item)
    if (index[1] == :encode) && (length(index) == 3) 
        if kindof(item) == :Signal
            insert!( e, index, (signal= idof(item),) )
        else
            # check if there is a :data field and remove it
            if haskey(trie(item), [:data])
                dat = pop!(trie(item).children, :data)
                # println("removed $dat")
            end
            # add the trie to the trie of e 
            for k in keys(trie(item))
                insert!(e, vcat(index, k), trie(item)[k])
            end
        end
    else
        if isnamed(item)  # only insert reference to it, not the whole thing
            trie(e)[index] = idof(item)
        else
            # add the trie to the trie of e 
            for k in keys(trie(item))
                insert!(e, vcat(index, k), trie(item)[k])
            end
        end
    end
    updateTracking!(e, index, item)
end

function Base.insert!(e::Union{Mark,Group}, index::Vector, item::LeafType)
    # println(index, " - ", item)
    if (index[1] == :encode) && (length(index) == 3)
        trie(e)[[index; :value]] = item
    else
        trie(e)[index] = item
    end
end


### translate positional args to named arguments
#  (e.g  pairs for channel encodings  )
function convertposargs(pargs...)
    is = []
    if !isempty(pargs)
        # check positional args
        all( p isa Pair for p in pargs ) || 
            error("positional arguments in marks should be pairs : channel => value / field / signal")
        
        for p in pargs
            ne = 1 + count( c -> c == '_', String(p.first) )
            if ne == 1  # add the default "enter" encoding set when none is specified
                k  = Symbol("encode_enter_" * String(p.first))
            elseif ne == 2
                k  = Symbol("encode_" * String(p.first))
            elseif ne > 2
                error("invalid channel spec : $(p.first)")
            end
            push!(is, k => p.second )
        end
    end
    
    is
end

function preMark(pargs...;nargs...)
    is = convertposargs(pargs...)  # process positional args to convert to named arguments

    ### create VGElement
    e = VGElement{:Mark}(; nargs..., is...)
    
    # if no "from/data" is specified, create it 
    if ! haskey(trie(e), [:from, :data])
        # look for facets or data 
        # TODO: improve search to only take data/facet that are used for encode (and skip used those in scales for example)
        deps = depgraph(e)
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

"""
    GroupMark([ Pairs[] ]; [ named arguments ])

Create a group mark. 

Group marks are higher level marks that can contain other marks. They can also  
contain all the definitions that the root Vega spec can contain (definitions for 
axes, legends, title, etc.).

# Example
```julia
gm = GroupMark(
    signals=[sig1, sig2],
    axes = [ xscale(orient="bottom"), yscale(orient="left") ],
    legends=[ (fill = cscale, title="type", titleFontSize=15) ],
    marks= [ linemark, pointmark ],
)
```
"""
function GroupMark(pargs...; nargs...)
    is = convertposargs(pargs...)  # process positional args to convert to named arguments

    ### create VGElement
    e = VGElement{:Group}(type=:group; nargs..., is...)
    
    # handle the "from" field
    #  - if set by user => use that, do not touch
    #  - if facets present, use first, throw warning if several
    #  - if no facet, use data
    if subtrie(trie(e), [:from]) === nothing
        deps = depgraph(e)
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
                for k in keys(trie(cfd))
                    # correct some misplaced fields in facets (TODO: improve this)
                    if k == [:groupby, :data]
                        insert!(e, [:from, :facet, :data], trie(cfd)[k])
                    elseif k == [:groupby, :field]    
                        insert!(e, [:from, :facet, :groupby], trie(cfd)[k])
                    else
                        insert!(e, vcat([:from, :facet], k), trie(cfd)[k])
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

