
module EasyVega

using JSON, Dates, Random
using Graphs, MetaGraphsNext 
import Tables

include("VGTrie.jl")
include("VGElement.jl")

include("scales.jl")
include("marks.jl")
include("data.jl")
include("misc_named.jl")
include("VG.jl")

include("io.jl")



end
