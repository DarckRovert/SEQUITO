# 💬 Lista Completa de Comandos - Sequito

**Versión:** 8.0.0 (Gold Master)  
**Autor:** DarckRovert (Ingame: Eljesuita)

---

## 📝 Comandos Principales

Sequito acepta dos prefijos de comando:
- `/sequito [comando]`
- `/seq [comando]` (atajo)

---

## 🆘 Ayuda e Información

### `/sequito help`
**Alias:** `/seq help`, `/sequito ?`

**Descripción:** Muestra la lista de comandos disponibles.

**Ejemplo:**
```
/sequito help
```

---

### `/sequito info`
**Alias:** `/seq info`

**Descripción:** Muestra información sobre tu personaje (clase, raza, especialización, nivel).

**Ejemplo:**
```
/sequito info
```

**Salida:**
```
Clase: Warlock (Brujo)
Raza: Orc (Orco)
Especialización: Affliction
Nivel: 80
Recurso: Mana (15420/18500)
```

---

### `/sequito spec`
**Alias:** `/seq spec`

**Descripción:** Muestra información detallada de tu especialización actual.

**Ejemplo:**
```
/sequito spec
```

**Salida:**
```
Especialización Activa: 1 (Affliction)
Grupo de Talentos: 1 de 2
Rol: DPS
```

---

## 🔧 Generación de Macros

### `/sequito macros`
**Alias:** `/seq macros`, `/sequito macro`

**Descripción:** Genera macros personalizadas estilo **Necrosis** para tu clase y especialización actual.

**Ejemplo:**
```
/sequito macros
```

**Salida:**
```
Sequito: Regenerando macros (Necrosis Edition Final) para WARLOCK...
✅ Macro creada: SeqStart
✅ Macro creada: SeqHeal
✅ Macro creada: SeqPet
✅ Macro creada: SeqDispel
✅ Macro creada: SeqRot
✅ Macro creada: SeqBurst
✅ Macro creada: SeqRacial
✅ Macro creada: SeqMount
Macros generadas exitosamente!
```

**Notas:**
- Las macros se crean con nombres cortos como `SeqStart`, `SeqPet`.
- Si ya existen macros con el mismo nombre, se sobrescribirán.
- **Auto-Update**: Si tienes activado `specauto`, esto ocurre automáticamente al cambiar talentos.

---

### `/sequito specauto`
**Alias:** `/seq specauto`, `/sequito autospec`

**Descripción:** Activa/desactiva la regeneración automática de macros al cambiar de especialización.

**Ejemplo:**
```
/sequito specauto
```

**Salida:**
```
Auto-actualización de macros: ACTIVADA
```

---

## 👥 Comandos de Raid

### `/sequito raid`
**Alias:** `/seq raid`, `/sequito r`

**Descripción:** Muestra la composición actual de la raid (clases y especializaciones).

*(Ver USAGE.md para más detalles)*

---

### `/sequito class`
**Alias:** `/seq class`, `/sequito classes`

**Descripción:** Muestra el conteo de clases en la raid.

---

### `/sequito buffs`
**Alias:** `/seq buffs`, `/sequito buff`

**Descripción:** Escanea la raid en busca de buffs faltantes.

---

### `/sequito focus [nombre]`
**Alias:** `/seq focus [nombre]`, `/sequito f [nombre]`

**Descripción:** Envía una orden táctica a la raid para enfocar un objetivo específico.

**Ejemplo:**
```
/sequito focus Ragnaros
```

---

### `/sequito alpha`
**Alias:** `/seq alpha`, `/sequito burst`

**Descripción:** Envía una orden de "Alpha Strike" (usar todos los cooldowns de DPS).

---

## 📊 Panel de Raid

### `/sequito panel`
**Alias:** `/seq panel`, `/sequito p`

**Descripción:** Abre/cierra el panel visual de raid.

---

### `/sequito lock`
**Alias:** `/seq lock`

**Descripción:** Bloquea/desbloquea la posición del panel de raid.

---

### `/sequito reset`
**Alias:** `/seq reset`

**Descripción:** Restaura TODA la configuración del addon a los valores por defecto y recarga la interfaz.

---

### `/sequito resetpos`
**Alias:** `/seq resetpos`

**Descripción:** Reinicia solo la posición del panel de raid y la esfera al centro de la pantalla.

---

## 🐎 Sistema de Monturas

### `/sequito mounts`
**Alias:** `/seq mounts`, `/sequito monturas`

**Descripción:** Lista todas las monturas disponibles y tus monturas favoritas configuradas.

**Ejemplo:**
```
/sequito mounts
```

---

### `/sequito setflying [nombre]` / `/sequito setground [nombre]`
Configura tus monturas favoritas para la macro `SeqMount`.

---

## ⚙️ Configuración

### `/sequito options`
**Alias:** `/seq options`, `/sequito config`, `/seq opt`

**Descripción:** Abre el panel de configuración del addon.

---

## 📝 Atajos de Comandos

| Comando Completo | Atajo | Descripción |
|-----------------|-------|-------------|
| `/sequito help` | `/seq ?` | Ayuda |
| `/sequito info` | `/seq i` | Info del personaje |
| `/sequito macros` | `/seq m` | Generar macros |
| `/sequito raid` | `/seq r` | Composición de raid |
| `/sequito panel` | `/seq p` | Panel de raid |
| `/sequito focus` | `/seq f` | Orden de focus |
| `/sequito options` | `/seq opt` | Configuración |
| `/sequito combat` | `/seq dps` | Resumen de combate |
| `/sequito version` | `/seq v` | Versión |

---

## 📊 CooldownMonitor - Monitor de CDs (v7.2.0)

### `/sequito cooldowns`
**Alias:** `/seq cd`
**Descripción:** Abre/cierra el panel de cooldowns del raid.

### `/sequito cd bres`
**Descripción:** Anuncia los Battle Res disponibles en el raid.
**Ejemplo de salida:**
```
[Sequito] BRES disponibles: Druid1 (Rebirth), Warlock1 (Soulstone)
```

### `/sequito cd lust`
**Descripción:** Anuncia si Heroism/Bloodlust está disponible.

### `/sequito cd raid`
**Descripción:** Anuncia todos los Raid CDs disponibles.

---

## 🎯 Assignments - Asignaciones (v7.2.0)

### `/sequito assign`
**Alias:** `/seq as`
**Descripción:** Abre el panel de asignaciones.

### `/sequito assign interrupts`
**Descripción:** Auto-asigna rotación de interrupts basada en clases disponibles.
**Ejemplo de salida:**
```
[Sequito] Rotación de Interrupts: 1. Shaman1 → 2. Rogue1 → 3. Warrior1
```

### `/sequito assign tanks`
**Descripción:** Abre el panel para asignar tanks a objetivos.

### `/sequito assign announce`
**Descripción:** Anuncia todas las asignaciones actuales al raid.

### `/sequito assign clear`
**Descripción:** Limpia todas las asignaciones.

### `/sequito assign sync`
**Descripción:** Sincroniza asignaciones con otros usuarios de Sequito.

---

## ✅ ReadyChecker - Chequeo Pre-Pull (v7.2.0)

### `/sequito readycheck`
**Alias:** `/seq rc`
**Descripción:** Abre el panel de ready check mejorado y escanea el raid.

### `/sequito readycheck full`
**Descripción:** Escanea y anuncia problemas al raid.
**Ejemplo de salida:**
```
[Sequito] Problemas detectados:
  - Rogue1: Veneno MH, Veneno OH
  - Warlock1: Sin Flask
  - Mage1: Mana: 65%
```

### `/sequito readycheck scan`
**Descripción:** Solo escanea sin abrir panel.

---

## 🎯 RaidAssist (v7.1.0)

### `/sequito ra` o `/sequito raidassist`
**Descripción:** Abre el panel principal de RaidAssist.

### `/sequito raleader`
**Descripción:** Abre el panel compacto de Raid Leader.

### `/sequito pull [segundos]`
**Descripción:** Inicia un pull timer sincronizado.
**Ejemplo:** `/sequito pull 10`

### `/sequito phase [número]`
**Descripción:** Anuncia una fase de boss a todo el raid.
**Ejemplo:** `/sequito phase 2`

### `/sequito checkcons`
**Descripción:** Revisa consumibles (flask/food) de todos los miembros.

### `/sequito wipes`
**Descripción:** Muestra el contador de wipes de la sesión.

### `/sequito resetwipes`
**Descripción:** Reinicia el contador de wipes.

### `/sequito mode [farm/progression]`
**Descripción:** Cambia el modo de operación.

### `/sequito wipehistory`
**Descripción:** Muestra el historial completo de wipes con estadísticas.

### `/sequito clearwipes`
**Descripción:** Borra el historial de wipes guardado.

### `/sequito alert [mensaje]`
**Descripción:** Muestra una alerta de prueba.

### `/sequito alertpos [top/center/bottom]`
**Descripción:** Cambia la posición de las alertas en pantalla.

---

## 🔄 MacroSync - Macros Compartidos (v7.1.0)

### `/sequito macro share <nombre>`
**Descripción:** Comparte un macro con tu grupo/raid.
**Ejemplo:** `/sequito macro share SeqBurst`

### `/sequito macro list`
**Descripción:** Lista los macros compartidos que has recibido.

### `/sequito macro import <nombre>`
**Descripción:** Importa un macro compartido a tus macros.
**Ejemplo:** `/sequito macro import SeqBurst`

### `/sequito macro library`
**Descripción:** Muestra la biblioteca de macros para tu clase/spec.

### `/sequito macro libraryall`
**Descripción:** Muestra toda la biblioteca de macros para tu clase.

### `/sequito macro getlib <nombre>`
**Descripción:** Importa un macro de la biblioteca.
**Ejemplo:** `/sequito macro getlib SeqDotAll`

### `/sequito macro getall`
**Descripción:** Importa todos los macros de la biblioteca para tu spec.

### `/sequito macro request`
**Descripción:** Solicita la lista de macros disponibles del grupo.

### `/sequito macro get <nombre> <jugador>`
**Descripción:** Solicita un macro específico de otro jugador.
**Ejemplo:** `/sequito macro get SeqBurst Eljesuita`

---

## ⚔️ TrinketTracker - PvP (NUEVO v7.2.0)

### `/sequito trinkets`
**Alias:** `/seq tt`
**Descripción:** Abre/cierra el panel de tracking de trinkets enemigos.

### `/sequito trinkets clear`
**Descripción:** Limpia todos los datos del tracker.

### `/sequito trinkets announce`
**Descripción:** Anuncia el estado de todos los trinkets enemigos al grupo.
**Ejemplo de salida:**
```
[Sequito] Trinkets en CD: Enemigo1 (1:45), Enemigo2 (0:30)
[Sequito] Trinkets LISTOS: Enemigo3, Enemigo4
```

---

## 💀 WipeAnalyzer - Análisis de Wipes (NUEVO v7.2.0)

### `/sequito analyze`
**Alias:** `/seq wa`
**Descripción:** Muestra el análisis del último wipe detectado.

### `/sequito analyze announce`
**Descripción:** Anuncia el análisis del wipe al raid/party.
**Ejemplo de salida:**
```
[Sequito] === ANÁLISIS DE WIPE ===
Primera muerte: Jugador1 (15.3s) - Shadow Bolt de Boss
Sin poción/healthstone: Jugador2, Jugador3
Total muertes: 8 | Interrupts: 5
```

### `/sequito wipehistory`
**Descripción:** Muestra el historial de wipes de la sesión.

### `/sequito clearwipes`
**Descripción:** Limpia el historial de wipes.

---

## 📊 Tabla de Nuevos Comandos v7.2.0

| Comando | Atajo | Descripción |
|---------|-------|-------------|
| `/sequito trinkets` | `/seq tt` | Panel de trinkets PvP |
| `/sequito trinkets clear` | - | Limpiar tracker |
| `/sequito trinkets announce` | - | Anunciar trinkets |
| `/sequito analyze` | `/seq wa` | Análisis de wipe |
| `/sequito analyze announce` | - | Anunciar análisis |
| `/sequito wipehistory` | - | Historial de wipes |
| `/sequito clearwipes` | - | Limpiar historial |

---

## ⚔️ Comandos PvP v8.0.0

### `/sequito focus`
**Alias:** `/seq ff`
**Descripción:** Abre el panel de FocusFire para llamadas de target.

### `/sequito focus call`
**Descripción:** Llama al target actual como objetivo de focus fire.

### `/sequito cc`
**Alias:** `/seq cc`
**Descripción:** Abre el panel de CCCoordinator.

### `/sequito cc assign <jugador> <target>`
**Descripción:** Asigna un CC a un jugador para un target específico.

### `/sequito healers`
**Alias:** `/seq ht`
**Descripción:** Abre el panel de HealerTracker.

### `/sequito defensive`
**Alias:** `/seq def`
**Descripción:** Abre el panel de DefensiveAlerts.

### `/sequito defensive peel`
**Descripción:** Anuncia que necesitas peel.

### `/sequito defensive heal`
**Descripción:** Anuncia que necesitas heal.

---

## 🏰 Comandos Dungeons v8.0.0

### `/sequito pullguide`
**Alias:** `/seq pg`
**Descripción:** Abre el panel de PullGuide.

### `/sequito pullguide mark`
**Descripción:** Auto-marca el pack actual.

### `/sequito dungeon`
**Alias:** `/seq dt`
**Descripción:** Abre el panel de DungeonTimer.

### `/sequito loot`
**Alias:** `/seq lc`
**Descripción:** Abre el panel de LootCouncil.

### `/sequito loot start`
**Descripción:** Inicia una sesión de loot council.

---

## 👥 Comandos Generales v8.0.0

### `/sequito notes add <jugador> <texto>`
**Alias:** `/seq pn add`
**Descripción:** Guarda una nota sobre un jugador.

### `/sequito build save <nombre>`
**Descripción:** Guarda tu build actual con un nombre.

### `/sequito build load <nombre>`
**Descripción:** Carga un build guardado.

### `/sequito build share <nombre>`
**Descripción:** Comparte un build con el grupo.

### `/sequito calendar`
**Alias:** `/seq cal`
**Descripción:** Abre el panel de EventCalendar.

### `/sequito stats`
**Alias:** `/seq ps`
**Descripción:** Muestra tus estadísticas de rendimiento.

### `/sequito poll "<pregunta>" opcion1 opcion2 ...`
**Alias:** `/seq vote`
**Descripción:** Crea una votación rápida.
**Ejemplo:**
```
/sequito poll "¿Seguimos o paramos?" Seguir Parar
```

### `/sequito version`
**Alias:** `/seq ver`
**Descripción:** Verifica versiones de Sequito en el grupo.

### `/sequito whisper <template>`
**Alias:** `/seq qw`
**Descripción:** Envía un mensaje rápido predefinido.
**Templates disponibles:** inv, afk, summon, ready, brb

---

## 📊 Tabla de Nuevos Comandos v8.0.0

| Comando | Atajo | Descripción |
|---------|-------|-------------|
| `/sequito focus` | `/seq ff` | Panel de FocusFire |
| `/sequito cc` | `/seq cc` | Panel de CCCoordinator |
| `/sequito healers` | `/seq ht` | Panel de HealerTracker |
| `/sequito defensive` | `/seq def` | Panel de DefensiveAlerts |
| `/sequito pullguide` | `/seq pg` | Panel de PullGuide |
| `/sequito dungeon` | `/seq dt` | Panel de DungeonTimer |
| `/sequito loot` | `/seq lc` | Panel de LootCouncil |
| `/sequito notes` | `/seq pn` | Notas de jugadores |
| `/sequito build` | `/seq bm` | Gestor de builds |
| `/sequito calendar` | `/seq cal` | Calendario de eventos |
| `/sequito stats` | `/seq ps` | Estadísticas de rendimiento |
| `/sequito poll` | `/seq vote` | Sistema de votaciones |
| `/sequito version` | `/seq ver` | Verificar versiones |
| `/sequito whisper` | `/seq qw` | Mensajes rápidos |

---

**Creado por DarckRovert (Ingame: Eljesuita)**
