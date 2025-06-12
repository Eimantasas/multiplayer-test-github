extends Node3D

var peer
@export var player_scene: PackedScene = load("res://Scenes/player.tscn")

var IP_address: String = "172.31.1.76"
var port: int = 5555
var database: SQLite

func create_sql_table():
	var table = {
		"id" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"playerid": {"data_type":"int"},
		"username": {"data_type":"text"}
	}
	database.create_table("players", table)


func insert_data_to_database(playerid: int, username: String):
	var data = {
		"playerid": playerid,
		"username": username
		}
	database.insert_row("players", data)


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
