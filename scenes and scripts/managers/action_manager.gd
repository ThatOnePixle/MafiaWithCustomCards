extends Node
#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $".."
var players = mainRoot.players

#Mid Game
var voteColecter: Dictionary[String, Dictionary] = {}
var nightCompletedList: Array[Dictionary] = []
var voteCompletedList: Array[Dictionary] = []

#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------

func _get_key_from_value(dict: Dictionary, value):
	return dict.keys()[dict.values().find(value)]

#actions
func _perform_action(gameState: String, player: Dictionary, target: String) -> void:
	match player.get(gameState, {"type":""})["type"]:
		"voted out":
			players[target]["consitions"]["dead"] = true
			players[target]["consitions"]["voted out"] = true
		"vote":
			_collect_vote(
				player["role"][gameState]["group"],
				target,
				len(mainRoot._get_members({"name":[player["role"]["name"]], "dead":[false, null]})),
				{
					"gameState": gameState,
					"player": {gameState: {"type": player["role"][gameState]["action"]}}
				}
			)
		"kill":
			if !players[target]["conditions"].get("protected", false):
				players[target]["conditions"]["dead"] = true
		"protect":
			players[target]["conditions"]["protected"] = true
		"investigate":
			var targetsRole = players[target]["role"]["name"]
			mainRoot.webNode._peers[player["id"]].send_text(JSON.stringify({"type": "info", "resultText": targetsRole}))
	if player["id"] not in nightCompletedList:
		nightCompletedList.append(player["id"])
	if len(nightCompletedList) + len(mainRoot._get_members({"night":[null]})) >= len(players): 
		mainRoot._check_win_cons(mainRoot._get_win_con(), "vote")
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
