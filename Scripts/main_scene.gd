extends Node3D

var peer
@export var player_scene: PackedScene = load("res://Scenes/player.tscn")

var IP_address: String = "10.0.0.9"
var port: int = 5555
var database: SQLite
var is_host = false

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func create_sql_table():
	var table = {
		"id" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"playerid": {"data_type":"int"},
		"score": {"data_type":"int"}
	}
	database.create_table("players", table)

func insert_data_to_database(playerid: int, score: int):
	var data = {
		"playerid": playerid,
		"score": score
		}
	database.insert_row("players", data)

func _on_connected_to_server():
	_register_player.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func _register_player(username: String):
	if is_host:
		var sender_id = multiplayer.get_remote_sender_id()
		insert_data_to_database(sender_id, 0)

func _on_host_button_up() -> void:
#	database = SQLite.new()
#	database.path = "res://data.db"
#	database.open_db()
#	create_sql_table()
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
#	insert_data_to_database(peer.get_unique_id(), 42)
	$CanvasLayer.hide()


func _on_join_button_up() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_address, port)
	multiplayer.multiplayer_peer = peer
#	insert_data_to_database(peer.get_unique_id(), 200)
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
