extends Node2D

var label_puntos: Label
@onready var timer = $Timer  # tu nodo Timer en la escena
var EnemyScene = preload("res://mob.tscn");

func _ready() -> void:
	randomize()
	label_puntos = $HUD/Label;
	actualizar_puntos();
	_reset_timer();  # arranca el primer tiempo

func actualizar_puntos():
	label_puntos.text = "Puntos: " + str(Gameh.puntos);

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
