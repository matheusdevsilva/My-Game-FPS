extends Node

signal multiplayer_finished

func _ready() -> void:
	
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_server_disconnected() -> void:
	print("Host saiu ou desconectou!")
	SteamManage.reset_steam()
	multiplayer_finished.emit()
	
@rpc("authority", "call_remote", "reliable")
func host_left() -> void:
	print("Host avisou que está saindo!")

	SteamManage.reset_steam()
	multiplayer_finished.emit()

func quit_multiplayer() -> void:
	if multiplayer.is_server():
		host_left.rpc()
		await get_tree().create_timer(0.2).timeout

	SteamManage.reset_steam()
	multiplayer_finished.emit()
