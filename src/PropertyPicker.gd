extends HBoxContainer
class_name PropertyPicker

var target_object : Object
var target_property : String
var target_property_type : String = "bool"
var editor
var sampler_file_dialog : FileDialog

signal changed(new_value)
signal uset(target_property, new_value)

func set_name(target_property : String):
	$lbl_property_name.text = target_property.capitalize()
	name = target_property

func setup(target_object, target_property, type : String):
	self.target_object = target_object
	self.target_property = target_property
	self.target_property_type = type
	set_name(target_property)
	editor = get_node_or_null(type)
	if editor:
		editor.visible = true

func set_editor_value(value):
	match target_property_type:
		"bool":
			editor.pressed = value
		"float", "int":
			editor.value = value
		"vec2":
			editor.get_node("x").value = value.x
			editor.get_node("y").value = value.y
		"vec3":
			editor.get_node("x").value = value.x
			editor.get_node("y").value = value.y
			editor.get_node("z").value = value.z
		"vec4":
			editor.get_node("x").value = value.x
			editor.get_node("y").value = value.y
			editor.get_node("z").value = value.z
			editor.get_node("w").value = 0
		"sampler2D":
			editor.get_node("preview").texture = value.file

func set_value_no_signal(new_value, update_editor):
	target_object.set(target_property, new_value)

func set_value(new_value, update_editor = true):
	set_value_no_signal(new_value, update_editor)
	emit_signal("changed", new_value)
	emit_signal("uset", target_property, new_value)

func set_field_no_signal(field:String, new_value, update_editor):
	target_object.set(target_property + ":" + field, new_value)
	if update_editor:
		editor.get_node(field).value = new_value

func set_field(field:String, new_value, update_editor = true):
	set_field_no_signal(field, new_value, update_editor)
	emit_signal("changed", target_object.get(target_property))
	emit_signal("uset", target_property, target_object.get(target_property))

func get_default_value(type : String):
	match type:
		"bool":
			return false
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
		"sampler2D":
			return null

func _on_bool_toggled(button_pressed):
	set_value(button_pressed)

func _on_int_value_changed(value):
	set_value(value)

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
