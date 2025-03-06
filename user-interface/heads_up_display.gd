class_name HeadsUpDisplay
extends Control


@export_group("References")
@export var player_character: PlayerCharacter = null


func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	#Can be made dynamic by turning the inputs into vars and calling "queue_redraw"
	draw_circle(get_viewport_rect().size / 2.0, 2.0, Color.WHITE, true)
