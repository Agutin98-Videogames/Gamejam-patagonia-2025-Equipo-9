extends Node2D

func _ready() -> void:
	await get_tree().create_timer(2.50).timeout
	get_tree().change_scene_to_file("res://men+¦.tscn")
	
