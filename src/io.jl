###############################################################################
#  printing / displaying functions
###############################################################################

## conversion to a tree (a dict of dicts)

function totree(vl::VG)
    kdict = Dict{String,Any}()
    for k in sort(keys(vl.trie))
        ks = split(k, "_")
        # build dict tree if no set yet
        pardict = kdict
        for k2 in ks[1:end-1]
            if ! haskey(pardict, k2)
                pardict[k2] = Dict{String,Any}()
            end
            pardict = pardict[k2]
        end
    
        pardict[ks[end]] = totree(vl.trie[k])
    end
    kdict
end
totree(e::LeafType)   = e
totree(v::Vector) = map(totree, v)
totree(e::NamedTuple) = e

## By default, print the tree of the spec
function Base.show(io::IO, vl::VG)
    printtree(io, totree(vl))
end

function printtree(io::IO, subtree::Union{NamedTuple, Dict, Vector}; indent=0)
    for (k,v) in pairs(subtree)
        if isa(v, LeafType)
            println(io, " " ^ indent, k, " : ", v)
            
        elseif isa(v, Vector) && all( e -> isa(e, LeafType), v ) # vector printable on one line
            rs = repr(v)
            if length(rs) > 50
                rs = rs[1:50] * "..."
            end
            println(io, " " ^ indent, k, " : ", rs)
            
        else
            println(io, " " ^ indent, k, " : ")
            printtree(io, v, indent=indent+2)
        end
        
        # escape if long vector
        if isa(subtree, Vector) && (k > 20)
            println(io, " " ^ indent, "$k - $(length(subtree)) : ...")
            break
        end
    end
end

# for VSCodeServer LimitIO : single char printing
printtree(io::IO, c::Char; indent=0) = println(io, c)
printtree(io::IO, s::AbstractString; indent=0) = println(io, s)

## displaying the graph

# function Base.show(io::IO, m::MIME"image/svg+xml", v::VG)
#     # translate to dict and then to JSON
#     iob = IOBuffer()
#     JSON.print(iob, totree(v))
    
#     # create command for server
#     req = MsgType("render-svg", "", String(take!(iob)), [])
    
#     println(req)
#     ret = postAndWait(req, 10000)  # bail out after 10 sec
#     try
#         if ret.label == "svg"
#             print(io, ret.text)
#         elseif ret.label == "error"
#             @error "VG error : $(ret.detail)"
#         else
#             @error "Unknown server message : $(ret.label)"
#         end
#     catch e    
#         error(e)
#     end
# end

# function Base.show(io::IO, m::MIME"image/png", v::VG)
#     # translate to dict and then to JSON
#     iob = IOBuffer()
#     JSON.print(iob, totree(v))
    
#     # create command for server
#     req = MsgType("render-png", "", String(take!(iob)), [])
    
#     println(req.label)
#     ret = postAndWait(req, 10000)  # bail out after 10 sec
#     try
#         if ret.label == "png"
#             print(io, ret.text)
#         elseif ret.label == "error"
#             @error "VG error : $(ret.detail[1:min(500,end)])"
#         else
#             @error "Unknown server message : $(ret.label)"
#         end
#     catch e    
#         error(e)
#     end
# end

# function our_json_print(io, spec::VGSpec)
#     JSON.print(io, add_encoding_types(Vega.getparams(spec)))
# end

# function Base.show(io::IO, m::MIME"application/vnd.vegalite.v4+json", v::VG)
#     VegaLite.our_json_print(io, VegaLite.VGSpec(totree(v)))
# end

# function Base.show(io::IO, m::MIME"application/vnd.vega.v5+json", v::VG)
#     print(io, VegaLite.convert_vl_to_vg(VegaLite.VGSpec(totree(v))))
# end

# function Base.show(io::IO, m::MIME"application/vnd.julia.fileio.htmlfile", v::VG)
#     VegaLite.writehtml_full(io, VegaLite.VGSpec(totree(v)))
# end

# function Base.show(io::IO, m::MIME"application/prs.juno.plotpane+html", v::VG)
#     VegaLite.writehtml_full(io, VegaLite.VGSpec(totree(v)))
# end
