extends RigidBody3D

@onready var animation_player: AnimationPlayer = $beam/AnimationPlayer
@onready var enemy_ufo_beam: MeshInstance3D = $"beam/ufo-beam/enemy-ufo-beam"
@onready var enemy_ufo_beam_burst: MeshInstance3D = $"beam/ufo-beam-burst/enemy-ufo-beam-burst"
@onready var beam: Area3D = $beam


const VELOCITY: float = 10.0
const MAX_LEVEL: float = 6.0
const INITIAL_LEVEL: float = 1.0


var level: float = INITIAL_LEVEL
var bursting: bool = false

func _ready() -> void:
	position.y = INITIAL_LEVEL
	scale = scale * INITIAL_LEVEL
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

func start_burst() -> void:
	bursting = true
	animation_player.stop()
	animation_player.play("de_active")
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
	enemy_ufo_beam.visible = false
	enemy_ufo_beam_burst.visible = false

func drag_object(body: Node) -> void:
	print_debug(body)
