extends Control
class_name MenuPlayer




func _ready() -> void:
	Steam.steam_server_connect_failed.connect(_on_steam_disconnected)


func _on_steam_disconnected():
	$VBoxContainer/ButtonInviteFriends.visible = false



func _on_button_continue_pressed() -> void:
	pass # Replace with function body.
	
func _on_button_invite_friends_pressed() -> void:
	
	pass # Replace with function body.
	
func _on_button_quit_pressed() -> void:
	GameManage.change_scene(GameManage.name_scenes.MAIN_MENU)
