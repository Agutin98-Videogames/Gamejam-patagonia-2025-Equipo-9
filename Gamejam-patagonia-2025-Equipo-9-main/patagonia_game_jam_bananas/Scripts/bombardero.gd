# bombardero.gd
extends CharacterBody2D

@export var distancia_deteccion = 400.0
@export var distancia_lanzar = 450.0
@export var tiempo_entre_lanzamientos = 4.0
@export var tiempo_idle_post_ataque = 2.0

var puede_lanzar = true
var jugador_detectado = false
var jugador_ref = null
var timer_lanzamiento = 0.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var posicion_y_inicial: float
var direccion = 1

enum Estado { IDLE, ATACANDO, IDLE_POST_ATAQUE }
var estado_actual = Estado.IDLE
var timer_idle_post_ataque = 0.0
var timer_ataque_backup = 0.0
var esperando_lanzar = false
var objetivo_lanzamiento: Vector2

@export var bomba_scene: PackedScene
@onready var audioDropBomb = $AudioDropBomb;

func _ready():
	posicion_y_inicial = global_position.y
	jugador_ref = get_tree().get_first_node_in_group("player")
	if not jugador_ref:
		jugador_ref = get_node_or_null("../Personaje")
	
	if not bomba_scene:
		bomba_scene = preload("res://bomba.tscn")
	
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
	$AnimatedSprite2D.play("durmiendo")

func _physics_process(delta):
	# Se mantiene fijo en su posición Y
	global_position.y = posicion_y_inicial
	
	# El enemigo no se mueve horizontalmente, solo ataca
	velocity.x = 0
	
	if not puede_lanzar:
		timer_lanzamiento -= delta
		if timer_lanzamiento <= 0:
			puede_lanzar = true
	
	match estado_actual:
		Estado.IDLE:
			detectar_jugador()
			if jugador_detectado and puede_lanzar:
				iniciar_ataque()
		
		Estado.ATACANDO:
			timer_ataque_backup -= delta
			if timer_ataque_backup <= 0:
				forzar_fin_ataque()
		
		Estado.IDLE_POST_ATAQUE:
			timer_idle_post_ataque -= delta
			if timer_idle_post_ataque <= 0:
				estado_actual = Estado.IDLE
	
	move_and_slide()
	actualizar_animaciones()

func actualizar_animaciones():
	match estado_actual:
		Estado.IDLE:
			if $AnimatedSprite2D.animation != "durmiendo":
				$AnimatedSprite2D.play("durmiendo")
		Estado.ATACANDO:
			pass # La animación de ataque ya se reproduce en iniciar_ataque()
		Estado.IDLE_POST_ATAQUE:
			if $AnimatedSprite2D.animation != "durmiendo":
				$AnimatedSprite2D.play("durmiendo")

func _on_frame_changed():
	# Lanza la bomba en el frame específico de la animación de ataque
	if $AnimatedSprite2D.animation == "ataque" and $AnimatedSprite2D.frame == 2:
		if esperando_lanzar:
			crear_y_lanzar_bomba()
			esperando_lanzar = false

func _on_animation_finished():
	match $AnimatedSprite2D.animation:
		"ataque":
			if esperando_lanzar:
				crear_y_lanzar_bomba()
			iniciar_idle_post_ataque()

func forzar_fin_ataque():
	if esperando_lanzar:
		crear_y_lanzar_bomba()
	iniciar_idle_post_ataque()

func iniciar_idle_post_ataque():
	estado_actual = Estado.IDLE_POST_ATAQUE
	timer_idle_post_ataque = tiempo_idle_post_ataque
	esperando_lanzar = false

func detectar_jugador():
	if not jugador_ref:
		return
	
	var distancia = global_position.distance_to(jugador_ref.global_position)
	
	if distancia <= distancia_deteccion:
		jugador_detectado = true
		# Determina hacia qué lado mirar
		if jugador_ref.global_position.x > global_position.x:
			direccion = 1
		else:
			direccion = -1
		
		$AnimatedSprite2D.flip_h = (direccion == -1)
	else:
		jugador_detectado = false

func iniciar_ataque():
	if not puede_lanzar or not jugador_ref or not bomba_scene:
		return
	
	audioDropBomb.play();
	var distancia_al_jugador = global_position.distance_to(jugador_ref.global_position)
	
	if distancia_al_jugador <= distancia_lanzar:
		# Orienta hacia el jugador
		if jugador_ref.global_position.x > global_position.x:
			direccion = 1
		else:
			direccion = -1
		
		$AnimatedSprite2D.flip_h = (direccion == -1)
		
		objetivo_lanzamiento = jugador_ref.global_position
		esperando_lanzar = true
		estado_actual = Estado.ATACANDO
		timer_ataque_backup = 2.0
		$AnimatedSprite2D.play("ataque")
		
		puede_lanzar = false
		timer_lanzamiento = tiempo_entre_lanzamientos

func crear_y_lanzar_bomba():
	if not bomba_scene:
		return
	
	var bomba = bomba_scene.instantiate()
	get_parent().add_child(bomba)
	bomba.global_position = global_position + Vector2(0, -30)
	
	var velocidad_inicial = calcular_velocidad_parabola(bomba.global_position, objetivo_lanzamiento)
	
	# Reproduce sonido de lanzamiento si tienes AudioStreamPlayer2D
	if has_node("Lanza_bomba"):
		$Lanza_bomba.play()
	
	if bomba.has_method("lanzar"):
		bomba.lanzar(velocidad_inicial)

func calcular_velocidad_parabola(origen: Vector2, destino: Vector2) -> Vector2:
	var distancia_horizontal = destino.x - origen.x
	var distancia_vertical = destino.y - origen.y
	var distancia_total = sqrt(distancia_horizontal * distancia_horizontal + distancia_vertical * distancia_vertical)
	
	# Ajustar tiempo de vuelo basado en la distancia total
	var tiempo_vuelo: float
	if distancia_total < 150:
		tiempo_vuelo = 0.8
	elif distancia_total < 300:
		tiempo_vuelo = 1.2
	else:
		tiempo_vuelo = 1.6
	
	# Calcular velocidad horizontal
	var velocidad_x = distancia_horizontal / tiempo_vuelo
	
	# Calcular velocidad vertical para crear un arco
	var altura_arco = 200.0  # Altura del arco más razonable
	var velocidad_y = -(sqrt(2 * gravity * altura_arco) + (distancia_vertical / tiempo_vuelo))
	
	# Limitar las velocidades para que no sean extremas
	velocidad_x = clamp(velocidad_x, -400, 400)
	velocidad_y = clamp(velocidad_y, -500, -150)
	
	return Vector2(velocidad_x, velocidad_y)
