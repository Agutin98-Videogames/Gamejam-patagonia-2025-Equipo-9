extends CharacterBody2D;
signal hit;
# Jump variables
# Configuración de físicas
@export var speed: float = 400.0;
@export var jump_force: float = -800.0;
@export var gravity: float = 1800.0;
var score: int = 0;
var screen_size; # Size of the game window.

func _ready():
	add_to_group("player");
	screen_size = get_viewport_rect().size;
	
func _process(delta):
	var velocity = Vector2.ZERO; # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		print("move right");
		velocity.x += 1;
	if Input.is_action_pressed("move_left"):
		print("move left");
		velocity.x -= 1;
	if Input.is_action_pressed("interact"):
		print("interact");
	if velocity.length() > 0:
		print("velocity length > 0");
		velocity = velocity.normalized() * speed;
		$AnimatedSprite2D.play();
	else:
		$AnimatedSprite2D.stop();
	position += velocity * delta;
	position = position.clamp(Vector2.ZERO, screen_size);

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta;
	else:
		# Si está en el piso, permitir salto
		if Input.is_action_just_pressed("ui_accept"): # espacio por defecto
			velocity.y = jump_force;

	# Movimiento lateral
	var direction := Input.get_axis("ui_left", "ui_right");
	velocity.x = direction * speed;

	# Mover personaje
	move_and_slide();

func add_points(amount: int):
	score += amount;
	print("Puntos: ", score);
