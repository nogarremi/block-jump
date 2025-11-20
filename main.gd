extends Node

@export var level: PackedScene
var loaded_level
var level_count

var start_time = 0
var game_active = false
var score = 0

var moving_left_time = 0
var moving_right_time = 0
var jumping_time = 0

var input_history = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#SilentWolf.configure({
		#"api_key": "2DO7p8YNVK37iiWZRy4xK7RFec0Tklp94b2UGOSk",
		#"game_id": "BlockJump",
		#"log_level": 1
	#})

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#print(input_history)
		get_tree().quit() # default behavior

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_game") and game_active:
		new_game()
	elif event.is_action_pressed("reset_level") and game_active:
		new_level()
	elif event.is_action_pressed("input_playback") and not game_active:
		input_replay()
	elif event.is_action_pressed("move_left") and game_active:
		moving_left_time = Time.get_ticks_msec()
	elif event.is_action_pressed("move_right") and game_active:
		moving_right_time = Time.get_ticks_msec()
	elif event.is_action_pressed("jump") and game_active:
		jumping_time = Time.get_ticks_msec()
	elif event.is_action_released("move_left") and game_active:
		input_history.append({"move_left":(Time.get_ticks_msec()-moving_left_time)})
		moving_left_time = 0
	elif event.is_action_released("move_right") and game_active:
		input_history.append({"move_right":(Time.get_ticks_msec()-moving_right_time)})
		moving_right_time = 0
	elif event.is_action_released("jump") and game_active:
		input_history.append({"jump":(Time.get_ticks_msec()-jumping_time)})
		jumping_time = 0

func new_game():
	$HUD.update_time(0)
	$HUD.show_message("")
	$HUD.remove_level_scores()
	game_active = true
	start_time = Time.get_ticks_msec()
	score = 0
	level_count = 1

	if loaded_level:
		call_deferred("remove_child", loaded_level)

	var level_scene_name = "res://level%s.tscn" % level_count
	level = load(level_scene_name)
	loaded_level = level.instantiate()
	add_child(loaded_level)
	loaded_level.connect("level_ended", game_over)

	$Player.gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	$Player.start($StartPosition.position)
	$ScoreTimer.start()

func new_level():
	$HUD.update_time(0)
	$HUD.show_message("")
	game_active = true
	start_time = Time.get_ticks_msec()
	score = 0
	
	$Player/CollisionShape2D.disabled = false
	$Player.gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	$Player.start($StartPosition.position)
	$Player.show()
	$ScoreTimer.start()

func game_over(body, event):
	$ScoreTimer.stop()
	game_active = false
	body.gravity = 0
	body.hide()

	if event != "dead":
		if moving_left_time != 0:
			input_history.append({"move_left":(Time.get_ticks_msec()-moving_left_time)})
			moving_left_time = 0
		if moving_right_time != 0:
			input_history.append({"move_right":(Time.get_ticks_msec()-moving_right_time)})
			moving_right_time = 0
		if jumping_time != 0:
			input_history.append({"jump":(Time.get_ticks_msec()-jumping_time)})
			jumping_time = 0

	score += Time.get_ticks_msec() - start_time
	$HUD.update_time(score)
	if level_count <= 4:
		if event != "dead":
			$HUD.show_next_level(level_count)
			call_deferred("remove_child", loaded_level)
			if level.can_instantiate():
				level_count += 1
				var level_scene_name = "res://level%s.tscn" % (level_count)
				level = load(level_scene_name)
				loaded_level = level.instantiate()
				call_deferred("add_child", loaded_level)
				loaded_level.connect("level_ended", game_over)
		else:
			$HUD.show_game_over(event)
	else:
		$HUD.show_game_over(event)

func input_replay():
	$HUD.show_level_replay()
	pass

func _on_playarea_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		var body_collision_obj = body.get_child(1)
		if not body_collision_obj.disabled:
			game_over(body, "dead")

func _on_score_timer_timeout() -> void:
	var new_time = Time.get_ticks_msec()
	score += (new_time - start_time)
	start_time = new_time
	$HUD.update_time(score)

func _on_goal_entered(body: Node2D) -> void:
	if body.name == "Player":
		game_over(body, "goal")
