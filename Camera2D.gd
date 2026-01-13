extends Camera2D

@onready var player_node = get_node("/root/Main/Level/Player")

func _ready():
	position =  player_node.global_position
	zoom = Vector2(2,2)

func _process(_delta):
	position = lerp(position, player_node.global_position, .05)
	
