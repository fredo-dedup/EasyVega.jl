#############  Data & Facets  #################################################
# Facets, as Data, define a data source for marks but their definition go into 
#   the 'from' field of Group marks

export Data, Facet

const Data = VGElement{:Data}
const Facet = VGElement{:Facet}

"""
    Data(), Facet()

Create a Data/Facet element. [Vega docs](https://vega.github.io/vega/docs/data/)

Arguments can be named arguments describing the data structure. All Julia objects 
thta comply with the Tables interface can be used as values. 

# Examples
```julia
using DataFrames
N = 100
tb = DataFrame(x=randn(N), y=randn(N), a=rand("ABC", N))

mydata = Data(values=tb)
```
"""
Data, Facet

# translate  data.sym into {data="dataname", field = "sym"}
function Base.getproperty(d::Union{Data,Facet}, sym::Symbol)
    # treat VGElement fieldnames as usual
	(sym in fieldnames(VGElement)) && return getfield(d, sym)
    # TODO : throw error for data colums named "__tracking" or "__trie" or "__id"

    f = VGElement{:generic}()
    insert!(f, [:field], sym)
    insert!(f, [:data], d)
    
    f
end

