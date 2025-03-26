class_name CutShapeDetector
extends Node

enum ShapeType {
    LINE,
    TRIANGLE, 
    ZIGZAG,
    CIRCLE, 
    WAVE,
    S_CURVE
}

const PRECISION_THRESHOLD = 0.7  # Tolerancia para detección de formas
const MAX_POINTS_TO_ANALYZE = 50  # Limitar puntos para rendimiento

func analyze_cut_shape(points: PackedVector2Array) -> ShapeType:
    if points.size() < 3:
        return ShapeType.LINE  # Corte muy corto
    
    # Reducir número de puntos para análisis eficiente
    points = _simplify_points(points)
    
    # Análisis de formas
    if _is_line(points):
        return ShapeType.LINE
    elif _is_triangle(points):
        return ShapeType.TRIANGLE
    elif _is_zigzag(points):
        return ShapeType.ZIGZAG
    elif _is_s_curve(points):
        return ShapeType.S_CURVE
    
    return ShapeType.LINE  # Forma por defecto

func _simplify_points(points: PackedVector2Array) -> PackedVector2Array:
    if points.size() > MAX_POINTS_TO_ANALYZE:
        var simplified = PackedVector2Array()
        var step = points.size() / MAX_POINTS_TO_ANALYZE
        
        for i in range(0, points.size(), step):
            simplified.append(points[i])
        
        return simplified
    return points

func _is_line(points: PackedVector2Array) -> bool:
    var start = points[0]
    var end = points[-1]
    var total_length = start.distance_to(end)
    var path_length = _calculate_path_length(points)
    
    return path_length / total_length < 1.2  # Pequeña variación permitida

func _is_triangle(points: PackedVector2Array) -> bool:
    if points.size() < 4:
        return false
    
    var angles = _calculate_direction_changes(points)
    return angles.size() >= 3 and angles.size() <= 4

func _is_zigzag(points: PackedVector2Array) -> bool:
    var angle_changes = _calculate_direction_changes(points)
    return angle_changes.size() >= 4 and angle_changes.size() <= 6

func _is_s_curve(points: PackedVector2Array) -> bool:
    # Detectar curva en S basada en cambios de dirección suaves
    var angle_changes = _calculate_direction_changes(points)
    return angle_changes.size() == 3

func _calculate_direction_changes(points: PackedVector2Array) -> Array:
    var angles = []
    for i in range(1, points.size() - 1):
        var angle = points[i-1].angle_to_point(points[i+1])
        angles.append(abs(angle))
    return angles

func _calculate_path_length(points: PackedVector2Array) -> float:
    var length = 0.0
    for i in range(1, points.size()):
        length += points[i-1].distance_to(points[i])
    return length
