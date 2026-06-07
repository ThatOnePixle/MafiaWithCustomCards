extends Node

# The port we will listen to.
const PORT = 8080

# Our TCP Server instance.
var _tcp_server = TCPServer.new()

# Our connected peers list.
var _peers: Dictionary[int, WebSocketPeer] = {}

var last_peer_id := 1

@onready var mainRoot: Control = $".."

func _ready():
	# Start listening on the given port.
	var err = _tcp_server.listen(PORT)
	if err == OK:
		print("Server started.")
	else:
		push_error("Unable to start server.")
		set_process(false)

func _process(_delta):
	while _tcp_server.is_connection_available():
		last_peer_id += 1
		print("+ Peer %d connected." % last_peer_id)
		var ws = WebSocketPeer.new()
		ws.accept_stream(_tcp_server.take_connection())
		_peers[last_peer_id] = ws

	# Iterate over all connected peers using "keys()" so we can erase in the loop
	for peer_id in _peers.keys():
		var peer = _peers[peer_id]

		peer.poll()

		var peer_state = peer.get_ready_state()
		if peer_state == WebSocketPeer.STATE_OPEN:
			while peer.get_available_packet_count():
				var packet = peer.get_packet()
				if peer.was_string_packet():
					var packet_text = packet.get_string_from_utf8()
					print("< Got text data from peer %d: %s" % [peer_id, packet_text])
					_recieve_data(peer_id, JSON.parse_string(packet_text))
				else:
					print("< Got binary data from peer %d: %d" % [peer_id, packet.size()])
		elif peer_state == WebSocketPeer.STATE_CLOSED:
			# Remove the disconnected peer.
			_peers.erase(peer_id)
			var code = peer.get_close_code()
			var reason = peer.get_close_reason()
			print("- Peer %s closed with code: %d, reason %s. Clean: %s" % [peer_id, code, reason, code != -1])

func _send_to_all(data: Dictionary):
	for peer in _peers.values():
		peer.send_text(JSON.stringify(data))

func _recieve_data(client, data):
	match data["type"]:
		"join":
			mainRoot.nonBotPlayers[data["name"]] = client
			print(mainRoot.nonBotPlayers)
			mainRoot.get_node("lobby")._change_players(1)
			_peers[client].send_text(JSON.stringify({"type": "lobby"}))
		"action":
			mainRoot._perform_action(data["gameState"], mainRoot.players[mainRoot._get_key_from_value(mainRoot.nonBotPlayers, client)], data["target"])
			
		"vote":
			if mainRoot._collect_vote(
				"vote",
				data["target"],
				len(mainRoot._get_members({"dead":[false, null]})),
				{
					"gameState": "voteing",
					"player": {"voteing": {"type": "voted out"}}
				}
			):
				mainRoot._check_win_cons(mainRoot._get_win_con(), "night")
func _send_data(state: String, extraData):
	match state:
		"lobby":
			_send_to_all({"type": "lobby"})
		"night":
			for player in mainRoot.players.keys():
				if mainRoot.players[player].get("night", {}).get("type", "") == "multiple":
					for action in mainRoot.players[player]["night"]["actions"].values():
						_send_action_data("action", action, _peers[mainRoot.nonBotPlayers[player]])
				else:
					_send_action_data("action", player.get("night", {}), _peers[mainRoot.nonBotPlayers[player]])
				
		"vote":
			for player in mainRoot.players.keys():
				if mainRoot.players[player].get("vote", {}).get("type", "") == "multiple":
					for action in mainRoot.players[player]["vote"]["actions"].values():
						_send_action_data("action", action, _peers[mainRoot.nonBotPlayers[player]])
				else:
					_send_action_data("action", player.get("vote", {}), _peers[mainRoot.nonBotPlayers[player]])
				_send_action_data("vote", {"target":"selection"}, _peers[mainRoot.nonBotPlayers[player]])
		"win":
			_send_to_all({"type": "win", "playersWon": extraData})
		"info":
			_send_to_all({"type": "info", "location": "resultText", "message": extraData})

func _send_action_data(gameState, actionData, peer):
		var options: Array = []
		if actionData.get("target", "") == "selection":
			options = mainRoot._get_members({"dead": [false, null]})
		peer.send_text(JSON.stringify({"type": gameState, "options": options}))
	
