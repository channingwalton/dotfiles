---
name: kotlin-developer
description: Senior Kotlin developer using http4k and functional patterns. Use when writing Kotlin code, implementing features, or working with Gradle projects. Used as a part of the XP skill.
---

# Kotlin Development

## Principles

- Immutable data structures (`data class`, `copy()`)
- Avoid `null` where possible; use `?` types explicitly
- Prefer `Result4k` for domain errors over exceptions
- Extension functions for domain conversions
- Four-space indentation, 120-char line limit

## Build Commands

```bash
./gradlew :<module>:test           # Run module tests
./gradlew :<module>:run            # Run service locally
./gradlew test                     # Full test suite
```

