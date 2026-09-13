extends Node

signal player_steam_ready(player)

const STEAM_APP_ID = 480
var steam_peer:SteamMultiplayerPeer

var lobby_id: int = 0
var lobby_name:String
var lobby_size:int
var lobby_type:Steam.LobbyType
var list_players = []
var host_id


func _ready() -> void:
	OS.set_environment("SteamAppID", str(STEAM_APP_ID))
	OS.set_environment("SteamGameID", str(STEAM_APP_ID))
	var init = Steam.steamInit(STEAM_APP_ID, true)
	print("Steam iniciada: ", init)
	Steam.lobby_created.connect(_on_lobby_created)


func create_server():
	print("Criando servidor Steam...")
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY,6)

func _on_lobby_created(connect: int,lobby: int) -> void:
	print("Lobby criado!")
	print("Lobby ID: ", lobby)
	if connect != 1:
		print("Erro ao criar lobby.")
		return
	lobby_id = lobby
	# Informações do lobby
	Steam.setLobbyData(lobby_id, "lobby_name", "Meu servidor")
	print("Servidor criado com sucesso!")
	GameManage.change_scene(GameManage.name_scenes.LOBBY)
	await GameManage.change_scene_finish
	add_new_player(multiplayer.get_unique_id())

func add_new_player(id_player: int):
	var new_player: Player = GameManage.instantiate_scene(GameManage.name_scenes.PLAYER)
	var steam_id:int  = Steam.getSteamID()
	new_player.name = str(id_player)
	new_player.set_multiplayer_authority(id_player)
	new_player.steam_id = steam_id
	new_player.username_steam = Steam.getFriendPersonaName(steam_id)
	player_steam_ready.emit(new_player)
	
