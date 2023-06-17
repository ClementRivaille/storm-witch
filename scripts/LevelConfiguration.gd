extends Resource
class_name LevelConfiguration

enum LightingLevel {
  dimmed,
  dark,
  light
}

@export var background: NodePath
@export var sky: NodePath
@export var lighting: LightingLevel
@export var rain: bool = true
