extends Node2D

@onready var player_node = get_node("/root/Main/Level/Player")

func _ready():
	pass

func _process(delta):
	var health_proportion = (float(player_node.hit_points) / player_node.max_hit_points) * 4
	print(player_node.hit_points, health_proportion)
	$Sprite2D.texture = load("res://GUI/HealthIndicator/Assets/" + str(int(health_proportion)) + "_lobes.png")
