extends Node2D

@onready var interior_container: Node2D = $InteriorContainer
@onready var character: CharacterBody2D = $Character
@onready var camera: Camera2D = $Camera

var exterior_nodes: Array[Node] = []

func _ready() -> void:
	character.call_deferred("follow_camera", camera)
	for child in get_children():
		if child != interior_container and child != character and child != camera:
			exterior_nodes.append(child)


func enter_interior(interior_scene_path: String, spawn_pos: Vector2) -> void:
	if interior_scene_path.is_empty():
		return

	for node in exterior_nodes:
		if node.get_parent() == self:
			remove_child(node)

	for child in interior_container.get_children():
		child.queue_free()

	var interior: Node2D = load(interior_scene_path).instantiate()
	interior_container.add_child(interior)

	character.position = spawn_pos.snapped(Vector2.ONE * 32)
	character.target_position = character.position
	character.is_moving = false


func exit_interior(outside_spawn_pos: Vector2) -> void:
	for child in interior_container.get_children():
		child.queue_free()

	for i in range(exterior_nodes.size()):
		var node := exterior_nodes[i]
		if node.get_parent() == null:
			add_child(node)
			move_child(node, i)

	character.position = outside_spawn_pos.snapped(Vector2.ONE * 32)
	character.target_position = character.position
	character.is_moving = false
