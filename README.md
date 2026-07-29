# SeatCommons

A content pack for [VoxelCore](https://github.com/MihailRis/voxelcore)

---

## Description

SeatCommons provides a collection of ready-to-use presets for **mountable entities** in VoxelCore.

Includes presets for:

- **Boats** — water vehicles with physics and buoyancy
- **Chairs** — sittable furniture (benches, thrones, etc.)
- **Ladders** — climbable structures

All presets are built on:
- [RideableAPI](https://github.com/Neveix/rideable-api) — for mounting logic
- A pluggable component system — for easy customization or overriding

This is a library pack. It does not add any items or blocks to your game by itself.
Other content packs use these presets to add rideable or climbable content.

---

## Installation

1. Download the content pack.
2. Place the folder in your `content/` directory.
3. Ensure [RideableAPI](https://github.com/Neveix/voxelcore-rideable-api) is installed.

---

## For Players

This pack adds no visible items or mechanics on its own.
It is a library that other content packs use to add rideable, climbable, or sittable entities.

If a content pack requires SeatCommons, it will list it as a dependency.
Simply install it and other packs will handle the rest.

---

## For Developers

See the API documentation for full details:

- [🇺🇸 API Documentation](./docs/en/main.md)
- [🇷🇺 Документация API](./docs/ru/main.md)

---

## Dependencies

- [RideableAPI](https://github.com/Neveix/voxelcore-rideable-api)

---

## License

MIT
