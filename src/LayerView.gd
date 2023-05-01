extends TextureRect
class_name Distortionator_LayerView

var uniform_list := {}

func _ready():
	material = ShaderMaterial.new()

func set_shader(shader : Shader):
	material.shader = shader
	uniform_list = ShaderInspector.get_uniform_list(shader.code)

func set_uniform(uniform_name : String, value):
	material.set_shader_param(uniform_name, value)
	uniform_list[uniform_name].value = value

func get_uniform(uniform_name : String, value):
	return material.get_shader_param(uniform_name)
