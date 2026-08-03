# InteractiveCommons - Developer Documentation

**Engine version:** VoxelCore 0.31.4+

---

## Overview

InteractiveCommons provides a framework for creating **interactive entities and blocks** in VoxelCore — 
anything a player can sit on, ride, or climb.

It handles:

- Physics and movement (for vehicles)
- Mounting logic (via RideableAPI)
- Player positioning and offsets
- Interaction handling (on_used, on_attacked, etc.)

The framework is built around **presets** — ready-to-use implementations for:
- Boats
- Furniture
- Ladders

---

## Setup

To use InteractiveCommons in your content pack:

- Ensure [RideableAPI](https://github.com/Neveix/voxelcore-rideable-api) is installed and loaded.


---

## API Versioning

InteractiveCommons uses API versioning to ensure backward compatibility.

All requires include the API version in the path.

When a new major version is released, the old version remains available.
This allows content packs to update gradually without breaking.

For more details, see the [API Versioning](./api-versioning.md).

---

## Table of Contents

### 1. Boats
- [1.1. Creating a Standard Boat with Custom Parameters](./boats/01-creating-a-boat.md)
- [1.2. Custom Boat Component](./boats/02-custom-component.md)
- [1.3. Overriding Functions Globally](./boats/03-overriding-globally.md)

### 2. Furniture
- [2.1. Creating a Chair](./furniture/01-creating-a-chair.md)
- [2.2. Custom Seat Component](./furniture/02-custom-component.md)
- [2.3. Overriding Functions Globally](./furniture/03-overriding-globally.md)

### 3. Ladders
- [3.1. Creating a Ladder](./ladders/01-creating-a-ladder.md)
- [3.2. Custom Ladder Component](./ladders/02-custom-component.md)
- [3.3. Overriding Functions Globally](./ladders/03-overriding-globally.md)

### Common Guides
- [Creating an Entity (Override Mechanism)](./common/creating-an-entity.md)
- [Custom Component Guide](./common/custom-component.md)
- [Global Override Guide](./common/overriding-globally.md)
