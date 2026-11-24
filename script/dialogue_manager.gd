extends Node

signal dialogue_started
signal dialogue_finished(npc_id: String)

var dialogue_scene := preload("res://scene/dialogue_box.tscn")
var box_instance: CanvasLayer = null

var is_active: bool = false
var current_lines: Array[String] = []
var current_index: int = 0
var current_npc_id: String = ""
var on_finish_callback: Callable = Callable()


func _ready() -> void:
	box_instance = dialogue_scene.instantiate()
	add_child(box_instance)
	box_instance.hide()


func start_dialogue(npc_name: String, lines: Array[String], npc_id: String = "", callback: Callable = Callable()) -> void:
	if is_active or lines.is_empty():
		return

	is_active = true
	current_lines = lines
	current_index = 0
	current_npc_id = npc_id
	on_finish_callback = callback

	box_instance.get_node("Panel/MarginContainer/VBoxContainer/NameLabel").text = npc_name
	box_instance.show()
	show_current_line()
	dialogue_started.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		next_line()


func show_current_line() -> void:
	var label := box_instance.get_node("Panel/MarginContainer/VBoxContainer/TextLabel")
	label.text = current_lines[current_index]


func next_line() -> void:
	current_index += 1
	if current_index < current_lines.size():
		show_current_line()
	else:
		end_dialogue()


func end_dialogue() -> void:
	is_active = false
	box_instance.hide()
	var finished_id := current_npc_id
	var cb := on_finish_callback
	
	current_lines.clear()
	current_npc_id = ""
	on_finish_callback = Callable()

	dialogue_finished.emit(finished_id)
	if cb.is_valid():
		cb.call()
