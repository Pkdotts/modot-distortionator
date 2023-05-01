extends HBoxContainer
class_name UniformEditor

var uniform
var editor

signal changed(new_value)
signal uset(uniform_name, new_value)

func set_name(uniform_name : String):
	$lbl_uniform_name.text = uniform_name.capitalize()
	name = "u_" + uniform_name

func setup(uniform : Dictionary):
	self.uniform = uniform
	set_name(uniform.name)
	editor = get_node_or_null(uniform.type)
	if editor:
		editor.visible = true
	
	if not uniform.value:
		uniform.value = get_default_value(uniform.type)
	else:
		match uniform.type:
			"float", "int":
				editor.value = uniform.value
			"vec2":
				editor.get_node("x").value = uniform.value.x
				editor.get_node("y").value = uniform.value.y
			"vec3":
				editor.get_node("x").value = uniform.value.x
				editor.get_node("y").value = uniform.value.y
				editor.get_node("z").value = uniform.value.z
			"vec4":
				editor.get_node("x").value = uniform.value.x
				editor.get_node("y").value = uniform.value.y
				editor.get_node("z").value = uniform.value.z
				editor.get_node("w").value = 0

func set_value_no_signal(new_value, update_editor):
	uniform.value = new_value

func set_value(new_value, update_editor = true):
	set_value_no_signal(new_value, update_editor)
	emit_signal("changed", uniform.value)
	emit_signal("uset", uniform.name, uniform.value)

func set_field_no_signal(field:String, new_value, update_editor):
	uniform.value[field] = new_value
	if update_editor:
		editor.get_node(field).value = uniform.value[field]

func set_field(field:String, new_value, update_editor = true):
	set_field_no_signal(field, new_value, update_editor)
	emit_signal("changed", uniform.value)
	emit_signal("uset", uniform.name, uniform.value)

func get_default_value(type : String):
	match type:
		"float":
			return 0.0
		"int":
			return 0
		"vec2":
			return Vector2()
		"vec3":
			return Vector3()
		"vec4":
			return Vector3()


func _on_float_value_changed(value):
	set_value(value)

func _on_x_value_changed(value):
	set_field("x", value)

func _on_y_value_changed(value):
	set_field("y", value)

func _on_z_value_changed(value):
	set_field("z", value)

func _on_w_value_changed(value):
	set_field("w", value)
