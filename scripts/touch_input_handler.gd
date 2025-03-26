class_name TouchInputHandler
extends Node2D

signal cut_performed(points)

var is_drawing = false
var current_points = PackedVector2Array()
var line: Line2D

func _ready():
    line = Line2D.new()
    line.width = 5
    line.default_color = Color(1, 0, 0, 0.5)  # Línea roja semi-transparente
    add_child(line)

func _input(event):
    if event is InputEventScreenTouch or event is InputEventMouseButton:
        _handle_touch_event(event)
    
    if event is InputEventScreenDrag or event is InputEventMouseMotion:
        _handle_drag_event(event)

func _handle_touch_event(event):
    if event.pressed:
        # Iniciar dibujo
        is_drawing = true
        current_points.clear()
        line.clear_points()
    else:
        # Finalizar dibujo
        if is_drawing and current_points.size() > 2:
            emit_signal("cut_performed", current_points)
        
        is_drawing = false
        line.clear_points()
        current_points.clear()

func _handle_drag_event(event):
    if is_drawing:
        var pos = event.position
        current_points.append(pos)
        line.add_point(pos)

func clear_drawing():
    is_drawing = false
    current_points.clear()
    line.clear_points()
