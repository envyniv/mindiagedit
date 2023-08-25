tool
class_name DialogueConditionalNode extends DialogueNode

const port_type: int = 2

const TrueColor: Color = Color(0, 1, 0)
const FalseColor: Color = Color(1, 0, 0)
func nodeString(): return "cond"

#func getEditorIcon(s: String) -> Texture:
#  return EditorPlugin.new().get_editor_interface().get_base_control().get_icon(s, "EditorIcons")

# Called when the node enters the scene tree for the first time.
func setup() -> void:
  nextSetup(false)
  var f = Label.new()
  add_child(f)
  f.align = Label.ALIGN_RIGHT
  f.text = "Condition"
  set_slot_enabled_right(f.get_index(), true)
  
  var o = Label.new()
  add_child(o)
  o.text = "Outcome"
  o.align = Label.ALIGN_CENTER
  set_slot(
    o.get_index(),
    true, 0, FalseColor,
    true, 0, TrueColor
  )
  return
