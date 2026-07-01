extends Node

@onready var mainRoot: Node = $".."
@onready var webManager: Node = $"web manager"

func _send_to_all(data: Dictionary):
	for peer in mainRoot.nonBotPlayers.values():
		peer.send_text(JSON.stringify(data))

func _recieve_data(client, data):
	match data["type"]:
		"join":
			mainRoot.nonBotPlayers[data["name"]] = webManager._peers[client]
			print(mainRoot.nonBotPlayers)
			mainRoot.get_node("lobby manager")._change_players(1)
			mainRoot.nonBotPlayers[data["name"]].send_text(JSON.stringify({"type": "lobby"}))
		"action":
			mainRoot.get_node("action manager")._perform_action(data["gameState"], mainRoot.players[mainRoot.get_node("action manager")._get_key_from_value(mainRoot.nonBotPlayers, webManager._peers[client])], data["target"])
			
		"vote":
			if mainRoot._collect_vote(
				"vote",
				data["target"],
				len(mainRoot._get_members({["conditions","dead"]:[false, null]})),
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
				if mainRoot.players[player]["role"].get("night", {}).get("type", "") == "multiple":
					for action in mainRoot.players[player]["role"]["night"]["actions"].values():
						_send_action_data("action", action, mainRoot.nonBotPlayers[player], mainRoot.players[player]["role"]["name"])
				else:
					_send_action_data("action", mainRoot.players[player]["role"].get("night", {}), mainRoot.nonBotPlayers[player], mainRoot.players[player]["role"]["name"])
				
		"vote":
			for player in mainRoot.players.keys():
				if mainRoot.players[player]["role"].get("vote", {}).get("type", "") == "multiple":
					for action in mainRoot.players[player]["role"]["vote"]["actions"].values():
						_send_action_data("action", action, mainRoot.nonBotPlayers[player], mainRoot.players[player]["role"]["name"])
				else:
					_send_action_data("action", mainRoot.players[player]["role"].get("vote", {}), mainRoot.nonBotPlayers[player], mainRoot.players[player]["role"]["name"])
				_send_action_data("vote", {"target":"selection"}, mainRoot.nonBotPlayers[player], mainRoot.players[player]["role"]["name"])
		"win":
			_send_to_all({"type": "win", "playersWon": extraData})
		"info":
			_send_to_all({"type": "info", "location": "resultText", "message": extraData})

func _send_action_data(gameState, actionData, peer, playerRole):
		var options: Array = []
		if actionData.get("target", "") == "selection":
			options = mainRoot._player_list_to_ids(mainRoot._get_members({["conditions","dead"]: [false, null]}))
			print(options)
		peer.send_text(JSON.stringify({"type": gameState, "options": options, "role":playerRole}))
