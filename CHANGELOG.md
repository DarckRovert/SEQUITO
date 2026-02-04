# 📝# Changelog

## v7.3.0 - Implementación Completa (2026-02-02)

### 🚀 Novedades - 14 Módulos Nuevos

#### ⚔️ Módulos PvP (4)
*   **FocusFire.lua**: Sistema de llamadas de target sincronizadas.
    *   Marca objetivo y sincroniza con el grupo.
    *   Alertas visuales/sonoras para focus fire.
    *   Muestra % de vida del target a todo el grupo.
    *   Comando: `/sequito focus`

*   **CCCoordinator.lua**: Coordinador de CC con DR tracking.
    *   Asignar CCs a objetivos específicos.
    *   Tracking de Diminishing Returns por categoría.
    *   Alertas cuando alguien rompe CC.
    *   Comando: `/sequito cc`

*   **HealerTracker.lua**: Monitor de healers enemigos.
    *   Trackea mana de healers enemigos.
    *   Alerta cuando healer está bajo de mana.
    *   Panel visual con barras de mana.
    *   Comando: `/sequito healers`

*   **DefensiveAlerts.lua**: Llamadas de defensivos.
    *   Botones rápidos para "NECESITO PEEL/HEAL/DISPEL".
    *   El grupo ve quién necesita ayuda.
    *   Keybinds configurables.
    *   Comando: `/sequito defensive`

#### 🏰 Módulos Dungeons (3)
*   **PullGuide.lua**: Guía de pulls con marcado automático.
    *   Auto-marca orden de kill (Skull, X, etc.).
    *   Prioriza por tipo (healer > caster > melee).
    *   Sugiere CCs para packs grandes.
    *   Comando: `/sequito pull`

*   **DungeonTimer.lua**: Timer de Heroic/Daily.
    *   Muestra tiempo restante para reset.
    *   Lista de dungeons completadas hoy.
    *   Recordatorios de reset.
    *   Comando: `/sequito dungeon`

*   **LootCouncil.lua**: Sistema de Loot Council.
    *   Votación rápida de loot.
    *   Muestra quién necesita qué item.
    *   Historial de loot distribuido.
    *   Comando: `/sequito loot`

#### 👥 Módulos Generales (7)
*   **PlayerNotes.lua**: Sistema de notas de jugadores.
    *   Guardar notas sobre jugadores.
    *   Compartir notas con el guild.
    *   Comando: `/sequito note <jugador> <texto>`

*   **BuildManager.lua**: Gestor de builds/specs.
    *   Guardar configuraciones de talentos + glyphs.
    *   Cambiar rápidamente entre builds.
    *   Compartir builds con el guild.
    *   Comando: `/sequito build save/load/share`

*   **EventCalendar.lua**: Calendario de eventos integrado.
    *   Muestra próximos eventos del guild.
    *   Confirmar asistencia desde el addon.
    *   Recordatorios antes del evento.
    *   Comando: `/sequito calendar`

*   **PerformanceStats.lua**: Estadísticas de rendimiento.
    *   Trackea DPS/HPS promedio por boss.
    *   Compara con raids anteriores.
    *   Historial de rendimiento.
    *   Comando: `/sequito stats`

*   **VotingSystem.lua**: Sistema de votaciones.
    *   Crear votaciones rápidas.
    *   Resultados en tiempo real.
    *   Comando: `/sequito poll "¿Pregunta?" opcion1 opcion2`

*   **VersionSync.lua**: Sincronización de versiones.
    *   Detecta versiones de Sequito en el grupo.
    *   Alerta si alguien tiene versión desactualizada.
    *   Comando: `/sequito version`

*   **QuickWhisper.lua**: Mensajes rápidos predefinidos.
    *   Templates: "Inv please", "AFK 5 min", "Need summon".
    *   Keybinds configurables.
    *   Comando: `/sequito whisper`

### 📊 Total del Addon
*   **38 módulos** funcionales
*   Soporte completo para **PvE** (Raids/Dungeons) y **PvP**
*   Sistema modular extensible

---

## v7.2.0 - TrinketTracker & WipeAnalyzer (2026-02-02)

### 🚀 Novedades

#### ⚔️ TrinketTracker (PvP)
*   **Tracker de Trinkets Enemigos**: Detecta cuando un enemigo usa su trinket PvP.
*   **Timer de 2 Minutos**: Muestra tiempo restante hasta que el trinket vuelva.
*   **Panel Flotante**: UI dedicada con estado de todos los trinkets enemigos.
*   **Integración con Nameplates**: Iconos sobre nameplates mostrando estado del trinket.
*   **Alertas Automáticas**: Notificación visual/sonora al detectar uso de trinket.
*   **Anuncios en Arena**: Anuncia automáticamente en party cuando un enemigo usa trinket.

#### 💀 WipeAnalyzer (PvE)
*   **Análisis de Wipes**: Detecta automáticamente cuando ocurre un wipe.
*   **Primera Muerte**: Identifica quién murió primero y por qué habilidad.
*   **Verificación de Consumibles**: Lista jugadores que murieron sin usar poción/healthstone.
*   **Tracking de Interrupts**: Registra interrupts exitosos durante el combate.
*   **Panel de Análisis**: UI con resumen completo del wipe.
*   **Historial de Wipes**: Guarda historial por sesión.

#### 📊 Módulos Existentes Activados
*   **CooldownMonitor**: Ahora cargado en el .toc - Monitor de CDs del raid.
*   **Assignments**: Ahora cargado en el .toc - Sistema de asignaciones.
*   **ReadyChecker**: Ahora cargado en el .toc - Chequeo pre-pull mejorado.

### 📝 Nuevos Comandos
*   `/sequito trinkets` - Panel de trinkets PvP
*   `/sequito trinkets clear` - Limpiar tracker
*   `/sequito trinkets announce` - Anunciar estado de trinkets
*   `/sequito analyze` - Análisis del último wipe
*   `/sequito cooldowns` - Panel de CDs del raid
*   `/sequito assign` - Panel de asignaciones
*   `/sequito assign interrupts` - Auto-asignar rotación de interrupts
*   `/sequito readycheck` - Chequeo pre-pull mejorado

### 🛠️ Mejoras
*   **Documentación Actualizada**: MODULES.md, COMMANDS.md y README.md actualizados.
*   **TOC Completo**: Todos los 24 módulos ahora están correctamente listados.

---

## v7.1.0 - RaidAssist Enhanced (2026-02-02)

### 🚀 Novedades
*   **Sistema de Alertas Personalizables**: Alertas visuales configurables con posición (TOP/CENTER/BOTTOM).
*   **Historial de Wipes**: Estadísticas detalladas guardadas en SavedVariables por zona/boss.
*   **MacroSync Module**: Nuevo sistema de macros compartidos entre usuarios.
    *   Sincronización de macros via addon messages.
    *   Biblioteca de macros predefinidos por clase (10 clases, 3-5 macros cada una).
    *   Sistema de rating por estrellas.
    *   Filtrado por especialización.
*   **Integración Visual con Esfera**: Botón satélite dedicado para RaidAssist.
*   **Indicador de Estado**: La esfera muestra estado de raid/party visualmente.

### 🐛 Correcciones
*   **C_Timer.After**: Reemplazado por timer manual compatible con 3.3.5a.
*   **SpellData.lua**: Agregado campo `type` a todos los consumibles.
*   **Paladin Interrupt**: Eliminado Rebuke (no existe en 3.3.5).
*   **Versión sincronizada**: TOC y Sequito.lua ahora coinciden en v7.1.0.

### 📝 Nuevos Comandos
*   `/sequito wipehistory` - Ver historial de wipes
*   `/sequito clearwipes` - Limpiar historial
*   `/sequito alert [msg]` - Mostrar alerta de prueba
*   `/sequito alertpos [top/center/bottom]` - Posición de alertas
*   `/sequito macro share/list/import/library/getlib/getall/request` - Sistema de macros

---

## v7.0.0 - Necrosis Edition Final (2026-01-30)

### 🚀 Novedades
*   **Paridad Total con Necrosis**: Completada la implementación de lógica de macros inteligente para las 10 clases.
*   **Panel de Opciones Renacido**: El panel de opciones ahora es 100% funcional.
    *   **Nueva Pestaña de Combate**: Configura el rastreo de DPS/HPS y resúmenes.
    *   **Configuración de Raid**: Control real sobre la visualización de roles, vida y ordenamiento.
    *   **Configuración de Esfera**: Escala, texto y visibilidad ahora responden al instante.
*   **Minimapa**: Añadido botón de minimapa funcional (Drag & Click).
*   **Runas DK**: Añadido soporte visual para runas de Caballeros de la Muerte (configurable).

### 🐛 Correcciones
*   **API WotLK**: Eliminadas todas las llamadas a APIs modernas (`SetColorTexture`, `SetObeyStepOnDrag`) que causaban errores en 3.3.5a.
*   **CCTracker**: Ahora respeta las opciones de "Alerta Sonora" y "Solo Combate".
*   **CombatTracker**: Resumen de combate corregido para respetar la configuración.
*   **Ghost Options**: Eliminadas opciones que no hacían nada; ahora todos los checkboxes tienen efecto real.

--- - Sequito

**Autor:** DarckRovert (Ingame: Eljesuita)

Todos los cambios notables en este proyecto serán documentados en este archivo.

---

## [2.3.0] - 2026-01-30

### ✨ Añadido
- **Necrosis Parity**: Implementación 1:1 del sistema de macros de Necrosis.
- **Universal Class Support**: Generación completa de macros para las 10 clases de WotLK.
- **Real-Time Data**: Las macros ahora verifican estrictamente `IsSpellKnown` para evitar errores.
- **Macros Raciales**: Nueva macro `SeqRacial` con grito de batalla ("¡Por el Sequito del Terror!").
- **Macros Específicas "Necro"**: Implementación de clásicos de Necrosis:
  - `SeqBubble` (Piedra de Hogar + Escudo Divino)
  - `SeqStart` (Target + Pet Attack + Opener inteligente)
  - `SeqRez` (Mensaje de rol al revivir)
  - `SeqLust` (Detección automática Heroism/Bloodlust)
- **Macro de Montura Inteligente**: `SeqMount` detecta zonas de vuelo vs terrestres.

### 🔧 Mejorado
- **Generador de Macros**: Reescrito completamente para usar listas dinámicas en lugar de huecos fijos.
- **Lógica de Mascotas**: Soporte avanzado para Warlock/Hunter con modificadores Shift/Ctrl copiados de Necrosis.
- **Limpieza**: Eliminadas dependencias de macros antiguas.

---

## [2.2.0] - 2026-01-29

### ✨ Añadido
- **SpecWatcher Module**: Detección automática de cambios de especialización
- **Logistics Module**: Sistema de "mayordomo" automático (auto-reparación, auto-venta, gestión de fragmentos)
- **PetManager Module**: Control y monitorización de mascotas (Hunter/Warlock/DK/Mage)
- **CCTracker Module**: Rastreo de Crowd Control con alertas visuales
- **Runes Module**: Visualización de runas para Death Knights
- **Visuals Module**: Efectos visuales inmersivos (Heartbeat, Proc Watcher)
- **Mounts Module**: Sistema de montura inteligente
- Auto-actualización de macros al cambiar de spec
- Comando `/sequito spec` para ver información de especialización
- Comando `/sequito specauto` para activar/desactivar auto-actualización
- Soporte para Dual Spec de WotLK
- Eventos `ACTIVE_TALENT_GROUP_CHANGED`, `CHARACTER_POINTS_CHANGED`, `PLAYER_TALENT_UPDATE`
- Notificaciones cuando se detecta cambio de spec
- Sistema de auto-reparación y auto-venta de basura
- Gestión automática de Fragmentos de Alma (Warlock)
- Botón orbital de mascota con monitor de salud
- Rastreo de Fear, Banish, Polymorph, Shackle, Freezing Trap, etc.
- Visualización de 6 runas con cooldowns para DK
- Efecto de latido rojo cuando HP < 35%
- Brillo en botones cuando hay procs importantes (Nightfall, Hot Streak, etc.)
- Sistema de montura inteligente (detecta áreas volables)

### 🔧 Mejorado
- Sistema de macros ahora responde a cambios de talentos
- Mejor detección de especializaciones
- Optimización de rendimiento en detección de spec
- Throttling en eventos de bolsa para optimizar CPU
- Mejor integración visual de módulos con la esfera principal

### 📚 Documentación
- Añadida documentación completa de SpecWatcher en MODULES.md
- Actualizado USAGE.md con información de auto-actualización
- Actualizado COMMANDS.md con nuevos comandos
- Añadido MACROS.md con guía completa de macros por clase
- Añadido MODULES_EXTRA.md con documentación de nuevos módulos

---

## [2.1.0] - 2026-01-29

### ✨ Añadido
- **RaidPanel Module**: Panel visual de raid con información en tiempo real
- **Options Module**: Panel de configuración completo
- **CombatTracker Module**: Seguimiento de DPS, HPS y estadísticas de combate
- Comando `/sequito panel` para abrir/cerrar panel de raid
- Comando `/sequito lock` para bloquear/desbloquear panel
- Comando `/sequito reset` para reiniciar posición del panel
- Comando `/sequito options` para abrir configuración
- Comando `/sequito combat` para ver resumen de combate
- Sistema de configuración con SavedVariables
- Interfaz gráfica arrastrable y redimensionable

### 🔧 Mejorado
- Mejor organización de archivos TOC
- Optimización de sincronización de raid
- Mejor manejo de eventos de combate
- Interfaz más intuitiva

### 🐛 Corregido
- Problemas de sincronización en raids grandes (40 jugadores)
- Errores al cargar módulos en orden incorrecto
- Conflictos con otros addons de raid

---

## [2.0.0] - 2026-01-29

### ✨ Añadido
- **Universal Module**: Detección de todas las clases de WotLK
- **MacroGenerator Module**: Generación de macros personalizadas por clase/spec
- **RaidSync Module**: Sincronización de información entre 40 jugadores
- **RaidIntel Module**: Análisis de buffs, cooldowns y composición
- Soporte para 10 clases: Warrior, Paladin, Hunter, Rogue, Priest, DK, Shaman, Mage, Warlock, Druid
- Detección automática de especializaciones
- Sistema de comandos tácticos (Focus, Alpha Strike)
- Escaneo de buffs faltantes en raid
- Contador de clases y roles
- Sistema de slash commands completo

### 🔧 Mejorado
- Reescritura completa del core del addon
- Mejor arquitectura modular
- Optimización de rendimiento
- Mejor manejo de memoria

### 📚 Documentación
- README.md completo
- INSTALL.md con guía de instalación
- USAGE.md con guía de uso
- COMMANDS.md con lista de comandos
- MODULES.md con documentación de módulos
- API.md para desarrolladores

---

## [1.0.0] - 2026-01-28

### ✨ Añadido
- Versión inicial de Sequito
- Core básico (Sequito.lua)
- GUI básica con esfera y satélites
- Spells.lua con datos de hechizos
- Speech.lua con frases de sabor
- EventManager.lua para gestión de eventos
- Menu.lua (esqueleto)
- Soporte básico para Warlock

### 📝 Notas
- Inspirado en Necrosis
- Versión alpha, solo para testing

---

## Tipos de Cambios

- ✨ **Añadido**: Nuevas funcionalidades
- 🔧 **Mejorado**: Cambios en funcionalidades existentes
- 🐛 **Corregido**: Corrección de bugs
- 🗑️ **Eliminado**: Funcionalidades removidas
- 🔒 **Seguridad**: Correcciones de seguridad
- 📚 **Documentación**: Cambios en documentación
- ⚡ **Rendimiento**: Mejoras de rendimiento

---

## Roadmap

### [2.4.0] - Planeado
- [ ] Integración con DBM/BigWigs
- [ ] Alertas de mecánicas de boss
- [ ] Sistema de estrategias predefinidas
- [ ] Comandos de voz (TTS)

### [3.0.0] - Futuro
- [ ] Soporte para Classic WoW
- [ ] Soporte para TBC
- [ ] Soporte para Cataclysm

---

## Versiones Antiguas

### Política de Soporte

- **Versión Actual (2.3.x)**: Soporte completo
- **Versión Anterior (2.2.x)**: Soporte de bugs críticos
- **Versiones Antiguas (2.1.x y anteriores)**: Sin soporte

### Migración

Para migrar de versiones antiguas:

1. Respalda tu configuración en `SavedVariables/Sequito.lua`
2. Elimina la carpeta del addon antiguo
3. Instala la nueva versión
4. Restaura tu configuración (si es compatible)
5. Ejecuta `/reload` en el juego

---

## Contribuciones

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para información sobre cómo contribuir.

---

## Agradecimientos

### v2.3.0
- Agradecimiento especial a Necrosis por ser la fuente de inspiración para la lógica "Elite".

### v2.2.0
- Gracias a la comunidad de UltimoWoW por el feedback sobre cambios de spec

---

**Creado por DarckRovert (Ingame: Eljesuita)**
