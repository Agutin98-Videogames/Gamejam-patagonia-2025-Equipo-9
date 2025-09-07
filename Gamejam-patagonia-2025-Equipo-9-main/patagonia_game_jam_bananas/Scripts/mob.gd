extends RigidBody2D;

var speed = 300;
var direction = Vector2.RIGHT;  # ← derecha
@onready var anim = $AnimatedSprite2D;

func _ready():
	linear_velocity = direction * speed;
	anim.play("Run");  # arrancar animación de correr
