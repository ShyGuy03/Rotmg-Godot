extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
@export var lifetime: float = 1.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	$LifetimeTimer.wait_time = lifetime
	$LifetimeTimer.start()
	$LifetimeTimer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
