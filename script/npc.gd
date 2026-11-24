extends Node2D

signal dialogue_completed

@export var npc_id: String = ""
@export var npc_name: String = ""
@export_multiline var dialogue_lines: Array[String] = [
	"abacate"
]

@onready var interact_area: Area2D = $Area2D
var player_in_range: bool = false

func _ready() -> void:
	interact_area.body_entered.connect(_on_area_body_entered)
	interact_area.body_exited.connect(_on_area_body_exited)


func _on_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_in_range = true


func _on_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_in_range = false


func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not DialogueManager.is_active and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		DialogueManager.start_dialogue(npc_name, dialogue_lines, npc_id, _on_my_dialogue_finished)


func _on_my_dialogue_finished() -> void:
	dialogue_completed.emit()
	# Aqui você pode chamar códigos específicos por ID do personagem ou num script filho:
	match npc_id:
		pass
