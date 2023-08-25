tool class_name DialogueNode extends GraphNode


func nodeString(): return "node"
var custom_props = ProjectSettings.get_setting("DialogueEditor/config/custom/"+nodeString())

var props: Dictionary = {}

const prev_clr: Color = Color(0, 0.5, 0.8)
const next_clr: Color = Color(1, 1, 1)

# Called when the node enters the scene tree for the first time.

func _ready():
  title = getName()
  setup()
  newPropertyButton()
  propertiesSetup()
  return

func setup():
  props = {
    "speaker" : String(),
    "message" : "\n",
  }
  nextSetup(true)
  return
  
func nextSetup(right: bool) -> void:
  var next = Control.new()
  add_child(next)
  set_slot(
    next.get_index(),
    true, 0, next_clr,
    right, 0, next_clr
  )
  return

func newPropertyButton() -> void:
  var button = TextureButton.new()
  add_child(button)
  button.texture_normal = getEditorIcon("Add")
  var popup = PopupMenu.new()
  button.add_child(popup)
  
  button.connect("pressed", popup, "popup", [ Rect2(button.rect_global_position, Vector2.ZERO) ])
  popup.clear()
  for i in ["Image", "int", "float", "String", "bool", "Color"]:
    popup.add_icon_item(getEditorIcon(i), i)
  
  popup.connect("id_pressed", self, "addNewProperty")
  return

signal request_property_name(integer)

func addNewProperty(value: int) -> void: emit_signal("request_property_name", value)

func on_prop_name_ok(popup: Node) -> void:
  popup.get_ok().disconnect("pressed", self, "on_prop_name_ok")
  popup.get_canc().disconnect("pressed", self, "on_prop_name_canc")
  concatProp(popup.get_node("LineEdit").text)
  return

func on_prop_name_canc(popup: Node) -> void:
  popup.get_ok().disconnect("pressed", self, "on_prop_name_ok")
  popup.get_canc().disconnect("pressed", self, "on_prop_name_canc")
  return

func concatProp(s: String) -> void:
  
  return

func getName(s: String = nodeString()) -> String:
  var gen = RandomNumberGenerator.new()
  gen.randomize()
  return s + str(gen.randi()).md5_text()
  
signal property_changed

func valueChange(value, key: String) -> void:
  props[key] = value
  return

func addButton(s: String) -> void:
  var prop = props[s]
  var node: Node
  if prop is String:
    if "\n" in prop:
      node = TextEdit.new()
      add_child(node) # Control
      node.rect_min_size = Vector2(0, 40)
    else:
      node = LineEdit.new()
      add_child(node)
    node.connect("text_changed", self, "valueChange", [node.text, s])
    
  elif prop is Image:
    node = TextureButton.new()
    add_child(node)
    
  elif prop is int:
    node = SpinBox.new()
    add_child(node)
    node.rounded = true
    node.connect("changed", self, "valueChange", [node.value, s])
    
  elif prop is float:
    node = SpinBox.new()
    add_child(node)
    node.connect("changed", self, "valueChange", [node.value, s])
    
  elif prop is bool:
    node = CheckBox.new()
    add_child(node)
    node.connect("toggled", self, "valueChange", [s])
    
  elif prop is Color:
    node = ColorPickerButton.new()
    add_child(node)
    node.connect("color_changed", self, "valueChange", [s])
  return

func propertiesSetup(node: String = "node") -> void:
  if custom_props:
    for entry in custom_props:
      props[entry] = custom_props[entry]
  for key in props:
    var label = Label.new()
    add_child(label)
    label.set_text(key.capitalize())
    addButton(key)
  return

func getEditorIcon(s: String) -> Texture:
  return EditorPlugin.new().get_editor_interface().get_base_control().get_icon(s, "EditorIcons")
