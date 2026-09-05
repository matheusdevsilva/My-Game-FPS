extends Node

enum name_scenes {
	PLAYER,
	LOBBY,
	SPLITSCREEN
}
var scenes: Dictionary[name_scenes, PackedScene] = {
	name_scenes.PLAYER: preload("res://Player/Player.tscn"),
	name_scenes.LOBBY:preload("res://Scenes/Lobby/Lobby.tscn"),
	name_scenes.SPLITSCREEN:preload("res://Scenes/SplitScreen/SplitScreen.tscn")
}
var split_screen: SplitScreen
var current_scene:Node 

func _ready() -> void:
	split_screen = instantiate_scene(name_scenes.SPLITSCREEN) as SplitScreen


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_split_screen"):
		toggle_split_screen()

func toggle_split_screen() -> void:
	add_node_in_scene(split_screen,GameManage.current_scene)
	print("ativando")
	split_screen.visible = not split_screen.visible
	
## Instancia uma cena.
func instantiate_scene(scene: name_scenes) -> Node:
	if not scenes.has(scene):
		return null
	return scenes[scene].instantiate()
	
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
