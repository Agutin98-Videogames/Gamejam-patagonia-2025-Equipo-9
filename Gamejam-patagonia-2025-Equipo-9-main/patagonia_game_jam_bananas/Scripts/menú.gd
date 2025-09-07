extends Control
@onready var audioButtonPressed = $AudioButtonPressed;
@onready var audioButtonToggled = $AudioButtonToggled;

func _on_botón_jugar_pressed() -> void:
	audioButtonPressed.play();
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://main.tscn");

func _on_botón_creditos_pressed() -> void:
	audioButtonPressed.play();
	await get_tree().create_timer(0.4).timeout
	pass # Replace with function body.

func _on_botón_salir_pressed() -> void:
	audioButtonPressed.play();
	await get_tree().create_timer(0.4).timeout
	get_tree().quit();
	
func _on_botón_jugar_mouse_entered() -> void:
	audioButtonToggled.play();
func _on_botón_creditos_mouse_entered() -> void:
	audioButtonToggled.play();
func _on_botón_salir_mouse_entered() -> void:
	audioButtonToggled.play();
