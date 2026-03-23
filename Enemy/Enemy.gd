extends PathFollow2D
@export var view_distance = 800
@export var turn_speed = .08
@export var hit_points = 100
@export var  bullets_per_second = 1.0
@export var bullet_speed = 400

@export var status_functions = {
	"idle": "idle",
	"patrol": "patrol", 
	"pursuing": "pursue",
	"player_spotted": "turn_towards_player",
	"firing": "shoot"
		}
var player_last_known_location 

@export var patrol_speed = .8
@export var pursuit_speed = 1.4
var current_speed = 0
@export var acceleration_speed = .1
@export var deceleration_speed = .10

@export var field_of_view_degrees = 120
@export var fire_field_degrees = 90
var current_point = 0

var status = "idle"
var bullet = preload("res://Bullet/Bullet.tscn")
var currently_facing 
var vector_to_player
var vector_to_last_known_location
# dot product of vector_to_player and currently_facing
var dot_product_to_player
var distance_to_player

var last_status

@onready var player_node = get_node("/root/Main/Level/Player")
@onready var ray_cast_to_player = get_node("Body/CastToPlayer")
@onready var body_animation_player = get_node("Body/AnimatedSprite2D")
@onready var path2d = get_parent()
@onready var nav_agent = get_node("./NavigationAgent2D")

func _ready():
	# connect("area_entered", Callable(self, "_on_hurtbox_area_entered"))
	$FireRate.wait_time = 1 / bullets_per_second
	body_animation_player.play('idle')
 

func _process(delta):
	pass

func _physics_process(delta):
	currently_facing = Vector2(cos($Body.global_rotation), sin($Body.global_rotation))
	vector_to_player = global_position.direction_to(player_node.get_position())	
	dot_product_to_player = vector_to_player.dot(currently_facing)
	distance_to_player = ray_cast_to_player.get_collision_point().distance_to(global_position)
	var player_spotted = look_for_player()

	var last_status = status

	status = get_new_status(player_spotted)
	if last_status != status:
		print('status changed to ', status)
	call(status_functions[status])

func idle():
	# play idle animation
	pass
	
func look_for_player()->bool:
	# attempts to find player, returns true if successful
	var collider = ray_cast_to_player.get_collider() 
	if !collider:
		print("collider was null")
	if collider == player_node and dot_product_to_player > scale_degrees_for_dot_product(field_of_view_degrees)  and distance_to_player < view_distance:
		player_last_known_location = player_node.get_global_position()
		vector_to_last_known_location = global_position.direction_to(player_node.get_global_position())	
		return true
	return false

func scale_degrees_for_dot_product(degrees):
	return (180 - degrees) / 180

func get_new_status(player_spotted)->String:
	if player_spotted:
		if  dot_product_to_player > scale_degrees_for_dot_product(fire_field_degrees):
			return  "firing"
		else:	
			return "player_spotted"
	elif player_last_known_location:
		return "pursuing"
	else:
		return "patrol"

func pursue():
	$FireRate.stop()
	nav_agent.target_position = player_node.global_position
	var next_point = nav_agent.get_next_path_position()
	path2d.curve.clear_points()
	path2d.curve.add_point(path2d.to_local(global_position))
	path2d.curve.add_point(path2d.to_local(next_point))
	current_speed = lerp(float(current_speed), float(pursuit_speed), acceleration_speed)
	progress = 0
	progress += current_speed
	
func turn_towards_player()->void:
	$Body.global_rotation = lerp(currently_facing, vector_to_last_known_location, turn_speed).angle()

func _on_Hurtbox_area_entered(area ):
	if area.is_in_group('hitbox'):
		take_damage(area.damage)

func take_damage(damage_amount):

	hit_points -= damage_amount
	print('enemy damage: ', damage_amount)
	if hit_points <= 0:
		die()

func die():
	queue_free()

func _on_FireRate_timeout():
	body_animation_player.play('fire')
	var new_bullet = bullet.instantiate()
	new_bullet.apply_impulse(currently_facing * bullet_speed, Vector2.ZERO)
	new_bullet.position = global_position + currently_facing * 40
	new_bullet.rotation = currently_facing.angle()
	get_tree().get_root().call_deferred("add_child",new_bullet)

func patrol():
	body_animation_player.play('idle')
	# ???
	$Body.rotation = 0
	current_speed = lerp(float(current_speed), float(patrol_speed), acceleration_speed)
	progress += current_speed

func shoot():
	turn_towards_player()
	if $FireRate.is_stopped():
		$FireRate.start()



	
