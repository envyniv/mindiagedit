tool extends Control

onready var filemenu = $VBoxContainer/HBoxContainer/filemenu
onready var filemenupopup = filemenu.get_popup()
onready var nodemenu = $VBoxContainer/HBoxContainer/nodemenu
onready var nodemenupopup = nodemenu.get_popup()

onready var graph = $VBoxContainer/GraphEdit
onready var filesel = $FileDialog
onready var newprop = $PopupDialog
onready var newpropname = $PopupDialog/LineEdit

onready var verlabel = $VBoxContainer/HBoxContainer/Label

#var selected_nodes = {}

var plugin_conf = ConfigFile.new()

var open_file: ConfigFile = null
# GraphEdit
# Called when the node enters the scene tree for the first time.
func _ready():
  plugin_conf.load("res://addons/lhdiagedit/plugin.cfg")
  verlabel.text = plugin_conf.get_value("plugin", "version")
  graph.connect("connection_request", self, "_on_Graph_connection_request")
  graph.connect("disconnection_request", self, "_on_Graph_disconnection_request")
  #graph.connect("node_selected", self, "_on_Graph_node_selected")
  #graph.connect("node_deselected", self, "_on_Graph_node_deselected")
  graph.connect("delete_nodes_request", self, "_on_Graph_delete_nodes_request")
  nodemenu.hide()
#  if recent_files:
#    for file in recent_files:
#      filemenupopup.add_item(file)
#    filemenupopup.add_separator()
  # Popup
  filemenupopup.clear()
  filemenupopup.add_icon_item(getEditorIcon("Open"), "Open", 200)
  filemenupopup.add_icon_item(getEditorIcon("New"), "New", 201)
  filemenupopup.connect("id_pressed", self, "onPressed")
  
  nodemenupopup.clear()
  nodemenupopup.add_icon_item(getEditorIcon("Add"), "Node")
  nodemenupopup.add_icon_item(getEditorIcon("VisualShaderNodeScalarFunc"), "FuncRef")
  nodemenupopup.add_icon_item(getEditorIcon("CurveCreate"), "Conditional")
  nodemenupopup.add_icon_item(getEditorIcon("AddSplit"), "Choice")
  nodemenupopup.connect("id_pressed", self, "newNode")
  
  pass # Replace with function body.

func parse(cf: ConfigFile) -> void:
  for section in open_file.get_sections():
    var node = null
    if "node" in section:
      node = DialogueNode.new()
    elif "cond" in section:
      node = DialogueConditionalNode.new()
    elif "funcref" in section:
      node = DialogueFuncRefNode.new()
    elif "choice" in section:
      node = DialogueChoiceNode.new()
    graph.add_node(node)
    for entry in open_file.get_section_keys(section):
      node.set_value(entry, open_file.get_value(section, entry))
  return

func open(path: String) -> void:
  #print(path)
  #ProjectSettings.set("DialogueEditor/config/recent", recent_files.append(path))
  if graph.get_child_count(): for child in graph.get_children(): child.queue_free()
  open_file = ConfigFile.new()
  open_file.load(path)
  parse(open_file)
  nodemenu.show()
  return

func getEditorIcon(s: String) -> Texture:
  return EditorPlugin.new().get_editor_interface().get_base_control().get_icon(s, "EditorIcons")

func bringUpFileMenu(m: String) -> void:
  filesel.set_filters(PoolStringArray(["*.diag ; Dialogue Files"]))
  filesel.connect("file_selected", self, "open")
  match m:
    "open":
      filesel.mode = FileDialog.MODE_OPEN_FILE
    "new":
      filesel.mode = FileDialog.MODE_SAVE_FILE
      filesel.window_title = "New"
  filesel.popup()
  return

func onPressed(id: int) -> void:
  match id:
    200:
      bringUpFileMenu("open")
    201:
      bringUpFileMenu("new")
    _:
      pass
#      open(recent_files[id])
  return

func newNode(id: int) -> void:
  var node
  #node = GraphNode.new()
  match id:
    0: # node
      node = DialogueNode.new()
    1: # funcref
      node = DialogueFuncRefNode.new()
    2: # cond
      node = DialogueConditionalNode.new()
    3: # choice
      node = DialogueChoiceNode.new()
  graph.add_child(node)
  node.connect("request_property_name", self, "getPropertyName", [node])
  node.connect("focus_exited", self, "saveNode", [node.props, node])
  if graph.get_child_count(): node.show_close = true
  node.connect("close_request", self, "_on_Graph_delete_nodes_request", [[node]])
  return

func saveNode(d: Dictionary, name: String) -> void:
  for key in d:
    open_file.set_value(name, key, d[key])
  return

func getPropertyName(id: int, node: GraphNode) -> void:
  node.disconnect("request_property_name", self, "getPropertyName")
  newprop.get_ok().connect("pressed", self, "on_prop_name_ok", [newprop])
  newprop.get_cancel().connect("pressed", self, "on_prop_name_canc", [newprop])
  newprop.popup()
  return

func remove_connections_to_node(node):
  for con in graph.get_connection_list():
    if con.to == node.name or con.from == node.name:
      graph.disconnect_node(con.from, con.from_port, con.to, con.to_port)

func _on_Graph_connection_request(from, from_port, to, to_port):
  # Don't connect to input that is already connected
  for con in graph.get_connection_list():
    if con.to == to and con.to_port == to_port:
      return
  graph.connect_node(from, from_port, to, to_port)

func _on_Graph_disconnection_request(from, from_port, to, to_port):
  graph.disconnect_node(from, from_port, to, to_port)

func _on_Graph_delete_nodes_request(nodes: Array):
  for node in nodes:
    remove_connections_to_node(node)
    node.queue_free()
