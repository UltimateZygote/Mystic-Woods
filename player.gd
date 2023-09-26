extends CharacterBody2D
class_name Player

var run_speed = 75
var attacking = false
var hurting = false
enum states {IDLE, RUN, ATTACK, DEAD, HURT}
var state = states.IDLE
var player
var health = 5
signal health_changed

func _physics_process(_delta):
	var input = Input.get_vector("left", "right", "up", "down")
	choose_action()
	$Label2.text = str(health)
	if !hurting:
		velocity = input * run_speed
	if !attacking:
		move_and_slide()
		#pick which animation
		if velocity.length() > 0:
			state = states.RUN
		else:
			state = states.IDLE
		#flipping direction
		if velocity.x != 0:
			transform.x.x = sign(velocity.x)

func _input(event):
	if state == states.DEAD:
		return
	if event.is_action_pressed("attack"):
		attacking = true
		state = states.ATTACK
		$AnimationPlayer.play("attack")
		await $AnimationPlayer.animation_finished
		attacking = false

func choose_action():
	$Label.text = states.keys()[state]
	match state:
		states.DEAD:
			$AnimationPlayer.play("death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
		states.IDLE:
			$AnimationPlayer.play("idle")
		states.ATTACK:
			velocity = Vector2.ZERO
		states.RUN:
			$AnimationPlayer.play("run")
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)

func hurt(amount, dir):
	health -= amount
	health_changed.emit(health)
	var prev_state = state
	hurting = true
	state = states.HURT
	velocity = dir * 100
	await get_tree().create_timer(0.2).timeout
	state = prev_state
	hurting = false
	if health <= 0:
		state = states.DEAD

func _on_hurtbox_area_entered(area):
	area.get_parent().hurt(1, position.direction_to(area.get_parent().position))


