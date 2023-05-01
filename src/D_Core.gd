extends Node
class_name Distortionator_Core

#-- THE UI --#

## The containers

onready var project_file_dialog : FileDialog = $"ProjectFileDialog"

onready var shader_edit_panel : VBoxContainer = $"p/v/HSplit/ShaderEditPanel"
onready var shaders_container : TabContainer = $"p/v/HSplit/ShaderEditPanel/TabContainer"

onready var layers_viewport : Viewport = $"p/Viewport"
onready var layers_container : Control = $"p/Viewport/LayerContainer"
onready var layers_list : ItemList = $"p/v/HSplit/PropertyEditPanel/dock_proj_layers/Layers/layer_list"

onready var parameter_dock : Control = $"p/v/HSplit/PropertyEditPanel/dock_properties/Parameters"
onready var uniform_editors_container : Control = $"p/v/HSplit/PropertyEditPanel/dock_properties/Parameters/uniforms/uniform_editors"

## The resources

export var default_shader : Shader

const play_icon = preload("res://assets/icons/Play.png")
const pause_icon = preload("res://assets/icons/Pause.png")
const layer_view_scene = preload("res://scenes/LayerView.tscn")
const shader_editor_scene = preload("res://scenes/ShaderEditor.tscn")
const uniform_editor_scene = preload("res://scenes/UniformEditor.tscn")

func _ready():
	setup_ui()
	import_settings()

func setup_ui():
	#$"p/v/HSplit/ShaderEditPanel/TabContainer/Default".text = preload("res://assets/default_shader.tres").code
	pass

func import_settings():
	var settings

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

var project_file_dialog_mode := "New Project"

func _on_btn_project_new_pressed():
	project_file_dialog_mode = "New Project"
	project_file_dialog.mode = FileDialog.MODE_SAVE_FILE
	project_file_dialog.popup_centered(Vector2(500, 600))

func _on_btn_project_open_pressed():
	project_file_dialog_mode = "Open Project"
	project_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	project_file_dialog.popup_centered(Vector2(500, 600))

func _on_ProjectFileDialog_file_selected(path):
	match project_file_dialog_mode:
		"New Project":
			new_project(path)
		"Open Project":
			load_project(path)
		"Save Project As":
			save_path = path
			export_project(save_path)

func _on_btn_project_save_pressed():
	if save_path:
		export_project(save_path)
	else:
		_on_btn_project_save_as_pressed()

func _on_btn_project_save_as_pressed():
	project_file_dialog_mode = "Save Project As"
	project_file_dialog.mode = FileDialog.MODE_SAVE_FILE
	project_file_dialog.popup_centered(Vector2(500, 600))

#-- LAYERS --#

func _on_btn_layer_add_pressed():
	create_new_layer()

func _on_btn_layer_remove_pressed():
	if layers_list.is_anything_selected():
		delete_layer(layers_list.get_selected_items()[0])

func _on_layer_list_item_selected(index):
	select_layer(index)

# Toggle the Shader editor on or off.
func _on_btn_run_pressed():
	set_playing_shader(not is_playing_shader)

#-- SETTINGS --#

var settings := {
	"default_shader": "assets/default_shader.tres",
	"default_texture": "test/bbg_citrus.png"
}

func get_real_path(path : String):
	return (project_path + "/" + path).simplify_path()

func get_res_path(path : String):
	return ("res://" + path).simplify_path()

func make_real_path_res(path : String):
	path = path.simplify_path()

func get_godot_project_path(path : String):
	var dir := Directory.new()
	var dir_path := path.get_base_dir()
	
	while true:
		dir.open(dir_path)
		if dir.file_exists("project.godot"):
			return dir_path
		var err = dir.change_dir("../")
		if not err == OK:
			break
	return null

#-- PROJECT --#

var shader_folder : String = "res://"
var texture_folder : String = "res://"
var save_path : String = "res://example_project.dsp"
var project_path : String = "/home/"
var unsaved : bool = false

var opened_shaders := {}

func new_project(path : String):
	print("Creating new project at %s." % path)
	var godot_project_path = get_godot_project_path(path)
	
	if not godot_project_path:
		OS.alert("File must be inside of a Godot project.", "Couldn't find project.godot")
		return
	
	close_project()
	
	project_path = godot_project_path
	shader_folder = "res://"
	texture_folder = "res://"
	save_path = path
	unsaved = false
	
	export_project(path)

func close_project():
	# Remove all the current layers.
	for layer in layers_container.get_children():
		layers_container.remove(layer)
		layer.queue_free()
	layers_list.clear()
	clear_uniform_editors()
	for shader_edit in shaders_container.get_children():
		shaders_container.remove(shader_edit)
		shader_edit.queue_free()
	opened_shaders.clear()

func load_project(path : String):
	var file = ConfigFile.new()
	var err = file.load(path)
	
	if not err == OK:
		OS.alert("Malformed file.")
		return
	
	var godot_project_path = get_godot_project_path(path)
	
	if godot_project_path == null:
		OS.alert("File must be inside of a Godot project.", "Couldn't find project.godot")
		return
	
	project_path = godot_project_path
	
	shader_folder = file.get_value("", "shader_folder", "res://")
	texture_folder = file.get_value("", "texture_folder", "res://")
	
	# TODO: Handle unsaved changes.
	OS.alert("Changes won't be recovered. Pedro should fix this.", "TODO")
	
	close_project()
	
	var sections : Array = file.get_sections()
	sections.erase("")
	
	for layer in sections:
		var layer_view : Distortionator_LayerView = create_new_layer(false)
		var keys : Array = file.get_section_keys(layer)
		keys.erase("shader")
		
		var shader_path = get_real_path(file.get_value(layer, "shader"))
		var shader = load(shader_path)
		
		if not shader or not shader is Shader:
			OS.alert("Not a valid Shader resource.", "Discarding Layer.")
			continue
		
		open_shader(shader_path, shader)
		
		layer_view.set_shader(shader)
		
		for uniform_name in keys:
			layer_view.set_uniform(uniform_name, file.get_value(layer, uniform_name, null))
	regenerate_uniform_editors()


func export_project(path : String):
	var file = ConfigFile.new()
	
	file.set_value("", "shader_folder", shader_folder)
	file.set_value("", "texture_folder", shader_folder)
	
	for layer in layers_container.get_children():
		var section_name = layer.name
		# TODO: update the shader path resolution
		file.set_value(section_name, "shader", default_shader.resource_path.trim_prefix("res://"))
		for uniform in layer.uniform_list.values():
			file.set_value(section_name, uniform.name, uniform.value)
	
	file.save(path)

#-- BACKEND --#

var is_playing_shader : bool = true

func set_playing_shader(playing : bool):
	is_playing_shader = playing
	shader_edit_panel.visible = not playing
	
	$"p/v/HSplit/PropertyEditPanel/Toolbar/btn_run".icon = pause_icon if is_playing_shader else play_icon

func open_shader(shader_path : String, shader = null):
	print(opened_shaders)
	if shader is Shader:
		if not shader_path in opened_shaders.keys():
			opened_shaders[shader_path] = shader
			var shader_editor = shader_editor_scene.instance()
			shader_editor.name = shader_path.get_file()
			shader_editor.readonly = true
			shaders_container.add_child(shader_editor, true)
		return
	open_shader(shader_path, safe_load_resource(shader_path))

func safe_load_resource(path : String):
	return load(path)

## The currently selected layer, or -1 if no layer is selected.
var selected_layer : int = -1

func create_new_layer(use_defaults = true):
	var layer_view : Distortionator_LayerView = layer_view_scene.instance()
	layer_view.name = "Layer 0"
	layers_container.add_child(layer_view, true)
	
	if use_defaults:
		layer_view.set_shader(
			load_shader(get_res_path(settings.default_shader))
		)
		
		layer_view.texture = safe_load_resource(get_res_path(settings.default_texture))
	
	layers_list.add_item(layer_view.name)
	layers_list.select(layers_list.get_item_count() - 1)
	
	select_layer(layers_list.get_item_count() - 1)
	
	return layer_view

func delete_layer(index : int):
	layers_container.get_child(0).free()
	layers_list.remove_item(index)

func move_layer(index : int, to : int):
	layers_list.move_item(index, to)
	layers_container.move_child(layers_container.get_child(index), to)

func select_layer(index):
	selected_layer = index
	regenerate_uniform_editors()

func regenerate_uniform_editors():
	clear_uniform_editors()
	
	var layer_view = layers_container.get_child(selected_layer)
	
	for i in layer_view.uniform_list.values():
		var uniform_editor : UniformEditor = uniform_editor_scene.instance()
		uniform_editor.setup(i)
		uniform_editors_container.add_child(uniform_editor, true)
		uniform_editor.connect("uset", self, "set_layer_uniform")
	
	parameter_dock.name = layers_container.get_child(selected_layer).name

func clear_uniform_editors():
	for i in uniform_editors_container.get_children():
		uniform_editors_container.remove_child(i)
		i.free()

func set_layer_uniform(uniform : String, value):
	var current_layer : Distortionator_LayerView = layers_container.get_child(selected_layer)
	print("Setting uniform %s to %s." % [uniform, value])
	current_layer.set_uniform(uniform, value)

func load_shader(shader_path : String):
	return load(shader_path)
