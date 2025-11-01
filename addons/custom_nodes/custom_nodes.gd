@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("PxLayer", "Node2D", preload("res://components/parallax/layer/parallax layer.gd"), preload('res://addons/custom_nodes/icon.svg'))
	add_custom_type("ControlledPx2D", "Parallax2D", preload("res://components/parallax/controlledPx/controlled parallax.gd"), preload("res://addons/custom_nodes/icon_controlledpx.svg"))
	add_custom_type("PX BG", "ControlledPx2D", preload("res://components/parallax/controlledPx/bg.gd"), preload("res://addons/custom_nodes/icon_cpx_bg.svg"))
	add_custom_type("PX FG", "ControlledPx2D", preload("res://components/parallax/controlledPx/fg.gd"), preload("res://addons/custom_nodes/icon_controlledpx.svg"))
	add_custom_type("PX Center", "ControlledPx2D", preload("res://components/parallax/controlledPx/center.gd"), preload("res://addons/custom_nodes/icon_cpx_center.svg"))

func _exit_tree():
	remove_custom_type("PxLayer")
	remove_custom_type("ControlledPx2D")
	remove_custom_type("ControlledPx2D_BG")
	remove_custom_type("ControlledPx2D_FG")
	remove_custom_type("ControlledPx2D_Center")
