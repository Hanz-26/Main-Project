# Phase 2: Godot Editor Scene Changes

These changes MUST be done inside Godot's editor (not from CLI).
Open your project in Godot first.

---

## IMPORTANT: Rename GameManager node

Your current scene has a node called "GameManager".
Hansel's scripts expect "Game Manager" (with a space).

1. Open `game.tscn` in Godot
2. Click on the "GameManager" node
3. Rename it to **Game Manager**
4. In the Inspector panel, check the box **"Access as Unique Name"** (the % icon)
5. Remove the "ScoreLabel" child (you'll replace it with the new HUD)

---

## Step 1: Add Spawn Location

1. In game.tscn, add a new **Node2D** called `Spawn_locations` as a child of the root "Game" node
2. Inside Spawn_locations, add a **Marker2D** called `Initial_spawn`
3. Position Initial_spawn where your player currently starts

---

## Step 2: Add HUD to Player Scene

Open `player.tscn`:

1. Add a **CanvasLayer** or **Control** node called `UI` as a child of Player
2. Inside UI, create this structure:

```
UI (Control)
├── Health (Control)
│   ├── Hearts (HBoxContainer)
│   │   ├── heart_full_1 (TextureRect) ← use assets/sprites/Hearts/basic/heart_full.png
│   │   ├── heart_empty_1 (TextureRect) ← use assets/sprites/Hearts/basic/heart_empty.png (visible=false)
│   │   ├── heart_full_2 (TextureRect)
│   │   ├── heart_empty_2 (TextureRect) (visible=false)
│   │   ├── heart_full_3 (TextureRect)
│   │   └── heart_empty_3 (TextureRect) (visible=false)
│   └── Lives (HBoxContainer)
│       └── Lives_count (Label) ← text: "x3", font: PixelOperator8-Bold
└── Coins (HBoxContainer)
    └── Coins_counter (Label) ← text: "x0", font: PixelOperator8-Bold
```

**Important:** Empty hearts start with `visible = false`. The code toggles visibility.

---

## Step 3: Add Sword System to Player Scene

Still in `player.tscn`:

1. Add a **Sprite2D** called `sword` as child of Player
   - Assign a sword sprite from `assets/sprites/Weapons/`
   - Position it next to the player character

2. Add an **AnimatedSprite2D** called `sword_attacks` as child of Player
   - Set `visible = false` initially
   - Create two animations: `stab` and `swing` using sword sprites
   - Inside sword_attacks, add:

```
sword_attacks (AnimatedSprite2D)
├── stab_area (Area2D)
│   └── stab_collision (CollisionShape2D) ← disabled by default
│       Script: weapon_hitzone.gd on the stab_area node
└── swing_area (Area2D)
    └── swing_collision (CollisionShape2D) ← disabled by default
        Script: weapon_hitzone.gd on the swing_area node
```

3. **Connect signal:** Select sword_attacks → Signals → `animation_finished` → connect to Player → `_on_sword_attacks_animation_finished`

---

## Step 4: Add Harm Zones to Enemies

For each Slime in your scene:

1. Open `slime.tscn`
2. Add an **Area2D** called `Harm Zone` as a child
3. Add a **CollisionShape2D** inside the Harm Zone (match the slime's body size)
4. Attach `harm_zone.gd` script to the Harm Zone Area2D
5. Connect the `body_entered` signal to `_on_body_entered`

---

## Step 5: Add Boss Camera (optional for now)

In `player.tscn`:

1. Add a second **Camera2D** called `Boss_Camera2D`
2. Set `enabled = false`
3. This camera activates during boss fights

---

## Step 6: Organize Enemy Nodes (optional)

In game.tscn, create this structure for cleaner organization:

```
Enemies (Node2D)
├── Bosses (Node2D)
│   └── (boss instances go here later)
├── Slime (existing)
├── Slime2 (existing)
...etc
```

Move your existing slime instances under the Enemies node.

---

## Step 7: Add Checkpoints (optional)

1. Instance `scenes/Items/Checkpoint_flag.tscn` in your level
2. Position it at key points (e.g., halfway through the level)
3. The checkpoint_flag.gd script handles the rest automatically

---

## Collision Layer Setup

Make sure your collision layers are configured:
- **Layer 1:** Environment (platforms, walls)
- **Layer 2:** Player
- **Layer 3:** Enemies
- **Layer 4:** Enemy harm zones (for weapon detection)

Player should scan layers 1, 3, 4
Enemies should scan layer 1
Harm zones should scan layer 2
Weapon hitzones should scan layer 4

---

## Testing Checklist

After making these changes:
- [ ] Player can move and jump (unchanged)
- [ ] Coins increment score
- [ ] Falling into killzone triggers death with lives system
- [ ] HUD shows hearts, lives, coins
- [ ] Sword attacks work (X=stab, Z=swing)
- [ ] Slime harm zones damage player
- [ ] Knockback pushes player away from enemies
- [ ] Player respawns at spawn point after death
- [ ] Game over reloads scene when lives = 0

---

## What's Safe to Skip for Now

- Boss_Camera2D (only needed for boss fights)
- Checkpoint flags (quality of life, not critical)
- Pause menu (can add later)
- Save file system (can add later)

Focus on: HUD, sword, harm zones, spawn point. Those are the core systems.
