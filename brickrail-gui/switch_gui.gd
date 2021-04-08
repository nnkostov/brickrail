extends Panel

var switch_name
var project
export(NodePath) var switch_label

signal train_action(train, action)

func setup(p_project, p_switch_name):
	project = p_project
	set_switch_name(p_switch_name)
	get_switch().connect("name_changed", self, "_on_switch_name_changed")
	$SwitchSettingsDialog.setup(p_project, p_switch_name)
	$SwitchSettingsDialog.show()

func _on_switch_name_changed(p_old_name, p_new_name):
	set_switch_name(p_new_name)

func set_switch_name(p_switch_name):
	switch_name = p_switch_name
	get_node(switch_label).text = switch_name

func get_switch():
	return project.switches[switch_name]

func _on_settings_button_pressed():
	$SwitchSettingsDialog.show()

func _on_switch_right_button_pressed():
	get_switch().switch("right")

func _on_switch_left_button_pressed():
	get_switch().switch("left")