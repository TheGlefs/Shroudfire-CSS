# Connect query-cache addon

This optional native SourceMod addon lets the server browser's **Game** column display **Shroudfire** through `sv_gamedesc_override`. Its name remains Connect because it is a separate third-party extension. Shroudfire runs without it.

The source here comes from [UNLOZE's Connect fork](https://git.unloze.com/UNLOZE/sm-ext-connect), based on revision `2d022bf65b9b0a409a420fae66e4e311631cff55`, with the local CS:S query-cache fixes included directly. It accepts both A2S_INFO packet sizes, selects the UDP socket from the received packet, includes the Linux query-hook offset, and supplies the Linux x86 runtime helpers required by the SDK libraries. Attribution is retained in the source headers; the addon uses [GPL-3.0](LICENSE) with the Source engine exception retained in the source headers.

## Compile on Linux

This build targets a **32-bit CS:S Linux server**. A Windows `.dll` or a Linux x86-64 binary requires separate native compatibility work; renaming a binary does not change its platform. The SourcePawn Shroudfire plugin itself is platform-independent.

On Ubuntu/Debian, install the compiler and tooling:

```bash
sudo apt-get update
sudo apt-get install -y build-essential g++-multilib git python3 python3-venv binutils
```

From the Shroudfire repository root:

```bash
bash tools/build_connect.sh
```

The script downloads SourceMod, MetaMod:Source, the CS:S HL2SDK, SDK manifests, and AMBuild into `deps/connect/`. It creates an isolated Python environment, compiles the addon from **this repository's `connect/` source**, checks its ELF architecture, override cvar and unresolved runtime symbols, and writes:

```text
dist/connect/package/addons/sourcemod/extensions/connect.ext.2.css.so
dist/connect/package/addons/sourcemod/extensions/connect.autoload
dist/connect/package/addons/sourcemod/gamedata/connect2.games.txt
dist/connect/package/addons/sourcemod/scripting/include/connect.inc
dist/shroudfire-connect-linux-x86.zip
```

`CONNECT_DEPS_ROOT` can point at an existing dependency directory. `PYTHON` can select another Python executable. The script reuses existing checkouts without pulling changes. Its Linux x86 build has not been executed on the Windows authoring host; GitHub Actions includes the build job.

To configure manually after downloading dependencies and installing AMBuild:

```bash
mkdir -p build/connect
cd build/connect
python ../../connect/configure.py --enable-optimize --sdks=css --targets=x86 \
  --hl2sdk-root=../../deps/connect \
  --hl2sdk-manifest-path=../../deps/connect/hl2sdk-manifests \
  --sm-path=../../deps/connect/sourcemod \
  --mms-path=../../deps/connect/metamod-source
ambuild
```

The automatic script also adjusts SourceMod SDK delete declarations for GCC's `noexcept` requirements when needed. It does not change the installed game server.

## Install

1. Stop the server.
2. Copy `dist/connect/package/` contents into the server's `cstrike/`, preserving the `addons/sourcemod/` paths.
3. Ensure the extension binary, `connect2.games.txt`, and empty `connect.autoload` marker are present.
4. Start the server and run `sm exts list` and `sv_gamedesc_override`. When Shroudfire is enabled, the override should read `Shroudfire`.
5. Check the server browser's Game column. Fully restart the server after replacing a native extension.

To include the built addon in the complete Shroudfire release:

```bash
python tools/build.py --compiler /path/to/sourcemod/addons/sourcemod/scripting/spcomp64 \
  --connect-package dist/connect/package --fastdl
```

Use the query-cache build supplied here for this feature. A Connect build without `sv_gamedesc_override` cannot change the browser Game column for Shroudfire.
