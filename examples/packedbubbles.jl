# example adapted from https://vega.github.io/editor/#/examples/vega/packed-bubble-chart

using EasyVega


cx = Signal(update= "width  / 2")
cy = Signal(update= "height / 2")

gravityX = Signal(
  value= 0.2,
  bind=  (input="range", min=0, max=1)
)

gravityY = Signal(
  value= 0.1,
  bind=  (input="range", min=0, max=1)
)

table = Data(values=[
  (category= "A", amount= 0.28),
  (category= "B", amount= 0.55),
  (category= "C", amount= 0.43),
  (category= "D", amount= 0.91),
  (category= "E", amount= 0.81),
  (category= "F", amount= 0.53),
  (category= "G", amount= 0.19),
  (category= "H", amount= 0.87),
  (category= "I", amount= 0.28),
  (category= "J", amount= 0.55),
  (category= "K", amount= 0.43),
  (category= "L", amount= 0.91),
  (category= "M", amount= 0.81),
  (category= "N", amount= 0.53),
  (category= "O", amount= 0.19),
  (category= "P", amount= 0.87)
])


siz = LinearScale(domain= table.amount, range=[100,3000])
color = OrdinalScale(domain= table.category, range="ramp")


# The bubbles
nodes = SymbolMark(
  :fill => color(table.category),
  :xfocus => (signal= cx,),
  :yfocus => (signal= cy,),
  :update_size => siz(signal= "pow(2 * datum.amount, 2)"),
  :update_stroke => "white",
  :update_strokeWidth => 1,
  :update_tooltip => (signal= "datum",),

  # apply a force transform (both attrative toward center, and repulsive to avoid collisions)
  transform= [
    (
      type= "force",
      iterations= 100,
      static= false,
      forces= [
        (force= "collide", iterations= 2, radius_expr= "sqrt(datum.size) / 2"),
        (force= "center", x= (signal= cx,), y= (signal= cy,)),
        (force= "x", x= "xfocus", strength= (signal= gravityX,)),
        (force= "y", y= "yfocus", strength= (signal= gravityY,))
      ]
    )
  ]
)


# Textmark to show the category name 
#  this textmark is not based on a Data but on another Mark : nodes.
#  Data as sources allow to modify / annotate the mark, here we are  
#  simply printing a letter at the center of the bubble. 
txtmark = TextMark(
  # need to be specific here for the from_data field because the source is 
  #  another mark not data.
  from_data = nodes,  

  :align => "center",
  :baseline => "middle",
  :fontSize => 15,
  :fontWeight => "bold",
  :fill => "white",

  #  'x' and 'y' channels of the mark source appear as fields ,
  # 'category' is from the data source of the mark, hence the 'datum.category'
  :text => (field= "datum.category",),
  :update_x => (field= :x,),
  :update_y => (field= :y,),
)


VG( width= 400, height=400,
  padding= 20, background= "white", 
  autosize= "none",
  marks= [ nodes, txtmark]
 )


