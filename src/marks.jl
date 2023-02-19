########### Marks  #########################################################""

export ArcMark, AreaMark, GroupMark, ImageMark, LineMark, PathMark, RectMark, 
    RuleMark, ShapeMark, SymbolMark, TextMark, TrailMark


const Mark = VGElement{:Mark}

ArcMark(;nargs...) = Mark(type=:arc; nargs...)
AreaMark(;nargs...) = Mark(type=:area; nargs...)
GroupMark(;nargs...) = Mark(type=:group; nargs...)
ImageMark(;nargs...) = Mark(type=:image; nargs...)
LineMark(;nargs...) = Mark(type=:line; nargs...)
PathMark(;nargs...) = Mark(type=:path; nargs...)
RectMark(;nargs...) = Mark(type=:rect; nargs...)
RuleMark(;nargs...) = Mark(type=:rule; nargs...)
ShapeMark(;nargs...) = Mark(type=:shape; nargs...)
SymbolMark(;nargs...) = Mark(type=:symbol; nargs...)
TextMark(;nargs...) = Mark(type=:text; nargs...)
TrailMark(;nargs...) = Mark(type=:trail; nargs...)






