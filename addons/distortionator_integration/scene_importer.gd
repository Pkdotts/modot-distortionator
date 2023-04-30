tool
extends EditorSceneImporter

func _get_extensions():
	return ["dsp", "bbg"]

func _get_import_flags():
	return IMPORT_SCENE

func _import_scene(path : String, flags : int, bake_fps : int):
	var file := ConfigFile.new()
	var node := PanelContainer.new()
	node.name = "BBG"
	
	var err = file.load(path)
	
	if err != OK:
		return null
	
	var layer_sections : PoolStringArray = file.get_sections()
	layer_sections.remove(0)
	
	var shader_path_prefix = file.get_value("", "shader_folder", "res://")
	var texture = file.get_value("", "texture_folder", "res://")
	
	for layer_section in layer_sections:
		var keys : Array = file.get_section_keys(layer_section)
		
		if not "shader" in keys:
			push_error("Layer %s doesn't contain a shader." % layer_section)
			continue
		
		keys.erase("shader")
		
		var shader_path : String = (
			shader_path_prefix + "/" +
			str(file.get_value(layer_section, "shader", "shader.res"))
		).simplify_path()
		var shader : Shader = load(shader_path)
		
		if not shader:
			push_error("Error loading shader at %s." % shader_path)
			continue
		
		var material := ShaderMaterial.new()
		material.shader = shader
		
		var layer_node := TextureRect.new()
		layer_node.texture = preload("res://addons/distortionator_integration/background.png")
		layer_node.stretch_mode = TextureRect.STRETCH_SCALE
		layer_node.material = material
		layer_node.name = layer_section
		node.add_child(layer_node, true)
		layer_node.owner = node
		
		if "texture" in keys:
			keys.erase("texture")
			var texture_path : String = file.get_value(layer_section,"texture","res://")
			var new_texture : Texture = load(texture_path)
			if new_texture:
				layer_node.texture = new_texture
			else:
				push_error("Error loading texture at %s." % texture_path)
		if "texture_stretch" in keys:
			var stretch_modes = [
				"STRETCH_SCALE_ON_EXPAND",
				"STRETCH_SCALE",
				"STRETCH_TILE",
				"STRETCH_KEEP"
			]
			keys.erase("texture_stretch")
			var texture_stretch : String = file.get_value(layer_section,"texture","STRETCH_SCALE")
			layer_node.stretch_mode = stretch_modes.find(texture_stretch)
		
		# Set the values for the uniforms!
		for key in keys:
			material.set_shader_param(
				key,
				file.get_value(layer_section, key, null)
			)
	
	return node
