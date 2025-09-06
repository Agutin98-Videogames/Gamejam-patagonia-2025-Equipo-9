extends CharacterBody2D

# Configuración de físicas
@export var speed: float = 400.0
@export var jump_force: float = -800.0
@export var gravity: float = 1800.0
var score: int = 0
var screen_size

# Sistema de transporte
var carried_item = null  # La banana que está cargando
var can_pickup: bool = false  # Si puede recoger algo
var pickup_target = null  # Qué objeto puede recoger
var can_deposit: bool = false  # Si puede depositar
var deposit_area = null  # Área donde puede depositar

@onready var nodo_main = get_tree().current_scene

func _ready():
	add_to_group("player")
	screen_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Salto
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_force

	# Movimiento lateral
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	
	# Interacciones (recoger/depositar)
	handle_interactions()
	
	# Animaciones
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	# Mover personaje
	move_and_slide()
	
	# Mantener en pantalla
	position.x = clamp(position.x, 0, screen_size.x)
	
	# Actualizar posición del objeto cargado
	update_carried_item_position()

func handle_interactions():
	# Tecla de interacción (puedes cambiarla)
	if Input.is_action_just_pressed("interact"):  # O "ui_select"
		
		if carried_item == null and can_pickup and pickup_target:
			# Recoger objeto
			pickup_item(pickup_target)
			
		elif carried_item != null and can_deposit and deposit_area:
			# Depositar objeto
			deposit_item()

func pickup_item(item):
	print("¡Recogiendo banana!")
	carried_item = item
	
	# Hacer invisible el objeto original y desactivar su física
	item.visible = false
	if item.has_method("set_freeze_enabled"):
		item.set_freeze_enabled(true)  # Para RigidBody2D
	# Desactivar las capas específicas de la BANANA
	item.set_collision_layer_value(4, false)  # Capa 4 (banana)
	item.set_collision_mask_value(1, false)   # No detectar piso
	item.set_collision_mask_value(4, false)   # No detectar otras bananas

	
	# Opcional: crear un sprite visual en el jugador
	create_carried_item_visual()

func deposit_item():
	if carried_item and deposit_area:
		print("¡Depositando banana en área central!")
		
		# Sumar puntos por depósito
		add_points(carried_item.value * 1)  
		Gameh.puntos +=1
		nodo_main.actualizar_puntos()
		
		
		# Eliminar el objeto
		carried_item.queue_free()
		carried_item = null
		
		# Quitar visual del objeto cargado
		remove_carried_item_visual()

func create_carried_item_visual():
	# Crear un sprite que muestre que lleva la banana
	var carried_sprite = Sprite2D.new()
	carried_sprite.name = "CarriedItem"
	add_child(carried_sprite)
	
	# Copiar la textura de la banana (asume que tiene un Sprite2D hijo)
	if carried_item.has_node("Sprite2D"):
		carried_sprite.texture = carried_item.get_node("Sprite2D").texture
	
	# Posicionar encima del jugador
	carried_sprite.position = Vector2(0, -50)  # Ajusta según tu sprite
	carried_sprite.scale = Vector2(0.8, 0.8)   # Hacerla más pequeña

func remove_carried_item_visual():
	# Quitar el sprite visual
	if has_node("CarriedItem"):
		get_node("CarriedItem").queue_free()

func update_carried_item_position():
	# Si lleva algo, actualizar la posición del objeto real (invisible)
	if carried_item:
		carried_item.global_position = global_position

# Señales para detectar cuándo puede recoger
func _on_pickup_area_entered(area_or_body):
	if area_or_body.is_in_group("collectible") and carried_item == null:
		print("Puede recoger banana - Presiona INTERACT")
		can_pickup = true
		pickup_target = area_or_body

func _on_pickup_area_exited(area_or_body):
	if area_or_body == pickup_target:
		print("Salió del área de recogida")
		can_pickup = false
		pickup_target = null

# Señales para detectar cuándo puede depositar
func _on_deposit_area_entered(area):
	if area.name == "Area2D_Central" and carried_item != null:
		print("Puede depositar banana - Presiona INTERACT")
		can_deposit = true
		deposit_area = area

func _on_deposit_area_exited(area):
	if area == deposit_area:
		print("Salió del área de depósito")
		can_deposit = false
		deposit_area = null

func add_points(amount: int):
	score += amount
	print("Puntos totales: ", score)
	
#extends CharacterBody2D
#
#@export var speed: float = 400.0
#@export var jump_force: float = -800.0
#@export var gravity: float = 1800.0
#var score: int = 0
#var screen_size
#
#func _ready():
	#add_to_group("player")
	#screen_size = get_viewport_rect().size
#
## USAR SOLO _physics_process() para evitar conflictos
#func _physics_process(delta: float) -> void:
	## Gravedad
	#if not is_on_floor():
		#velocity.y += gravity * delta
	#else:
		## Salto
		#if Input.is_action_just_pressed("ui_accept"):
			#velocity.y = jump_force
#
	## Movimiento lateral
	#var direction := Input.get_axis("ui_left", "ui_right")
	#velocity.x = direction * speed
	#
	## Animaciones
	#if velocity.length() > 0:
		#$AnimatedSprite2D.play()
	#else:
		#$AnimatedSprite2D.stop()
#
	## Mover personaje
	#move_and_slide()
	#
	## Mantener en pantalla (opcional)
	#position.x = clamp(position.x, 0, screen_size.x)
#
#func add_points(amount: int):
	#score += amount
	#print("Puntos totales: ", score)
