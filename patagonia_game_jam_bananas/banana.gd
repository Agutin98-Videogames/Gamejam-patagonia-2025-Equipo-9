extends RigidBody2D

@export var value: int = 1  # valor del recolectable (ej: monedas, puntos, etc.)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("on body entered")
	if body.is_in_group("personaje"): # aseguramos que sea el jugador
		body.add_points(value) # llamamos a una función del jugador
		queue_free() # destruimos el recolectable
