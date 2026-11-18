extends Area2D

@export var is_exit: bool = false
@export_file("*.tscn") var interior_scene: String
@export var spawn_position: Vector2

var player_ref: CharacterBody2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_ref = body


func _on_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null


func _unhandled_input(event: InputEvent) -> void:
	if player_ref and event.is_action_pressed("interact"):
		var world := get_tree().current_scene
		if is_exit and world.has_method("exit_interior"):
			world.exit_interior(spawn_position)
		elif not is_exit and world.has_method("enter_interior"):
			world.enter_interior(interior_scene, spawn_position)
