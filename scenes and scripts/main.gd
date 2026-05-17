extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------
#Roles
var roleOptions: Dictionary = _load_roles_data()
var roles: Array[String] = []
var teams: Array = []

#Roles Variables
var voteColecter: Dictionary[String, Dictionary] = {}

#Players
var players: Dictionary[String, Dictionary] = {}
var numOfPlayers: int = 1
var nonBotPlayers: Dictionary[String, int] = {}

#Scenes
var lobbyScene: PackedScene = preload("res://scenes and scripts/lobby/lobby.tscn")
var nightScene: PackedScene = preload("res://scenes and scripts/night/night.tscn")
var voteingScene: PackedScene = preload("res://scenes and scripts/voteing/voteing.tscn")
var lobbySceneObject: Node = lobbyScene.instantiate()

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
func _check_win_cons(teamWin, sceneToTransitionTo, webScene) -> void:
	var playersWon: Array = []
	print(players)
	if teamWin == []:
		voteColecter.clear()
		get_child(1).queue_free()
		add_child(sceneToTransitionTo.instantiate())
	else:
		for player in players.values():
			if player["team"] == "neutral":
				if player in teamWin:
					playersWon.append(player["id"])
			else:
				for team in teamWin:
					if player["team"] == team["name"]:
						playersWon.append(player["id"])
		add_child(lobbySceneObject)
		print(str(playersWon) + " have won!")
	get_node("web manager")._send_data(webScene, playersWon)

#Assign Roles
func _assign_roles() -> void:
	for id in nonBotPlayers.keys():
		var roleToBeAssigned: String = roles[randi_range(0,len(roles)-1)]
		players[id] = roleOptions[roleToBeAssigned].duplicate(true)
		players[id]["id"] = id
		roles.erase(roleToBeAssigned)
	for i in range(numOfPlayers - len(players)):
		var roleToBeAssigned: String = roles[randi_range(0,len(roles)-1)]
		players["Bot" + str(i)] = roleOptions[roleToBeAssigned].duplicate(true)
		players["Bot" + str(i)]["id"] = "Bot" + str(i)
		roles.erase(roleToBeAssigned)
			
	teams = _load_team_data()

#night
func _perform_action(gameState: String, player: Dictionary, target: String) -> void:
	match player[gameState]["type"]:
		"voted out":
			players[target]["dead"] = true
			players[target]["voted out"] = true
		"vote":
			_vote_action_logic(gameState, player, target)
		"kill":
			if !players[target].get("protected", false):
				players[target]["dead"] = true
		"protect":
			players[target]["protected"] = true
		"investigate":
			get_node("night/resultLabel").text = players[target]["name"]
			get_node("web manager")._peers[player["id"]].send_text(JSON.stringify({"type": "info", "resultText": players[target]["name"]}))
func _vote_action_logic(gameState: String, player: Dictionary, target: String) -> void:
	if !voteColecter.has(player["role"]):
		voteColecter[player["role"]] = {}
	voteColecter[player["role"]][target] = voteColecter[player["role"]].get(target, 0) + 1
	
	if len(voteColecter[player["role"]].values()) >= len(_get_members({"name":["Mafia (0)"], "dead": [false, null]})):
		var amountOfVotes: Array = voteColecter[player["role"]].values()
		amountOfVotes.sort()
		var highestAmountOfVotes: int = amountOfVotes[len(voteColecter[player["role"]].values())-1]
		if amountOfVotes.size() > 1:
			if highestAmountOfVotes != amountOfVotes[len(voteColecter[player["role"]].values())-2]:	
				target = _get_key_from_value(voteColecter[player["role"]], highestAmountOfVotes)
		_perform_action(gameState, {gameState: {"type": player[gameState]["action"]}}, target)

#Voteing
func _player_vote(target: String) -> void:
	if !voteColecter.has("vote"):
		voteColecter["vote"] = {}
	voteColecter["vote"][target] = voteColecter["vote"].get(target, 0) + 1
	if len(voteColecter["vote"].values()) >= len(_get_members({"dead":[false, null]})):
		var amountOfVotes: Array = voteColecter["vote"].values()
		amountOfVotes.sort()
		var highestAmountOfVotes: int = amountOfVotes[len(voteColecter["vote"].values())-1]
		if highestAmountOfVotes != amountOfVotes[len(voteColecter["vote"].values())-2]:	
			target = _get_key_from_value(voteColecter["vote"], highestAmountOfVotes)
			_perform_action("voteing", {"voteing": {"type": "voted out"}}, target)

#Swapping Scenes
func _ready() -> void:
	add_child(lobbySceneObject)
func _start() -> void:
	_assign_roles()
	_check_win_cons(_get_win_con(), nightScene, "night")
func _start_vote() -> void:
	_check_win_cons(_get_win_con(), voteingScene, "vote")
func _end_vote() -> void:
	_check_win_cons(_get_win_con(),nightScene, "night")
