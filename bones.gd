extends CharacterBody2D

var speed = 40 #pixels / sec
enum states {IDLE, CHASE, ATTACK, DEAD, HURT}
var state = states.IDLE
var player
var health = 3
var attacking = false
var minimap_icon = "mob"
signal removed

func _physics_process(_delta):
	choose_action()
	move_and_slide()

func choose_action():
	$Label.text = states.keys()[state]
	match state:
		states.DEAD:
			removed.emit(self)
			$AnimationPlayer.play("death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
		states.IDLE:
			$AnimationPlayer.play("idle")
			velocity = Vector2.ZERO
		states.CHASE:
			$AnimationPlayer.play("run")
			velocity = position.direction_to(player.position) * speed
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
		states.ATTACK:
			attacking = true
			velocity = Vector2.ZERO
			$AnimationPlayer.play("attack")
			transform.x.x = sign(position.direction_to(player.position).x)
			attacking = false

func _on_attack_body_entered(body):
	state = states.ATTACK


func _on_detect_body_entered(body):
	player = body
	state = states.CHASE


func _on_detect_body_exited(body):
#	player = null
	state = states.IDLE


func _on_attack_body_exited(body):
	state = states.CHASE

func hurt(amount, dir):
	health -= amount
	var prev_state = state
	state = states.HURT
	velocity = dir * 100
	await get_tree().create_timer(0.2).timeout
	state = prev_state
	if health <= 0:
		state = states.DEAD

func _on_hurtbox_area_entered(area):
	area.get_parent().hurt(1, position.direction_to(area.get_parent().position))
