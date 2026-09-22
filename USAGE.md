# 📚 Guía de Uso - Sequito

**Versión:** 10.2.0 (Definitive Edition)  
**Autor:** DarckRovert (Ingame: Thesaviour)

---

## 🏆 Novedades Definitive Edition (v9.0)

### 🧠 Hive Mind (Para Oficiales)
- `/sequito sync start` - Envía la estrategia del Boss actual a toda la raid (debe estar en tus notas).
- `/sequito sync config` - Abre el panel para configurar addons de la raid remotamente.

### 🎓 Academy Mode (Para Todos)
- `/sequito inspect` (o click en el botón) - Muestra talentos y gear real del objetivo.
- **Rotation Helper:** Simplemente entra en combate y sigue el icono que aparece en pantalla.
- `/sequito gallery` - Abre la galería de loot legendario de la hermandad.

---

## 🚀 Inicio Rápido

### Primer Uso

1. **Entra al juego** con tu personaje
2. **Espera 5 segundos** para que Sequito genere tus macros automáticamente.
3. **Escribe** `/sequito` para ver el mensaje de bienvenida
4. **Si lo deseas, regenera manualmente** con `/sequito macros`
5. **Abre el panel** con `/sequito panel` (si estás en grupo/raid)

---

## 💬 Comandos Básicos

### Ayuda y Información

```
/sequito help      - Muestra lista de comandos
/sequito info      - Muestra tu clase, raza y especialización
/sequito spec      - Muestra información de tu especialización actual
```

### Generación de Macros

```
/sequito macros    - Genera macros personalizadas para tu clase/spec
```

**¿Qué hace?**
- Detecta tu clase y especialización
- Crea macros optimizadas para tu build
- Las macros aparecen en tu lista de macros del juego

**Ejemplo para Warlock Affliction:**
- Macro de rotación de DoTs
- Macro de AoE
- Macro de pet management
- Macro de cooldowns

---

## 👥 Comandos de Raid

### Información de Raid

```
/sequito raid      - Muestra composición de raid (clases y specs)
/sequito class     - Muestra conteo de clases en raid
/sequito buffs     - Escanea buffs faltantes en raid
```

### Panel Visual de Raid

```
/sequito panel     - Abre/cierra el panel de raid
/sequito lock      - Bloquea/desbloquea la posición del panel
/sequito reset     - Reinicia la posición del panel al centro
```

**Panel de Raid muestra:**
- Lista de miembros con clase y spec
- Estado de buffs importantes
- Cooldowns disponibles
- Composición de grupo

### Comandos Tácticos

```
/sequito focus [nombre]   - Envía orden de focus a la raid
/sequito alpha            - Envía orden de Alpha Strike
```

**Ejemplo:**
```
/sequito focus Ragnaros
```
Todos los miembros de raid con Sequito recibirán la orden de atacar a Ragnaros.

---

## ⚔️ Seguimiento de Combate

### Comandos de Combate

```
/sequito combat    - Muestra resumen del último combate
```

**Información mostrada:**
- DPS total
- HPS (Healing Per Second)
- Daño recibido
- Muertes
- Duración del combate

---

## ⚙️ Configuración

### Panel de Opciones

```
/sequito options   - Abre el panel de configuración
```

**Opciones disponibles:**

#### Módulos
- Activar/desactivar generación de macros
- Activar/desactivar sincronización de raid
- Activar/desactivar seguimiento de combate
- Activar/desactivar panel de raid

#### Notificaciones
- Mensajes de chat
- Alertas visuales
- Sonidos

#### Sincronización
- Auto-sync en raid
- Compartir información de spec
- Recibir comandos tácticos

#### Interfaz
- Escala del panel
- Transparencia
- Posición

### Auto-Actualización de Macros

```
/sequito specauto  - Activa/desactiva auto-actualización al cambiar spec
```

**¿Qué hace?**
- Detecta cuando cambias de especialización
- Regenera automáticamente las macros para la nueva spec
- Te notifica del cambio

---

## 🎮 Uso por Clase

### 🔮 Warlock (Brujo)

**Macros generadas:**
- **Affliction**: Rotación de DoTs (Corruption, Curse of Agony, Unstable Affliction)
- **Demonology**: Pet management y Metamorphosis
- **Destruction**: Rotación de nukes (Incinerate, Chaos Bolt)

**Comandos útiles:**
```
/sequito macros    - Genera macros de Warlock
/sequito info      - Verifica tu spec actual
```

### ⚕️ Priest (Sacerdote)

**Macros generadas:**
- **Holy**: Healing rotation (Flash Heal, Prayer of Healing)
- **Discipline**: Shield spam y Penance
- **Shadow**: DoT rotation (SW:Pain, VT, DP, Mind Flay)

### ☠️ Death Knight

**Macros generadas:**
- **Blood**: Tanking rotation
- **Frost**: DPS dual-wield
- **Unholy**: Pet DPS y diseases

### 🔥 Mage

**Macros generadas:**
- **Arcane**: Arcane Blast spam
- **Fire**: Fireball + Hot Streak
- **Frost**: Frostbolt + Fingers of Frost

### 🐺 Shaman

**Macros generadas:**
- **Elemental**: Lightning Bolt rotation
- **Enhancement**: Melee rotation con Stormstrike
- **Restoration**: Chain Heal y Riptide

### 🌿 Druid

**Macros generadas:**
- **Balance**: Moonfire/Sunfire rotation
- **Feral**: Cat/Bear form rotations
- **Restoration**: HoT stacking

### 🗡️ Warrior

**Macros generadas:**
- **Arms**: Mortal Strike rotation
- **Fury**: Bloodthirst spam
- **Protection**: Tanking rotation

### 🛡️ Paladin

**Macros generadas:**
- **Holy**: Holy Light y Holy Shock
- **Protection**: Tanking con 969 rotation
- **Retribution**: Crusader Strike rotation

### 🏹 Hunter

**Macros generadas:**
- **Beast Mastery**: Pet DPS
- **Marksmanship**: Aimed Shot rotation
- **Survival**: Explosive Shot rotation

### 🗡️ Rogue

**Macros generadas:**
- **Assassination**: Mutilate rotation
- **Combat**: Sinister Strike spam
- **Subtlety**: Hemorrhage rotation

---

## 👥 Uso en Raid

### Configuración Inicial

1. **Todos los miembros** deben tener Sequito instalado
2. **Entra a la raid**
3. **Espera unos segundos** para que se sincronice
4. **Abre el panel** con `/sequito panel`

### Sincronización Automática

Sequito sincroniza automáticamente:
- Clase y especialización de cada miembro
- Buffs activos
- Cooldowns disponibles
- Estado de combate

### Líder de Raid

Como líder, puedes:

```
/sequito focus [objetivo]  - Marca objetivo prioritario
/sequito alpha             - Orden de burst damage
/sequito buffs             - Verifica buffs faltantes
```

### Miembros de Raid

Como miembro, puedes:

```
/sequito raid      - Ver composición
/sequito panel     - Ver panel de raid
/sequito combat    - Ver tu rendimiento
```

---

## 💡 Consejos y Trucos

### Optimización de Macros

1. **Revisa las macros generadas** antes de usarlas
2. **Personaliza** según tu estilo de juego
3. **Regenera** después de cambiar talentos importantes

### Uso del Panel de Raid

1. **Posiciónalo** donde no obstruya tu visión
2. **Bloquea** la posición con `/sequito lock`
3. **Ajusta la escala** en opciones si es muy grande/pequeño

### Sincronización

1. **Asegúrate** de que todos tengan la misma versión
2. **Espera** unos segundos después de entrar a raid
3. **Verifica** con `/sequito raid` que todos estén sincronizados

### Cambio de Especialización

1. **Activa auto-update** con `/sequito specauto`
2. **Cambia de spec** normalmente
3. **Sequito detectará** el cambio y actualizará macros automáticamente

---

## ⚠️ Limitaciones

### Lo que Sequito NO hace:

- ❌ **No automatiza ataques** - Solo crea macros, tú las ejecutas
- ❌ **No juega por ti** - Solo proporciona información
- ❌ **No hace bots** - Cumple con los ToS de WoW
- ❌ **No lee memoria del juego** - Solo usa API oficial de WoW

### Restricciones de Macros

- **Máximo 255 caracteres** por macro (limitación de WoW)
- **Máximo 36 macros generales** + 18 por personaje
- Las macros complejas pueden requerir múltiples macros

---

## 🔧 Solución de Problemas

### Las macros no se actualizan al cambiar spec

**Solución:**
```
/sequito specauto  - Verifica que esté activado
/sequito macros    - Regenera manualmente
```

### El panel de raid no muestra a todos

**Solución:**
1. Verifica que todos tengan Sequito instalado
2. Espera 10-15 segundos para sincronización
3. Intenta `/reload`

### Los comandos tácticos no llegan

**Solución:**
1. Verifica que estés en raid (no funciona en party de 5)
2. Asegúrate de que otros tengan Sequito
3. Revisa que la sincronización esté activada en opciones

---

## 📚 Más Información

- [COMMANDS.md](COMMANDS.md) - Lista completa de comandos
- [MODULES.md](MODULES.md) - Documentación de módulos
- [FAQ.md](FAQ.md) - Preguntas frecuentes
- [API.md](API.md) - Para desarrolladores

---

**Creado por DarckRovert (Ingame: Thesaviour)**
