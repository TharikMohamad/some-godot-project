extends Node2D

@onready var tilemap: Node2D = $TileMap
@onready var guilda: Node2D = $Guild
@onready var interior_container: Node2D = $InteriorContainer
@onready var character: CharacterBody2D = $Character
@onready var camera: Camera2D = $Camera

func _ready() -> void:
	character.call_deferred("follow_camera", camera)


func enter_interior(interior_scene_path: String, spawn_pos: Vector2) -> void:
	if interior_scene_path.is_empty():
		return

	if tilemap.get_parent() == self:
		remove_child(tilemap)
	if guilda.get_parent() == self:
		remove_child(guilda)

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

	if tilemap.get_parent() == null:
		add_child(tilemap)
		move_child(tilemap, 0)
	if guilda.get_parent() == null:
		add_child(guilda)
		move_child(guilda, 1)

	character.position = outside_spawn_pos.snapped(Vector2.ONE * 32)
	character.target_position = character.position
	character.is_moving = false
