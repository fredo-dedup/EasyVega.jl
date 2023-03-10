#############  Data & Facets  #################################################
# Facets, as Data, define a data source for marks but their definition go into 
#   the 'from' field of Group marks

export Data, Facet

const Data = VGElement{:Data}
const Facet = VGElement{:Facet}

# translate  data.sym into {data="dataname", field = "sym"}
function Base.getproperty(d::Union{Data,Facet}, sym::Symbol)
    # treat VGElement fieldnames as usual
	(sym in fieldnames(VGElement)) && return getfield(d, sym)
    # FIXME : issue if fields are named "tracking" or "trie" or id

    f = VGElement{:generic}()
    insert!(f, [:field], sym)
    insert!(f, [:data], d)
    
    f
end

