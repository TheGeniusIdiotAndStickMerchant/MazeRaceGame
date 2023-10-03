class_name GameScene
extends Node3D

signal finished

var targets: Array[Marker3D] = []
var target: Area3D
var ret: Area3D

@export var target_scene: PackedScene
@export var return_scene: PackedScene

@onready var start_pos: Vector3 = $Player.position

func _ready():
	for i in $TargetPositions.get_children():
		targets.append(i as Marker3D)
	targets.shuffle()

func new_return(callback: Callable):
	if target != null: target.queue_free()
	ret = return_scene.instantiate()
	ret.position = start_pos
	add_child(ret)
	ret.body_entered.connect(callback)

func new_target(callback: Callable):
	if target != null: target.queue_free()
	var targetMarker: Marker3D = targets.pop_front()
	target = target_scene.instantiate()
	target.position = targetMarker.position
	add_child(target)
	target.body_entered.connect(callback)

func final_return(_pass):
	finished.emit()

func final_coll_back(_body):
	new_return(final_return)

func final_coll_no_back(_body):
	finished.emit()

func random_marker_no_back():
	new_target(final_coll_no_back)

func random_marker_back():
	new_target(final_coll_back)

func all_markers_rand_order_auto_back():
	new_target(all_markers_rand_order_auto_back_coll)

func all_markers_rand_order_auto_back_coll(_body):
	$Player.position = start_pos
	if targets.size() > 1:
		new_target(all_markers_rand_order_auto_back_coll)
	else:
		new_target(final_coll_no_back)

func all_markers_rand_order_back():
	new_target(all_markers_rand_order_back_coll)

func return_all_markers_rand_order(_body):
	ret.queue_free()
	new_target(all_markers_rand_order_back_coll)

func all_markers_rand_order_back_coll(_body):
	if targets.size() > 1:
		new_return(return_all_markers_rand_order)
	else:
		new_return(final_return)
