extends Control
class_name MenuPlayer




func _ready() -> void:
	Steam.steam_server_connect_failed.connect(_on_steam_disconnected)


func _on_steam_disconnected():
	$VBoxContainer/ButtonInviteFriends.visible = false
