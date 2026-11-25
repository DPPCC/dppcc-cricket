
extends Node3D

const CLUB_NAME := "DUNGSHRI PASCHIM PARA CRICKET CLUB"
const GAME_NAME := "DPPCC CRICKET"

var camera: Camera3D
var ball: MeshInstance3D
var status_label: Label
var score_label: Label
var menu_panel: Control
var match_panel: Control

var score: int = 0
var wickets: int = 0
var balls_faced: int = 0
var ball_in_motion: bool = false
var ball_z: float = -4.5
var shot_used: bool = false


func _ready() -> void:
    _build_world()
    _build_interface()
    _show_menu()


# ---------------- WORLD ----------------

func _build_world() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.38, 0.62, 0.82)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.8, 0.82, 0.85)
    env.ambient_light_energy = 0.9
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.2
    add_child(sun)

    _build_stadium()
    _build_pitch()
    _build_wickets()

    camera = Camera3D.new()
    camera.position = Vector3(0, 19, 34)
    camera.look_at(Vector3(0, 0, 0), Vector3.UP)
    camera.current = true
    add_child(camera)

    ball = MeshInstance3D.new()
    var ball_mesh := SphereMesh.new()
    ball_mesh.radius = 0.18
    ball_mesh.height = 0.36
    ball.mesh = ball_mesh

    var ball_mat := StandardMaterial3D.new()
    ball_mat.albedo_color = Color(0.9, 0.04, 0.03)
    ball.material_override = ball_mat
    ball.position = Vector3(0, 0.35, -4.5)
    ball.visible = false
    add_child(ball)


func _mat(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.9
    return material


func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
    var obj := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    obj.mesh = mesh
    obj.position = pos
    obj.material_override = _mat(color)
    parent.add_child(obj)
    return obj


func _build_stadium() -> void:
    var field := MeshInstance3D.new()
    var field_mesh := CylinderMesh.new()
    field_mesh.top_radius = 1.0
    field_mesh.bottom_radius = 1.0
    field_mesh.height = 0.3
    field_mesh.radial_segments = 64
    field.mesh = field_mesh
    field.scale = Vector3(38, 1, 31)
    field.position.y = -0.16
    field.material_override = _mat(Color(0.10, 0.36, 0.14))
    add_child(field)

    var inner := MeshInstance3D.new()
    var inner_mesh := CylinderMesh.new()
    inner_mesh.top_radius = 1.0
    inner_mesh.bottom_radius = 1.0
    inner_mesh.height = 0.12
    inner_mesh.radial_segments = 64
    inner.mesh = inner_mesh
    inner.scale = Vector3(34, 1, 27)
    inner.position.y = 0.02
    inner.material_override = _mat(Color(0.16, 0.46, 0.19))
    add_child(inner)

    for i in range(64):
        var angle: float = TAU * float(i) / 64.0
        var x: float = 34.0 * cos(angle)
        var z: float = 27.0 * sin(angle)

        var marker := MeshInstance3D.new()
        var marker_mesh := SphereMesh.new()
        marker_mesh.radius = 0.16
        marker.mesh = marker_mesh
        marker.position = Vector3(x, 0.15, z)
        marker.material_override = _mat(Color(1.0, 0.95, 0.75))
        add_child(marker)

    _build_stands()
    _build_floodlights()
    _build_scoreboard()


func _build_stands() -> void:
    var concrete := Color(0.19, 0.22, 0.27)
    var blue := Color(0.08, 0.28, 0.62)
    var white := Color(0.85, 0.87, 0.90)

    for side in [-1.0, 1.0]:
        for row in range(6):
            var z: float = float(side) * (31.0 + float(row) * 1.6)
            var y: float = 0.45 + float(row) * 0.72

            _box(self, Vector3(59, 0.55, 1.5),
                Vector3(0, y, z), concrete)

            for section in range(8):
                var x: float = -25.0 + float(section) * 7.1
                var seat_color: Color = blue if (row + section) % 2 == 0 else white
                _box(self, Vector3(6.7, 0.2, 0.55),
                    Vector3(x, y + 0.32, z), seat_color)

    for side in [-1.0, 1.0]:
        for row in range(5):
            var x: float = float(side) * (38.0 + float(row) * 1.4)
            var y: float = 0.4 + float(row) * 0.72
            _box(self, Vector3(1.5, 0.55, 48),
                Vector3(x, y, 0), concrete)


func _build_floodlights() -> void:
    var pole_color := Color(0.34, 0.37, 0.42)

    for x_side in [-1.0, 1.0]:
        for z_side in [-1.0, 1.0]:
            var pole := MeshInstance3D.new()
            var pole_mesh := CylinderMesh.new()
            pole_mesh.top_radius = 0.15
            pole_mesh.bottom_radius = 0.28
            pole_mesh.height = 19.0
            pole.mesh = pole_mesh
            pole.position = Vector3(float(x_side) * 39, 9.5, float(z_side) * 33)
            pole.material_override = _mat(pole_color)
            add_child(pole)

            var lamp := _box(
                self,
                Vector3(2.8, 0.8, 1.2),
                Vector3(float(x_side) * 39, 19, float(z_side) * 33),
                Color(1.0, 0.94, 0.72)
            )

            var lamp_material := StandardMaterial3D.new()
            lamp_material.albedo_color = Color(1.0, 0.94, 0.72)
            lamp_material.emission_enabled = true
            lamp_material.emission = Color(1.0, 0.82, 0.52)
            lamp_material.emission_energy_multiplier = 2.0
            lamp.material_override = lamp_material


func _build_scoreboard() -> void:
    _box(
        self,
        Vector3(12, 5, 0.6),
        Vector3(0, 7, -43),
        Color(0.02, 0.05, 0.09)
    )

    var board_text := Label3D.new()
    board_text.text = "DPPCC CRICKET"
    board_text.font_size = 64
    board_text.position = Vector3(0, 7.5, -42.6)
    board_text.pixel_size = 0.012
    board_text.modulate = Color.WHITE
    board_text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(board_text)

    var club_text := Label3D.new()
    club_text.text = "DUNGSHRI PASCHIM PARA CRICKET CLUB"
    club_text.font_size = 22
    club_text.position = Vector3(0, 6.3, -42.6)
    club_text.pixel_size = 0.012
    club_text.modulate = Color(0.75, 0.85, 1.0)
    club_text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(club_text)


# ---------------- PITCH ----------------

func _build_pitch() -> void:
    _box(
        self,
        Vector3(3.2, 0.12, 12),
        Vector3(0, 0.02, 0),
        Color(0.66, 0.48, 0.30)
    )

    for z in [-4.2, 4.2]:
        _box(
            self,
            Vector3(4.0, 0.025, 0.12),
            Vector3(0, 0.095, z),
            Color.WHITE
        )

        for side in [-1.0, 1.0]:
            _box(
                self,
                Vector3(0.12, 0.025, 1.0),
                Vector3(float(side) * 1.8, 0.095, z),
                Color.WHITE
            )


func _build_wickets() -> void:
    for z in [-4.2, 4.2]:
        for i in range(3):
            var stump := MeshInstance3D.new()
            var stump_mesh := CylinderMesh.new()
            stump_mesh.top_radius = 0.045
            stump_mesh.bottom_radius = 0.045
            stump_mesh.height = 1.1
            stump.mesh = stump_mesh
            stump.position = Vector3((i - 1) * 0.18, 0.58, z)
            stump.material_override = _mat(Color(0.95, 0.85, 0.65))
            add_child(stump)


# ---------------- GAME INTERFACE ----------------

func _build_interface() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    menu_panel = _make_panel(layer)
    match_panel = _make_panel(layer)

    var title := _make_label(menu_panel, GAME_NAME, 38)
    title.position = Vector2(0, 95)
    title.size = Vector2(1280, 60)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var club := _make_label(menu_panel, CLUB_NAME, 17)
    club.position = Vector2(0, 160)
    club.size = Vector2(1280, 35)
    club.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var start_button := _make_button(
        menu_panel, "START PRACTICE MATCH",
        Vector2(440, 300), Vector2(400, 68)
    )
    start_button.pressed.connect(_start_match)

    var note := _make_label(
        menu_panel, "DPPCC 3D STADIUM PROTOTYPE", 15
    )
    note.position = Vector2(0, 610)
    note.size = Vector2(1280, 30)
    note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    score_label = _make_label(match_panel, "DPPCC | 0/0 (0.0 overs)", 24)
    score_label.position = Vector2(24, 18)
    score_label.size = Vector2(500, 45)

    status_label = _make_label(
        match_panel, "Press BOWL to deliver the ball", 19
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


func _make_panel(parent: Node) -> Control:
    var panel := Control.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    parent.add_child(panel)
    return panel


func _make_label(parent: Node, value: String, font_size: int) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", Color.WHITE)
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


# ---------------- MATCH SYSTEM ----------------

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
        status_label.text = "Wait for the current delivery."
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
                status_label.text = "DOT BALL. Press BOWL again."

            _update_score()


func _update_score() -> void:
    var completed_overs: int = int(balls_faced / 6)
    var balls_in_over: int = balls_faced % 6

    score_label.text = "DPPCC | %d/%d (%d.%d overs)" % [
        score,
        wickets,
        completed_overs,
        balls_in_over
    ]
