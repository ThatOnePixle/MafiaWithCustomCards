extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------
#Roles
var roleOptions: Dictionary = _load_roles_data()
var roles: Array[String] = []
var teams: Array = []

#Mid Game
var voteColecter: Dictionary[String, Dictionary] = {}
var nightCompletedList: Array[Dictionary] = []
var voteCompletedList: Array[Dictionary] = []

#Players
var players: Dictionary[String, Dictionary] = {}
var numOfPlayers: int = 0
var nonBotPlayers: Dictionary[String, int] = {}

#Nodes
@onready var lobbyNode: Control = $lobby

#Comparisons
var comparisons = {
	"==": func(a, b): return a == b,
	"!=": func(a, b): return a != b,
	">=": func(a, b): return a >= b,
	"<=": func(a, b): return a <= b,
	">":  func(a, b): return a > b,
	"<":  func(a, b): return a < b
}

#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------

#Misc Functions
func _get_members(conditions: Dictionary):
	var members: Array = []
	for player in players.values():
		var playerPass: bool = true
		for condition in conditions.keys():
			if player.get(condition, null) not in conditions[condition]:
				playerPass = false
		if playerPass:
			members.append(player)
	return members
func _player_list_to_ids(playerList: Array):
	var playerIdList: Array = []
	for player in playerList:
		playerIdList.append(player.get("id", "Unknown"))
	return playerIdList
func _get_key_from_value(dict: Dictionary, value):
	return dict.keys()[dict.values().find(value)]


#Setup Custom Data
func _load_roles_data():
	var rolesData = {}
	var dir = DirAccess.open("res://roles")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file = FileAccess.open("res://roles/" + file_name, FileAccess.READ)
			var data = JSON.parse_string(file.get_as_text())
			rolesData[data["name"]] = data  # ← key by name
		file_name = dir.get_next()
	return rolesData
func _load_team_data():
	var teamData = []
	var dir = DirAccess.open("res://teams")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file = FileAccess.open("res://teams/" + file_name, FileAccess.READ)
			var data = JSON.parse_string(file.get_as_text())
			teamData.append(data)
		file_name = dir.get_next()
	#Neutral Roles
	for player in players.values():
		if player["team"] == "neutral":
			teamData.append(player)
	return teamData
func _create_json_var(varStructure: Dictionary):
	var returnVar = 0
	match varStructure["type"]:
		"players":
			returnVar = len(_get_members({"dead": [false, null]}))
			match varStructure["condition"]:
				"is team":
					returnVar = len(_get_members({"team": [varStructure["team"]], "dead": [false, null]}))
			if varStructure.get("inverted", false):
				returnVar = len(_get_members({"dead": [false, null]})) - returnVar
		"constant":
			returnVar = int(varStructure["number"])
	return returnVar

#Check Win-Cons
func _get_win_con():
	var teamsThatHaveWon: Array = []
	for team in teams:
		print(team)
		match team["win con"]["type"]:
			"compare":
				var var1 = _create_json_var(team["win con"]["var1"])
				var var2 = _create_json_var(team["win con"]["var2"])
				var comp = team["win con"]["comparison"]
				if comparisons.has(comp) and comparisons[comp].call(var1, var2):
					teamsThatHaveWon.append(team)
			"has tag":
				if players[team["id"]].get(team["win con"]["tag"], false):
					teamsThatHaveWon.append(team)
	return teamsThatHaveWon
func _check_win_cons(teamWin, webScene) -> void:
	var playersWon: Array = []
	print(players)
	if teamWin != []:
		webScene = "win"
		for player in players.values():
			if player["team"] == "neutral":
				if player in teamWin:
					playersWon.append(player["id"])
			else:
				for team in teamWin:
					if player["team"] == team["name"]:
						playersWon.append(player["id"])
		lobbyNode.visible = true
		print(str(playersWon) + " have won!")
	voteColecter.clear()
	nightCompletedList.clear()
	voteCompletedList.clear()
	get_node("web manager")._send_data(webScene, playersWon)

#Assign Roles
func _assign_roles() -> void:
	var tempRoles: Array[String] = roles.duplicate(true)
	for id in nonBotPlayers.keys():
		var roleToBeAssigned: String = tempRoles[randi_range(0,len(tempRoles)-1)]
		players[id] = roleOptions[roleToBeAssigned].duplicate(true)
		players[id]["id"] = id
		tempRoles.erase(roleToBeAssigned)
	for i in range(numOfPlayers - len(players)):
		var roleToBeAssigned: String = tempRoles[randi_range(0,len(tempRoles)-1)]
		players["Bot" + str(i)] = roleOptions[roleToBeAssigned].duplicate(true)
		players["Bot" + str(i)]["id"] = "Bot" + str(i)
		tempRoles.erase(roleToBeAssigned)
			
	teams = _load_team_data()

#night
func _perform_action(gameState: String, player: Dictionary, target: String) -> void:
	match player[gameState]["type"]:
		"voted out":
			players[target]["dead"] = true
			players[target]["voted out"] = true
		"vote":
			_collect_vote(
				player[gameState]["group"],
				target,
				len(_get_members({"name":[player["name"]], "dead":[false, null]})),
				{
					"gameState": gameState,
					"player": {gameState: {"type": player[gameState]["action"]}}
				}
			)
		"kill":
			if !players[target].get("protected", false):
				players[target]["dead"] = true
			else: 
				players[target]["protected"] = false
		"protect":
			players[target]["protected"] = true
		"investigate":
			get_node("night/resultLabel").text = players[target]["name"]
			get_node("web manager")._peers[player["id"]].send_text(JSON.stringify({"type": "info", "resultText": players[target]["name"]}))
	if player not in nightCompletedList:
		nightCompletedList.append(player)
	if len(nightCompletedList) + len(_get_members({"night":[null]})) >= len(players): 
		_check_win_cons(_get_win_con(), "vote")
func _collect_vote(voteGroup: String, target: String, votesNeeded: int, actionData: Dictionary) -> bool:
	if !voteColecter.has(voteGroup):
		voteColecter[voteGroup] = {}

	voteColecter[voteGroup][target] = voteColecter[voteGroup].get(target, 0) + 1
	var totalVotes = 0
	for v in voteColecter[voteGroup].values():
		totalVotes += v

	if totalVotes >= votesNeeded:
		var amountOfVotes: Array = voteColecter[voteGroup].values()
		amountOfVotes.sort()

		var highestVotes = amountOfVotes[-1]
		var winningTarget = target

		if amountOfVotes.size() > 1:
			if highestVotes != amountOfVotes[-2]:
				winningTarget = _get_key_from_value(voteColecter[voteGroup], highestVotes)

		_perform_action(actionData["gameState"], actionData["player"], winningTarget)
	return totalVotes >= votesNeeded

#Swapping Scenes
func _start() -> void:
	lobbyNode.visible = false
	_assign_roles()
	_check_win_cons(_get_win_con(), "night")
