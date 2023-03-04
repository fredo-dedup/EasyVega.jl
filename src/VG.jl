################# VG ##########################################################
# final Element, collects named VGElements (Signal, Data, Scale, ..) and
# places their definitions at the right place in the trie

const VG = VGElement{:final}

function VGElement{:final}(;nargs...)
    f = VGElement{:prefinal}(;nargs...) 
    wraplevel!(f)

    tracks = f.tracking
    # println(tracks)

    # maintain two dicts : positions fixed, and floating
    # populate fixed with floating until floating is empty
    fixedpos = Dict{VGElement, Any}()
    floatingpos = Dict{VGElement, Any}()
    
    # populate floating pos group with all mentions
    merge!(floatingpos, tracks.mentions)

    # fixed defs can be transfered to fixed group
    merge!(fixedpos, tracks.fixeddefs)
    filter!(p -> !haskey(tracks.fixeddefs,p[1]), floatingpos)

    # iteratively transfer elements from floatingpos to fixedpos
    # (floating can be transfered when all elements in depends on are fixed)
    anymoved = true
    while (length(floatingpos) > 0) && anymoved
        anymoved = false
        for (k,gr) in floatingpos
            # test if all the elements it depends on have a fixed position
            if all( haskey(fixedpos, p) for p in tracks.dependson[k] ) 
                # if yes, we can fix it to the lowest common group of dependson
                
                
                # FIXME : constraint is the other way around !
                # if length(tracks.dependson[k]) == 0
                #     grp = gr
                # else 
                #     dogrs = [ fixedpos[e] for e in tracks.dependson[k] ]
                #     ps = [ tracks.grouppaths[g] for g in dogrs ]
                #     grps = mincommonindex(ps...)
                #     grp = (length(grps)==0) ? f : grps[end]
                # end

                grp = gr  # let's try this simplification

                fixedpos[k] = grp
                pop!(floatingpos, k)
                anymoved = true
                # println("(1) $k  ->  $grp")
            end
        end
    end
    
    anymoved || error("circular reference somewhere")

    #### now we insert the definitions at the indicated place
    # println(fixedpos)

    # arrange by destination group and element type
    gtyped = Dict{VGElement, Any}()
    for (e, gr) in fixedpos
        haskey(gtyped, gr) || ( gtyped[gr] = Dict{Symbol, Vector}() )
        typ = DefName[ kindof(e) ]
        haskey(gtyped[gr], typ) || ( gtyped[gr][typ] = [] )
        push!(gtyped[gr][typ], e)
    end
    # println(gtyped)

    # now insert defs
    trie = rebuildwithdefs(f, gtyped)
    for (k, v) in trie.children
        f.trie.children[k] = v
    end
    
    VG(f.trie, f.tracking)
end

# recursive insertion, without tracking
function rebuildwithdefs(group::VGElement, gtyped)
    # println(group)
    # trie = VGTrie{LeafType}(Symbol)
    trie = group.trie
    for (typ, es) in gtyped[group]
        # println("  - $typ  : $es ($(length(es)) elements)")
        for (i, d) in enumerate(es)
            # in definitions vectores, remove references, to leave room for the def trie
            haskey(trie, [typ, i]) && (subtrie(trie, [typ, i]).is_key = false )

            # println("****  $d   $(typeof(d))  $(kindof(d))")
            t2 = (kindof(d) == :Group) ? rebuildwithdefs(d, gtyped) : d.trie
            for k in keys(t2)
                trie[vcat([typ, i], k)] = t2[k]
            end
            # for (k, v) in trie.children
            #     trie[[typ, i]].children[k] = v
            # end
            trie[[typ, i, :name]] = idof(d) # add their name
        end
    end
    trie
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