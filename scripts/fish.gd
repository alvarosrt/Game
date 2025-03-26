class_name Fish
extends Area2D

enum FishType {
    SARDINE,
    TUNA,
    SALMON,
    SPECIAL_FISH
}

signal perfect_cut(combo_multiplier)
signal wrong_cut()

@export var fish_type: FishType = FishType.SARDINE
@export var required_shape: CutShapeDetector.ShapeType = CutShapeDetector.ShapeType.LINE
@export var points_value: int = 10
@export var special_fish_cut_time: float = 10.0

var is_special_fish = false
var special_fish_cuts = 0
var cut_detector: CutShapeDetector

func _ready():
    cut_detector = CutShapeDetector.new()
    add_child(cut_detector)

func on_cut(cut_points: PackedVector2Array):
    var detected_shape = cut_detector.analyze_cut_shape(cut_points)
    
    if verify_cut_shape(detected_shape):
        perform_perfect_cut()
    else:
        perform_wrong_cut()

func verify_cut_shape(detected_shape: CutShapeDetector.ShapeType) -> bool:
    return detected_shape == required_shape

func perform_perfect_cut():
    generate_cut_effects(true)
    emit_signal("perfect_cut", get_combo_multiplier())
    
    if is_special_fish:
        special_fish_cuts += 1
        queue_redraw()  # Actualizar visual de cortes especiales

func perform_wrong_cut():
    generate_cut_effects(false)
    emit_signal("wrong_cut")

func generate_cut_effects(is_perfect: bool):
    # TODO: Implementar efectos visuales y sonoros
    pass

func get_combo_multiplier() -> float:
    # Lógica de multiplicador de combo
    return 1.0 + (special_fish_cuts * 0.1)

func _process(delta):
    if is_special_fish:
        special_fish_cut_time -= delta
        if special_fish_cut_time <= 0:
            queue_free()  # Desaparecer si se acaba el tiempo
