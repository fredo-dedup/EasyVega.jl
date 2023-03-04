########### Marks  #########################################################""

export ArcMark, AreaMark, GroupMark, ImageMark, LineMark, PathMark, RectMark, 
    RuleMark, ShapeMark, SymbolMark, TextMark, TrailMark

const Mark = VGElement{:Mark}

ArcMark(;nargs...)    = Mark(type=:arc; nargs...)
AreaMark(;nargs...)   = Mark(type=:area; nargs...)
ImageMark(;nargs...)  = Mark(type=:image; nargs...)
LineMark(;nargs...)   = Mark(type=:line; nargs...)
PathMark(;nargs...)   = Mark(type=:path; nargs...)
RectMark(;nargs...)   = Mark(type=:rect; nargs...)
RuleMark(;nargs...)   = Mark(type=:rule; nargs...)
ShapeMark(;nargs...)  = Mark(type=:shape; nargs...)
SymbolMark(;nargs...) = Mark(type=:symbol; nargs...)
TextMark(;nargs...)   = Mark(type=:text; nargs...)
TrailMark(;nargs...)  = Mark(type=:trail; nargs...)


### group mark  ###############################################################
const Group = VGElement{:Group}

function GroupMark(;nargs...)
    e = Group(type=:group; nargs...)
    
    #  compared to tracking of common elements we need : 
    #    - the update the group paths by appending the current group
    #    - updating the children of this group element
    #    - checking for new defs (TODO)
    #    - Facet handling  (TODO)
    tracks = e.tracking

    # assign orphan mentions to this group
    for (el, gr) in tracks.mentions
        if gr === nothing
            tracks.mentions[el] = e
        end
    end

    # assign orphan fixeddefs to this group
    for (el, gr) in tracks.fixeddefs
        if gr === nothing
            tracks.fixeddefs[el] = e
        end
    end

    # update the grouppaths
    for (el, pos) in tracks.grouppaths
        tracks.grouppaths[el] = (pos === nothing) ? [e] : [e; pos]
    end
    tracks.grouppaths[e] = []  # add this group too

    # all those groups are children of current group
    tracks.children[e] = keys(tracks.children)
    e
end

