extends Control

#----------------------------------------------------------------------------------------------------
#Variables
#----------------------------------------------------------------------------------------------------

@onready var mainRoot = $"../.."
@onready var background = $background
#----------------------------------------------------------------------------------------------------
#Functions
#----------------------------------------------------------------------------------------------------

func _ready() -> void:
	for i in range(1,mainRoot.numOfPlayers):
		var buttonPerPerson: Button = Button.new()
		buttonPerPerson.text = "Bot " + str(i)
		buttonPerPerson.anchor_top = 0.2
		buttonPerPerson.anchor_bottom = 0.9
		buttonPerPerson.anchor_left = float(i) * 1/mainRoot.numOfPlayers - 0.1
		buttonPerPerson.anchor_top = buttonPerPerson.anchor_left + 0.2
		background.add_child(buttonPerPerson)
