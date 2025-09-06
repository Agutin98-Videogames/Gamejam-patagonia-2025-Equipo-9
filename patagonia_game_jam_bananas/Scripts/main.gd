extends Node2D

var label_puntos: Label

func _ready() -> void:
	label_puntos = $HUD/Label
	actualizar_puntos()
	

func actualizar_puntos():
	label_puntos.text = "Puntos: " + str(Gameh.puntos)
