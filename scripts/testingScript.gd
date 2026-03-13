extends Node2D

var start:= Vector2(50, 80)
var end:= Vector2(300, 200)

var testNode = graphNode.new(50, 80)
var test = Edge.new(start, end)

func _ready():
	add_child(test)
	add_child(testNode)
