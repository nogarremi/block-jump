extends Node

signal level_ended

func _on_goal_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var body_collision_obj = body.get_child(1)
		if not body_collision_obj.disabled:
			body_collision_obj.set_deferred("disabled", true)
			level_ended.emit(body, "goal")
