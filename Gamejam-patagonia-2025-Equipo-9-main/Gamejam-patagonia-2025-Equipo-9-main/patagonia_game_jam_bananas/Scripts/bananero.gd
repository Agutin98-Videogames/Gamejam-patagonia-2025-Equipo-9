extends Sprite2D

@export var banana_scene: PackedScene

func _ready():
	# This timer will spawn a new banana every 6 seconds.
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 6.0
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(self._on_spawn_timer_timeout)
	add_child(spawn_timer)

func _on_spawn_timer_timeout():
	# This function is called every 6 seconds.
	spawn_banana()

func spawn_banana():
	var banana = banana_scene.instantiate()
	# Position the banana in the tree. You might need to adjust this Vector2.
	banana.global_position = global_position + Vector2(0, -100)
	get_parent().add_child(banana)

	# Make sure the banana is a RigidBody2D or CharacterBody2D with a script.
	# In the banana's script, you would handle the fall.
	banana.gravity_scale = 0 # Prevent it from falling immediately.

	# Start a one-shot timer to make the banana fall after a delay.
	var drop_timer = Timer.new()
	drop_timer.wait_time = 6.0  # The banana will stay for 6 seconds.
	drop_timer.one_shot = true
	drop_timer.timeout.connect(banana._on_drop_timer_timeout)
	banana.add_child(drop_timer)
	drop_timer.start()
