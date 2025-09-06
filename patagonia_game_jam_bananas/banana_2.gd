# Script para la Banana (RigidBody2D)
extends RigidBody2D

@export var value: int = 1

func _ready():
	print("Banana lista para caer, rebotar y ser transportada")
	add_to_group("collectible")
	
	# Configurar propiedades físicas del RigidBody2D
	linear_damp = 0.5
	mass = 1.0
	gravity_scale = 1.0
	
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
		
## Script para la Banana (RigidBody2D principal)
#extends RigidBody2D
#
#@export var value: int = 1
#
#func _ready():
	#print("Banana lista para caer, rebotar y ser recolectada")
	#add_to_group("collectible")
	#
	## Configurar propiedades físicas del RigidBody2D
	#linear_damp = 0.5
	#mass = 1.0
	#gravity_scale = 1.0
	#
	## Conectar la señal del Area2D hijo (que crearás manualmente)
	#var collection_area = get_node("Area2D")  # Debe coincidir con el nombre que le des
	#if collection_area:
		#collection_area.body_entered.connect(_on_collection_area_body_entered)
		#print("Señal del Area2D conectada correctamente")
	#else:
		#print("ERROR: No se encontró el nodo Area2D")
#
#func _on_collection_area_body_entered(body: Node2D):
	#print("¡Cuerpo detectado en área de recolección!")
	#
	## Verificar si es el jugador
	#if body.is_in_group("player"):
		#print("¡Es el jugador!")
		#
		## Dar puntos al jugador
		#if body.has_method("add_points"):
			#body.add_points(value)
			#print("¡Banana recolectada! +", value, " punto(s)")
			#
			## Destruir la banana
			#queue_free()
		#else:
			#print("El jugador no tiene método add_points")
	#else:
		#print("No es el jugador, es: ", body.name)
	#
#
