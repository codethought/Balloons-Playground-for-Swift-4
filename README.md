# Balloons‑Playground‑for‑Swift 6

The classic **Balloons** demo—first published on Apple’s [Swift Blog](https://developer.apple.com/swift/blog/?id=9)—has been modernised for **Swift 6** and the latest Xcode releases.

> **Why this update?**\
> Swift 6 introduces stricter data‑race checking and a first‑class actor model.\
> Migrating the playground demonstrates how a real‑world UIKit sample can adopt the new concurrency features with minimal friction.

---

## Requirements

| Tool  | Minimum Version    |
| ----- | ------------------ |
| macOS | 14 (Sonoma)        |
| Xcode | 17 (beta or later) |
| Swift | 6.0 toolchain      |

> ❗️ **Tip:** Xcode 17 ships with Swift 6 by default. Earlier Xcode releases can load a Swift 6 *snapshot* toolchain from [swift.org](https://swift.org/download/).

---

## What’s new in the Swift 6 edition

- **Full Swift 6 syntax**—`if let` shorthand, availability macros, and package‑compiled resources.
- **Swift Concurrency integration**—UI‑affecting types are annotated with `@MainActor`.\
  This guarantees all UIKit operations execute on the main executor and removes the need for ad‑hoc `DispatchQueue.main.async` calls.
- **Async/await refactor**—Texture pre‑loading, random balloon spawn timers, and fade‑out sequences now leverage `async let`, `Task.sleep`, and structured concurrency.
- **Modern randomisation**—Replaced the custom RNG helper with `CGFloat.random(in:)`.
- **Improved documentation**—Playground markup has been rewritten in CommonMark for Xcode’s live preview and external readers (GitHub, VS Code, etc.).

---

## Quick start

1. Clone or download the repository.
2. Open `` in Xcode 17+.
3. Choose **Editor ▸ Live Preview** (or **Assistant** pane) to watch the balloons rise.
4. If concurrency warnings appear, confirm the playground uses the *Swift 6* toolchain via **File ▸ Playground Settings ▸ Swift Version**.

---

## Concurrency & `MainActor` design notes

The root view and coordinating controllers are isolated to the main executor:

```swift
@MainActor
final class BalloonsView: UIView {
    // … drawing & animation code …
}
```

- Child types inherit main‑actor isolation automatically—no extra attributes required.
- Pure calculation helpers are marked `nonisolated` or defined in separate structs to avoid unnecessary hops onto the main actor.
- Background work (e.g. image decoding) runs with `Task.detached(priority: .userInitiated)` and publishes results back to the UI via main‑isolated async contexts.

This pattern keeps UI logic safe while allowing heavy work to proceed concurrently.

---

## Migrating from the Swift 4 playground

| File              | Key change                                                                                  |
| ----------------- | ------------------------------------------------------------------------------------------- |
| `Balloon.swift`   | Converted to a value‑semantics **struct**; colour is now sampled with the standard RNG API. |
| `GameScene.swift` | Now `@MainActor`; textures load with `async let` and `await`.                               |
| `Helpers.swift`   | Obsolete GCD helpers removed—replaced by Swift Concurrency primitives.                      |
| Docs              | All doc comments upgraded to Markdown/CommonMark.                                           |

---

## License

MIT – see `LICENSE.md`.

---

*Last updated: 28 June 2025*

