class_name GameScene
extends Node2D

signal game_over(final_score)

@onready var fish_spawner = $FishSpawner
@onready var touch_input_handler = $TouchInputHandler
@onready var hud = $HUD

# Configuraciones de juego
@export var initial_round_fish_count: int = 10
@export var special_fish_interval: int = 5
@export var frenzy_threshold: int = 5
@export var frenzy_duration: float = 10.0
@export var max_wrong_cuts: int = 5  # Nueva configuración para fin de juego

# Variables de estado de juego
var current_score: int = 0
var current_combo: int = 0
var fish_cut_in_round: int = 0
var is_frenzy_mode: bool = false
var frenzy_timer: float = 0.0
var current_round: int = 1
var wrong_cuts_count: int = 0

# Gestión de dificultad
var difficulty_multiplier: float = 1.0

func _ready():
    # Conectar señales
    touch_input_handler.connect("cut_performed", Callable(self, "_on_cut_performed"))
    fish_spawner.connect("fish_spawned", Callable(self, "_on_fish_spawned"))
    
    # Iniciar primera ronda
    start_round()

func _process(delta):
    # Gestión del modo frenesí
    if is_frenzy_mode:
        frenzy_timer -= delta
        if frenzy_timer <= 0:
            end_frenzy_mode()
    
    # Actualizar dificultad gradualmente
    difficulty_multiplier += delta * 0.01

func start_round():
    # Reiniciar variables de ronda
    fish_cut_in_round = 0
    is_frenzy_mode = false
    current_combo = 0
    
    # Iniciar spawneo de peces
    fish_spawner.start_spawning(
        initial_round_fish_count, 
        difficulty_multiplier
    )

func _on_cut_performed(cut_points):
    # Buscar peces bajo el corte
    var fishes_under_cut = _find_fishes_under_cut(cut_points)
    
    if not fishes_under_cut.is_empty():
        # Cortar el primer pez encontrado
        fishes_under_cut[0].on_cut(cut_points)

func _on_fish_spawned(fish):
    # Conectar señales de pez
    fish.connect("perfect_cut", Callable(self, "_on_perfect_cut"))
    fish.connect("wrong_cut", Callable(self, "_on_wrong_cut"))
    fish.connect("special_fish_cut", Callable(self, "_on_special_fish_cut"))

func _on_perfect_cut(combo_multiplier):
    # Actualizar puntuación y combo
    current_combo += 1
    var points = 10 * combo_multiplier * (1 if not is_frenzy_mode else 2)
    current_score += points
    
    # Actualizar HUD
    hud.update_score(current_score)
    hud.update_combo(current_combo)
    
    # Resetear cortes incorrectos
    wrong_cuts_count = 0
    
    # Verificar modo frenesí
    if current_combo >= frenzy_threshold and not is_frenzy_mode:
        start_frenzy_mode()
    
    # Conteo de peces cortados
    fish_cut_in_round += 1
    check_round_completion()

func _on_wrong_cut():
    # Incrementar cortes incorrectos
    wrong_cuts_count += 1
    
    # Resetear combo
    current_combo = 0
    hud.update_combo(current_combo)
    
    # Penalización por corte incorrecto
    current_score = max(0, current_score - 5)
    hud.update_score(current_score)
    
    # Verificar condición de fin de juego
    if wrong_cuts_count >= max_wrong_cuts:
        game_over()

func _on_special_fish_cut(points):
    # Manejar puntuación del pez especial
    current_score += points
    hud.update_score(current_score)

func start_frenzy_mode():
    is_frenzy_mode = true
    frenzy_timer = frenzy_duration
    hud.activate_frenzy_mode()

func end_frenzy_mode():
    is_frenzy_mode = false
    hud.deactivate_frenzy_mode()

func check_round_completion():
    # Verificar si se ha completado la ronda
    if fish_cut_in_round >= initial_round_fish_count:
        # Incrementar ronda
        current_round += 1
        
        # Verificar intervalo de pez especial
        if current_round % special_fish_interval == 0:
            spawn_special_fish()
        else:
            # Iniciar siguiente ronda
            start_round()

func spawn_special_fish():
    fish_spawner.spawn_special_fish(difficulty_multiplier)

func _find_fishes_under_cut(cut_points: PackedVector2Array) -> Array:
    var fishes_under_cut = []
    
    # Verificar todos los puntos del corte
    for point in cut_points:
        for fish in get_tree().get_nodes_in_group("fish"):
            if _is_point_inside_fish(point, fish) and not fishes_under_cut.has(fish):
                fishes_under_cut.append(fish)
    
    return fishes_under_cut

func _is_point_inside_fish(point: Vector2, fish: Fish) -> bool:
    # Utilizar método de colisión de Area2D
    return fish.overlaps_point(point)

func game_over():
    # Detener spawneo de peces
    fish_spawner.stop_spawning()
    
    # Emitir señal de fin de juego
    emit_signal("game_over", current_score)
    
    # Mostrar pantalla de game over
    # TODO: Implementar pantalla de game over

func _on_game_over_screen_restart():
    # Reiniciar todo el juego
    current_score = 0
    current_round = 1
    difficulty_multiplier = 1.0
    wrong_cuts_count = 0
    
    hud.update_score(current_score)
    start_round()
