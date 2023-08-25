# Minimal Dialogue Editor

MinDiagEdit is a minimal, node based dialogue editor plugin designed to be
simple in concept and implementation.

Relies on `ConfigFile` to be easily editable outside of the Godot Engine via any
text editor.

there are only 4 node types.

## Node types

### Node

**props:**
- speaker (`self` if none/missing)
- message
- next ( _optional_ )

### Conditional Branch

**props:**
- cond ([Function Reference](#func-ref-cond))
- True
- False

### Choice

**props:**
- text
- next

### Function Reference

#### Default behaviour
**props:**
- object (`self` if none/missing)
- func

This node type is used to have the dialogue processor execute a function in the context of the
provided object.

<a id=func-ref-cond>
#### When used as a condition for a branching dialogue

## Currently used in:

- [Last Hope](https://github.com/envyniv/Project-Hope)
