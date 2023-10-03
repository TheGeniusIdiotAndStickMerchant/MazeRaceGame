extends Node

@export var maze_scene: PackedScene

var maze: GameScene = null

func _ready():
	randomize()

func standard_game_init():
	$MainMenu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	maze = maze_scene.instantiate()
	add_child(maze)

func standard_game_stop():
	await maze.finished
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	maze.queue_free()
	$MainMenu.show()


func _on_single_button_pressed():
	standard_game_init()
	maze.random_marker_no_back()
	standard_game_stop()


func _on_single_button_back_pressed():
	standard_game_init()
	maze.random_marker_back()
	standard_game_stop()


func _on_all_button_pressed():
	standard_game_init()
	maze.all_markers_rand_order_auto_back()
	standard_game_stop()



func _on_all_button_back_pressed():
	standard_game_init()
	maze.all_markers_rand_order_back()
	standard_game_stop()
