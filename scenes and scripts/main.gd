extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------
#Roles
var roleOptions: Dictionary = _load_roles_data()
var roles: Array[String] = []
var teams: Array = []

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
func _get_members(conditions: Dictionary[String, Array]):
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
		playerIdList.append(player["id"])
	return playerIdList

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
				if players[team["playerID"]].get(team["win con"]["tag"], false):
					teamsThatHaveWon.append(team)
	return teamsThatHaveWon
func _check_win_cons(teamWin, sceneToTransitionTo, webScene) -> void:
	var playersWon: Array = []
	print(players)
	if teamWin == []:
		get_child(1).queue_free()
		add_child(sceneToTransitionTo.instantiate())
	else:
		for player in players.values():
			if player["team"] == "neutral":
				if player in teamWin:
					playersWon.append(player["playerID"])
			else:
				for team in teamWin:
					if player["team"] == team["name"]:
						playersWon.append(player["playerID"])
		print(str(playersWon) + " have won!")
	_send_web_info(webScene, playersWon)

#Web Stuff
func _send_web_info(state: String, extraData):
	match state:
		"lobby":
			get_node("web manager")._send_to_all({"type": "lobby"})
		"night":
			for player in nonBotPlayers.keys():
				get_node("web manager").peers[nonBotPlayers[player]].send_text(JSON.stringify({"type": "night", "night": players[player]["night"]}))
		"vote":
			get_node("web manager")._send_to_all({"type": "vote", "options": _player_list_to_ids(_get_members({"dead": [false, null]}))})
		"win":
			get_node("web manager")._send_to_all({"type": "win", "playersWon": extraData})
		"info":
			get_node("web manager")._send_to_all({"type": "info", "message": extraData})

#Assign Roles
func _assign_roles() -> void:
	for playerID in nonBotPlayers.keys():
		var roleToBeAssigned: String = roles[randi_range(0,len(roles)-1)]
		players[playerID] = roleOptions[roleToBeAssigned].duplicate(true)
		players[playerID]["playerID"] = playerID
		roles.erase(roleToBeAssigned)
	for i in range(numOfPlayers - len(players)):
		var roleToBeAssigned: String = roles[randi_range(0,len(roles)-1)]
		players["Bot" + str(i)] = roleOptions[roleToBeAssigned].duplicate(true)
		players["Bot" + str(i)]["playerID"] = "Bot" + str(i)
		roles.erase(roleToBeAssigned)
			
	teams = _load_team_data()

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
