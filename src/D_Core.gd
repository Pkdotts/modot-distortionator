extends Node
class_name Distortionator_Core

#-- THE UI --#

## The containers

onready var layers_containter : Control = $"p/LayerContainer"
onready var layers_list : ItemList = $"p/HSplit/VBoxContainer/layer_list"

onready var uniform_names_container : Control = $"p/HSplit/VBoxContainer/uniforms/uniform_names"
onready var uniform_editors_container : Control = $"p/HSplit/VBoxContainer/uniforms/uniform_editors"

func _ready():
	setup_ui()

func setup_ui():
	$"Toolbar/btn_File".get_popup().connect("id_pressed", self, "btn_file_id_pressed")
	$"Toolbar/btn_Project".get_popup().connect("id_pressed", self, "btn_project_id_pressed")

func btn_file_id_pressed(id : int):
	match id:
		0: # NEW
			pass
		1: # OPEN...
			pass
		2: # SAVE
			pass
		3: # SAVE AS...
			pass

func btn_project_id_pressed(id : int):
	match id:
		0: # IMPORT...
			pass
		1: # EXPORT...
			pass

#-- BACKEND --#

## The currently opened project
var current_project : Distortionator_Project

## The currently selected layer, or -1 if no layer is selected.
var selected_layer : int = -1
