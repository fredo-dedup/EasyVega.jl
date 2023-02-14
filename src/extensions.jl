
###########  Data struct  #####################################################

datacounter = 1

struct Data
    id::String
    trie::VGTree
end

# general constructor
function Data(;nargs...)
    global datacounter
    dat = Data("Data_$datacounter", VGTree(;nargs...))
    datacounter += 1
    dat
end


## make the data.sym1 yield (data = data_id, field=sym) work
function Base.getproperty(d::Data, sym::Symbol)
  # treat VG fieldname :trie as it should
  (sym == :trie) && return getfield(d, :trie)
  (sym == :id)   && return getfield(d, :id)

  VGTree(;data= d.id, field=sym)
end

function Base.show(io::IO, d::Data)
    println(io, d.id)
    show(io, d.trie)
end