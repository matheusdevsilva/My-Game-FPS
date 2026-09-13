extends Control


func _on_button_single_pressed() -> void:
	GameManage.change_scene(GameManage.name_scenes.LOBBY)
	pass # Replace with function body.


func _on_button_multiplayer_pressed() -> void:
	SteamManage.create_server()
