################# VG ##########################################################
# final Element, collects named VGElements (Signal, Data, Scale, ..) and
# places their definitions at the right place in the trie

export VG

function VG(;nargs...)
    f = VGElement{:final}(;nargs...) 
    deps = depgraph(f)

    # skip everything if no dependency (i.e a fully explicit spec is given)
    (nv(deps)==0) && return f

    # We iteratively update 'positions' which is a vector giving a
    # candidate position for the definition of each named element.
    # Positions are initialized with their path in the dependency graph between 
    # the root element VG and the element.
    # Positions are updated (by moving up toward the root) to ensure they are at or 
    # before the definition of the elements depending on it (except if its  
    #   position is fixed)
    # We stop when necessary updates are exhausted (i.e the positions are 
    #  consistent) 
    
    #### initialize
    isfixed = Set( i for i in vertices(deps) if deps[label_for(deps,i)] )
    # println(isfixed)
    paths = dijkstra_shortest_paths(deps, code_for(deps, f))
    positions = enumerate_paths(paths)
    # println(positions)
    
    anymoved = true
    children = [ inneighbors(deps, i) for i in 1:nv(deps) ]
    while anymoved
        anymoved = false
        for (i, path) in enumerate(positions)
            if (length(children) > 0) && (length(path) > 0) && !(i in isfixed)
                minpath = mincommonindex(positions[children[i]]...)
                if minpath != path
                    anymoved = true
                    positions[i] = minpath
                    # println("$i : $path => $minpath")
                end
            end
        end
    end

    # find the closest group to the candidate path to put the definition in
    defpos = Dict{VGElement, VGElement}()
    groups = Set( i for i in 1:nv(deps) if kindof(label_for(deps,i)) in [:final, :Group] )
    # println(groups)
    for (i,path) in enumerate(positions)
        (i == code_for(deps, f)) && continue # skip root
        if length(path) < 2
            gr = f
        else
            idx = findlast( ip in groups for ip in path[1:end-1] )
            gr = label_for(deps, path[idx])
        end
        el = label_for(deps, i)
        defpos[el] = gr 
    end
    # println(defpos)

    #### now we insert the definitions at the indicated place
    # arrange by destination group and element type
    gtyped = Dict{VGElement, Any}()
    for (e, gr) in defpos
        haskey(gtyped, gr) || ( gtyped[gr] = Dict{Symbol, Vector}() )
        typ = DefName[ kindof(e) ]
        if typ !== nothing  # skip facets
            haskey(gtyped[gr], typ) || ( gtyped[gr][typ] = [] )
            push!(gtyped[gr][typ], e)
        end
    end
    # sort within vectors to respect potential dependence (eg between data, between marks)
    ord = sortperm(topological_sort(deps))
    for (_, d) in gtyped
        for (_, v) in d
            sort!(v, by= g -> ord[code_for(deps,g)], rev=true)
        end
    end

    # now insert defs
    tr = rebuildwithdefs(f, gtyped)
    for (k, v) in tr.children
        trie(f).children[k] = v
    end
    
    f
end

# recursive insertion, without tracking
function rebuildwithdefs(group::VGElement, gtyped)
    tr = trie(group)
    for (typ, es) in gtyped[group]
        for (i, d) in enumerate(es)
            # in definitions vectors, remove references, to leave room for the def trie
            haskey(tr, [typ, i]) && (subtrie(tr, [typ, i]).is_key = false )

            t2 = (kindof(d) == :Group) ? rebuildwithdefs(d, gtyped) : trie(d)
            for k in keys(t2)
                tr[vcat([typ, i], k)] = t2[k]
            end
            # for (k, v) in tr.children
            #     tr[[typ, i]].children[k] = v
            # end
            tr[[typ, i, :name]] = idof(d) # add their name
        end
    end
    tr
end


# find largest common path
function mincommonindex(vs...)
    (length(vs) == 1) && return vs[1]
    nk = []
    for i in 1:minimum(length, vs)
        any( vs[1][i] != vs[j][i] for j in 2:length(vs) ) && break
        push!(nk, vs[1][i])
    end
    nk
end