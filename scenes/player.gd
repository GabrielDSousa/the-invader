extends RigidBody3D

@onready var animation_player: AnimationPlayer = $beam/AnimationPlayer
@onready var ufo_beam: MeshInstance3D = $"beam/ufo-beam"
@onready var ufo_beam_burst: MeshInstance3D = $"beam/ufo-beam-burst"
@onready var ufo_mesh: MeshInstance3D = $ufo
@onready var player_collision: CollisionShape3D = $collision
@onready var beam_collision: CollisionShape3D = $beam/collision
@onready var beam: Area3D = $beam
@onready var xp_value: Label = $view/HUD/XP/value
@onready var level_value: Label = $view/HUD/level/value
@onready var camera: Camera3D = $view/Camera


const VELOCITY: float = 10.0
const MAX_LEVEL: float = 6.0
const INITIAL_LEVEL: float = 1.0
const MAX_LAYER: int = 4
const XP_WEIGHT: int = 20

var current_layer = MAX_LAYER
var level: float = INITIAL_LEVEL
var bursting: bool = false

func _ready() -> void:
	position.y = INITIAL_LEVEL
	set_scale_from_multiplier(INITIAL_LEVEL)
	beam.connect("body_entered", drag_object)


func _physics_process(_delta: float) -> void:
	# Movement
	if not bursting:
		if Input.is_action_pressed("ui_up"):
			apply_force(Vector3(-VELOCITY, 0.0, 0.0))
		elif Input.is_action_pressed("ui_down"):
			apply_force(Vector3(VELOCITY, 0.0, 0.0))
		if Input.is_action_pressed("ui_right"):
			apply_force(Vector3(0.0, 0.0, -VELOCITY))
		elif Input.is_action_pressed("ui_left"):
			apply_force(Vector3(0.0, 0.0, VELOCITY))

	# Beam
	if Input.is_action_pressed("ui_accept"):
		if not bursting:
			start_burst()

	if Input.is_action_just_released("ui_accept"):
		if bursting:
			stop_burst()
			current_layer = MAX_LAYER

func start_burst() -> void:
	bursting = true
	animation_player.stop()
	animation_player.play("de_active")
	beam_collision.set_deferred("disabled", false)
	await animation_player.animation_finished
	burst()

func burst() -> void:
	if bursting:
		animation_player.play("burst")

func stop_burst() -> void:
	bursting = false
	animation_player.stop()
	animation_player.play_backwards("de_active")
	await animation_player.animation_finished
	beam_collision.set_deferred("disabled", true)
	ufo_beam.visible = false
	ufo_beam_burst.visible = false

func drag_object(body: Node3D) -> void:
	while current_layer > 0:
		if body is GridMap:
			var map_position: Vector3i = body.local_to_map(beam.global_position)
			map_position = Vector3i(map_position.x, current_layer, map_position.z)
			var item_id: int = body.get_cell_item(map_position)
			if item_id != -1:
				var mesh: Mesh = body.mesh_library.get_item_mesh(item_id)
				var mesh_instance := MeshInstance3D.new()
				mesh_instance.position = body.map_to_local(map_position)
				mesh_instance.mesh = mesh
				body.set_cell_item(map_position, body.INVALID_CELL_ITEM)
				body.add_child(mesh_instance)

				var xp = mesh_instance.get_aabb().get_volume()

				var time_left: float = xp * 100
				while time_left > 0:
					if not bursting:
						# Revert drag
						mesh_instance.queue_free()
						body.set_cell_item(map_position, item_id)
						current_layer = MAX_LAYER
						return
					# Scale Y and and fade out
					mesh_instance.scale.y += 0.1
					time_left -= 1
					await get_tree().create_timer(0.5).timeout
				mesh_instance.queue_free()
				add_xp(xp)
		current_layer -= 1


func set_scale_from_multiplier(multiplier: float) -> void:
	beam.scale = beam.scale.lerp(beam.scale * multiplier, 1.0)
	ufo_mesh.scale = ufo_mesh.scale.lerp(ufo_mesh.scale * multiplier, 1.0)
	player_collision.scale = player_collision.scale.lerp(player_collision.scale * multiplier, 1.0)
	player_collision.scale = player_collision.scale.lerp(player_collision.scale * multiplier, 1.0)
	position = position.lerp(Vector3(position.x, ufo_mesh.scale.y, position.z), 1.0)

func add_xp(value: float) -> void:
	xp_value.text = var_to_str(ceil(float(xp_value.text) + (value) + XP_WEIGHT))
	if (float(xp_value.text) > (100 * level)):
		level_up()

func level_up() -> void:
	level += 1
	level_value.text = var_to_str(level)
	set_scale_from_multiplier(level)
