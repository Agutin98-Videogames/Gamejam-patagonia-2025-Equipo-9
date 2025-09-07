# Script para la Banana (RigidBody2D)
extends RigidBody2D

@export var value: int = 1

func _ready():
	print("Banana lista para caer, rebotar y ser transportada")
	add_to_group("collectible")
	
	# Configurar propiedades físicas del RigidBody2D
	linear_damp = 0.5
	mass = 1.0
	gravity_scale = 0
	
	# Conectar señal del Area2D hijo para detección de jugador cercano
	var collection_area = get_node("Area2D")  # Debe coincidir con el nombre que le des
	if collection_area:
		collection_area.body_entered.connect(_on_collection_area_body_entered)
		print("Señal del Area2D conectada correctamente")
	else:
		print("ERROR: No se encontró el nodo Area2D")

func _on_collection_area_body_entered(body: Node2D):
	# Solo notificar al jugador que puede recoger
	if body.is_in_group("player"):
		print("Jugador cerca de la banana")
		body._on_pickup_area_entered(self)

func _on_collection_area_body_exited(body: Node2D):
	# Notificar al jugador que salió del área
	if body.is_in_group("player"):
		print("Jugador se alejó de la banana")
		body._on_pickup_area_exited(self)
		
# This function will be called when the timer for this specific banana times out.
func _on_drop_timer_timeout():
	# Set the gravity scale to 1 (or your desired value) to make the banana fall.
	gravity_scale = 1
