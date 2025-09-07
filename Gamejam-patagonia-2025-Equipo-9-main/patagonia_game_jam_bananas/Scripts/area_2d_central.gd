# Script para Area2D_Central (Area2D)
extends Area2D;

var flag_ya_entre_a_mejora_2da :bool = false;
var flag_ya_entre_a_mejora_3ra :bool = false;

@onready var audioPowerUp = $AudioPowerUp;

func _ready():
	print("Área de depósito central lista");
	$AnimatedSprite2D.play("primera");
	
	# Conectar señales para detectar cuando el jugador entra/sale
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if Gameh.puntos == 2 and flag_ya_entre_a_mejora_2da==false:
		audioPowerUp.play();
		flag_ya_entre_a_mejora_2da = true
		$AnimatedSprite2D.play("segunda")
		var label_2 = $Mejoraste_a_nivel_2
		label_2.visible = true
		await get_tree().create_timer(1.5).timeout
		
		# Animación de desvanecimiento para el label
		var tween = create_tween()
		tween.tween_property(label_2, "modulate:a", 0.0, 0.8)
		tween.tween_callback(label_2.queue_free)

	if Gameh.puntos == 3 and flag_ya_entre_a_mejora_3ra==false:
		audioPowerUp.play();
		flag_ya_entre_a_mejora_3ra = true
		$AnimatedSprite2D.play("tercera")
		var label_3 = $Mejoraste_a_nivel_3
		label_3.visible = true
		await get_tree().create_timer(1.5).timeout
		
		# Animación de desvanecimiento para el label
		var tween = create_tween()
		tween.tween_property(label_3, "modulate:a", 0.0, 0.8)
		tween.tween_callback(label_3.queue_free)
				
func _on_body_entered(body: Node2D):
	# Cuando el jugador entra al área de depósito
	if body.is_in_group("player"):
		print("Jugador entró al área de depósito")
		body._on_deposit_area_entered(self)

func _on_body_exited(body: Node2D):
	# Cuando el jugador sale del área de depósito  
	if body.is_in_group("player"):
		print("Jugador salió del área de depósito")
		body._on_deposit_area_exited(self)
