extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------
#Roles
var roleOptions: Dictionary = _load_roles_data()
var teams: Array = _load_team_data()
var roles: Array[String] = []

#Players
var players: Dictionary[String, Dictionary] = {}
var nonBotPlayers: Dictionary[String, WebSocketPeer] = {}

#Nodes
@onready var lobbyNode: Control = $"lobby manager"
@onready var packetNode: Node = $"packet manager"
@onready var actionNode: Node = $"action manager"
@onready var winNode: Node = $"win manager"

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
		for location in conditions.keys():
			if player[location[0]].get(location[1], null) not in conditions[location]:
				playerPass = false
		if playerPass:
			members.append(player)
	return members
func _player_list_to_ids(playerList: Array):
	var playerIdList: Array = []
	for player in playerList:
		playerIdList.append(player["persistant data"].get("id", "Unknown"))
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
		if player["role"]["team"] == "neutral":
			teamData.append(player["role"])
	return teamData
func _create_json_var(varStructure: Dictionary):
	var returnVar = 0
	match varStructure["type"]:
		"players":
			returnVar = len(_get_members({["conditions","dead"]: [false, null]}))
			match varStructure["condition"]:
				"is team":
					returnVar = len(_get_members({["role","team"]: [varStructure["team"]], ["conditions","dead"]: [false, null]}))
			if varStructure.get("inverted", false):
				returnVar = len(_get_members({["conditions","dead"]: [false, null]})) - returnVar
		"constant":
			returnVar = int(varStructure["number"])
	return returnVar

#Check Win-Cons
func _get_win_con():
	var teamsThatHaveWon: Array = []
	for team in teams:
		#print(team)
		match team["win con"]["type"]:
			"compare":
				var var1 = _create_json_var(team["win con"]["var1"])
				var var2 = _create_json_var(team["win con"]["var2"])
				var comp = team["win con"]["comparison"]
				if comparisons.has(comp) and comparisons[comp].call(var1, var2):
					teamsThatHaveWon.append(team)
			"has tag":
				if players[team["id"]]["conditions"].get(team["win con"]["tag"], false):
					teamsThatHaveWon.append(team)
	return teamsThatHaveWon
func _check_win_cons(teamWin, webScene) -> void:
	var playersWon: Array = []
	print(players)
	if teamWin != []:
		webScene = "win"
		for player in players.values():
			if player["role"]["team"] == "neutral":
				if player["role"] in teamWin:
					playersWon.append(player["persistant data"]["id"])
			else:
				for team in teamWin:
					if player["role"]["team"] == team["name"]:
						playersWon.append(player["persistant data"]["id"])
		lobbyNode.visible = true
		print(str(playersWon) + " have won!")
	
	#clean up
	for player in players.values():
		player.get("conditions", {}).erase("protected")
	actionNode.voteColecter.clear()
	actionNode.nightCompletedList.clear()
	actionNode.voteCompletedList.clear()
	actionNode.gameState = webScene
	packetNode._send_data(webScene, playersWon)
