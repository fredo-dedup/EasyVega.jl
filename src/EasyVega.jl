
module EasyVega

using JSON, Dates
using Graphs, MetaGraphsNext
import Tables


include("VGTrie.jl")
include("VGElement.jl")

include("scales.jl")
include("marks.jl")
include("data.jl")
include("signals.jl")
include("VG.jl")

include("io.jl")

end
