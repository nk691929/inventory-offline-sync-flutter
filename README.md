# Inventory Offline Sync — Flutter

A collaborative inventory management app built to simulate real multi-user, unreliable-network conditions: three roles operate on shared stock data, edits made offline queue locally and replay automatically on reconnect, and concurrent conflicting edits are resolved with a documented policy rather than silently corrupting data.

Built as a from-scratch architectural rebuild — see [AI Assistance](#ai-assistance) below for an honest account of what was and wasn't AI-assisted.

![CI](https://github.com/nk691929/inventory-offline-sync-flutter/actions/workflows/ci.yml/badge.svg)

## Features

- **Mock authentication** with three seeded roles (Admin, Manager, Viewer)
- **RBAC enforced at two layers** — hidden in the UI *and* independently blocked at the use-case layer, so permissions hold even if a UI control is bypassed
- **Optimistic stock updates** — UI updates instantly on edit, with automatic rollback if the sync ultimately fails
- **Offline queue** — edits made without connectivity persist locally (Hive) and automatically replay when the connection returns
- **Bounded retries** — failed syncs retry up to 3 times before being marked permanently failed, rather than retrying forever
- **Last-Writer-Wins conflict resolution** — documented policy below, including its known trade-offs
- **Per-product audit log** — full mutation history, including changes that were later rolled back
- **Automated tests** — unit tests (rollback logic, RBAC enforcement, LWW conflict detection) and widget tests (role-based UI rendering)
- **CI** — GitHub Actions runs `flutter analyze` and `flutter test` on every push and PR

## Architecture

Clean Architecture, feature-first structure, domain layer with zero Flutter/Hive dependencies:
lib/
├── core/ # connectivity, shared utilities
├── features/
│ ├── auth/
│ │ ├── domain/ # AppUser, UserRole, Permission
│ │ ├── data/ # mock credential check, SharedPreferences session
│ │ └── presentation/ # LoginScreen, AuthNotifier
│ └── inventory/
│ ├── domain/
│ │ ├── entities/ # Product, StockMutation, SyncOperation (sealed)
│ │ ├── repositories/ # InventoryRepository (interface)
│ │ ├── services/ # SyncQueueManager
│ │ └── usecases/ # UpdateStockUseCase (RBAC enforcement)
│ ├── data/
│ │ ├── models/ # Hive-annotated models, separate from entities
│ │ ├── datasources/ # local (Hive), remote (mock backend)
│ │ └── repositories/ # InventoryRepositoryImpl
│ └── presentation/ # screens, Riverpod providers

**Domain layer has zero framework imports** — every entity and repository interface could compile in a plain Dart console app with no Flutter SDK. Hive annotations live on separate `Model` classes in the data layer, mapped to/from domain entities at the repository boundary, so swapping storage engines would never require touching business logic.

### Data flow
UI (Riverpod) → UseCase (RBAC check) → Repository (Model↔Entity mapping)
↓ ↓
Local Datasource Mock Backend
↓
Hive

## Conflict Resolution Policy — Last-Writer-Wins

When two edits to the same product's stock are made concurrently (e.g., one made offline, another already synced), the mock backend compares timestamps. The mutation with the **older** timestamp is rejected outright; the app rolls back its local optimistic value to what it was before the rejected edit.

**This is a deliberate, documented trade-off, not an oversight:** LWW *discards* the losing write rather than merging it. For a stock-count field specifically, this is an acceptable trade-off — physical inventory counts are typically reconciled against real-world stock takes anyway, so software LWW isn't the final source of truth. A CRDT or merge-on-max approach would preserve both concurrent deltas, at the cost of significantly more implementation complexity for a benefit that doesn't clearly apply to this domain.

**Known limitation:** this implementation proves conflict *rejection* — an older write is correctly blocked and rolled back. It does **not** implement propagating the *winning* value back down to the device that lost the conflict; that would require a real-time fetch/subscribe mechanism against a real backend, which is out of scope for a mock-backend demo.

## Tech Stack

- Flutter, Dart 3 (sealed classes, pattern matching)
- Riverpod (`Provider`, `StreamProvider`, `StreamProvider.family`, `AsyncNotifier`)
- Hive (local persistence — products, mutation history, sync queue)
- `connectivity_plus` (network state detection)
- `shared_preferences` (session persistence)
- Mock backend service (simulated REST + LWW conflict detection, in-memory)

## Running Locally

```bash
git clone https://github.com/nk691929/inventory-offline-sync-flutter.git
cd inventory-offline-sync-flutter
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Test Accounts

| Email | Password | Role | Can |
|---|---|---|---|
| admin@example.com | admin123 | Admin | Everything |
| manager@example.com | manager123 | Manager | View, create, edit stock |
| viewer@example.com | viewer123 | Viewer | View only |

## Testing

```bash
flutter test
```

Covers: optimistic update rollback, LWW conflict rejection (isolated from the mock backend's random-failure simulation to keep it deterministic), RBAC enforcement at the use-case layer (verified independent of any UI), and role-based UI rendering.

## Known Limitations

- Mock backend only — no real server; conflict detection is timestamp-based and in-memory, reset on app restart
- No propagation of a conflict's winning value back to the losing device (see Conflict Resolution above)
- `connectivity_plus` reports network *interface* state, not actual internet reachability — the app's real resilience comes from retry/rollback logic handling failed sync attempts regardless of what connectivity reported beforehand

## AI Assistance

This project was rebuilt from scratch after an earlier version, built with heavy unreviewed AI assistance, turned out to contain architecture the author couldn't independently explain or defend. This version was built through a structured, concept-first process: every design decision (entity modeling, the sealed-class sync queue, Model/Entity separation, the discriminator pattern for persisting a polymorphic hierarchy through Hive, RBAC placement, LWW trade-offs) was reasoned through and explained before implementation, with AI used as a reviewer and Socratic guide rather than a code generator. Real bugs were found and fixed through this process, including a missing `enqueueOperation()` call causing a silent no-op, a field-name bug in a mutation history filter, a stream that never emitted its initial state, and a concurrency race condition from duplicate `connectivity_plus` events — each diagnosed through actual debugging, not supplied pre-solved.
