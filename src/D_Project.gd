extends Resource
class_name Distortionator_Project

## Class for a Distortionator Project.

## A reference to the core:
var core

## The layers of the current project,
## as an array of [D_Layer].
var layers : Array

const layer_view_scene := preload("res://scenes/LayerView.tscn")

## References to the nodes that represent the layers.
var layer_views : Array

func create_layer(name : String):
	pass

func import_file(file_path : String):
	pass

func export_file(file_path : String):
	pass
