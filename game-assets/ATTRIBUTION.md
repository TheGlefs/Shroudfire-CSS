# Third-party asset attribution

## Echo's Zombie Claws

- Source: https://gamebanana.com/mods/212737
- Original archive: `ezc-r1.zip`
- Original archive MD5: `97a1461ff092c1b544947a89a3d67bd7`
- Original model, textures, and sounds: Valve
- Model and texture edits: Zombie Survival Team and Zombie Panic! Source Team
- Compilation and sound edits: Grey-Echo (£cho/Ech0)

The model files were renamed and the sound files were relocated to server-specific
paths so they do not globally replace Counter-Strike: Source's stock knife assets.
The compiled model and materials use `models/shroudfire/claws/` paths.

## Invisant player model

The Invisant uses Zombie003 from the Original Default Zombie Skins Pack
(+Custom Edits): https://gamebanana.com/mods/567298

- Original archive: `default_css_zh_zm_zr_zombie_skins.zip`
- Original archive SHA-256: `2b9bfece2414854a59c9637fc686deecd47999c93d557d7561b8c6bf5767cb39`
- Original Half-Life 2 model and textures: Valve
- Counter-Strike: Source player-model port: robot
- Pack redistributor: Swiggity_Wiggy_

The six full-body model files were renamed from `models/player/zh/zh_zombie003.*`
to `models/shroudfire/player/zombie_v2.*` so they do not replace an existing
Zombie003 installation and use Shroudfire-specific download filenames.
The compiled model's internal name and material directory use the Shroudfire
namespace. Its material is
`materials/models/shroudfire/player/Zombie_Classic_sheet.vmt` and still refers
to textures already mounted from Half-Life 2.




The claw model material directory is `materials/models/shroudfire/claws/`.
Voice-file terms are in `sound/shroudfire/SOUNDS-LICENSE.md`.
