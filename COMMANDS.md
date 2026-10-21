# Shroudfire commands and settings

Generated from the SourceMod command registrations and cvar descriptions. Enter `sf_` commands in the console; type menu shortcuts in chat without a prefix. Administrator access uses SourceMod permissions.

## Chat shortcuts

| Chat text | Action |
| --- | --- |
| `help` | Open the gameplay guide. |
| `menu` | Open the upgrade menu for your current role. |
| `upgrade` | Open the upgrade guide. |
| `reset` | Refund your current role's upgrades and open the upgrade menu. |
| `rank` | Show your current team's rank and combat statistics; 9 switches teams and 0 exits. |
| `audio` | Open your audio settings menu. |
| `bugs` | Open the known bugs guide. |
| `cheat` | Open the visibility and anti-cheat guide. |
| `close` | Close an open upgrade menu or guide. |
| `1–8` | Buy the corresponding upgrade while the upgrade menu is open. |

`upgrades` is a compatibility alias for `upgrade`. Matching ignores capitalization and surrounding whitespace. Native menus use SourceMod number keys and work alive or dead. The upgrade menu fits on one page: 1–8 buy, 9 resets points, and 0 exits. Rank shows the current team with the other team on 9; guides use next/back/exit where shown. Chat digits always follow the eight-upgrade order shown by `menu`.

## Console commands

| Command | Access | Description |
| --- | --- | --- |
| `sf_status` | Generic admin or server console | Displays Shroudfire state, map rotation, teams, queue, AFK players, and spawn capacity. |
| `sf_observe [player]` | Generic admin | Moves you to Spectator to watch a living player or use a free camera. |
| `sf_restart` | Generic admin or server console | Restarts the current round without advancing the Invisant roster, including with one active player. Requires the generic admin flag. |
| `sf_invisant` | Root admin | Moves you to the Invisant team and respawns you at its spawn. |
| `sf_setlevel <player> <invisant\|armitive> <level>` | Root admin or server console | Sets an online player's Invisant or Armitive level to its starting XP, resets that role's purchased upgrades, and recalculates its available upgrade points for the assigned level. |
| `sf_level` | Player | Displays your Invisant and Armitive XP and levels. |
| `sf_cvar <name> [value]` | Generic admin or server console | Reads or sets a server cvar from the console. Requires the generic admin flag. |
| `sf_nextmap [map\|reset]` | Generic admin or server console | Displays or sets the next map; use reset to follow the configured rotation. |
| `sf_armitive` | Root admin | Moves you to the Armitive team and respawns you at its spawn. |
| `sf_update_notice <seconds>` | Server console only | Announces an upcoming CS:S update restart in chat. Server console only. |

`sf_setlevel` accepts levels 0–40 and SourceMod player targets. `sf_cvar` reads/writes plugin and stock cvars, hides protected values and logs changes. `sf_nextmap` validates installed maps and sets a one-map override; reset returns to the rotation. `sf_update_notice` accepts 1–3600 seconds and sends a notice only. `sf_invisant`, `sf_armitive` and `sf_observe` require a connected administrator. Observation also requires `sf_admin_spectate 1`.

## Server settings

Compiled defaults are listed below. The supplied config sets `sf_enable 1` and `sf_silent_local_movement 1`; other values match these defaults. Put persistent changes in `cfg/sourcemod/shroudfire.cfg`.

| Setting | Default | Range | Description |
| --- | --- | --- | --- |
| `sf_normal_stage1_level` | `1` | 1.0–40.0 | Role level required for normal upgrade stage 1. |
| `sf_normal_stage2_level` | `5` | 1.0–40.0 | Role level required for normal upgrade stage 2. |
| `sf_normal_stage3_level` | `10` | 1.0–40.0 | Role level required for normal upgrade stage 3. |
| `sf_normal_stage4_level` | `15` | 1.0–40.0 | Role level required for normal upgrade stage 4. |
| `sf_normal_stage5_level` | `20` | 1.0–40.0 | Role level required for normal upgrade stage 5. |
| `sf_ultimate_stage1_level` | `8` | 1.0–40.0 | Role level required for ultimate upgrade stage 1. |
| `sf_ultimate_stage2_level` | `16` | 1.0–40.0 | Role level required for ultimate upgrade stage 2. |
| `sf_ultimate_stage3_level` | `24` | 1.0–40.0 | Role level required for ultimate upgrade stage 3. |
| `sf_ultimate_stage4_level` | `32` | 1.0–40.0 | Role level required for ultimate upgrade stage 4. |
| `sf_ultimate_stage5_level` | `40` | 1.0–40.0 | Role level required for ultimate upgrade stage 5. |
| `sf_invisant_base_armor` | `25` | 0.0–200.0 | Invisant armor before Resilience. |
| `sf_knife_damage_min` | `50` | 1.0–1000.0 | Minimum Invisant knife damage per hit, inclusive. |
| `sf_knife_damage_max` | `75` | 1.0–1000.0 | Maximum Invisant knife damage per hit, inclusive. |
| `sf_armitive_blocked_weapons` | `m249` | String | Comma-separated weapons Armitive cannot buy; empty allows all weapons. |
| `sf_starvation_round_delay` | `60.0` | 0.0–3600.0 | Seconds of live play after freeze time before Invisant starvation can begin. |
| `sf_starvation_combat_delay` | `45.0` | 0.0–3600.0 | Seconds without dealing or taking damage before Invisant starvation begins. |
| `sf_starvation_damage` | `1` | 1.0–500.0 | Health an Invisant loses per starvation tick before acceleration. |
| `sf_starvation_interval` | `1.0` | 0.1–60.0 | Seconds between Invisant starvation ticks before acceleration. |
| `sf_starvation_acceleration_delay` | `20.0` | 0.0–3600.0 | Seconds of uninterrupted starvation before accelerated ticks begin; 0 accelerates immediately. |
| `sf_starvation_accelerated_interval` | `1.0` | 0.1–60.0 | Seconds between Invisant starvation ticks after acceleration. |
| `sf_starvation_accelerated_damage` | `3` | 1.0–500.0 | Health an Invisant loses per starvation tick after acceleration. |
| `sf_knife_range` | `72.0` | 0.0–16384.0 | Maximum Invisant knife reach in units; 0 disables extended hits. |
| `sf_knife_cone` | `60.0` | 0.0–360.0 | Full Invisant knife cone width in degrees; 360 covers every direction. |
| `sf_knife_attack_speed_percent` | `66` | 1.0–100.0 | Invisant knife attack speed as a percent of normal; 100 restores the normal rate. |
| `sf_knife_miss_sound` | `1` | 0.0–1.0 | Replay Invisant knife air-miss sounds spatially to Armitive players. |
| `sf_knife_world_hit_sound` | `1` | 0.0–1.0 | Replay Invisant knife wall and ground impact sounds spatially to Armitive players. |
| `sf_lightweight_gravity_percent` | `10` | 0.0–20.0 | Gravity reduction percent per Lightweight stage. |
| `sf_momentum_run_percent` | `3` | 0.0–100.0 | Run speed increase percent per Momentum stage. |
| `sf_resilience_armor_per_stage` | `15` | 0.0–100.0 | Maximum armor gained per Resilience stage. |
| `sf_resilience_helmet_stage` | `5` | 1.0–5.0 | Resilience stage that grants a helmet. |
| `sf_reforging_armor_per_stage` | `1` | 0.0–100.0 | Armor regenerated per Reforging stage each interval. |
| `sf_reforging_interval` | `3` | 1.0–60.0 | Seconds between Reforging armor ticks and after damage. |
| `sf_vampirism_health_per_stage` | `3` | 0.0–100.0 | Health restored per Vampirism stage on a damaging hit. |
| `sf_bloodlust_health_per_stage` | `6` | 0.0–100.0 | Health restored per Bloodlust stage on a kill. |
| `sf_mobility_crouch_percent` | `15` | 0.0–100.0 | Crouch speed increase percent per Mobility stage. |
| `sf_surge_base_speed` | `480` | 0.0–2000.0 | Surge speed boost at stage 1. Default: 480. |
| `sf_surge_speed_per_stage` | `30` | 0.0–1000.0 | Additional Surge speed boost for each stage after stage 1. Default: 30. |
| `sf_surge_add_momentum` | `0` | 0.0–1.0 | Whether Surge adds to current velocity (1) or replaces it (0). Default: 0. |
| `sf_surge_cooldown` | `20` | 0.0–300.0 | Seconds until Surge is ready after use. |
| `sf_armitive_base_health` | `100` | 1.0–500.0 | Armitive health before Fortitude. |
| `sf_fortitude_health_per_stage` | `10` | 0.0–100.0 | Maximum health gained per Fortitude stage. |
| `sf_recovery_health_per_stage` | `1` | 0.0–100.0 | Health regenerated per Recovery stage each interval. |
| `sf_recovery_interval` | `3` | 1.0–60.0 | Seconds between Recovery health ticks and after damage. |
| `sf_overload_magazine_percent` | `10` | 0.0–50.0 | Magazine capacity increase percent per Overload stage. |
| `sf_stockpile_clips_per_stage` | `1` | 0.0–5.0 | Extra reserve clips per Stockpile stage. |
| `sf_barrage_fire_rate_percent` | `7` | 0.0–100.0 | Weapon fire rate increase percent per Barrage stage. |
| `sf_control_reduction_percent` | `10` | 0.0–20.0 | Recoil and spread reduction percent per Control stage. |
| `sf_dexterity_speed_percent` | `12` | 0.0–19.0 | Reload and weapon switch time reduction percent per Dexterity stage. |
| `sf_ward_base_seconds` | `2.0` | 0.1–30.0 | Ward immunity duration at stage 1 in seconds. |
| `sf_ward_seconds_per_stage` | `0.5` | 0.0–10.0 | Additional Ward seconds for each stage after stage 1. |
| `sf_ward_cooldown` | `30` | 0.0–300.0 | Seconds until Ward is ready after it ends. |
| `sf_upgrade_purchase_window` | `20` | 0.0–120.0 | Seconds from round start when purchased or reset upgrades apply immediately. |
| `sf_enable` | `0` | 0.0–1.0 | Enables Shroudfire. |
| `sf_invisant_team` | `3` | 2.0–3.0 | Selects the Invisant team: 2 for Terrorists or 3 for Counter-Terrorists. |
| `sf_visible_per_invisant` | `4` | 2.0–32.0 | Maximum number of Armitive players per Invisant player. |
| `sf_round_time` | `120` | 30.0–3600.0 | Seconds before an unfinished round ends with an Armitive win. |
| `sf_map_max_rounds` | `20` | 0.0–1000.0 | Completed rounds per map before changing maps; 0 disables the round limit. |
| `sf_map_time_limit` | `30.0` | 0.0–1440.0 | Minutes per map with at least two active human players before changing maps; 0 disables the time limit. |
| `sf_map_rotation` | `de_dust2,de_mirage,de_inferno,de_nuke` | String | Comma-separated map rotation; unavailable maps are skipped. |
| `sf_timeout_kill_invisant` | `0` | 0.0–1.0 | Kill surviving Invisant at timeout; 0 reveals them during the 10-second round transition instead. |
| `sf_timeout_reveal_seconds` | `2.0` | 0.0–10.0 | Seconds for surviving Invisant to fade from invisible to visible after timeout; 0 reveals instantly. |
| `sf_map_join_grace` | `30` | 0.0–120.0 | Seconds after map start in which joining players can respawn as Armitive. |
| `sf_afk_seconds` | `30` | 0.0–600.0 | Seconds of inactivity after freeze time before a player is killed; 0 disables AFK deaths. |
| `sf_afk_warning_seconds` | `10` | 0.0–600.0 | Seconds before AFK death to start the HUD countdown and warning sounds; 0 disables the warnings. |
| `sf_afk_limit` | `5` | 0.0–100.0 | Consecutive deaths without live-round movement before a player is kicked; 0 disables kicks. |
| `sf_camping_distance` | `256.0` | 0.0–4096.0 | Distance in units an Armitive must move from the tracked position before the camping timer resets; 0 disables anti-camping. |
| `sf_camping_warning_seconds` | `20.0` | 0.0–600.0 | Seconds an Armitive may remain within the camping distance before the HUD and voice warning. |
| `sf_camping_damage_delay` | `10.0` | 0.0–600.0 | Seconds from the Armitive camping warning until health loss begins. |
| `sf_camping_damage` | `10` | 1.0–500.0 | Health an Armitive loses per second while camping. |
| `sf_queue_reconnect_grace` | `600` | 0.0–86400.0 | Seconds a reconnecting player retains queue age; 0 is unlimited. |
| `sf_xp_kill_invisant` | `50` | 0.0–10000.0 | XP for an Invisant killing an Armitive player. |
| `sf_xp_kill_armitive` | `100` | 0.0–10000.0 | XP for an Armitive player killing an Invisant. |
| `sf_xp_round_win_invisant` | `70` | 0.0–10000.0 | XP for an Invisant participant on a completed win. |
| `sf_xp_round_win_armitive` | `35` | 0.0–10000.0 | XP for an Armitive participant on a completed win. |
| `sf_xp_armitive_pistol_percent` | `125` | 0.0–1000.0 | Armitive pistol kill XP as a percent of Armitive base kill XP; 100 removes the bonus. |
| `sf_xp_armitive_knife_percent` | `150` | 0.0–1000.0 | Armitive knife kill XP as a percent of Armitive base kill XP; 100 removes the bonus. |
| `sf_xp_level_base` | `100` | 1.0–1000000.0 | Base XP for the level curve. |
| `sf_kill_streak_window` | `10.0` | 1.0–60.0 | Maximum seconds between a player's consecutive opponent kills for a kill streak. |
| `sf_xp_assist_fraction` | `0.25` | 0.0–1.0 | Fraction of the current role's kill XP awarded for a qualifying assist. Set to 0 to disable assist XP. |
| `sf_xp_assist_damage_share` | `0.25` | 0.0–1.0 | Minimum share of a victim's opposing-player damage required for assist XP. 0.25 means 25 percent. |
| `sf_xp_first_blood_percent` | `125` | 0.0–1000.0 | Kill XP percent for First Blood; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_xp_double_kill_percent` | `120` | 0.0–1000.0 | Kill XP percent for Double Kill; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_xp_killing_spree_percent` | `130` | 0.0–1000.0 | Kill XP percent for Killing Spree; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_xp_ultra_kill_percent` | `140` | 0.0–1000.0 | Kill XP percent for Ultra Kill; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_xp_rampage_percent` | `150` | 0.0–1000.0 | Kill XP percent for Rampage; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_xp_dominating_percent` | `160` | 0.0–1000.0 | Kill XP percent for Dominating; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_xp_unstoppable_percent` | `170` | 0.0–1000.0 | Kill XP percent for Unstoppable; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_xp_monster_kill_percent` | `180` | 0.0–1000.0 | Kill XP percent for Monster Kill; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_xp_godlike_percent` | `190` | 0.0–1000.0 | Kill XP percent for Godlike; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_xp_holy_shit_percent` | `200` | 0.0–1000.0 | Kill XP percent for Holy Shit; multiplies the Armitive knife or pistol bonus when applicable. |
| `sf_invisant_see_teammates` | `1` | 0.0–1.0 | Allow Invisant players to see and spectate Invisant teammates. |
| `sf_discord_link` | `https://discord.gg/TMV2DEPhqT` | String | Discord server invite link in chat messages; empty disables the messages. |
| `sf_discord_message` | `1` | 0.0–1.0 | Enables Discord invite messages in chat. |
| `sf_discord_interval` | `1200` | 1.0–86400.0 | Seconds between recurring Discord invite messages. |
| `sf_audio_hint` | `1` | 0.0–1.0 | Enables the automatic audio chat hint. |
| `sf_audio_hint_cooldown` | `60` | 0.0–86400.0 | Seconds before the automatic audio chat hint can trigger again. |
| `sf_cheat_hint` | `1` | 0.0–1.0 | Enables the automatic cheat chat hint. |
| `sf_cheat_hint_cooldown` | `60` | 0.0–86400.0 | Seconds before the automatic cheat chat hint can trigger again. |
| `sf_upgrade_hint` | `1` | 0.0–1.0 | Enables the automatic upgrade chat hint. |
| `sf_upgrade_hint_cooldown` | `60` | 0.0–86400.0 | Seconds before the automatic upgrade chat hint can trigger again. |
| `sf_bugs_hint` | `1` | 0.0–1.0 | Enables the automatic known-bugs chat hint. |
| `sf_bugs_hint_cooldown` | `60` | 0.0–86400.0 | Seconds before the automatic known-bugs chat hint can trigger again. |
| `sf_menu_hint` | `1` | 0.0–1.0 | Enables the automatic upgrade-menu chat hint. |
| `sf_menu_hint_cooldown` | `60` | 0.0–86400.0 | Seconds before the automatic upgrade-menu chat hint can trigger again. |
| `sf_reset_hint` | `1` | 0.0–1.0 | Enables the automatic upgrade-reset chat hint. |
| `sf_reset_hint_cooldown` | `60` | 0.0–86400.0 | Seconds before the automatic upgrade-reset chat hint can trigger again. |
| `sf_rank_hint` | `1` | 0.0–1.0 | Enables the automatic rank chat hint. |
| `sf_rank_hint_cooldown` | `60` | 0.0–86400.0 | Seconds before the automatic rank chat hint can trigger again. |
| `sf_hud` | `1` | 0.0–1.0 | Show role, level, XP and queue position in the round-start center panel. |
| `sf_round_info_seconds` | `10` | 0.0–120.0 | Seconds to show the round-start role, level, XP and queue panel. Set to 0 to disable. |
| `sf_hud_kill_seconds` | `5.0` | 0.0–120.0 | Seconds to show each kill XP line, including post-round kills; 0 hides these lines. |
| `sf_hud_assist_seconds` | `5.0` | 0.0–120.0 | Seconds to show each assist XP line; 0 hides these lines without changing XP awards. |
| `sf_hud_round_result_seconds` | `10.0` | 0.0–120.0 | Seconds to show the round win or draw title; 0 hides the title. |
| `sf_hud_round_win_xp_seconds` | `10.0` | 0.0–120.0 | Seconds to show round-win XP; 0 hides this line without changing XP awards. |
| `sf_hud_levelup_seconds` | `5.0` | 0.0–120.0 | Seconds to show a level-up line; 0 hides these lines. |
| `sf_hud_priority_seconds` | `5.0` | 0.0–120.0 | Seconds to show earned Invisant queue priority; 0 hides this line without changing priority. |
| `sf_hud_no_rewards_seconds` | `5.0` | 0.0–120.0 | Seconds to show No rewards after round end following a post-round kill; 0 hides this line. |
| `sf_timeout_warning_seconds` | `10` | 0.0–120.0 | Seconds before timeout when the Invisant fade warning and reveal voice begin; 0 disables both. |
| `sf_wallhack` | `1` | 0.0–1.0 | Show living Armitive with through-wall outlines to living Invisant players. |
| `sf_ward_screen_tint` | `85` | 0.0–255.0 | Green screen tint strength while Ward is active. Set to 0 to disable; 255 is maximum. |
| `sf_extra_spawns` | `1` | 0.0–1.0 | Create validated additional team spawns on Windows and Linux when the map does not have enough for the maximum roster. |
| `sf_blood_amount` | `4` | 0.0–6.0 | Number of additional blood-splatter bursts when an Armitive damages an Invisant or an Invisant knife damages an Armitive. Set to 0 for normal blood only. |
| `sf_tonemap_exposure` | `0.40` | 0.05–1.0 | Attempts to set HDR exposure on the map's tonemap controller. Stock de_dust2 lighting is baked and unaffected. |
| `sf_admin_spectate` | `1` | 0.0–1.0 | Allow administrators with the generic flag to observe players or use a spectator free camera. |
| `sf_custom_sounds` | `0` | 0.0–1.0 | Play Shroudfire voice clips when clients have downloaded the supplied sounds. |
| `sf_silent_local_movement` | `0` | 0.0–1.0 | Block an Invisant's own footsteps, jumps, and landings using Source client prediction overrides. |
| `sf_round_win_sound_delay` | `0.5` | 0.0–10.0 | Delay in seconds before playing an Armitive win, Invisant win, or round draw voice clip. |
| `sf_announce` | `1` | 0.0–1.0 | Show a chat notice when an Armitive player earns Invisant priority. |
| `sf_map_lightstyle` | `h` | String | Baked map-light brightness: a is darkest, h is dark, m is normal. |
| `sf_invisant_screen_tint` | `125` | 0.0–255.0 | Red color-grade strength for Invisant players; 0 disables it. |

Global chat reaches every human, including dead players and spectators. Team chat stays within the sender's role. Invisant radio, flashlight and spray commands are blocked; their buying is disabled. Armitive buying follows normal checks and sf_armitive_blocked_weapons, including autobuy and rebuy. Suicide/fatal falls forfeit next-round Invisant eligibility. Post-round kills change no XP, rankings, streaks or priority.

## Audio preferences

`audio` opens all eight toggles on one page: Round Start, Round End, Kill Streak, Starvation, Timeout, Camping, AFK, and Menu. Camping warning voices are independent of AFK. All settings default ON and persist between sessions.

## Knife damage and purchases

`sf_knife_damage_min` and `sf_knife_damage_max` define an inclusive damage range. Reversed bounds use their lower and higher values; identical values give fixed damage. Native and extended Invisant claw hits roll damage once.

`sf_armitive_blocked_weapons` accepts comma-separated or whitespace-separated CS:S weapon names and purchase aliases, case-insensitively, with an optional `weapon_` prefix. The default blocks `m249`; an empty string permits all purchases. For example, `sf_cvar sf_armitive_blocked_weapons "m249,awp"` blocks those weapons. Unknown names and CS2-only weapons are ignored and reported in the server console. CSS names include `m4a1`, `mp5navy`, `m3`, `sg552`, and `sg550`; grenades and equipment purchase aliases are supported. Restrictions affect buying, autobuy and rebuy, while pickups and spawn loadouts retain their existing rules.

## Starvation

Both the live-round delay and time without dealing or taking damage must expire before starvation starts. The first tick is immediate. Defaults: 60 seconds after freeze time, 45 seconds without combat, 1 HP every second, then 3 HP every second after 20 seconds of uninterrupted starvation. A 100-HP Invisant starting at 1:00 dies with roughly 0:15 left in a two-minute round. Fractional tick intervals run every game frame; delayed frames cause no catch-up damage burst. Damage dealt or taken resets starvation and its acceleration; starvation damage itself does not reset it. Solo play and rounds without living Armitive do not cause starvation.

## Automatic chat hints

Automatic chat hints use the CS2 wording with a green prefix and brown command names. For example: `[Shroudfire] Type upgrade to learn about them`.
