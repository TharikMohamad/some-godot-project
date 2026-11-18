extends CharacterBody2D

@onready var animationplayer: AnimationPlayer = $texture/AnimationPlayer

const TILE_SIZE: int = 32
const WALK_SPEED: float = 160.0
const RUN_SPEED: float = 320.0
const ROLL_SPEED: float = 480.0
const ROLL_COOLDOWN: float = 1.5

var is_moving: bool = false
var target_position: Vector2 = Vector2.ZERO
var current_speed: float = WALK_SPEED

var roll_queued: bool = false
var can_roll: bool = true
var facing_direction: Vector2 = Vector2.DOWN
var input_queue: Array[String] = []


func _ready() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	target_position = position
	update_idle_animation()


func _physics_process(delta: float) -> void:
	update_input_queue()

	if Input.is_action_just_pressed("roll") and can_roll:
		roll_queued = true

	if is_moving:
		position = position.move_toward(target_position, current_speed * delta)
		if position.distance_to(target_position) < 0.5:
			position = target_position
			is_moving = false
			animationplayer.speed_scale = 1.0
		return

	var direction := get_priority_direction()

	if direction != Vector2.ZERO:
		facing_direction = direction
		update_animation(facing_direction)

	if roll_queued:
		roll_queued = false
		try_roll(facing_direction)
		return

	if direction != Vector2.ZERO:
		try_move(direction)
	else:
		animationplayer.speed_scale = 1.0
		update_idle_animation()


func update_idle_animation() -> void:
	$texture.flip_h = false
	if facing_direction == Vector2.LEFT:
		animationplayer.play("idle_l")
	elif facing_direction == Vector2.RIGHT:
		animationplayer.play("idle_r")
	elif facing_direction == Vector2.UP:
		animationplayer.play("idle_u")
	else:
		animationplayer.play("idle_b")


func try_move(direction: Vector2) -> void:
	var target_vector := direction * TILE_SIZE
	if is_path_clear(target_vector):
		current_speed = RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
		target_position = position + target_vector
		is_moving = true


func try_roll(direction: Vector2) -> void:
	var valid_vector := Vector2.ZERO
	for i in range(1, 5):
		var check_vector := direction * (TILE_SIZE * i)
		if is_path_clear(check_vector):
			valid_vector = check_vector
		else:
			break

	if valid_vector != Vector2.ZERO:
		can_roll = false
		start_roll_cooldown()
		animationplayer.speed_scale = 2.0
		update_animation(direction)
		current_speed = ROLL_SPEED
		target_position = position + valid_vector
		is_moving = true


func is_path_clear(offset: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + offset,
		collision_mask,
		[self]
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result := space_state.intersect_ray(query)
	
	if not result.is_empty():
		return false
	return true


func update_input_queue() -> void:
	var actions: Array[String] = ["ui_left", "ui_right", "ui_up", "ui_down"]
	for action in actions:
		if Input.is_action_just_pressed(action):
			input_queue.erase(action)
			input_queue.append(action)
		elif not Input.is_action_pressed(action):
			input_queue.erase(action)


func get_priority_direction() -> Vector2:
	if input_queue.is_empty():
		return Vector2.ZERO
	match input_queue.back():
		"ui_left": return Vector2.LEFT
		"ui_right": return Vector2.RIGHT
		"ui_up": return Vector2.UP
		"ui_down": return Vector2.DOWN
	return Vector2.ZERO


func update_animation(direction: Vector2) -> void:
	if not is_moving:
		animationplayer.speed_scale = 1.8 if Input.is_action_pressed("run") else 1.0

	if direction.x != 0:
		$texture.flip_h = direction.x > 0
		animationplayer.play("walking_h")
	elif direction.y < 0:
		animationplayer.play("walking_up")
	elif direction.y > 0:
		animationplayer.play("walking_down")


func start_roll_cooldown() -> void:
	await get_tree().create_timer(ROLL_COOLDOWN).timeout
	can_roll = true


func follow_camera(camera: Camera2D) -> void:
	var rt := get_node_or_null("remote_transform") as RemoteTransform2D
	if rt and camera:
		rt.remote_path = rt.get_path_to(camera)
