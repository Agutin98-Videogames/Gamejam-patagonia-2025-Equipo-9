# bomba.gd
extends RigidBody2D

@export var dano = 30
@export var radio_explosion = 150.0
@export var tiempo_explosion = 3.0  # Tiempo en segundos antes de explotar
@export var fuerza_explosion = 500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var timer_explosion = 0.0
var ha_explotado = false
var velocidad_lanzamiento: Vector2

# Referencia a la explosión
@export var explosion_scene: PackedScene

func _ready():
	timer_explosion = tiempo_explosion
	
	if not explosion_scene:
		explosion_scene = preload("res://explosion.tscn")
	
	# Configurar la bomba como un RigidBody2D
	gravity_scale = 1.0
	
	# Reproducir animación de bomba activa
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")
	
	# Conectar señales de colisión
	body_entered.connect(_on_body_entered)
	
	# Sonido de la bomba activándose
	if has_node("Sonido_activa"):
		$Sonido_activa.play()

func _physics_process(delta):
	if ha_explotado:
		return
	
	# Cuenta regresiva para explotar
	timer_explosion -= delta
	
	# Cambiar animación cuando esté cerca de explotar
	if timer_explosion <= 1.0 and has_node("AnimatedSprite2D"):
		if $AnimatedSprite2D.animation != "por_explotar":
			$AnimatedSprite2D.play("por_explotar")
	
	# Explotar cuando se acabe el tiempo
	if timer_explosion <= 0:
		explotar()

func lanzar(velocidad: Vector2):
	velocidad_lanzamiento = velocidad
	linear_velocity = velocidad

func _on_body_entered(body):
	# Si la bomba toca al jugador, explota inmediatamente
	if body.is_in_group("player") or body.is_in_group("jugador"):
		explotar()
	# Si toca el suelo, acelera la explosión
	elif body.is_in_group("suelo") or body.is_in_group("plataforma") or body.is_in_group("ground"):
		if timer_explosion > 1.0:
			timer_explosion = 1.0

func explotar():
	if ha_explotado:
		return
	
	ha_explotado = true
	
	# Crear efecto de explosión
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		
		# Si la explosión tiene método para configurar su tamaño
		if explosion.has_method("configurar_explosion"):
			explosion.configurar_explosion(radio_explosion, dano)
	
	# Buscar entidades cercanas y aplicar daño
	aplicar_dano_en_area()
	
	# Sonido de explosión
	if has_node("Sonido_explosion"):
		$Sonido_explosion.play()
		# Esperar a que termine el sonido antes de destruir
		await $Sonido_explosion.finished
	
	# Destruir la bomba
	queue_free()

func aplicar_dano_en_area():
	# Buscar todos los cuerpos en el área de explosión
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	
	# Crear un círculo para detectar colisiones
	var shape = CircleShape2D.new()
	shape.radius = radio_explosion
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.exclude = [self]
	
	var resultados = space_state.intersect_shape(query)
	
	for resultado in resultados:
		var cuerpo = resultado.collider
		
		# Aplicar daño al jugador
		if cuerpo.is_in_group("jugador"):
			if cuerpo.has_method("recibir_dano"):
				cuerpo.recibir_dano(dano)
			
			# Aplicar empuje
			var direccion = (cuerpo.global_position - global_position).normalized()
			if cuerpo.has_method("aplicar_empuje"):
				cuerpo.aplicar_empuje(direccion * fuerza_explosion)
		
		# También puede dañar otros enemigos si quieres
		elif cuerpo.is_in_group("enemigos"):
			if cuerpo.has_method("recibir_dano"):
				cuerpo.recibir_dano(dano / 2)  # Daño reducido a otros enemigos
