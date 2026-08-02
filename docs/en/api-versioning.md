# API Versioning

InteractiveCommons uses API versioning to ensure backward compatibility across updates.

---

## Why Versioning?

As InteractiveCommons evolves, new features are added and existing APIs may change.
Versioning allows content packs to continue using older APIs while optionally
migrating to newer versions.

---

## How It Works

All requires include the API version in the path, for example:
```lua
require("intcom:api/v1/components/boat")
```

## Compatibility Guarantee

- **v1** will remain available and functional.
- Content packs using `v1` will not break when newer versions are released.
- Bug fixes may be backported to `v1` when critical.
- New features are added to the latest version only.
