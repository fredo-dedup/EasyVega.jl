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

function toJSON(io::IO, v::DateTime)
    dtu = Dates.datetime2unix(v)*1000
    dtu = round(Int64, dtu)
    print(io, "$dtu")
end
toJSON(io::IO, v::Date) = toJSON(io, DateTime(v))

toJSON(io::IO, v::Time) = print(io, "\"$v\"")
toJSON(io::IO, v::Nothing) = print(io, "null")


function Base.show(io::IO, m::MIME"text/plain", v::VGElement{:final})
    show(io, trie(v))  # do not show refs
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

function Base.show(io::IO, m::MIME"application/vnd.vega.v5+json", v::VGElement{:final})
    toJSON(io, trie(v))
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

Base.showable(m::MIME"text/html", v::VGElement{:final}) = isdefined(Main, :PlutoRunner)
function Base.show(io::IO, m::MIME"text/html", v::VGElement{:final})
    writehtml_partial_script(io, v)
end

"""
Creates a HTML script + div block for showing the plot (typically for Pluto).
VegaLite js files are loaded from the web using script tags.
"""
function writehtml_partial_script(io::IO, v::VGElement{:final})
    divid = "vg" * randstring(10)

    print(io, """
    <style media="screen">
        .vega-actions a {
        margin-right: 10px;
        font-family: sans-serif;
        font-size: x-small;
        font-style: italic;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
    <script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>
    <div id="$divid"></div>
    <script>
        var spec = """
    )

    toJSON(io, trie(v))

    print(io,"""
        ;
        var opt = {
        mode: "vega",
        renderer: "svg",
        actions: true
        };
        vegaEmbed("#$divid", spec, opt);
    </script>
    """)
end
