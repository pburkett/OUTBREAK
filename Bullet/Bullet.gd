extends RigidBody2D
var collisions = 0
@export var collisions_before_disappear = 2
var is_dying = false
var collision_on_last_frame = false

func _ready():
	# scale = Vector2(4,4)
	$AnimatedSprite2D.play('traveling')
	pass

func _physics_process(delta):
	if !is_dying:
		rotation = linear_velocity.angle() + .5*PI
	if collision_on_last_frame:
		collision_on_last_frame = false
		if (get_colliding_bodies()[0].is_in_group('absorb_projectiles')):
			die()
			return
		collisions += 1
		if (collisions >= collisions_before_disappear) and !is_dying:
			die()
			

func _integrate_forces(state):
	if state.get_contact_count() == 1:
		collision_on_last_frame = true

		

func _on_AnimatedSprite_animation_finished():
	if is_dying:
		queue_free()  

func die():
	is_dying = true
	set_linear_velocity(Vector2(0,0))
	set_angular_velocity(0)
	$PhysicsCollision.set_deferred("disabled", true)
	$AnimatedSprite2D.play('impact_metal')
