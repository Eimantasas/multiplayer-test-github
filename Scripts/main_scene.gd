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
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	create_sql_table()
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	insert_data_to_database(peer.get_unique_id(), "hostuser")
	$CanvasLayer.hide()


func _on_join_button_up() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_address, port)
	multiplayer.multiplayer_peer = peer
	_insert_data.rpc(peer.get_unique_id(), "client")
	$CanvasLayer.hide()

@rpc("authority", "call_remote", "reliable")
func _insert_data(id: int, user: String):
	insert_data_to_database(id, user)
	
func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func del_player(id):
	await get_tree().create_timer(1).timeout
	rpc("_del_player", id)

@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
