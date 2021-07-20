extends Area




# Declare member variables here. Examples:
export var titel = "example title"
export var description = "tweet tweet I do"
export var museum = "I am from museum x.z"

 #(new_titel,new_description,new_museum)
signal set_attribut(new_text,new_description,new_museum)


# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	get_tree().call_group("UI","attribut")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass






func _on_Player_hitting_object(collider):
	print(collider)
	emit_signal("set_attribut", titel, description, museum)
#	print(self)
#	if collider == self:

#,titel,description,museum
