extends RigidBody3D

const VELOCITY: float = 1.0
const MAX_LEVEL: int = 6
const INITIAL_LEVEL: int = 1


var level: int = INITIAL_LEVEL

func _physics_process(delta: float) -> void:
# Basic Movement
# Todo: Upgrade to proper actions with mutiple ways to play
	if Input.is_action_pressed("ui_up"):
		apply_force(Vector3(-VELOCITY, 0.0, 0.0))
	elif Input.is_action_pressed("ui_down"):
		apply_force(Vector3(VELOCITY, 0.0, 0.0))
	if Input.is_action_pressed("ui_right"):
		apply_force(Vector3(0.0, 0.0, -VELOCITY))
	elif Input.is_action_pressed("ui_left"):
		apply_force(Vector3(0.0, 0.0, VELOCITY))
