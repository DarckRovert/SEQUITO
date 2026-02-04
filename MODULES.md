# 🛠️ Documentación de Módulos - Sequito

**Versión:** 7.3.0  
**Autor:** DarckRovert (Ingame: Eljesuita)

---

## 📋 Índice de Módulos (38 total)

### Core (6)
1. [Universal.lua](#universallua) - Detección de clase y recursos
2. [MacroGenerator.lua](#macrogeneratorlua) - Generación de macros (Necrosis Ed.)
3. [MacroSync.lua](#macrosynclua) - Sistema de macros compartidos
4. [SpecWatcher.lua](#specwatcherlua) - Detección de cambios de spec
5. [EventManager.lua](#eventmanagerlua) - Gestor de eventos
6. [Options.lua](#optionslua) - Panel de configuración

### Raid/Party (7)
7. [RaidSync.lua](#raidsynclua) - Sincronización de raid
8. [RaidIntel.lua](#raidintellua) - Inteligencia de raid
9. [RaidPanel.lua](#raidpanellua) - Panel visual de raid
10. [RaidAssist.lua](#raidassistlua) - Asistente de raid con alertas
11. [CooldownMonitor.lua](#cooldownmonitorlua) - Monitor de CDs del raid
12. [Assignments.lua](#assignmentslua) - Sistema de asignaciones
13. [ReadyChecker.lua](#readycheckerlua) - Chequeo pre-pull mejorado

### Combate (2)
14. [CombatTracker.lua](#combattrackerlua) - Seguimiento de combate
15. [CCTracker.lua](#cctrackerlua) - Tracker de CC
16. [WipeAnalyzer.lua](#wipeanalyzerlua) - Analizador de Wipes

### PvP (5) - **NUEVO v7.3.0**
17. [TrinketTracker.lua](#trinkettrackerlua) - Tracker de Trinkets enemigos
18. [FocusFire.lua](#focusfirelua) - **NUEVO** Llamadas de target sincronizadas
19. [CCCoordinator.lua](#cccoordinatorlua) - **NUEVO** Coordinador de CC con DR
20. [HealerTracker.lua](#healertrackerlua) - **NUEVO** Monitor de healers enemigos
21. [DefensiveAlerts.lua](#defensivealertslua) - **NUEVO** Llamadas de defensivos

### Dungeons (3) - **NUEVO v7.3.0**
22. [PullGuide.lua](#pullguidelua) - **NUEVO** Guía de pulls con auto-marcado
23. [DungeonTimer.lua](#dungeontimerlua) - **NUEVO** Timer de Heroic/Daily
24. [LootCouncil.lua](#lootcouncillua) - **NUEVO** Sistema de Loot Council

### General (7) - **NUEVO v7.3.0**
25. [PlayerNotes.lua](#playernoteslua) - **NUEVO** Notas de jugadores
26. [BuildManager.lua](#buildmanagerlua) - **NUEVO** Gestor de builds/specs
27. [EventCalendar.lua](#eventcalendarlua) - **NUEVO** Calendario de eventos
28. [PerformanceStats.lua](#performancestatslua) - **NUEVO** Estadísticas DPS/HPS
29. [VotingSystem.lua](#votingsystemlua) - **NUEVO** Sistema de votaciones
30. [VersionSync.lua](#versionsynclua) - **NUEVO** Sincronización de versiones
31. [QuickWhisper.lua](#quickwhisperlua) - **NUEVO** Mensajes rápidos

### Utilidades (7)
32. [Logistics.lua](#logisticslua) - Auto-reparación y venta
33. [PetManager.lua](#petmanagerlua) - Control de mascotas
34. [Mounts.lua](#mountslua) - Sistema de monturas
35. [Visuals.lua](#visualslua) - Efectos visuales
36. [Runes.lua](#runeslua) - Runas de DK
37. [Menu.lua](#menulua) - Menú contextual
38. [RaidAssistUI.lua](#raidassistuilua) - UI de RaidAssist

---

## 🔧 MacroGenerator.lua

### Descripción
El corazón de la actualización 2.3.0. Este módulo ha sido reescrito para replicar exactamente la lógica de macros de **Necrosis**. Ya no usa plantillas genéricas, sino lógica "hardcoded" específica para cada clase para garantizar la máxima calidad y utilidad.

### Funcionalidades Clave

#### 1. Real-Time Data Check
Antes de incluir un hechizo en una macro, el generador verifica estrictamente `IsSpellKnown(id)`.
- Si no sabes el hechizo (ej. nivel bajo), la macro se adapta o no se crea.
- Evita los molestos signos de interrogación (?) en las barras.

#### 2. Macros Inteligentes (Smart Macros)
Copia la filosofía "Multi-Función" de Necrosis.
- **[SeqPet]**: Un solo botón para Atacar, Seguir y usar Habilidad Especial (Shift) con prioridad Mouseover > Focus > Target.
- **[SeqHeal]**: Un solo botón para usar Piedra/Poción o crearla si no existe (Click Derecho).
- **[SeqStart]**: Selecciona enemigo, manda pet y lanza opener.

#### 3. Soporte Universal
Ahora genera este nivel de macros para las 10 clases, incluyendo:
- Macros de "Panic Buttons" (Burbuja, Muro de Escudo, Dispersión).
- Macros de Utilidad de Raid (Himno, Heroísmo, Redirección).

### API del Módulo

#### `Sequito_MacroGenerator_CreateMacros()`
Llama a la generación completa. Borra macros antiguas de Sequito y crea las nuevas.

#### `Sequito_MacroGenerator_GetSmartSpell(id)`
Helper interno que retorna el nombre del hechizo SOLO si está aprendido.

---

## 🔍 Universal.lua
*(Sin cambios mayores en API, ver documentación anterior)*

---

## 🔄 SpecWatcher.lua
Detecta cuando cambias de talentos (Dual Spec) y desencadena automáticamente `Sequito_MacroGenerator_CreateMacros()` para que tus botones siempre hagan lo correcto.

---

## 👥 RaidSync.lua / RaidIntel.lua / RaidPanel.lua
*(Funcionalidad intacta v2.2.0 - Sincronización y Panel de Raid)*

---

## 📊 CooldownMonitor.lua

### Descripción
Monitor de Cooldowns del Raid en tiempo real. Trackea CDs importantes de todos los miembros.

### Funcionalidades Clave

#### 1. Cooldowns Trackeados
- **Battle Res**: Rebirth (Druid), Soulstone (Warlock)
- **Heroism/Bloodlust**: Shaman
- **Raid CDs**: Divine Sacrifice, Aura Mastery, Anti-Magic Zone, Divine Hymn
- **Externals**: Pain Suppression, Guardian Spirit, Hand of Sacrifice/Protection
- **Tank CDs**: Shield Wall, Last Stand, Survival Instincts, Barkskin
- **Utility**: Misdirection, Tricks of the Trade, Innervate

#### 2. Panel Visual
- Panel flotante con todos los CDs del raid
- Filtros por tipo (BRes, Lust, Raid CD, External, Tank CD)
- Colores por tipo de cooldown
- Timer en tiempo real

#### 3. Alertas
- Anuncia en raid cuando se usa un CD importante
- Alerta cuando un BRes vuelve a estar disponible

### Comandos
- `/sequito cooldowns` - Abre/cierra el panel de CDs
- `/sequito cd bres` - Anuncia Battle Res disponibles
- `/sequito cd lust` - Anuncia Heroism/Bloodlust disponible

### API del Módulo
- `S.CooldownMonitor:Toggle()` - Abre/cierra panel
- `S.CooldownMonitor:GetAvailableBRes()` - Lista BRes disponibles
- `S.CooldownMonitor:AnnounceAvailable(type)` - Anuncia CDs disponibles

---

## 🎯 Assignments.lua

### Descripción
Sistema de Asignaciones Automáticas para Raids.

### Funcionalidades Clave

#### 1. Tipos de Asignaciones
- **Interrupts**: Rotación automática de interrupters
- **Tanks**: Asignar tanks a objetivos específicos
- **Healers**: Asignar healers a tanks/grupos
- **Cooldowns**: Asignar CDs defensivos a fases
- **Marks**: Asignar marcas de raid a jugadores

#### 2. Auto-Asignación
- Detecta automáticamente clases con interrupt
- Ordena por CD más corto (Shaman > Rogue/Warrior > Mage)
- Genera rotación óptima

#### 3. Sincronización
- Comparte asignaciones con el raid via addon messages
- Todos los usuarios de Sequito reciben las asignaciones

### Comandos
- `/sequito assign` - Abre panel de asignaciones
- `/sequito assign interrupts` - Auto-asigna rotación de interrupts
- `/sequito assign announce` - Anuncia todas las asignaciones

### API del Módulo
- `S.Assignments:Toggle()` - Abre/cierra panel
- `S.Assignments:AutoAssignInterrupts()` - Auto-asigna interrupts
- `S.Assignments:SyncToRaid()` - Sincroniza con el raid

---

## ✅ ReadyChecker.lua

### Descripción
Chequeo Pre-Pull Mejorado. Verifica que todos estén listos antes del pull.

### Funcionalidades Clave

#### 1. Verificaciones por Clase
- **Rogue**: Venenos aplicados (MH/OH)
- **Warlock/Hunter**: Mascota invocada
- **Warlock**: Healthstone en bolsas, Spellstone
- **DK**: Presencia activa, Horn of Winter
- **Paladin**: Aura y Sello activos
- **Shaman**: Escudo y Weapon Imbue
- **Mage**: Armadura activa
- **Warrior**: Grito y Postura
- **Druid**: Mark of the Wild
- **Priest**: Fortitude, Divine Spirit, Shadow Protection

#### 2. Verificaciones Generales
- Flask activo
- Food buff (Well Fed)
- Vida y Mana al 100%
- No muerto, no AFK, no desconectado

#### 3. Panel Visual
- Lista de todos los miembros con estado
- Icono verde (listo) o rojo (problemas)
- Detalle de qué falta a cada jugador

### Comandos
- `/sequito readycheck` - Abre panel y escanea
- `/sequito readycheck full` - Escaneo completo con anuncio

### API del Módulo
- `S.ReadyChecker:Toggle()` - Abre/cierra panel
- `S.ReadyChecker:ScanRaid()` - Escanea el raid
- `S.ReadyChecker:AnnounceProblems()` - Anuncia problemas al raid
- `S.ReadyChecker:QuickCheck()` - Retorna true si todos listos

---

## ⚔️ CombatTracker.lua
*(Funcionalidad intacta v2.2.0 - Métricas de combate)*

---

## 🎒 Logistics / PetManager / CCTracker
Módulos de soporte que mejoran la calidad de vida.
- **Logistics**: Vende basura gris automáticamente.
- **PetManager**: Botón orbital para controlar mascota (Warlock/Hunter/DK).
- **CCTracker**: Barras de tiempo para tus CCs (Miedo, Destierro, Oveja).

---

---

## 🔄 MacroSync.lua (NUEVO v7.1.0)

### Descripción
Sistema de sincronización y biblioteca de macros entre usuarios de Sequito.

### Funcionalidades Clave

#### 1. Sincronización entre Usuarios
- Comparte macros con tu grupo/raid via addon messages.
- Recibe y almacena macros de otros jugadores.
- Solicita lista de macros disponibles del grupo.
- Solicita macros específicos por nombre.

#### 2. Biblioteca de Macros por Clase
- 10 clases cubiertas con 3-5 macros cada una.
- Sistema de rating (estrellas) para calidad.
- Filtrado por especialización.
- Macros probados y optimizados para 3.3.5a.

### Comandos
- `/sequito macro share <nombre>` - Comparte macro con el grupo
- `/sequito macro list` - Lista macros recibidos
- `/sequito macro import <nombre>` - Importa macro compartido
- `/sequito macro library` - Muestra biblioteca de tu clase/spec
- `/sequito macro getlib <nombre>` - Importa de biblioteca
- `/sequito macro getall` - Importa todos de biblioteca
- `/sequito macro request` - Solicita lista del grupo

### API del Módulo
- `S.MacroSync:ShareMacro(name)` - Comparte un macro
- `S.MacroSync:ImportMacro(name)` - Importa macro compartido
- `S.MacroSync:ListLibraryMacros(class, spec)` - Lista biblioteca
- `S.MacroSync:ImportFromLibrary(name)` - Importa de biblioteca

---

## 🎯 RaidAssist.lua (MEJORADO v7.1.0)

### Descripción
Asistente completo para raids con alertas personalizables e historial de wipes.

### Nuevas Funcionalidades v7.1.0

#### 1. Sistema de Alertas Personalizables
- Alertas visuales con colores por tipo (INFO/WARNING/CRITICAL).
- Posición configurable: TOP, CENTER, BOTTOM.
- Sonidos personalizados por tipo de alerta.
- Animación de fade-out automática.

#### 2. Historial de Wipes
- Guardado persistente en SavedVariables.
- Estadísticas por zona y boss.
- Tiempo de combate y causa de muerte.
- Comandos para ver y limpiar historial.

#### 3. Integración Visual
- Botón satélite dedicado en la esfera.
- Indicador de estado raid/party.
- Submenú en el menú contextual.

### Comandos
- `/sequito wipehistory` - Ver historial de wipes
- `/sequito clearwipes` - Limpiar historial
- `/sequito alert [mensaje]` - Mostrar alerta de prueba
- `/sequito alertpos [top/center/bottom]` - Cambiar posición

### API del Módulo
- `S.RaidAssist:ShowAlert(msg, type, duration)` - Muestra alerta
- `S.RaidAssist:SetAlertPosition(pos)` - Cambia posición
- `S.RaidAssist:PrintWipeHistory()` - Imprime historial
- `S.RaidAssist:ClearWipeHistory()` - Limpia historial

---

## ⚔️ TrinketTracker.lua (NUEVO v7.2.0)

### Descripción
Tracker de Trinkets PvP enemigos para Arena y Battlegrounds.

### Funcionalidades Clave

#### 1. Detección Automática
- Detecta cuando un enemigo usa su trinket PvP.
- Soporta trinkets de facción y raciales (Will of the Forsaken, Every Man for Himself).
- Alerta visual y sonora al detectar uso.

#### 2. Timer de Cooldown
- Timer de 2 minutos por cada trinket usado.
- Muestra tiempo restante en panel flotante.
- Alerta cuando el trinket vuelve a estar disponible.

#### 3. Integración con Nameplates
- Iconos sobre nameplates enemigos mostrando estado del trinket.
- Desaturado cuando está en CD, normal cuando está listo.

#### 4. Anuncios Automáticos
- Anuncia en party/raid cuando un enemigo usa trinket (en arena).
- Comando para anunciar estado de todos los trinkets.

### Comandos
- `/sequito trinkets` - Abre/cierra el panel de trinkets
- `/sequito trinkets clear` - Limpia el tracker
- `/sequito trinkets announce` - Anuncia estado de trinkets al grupo

### API del Módulo
- `S.TrinketTracker:Toggle()` - Abre/cierra panel
- `S.TrinketTracker:GetTrinketStatus(name)` - Obtiene estado de trinket de un jugador
- `S.TrinketTracker:AnnounceAll()` - Anuncia todos los trinkets
- `S.TrinketTracker:ClearAll()` - Limpia el tracker

---

## 💀 WipeAnalyzer.lua (NUEVO v7.2.0)

### Descripción
Analizador de Wipes para raids que ayuda a identificar las causas de los wipes.

### Funcionalidades Clave

#### 1. Registro de Muertes
- Registra todas las muertes durante el combate.
- Guarda quién murió, cuándo, y por qué habilidad.
- Orden cronológico de muertes.

#### 2. Análisis de Primera Muerte
- Identifica quién murió primero (crítico para entender el wipe).
- Muestra la habilidad que causó la muerte.
- Muestra el enemigo que causó el daño.

#### 3. Verificación de Consumibles
- Detecta quién usó pociones/healthstones durante el combate.
- Lista jugadores que murieron sin usar consumibles.

#### 4. Tracking de Interrupts
- Registra interrupts exitosos.
- Ayuda a identificar si faltaron interrupts críticos.

#### 5. Historial de Wipes
- Guarda historial de wipes por sesión.
- Estadísticas por encuentro.

### Comandos
- `/sequito analyze` - Muestra análisis del último wipe
- `/sequito wipehistory` - Muestra historial de wipes
- `/sequito clearwipes` - Limpia historial

### API del Módulo
- `S.WipeAnalyzer:Toggle()` - Abre/cierra panel
- `S.WipeAnalyzer:Analyze()` - Analiza último wipe
- `S.WipeAnalyzer:AnnounceAnalysis()` - Anuncia análisis al raid
- `S.WipeAnalyzer:ShowHistory()` - Muestra historial

---

**Nota:** Para detalles de implementación técnica, revisar el código fuente en `Modules/`.
