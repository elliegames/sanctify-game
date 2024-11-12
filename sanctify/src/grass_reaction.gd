extends MultiMeshInstance3D

var cursor: Cursor


func _ready() -> void:
	cursor = get_parent().get_parent().get_parent().get_node("Cursor") as Cursor


func _process(delta: float) -> void:
	set_instance_shader_parameter("cursor_position", cursor.position)
