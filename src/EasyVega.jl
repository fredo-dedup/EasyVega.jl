
module EasyVega

using JSON
using Dates

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
