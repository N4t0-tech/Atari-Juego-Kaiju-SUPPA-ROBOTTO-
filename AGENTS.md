# AGENTS.md — atari-juego

Atari 8-bit game in 6502 assembly (MADS assembler): a recreation of the Kaiju / "SUPPA ROBOTTO" game (original rules reverse-engineered from its cc65 binary) with our own code. No README, Makefile, CI, tests, or lint. Spanish labels/comments.

## Build & run

- Build: `mads main.asm -o:juego.xex` (MADS 2.1.7)
- Run: open `juego.xex` in Altirra (`altirra juego.xex`); control with joystick 1 + trigger
- No test suite — verification is: assemble clean + smoke-test in emulator
- `juego.xex` is a committed build artifact: rebuild it after any `.asm` change
- Some `.asm` files may be read-only on disk (check `ls -l`; `chmod u+w <file>` before editing)

## Architecture

- `main.asm` is the only entrypoint (`org $2000`, `run start`). It pulls in everything via `icl`; there is no linker step. Include order: `hardware.asm`, code (`jugador`, `bala`, `sonido`, `hud`, `nivel`, `enemigos`, `celulas`, `etapas`), `datos.asm`, `kaiju_graficos/niveles/robots.asm`, an `.if * > $6000` guard, then `kaiju_titulo.asm` **last** (it does `org $6000` / `org $7000`), then an `.if * > PMG` guard.
- Memory map: program + data $2000–<$6000 (currently ~$5924; the guard fails the build if it grows past $6000), title picture $6000–$6FEF + $7000–$7EAF, `PMG = $8000` (2 KB single-line), `FUENTE = $8800` (1 KB), `PANTALLA = $8C00` (24×40), `DLIST = $8FC0`, `DLIST_T = $9000` (title display list, built at runtime). All in `hardware.asm`.
- Game flow (`main.asm` + `etapas.asm`): `titulo` (wait for a fresh button press) → `nueva_partida` (etapa 0, energia 5, puntos 0) → for each stage: `pantalla_level` ("LEVEL m-n", 2 s) → `cargar_etapa` → frame loop. Loop exits: `celrest = 0` → `etapa++` (after 30: "YOU ARE SUPER PLAYER" → title); `fin = 1` (a cell was shot) → `energia--`, "TRY AGAIN", same stage again; `energia = 0` → "GAME OVER" → title. Energy and score carry over between stages.
- Stage `e` (0-29): map `kaiju_niveles[e % 6]`, robots + cells from `kaiju_dats[e]` (DAT0-29; DAT30 unused). World = e/6+1, stage-in-world = e%6+1.
- Frame loop: `esperar_paso` (waits `FRAMES_PASO` = 2 frames and bumps `npaso`; the cc65 original only managed ~1 loop per 2 frames, so every rule below counts loop steps, not frames) `-> mover_jugador -> animar_jugador -> dibujar_jugador -> actualizar_bala -> actualizar_enemigos -> dibujar_celulas -> contactos -> actualizar_sonido -> actualizar_hud`, then the exit checks.
- `hardware.asm` — all equates (shadow registers, GTIA/ANTIC, POKEY, ROM font, zero-page `ptr = $CB` / `ptr2 = $CD`, memory map). Add new hardware addresses here, not inline.
- `datos.asm` — all shared mutable state plus constant tables: player (`px/py`, `ddx/ddy`, `tick/paso/pose/espejo/andando`), bullet, stage state (`etapa`, `energia`, `invul`, `fin`, `cuenta`, `cnt11`), robot arrays `rob_*` (MAXROB 10), cell arrays `cel_*` (MAXCEL 18), `dir_dx/dir_dy`, `persigue`, sound tables `snd_*` (`SND_*`), `POSE_*`/`poses_lo/hi`, `filas_lo/hi`, `dl_datos`, `revtab`. New globals go here. `sprite`/`detalle` (old 12-row robot) and `vida_icono` are no longer drawn; kept for the editor.
- Screen: all 24 rows ANTIC 4 multicolor (no DLI), Kaiju font (`CHBAS = >FUENTE`), colors `KAIJU_COLOR0-2`; row 0 is the HUD. `modo_juego` / `modo_texto(A = font page)` / `modo_titulo` (`nivel.asm`) switch display list, font and colors; `poner_dl` writes `SDLSTL/H` right after a frame so the VBI never copies half an address. Messages use the ROM font (`CHBAS = $E0`) in ANTIC 4 like the original; "LEVEL m-n" uses the Kaiju font (letters $28-$2A, '-' $2B, digits $0A+n). Row r = lines 32+8r..39+8r, column c = HPOS 48+4c..51+4c.
- Title: `kaiju_titulo1` (lines 0-101) and `kaiju_titulo2` (102-195) in separate 4 KB blocks because a 40-byte ANTIC E line cannot cross a 4 KB boundary; `DLIST_T` has a second LMS, then one ANTIC 7 line with `kaiju_txt_titulo`.
- HUD (`hud.asm`, Kaiju layout): cols 0-9 energy icons ($06,$07 per point), cols 10-27 one $34 per remaining cell, cols 29-38 ten digits ($0A+d; first 4 always 0, last 6 from `puntos` BCD). Redrawn only when `hud_dirty`. `sumar_bcd` adds a single BCD digit (A) to `puntos+X` without `SED` (+1: X=2 A=$01; +10: X=2 A=$10; +100: X=1 A=$01).

## Game rules (from the original, verified in an emulator)

- Player: the Kaiju robot (6 poses from `kaiju_graficos.asm`, 8×24 single-line, P0 body `KAIJU_PCOLR0` + P1 outline `KAIJU_PCOLR1`, `GPRIOR = $31` OR-mixing). `dibujar_jugador` reads the pose via `ptr` and assumes each `_p1` sits right after its `_p0`; `datos.asm` checks it with `.if/.error`. Animation: idle → `QUIETO_IZQ`/`QUIETO_DER` by `ddx`; walking alternates A/B every 5 frames; straight up uses `ARRIBA`, otherwise `CAMINA` mirrored via `revtab` when `ddx<0`.
- Movement: 1 px horizontally / 2 lines vertically per frame, diagonal throttled (skip 1 of 4 steps via `npaso & 3`, returning before any move; keep this). X then Y applied separately and undone if `choca` (slides along walls). Player box = 8 columns × pose lines 2-21 (`caja_jugador` → `col0..col1`, `fil0..fil1`). `andando` drives the animation, so pushing a wall shows the idle pose.
- Tiles: `choca` treats 1-$13 and $34+ as solid; cells ($14-$1B) and enemies ($1C-$33, also inverse) are passable so `contactos` can handle touching them. Being blocked by the green border (tiles 2/3) calls `herir` (`borde_hiere`).
- Cells (`celulas.asm`): 2×2 chars, animated $18-$1B / $14-$17, swapping at `cuenta` 0 and 6 (12-frame cycle). Touching one collects it (+100). Shooting one sets `fin` (stage lost, see flow).
- Enemies (`enemigos.asm`): 2×2 chars at `rob_x/rob_y`, chars `rob_clase` ($9C inverse = COLOR3, or $1C) + 0/4 when facing left (dir 0-3) or + $10/$14 (dir 4-8), alternating with `rob_fase`. Updated every 11 frames; they move one cell every 2 updates (when `rob_fase` returns to 0) and only into 4 empty cells. Directions (measured in the original): 0 up-left, 1 up, 2 left, 3 down-left, 4 down-right, 5 down, 6 right, 7 up-right, 8 stop, 9 = destroyed. Patrol: `rob_dira` while `rob_paso < rob_pasos/2`, else `rob_dirb`; `rob_paso` wraps at `rob_pasos` (0 = keep current dir). If the player's center cell (`pcx/pcy`) is inside the watch zone (cols `rob_zx0..zx1`, rows `rob_zy0..zy1`) the robot switches to `rob_estado = 2` for good and chases with `persigue` (8-way toward the player). HP (`rob_vida`) by stage: 1 (e<6), 2 (e<18), 3. Killing one gives +10. Touching one costs 1 energy.
- Damage (`herir`): -1 energy unless `invul > 0`; then 50 frames of invulnerability.
- Bullet (missiles 0+1, one at a time, edge-triggered fire, `bdx = ddx`, `bdy = ddy*2`, diagonals ±3/±6, spawn `px+2, py+8`): checks its 4 corners (4×8 box, `bala_px/bala_py`, `bloque_en` → `bcol/bfil`, `ptr2/Y`): every blue block (5) touched breaks (+1) and the bullet dies; the first non-blue thing found decides: cell → `fin = 1`; enemy char → `golpear_enemigo`; border/brick → just dies. `HPOSM1 = bx`, `HPOSM0 = bx+2` (never the same X). COLOR3 ($26) is shared by the bullet and the inverse-char enemies.
- Differences from the original, on purpose: the chase uses a clean 8-way table (the original's chase compared the wrong axis in some cases); our player moves 2 lines vertically per frame (original 1); sounds are simplified (`SND_DISPARO/RECOGER/GOLPE`, channel 1); the original also charged energy when touching the top screen edge, which our border walls make unreachable.

## Gotchas

- Write via OS shadow registers (`SDMCTL`, `GPRIOR`, `PCOLR0/1`, `COLOR0-4`, `CHBAS`, `SDLSTL/H`), not direct GTIA/ANTIC registers, except `GRACTL/HPOSP0-3/HPOSM0/HPOSM1/PMBASE`.
- PMG layout (single-line, `SDMCTL = $3E`, positions in scanlines): missiles `PMG+$300`, P0 `+$400`, P1 `+$500`; P2/P3 unused (`HPOSP2/3 = 0`). The bullet is the 4 rows of `bala_icono`, each drawn on 2 lines. Erase-before-draw: `borrar_jugador`/`borrabala` run before moving/painting; `limpiar_pmg` clears all 2 KB (stage start, messages, title) and resets `activa`.
- Sound is a countdown: `sonar` (A = `SND_*`) sets `sndtim = 8`; `actualizar_sonido` must zero `AUDC1` at 0 or the tone drones. `modo_texto` silences it.
- Playfield limits are a safety net behind the walls: player x 50–200, y 40–198; bullet dies outside x 48–206, y 40–216.
- `icl` paths are relative to the project dir; keep all `.asm` files flat in the repo root.
- Long branches: `bala.asm` grew past the ±127 byte range once (`bcc pintabala`); use `bcs skip / jmp` when MADS reports "Branch out of range".

## Editor (`editor-sprite.html`)

- Visual sprite editor (open in any browser, no build step): 128-color Atari palette; the Kaiju poses (8×24, always multicolor) and `KAIJU_PCOLR0/1`; the old 12-row robot; the 11×3 lives icon (not drawn by the game any more); the 2×4 bullet (its color is COLOR3, shared with enemies); background/text brightness. Pencil/eraser/fill, undo, shift/mirror/copy, animation preview.
- Its "Prueba" scene is only a **preview** of movement, animation and shooting on the Kaiju maps (blocks, breakable blue blocks +1): no enemies, cells, stages or Kaiju HUD. It embeds copies of the 6 levels (`NIVELES_B64`), `kaiju_fuente` (`FUENTE_K_B64`) and `KAIJU_COLOR0-2` (`KAIJU_PF`); refresh them if those change.
- Export emits `.byte` blocks for `datos.asm`, a `lda/sta` color block for `iniciar` in `main.asm` (only COLOR3/COLOR4 and similar still apply; robot colors live in `KAIJU_PCOLR0/1`), and a `kaiju_graficos.asm` block (equates + `kaiju_<pose>_p0/_p1`). Apply the parts that changed when the user pastes it.
- Import finds byte blocks by label (order-independent) and colors by `lda #…`/`sta REG` pairs. Drafts autosave to `localStorage`. `INICIAL` (and `INICIAL.kaiju`) are hardcoded copies of the data: refresh them every time those bytes change.

## Kaiju resources (`kaiju_*.asm`)

- Converted from the Kaiju disk (`~/KAIJU CODIGO FUENTE/`, cc65-compiled — no C or asm source), verified byte-for-byte.
- `kaiju_graficos.asm`: `KAIJU_*` color equates, 7 poses (`sin_usar` unused), 4 shot frames (unused: we keep our missile bullet), `kaiju_fuente` (57 ANTIC 4 chars, codes $02-$3A, copied over the ROM font at `FUENTE+$10`), texts in screen codes terminated by **$FF** (space is code 0).
- `kaiju_niveles.asm`: 6 maps, `.byte x,y` player start + 23×40 chars (row 1 onward).
- `kaiju_robots.asm`: 31 `DATn` tables: `.byte robots, cells`, 16-byte robot records (+0 x, +1 y, +5 dirA, +6 dirB, +7 steps, +9 char base, +12/+13 watch rows, +14/+15 watch columns; other bytes unused by the original), then cells as (x, y) pairs.
- `kaiju_titulo.asm` + `kaiju_titulo.mic` (binary via `ins`): 196 lines of the 160×240 ANTIC E picture, split at $6000/$7000.
