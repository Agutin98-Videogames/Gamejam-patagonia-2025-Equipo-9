extends CharacterBody2D

# Referencias a nodos
@onready var animated_sprite = $AnimatedSprite2D

var posicion_inicial: Vector2
var posicion_arbol: Vector2 = Vector2(80, 0)  
var estado = "caminando_al_arbol"
var velocidad = 300.0
var velocidad_escalada = 50.0
var distancia_minima = 10.0
var altura_arbol = 200.0  # Altura que debe subir
var altura_actual = 0.0
var tiene_bananas = false

# Variables para física de plataformas
var gravedad = 980.0
var fuerza_salto = 300.0

func _ready():
	posicion_inicial = global_position
	animated_sprite.play("caminar")

func _physics_process(delta):
	# Aplicar gravedad cuando no está escalando
	if estado != "escalando" and estado != "bajada" and estado != "juntando_bananas":
		if not is_on_floor():
			velocity.y += gravedad * delta
	
	match estado:
		"caminando_al_arbol":
			caminar_al_arbol(delta)
		"escalando":
			escalar_subida(delta)
		"juntando_bananas":
			juntar_bananas(delta)
		"bajada":
			escalar_bajada(delta)
		"regresando":
			regresar_a_inicio(delta)
		"esperando":
			esperar()

func caminar_al_arbol(delta):
	animated_sprite.play("caminar")
	
	var direccion_x = posicion_arbol.x - global_position.x
	
	if abs(direccion_x) > distancia_minima:
		# Mover hacia el árbol solo en X
		velocity.x = sign(direccion_x) * velocidad
		
		# Voltear sprite según la dirección
		if direccion_x > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	else:
		# Llegó debajo del árbol, empezar a escalar
		velocity.x = 0
		if is_on_floor():
			estado = "escalando"
			altura_actual = 0.0
	
	move_and_slide()

func escalar_subida(delta):
	animated_sprite.play("escalar")
	
	# No aplicar gravedad mientras escala
	velocity.x = 0
	
	if altura_actual < altura_arbol:
		# Subir por el árbol
		velocity.y = -velocidad_escalada
		altura_actual += velocidad_escalada * delta
	else:
		# Llegó arriba, agarrar las bananas
		velocity.y = 0
		estado = "juntando_bananas"
	
	move_and_slide()

func juntar_bananas(delta):
	animated_sprite.stop()
	velocity = Vector2.ZERO
	move_and_slide()
	
	# Esperar 1 segundo
	await get_tree().create_timer(1.0).timeout
	
	tiene_bananas = true
	estado = "bajada"

func escalar_bajada(delta):
	animated_sprite.play("escalar")
	
	# No aplicar gravedad mientras baja escalando
	velocity.x = 0
	
	if altura_actual > 0:
		# Bajar del árbol
		velocity.y = velocidad_escalada
		altura_actual -= velocidad_escalada * delta
	else:
		# Llegó abajo, regresar al inicio
		velocity.y = 0
		estado = "regresando"
	
	move_and_slide()

func regresar_a_inicio(delta):
	animated_sprite.play("caminar")
	
	var direccion_x = posicion_inicial.x - global_position.x
	
	if abs(direccion_x) > distancia_minima:
		# Mover hacia la posición inicial solo en X
		velocity.x = sign(direccion_x) * velocidad
		
		# Voltear sprite según la dirección
		if direccion_x > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	else:
		# Llegó al inicio, esperar un poco antes de repetir
		velocity.x = 0
		if is_on_floor():
			estado = "esperando"
	
	move_and_slide()

func esperar():
	animated_sprite.stop()
	velocity.x = 0
	move_and_slide()
	
	# Esperar 2 segundos antes de repetir el ciclo
	await get_tree().create_timer(2.0).timeout
	
	# Reiniciar el ciclo
	tiene_bananas = false
	estado = "caminando_al_arbol"
