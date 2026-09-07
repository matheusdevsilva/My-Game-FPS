extends Node

signal player_disconect(id_player)
signal player_connect(id_player)
signal player_send_mensagen()


func add_new_player(id_player:int)-> Player:
	var new_player = GameManage.instantiate_scene(
		GameManage.name_scenes.PLAYER)
	new_player.name = id_player
	new_player.set_multiplayer_authority(id_player)	
	new_player.username_steam = null
	
	return new_player
	
func  create_server():
	pass
func  host_server(id_server):
	pass


func send_mensagen():
	pass
