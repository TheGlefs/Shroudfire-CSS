# Shroudfire for Counter-Strike: Source

Shroudfire is an asymmetric combat mode for **Counter-Strike: Source**. **Invisant** (*invisible assailants*) hunt with invisibility and claws, while **Armitive** (*armed fugitives*) fight back with firearms or survive until time runs out. Roles rotate each round, and progression persists between sessions.

This edition runs as a SourceMod plugin with MetaMod:Source. For the native C++ edition for Counter-Strike 2, see [Shroudfire for Counter-Strike S2](https://github.com/TheGlefs/Shroudfire-CS2).

**Shroudfire was built using AI, but it is not slop. Great care was taken to get every detail right.** To build it, change it, or update it, open this repository in an AI coding assistant and describe what you want. See [Build or update with AI](#build-or-update-with-ai) for examples, or follow the manual build instructions below.

[How to play](#how-to-play) · [ESP and wallhacks](#esp-and-wallhacks) · [Upgrades](#upgrades) · [Chat shortcuts](#chat-shortcuts) · [Play](#play) · [Host a server](#install-and-configure) · [Build](#build) · [Discord](https://discord.gg/TMV2DEPhqT)

## How to play

Rounds last two minutes by default, with a roster that scales toward four Armitive per Invisant. Each role has separate XP, levels up to 40, upgrade points, and persistent combat rankings. The descriptions below use the supplied server defaults. Server settings can change the round length and role ratio.

### Invisant

Invisible, knife-only. Armitive cannot hear your footsteps. Kill all Armitive to win. Knife: 60-degree cone, 72 units of reach, 50-75 raw damage per hit by default. Servers can configure both damage bounds.

No backstab bonus; knife attacks at 66% of normal speed. Track living Armitive through walls and take no fall damage.

After 60s of live play, 45s without dealing or taking damage starts `Starvation`. You lose 1 HP/s, increasing to 3 HP/s after 20s of continuous starvation. Starting at full health at 1:00, you die with roughly 0:15 remaining unless combat resets it. Server settings can change the delays, damage, and tick intervals.

### Armitive

Find the Invisant with firearms, blood, and contact. The default purchase restriction blocks the `M249`; administrators can change the list. Armitive win if anyone survives the round timer.

Headshot damage to Invisant is halved and capped at 90. One headshot cannot kill a full-health Invisant.

Move at least 256 units from your tracked position to avoid camping. A warning starts after 20s; after another 10s, you lose 10 HP/s until you move away. Server settings can change the movement distance, warning and damage delays, and damage per second.

### Rotation

Roles rotate each round. An Armitive who kills an Invisant gets priority to become Invisant next round.

Otherwise, the longest-waiting eligible player becomes Invisant. Suicide forfeits next-round eligibility.

### Progression

Kills, qualifying damage assists, and completed-round wins grant separate Invisant and Armitive XP. Server settings can change XP rewards, assist requirements, and the level progression curve.

As Armitive, knife kills earn 150% kill XP; pistol kills, 125%. Levels grant upgrade points. In chat, type `upgrade` for effects, `menu` to spend points, or `reset` to refund them.

### Kill streaks

In 2v2+ rounds, the first enemy kill earns `First Blood`: 125% kill XP. Your second kill within 10s of the last earns 120%.

Each later kill within 10s of your last adds 10% kill XP, up to 200% on your tenth kill. Only you hear the sounds. Server settings can change the streak window and XP bonuses.

### Rank

Type `rank` for your current team's statistics and rank. Kills after the round ends grant no XP, rank, or role priority.

Default timeout behavior reveals surviving Invisant during the round transition. Servers can choose to kill them instead.

## ESP and wallhacks

Invisant are not made transparent. During the hunt, the server does not send Invisant players, or their weapon and movement sounds, to Armitive computers.

ESP and wallhacks can only show data a computer receives. With no Invisant player data, they cannot reveal or track an Invisant.

Missed knife swings and wall impacts remain audible clues. Surviving Invisant may be deliberately revealed after timeout.

Armitive still see blood and bullet impacts, and hear damage sounds.

## Upgrades

Each role has eight upgrades, with five stages per upgrade. Unlocks use your level in that role. Server settings can change unlock levels, upgrade effects, regeneration intervals, and the purchase window.

### Unlocks

Normal stages unlock at role levels 1, 5, 10, 15 and 20.

Ultimate stages unlock at role levels 8, 16, 24, 32 and 40.

Type `menu` to spend points or `reset` to refund them.

Changes apply immediately in the opening 20s, then next round afterward.

### Armitive

| Upgrade | Effect |
| --- | --- |
| **Fortitude** | Gain 10 maximum health per stage. |
| **Recovery** | Restore 1 health per stage every 3 seconds. |
| **Overload** | Gain 10% extra magazine capacity per stage. |
| **Stockpile** | Gain 1 extra reserve ammo clip per stage. |
| **Barrage** | Gain 7% faster weapon fire rate per stage. |
| **Control** | Gain 10% less recoil and bullet spread per stage. |
| **Dexterity** | Gain 12% less weapon switch and reload time per stage. |
| **Ultimate: Ward** | Press E for 2 seconds of immunity at 1/5, plus 0.5 seconds per later stage. |

### Invisant

| Upgrade | Effect |
| --- | --- |
| **Lightweight** | Gain 10% less gravity per stage. |
| **Momentum** | Gain 3% faster run speed per stage. |
| **Resilience** | Gain 15 armor per stage and helmet at 5/5. |
| **Reforging** | Gain 1 armor per stage every 3 seconds. |
| **Vampirism** | Gain 3 health per stage when dealing damage. |
| **Bloodlust** | Gain 6 health per stage when killing an enemy. |
| **Mobility** | Gain 15% faster crouching speed per stage. |
| **Ultimate: Surge** | Press E for a 480 unit speed boost at 1/5, increased by 30 per later stage. |

## Chat shortcuts

Type these in chat without a prefix:

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
| `close` | Close an open menu or guide. |

### Menu controls

Upgrade, rank, and audio menus use native SourceMod number keys and work while alive or dead. The upgrade menu shows all eight upgrades on one page:

| Key | Action |
| --- | --- |
| 1–8 | Buy the corresponding upgrade. |
| 9 | Reset your current role's upgrade points. |
| 0 | Exit the menu. |

Chat digits `1`–`8` also buy the corresponding upgrade while its menu is open. `audio` provides eight persistent toggles: Round Start, Round End, Kill Streak, Starvation, Timeout, Camping, AFK, and Menu. Settings follow you across roles and sessions.

Guides open the authored HTML pages from FastDL when configured, with native SourceMod guides as a fallback. Native guides display the current server settings; the HTML pages and descriptions above use the supplied defaults.

See [COMMANDS.md](COMMANDS.md) and the [HTML command reference](game-assets/shroudfire/commands.html) for the full command reference, administrator access, rankings, and server settings.

## Play

Join a Counter-Strike: Source server running Shroudfire.

## Install and configure

### Requirements

- A Counter-Strike: Source dedicated server with MetaMod:Source and SourceMod 1.12.
- SourceMod SDKTools, SDKHooks, DHooks, Client Preferences, and SQLite support.
- Working client downloads for the supplied claws, player model, color lookup table, and optional voices. Enable `sv_allowdownload` and configure FastDL for public hosting.
- Optionally, the bundled [Connect query-cache addon](connect/README.md) to display Shroudfire in the server browser's Game column.

The SourceMod runtime and server binaries are external dependencies and are not bundled. The SourcePawn bytecode is portable; native extensions must match the server platform and architecture.

### Installation

1. **Build the plugin and assets** using [AI](#build-or-update-with-ai) or the [manual instructions](#build). The install tree is written to `dist/package/`.
2. **Stop the server** before installing the plugin, assets, or native extensions.
3. **Copy the package.** Copy the contents of `dist/package/` into the server's `cstrike/` directory, preserving paths. Load only `addons/sourcemod/plugins/shroudfire.smx` for this mode.
4. **Configure gameplay.** Edit `cfg/sourcemod/shroudfire.cfg`. It enables Shroudfire and local movement silencing. Custom voices default to off; enable `sf_custom_sounds 1` after downloads work.
5. **Set up client downloads.** If using FastDL, upload the contents of `dist/fastdl/` to your download root. All custom assets use Shroudfire paths. Retain their license and attribution notices.
6. **Set administrator access.** Use SourceMod's normal administrator configuration. Generic access allows status, cvar changes, restart, next-map selection, and observation. Root access also allows level changes and forcing your own role.
7. **Start and verify.** Run the following in the server console, then check role assignment, combat, menus, and round transitions with multiple human clients before opening the server to players.

```text
sm plugins list
sf_status
sf_cvar sf_enable
```

### Configuration and player data

| File or directory | Purpose |
| --- | --- |
| `cstrike/cfg/sourcemod/shroudfire.cfg` | Gameplay balance, map rotation, upgrades, HUD, chat hints, and sound settings. |
| SourceMod administrator configuration | Administrator permissions and access levels. |
| `cstrike/addons/sourcemod/data/sqlite/shroudfire.sq3` | Persistent player profiles and combat statistics. |
| SourceMod Client Preferences | Queue and audio preferences stored with `shroudfire_` cookies. |

The plugin creates its current database tables automatically. Back up configs and player data before updating or migrating.

### Map rotation

By default, a map changes after **20 completed rounds or 30 minutes of play** with at least two active humans. The current round finishes, players receive a five-second announcement, and the server changes map.

Configure installed Source maps in `sf_map_rotation`; the default list skips missing maps such as CS2's Mirage. Set both map limits to `0` for unlimited play on the current map. `sf_nextmap [map|reset]` chooses the next destination without changing immediately. See the [command reference](COMMANDS.md) for the full behavior.

### Connect addon

The included [Connect source](connect/) provides `sv_gamedesc_override`, allowing the server browser's Game column to show **Shroudfire**. Gameplay does not require this addon.

Follow [connect/README.md](connect/README.md) to build the Linux x86 extension and install its binary, `connect2.games.txt`, and `connect.autoload` marker. Restart the server after installing native extensions.

This is a separate native build requiring the CS:S HL2SDK, SourceMod and MetaMod source, AMBuild, and a 32-bit Linux C++ toolchain. The repository includes the build script and required query-cache code.

## Build

Install Python 3 and use the compiler from your SourceMod installation. From the repository root:

```powershell
python tools/generate_guides.py
python tools/generate_reference.py
python tools/build.py --compiler C:\css-server\cstrike\addons\sourcemod\scripting\spcomp64.exe --fastdl
```

On Linux, pass your SourceMod `addons/sourcemod/scripting/spcomp` path instead. Use `--include` if the standard SourceMod includes are in another directory. The build treats compiler warnings as errors.

| Output | Contents |
| --- | --- |
| `dist/package/` | Installable server files. |
| `dist/shroudfire-css-1.0.0.zip` | Packaged server archive. |
| `dist/fastdl/` | Optional FastDL assets, both raw and bzip2. |

Build steps write to `dist/`; they do not modify a running server. GitHub Actions compiles and packages the plugin and the Linux x86 Connect addon on every push and pull request. The plugin job pins SourceMod 1.12.0.7255 from its official GitHub release and verifies the archive's SHA-256.

## Build or update with AI

Open this checkout in an AI coding assistant with access to the files and terminal, then describe the result you want. For example:

> Build Shroudfire for my Counter-Strike: Source server. Read the README and build scripts, use my SourceMod compiler, regenerate the guides and references, compile with warnings treated as errors, and prepare the install archive and FastDL assets.

> Change Ward's cooldown to 25 seconds. Read the source and related guides, update the compiled default and guide content where needed, regenerate docs and config, verify the affected behavior, compile with warnings treated as errors, and prepare the install archive.

Tell the assistant your server platform, relevant local paths, and the behavior you want. Test gameplay changes with multiple clients on the destination server.

## Development

| Area | Files |
| --- | --- |
| Main SourceMod plugin | [addons/sourcemod/scripting/shroudfire.sp](addons/sourcemod/scripting/shroudfire.sp) |
| Gameplay, settings, menus, rankings, and sound categories | [addons/sourcemod/scripting/include/shroudfire/](addons/sourcemod/scripting/include/shroudfire/) |
| Native fallback guides | [guides.json](guides.json); regenerate with `python tools/generate_guides.py`. |
| Authored HTML guides | [game-assets/shroudfire/](game-assets/shroudfire/) |
| Command reference and example config | Regenerate with `python tools/generate_reference.py` after editing command and setting descriptions in the plugin. |
| Build and packaging | [tools/build.py](tools/build.py) |
| Optional server-browser addon | [connect/README.md](connect/README.md) |

Keep the generated `addons/sourcemod/scripting/include/shroudfire/guides.inc`; it is required to compile the plugin. Edit the authored HTML files directly, preserving their existing markup and style. Preserve file encodings, and keep commands, settings, guides, and example configs consistent.

## Compatibility and known limitations

Windows builds were checked with the local SourceMod 1.12 compiler. 

Menus use SourceMod number keys; the Counter-Strike 2 edition's HUD navigation keys do not apply here. HTML guides describe the supplied defaults, while native fallback guides display current server settings.

For player-facing limitations, type `bugs` in chat. For hosting and asset requirements, see the [command reference](COMMANDS.md), [asset attribution](game-assets/ATTRIBUTION.md), and [Connect build instructions](connect/README.md).

## License and credits

The SourceMod plugin distribution is [GPL-3.0](LICENSE), with the Source engine linking exception in [NOTICE](NOTICE). SourceMod API notices are retained in [third-party/SourceMod-LICENSE.txt](third-party/SourceMod-LICENSE.txt). See [SourceMod's licensing information](https://www.sourcemod.net/license.php). When distributing plugin binaries, provide their complete corresponding source, including build scripts, as required by GPLv3.

The **51 MP3 voices were generated with elevenlabs.io** and retain separate non-commercial terms in [SOUNDS-LICENSE.md](SOUNDS-LICENSE.md). They are excluded from the source-code licenses. Model and texture credits, origins, and redistribution details are retained in [game-assets/ATTRIBUTION.md](game-assets/ATTRIBUTION.md). Third-party game assets retain their owners' terms.
