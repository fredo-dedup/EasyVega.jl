module EasyVega

@info "hello EasyVega"

using JSON
using Dates

import Tables
import DataStructures: Trie, subtrie, keys_with_prefix

export VG, Data, Scale, Facet

include("SymbolTrie.jl")
include("VGTree.jl")
#include("syntax.jl")
# include("extensions.jl")
# include("io.jl")
# include("libshmem_win.jl")

end
