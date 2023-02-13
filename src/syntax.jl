## the VG struct

# this will help limit what goes into the spec tree
const LeafType = Union{
	String,
	Symbol,
	Number,
	Date, DateTime, Time,
	Nothing
}

struct VG
  trie::Trie{Union{LeafType, Vector}}
end

const VecValues = Union{LeafType, Vector, NamedTuple, VG}

# single arg case (not caught by named args function below apparently)
VG() = VG(Trie{Union{LeafType, Vector}}())
VG(vl::VG) = VG(deepcopy(vl.trie)) # copy the trie
VG(nt::NamedTuple) = VG(;pairs(nt)...)

# general constructor
function VG(pargs...;nargs...)
	all( isa.(pargs, Union{VG, NamedTuple}) ) ||
		@error "non-named argument(s) not allowed"
    # TODO : catch errors and show helpful message

	vl = VG( Trie{Union{LeafType, Vector}}() )

	# add named arguments if any
	for (k,v) in pairs(nargs)
		insert!(vl, String(k), v)
		# TODO : ensure vectors are VecValues[] ?
	end

	# add positional arguments (can be NamedTuples or VG only)
	for pa in pargs
		nvl = isa(pa, NamedTuple) ? VG(pa) : pa # force to VG if NamedTuple
		for l1k in l1keys(nvl)
			if haskey(nvl.trie, l1k)  # leaf
				insert!(vl, l1k, nvl.trie[l1k])
			else  # branch
				insert!(vl, l1k, VG(subtrie(nvl.trie, l1k * "_")))
			end
		end
	end
	vl
end

# gets 1st level keys
function l1keys(vl::VG)
	l1k = Set{String}()
	for k in keys(vl.trie)
		ks = split(k, "_")
		push!(l1k, ks[1])
	end
	l1k
end

## functions amending the structure

# insert at index in vl

# NamedTuples into VG structs
Base.insert!(vl::VG, index, item::NamedTuple) =
	insert!(vl, index, VG(;pairs(item)...))

function Base.insert!(vl::VG, index, item::Union{LeafType, Vector, VG})
  # leaf already existing => add to vector or create vector
  if haskey(vl.trie, index)
    if isa(vl.trie[index], Vector)
      push!(vl.trie[index], item)
    else
      vl.trie[index] = VecValues[ vl.trie[index], item ]
    end

  # there is already a branch on index
  # TODO use 1st level of index instead of index ?
  elseif length(keys_with_prefix(vl.trie, index * "_")) > 0
    prefix = index * "_"
    vl.trie[index] = VecValues[ VG(subtrie(vl.trie, prefix)), item ]  # create vector with subtrie
    delete!(subtrie(vl.trie, index).children, '_') # remove subtrie

  # if VG graft the branch
  elseif isa(item, VG)
    for k in keys(item.trie)
      vl.trie[index * "_" * k] = item.trie[k]
    end

  elseif isa(item, Union{LeafType, Vector})
    vl.trie[index] = item

  else
    @warn "unanticipated case : item is a $(typeof(item))"
  end

  vl
end

# adding VGs
function Base.:+(vl1::VG, vl2::VG)
	vl = VG(vl1)  # copy
	for k in keys(vl2.trie)
		insert!(vl, k, vl2.trie[k])
  	end
  	vl
end

Base.:+(vl1::VG, nt::NamedTuple) = vl1 + VG(nt)

## let's try to accept rowtables

function Base.insert!(vl::VG, index, item::Any)
  insert!(vl, index, Tables.rowtable(item))
  # TODO : catch errors and show helpful message
end


## make the VG().sym1().sym2() syntax work
# function Base.getproperty(vl::VG, sym::Symbol)
#   # treat VG fieldname :trie as it should
#   (sym == :trie) && return getfield(vl, :trie)

#   function (pargs...; nargs...)
# 		# single, non-named argument
# 		if (length(pargs)==1) && (length(nargs)==0)
# 			a = pargs[1]
# 			if a isa Union{LeafType, Vector}
# 				insert!(vl, String(sym), a)
# 			elseif a isa VG
# 				insert!(vl, String(sym), a)
# 			elseif a isa NamedTuple
# 				insert!(vl, String(sym), VG(a))
# 			else  # last chance try to turn it into a row table
# 				insert!(vl, String(sym), a)
# 			end
# 		else
# 			insert!(vl, String(sym), VG(pargs...;nargs...))
# 		end
#   end
# end

## make the VG().sym1().sym2() syntax also work for the VG type :
#   VG.sym1().sym2()

# forbidden symbols are the DataType symbols
# :name, :super, :parameters, :types, :names, :instance, :layout, :size,
# :ninitialized, :uid, :abstract, :mutable, :hasfreetypevars, :isconcretetype,
# :isdispatchtuple, :isbitstype, :zeroinit, :isinlinealloc,
# :has_concrete_subtype, Symbol("llvm::StructType"), Symbol("llvm::DIType"))

# function Base.getproperty(vlt::Type{VG}, sym::Symbol)
# 	# treat DataType fieldnames as usual
# 	(sym in fieldnames(DataType)) && return getfield(vlt, sym)

# 	# create new VG
# 	getproperty(VG(), sym)
# end
