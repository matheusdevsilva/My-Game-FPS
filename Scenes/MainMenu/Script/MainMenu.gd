extends Control
class_name MainMenu

func _on_button_single_pressed() -> void:
	GameManage.play_singleplayer()

func _on_button_multiplayer_pressed() -> void:
	SteamManage.create_server()

func _on_button_settings_pressed() -> void:
	pass # Replace with function body.
