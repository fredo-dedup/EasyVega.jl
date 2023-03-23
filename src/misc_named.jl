### other named elements  ##################################################### 

########### Signals ###
export Signal

const Signal = VGElement{:Signal}

# TODO : signals with bindings should be at root level, enforce that

# special constructor for simple expressions String =>  (update= "expression")
VGElement{:Signal}(expr::AbstractString) = VGElement{:Signal}(;update=expr)



########### Projection ##
export Projection

const Projection = VGElement{:Projection}

########### Style ##
export Style

const Style = VGElement{:Style}

