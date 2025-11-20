extends CanvasLayer

signal start_game
signal valid_leaderboard_submission
signal next_level

var player_name: String
var score: int
var high_scores
var total_score = 0
var level_scores = []

func remove_level_scores():
	level_scores = []
	total_score = 0

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()

func show_game_state_message(text):
	show_message(text)
	await get_tree().create_timer(0.5).timeout
	$MessageLabel.hide()

func show_next_level(level_count):
	$Overlay.show()
	total_score += score
	show_message("Level Cleared!")
	
	level_scores.append(await send_score("level_%d" % level_count))
	
	$NextLevelButton.show()
	$NextLevelButton.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func show_game_over(event):
	$Overlay.show()
	if event == "dead":
		show_message("You fell!")
		$NextLevelButton.show()
		$NextLevelButton.grab_focus()
	elif event == "goal":
		show_message("You won!")
		total_score += score
		
		level_scores.append(await send_score("level_5"))
		send_score()
		
		$Leaderboard.show()
		$StartButton.show()
		$StartButton.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LeaderboardName.show()
	$LeaderboardName.grab_focus()
	await get_scores()
	await valid_leaderboard_submission
	$LeaderboardName.hide()
	$LeaderboardName.clear()
	update_leaderboard_label()
	$Leaderboard.show()
	$StartButton.show()
	$StartButton.grab_focus()

func convert_ms_to_readable_time(ms):
	var milli = ms % 1000
	var seconds = ms / 1000 % 60
	var minutes = ms / 60000
	if minutes > 0:
		return " %02d:%02d.%03d" % [minutes, seconds, milli]
	else:
		return "%02d.%03d" % [seconds, milli]

func update_time(time):
	score = time
	$LevelScoreLabel.text = "Time: %s" % convert_ms_to_readable_time(time)
	$TotalScoreLabel.text = "Total Time: %s" % convert_ms_to_readable_time(total_score + time)

func update_leaderboard_label():
	pass
	#for index in range(high_scores.size()):
		#$Leaderboard.text += "%d: %s %s" % [index+1, high_scores[index][0], convert_ms_to_readable_time(high_scores[index][1])]

func send_score(leaderboard="main"):
	pass
	#var res
	#if leaderboard == "main":
		#var metadata = {"segments":level_scores}
		#res = await SilentWolf.Scores.save_score(player_name, total_score, leaderboard, metadata).sw_save_score_complete
	#else:
		#res = await SilentWolf.Scores.save_score(player_name, score, leaderboard).sw_save_score_complete
	#
	#return res["score_id"]

func get_scores(leaderboard="main"):
	pass
	#var sw_result: Dictionary = await SilentWolf.Scores.get_scores(5, leaderboard).sw_get_scores_complete
	#var temp_scores = sw_result.scores
	#high_scores = []
	#for index in range(temp_scores.size()):
		#high_scores.append([temp_scores[index]["player_name"], int(temp_scores[index]["score"])])

func show_level_replay():
	pass

func _on_start_button_pressed() -> void:
	score = 0
	remove_level_scores()
	$Overlay.hide()
	$Leaderboard.hide()
	$Leaderboard.text = ""
	$StartButton.hide()
	$MessageLabel.hide()
	$ControlsLabel.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	start_game.emit()

func _on_leaderboard_name_text_submitted(new_text: String) -> void:
	if new_text.length() == 0:
		return
	player_name = new_text
	valid_leaderboard_submission.emit()

func _on_next_level_button_pressed() -> void:
	score = 0
	$Overlay.hide()
	$Leaderboard.hide()
	$Leaderboard.text = ""
	$NextLevelButton.hide()
	$MessageLabel.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	next_level.emit()
