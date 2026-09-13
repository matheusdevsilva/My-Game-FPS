extends Node3D

var ost = [
	"res://Scenes/vitrola/4. Glacier.mp3",
	"res://Scenes/vitrola/1. Government Funding.mp3",
]

var current_song := 0

@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	audio.finished.connect(_on_song_finished)
	play_song(current_song)


func play_song(index: int) -> void:
	audio.stream = load(ost[index])
	audio.play()


func _on_song_finished() -> void:
	current_song += 1
	if current_song >= ost.size():
		current_song = 0
	play_song(current_song)
