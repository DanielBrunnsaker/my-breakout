extends Node2D

@export var thickness := 40.0

@onready var left := $LeftWall
@onready var right := $RightWall
@onready var top := $TopWall
@onready var bottom := $BottomWall

func _ready() -> void:
	place_to_viewport()

func place_to_viewport() -> void:
	var rect := get_viewport().get_visible_rect()
	var w := rect.size.x
	var h := rect.size.y

	# Important: keep Bounds at (0,0) for this method
	global_position = Vector2.ZERO

	# Position wall bodies (their origin is center of their CollisionShape)
	left.global_position = Vector2(-thickness * 0.5, h * 0.5)
	right.global_position = Vector2(w + thickness * 0.5, h * 0.5)
	top.global_position = Vector2(w * 0.5, -thickness * 0.5)
	bottom.global_position = Vector2(w * 0.5, h + thickness * 0.5)

	# Set collision sizes
	(left.get_node("CollisionShape2D").shape as RectangleShape2D).size = Vector2(thickness, h + 2.0 * thickness)
	(right.get_node("CollisionShape2D").shape as RectangleShape2D).size = Vector2(thickness, h + 2.0 * thickness)
	(top.get_node("CollisionShape2D").shape as RectangleShape2D).size = Vector2(w + 2.0 * thickness, thickness)
	(bottom.get_node("CollisionShape2D").shape as RectangleShape2D).size = Vector2(w + 2.0 * thickness, thickness)
