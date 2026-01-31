extends StaticBody2D

@export var speed := 400.0
var screen_size: Vector2

var dragging := false
var target_x := 0.0

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _unhandled_input(event: InputEvent) -> void:
	# Touch start/end
	if event is InputEventScreenTouch:
		dragging = event.pressed
		if dragging:
			target_x = event.position.x

	# Touch drag motion
	elif event is InputEventScreenDrag and dragging:
		target_x = event.position.x

	# Optional: mouse drag also works on desktop
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		if dragging:
			target_x = event.position.x
	elif event is InputEventMouseMotion and dragging:
		target_x = event.position.x

func _process(delta: float) -> void:
	var velocity := Vector2.ZERO

	# Keyboard input stays the same
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	# Touch input: move toward finger X if no keyboard input is active
	if velocity.x == 0 and dragging:
		var dx := target_x - global_position.x

		# Deadzone so it doesn't jitter
		if abs(dx) > 4.0:
			velocity.x = sign(dx)

	velocity = velocity.normalized() * speed
	position += velocity * delta

	# Clamp just X if you want (recommended), keep Y unchanged
	position.x = clamp(position.x, 0.0, screen_size.x)
