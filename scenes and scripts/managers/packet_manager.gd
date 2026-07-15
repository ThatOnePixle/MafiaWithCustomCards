extends Node

@onready var mainRoot: Node = $".."
@onready var webManager: Node = $"web manager"
@onready var actionManager: Node = $"../action manager"

func _send_to_all(data: Dictionary):
	for peer in mainRoot.nonBotPlayers.values():
		peer.send_text(JSON.stringify(data))

func _recieve_data(client, data):
	match data["type"]:
		"join":
			mainRoot.nonBotPlayers[data["name"]] = webManager._peers[client]
			#print(mainRoot.nonBotPlayers)
			mainRoot.get_node("lobby manager")._change_players(1)
			mainRoot.nonBotPlayers[data["name"]].send_text(JSON.stringify({"type": "lobby"}))
		"action":
			if data.isVote:
				if actionManager._collect_vote(
					"vote",
					data["target"],
					len(mainRoot._get_members({["conditions","dead"]:[false, null]})),
					{
						"player": {"role":{"vote": {"type": "voted out"}}}
					}
				):
					mainRoot._check_win_cons(mainRoot._get_win_con(), "night")
			else:
				mainRoot.get_node("action manager")._perform_action(mainRoot.players[mainRoot.get_node("action manager")._get_key_from_value(mainRoot.nonBotPlayers, webManager._peers[client])], data["target"], true)
			
func _send_data(state: String, extraData):
	var data: Dictionary
	for player in mainRoot.players.keys():
		match state:
			"lobby":
				data = {"type": "lobby"}
			"night":
				data = _send_action_data(mainRoot.players[player]["role"].get("night", {}),  mainRoot.players[player]["role"]["name"], mainRoot.players[player]["conditions"].get("dead", false), false)
			"vote":
				data = _send_action_data({"target":"selection"}, mainRoot.players[player]["role"]["name"], mainRoot.players[player]["conditions"].get("dead", false), true)
			"win":
				data = {"type": "win", "playersWon": extraData}
			"info":
				data = {"type": "info", "location": "resultText", "message": extraData}
		mainRoot.nonBotPlayers[player].send_text(JSON.stringify(data))

func _send_action_data(actionData, playerRole, dead: bool, isVote: bool):
	var options: Array = []
	if actionData.get("target", "") == "selection" and !dead:
		options = mainRoot._player_list_to_ids(mainRoot._get_members({["conditions","dead"]: [false, null]}))
	return {"type": "action", "isVote": isVote, "options": options, "role":playerRole}
