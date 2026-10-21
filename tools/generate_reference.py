"""Generate command/settings references, example config and matching HTML guide pages."""
from pathlib import Path
import re
import html

ROOT = Path(__file__).resolve().parents[1]
SCRIPTING = ROOT / 'addons/sourcemod/scripting'
CHAT = [
    ('help', 'Open the gameplay guide.'),
    ('menu', 'Open the upgrade menu for your current role.'),
    ('upgrade', 'Open the upgrade guide.'),
    ('reset', "Refund your current role's upgrades and open the upgrade menu."),
    ('rank', "Show your current team's rank and combat statistics; 9 switches teams and 0 exits."),
    ('audio', 'Open your audio settings menu.'),
    ('bugs', 'Open the known bugs guide.'),
    ('cheat', 'Open the visibility and anti-cheat guide.'),
    ('close', 'Close an open upgrade menu or guide.'),
    ('1–8', 'Buy the corresponding upgrade while the upgrade menu is open.')
]

def declarations():
    main = (SCRIPTING / 'shroudfire.sp').read_text(encoding='utf-8')
    parity = (SCRIPTING / 'include/shroudfire/parity.inc').read_text(encoding='utf-8')
    settings = (SCRIPTING / 'include/shroudfire/settings.inc').read_text(encoding='utf-8')
    commands = []
    pattern = r'Reg(Admin|Console)Cmd\(\s*"(sf_\w+)",\s*(\w+),\s*(?:(ADMFLAG_\w+),\s*)?"([^"]+)"\s*\);'
    for kind, name, callback, flag, description in re.findall(pattern, main + '\n' + parity):
        access = 'Root admin' if flag == 'ADMFLAG_ROOT' else 'Generic admin' if flag else 'Player'
        if name == 'sf_update_notice':
            access = 'Server console only'
        elif name not in ['sf_level', 'sf_invisant', 'sf_armitive', 'sf_observe']:
            access += ' or server console'
        commands.append(dict(name=name, access=access, description=description))
    cvars = []
    pattern = r'CreateConVar\("(sf_\w+)", "([^"]*)", "([^"]*)", (FCVAR_\w+)(?:, true, ([\d.]+), true, ([\d.]+))?\)'
    for name, default, description, flags, minimum, maximum in re.findall(pattern, settings):
        cvars.append(dict(name=name, default=default, description=description, minimum=minimum, maximum=maximum))
    if len(commands) != 10 or len(cvars) != 130:
        raise ValueError(f'Unexpected reference coverage: {len(commands)} commands, {len(cvars)} settings')
    return commands, cvars

def generate():
    commands, cvars = declarations()
    prose = ('# Shroudfire commands and settings\n\n'
             'Generated from the SourceMod command registrations and cvar descriptions. '
             'Enter `sf_` commands in the console; type menu shortcuts in chat without a prefix. '
             'Administrator access uses SourceMod permissions.\n\n'
             '## Chat shortcuts\n\n| Chat text | Action |\n| --- | --- |\n')
    prose += ''.join(f'| `{name}` | {description} |\n' for name, description in CHAT)
    prose += ('\n`upgrades` is a compatibility alias for `upgrade`. Matching ignores capitalization and surrounding whitespace. '
              'Native menus use SourceMod number keys and work alive or dead. The upgrade menu fits on one page: 1–8 buy, 9 resets points, and 0 exits. Rank shows the current team with the other team on 9; guides use next/back/exit where shown. '
              'Chat digits always follow the eight-upgrade order shown by `menu`.\n\n'
              '## Console commands\n\n| Command | Access | Description |\n| --- | --- | --- |\n')
    usage = {'sf_cvar': ' <name> [value]', 'sf_nextmap': ' [map\\|reset]',
             'sf_setlevel': ' <player> <invisant\\|armitive> <level>', 'sf_observe': ' [player]',
             'sf_update_notice': ' <seconds>'}
    prose += ''.join(f'| `{c["name"]}{usage.get(c["name"], "")}` | {c["access"]} | {c["description"]} |\n' for c in commands)
    prose += ('\n`sf_setlevel` accepts levels 0–40 and SourceMod player targets. '
              '`sf_cvar` reads/writes plugin and stock cvars, hides protected values and logs changes. '
              '`sf_nextmap` validates installed maps and sets a one-map override; reset returns to the rotation. '
              '`sf_update_notice` accepts 1–3600 seconds and sends a notice only. '
              '`sf_invisant`, `sf_armitive` and `sf_observe` require a connected administrator. '
              'Observation also requires `sf_admin_spectate 1`.\n\n'
              '## Server settings\n\nCompiled defaults are listed below. The supplied config sets `sf_enable 1` '
              'and `sf_silent_local_movement 1`; other values match these defaults. '
              'Put persistent changes in `cfg/sourcemod/shroudfire.cfg`.\n\n'
              '| Setting | Default | Range | Description |\n| --- | --- | --- | --- |\n')
    for c in cvars:
        bounds = f'{c["minimum"]}–{c["maximum"]}' if c['minimum'] else 'String'
        prose += f'| `{c["name"]}` | `{c["default"]}` | {bounds} | {c["description"]} |\n'
    prose += ('\nGlobal chat reaches every human, including dead players and spectators. Team chat stays within the sender\'s role. '
              'Invisant radio, flashlight and spray commands are blocked; their buying is disabled. '
              'Armitive buying follows normal checks and sf_armitive_blocked_weapons, including autobuy and rebuy. '
              'Suicide/fatal falls forfeit next-round Invisant eligibility. '
              'Post-round kills change no XP, rankings, streaks or priority.\n')
    prose += '\n## Audio preferences\n\n`audio` opens all eight toggles on one page: Round Start, Round End, Kill Streak, Starvation, Timeout, Camping, AFK, and Menu. Camping warning voices are independent of AFK. All settings default ON and persist between sessions.\n\n## Knife damage and purchases\n\n`sf_knife_damage_min` and `sf_knife_damage_max` define an inclusive damage range. Reversed bounds use their lower and higher values; identical values give fixed damage. Native and extended Invisant claw hits roll damage once.\n\n`sf_armitive_blocked_weapons` accepts comma-separated or whitespace-separated CS:S weapon names and purchase aliases, case-insensitively, with an optional `weapon_` prefix. The default blocks `m249`; an empty string permits all purchases. For example, `sf_cvar sf_armitive_blocked_weapons "m249,awp"` blocks those weapons. Unknown names and CS2-only weapons are ignored and reported in the server console. CSS names include `m4a1`, `mp5navy`, `m3`, `sg552`, and `sg550`; grenades and equipment purchase aliases are supported. Restrictions affect buying, autobuy and rebuy, while pickups and spawn loadouts retain their existing rules.\n\n## Starvation\n\nBoth the live-round delay and time without dealing or taking damage must expire before starvation starts. The first tick is immediate. Defaults: 60 seconds after freeze time, 45 seconds without combat, 1 HP every second, then 3 HP every second after 20 seconds of uninterrupted starvation. A 100-HP Invisant starting at 1:00 dies with roughly 0:15 left in a two-minute round. Fractional tick intervals run every game frame; delayed frames cause no catch-up damage burst. Damage dealt or taken resets starvation and its acceleration; starvation damage itself does not reset it. Solo play and rounds without living Armitive do not cause starvation.\n\n'
    prose += '## Automatic chat hints\n\nAutomatic chat hints use the CS2 wording with a green prefix and brown command names. For example: `[Shroudfire] Type upgrade to learn about them`.\n\n'
    (ROOT / 'COMMANDS.md').write_bytes((prose.rstrip() + '\n').encode('utf-8'))
    config = '// Shroudfire gameplay configuration. Generated from settings.inc.\n// Enable custom voices only after client downloads work.\n'
    for c in cvars:
        value = '1' if c['name'] in ['sf_enable', 'sf_silent_local_movement'] else c['default']
        config += f'\n// {c["description"]}\n{c["name"]} "{value}"\n'
    (ROOT / 'cfg/sourcemod/shroudfire.cfg').write_bytes(config.encode('utf-8'))
    # Match the authored MOTD pages; regenerate only the command reference.
    help_page = (ROOT / 'game-assets/shroudfire/help.html').read_text(encoding='utf-8')
    css = re.search(r'<style>(.*?)</style>', help_page, re.S).group(1).rstrip()
    css += "\n        table { border-collapse: collapse; width: 100%; margin: 1.5vmin 0; }\n"
    css += "        td, th { border: 1px solid #403523; padding: 1vmin; text-align: left; }\n"
    def page(title, content):
        content = content.replace('</tr>', '</tr>\n').replace('</table>', '</table>\n')
        return ('<!doctype html>\n<html>\n<head>\n    <meta charset="utf-8">\n'
                f'    <title>{title}</title>\n    <style>{css}    </style>\n</head>\n<body>\n'
                '    <div class="content">\n' + content + '\n    </div>\n</body>\n</html>\n')
    esc = html.escape
    commands_html = '<h2 class="heading-guide">Shroudfire commands and settings</h2><h2>Chat shortcuts</h2><table><tr><th>Chat text</th><th>Action</th></tr>'
    commands_html += ''.join(f'<tr><td><code>{esc(n)}</code></td><td>{esc(d)}</td></tr>' for n,d in CHAT)
    commands_html += '</table><p>The upgrade menu shows all eight upgrades on one page: 1–8 buy, 9 resets points, and 0 exits. Chat digits 1–8 also buy while the menu is open.</p><h2>Console commands</h2><table><tr><th>Command</th><th>Access</th><th>Description</th></tr>'
    commands_html += ''.join(f'<tr><td><code>{esc(c["name"] + usage.get(c["name"], "").replace(chr(92), ""))}</code></td><td>{esc(c["access"])}</td><td>{esc(c["description"])}</td></tr>' for c in commands)
    commands_html += '</table><h2>Settings</h2><p>The example config enables the plugin and local movement silencing. Custom voices stay off until downloads work.</p><table><tr><th>Setting</th><th>Default</th><th>Description</th></tr>'
    commands_html += ''.join(f'<tr><td><code>{esc(c["name"])}</code></td><td>{esc(c["default"])}</td><td>{esc(c["description"])}</td></tr>' for c in cvars)
    commands_html += '</table>'
    commands_html += '<h2>Automatic chat hints</h2><p>Hints use the CS2 wording with a green prefix and brown command names. For example: [Shroudfire] Type upgrade to learn about them.</p><h2>Audio preferences</h2><p>Eight persistent toggles appear on one page: Round Start, Round End, Kill Streak, Starvation, Timeout, Camping, AFK, Menu. Camping is independent of AFK. All categories default ON.</p><h2>Knife damage and purchases</h2><p>Knife damage rolls once per hit within the inclusive configured range; reversed bounds are accepted and equal bounds give fixed damage. sf_armitive_blocked_weapons accepts comma-separated or whitespace-separated CS:S names and aliases, case-insensitively, with an optional weapon_ prefix. The default blocks m249; an empty string allows all purchases. Buy menu, console, autobuy and rebuy are covered; pickups and spawn loadouts follow existing rules. Unknown names and CS2-only weapons are reported and ignored.</p><h2>Starvation</h2><p>Both the live-round and combat delays must expire. Defaults: 60 seconds after freeze time, 45 seconds without dealing or taking damage, 1 HP each second, then 3 HP each second after 20 seconds of continuous starvation. A 100-HP Invisant starting at 1:00 dies with roughly 0:15 left in a two-minute round. The first tick is immediate. Fractional intervals run each game frame without catch-up damage bursts. Combat resets starvation and acceleration. Solo play and rounds without living Armitive do not cause starvation.</p>'
    html_dir = ROOT / 'game-assets/shroudfire'
    html_dir.mkdir(exist_ok=True)
    result = page('Shroudfire commands', commands_html)
    (html_dir / 'commands.html').write_bytes(result.encode('utf-8'))

if __name__ == '__main__':
    generate()
