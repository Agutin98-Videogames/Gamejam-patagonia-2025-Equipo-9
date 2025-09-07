# explosion.gd
extends Node2D

var radio_explosion = 150.0
var dano = 30

func _ready():
	# Reproduce la animación de explosión
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
		$AnimatedSprite2D.play("default")
	
	# Si no tienes AnimatedSprite2D, destruye después de un tiempo
	if not has_node("AnimatedSprite2D"):
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 1.0
		timer.one_shot = true
		timer.timeout.connect(_on_timer_finished)
		timer.start()

func configurar_explosion(radio: float, dano_explosion: int):
	radio_explosion = radio
	dano = dano_explosion
	
	# Ajustar el tamaño de la animación si es necesario
	if has_node("AnimatedSprite2D"):
		var escala = radio / 100.0  # Asumiendo que 100 es el radio base
		$AnimatedSprite2D.scale = Vector2(escala, escala)

func _on_animation_finished():
	# Asegurar que se destruya cuando termine cualquier animación
	print("Explosión terminada, destruyendo...")
	queue_free()

func _on_timer_finished():
	# Método de respaldo para destruir la explosión
	print("Timer de explosión terminado, destruyendo...")
	queue_free()
