```markdown
# Sushi Cutting Game

## Overview

This is a 2D sushi cutting game for smartphones, developed using Godot Engine 4 and GDScript. Players will need to slice different types of fish according to on-screen prompts to prepare sushi and earn points.

## Technology

* **Engine:** Godot Engine 4
* **Language:** GDScript

## Scripts Overview

This document outlines the core scripts developed so far:

### `cut_shape_detector.gd`

This script is responsible for analyzing the player's swipe gesture and determining the shape they drew. It's a fundamental component of the game's core mechanic.

* **Class Name:** `CutShapeDetector`
* **Extends:** `Node`
* **Enum `ShapeType`:** Defines the different shapes the detector can recognize:
    * `LINE`
    * `TRIANGLE`
    * `ZIGZAG`
    * `CIRCLE`
    * `WAVE`
    * `S_CURVE`
* **Constants:**
    * `PRECISION_THRESHOLD`: A tolerance value used to determine how closely the player's drawing needs to match the target shape.
    * `MAX_POINTS_TO_ANALYZE`: Limits the number of points analyzed from the swipe gesture to optimize performance.
* **Methods:**
    * `analyze_cut_shape(points: PackedVector2Array) -> ShapeType`: The main function that takes an array of points representing the player's swipe and returns the detected `ShapeType`.
    * `_simplify_points(points: PackedVector2Array) -> PackedVector2Array`: Reduces the number of points in the input array for more efficient analysis.
    * `_is_line(points: PackedVector2Array) -> bool`: Checks if the drawn shape is a line.
    * `_is_triangle(points: PackedVector2Array) -> bool`: Checks if the drawn shape is a triangle.
    * `_is_zigzag(points: PackedVector2Array) -> bool`: Checks if the drawn shape is a zigzag.
    * `_is_s_curve(points: PackedVector2Array) -> bool`: Checks if the drawn shape is an S-curve.
    * `_calculate_direction_changes(points: PackedVector2Array) -> Array`: Calculates the changes in direction of the drawn path, used in shape detection.
    * `_calculate_path_length(points: PackedVector2Array) -> float`: Calculates the total length of the drawn path.

### `touch_input_handler.gd`

This script handles the player's touch input on the screen, recording the swipe gesture as a series of points.

* **Class Name:** `TouchInputHandler`
* **Extends:** `Node2D`
* **Signal `cut_performed(points)`:** Emitted when the player lifts their finger after drawing, sending the recorded path points.
* **Variables:**
    * `is_drawing`: A boolean indicating whether the player is currently drawing.
    * `current_points`: A `PackedVector2Array` storing the points of the current swipe.
    * `line`: A `Line2D` node used to visually display the player's drawing in real-time (for debugging or visual feedback).
* **Methods:**
    * `_ready()`: Initializes the `Line2D` node.
    * `_input(event)`: Overrides the built-in input handling function to process touch and mouse events.
    * `_handle_touch_event(event)`: Handles `InputEventScreenTouch` and `InputEventMouseButton` to start and end drawing.
    * `_handle_drag_event(event)`: Handles `InputEventScreenDrag` and `InputEventMouseMotion` to record points while drawing.
    * `clear_drawing()`: Resets the drawing state, clearing the recorded points and the visual line.

### `fish.gd`

This script defines the behavior of individual fish in the game, including their type, the required cutting shape, and how they react to player cuts.

* **Class Name:** `Fish`
* **Extends:** `Area2D`
* **Enum `FishType`:** Defines the different types of fish that can appear in the game:
    * `SARDINE`
    * `TUNA`
    * `SALMON`
    * `SPECIAL_FISH`
* **Signals:**
    * `perfect_cut(combo_multiplier)`: Emitted when the player makes a perfect cut on the fish. Sends the current combo multiplier.
    * `wrong_cut()`: Emitted when the player makes an incorrect cut.
* **Exported Variables:**
    * `fish_type`: The specific type of this fish (from the `FishType` enum).
    * `required_shape`: The `ShapeType` that the player needs to draw to perfectly cut this fish.
    * `points_value`: The number of points awarded for successfully cutting this fish.
    * `special_fish_cut_time`: The time limit for cutting the special fish.
* **Variables:**
    * `is_special_fish`: A boolean indicating if this fish is the special bonus fish.
    * `special_fish_cuts`: A counter for the number of times the special fish has been cut.
    * `cut_detector`: An instance of the `CutShapeDetector` class used to analyze the player's cuts on this fish.
* **Methods:**
    * `_ready()`: Initializes the `CutShapeDetector` instance.
    * `on_cut(cut_points: PackedVector2Array)`: Called when a cut is performed on this fish. It analyzes the cut and determines if it was perfect.
    * `verify_cut_shape(detected_shape: CutShapeDetector.ShapeType) -> bool`: Compares the detected shape with the `required_shape` of this fish.
    * `perform_perfect_cut()`: Handles the actions that occur when a perfect cut is made (generating effects, emitting signal).
    * `perform_wrong_cut()`: Handles the actions that occur when an incorrect cut is made (generating effects, emitting signal).
    * `generate_cut_effects(is_perfect: bool)`: Placeholder for implementing visual and sound effects for cuts.
    * `get_combo_multiplier() -> float`: Returns the current combo multiplier based on the number of special fish cuts (will be expanded).
    * `_process(delta)`: Handles the behavior of the special fish, such as its time limit.

## Main Features

* **Graphics:** Detailed pixel art with a vibrant and llamative palette.
* **Resolution:** 1080x1920, optimized for mobiles in landscape orientation.
* **Physics and Movement:** The fish enter from the left and are placed in the center on a cutting board.
* **Cutting System:**
    * A shape appears, and the player must recreate it with their finger for a perfect cut and combo.
    * Frenzy mode activates after 5 perfect cuts, generating more coins.
    * Sliding the finger cuts the fish.
    * Perfect cuts have visual feedback (sparkles).
    * Incorrect cuts reduce the score.
* **Effects:** Knife effect, perfect cut sparkles, frenzy mode glowing cuts.
* **Bonus at the End of the Round:** A larger "Special Fish" appears for repeated cuts within a time limit for extra points.
* **Gameplay:** Fast-paced and addictive for short sessions. Difficulty increases over time. Rounds of 10-15 fish with a special fish bonus. Potential for power-ups, new fish types, and challenges.

## Project Structure

~~~
sushi_cutting_game/
├── project.godot
├── scenes/
│   ├── main.tscn
│   ├── game_scene.tscn
│   ├── fish.tscn
│   └── ui/
│       ├── main_menu.tscn
│       ├── hud.tscn
│       └── pause_menu.tscn
├── scripts/
│   ├── game_scene.gd
│   ├── fish.gd
│   ├── fish_spawner.gd
│   ├── touch_input_handler.gd
│   ├── cut_shape_detector.gd
│   └── ui/
│       ├── main_menu.gd
│       ├── hud.gd
│       └── pause_menu.gd
│   └── managers/
│       ├── game_manager.gd
│       ├── sound_manager.gd
│       ├── achievements_manager.gd
│       └── powerup_manager.gd
├── assets/
│   ├── sprites/
│   │   ├── peces/
│   │   ├── ui/
│   │   ├── background/
│   │   └── shapes/
│   ├── sounds/
│   └── fonts/
├── effects/
│   ├── corte_perfecto.tscn
│   ├── efecto_cuchillo.tscn
│   └── destello.tscn
└── export_presets.cfg
~~~

## Main Interaction Flow

1.  **Fish Spawn:** A fish appears on the screen.
2.  **Show Required Cut Shape:** The required cutting shape is displayed to the player.
3.  **Player Performs Cut:** The player swipes their finger on the screen.
4.  **`touch_input_handler` Captures Cut:** The touch input is recorded as a series of points.
5.  **`cut_shape_detector` Analyzes Shape:** The recorded points are analyzed to determine the drawn shape.
6.  **`fish` Verifies Cut:** The detected shape is compared to the required shape for the current fish.
7.  **`game_scene` Updates Score/Combo:** The score and combo are updated based on the cut result.
8.  **Visual and Sound Effects:** Visual and sound effects are triggered to provide feedback.
9.  **Possible Frenzy Mode Activation:** The frenzy mode may be activated based on the combo.

## Next Steps

* Implement `game_scene.gd` to manage the main game logic.
* Create the fish spawning system (`fish_spawner.gd`).
* Develop the user interface (`hud.tscn` and `hud.gd`).
* Add visual and sound effects.
* Implement the remaining manager scripts.
* Integrate the shape detection with the fish cutting logic.
* Refine the shape detection accuracy.
* Add visual and sound feedback for the player.
* Optimize performance for mobile devices.
* Test the game on different devices.
```
