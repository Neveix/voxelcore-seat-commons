# VehicleAPI - Developer Documentation

**Engine version:** VoxelCore 0.31.x

---

## Overview

VehicleAPI provides a framework for creating water vehicles in VoxelCore.
It handles physics, movement, and mounting logic, while allowing
developers to customize or replace core components.

---

## Setup

To use VehicleAPI in your content pack:

1. Ensure [RideableAPI](https://github.com/Neveix/voxelcore-rideable-api)
   is installed and loaded.
2. [optional] Copy the `typings/local` folder to your project (for type annotations).

---

## Architecture Overview

VehicleAPI separates logic into two layers:

| Layer | Location | Purpose |
| :--- | :--- | :--- |
| **Modules** | `modules/` | Core logic implementations. |
| **Components** | `scripts/components/` | Thin wrappers that call module functions. |

### Why modules?

Components are tied to entities and are reloaded with the world.
Modules are loaded once and persist across world reloads.
This allows developers to override default behavior globally
by replacing a module, without modifying every entity.

For example, the default boat physics logic is in:
```
modules/boat.lua
```

The component `boat.lua` simply calls functions from this module.

---

## Table of Contents

1. [Creating a Standard Boat with Custom Parameters](./01-creating-a-vehicle.md)
2. [Custom Boat Script](./02-custom-vehicle-component.md)
3. [Overriding Functions Globally](./03-overriding-globally.md)

---

## See Also

<!-- - [Tutorial: Creating a Rideable Vehicle](./tutorial.md) -->
