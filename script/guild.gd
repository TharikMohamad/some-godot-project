extends Node2D

@onready var character: CharacterBody2D = get_node_or_null("../Character")
@onready var camera: Camera2D = get_node_or_null("../Camera")

func _ready() -> void:
	if character and camera:
		character.follow_camera(camera)
	if Global.spawn_position != Vector2.ZERO and character:
		character.position = Global.spawn_position
		Global.spawn_position = Vector2.ZERO
