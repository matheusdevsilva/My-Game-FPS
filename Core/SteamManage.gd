extends Node

signal player_steam_ready(player)

const STEAM_APP_ID = 480
var steam_peer:SteamMultiplayerPeer

var lobby_id: int = 0
var lobby_name:String
var lobby_size:int
var lobby_type:Steam.LobbyType
var list_players = []
var host_id:int
var players_avatar: Dictionary = {}


func _ready() -> void:
	OS.set_environment("SteamAppID", str(STEAM_APP_ID))
	OS.set_environment("SteamGameID", str(STEAM_APP_ID))
	var init = Steam.steamInit(STEAM_APP_ID, true)
	print("Steam iniciada: ", init)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_invite.connect(_on_lobby_invite)
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	
func _process(_delta: float) -> void:
	Steam.run_callbacks()
	
		
func create_server() -> void:
	print("Criando servidor Steam...")
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY,6)

func _on_lobby_created(connect: int,lobby: int) -> void:
	print("Lobby criado!")
	print("Lobby ID: ", lobby)
	if connect != 1:
		print("Erro ao criar lobby.")
		return
	lobby_id = lobby
	Steam.setLobbyData(lobby_id, "lobby_name", "Meu servidor")
	
	steam_peer = SteamMultiplayerPeer.new()
	var error = steam_peer.create_host(0)
	
	if error != OK:
		print("Erro ao criar SteamMultiplayerPeer: ", error)
		return
	multiplayer.multiplayer_peer = steam_peer	
	print("Servidor criado com sucesso!")
	
	GameManage.change_scene(GameManage.name_scenes.LOBBY)
	await GameManage.change_scene_finish
	add_new_player(multiplayer.get_unique_id())

	
func join_server(lobby: int) -> void:
	lobby_id = lobby
	print("Entrando no lobby: ", lobby_id)
	Steam.joinLobby(lobby_id)
	
func _on_lobby_joined(lobby: int,_permissions: int,_locked: bool,response: int) -> void:
	
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("Erro ao entrar no lobby: ", response)
		return
	print("Entrou no lobby!")
	print("Lobby ID: ", lobby)
	lobby_id = lobby
	
	steam_peer = SteamMultiplayerPeer.new()
	var error = steam_peer.create_client(lobby_id)
	if error != OK:
		print("Erro ao conectar SteamMultiplayerPeer: ", error)
		return
	multiplayer.multiplayer_peer = steam_peer
	
	GameManage.change_scene(GameManage.name_scenes.LOBBY)
	await GameManage.change_scene_finish
	add_new_player(multiplayer.get_unique_id())
	
func add_new_player(id_player: int) -> void:
	var new_player: Player = GameManage.instantiate_scene(GameManage.name_scenes.PLAYER)
	var steam_id:int  = Steam.getSteamID()
	new_player.name = str(id_player)
	new_player.set_multiplayer_authority(id_player)
	new_player.steam_id = steam_id
	new_player.username_steam = Steam.getFriendPersonaName(steam_id)
	get_avatar_player_steam(steam_id,new_player)
	player_steam_ready.emit(new_player)
	
	
## funcao de abrir o menu de amigos da steam 	
func invite_friends() -> void:
	print("invite_friends chamado")
	print("Lobby ID: ", lobby_id)

	if lobby_id == 0:
		print("ERRO: nenhum lobby criado")
		return

	print("Abrindo Steam Overlay...")
	Steam.activateGameOverlayInviteDialog(lobby_id)
	print("Comando enviado para Steam")
	
## funcao callback para quando selecionar o amigo que foi selecionado no convite
func _on_lobby_invite(steam_id: int,lobby_id_invite: int,game_id: int) -> void:
	print("Convite recebido!")
	print("Quem convidou: ", steam_id)
	print("Lobby: ", lobby_id_invite)
	print("Game ID: ", game_id)
	join_server(lobby_id_invite)	
	
## funcao de pegar avatar da steam
func get_avatar_player_steam(steam_id: int, player: Player):
	print("Requesitando o avatar")
	players_avatar[steam_id] = player
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM,steam_id)
	
func _on_avatar_loaded(avatar_id: int, size: int, buffer: PackedByteArray):
	if not players_avatar.has(avatar_id):
		print("Player não encontrado para o Steam ID: ", avatar_id)
		return
	var image = Image.create_from_data(
		size,
		size,
		false,
		Image.FORMAT_RGBA8,
		buffer
	)
	var texture = ImageTexture.create_from_image(image)
	var player: Player = players_avatar[avatar_id]
	player.avatar_steam = texture
	print("Avatar colocado no Player: ", avatar_id)
	
	
	
	
