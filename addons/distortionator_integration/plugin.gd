tool
extends EditorPlugin

var distortionator_format_importer = preload("res://addons/distortionator_integration/scene_importer.gd")

func _enter_tree():
	distortionator_format_importer = distortionator_format_importer.new()
	
	add_scene_import_plugin(distortionator_format_importer)

func _exit_tree():
	remove_scene_import_plugin(distortionator_format_importer)
