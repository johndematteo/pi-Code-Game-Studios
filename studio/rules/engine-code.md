---
paths:
  - "src/core/**"
  - "Assets/**/{Core,core}/**/*.cs"
  - "Source/**/{Core,core}/**/*.{h,cpp}"
---

# Engine Code Rules

- ZERO allocations in hot paths (update loops, rendering, physics) — pre-allocate, pool, reuse
- All engine APIs must be thread-safe OR explicitly documented as single-thread-only
- Profile before AND after every optimization — document the measured numbers
- Engine code must NEVER depend on gameplay code (strict dependency direction: engine <- gameplay)
- Every public API must have usage examples in its doc comment
- Changes to public interfaces require a deprecation period and migration guide
- Use RAII / deterministic cleanup for all resources
- All engine systems must support graceful degradation
- Before writing engine API code, consult `docs/engine-reference/` for the current engine version and verify APIs against the reference docs

## Examples

**Correct** (zero-alloc hot path) — Godot:

```gdscript
# Pre-allocated array reused each frame
var _nearby_cache: Array[Node3D] = []

func _physics_process(delta: float) -> void:
    _nearby_cache.clear()  # Reuse, don't reallocate
    _spatial_grid.query_radius(position, radius, _nearby_cache)
```

Unity:

```csharp
private readonly Collider[] _nearbyCache = new Collider[64];  // allocated once

void FixedUpdate()
{
    int count = Physics.OverlapSphereNonAlloc(transform.position, radius, _nearbyCache);
}
```

Unreal:

```cpp
// TArray member, reserved once; Reset() keeps the allocation
void UProximityComponent::TickComponent(float DeltaTime, ELevelTick TickType,
                                        FActorComponentTickFunction* ThisTickFunction)
{
    NearbyCache.Reset();
    SpatialGrid->QueryRadius(GetComponentLocation(), Radius, NearbyCache);
}
```

Bevy:

```rust
// A Local keeps the scratch buffer across runs; clear() keeps its capacity
fn proximity(
    mut nearby: Local<Vec<Entity>>,
    grid: Res<SpatialGrid>,
    player: Single<&Transform, With<Player>>,
) {
    nearby.clear();
    grid.query_radius(player.translation, RADIUS, &mut nearby);
}
```

**Incorrect** (allocating in hot path):

```gdscript
func _physics_process(delta: float) -> void:
    var nearby: Array[Node3D] = []  # VIOLATION: allocates every frame
    nearby = get_tree().get_nodes_in_group("enemies")  # VIOLATION: tree query every frame
```

Bevy:

```rust
// VIOLATION: a fresh Vec every run, and a query over every entity to filter
fn proximity(
    enemies: Query<(&Transform, &Enemy)>,
    player: Single<&Transform, With<Player>>,
) {
    let nearby: Vec<Entity> = enemies
        .iter()
        .filter(|(t, _)| t.translation.distance(player.translation) < RADIUS)
        .map(|_| Entity::PLACEHOLDER)
        .collect();
}
```
