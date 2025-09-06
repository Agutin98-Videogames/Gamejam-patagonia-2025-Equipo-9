extends Sprite2D

@export var banana_scene: PackedScene

var drop_timer: Timer

func _ready():
	drop_timer = Timer.new()
	drop_timer.wait_time = 6.0 
	drop_timer.one_shot = false 
	add_child(drop_timer)
	drop_timer.timeout.connect(self._on_drop_timer_timeout)
	drop_timer.start()

func _on_drop_timer_timeout():
	drop_banana()

func drop_banana():
	var banana = banana_scene.instantiate()
	banana.global_position = global_position + Vector2(0, 50)
	get_parent().add_child(banana)
