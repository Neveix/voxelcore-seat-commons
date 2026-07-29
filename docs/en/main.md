# SeatCommons - Developer Documentation

**Engine version:** VoxelCore 0.31.4+

---

## Overview

SeatCommons provides a framework for creating **mountable entities** in VoxelCore — 
anything a player can sit on, ride, or climb.

It handles:

- Physics and movement (for vehicles)
- Mounting logic (via RideableAPI)
- Player positioning and offsets
- Interaction handling (on_used, on_attacked, etc.)

The framework is built around **presets** — ready-to-use implementations for:
- Boats (water vehicles)
- Chairs (sittable furniture)
- Ladders (climbable structures)

This is a library pack. It does not add content by itself — 
it provides the building blocks for other packs to use.

---

## Setup

To use SeatCommons in your content pack:

1. Ensure [RideableAPI](https://github.com/Neveix/voxelcore-rideable-api)
   is installed and loaded.
2. **Optionally** Copy the `typings/local` folder to your project (for type annotations).


---

## API Versioning

SeatCommons uses API versioning to ensure backward compatibility.

All requires include the API version in the path.

When a new major version is released, the old version remains available.
This allows content packs to update gradually without breaking.

For more details, see the [API Versioning](./api-versioning.md).

---

## Architecture Overview

SeatCommons separates logic into two layers:

| Layer | Location | Purpose |
| :--- | :--- | :--- |
| **Modules** | `modules/` | Core logic implementations. |
| **components** | `scripts/components/` | Thin wrappers that call module functions. |

---

## Table of Contents

1. [Creating a Standard Boat with Custom Parameters](./boats/01-creating-a-boat.md)
2. [Custom Boat Script](./boats/02-custom-boat-component.md)
3. [Overriding Functions Globally](./boats/03-overriding-globally.md)

