extends Control

onready var text_titel = get_node("Panel/label_titel")
onready var text_description = get_node("Panel/label_description")
onready var text_musem = get_node("Panel/label_museum")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.



#
func _on_Player_set_UItexts(titel, description, museum):

	text_titel.text = titel
	text_description.text = description
	text_musem.text = museum

	pass # Replace with function body.
