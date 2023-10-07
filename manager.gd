extends Node

@export var maze_scene: PackedScene

var maze: GameScene = null
var last_init: Callable

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
	last_init = _on_single_button_pressed
	standard_game_init()
	maze.random_marker_no_back()
	standard_game_stop()

func _on_single_button_back_pressed():
	last_init = _on_single_button_back_pressed
	standard_game_init()
	maze.random_marker_back()
	standard_game_stop()

func _on_all_button_pressed():
	last_init = _on_all_button_pressed
	standard_game_init()
	maze.all_markers_rand_order_auto_back()
	standard_game_stop()

func _on_all_button_back_pressed():
	last_init = _on_all_button_back_pressed
	standard_game_init()
	maze.all_markers_rand_order_back()
	standard_game_stop()


func _input(event):
	if event.is_action_pressed("ui_cancel") && maze != null:
		$PauseMenu.show()
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func end_pause():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	$PauseMenu.hide()

func _on_restart_button_pressed():
	maze.queue_free()
	last_init.call()
	
	end_pause()

func _on_menu_button_pressed():
	maze.queue_free()
	$MainMenu.show()
	$PauseMenu.hide()
	get_tree().paused = false

func _on_resume_button_pressed():
	end_pause()


func _on_quit_button_pressed():
	get_tree().quit()
