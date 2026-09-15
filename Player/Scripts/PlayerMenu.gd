extends Control
class_name PlayerMenu

@onready var button_invite_friends:Button = $VBoxContainer/ButtonInviteFriends

func _ready() -> void:
	button_invite_friends.visible = SteamManage.can_invite_friends()

func _on_button_continue_pressed() -> void:
	GameManage.close_menu()
	
func _on_button_invite_friends_pressed() -> void:
	if not SteamManage.can_invite_friends():
		return
	SteamManage.invite_friends()
	
func _on_button_settings_pressed() -> void:
	GameManage.open_menu(GameManage.NameMenu.SETTINGS)
	
func _on_button_quit_pressed() -> void:
	await NetworkManage.quit_multiplayer()
	GameManage.change_scene(GameManage.NameScene.MAIN_MENU)

	
