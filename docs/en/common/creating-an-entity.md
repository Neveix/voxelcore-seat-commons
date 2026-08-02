# Creating an Entity

This guide covers the general approach for creating any entity type in InteractiveCommons.

---

## Customization

To customize behavior, create a module file in your content pack:

```
modules/intcom/<entity_type>/<your_name>.lua
```

The `<your_name>` should match the name used in your entity definition.

There are two types of overrides:

1. **Parameters** — simple values like speed, position offsets, etc.
2. **Functions** — custom logic for specific events

---

### Overriding Parameters

Return a table with the parameters you want to change.

**Example:**

```lua
return {
    max_speed = 10,
    acceleration = 0.07,
}
```

All parameters are optional. If omitted, default values are used.

See the entity-specific guide for the full parameter list.

---

### Overriding Functions

To override functions, return an initializer function that accepts the default implementation.

**Example:**

```lua
local C = {}

function C.init(super)
    C.super = super
    C.super_funcs = {
        on_used = super.on_used
    }
    return C
end

function C.on_used(self, pid)
    console.chat("overridden!")
    C.super_funcs.on_used(self, pid)
end

C.params = {
    max_speed = 7,
}

return C.init
```

### How it works

- The initializer receives a `super` table containing the default implementation.
- The returned table should contain:
  - [optional] Overridden functions
  - [optional] A `params` field with parameter overrides
- To call the parent implementation, store a reference to the original function
  (e.g., in `C.super_funcs`) and use it later.

```lua
C.super_funcs = {
    on_used = super.on_used
}
```

> ⚠️ **Warning:** Do **not** call `C.super.on_used(self, pid)` directly inside the overridden function,
> as this will cause **infinite recursion**. Store the reference separately as shown above.
