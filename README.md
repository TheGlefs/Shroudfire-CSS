# Shroudfire

Shroudfire brings asymmetric combat to Counter-Strike: Source: **Invisant** (*invisible assailants*) hunt with claws, while **Armitive** (*armed fugitives*) fight back with firearms or survive the timer.

**Shroudfire was built using AI. To build it, change it, or update it, open this repository in an AI coding assistant and describe what you want.**

Example AI request:

> Change Ward's cooldown to 25 seconds. Read the source and related guides, update the compiled default and guide content where needed, regenerate docs and config, verify the affected behavior, compile with warnings treated as errors, and prepare the install archive.

Rounds last two minutes by default. Roles rotate through a persistent queue; killing an Invisant earns priority. Each role has separate XP, levels up to 40, upgrade points, and persistent combat rankings. The roster scales toward four Armitive per Invisant.

| Invisant upgrades | Armitive upgrades |
| --- | --- |
| Lightweight, Momentum, Resilience, Reforging, Vampirism, Bloodlust, Mobility, **Surge** | Fortitude, Recovery, Overload, Stockpile, Barrage, Control, Dexterity, **Ward** |

Press **Use (E)** after buying an ultimate. Surge launches an Invisant toward their aim; Ward briefly shields an Armitive. Upgrades purchased or reset within the opening 20 seconds apply immediately; later changes apply next round. Starvation, AFK handling, and Armitive camping damage keep rounds moving. Starvation defaults to 60 seconds of live play and 45 seconds without combat, losing 1 HP/s and accelerating to 3 HP/s after 20 seconds. Its delays, damage and fractional tick intervals are configurable. Invisant knife damage and Armitive purchase restrictions are configurable too.

Type `help`, `menu`, `upgrade`, `reset`, `rank`, `audio`, `bugs`, `cheat`, or `close` in chat. Guides open the authored HTML pages from FastDL when configured, with native SourceMod guides as a fallback. Upgrade, rank and audio menus use native SourceMod number keys, available while alive or dead. The upgrade menu shows all eight upgrades on one page: `1`–`8` buy, `9` resets points, and `0` exits. `rank`: Show your current team's rank and combat statistics; 9 switches teams and 0 exits. Chat digits `1`–`8` also buy the corresponding upgrade while its menu is open. Audio settings provide eight persistent toggles: Round Start, Round End, Kill Streak, Starvation, Timeout, Camping, AFK, and Menu. Native guides display the current server settings; the authored HTML pages describe the supplied defaults.

See [COMMANDS.md](COMMANDS.md) and the [command reference](game-assets/shroudfire/commands.html). Community: [Discord](https://discord.gg/TMV2DEPhqT).

## Requirements

- Counter-Strike: Source dedicated server with MetaMod:Source and SourceMod 1.12.
- SourceMod SDKTools, SDKHooks, DHooks, Client Preferences, and SQLite support.
- Optional bundled [Connect query-cache addon](connect/README.md) for the server-browser game description. Its source and Linux build instructions are included; gameplay does not require it.
- Working client downloads for the supplied claws, player model, color lookup table, and optional voices. Enable `sv_allowdownload` and configure FastDL for public hosting.

The SourceMod runtime and server binaries are external dependencies and are not bundled. Windows builds were checked with the local SourceMod 1.12 compiler. The bytecode is portable; the optional Linux Connect addon and multiplayer effects still need validation on the destination server.

## Build and package

Install Python 3, then use the compiler from your SourceMod installation:

```powershell
python tools/generate_guides.py
python tools/generate_reference.py
python tools/build.py --compiler C:\css-server\cstrike\addons\sourcemod\scripting\spcomp64.exe --fastdl
```

On Linux, pass your SourceMod `addons/sourcemod/scripting/spcomp` path instead. Use `--include` if the standard SourceMod includes are in another directory. The build treats compiler warnings as errors.

The install tree is `dist/package/`; the archive is `dist/shroudfire-css-1.0.0.zip`. Optional FastDL files appear under `dist/fastdl/`, with both raw and bzip2 assets. No build step modifies a running server. GitHub Actions compiles and packages the plugin and the Linux x86 Connect addon on every push and pull request.

## Install

1. Stop the server before installing the plugin, assets or native extensions.
2. Copy the **contents** of `dist/package/` into the server's `cstrike/` directory, preserving paths. Load only `addons/sourcemod/plugins/shroudfire.smx` for this mode.
3. Configure `cfg/sourcemod/shroudfire.cfg`. It enables Shroudfire and local movement silencing. Custom voices default to off; enable `sf_custom_sounds 1` after downloads work.
4. If using FastDL, upload `dist/fastdl/` contents to your download root. All custom assets use Shroudfire paths. Original assets and voice recordings have separate notices below.
5. Use SourceMod's normal administrator configuration. Generic access allows status, cvar changes, restart, next-map selection, and observation. Root access also allows level changes and forcing your own role.
6. Start the server and run `sm plugins list`, `sf_status`, and `sf_cvar sf_enable`. Verify gameplay with multiple human clients before public use.

Shroudfire manages map rotation after 20 completed rounds or 30 minutes with at least two active humans. It finishes the current round, announces the next map, and changes after five seconds. Configure installed Source maps in `sf_map_rotation`; its default list skips missing maps such as CS2's Mirage. Set both map limits to `0` for unlimited play. `sf_nextmap [map|reset]` chooses the next destination without changing immediately.

## Connect addon

The included [Connect source](connect/) provides `sv_gamedesc_override`, allowing the server browser's Game column to show **Shroudfire**. Follow [connect/README.md](connect/README.md) to build the Linux x86 extension and install its binary, `connect2.games.txt`, and `connect.autoload` marker. Restart the server after installing native extensions.

The addon is a separate native build. Its compilation needs the CS:S HL2SDK, SourceMod/MetaMod source, AMBuild, and a 32-bit Linux C++ toolchain. This repository includes a build script and the required query-cache code.

Player profiles are stored in `addons/sourcemod/data/sqlite/shroudfire.sq3`. The plugin creates its own current tables and stores queue/audio preferences using `shroudfire_` cookies.

## Development

The main plugin is `addons/sourcemod/scripting/shroudfire.sp`. Shared settings, current menus, rankings, camping, map rotation, sound categories, and native guides are under `addons/sourcemod/scripting/include/shroudfire/`.

Edit `guides.json` for native fallback guides, then run `python tools/generate_guides.py`. Keep the generated `addons/sourcemod/scripting/include/shroudfire/guides.inc`; it is required to compile the plugin. Edit the authored HTML files under `game-assets/shroudfire/` directly, preserving their existing markup and style. Edit command/settings descriptions in the plugin, then run `python tools/generate_reference.py` to update the Markdown reference, HTML command reference, and example config.

## License and assets

The SourceMod plugin distribution is [GPL-3.0](LICENSE), with the Source engine linking exception in [NOTICE](NOTICE). SourceMod API notices are retained in [third-party/SourceMod-LICENSE.txt](third-party/SourceMod-LICENSE.txt). See [SourceMod's licensing information](https://www.sourcemod.net/license.php).

The **51 MP3 voices were generated with elevenlabs.io** and retain separate non-commercial terms in [SOUNDS-LICENSE.md](SOUNDS-LICENSE.md). They are excluded from the source-code licenses. Model and texture credits, origins, and redistribution details are retained in [game-assets/ATTRIBUTION.md](game-assets/ATTRIBUTION.md). Third-party game assets retain their owners' terms.
