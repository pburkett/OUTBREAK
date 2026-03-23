extends Camera2D

@onready var player_node = get_node("/root/Main/LevelManager/Level/Player")

func _ready():
	position =  player_node.global_position
	zoom = Vector2(1.5,1.5)

func _process(_delta):
	position = lerp(position, player_node.global_position, .03)
	
