extends Node2D

var label_puntos: Label
var label_vida: Label
var vida_actual:int= 5
@onready var timer = $Timer  # tu nodo Timer en la escena
var EnemyScene = preload("res://mob.tscn"); #mono kamikaze

func _ready() -> void:
	randomize()
	label_puntos = $HUD/Label
	label_vida = $HUD/Label_vida
	actualizar_puntos();
	actualizar_vida()
	_reset_timer();  # arranca el primer tiempo de kamikaze

func _process(delta: float) -> void:
	if vida_actual != Gameh.vida:
		actualizar_vida()
		vida_actual = Gameh.vida

func actualizar_puntos():
	label_puntos.text = "Puntos: " + str(Gameh.puntos);

func actualizar_vida():
	label_vida.text = "Vida: " + str(Gameh.vida);
	if Gameh.vida <=0:
		Gameh.vida = 0
		print("PERDISTE")
		get_tree().change_scene_to_file("res://perdiste.tscn")

func _spawn_enemy():
	var enemy = EnemyScene.instantiate();
	enemy.position = Vector2(0, 430);
	add_child(enemy);

func _on_timer_timeout() -> void:
	_spawn_enemy();
	_reset_timer();  # vuelve a elegir un tiempo aleatorio
	
func _reset_timer():
	# entre 5 y 10 segundos aleatorios
	timer.wait_time = randf_range(5.0, 10.0);
	timer.start();
