extends CharacterBody2D
signal died
signal block_broken

var dead := false
@export var spin_speed := 1.5 # radians/sec (try 0.5–3.0)
@onready var sprite := $Sprite2D
@export var speed := 400.0
@export var speed_increase_per_block := 15.0
@export var max_speed := 700.0
var base_speed := 0.0

func start(pos: Vector2) -> void:
	dead = false
	global_position = pos
	speed = base_speed
	show()

	randomize()
	var min_angle := deg_to_rad(30)   # minimum downward angle
	var max_angle := deg_to_rad(75)   # maximum downward angle

	var angle := randf_range(min_angle, max_angle)

	# Randomize left/right
	if randf() < 0.5:
		angle = PI - angle

	velocity = Vector2.RIGHT.rotated(angle) * speed

func die() -> void:
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	hide()
	emit_signal("died")

func _ready() -> void:
	hide()
	base_speed = speed
	
	randomize()
	var angle := randf_range(-PI / 2, PI / 2)
	if randf() < 0.5:
		angle += PI
	velocity = Vector2.RIGHT.rotated(angle) * speed

func _physics_process(delta: float) -> void:
	if dead:
		return

	sprite.rotation += spin_speed * delta

	var collision := move_and_collide(velocity * delta)
	if collision:
		var col := collision.get_collider()
		
		if col and col.is_in_group("kill_floor"):
			die()
			return
		
		if col and col.is_in_group("block"):
			col.queue_free() # or col.call_deferred("queue_free")
			speed = min(speed + speed_increase_per_block, max_speed)
			emit_signal("block_broken")

		velocity = velocity.bounce(collision.get_normal()).normalized() * speed
