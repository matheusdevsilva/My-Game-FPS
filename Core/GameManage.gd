extends Node

signal change_scene_finish

signal menu_opened(menu: NameMenu)
signal menu_closed(menu: NameMenu)

## Enum de nomes da cenas
enum NameScene {
	PLAYER,
	MAIN_MENU,
	LOBBY,
	SPLITSCREEN
}
enum NameMenu {
	MENU_PLAYER,
	HUD_PLAYER,
	SETTINGS,
	CREDITS
}
const SCENES: Dictionary[NameScene, PackedScene] = {
	NameScene.PLAYER: preload("res://Player/Player.tscn"),
	NameScene.MAIN_MENU: preload("res://Scenes/MainMenu/MainMenu.tscn"),
	NameScene.LOBBY: preload("res://Scenes/Lobby/Lobby.tscn"),
	NameScene.SPLITSCREEN: preload("res://Scenes/SplitScreen/SplitScreen.tscn")
}
const MENUS: Dictionary[NameMenu, PackedScene] = {
	NameMenu.MENU_PLAYER: preload("res://Player/UI/PlayerMenu.tscn"),
	NameMenu.HUD_PLAYER: preload("res://Player/UI/PlayerHUD.tscn"),
}

var current_scene:Node 
var current_menu:Control
var current_menu_id: NameMenu


func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	SteamManage.player_steam_ready.connect(_on_player_steam_ready)
	
## funcao para trocar de cena
func change_scene(scene: NameScene) -> void:
	if not SCENES.has(scene):
		return
	get_tree().change_scene_to_packed(SCENES[scene])
	
## callback que e chamado quando a cena e carregada
func _on_scene_changed() -> void:
	current_scene = get_tree().current_scene
	change_scene_finish.emit()

## Instancia uma cena.
func instantiate_scene(scene: NameScene) -> Node:
	if not SCENES.has(scene):
		return null
	return SCENES[scene].instantiate()
	
## Remove um Node do parent atual.
func remove_node_in_scene(node: Node) -> void:
	if not is_instance_valid(node):
		return
	var parent := node.get_parent()
	if not parent:
		return
	parent.remove_child(node)

## Adiciona um Node a um parent.
func add_node_in_scene(node: Node, parent: Node) -> void:
	if not is_instance_valid(node) or not is_instance_valid(parent):
		return
	if node.get_parent():
		return	
	parent.add_child(node)

## Move um Node para um novo parent.
func move_node_in_scene(node: Node, new_parent: Node) -> void:
	if not is_instance_valid(node) or not is_instance_valid(new_parent) or node == new_parent :
		return
	var old_parent := node.get_parent()
	if old_parent:
		old_parent.remove_child(node)
	new_parent.add_child(node)


##
func play_singleplayer() -> void:
	change_scene(NameScene.LOBBY)
	await change_scene_finish
	add_node_in_scene(instantiate_scene(NameScene.PLAYER),current_scene)

func _on_player_steam_ready(player: Player) -> void:
	add_node_in_scene(player, current_scene)


func open_menu(menu: NameMenu) -> void:
	if not MENUS.has(menu):
		return
	# Se o mesmo menu já estiver aberto, fecha
	if is_instance_valid(current_menu):
		if current_menu_id == menu:
			close_menu()
			return
		# Se for outro menu, fecha o anterior
		close_menu()
	var new_menu := MENUS[menu].instantiate() as Control
	if not new_menu:
		return
	current_menu = new_menu
	current_menu_id = menu
	add_node_in_scene(current_menu, current_scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	menu_opened.emit(menu)

func close_menu() -> void:
	if not is_instance_valid(current_menu):
		current_menu = null
		return
	var closed_menu := current_menu_id
	current_menu.queue_free()
	current_menu = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	menu_closed.emit(closed_menu)
