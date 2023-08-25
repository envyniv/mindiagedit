tool
extends EditorPlugin

const path: String = "res://addons/lhdiagedit"

const MainPanel = preload("res://addons/lhdiagedit/view.tscn")
var main_panel_instance

var defaultSettings: Dictionary = {
  get_plugin_name()+"/config/recent": PoolStringArray([]),
  get_plugin_name()+"/config/custom/node": Dictionary(),
  get_plugin_name()+"/config/custom/conditional": Dictionary(),
  get_plugin_name()+"/config/custom/funcref": Dictionary(),
  get_plugin_name()+"/config/custom/choice": Dictionary(),
}

func _enter_tree():
  #plugin_conf.load(path+"/plugin.cfg")
  #get_editor_interface().get_file_system_dock().queue_free()
  main_panel_instance = MainPanel.instance()
  # Add the main panel to the editor's main viewport.
  get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
  # Hide the main panel. Very much required.
  make_visible(false)
  
  # setup projectsettings
  for setting in defaultSettings:
    ProjectSettings.set(setting, defaultSettings[setting])
  
  return

func _exit_tree():
  if main_panel_instance:
    main_panel_instance.queue_free()
  for setting in defaultSettings:
    ProjectSettings.clear(setting)
  #ProjectSettings.clear("DialogueEditor")
  return

func has_main_screen():
  return true

func make_visible(visible):
  if main_panel_instance:
    main_panel_instance.visible = visible

func get_plugin_name():
  return "Dialogues"

func get_plugin_icon():
  return get_editor_interface().get_base_control().get_icon("Script", "EditorIcons")
