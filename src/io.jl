function toJSON(io::IO, t::VGTrie)
    if t.is_key
        toJSON(io, t.value)
    elseif keytype(t.children) == Symbol
        print(io, "{")
        sep = false
        for k in sort(collect(keys(t.children)))
            sep && print(io, ",")
            toJSON(io, k)
            print(io, ":")
            toJSON(io, t.children[k])
            sep = true
        end
        print(io, "}")
    else
        print(io, "[")
        sep = false
        for k in sort(collect(keys(t.children)))
            sep && print(io, ",")
            toJSON(io, t.children[k])
            sep = true
        end
        print(io, "]")
    end
end

toJSON(io::IO, v::AbstractString) = print(io, "\"$v\"")
toJSON(io::IO, v::Char) = print(io, "\"$v\"")
toJSON(io::IO, v::Symbol) = print(io, "\"$v\"")
toJSON(io::IO, v::Number) = print(io, "$v")
toJSON(io::IO, v::Date) = print(io, "\"$v\"")
# toJSON(io::IO, v::DateTime) = print(io, "\"$v\"")
toJSON(io::IO, v::DateTime) = print(io, "$(Dates.datetime2unix(v))")

toJSON(io::IO, v::Time) = print(io, "\"$v\"")
toJSON(io::IO, v::Nothing) = print(io, "null")


function Base.show(io::IO, m::MIME"text/plain", v::VG)
    show(io, v.trie)  # do not show refs
    return
end

# function Base.show(io::IO, v::AbstractVegaSpec)
#     if !get(io, :compact, true)
#         Vega.printrepr(io, v, include_data=:short)
#     else
#         print(io, summary(v))
#     end
#     return
# end

# function convert_vg_to_x(v::VGSpec, script)
#     full_script_path = joinpath(vegalite_app_path, "node_modules", "vega-cli", "bin", script)
#     p = open(Cmd(`$(nodejs_cmd()) $full_script_path -l error`, dir=vegalite_app_path), "r+")
#     writer = @async begin
#         our_json_print(p, v)
#         close(p.in)
#     end
#     reader = @async read(p, String)
#     wait(p)
#     res = fetch(reader)
#     if p.exitcode != 0
#         throw(ArgumentError("Invalid spec"))
#     end
#     return res
# end

# function convert_vg_to_svg(v::VGSpec)
#     vg2svg_script_path = joinpath(vegalite_app_path, "vg2svg.js")
#     p = open(Cmd(`$(nodejs_cmd()) $vg2svg_script_path`, dir=vegalite_app_path), "r+")
#     writer = @async begin
#         our_json_print(p, v)
#         close(p.in)
#     end
#     reader = @async read(p, String)
#     wait(p)
#     res = fetch(reader)
#     if p.exitcode != 0
#         throw(ArgumentError("Invalid spec"))
#     end
#     return res
# end

Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vega.v5+json")}) = true

function Base.show(io::IO, m::MIME"application/vnd.vega.v5+json", v::VG)
    toJSON(io, v.trie)
end

# function Base.show(io::IO, m::MIME"image/svg+xml", v::VGSpec)
#     print(io, convert_vg_to_svg(v))
# end

# function Base.show(io::IO, m::MIME"application/vnd.julia.fileio.htmlfile", v::VGSpec)
#     writehtml_full(io, v)
# end

# function Base.show(io::IO, m::MIME"application/prs.juno.plotpane+html", v::VGSpec)
#     writehtml_full(io, v)
# end

# Base.showable(m::MIME"text/html", v::VGSpec) = isdefined(Main, :PlutoRunner)
# function Base.show(io::IO, m::MIME"text/html", v::VGSpec)
#     writehtml_partial_script(io, v)
# end
