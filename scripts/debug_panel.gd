extends Control


func _ready() -> void:
	var title = get_node("Background/VBoxContainer/Title")
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color.YELLOW)
	
	var debug_text = get_node("Background/VBoxContainer/DebugText")
	debug_text.add_theme_font_size_override("font_size", 11)
	debug_text.add_theme_color_override("font_color", Color.WHITE)
