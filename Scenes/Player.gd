extends KinematicBody2D

var Motion = Vector2(0.0, 0.0)

var Dead = false
var ChargingJump = false
var JumpForce
var Jumping = false
var LastMovementLeft = false

var AnimationRunning = false

signal Died

func _ready():
	var slimeColor = Color(rand_range(0.5, 1.0), rand_range(0.5, 1.0), rand_range(0.5, 1.0), 1.0)
	$Sprite.modulate = slimeColor
	$JumpForce.modulate = slimeColor
	SwitchAnimation("Spawn")

func _physics_process(delta):
	Motion.y += 600.0 * delta
	
	if Dead:
		SwitchAnimation("Dead")
		Motion.x = 0.0
	else:
		var isOnFloor = is_on_floor()
		if Motion.y > 20.0:
			if Motion.y < 50.0:
				SwitchAnimation("JumpArcTop")
			elif Motion.y < 150.0:
				SwitchAnimation("JumpArcDown")
			else:
				SwitchAnimation("Fall")
		elif Jumping:
			if isOnFloor:
				SwitchAnimation("Land")
				Jumping = false
			else:
				if Motion.y > -150.0:
					if Motion.y < -50.0:
						SwitchAnimation("JumpArcUpSlow")
					else:
						SwitchAnimation("JumpArcDown")
		
		var xMove = 0.0
		if Input.is_action_pressed("ui_left"):
			xMove += -6000.0 * delta
		if Input.is_action_pressed("ui_right"):
			xMove += 6000.0 * delta
		if Input.is_action_pressed("ui_up"):
			if ChargingJump:
				xMove = 0.0
				JumpForce = min(JumpForce + (delta * 400.0), 600.0)
				$JumpForce.value = JumpForce
				if JumpForce < 300.0:
					SwitchAnimation("Crouch")
				else:
					SwitchAnimation("CrouchDeeper")
			elif isOnFloor:
				ChargingJump = true
				JumpForce = 0.0
				$JumpForce.value = JumpForce
		elif ChargingJump:
			ChargingJump = false
			Motion.y = -JumpForce
			Jumping = true
			SwitchAnimation("JumpStart")
			
		$JumpForce.visible = ChargingJump
		
		if xMove > 0.0:
			LastMovementLeft = false
		elif xMove < 0.0:
			LastMovementLeft = true
		
		if isOnFloor and not ChargingJump and not Jumping:
			if xMove > 0.0:
				SwitchAnimation("WalkRight")
			elif xMove < 0.0:
				SwitchAnimation("WalkLeft")
			elif LastMovementLeft:
				SwitchAnimation("IdleLeft")
			else:
				SwitchAnimation("IdleRight")
		
		Motion.x = xMove
		
		if isOnFloor:
			if $GroundDetectors/Left.is_colliding() and $GroundDetectors/Middle.is_colliding() and $GroundDetectors/Right.is_colliding():
				if $GreaterSpikeDetection.get_overlapping_bodies().size() == 0:
					Global.RespawnPosition = get_position()
	Motion = move_and_slide(Motion, Vector2(0.0, -1.0))

func SwitchAnimation(animation):
	var current = $AnimationPlayer.current_animation
	if not ((current == "Land" or current == "Spawn") and AnimationRunning):
		if current != animation:
			$AnimationPlayer.play(animation)

func _on_AnimationPlayer_animation_finished(anim_name):
	AnimationRunning = false

func _on_AnimationPlayer_animation_started(anim_name):
	AnimationRunning = true

func _on_SpikeDetection_body_entered(body):
	Die()

func Die():
	if not Dead:
		Dead = true
		set_collision_layer_bit(5, false)
		set_collision_mask_bit(5, false)
		$SpikeDetection.call_deferred("queue_free")
		$GreaterSpikeDetection.call_deferred("queue_free")
		$GroundDetectors.call_deferred("queue_free")
		$JumpForce.visible = false
		call_deferred("emit_signal", "Died")
