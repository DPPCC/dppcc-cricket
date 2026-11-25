
extends Node3D

const CLUB_NAME := "DUNGSHRI PASCHIM PARA CRICKET CLUB"
const GAME_NAME := "DPPCC CRICKET"

var camera: Camera3D
var ball: MeshInstance3D
var status_label: Label
var score_label: Label
var menu_panel: Control
var match_panel: Control

var score := 0
var wickets := 0
var balls_faced := 0
var ball_in_motion := false
var ball_z := -4.5
var shot_used := false

func _ready() -> void:
    _build_world()
    _build_interface()
    _show_menu()

func _build_world() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.42, 0.68, 0.88)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.75, 0.78, 0.82)
    env.ambient_light_energy = 0.8
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.2
    add_child(sun)

    var ground := MeshInstance3D.new()
    var ground_mesh := PlaneMesh.new()
    ground_mesh.size = Vector2(24, 24)
    ground.mesh = ground_mesh
    ground.position.y = -0.12

    var grass := StandardMaterial3D.new()
    grass.albedo_color = Color(0.16, 0.43, 0.19)
    ground.material_override = grass
    add_child(ground)

    var pitch := MeshInstance3D.new()
    var pitch_mesh := BoxMesh.new()
    pitch_mesh.size = Vector3(3.0, 0.12, 12.0)
    pitch.mesh = pitch_mesh
    pitch.position = Vector3(0, -0.02, 0)

    var pitch_mat := StandardMaterial3D.new()
    pitch_mat.albedo_color = Color(0.66, 0.48, 0.30)
    pitch.material_override = pitch_mat
    add_child(pitch)

    _add_wickets(Vector3(0, 0.55, -4.2))
    _add_wickets(Vector3(0, 0.55, 4.2))

    camera = Camera3D.new()
    camera.position = Vector3(0, 8.5, 14.5)
    camera.look_at(Vector3(0, 0.3, 0), Vector3.UP)
    camera.current = true
    add_child(camera)

    ball = MeshInstance3D.new()
    var ball_mesh := SphereMesh.new()
    ball_mesh.radius = 0.18
    ball_mesh.height = 0.36
    ball.mesh = ball_mesh

    var ball_mat := StandardMaterial3D.new()
    ball_mat.albedo_color = Color(0.82, 0.08, 0.06)
    ball.material_override = ball_mat
    ball.position = Vector3(0, 0.35, -4.5)
    ball.visible = false
    add_child(ball)

func _add_wickets(at_position: Vector3) -> void:
    for i in range(3):
        var stump := MeshInstance3D.new()
        var stump_mesh := CylinderMesh.new()
        stump_mesh.top_radius = 0.045
        stump_mesh.bottom_radius = 0.045
        stump_mesh.height = 1.1
        stump.mesh = stump_mesh

        stump.position = at_position + Vector3((i - 1) * 0.18, 0, 0)

        var wood := StandardMaterial3D.new()
        wood.albedo_color = Color(0.92, 0.83, 0.60)
        stump.material_override = wood
        add_child(stump)

func _build_interface() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    menu_panel = _make_panel(layer, "menu_panel")

    var title := _make_label(
        menu_panel, GAME_NAME, 38, Color.WHITE
    )
    title.position = Vector2(0, 95)
    title.size = Vector2(1280, 60)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var club := _make_label(
        menu_panel, CLUB_NAME, 17, Color(0.88, 0.91, 0.95)
    )
    club.position = Vector2(0, 160)
    club.size = Vector2(1280, 35)
    club.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var start_button := _make_button(
        menu_panel,
        "START PRACTICE MATCH",
        Vector2(440, 300),
        Vector2(400, 68)
    )
    start_button.pressed.connect(_start_match)

    var note := _make_label(
        menu_panel,
        "EARLY PLAYABLE PROTOTYPE - GODOT 4",
        15,
        Color(0.78, 0.82, 0.87)
    )
    note.position = Vector2(0, 610)
    note.size = Vector2(1280, 30)
    note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    match_panel = _make_panel(layer, "match_panel")

    score_label = _make_label(
        match_panel,
        "DPPCC | 0/0 (0.0 overs)",
        24,
        Color.WHITE
    )
    score_label.position = Vector2(24, 18)
    score_label.size = Vector2(500, 45)

    status_label = _make_label(
        match_panel,
        "Press BOWL to deliver the ball",
        19,
        Color.WHITE
    )
    status_label.position = Vector2(0, 560)
    status_label.size = Vector2(1280, 40)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var bowl_button := _make_button(
        match_panel, "BOWL",
        Vector2(900, 620), Vector2(150, 62)
    )
    bowl_button.pressed.connect(_bowl)

    var shot_button := _make_button(
        match_panel, "SHOT",
        Vector2(1070, 620), Vector2(150, 62)
    )
    shot_button.pressed.connect(_play_shot)

    var back_button := _make_button(
        match_panel, "MENU",
        Vector2(24, 620), Vector2(130, 62)
    )
    back_button.pressed.connect(_show_menu)

func _make_panel(parent: Node, node_name: String) -> Control:
    var panel := Control.new()
    panel.name = node_name
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    parent.add_child(panel)
    return panel

func _make_label(
    parent: Node,
    value: String,
    font_size: int,
    color: Color
) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    parent.add_child(label)
    return label

func _make_button(
    parent: Node,
    value: String,
    pos: Vector2,
    button_size: Vector2
) -> Button:
    var button := Button.new()
    button.text = value
    button.position = pos
    button.size = button_size
    button.add_theme_font_size_override("font_size", 20)
    parent.add_child(button)
    return button

func _show_menu() -> void:
    menu_panel.visible = true
    match_panel.visible = false
    ball_in_motion = false
    ball.visible = false

func _start_match() -> void:
    score = 0
    wickets = 0
    balls_faced = 0

    _update_score()

    menu_panel.visible = false
    match_panel.visible = true
    status_label.text = "Practice match started. Press BOWL."

func _bowl() -> void:
    if ball_in_motion:
        status_label.text = "Wait for the current delivery to finish."
        return

    ball_in_motion = true
    shot_used = false
    ball_z = -4.5
    ball.position = Vector3(0, 0.35, ball_z)
    ball.visible = true

    status_label.text = "Ball coming... time your SHOT!"

func _play_shot() -> void:
    if not ball_in_motion:
        status_label.text = "Press BOWL first."
        return

    if shot_used:
        status_label.text = "You already played this delivery."
        return

    shot_used = true

    if ball_z >= -1.7 and ball_z <= 1.5:
        score += 4
        status_label.text = "PERFECT TIMING! FOUR RUNS."
    else:
        status_label.text = "Shot missed. No runs."

    _update_score()

func _process(delta: float) -> void:
    if ball_in_motion:
        ball_z += delta * 5.0
        ball.position.z = ball_z

        if ball_z >= 4.0:
            ball_in_motion = false
            ball.visible = false
            balls_faced += 1

            if not shot_used:
                status_label.text = "DOT BALL. Press BOWL for next delivery."

            _update_score()

func _update_score() -> void:
    var completed_overs := int(balls_faced / 6)
    var balls_in_over := balls_faced % 6

    score_label.text = "DPPCC | %d/%d (%d.%d overs)" % [
        score,
        wickets,
        completed_overs,
        balls_in_over
    ]
