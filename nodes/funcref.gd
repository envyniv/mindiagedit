tool class_name DialogueFuncRefNode extends DialogueNode

func nodeString(): return "funcref"
const port_type: int = 1

const port_color = Color(.5, .2, .5)

func setup() -> void:
  port_color
  props["object"] = String()
  props["function"] = String()
  nextSetup(true)
  return

# if connected as cond don't allow next
