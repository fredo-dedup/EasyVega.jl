########### Signals ###########################################################

export Signal

const Signal = VGElement{:Signal}

#  make scale(...) expand to (scale= scaleid, ...)
# function (s::Scale)(t::VGElement)
#     t.trie[[:scale]] = idof(s)
#     push!(t.refs, s) # annotate that there is a new scale in the Trie now
#     t
# end

# (s::Scale)(; nargs...) = s( VGElement{:generic}(;nargs...) )




# LinearScale(;nargs...) = Scale(type=:linear; nargs...)
# LogScale(;nargs...) = Scale(type=:log; nargs...)
# PowScale(;nargs...) = Scale(type=:pow; nargs...)





