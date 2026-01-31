extends Node

@onready var score_label: Label = get_node("UI/ScoreLabel")
@onready var start_screen: Control = get_node("UI/StartScreen")
@onready var game_over_screen: Control = get_node("UI/GameOverScreen")
@onready var congrats_screen := $UI/CongratsScreen
@onready var ball: Node = get_node("Ball")

@export var block_scene: PackedScene

@export var cols := 8
@export var rows := 4

@export var block_size := Vector2(55, 30) # spacing, not necessarily sprite size
@export var top_left := Vector2(40, 40)   # where the grid starts (world coords)
@export var gap := Vector2(2, 2)          # extra spacing between blocks

var score := 0
var playing := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if start_screen.visible or game_over_screen.visible:
			start_game()

func update_score_label() -> void:
	score_label.text = "%d" % score

func _on_block_broken() -> void:
	if not playing:
		return
	score += 1
	update_score_label()
	
	# If no blocks left -> win
	if $Blocks.get_child_count() == 0:
		show_congrats_screen()

func spawn_blocks() -> void:
	# Clear old blocks (useful for restart)
	for child in $Blocks.get_children():
		child.queue_free()

	for r in range(rows):
		for c in range(cols):
			var block := block_scene.instantiate() as Node2D
			block.position = top_left + Vector2(
					c * (block_size.x + gap.x),
					r * (block_size.y + gap.y)
			)
			$Blocks.add_child(block)
			

func show_start_screen() -> void:
	congrats_screen.visible = false
	playing = false
	start_screen.visible = true
	game_over_screen.visible = false
	score_label.visible = false

	# Freeze ball until game starts
	ball.dead = true
	ball.velocity = Vector2.ZERO

func show_congrats_screen() -> void:
	playing = false
	congrats_screen.visible = true
	score_label.visible = false

	# stop ball
	ball.dead = true
	ball.velocity = Vector2.ZERO

func start_game() -> void:
	playing = true
	score = 0
	update_score_label()

	# Reset level
	spawn_blocks()
	
	ball.dead = true
	ball.velocity = Vector2.ZERO
	ball.hide()

	# UI
	start_screen.visible = false
	game_over_screen.visible = false
	score_label.visible = true

	# Reset ball
	ball.show()
	ball.start($StartPosition.global_position)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball.died.connect(game_over)
	ball.block_broken.connect(_on_block_broken)

	# Button hooks
	$UI/StartScreen/StartButton.pressed.connect(start_game)
	$UI/GameOverScreen/RestartButton.pressed.connect(start_game)
	$UI/CongratsScreen/RestartButton.pressed.connect(start_game)

	show_start_screen()

func game_over() -> void:
	if not playing:
		return

	playing = false

	# Stop ball movement
	ball.dead = true
	ball.velocity = Vector2.ZERO

	# UI
	game_over_screen.visible = true
	# Optional: show final score
	var lbl := $UI/GameOverScreen/GameOverLabel as Label
	#lbl.text = "Game Over\nScore: %d" % score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
