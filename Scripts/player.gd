extends CharacterBody2D

const BulletScene = preload("res://scenes/Bullet.tscn")  # adjust path as needed
@export var bullet_speed: float = 300.0
@export var fire_rate: float = 0.2  # seconds between shots
@onready var fire_rate_timer: Timer = $FireRateTimer
var can_shoot: bool = true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot: AudioStreamPlayer2D = $Shoot
@onready var spawn_point: Marker2D = $SpawnPoint

const SPEED = 50.0


var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false


#--------------------------------------------------------
# MOVEMENT & ANIMATION
#--------------------------------------------------------
func _physics_process(_delta: float) -> void:
	
	if Input.is_action_pressed("attack") and can_shoot:
		attack()
	process_movement()
	process_animation()
	move_and_slide()

func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left","right","up","down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO

func process_animation() -> void:
	if is_attacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("move", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")


#--------------------------------------------------------
# ATTACKING
#--------------------------------------------------------

func attack() -> void:
	is_attacking = true
	can_shoot = false
	shoot.play()
	play_animation("shoot", last_direction)
	spawn_bullet()
	fire_rate_timer.wait_time = fire_rate
	fire_rate_timer.start()

func spawn_bullet() -> void:
	var bullet = BulletScene.instantiate()
	var mouse_dir = (get_global_mouse_position() - spawn_point.global_position).normalized()
	bullet.direction = mouse_dir
	bullet.speed = bullet_speed
	bullet.global_position = spawn_point.global_position
	bullet.rotation = mouse_dir.angle() + deg_to_rad(45)
	get_tree().current_scene.add_child(bullet)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false

func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true
