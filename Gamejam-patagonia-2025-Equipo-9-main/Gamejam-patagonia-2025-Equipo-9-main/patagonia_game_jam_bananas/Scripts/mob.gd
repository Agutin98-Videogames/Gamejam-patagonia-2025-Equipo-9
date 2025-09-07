extends RigidBody2D;

var speed = 300;
var direction = Vector2.RIGHT;  # ← derecha
var ha_explotado:bool = false
@onready var anim = $AnimatedSprite2D;
@onready var area_de_deteccion = $Area2D

func _ready():
	z_index = 200
	linear_velocity = direction * speed;
	anim.play("Run");  # arrancar animación de correr

	# Conectar la señal de colisión del Area2D
	if area_de_deteccion:
		area_de_deteccion.body_entered.connect(_on_area_2D_body_entered)
		print("area mob conectada")
	else:
		print("area mob no encontrada")

# Esta es la función que se llama cuando el Area2D detecta un cuerpo
func _on_area_2D_body_entered(body: Node2D):
	if body.name == "Piso":
		print("NODO : ",body.name)
	# Si la bomba toca al jugador, explota inmediatamente
	if body.is_in_group("player") or body.is_in_group("jugador"):
		$AnimatedSprite2D.play("Attack")
		await get_tree().create_timer(0.2).timeout	
		explotar()
		print("Kamikaze chocó")
		Gameh.vida -=1
		body.herido()

		
func explotar():
	if ha_explotado:
		return
	ha_explotado = true
	
	# Crear efecto de explosión
	$AnimatedSprite2D.play("Explode")
	
	
	# Sonido de explosión
	if has_node("Sonido_explosion"):
		$Sonido_explosion.play()
		# Esperar a que termine el sonido antes de destruir
		await $Sonido_explosion.finished
	
	await get_tree().create_timer(0.4).timeout	
	# Destruir la bomba
	queue_free()		
