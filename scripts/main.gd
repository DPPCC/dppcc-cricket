
extends Node3D

const CLUB_NAME = "DUNGSHRI PASCHIM PARA CRICKET CLUB"

var score: int = 0
var wickets: int = 0
var balls: int = 0

var ball: MeshInstance3D
var ball_active: bool = false
var ball_velocity: Vector3 = Vector3.ZERO
var shot_played: bool = false

var score_label: Label
var status_label: Label
var batter: Node3D
var bowler: Node3D
var bat: MeshInstance3D

var ball_material: StandardMaterial3D
var white_material: StandardMaterial3D
var red_material: StandardMaterial3D
var green_material: StandardMaterial3D
var blue_material: StandardMaterial3D
var brown_material: StandardMaterial3D

func _ready() -> void:
    create_materials()
    create_environment()
    create_field()
    create_pitch()
    create_stadium()
    create_players()
    create_ball()
    create_camera()
    create_ui()
    update_scoreboard()


func create_materials() -> void:
    white_material = make_material(Color.WHITE)
    red_material = make_material(Color(0.8, 0.05, 0.04))
    green_material = make_material(Color(0.08, 0.42, 0.12))
    blue_material = make_material(Color(0.05, 0.18, 0.8))
    brown_material = make_material(Color(0.38, 0.19, 0.07))
    ball_material = make_material(Color(0.9, 0.03, 0.02))


func make_material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    return material


func create_environment() -> void:
    var world := WorldEnvironment.new()
    var environment := Environment.new()

    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.35, 0.65, 0.95)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color.WHITE
    environment.ambient_light_energy = 0.7

    world.environment = environment
    add_child(world)

    var sunlight := DirectionalLight3D.new()
    sunlight.rotation_degrees = Vector3(-55, -30, 0)
    sunlight.light_energy = 1.3
    add_child(sunlight)


func add_box(parent: Node3D, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
    var item := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    item.mesh = mesh
    item.position = pos
    item.material_override = material
    parent.add_child(item)
    return item


func add_sphere(parent: Node3D, radius: float, pos: Vector3, material: Material) -> MeshInstance3D:
    var item := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    item.mesh = mesh
    item.position = pos
    item.material_override = material
    parent.add_child(item)
    return item


func add_capsule(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material) -> MeshInstance3D:
    var item := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    item.mesh = mesh
    item.position = pos
    item.material_override = material
    parent.add_child(item)
    return item


func add_limb(parent: Node3D, start: Vector3, finish: Vector3, radius: float, material: Material) -> void:
    var direction: Vector3 = finish - start
    var length: float = direction.length()

    var limb := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = length

    limb.mesh = mesh
    limb.position = (start + finish) / 2.0
    limb.quaternion = Quaternion(Vector3.UP, direction.normalized())
    limb.material_override = material
    parent.add_child(limb)


func create_field() -> void:
    add_box(self, Vector3(100, 0.3, 100), Vector3(0, -0.25, 0), green_material)

    var grass_line := make_material(Color(0.12, 0.48, 0.12))
    add_box(self, Vector3(38, 0.08, 38), Vector3(0, -0.04, 0), grass_line)

    var boundary_material := make_material(Color(1.0, 0.85, 0.1))

    for i in range(40):
        var angle: float = float(i) * TAU / 40.0
        var x: float = cos(angle) * 29.0
        var z: float = sin(angle) * 29.0
        add_sphere(self, 0.22, Vector3(x, 0.15, z), boundary_material)


func create_pitch() -> void:
    var pitch_material := make_material(Color(0.72, 0.56, 0.35))
    add_box(self, Vector3(3.5, 0.12, 24), Vector3(0, 0.02, -1), pitch_material)

    var line_material := make_material(Color.WHITE)

    add_box(self, Vector3(3.5, 0.04, 0.12), Vector3(0, 0.12, -12), line_material)
    add_box(self, Vector3(3.5, 0.04, 0.12), Vector3(0, 0.12, 10), line_material)

    create_wickets(Vector3(0, 0, -10))
    create_wickets(Vector3(0, 0, 8))


func create_wickets(pos: Vector3) -> void:
    for i in range(3):
        var x: float = (float(i) - 1.0) * 0.22
        add_box(self, Vector3(0.08, 0.9, 0.08), pos + Vector3(x, 0.48, 0), white_material)

    add_box(self, Vector3(0.5, 0.05, 0.08), pos + Vector3(0, 0.95, 0), white_material)


func create_stadium() -> void:
    var stand_material := make_material(Color(0.18, 0.2, 0.28))
    var seat_material := make_material(Color(0.25, 0.3, 0.42))

    add_box(self, Vector3(75, 5, 5), Vector3(0, 2, -36), stand_material)
    add_box(self, Vector3(75, 5, 5), Vector3(0, 2, 36), stand_material)
    add_box(self, Vector3(5, 5, 70), Vector3(-36, 2, 0), stand_material)
    add_box(self, Vector3(5, 5, 70), Vector3(36, 2, 0), stand_material)

    for row in range(5):
        for i in range(22):
            var x: float = -27.0 + float(i) * 2.5
            var z1: float = -33.0 - float(row) * 0.7
            var z2: float = 33.0 + float(row) * 0.7

            add_box(self, Vector3(1.0, 0.5, 0.7), Vector3(x, 3.0 + float(row) * 0.5, z1), seat_material)
            add_box(self, Vector3(1.0, 0.5, 0.7), Vector3(x, 3.0 + float(row) * 0.5, z2), seat_material)

    # দর্শক
    var crowd_colors: Array[Color] = [
        Color.RED,
        Color.BLUE,
        Color.YELLOW,
        Color.WHITE,
        Color.ORANGE,
        Color.PURPLE
    ]

    for row in range(5):
        for i in range(22):
            var x: float = -27.0 + float(i) * 2.5
            var z1: float = -31.0 - float(row) * 0.7
            var z2: float = 31.0 + float(row) * 0.7
            var y: float = 3.6 + float(row) * 0.5
            var color_index: int = (i + row) % crowd_colors.size()
            var crowd_material := make_material(crowd_colors[color_index])

            add_sphere(self, 0.25, Vector3(x, y, z1), crowd_material)
            add_sphere(self, 0.25, Vector3(x, y, z2), crowd_material)


func create_player(parent: Node3D, pos: Vector3, shirt: Material, is_batter: bool) -> Node3D:
    var player := Node3D.new()
    player.position = pos
    parent.add_child(player)

    var skin := make_material(Color(0.72, 0.45, 0.28))
    var trousers := make_material(Color(0.08, 0.08, 0.12))

    # শরীর
    add_capsule(player, 0.38, 1.0, Vector3(0, 1.35, 0), shirt)

    # মাথা
    add_sphere(player, 0.28, Vector3(0, 2.15, 0), skin)

    # হাত
    add_limb(player, Vector3(-0.35, 1.7, 0), Vector3(-0.55, 1.05, -0.1), 0.13, shirt)
    add_limb(player, Vector3(0.35, 1.7, 0), Vector3(0.55, 1.05, -0.1), 0.13, shirt)

    # পা
    add_limb(player, Vector3(-0.18, 0.9, 0), Vector3(-0.22, 0.12, 0), 0.16, trousers)
    add_limb(player, Vector3(0.18, 0.9, 0), Vector3(0.22, 0.12, 0), 0.16, trousers)

    # জুতা
    add_box(player, Vector3(0.35, 0.15, 0.5), Vector3(-0.22, 0.08, -0.12), trousers)
    add_box(player, Vector3(0.35, 0.15, 0.5), Vector3(0.22, 0.08, -0.12), trousers)

    # ব্যাট
    if is_batter:
        var bat_item := add_box(player, Vector3(0.18, 1.35, 0.12), Vector3(0.65, 0.95, -0.25), brown_material)
        bat_item.rotation_degrees.z = -20
        bat = bat_item

    return player


func create_players() -> void:
    batter = create_player(self, Vector3(0, 0, 4), blue_material, true)
    bowler = create_player(self, Vector3(0, 0, -14), red_material, false)

    create_player(self, Vector3(0, 0, 10), green_material, false)

    # ফিল্ডার
    create_player(self, Vector3(-12, 0, -8), red_material, false)
    create_player(self, Vector3(12, 0, -8), red_material, false)
    create_player(self, Vector3(-19, 0, 2), red_material, false)
    create_player(self, Vector3(19, 0, 2), red_material, false)
    create_player(self, Vector3(-10, 0, 18), red_material, false)
    create_player(self, Vector3(10, 0, 18), red_material, false)


func create_ball() -> void:
    ball = MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.16
    mesh.height = 0.32
    ball.mesh = mesh
    ball.material_override = ball_material
    ball.position = Vector3(0, 1.2, -12)
    add_child(ball)


func create_camera() -> void:
    var camera := Camera3D.new()
    camera.position = Vector3(0, 8, 17)
    camera.look_at(Vector3(0, 1, -2), Vector3.UP)
    camera.current = true
    camera.fov = 65
    add_child(camera)


func create_ui() -> void:
    var canvas := CanvasLayer.new()
    add_child(canvas)

    score_label = Label.new()
    score_label.position = Vector2(15, 15)
    score_label.add_theme_font_size_override("font_size", 23)
    score_label.add_theme_color_override("font_color", Color.WHITE)
    canvas.add_child(score_label)

    status_label = Label.new()
    status_label.position = Vector2(15, 55)
    status_label.add_theme_font_size_override("font_size", 18)
    status_label.add_theme_color_override("font_color", Color.YELLOW)
    canvas.add_child(status_label)

    var panel := PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    panel.offset_top = -100
    panel.offset_bottom = -10
    panel.offset_left = 10
    panel.offset_right = -10
    canvas.add_child(panel)

    var buttons := HBoxContainer.new()
    buttons.add_theme_constant_override("separation", 8)
    panel.add_child(buttons)

    make_button(buttons, "BOWL", _on_bowl)
    make_button(buttons, "DRIVE", _on_drive)
    make_button(buttons, "DEFEND", _on_defend)
    make_button(buttons, "PULL", _on_pull)


func make_button(parent: Control, button_text: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = button_text
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.custom_minimum_size = Vector2(0, 65)
    button.add_theme_font_size_override("font_size", 18)
    button.pressed.connect(callback)
    parent.add_child(button)


func update_scoreboard() -> void:
    score_label.text = CLUB_NAME + "\nDPPCC CRICKET   |   %d/%d   |   Overs: %d.%d" % [
        score,
        wickets,
        int(balls / 6),
        balls % 6
    ]


func _on_bowl() -> void:
    if ball_active:
        status_label.text = "Wait for the current ball!"
        return

    if wickets >= 10 or balls >= 120:
        status_label.text = "INNINGS FINISHED!"
        return

    balls += 1
    shot_played = false
    ball.position = Vector3(0, 1.3, -12)
    ball_velocity = Vector3(0, -0.3, 11.5)
    ball_active = true
    status_label.text = "BOWLER IS RUNNING IN!"
    update_scoreboard()


func play_shot(direction: float, power: float, shot_name: String) -> void:
    if not ball_active:
        status_label.text = "First press BOWL!"
        return

    if shot_played:
        status_label.text = "You already played this ball!"
        return

    var distance_to_batter: float = abs(ball.position.z - 3.0)

    if distance_to_batter > 3.0 or ball.position.y > 2.8:
        status_label.text = "Too early or too late!"
        return

    shot_played = true
    ball_velocity = Vector3(direction * power, 5.0, -14.0)
    status_label.text = shot_name + " SHOT!"
    
    if bat != null:
        var tween := create_tween()
        tween.tween_property(bat, "rotation_degrees:z", -95.0, 0.12)
        tween.tween_property(bat, "rotation_degrees:z", -20.0, 0.25)


func _on_drive() -> void:
    play_shot(0.0, 1.0, "DRIVE")


func _on_defend() -> void:
    play_shot(0.0, 0.25, "DEFENCE")


func _on_pull() -> void:
    play_shot(1.0, 1.7, "PULL")


func _process(delta: float) -> void:
    if not ball_active:
        return

    ball_velocity.y -= 9.8 * delta
    ball.position += ball_velocity * delta

    if shot_played and ball.position.z < -27.0:
        if abs(ball.position.x) > 28.0:
            score += 6
            status_label.text = "SIX! AMAZING SHOT!"
        else:
            score += 4
            status_label.text = "FOUR! GREAT SHOT!"

        ball_active = false
        update_scoreboard()

    elif not shot_played and ball.position.z > 6.0:
        wickets += 1
        ball_active = false
        status_label.text = "OUT! WICKET!"
        update_scoreboard()

    elif ball.position.y < 0.0:
        if shot_played:
            score += 1
            status_label.text = "ONE RUN!"
            update_scoreboard()
        else:
            status_label.text = "DOT BALL!"
        ball_active = false
