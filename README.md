# Balloons Playground · Swift 6 Edition

The classic **Balloons** SpriteKit demo—first showcased on Apple’s [Swift Blog](https://developer.apple.com/swift/blog/?id=9) and at WWDC 2014—has been **fully modernised for Swift 6**, structured concurrency, and the latest Xcode releases.

> **Why this update?**\
> Swift 6 introduces stricter data‑race checking and a first‑class actor model.\
> Migrating the playground demonstrates how a real‑world UIKit sample can adopt the new concurrency features with minimal friction.

---

## Requirements

| Tool  | Minimum Version    |
| ----- | ------------------ |
| macOS | 14 (Sonoma)        |
| Xcode | 17 (beta or later) |
| Swift | 6.0 toolchain      |

> ❗️ **Tip:** Xcode 17 ships with Swift 6 by default. Earlier Xcode releases can load a Swift 6 *snapshot* toolchain from [swift.org](https://swift.org/download/).

---

## What’s new in the Swift 6 edition

- **Full Swift 6 syntax**—`if let` shorthand, availability macros, and package‑compiled resources.
- **Swift Concurrency integration**—UI‑affecting types are annotated with `@MainActor`.\
  This guarantees all UIKit operations execute on the main executor and removes the need for ad‑hoc `DispatchQueue.main.async` calls.
- **Async/await refactor**—Texture pre‑loading, random balloon spawn timers, and fade‑out sequences now leverage `async let`, `Task.sleep`, and structured concurrency.
- **Modern randomisation**—Replaced the custom RNG helper with `CGFloat.random(in:)`.
- **Improved documentation**—Playground markup has been rewritten in CommonMark for Xcode’s live preview and external readers (GitHub, VS Code, etc.).

---



## What’s new compared with the Swift 4 playground

| Area                  | Upgrade Highlights                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| **Concurrency**       | `@MainActor` isolates all UI‑touching code; animation timing now uses `async`/`await` instead of nested `SKAction.wait` blocks.      |
| **Randomisation**     | Swapped the C‑API `arc4random_uniform` for the Swift 6 `Int.random(in:)` and `CGFloat.random(in:)` helpers.                          |
| **Physics Contacts**  | Signature update to `didBegin(_:)`, plus an inline `print` debug hook so you can *see* each pop in Xcode’s console.                  |
| **Documentation**     | All markup upgraded to CommonMark; better call‑outs explain how to use Xcode’s results‑sidebar “pin” feature to inspect live values. |
| **Requirements bump** | macOS Sequoia 15 + Xcode 17 for native Swift 6 toolchains and improved live‑preview.                                                 |

---


## Quick Start

1. **Clone / download** this repo.
2. Open `` in **Xcode 17** (or newer).
3. Choose ***Editor ▸ Live View*** (⌥‑⌘‑Return). The SKView should appear and balloons begin to launch automatically.
4. Open the **Debug area** (⌘‑⇧‑Y) to watch the new `print("💥 Balloon popped at …")` messages every time two balloons collide.
5. Experiment! Try flipping gravity or pinning variables with the *results sidebar*:
   - Hover to the **far‑right gutter** next to a line that evaluates to a value.
   - Click the **hollow grey circle (◯)** to *pin* that value. Xcode keeps it live in the timeline so you can watch arrays, numbers, and even textures update in real time.

---

## Concurrency & `MainActor` design notes

The root view and coordinating controllers are isolated to the main executor:

```swift
@MainActor
final class PhysicsContactDelegate: NSObject, SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) { … }
}
```

- Sub‑types inherit main‑actor isolation automatically.
- Pure math helpers live in `nonisolated` functions so you don’t bounce back to the main executor unnecessarily.
- Expensive texture pre‑loading uses `Task.detached`, then hops back to the main actor to attach the results to nodes.

This keeps UI logic race‑free while still allowing heavy work to run concurrently.

---

## Migrating from the Swift 4 playground

| File              | Key change                                                                                  |
| ----------------- | ------------------------------------------------------------------------------------------- |
| `Balloon.swift`   | Converted to a value‑semantics **struct**; colour is now sampled with the standard RNG API. |
| `GameScene.swift` | Now `@MainActor`; textures load with `async let` and `await`.                               |
| `Helpers.swift`   | Obsolete GCD helpers removed—replaced by Swift Concurrency primitives.                      |
| Docs              | All doc comments upgraded to Markdown/CommonMark.                                           |

---

## Migrating your own SpriteKit playground

1. **Add** `@MainActor` to any type that talks to SpriteKit APIs.
2. Replace `SKAction.wait` chains with `try await Task.sleep(_:)` for clearer timing.
3. Swap C RNG calls for Swift’s `random(in:)` helpers for thread safety.
4. Use the Xcode pin gutter feature to inspect live textures / counts instead of custom logging.

---


## License

MIT – see `LICENSE.md`.

---

*Last updated: 28 June 2025*

