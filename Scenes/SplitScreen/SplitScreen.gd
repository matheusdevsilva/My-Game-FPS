extends Control
class_name SplitScreen

@onready var player1_viewport: SubViewportContainer = $Player1Viewport
@onready var player2_viewport: SubViewportContainer = $Player2Viewport

@onready var viewport_1: SubViewport = $Player1Viewport/SubViewport
@onready var viewport_2: SubViewport = $Player2Viewport/SubViewport

func _ready() -> void:
	_update_viewports()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_split_screen"):
		toggle_split_screen()

func toggle_split_screen() -> void:
	visible = not visible

func _update_viewports() -> void:
	var size := get_viewport_rect().size
	var half_height := size.y / 2.0

	player1_viewport.position = Vector2.ZERO
	player1_viewport.size = Vector2(size.x, half_height)

	player2_viewport.position = Vector2(0, half_height)
	player2_viewport.size = Vector2(size.x, half_height)
