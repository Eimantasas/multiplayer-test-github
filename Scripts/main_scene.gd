extends Node3D

var peer

@onready var player_scene: PackedScene = load("res://Scenes/player.tscn")
@onready var user_line: LineEdit = $CanvasLayer/LineEdit
@onready var user_warn_label: Label = $CanvasLayer/UserWarningLabel
@onready var tab_container: TabContainer = $CanvasLayer/TabContainer
@onready var x_button: Button = $CanvasLayer/X

var IP_address: String = "127.0.0.1"
var port: int = 5555
var database: SQLite

func _ready() -> void:
	user_warn_label.visible = false
	tab_container.visible = false
	x_button.visible = false


#Database Functions
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



#Button Functions
func _on_host_button_up() -> void:
	if user_line.text == "":
		user_warn_label.visible = true
		return
	
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	create_sql_table()
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	add_player()
	insert_data_to_database(peer.get_unique_id(), user_line.text)
	print(user_line.text, " is hosting!")
	$CanvasLayer.hide()


func _on_join_button_up() -> void:
	if user_line.text == "":
		user_warn_label.visible = true
		return
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_address, port)
	multiplayer.multiplayer_peer = peer
	_insert_data.rpc(peer.get_unique_id(), user_line.text)
	print(user_line.text, " joined!")
	$CanvasLayer.hide()

func _on_info_button_up() -> void:
	tab_container.visible = true
	x_button.visible = true

func _on_x_button_up() -> void:
	tab_container.visible = false
	x_button.visible = false


#player networking functions
@rpc("authority", "call_remote", "reliable")
func _insert_data(id: int, user: String):
	insert_data_to_database(id, user)
	
func exit_game(id):
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
