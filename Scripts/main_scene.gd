extends Node3D

var peer
@export var player_scene: PackedScene = load("res://Scenes/player.tscn")

var IP_address: String = "127.0.0.1"
var port: int = 5555


func _on_host_button_up() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$CanvasLayer.hide()


func _on_join_button_up() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_address, port)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func del_player(id):
	rpc("_del_player", id)

@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
