
###########  Data struct  #####################################################


@info "hello extensions"


datacounter = 1

struct Data
    id::String
    trie::Trie{Union{LeafType, Vector}}
end

# single arg case (not caught by named args function below apparently)
function Data()
    Data("Data_$datacounter", Trie{Union{LeafType, Vector}})
    datacounter += 1
end
# VG(vl::VG) = VG(deepcopy(vl.trie)) # copy the trie
# VG(nt::NamedTuple) = VG(;pairs(nt)...)
  
# general constructor
function Data(pargs...;nargs...)
    # all( isa.(pargs, Union{VG, NamedTuple}) ) ||
    #     @error "non-named argument(s) not allowed"
    # TODO : catch errors and show helpful message

    dat = Data()

    # add named arguments if any
    for (k,v) in pairs(nargs)
        insert!(dat, String(k), v)
        # TODO : ensure vectors are VecValues[] ?
    end

    # # add positional arguments (can be NamedTuples or VG only)
    # for pa in pargs
    #     nvl = isa(pa, NamedTuple) ? VG(pa) : pa # force to VG if NamedTuple
    #     for l1k in l1keys(nvl)
    #         if haskey(nvl.trie, l1k)  # leaf
    #             insert!(vl, l1k, nvl.trie[l1k])
    #         else  # branch
    #             insert!(vl, l1k, VG(subtrie(nvl.trie, l1k * "_")))
    #         end
    #     end
    # end
    dat
end
  
