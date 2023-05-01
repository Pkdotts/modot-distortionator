extends TextureRect

export var viewport_path : NodePath setget set_viewport_path

func set_viewport_path(path):
	viewport_path = path
	if path:
		var viewport = get_node_or_null(viewport_path)
		if viewport:
			texture = viewport.get_texture()

func _ready():
	if viewport_path:
		texture = get_node(viewport_path).get_texture()
