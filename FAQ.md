# ❓ Preguntas Frecuentes (FAQ) - Sequito

**Versión:** 7.3.0  
**Autor:** DarckRovert (Ingame: Eljesuita)

---

## 📚 Índice

1. [General](#general)
2. [Instalación](#instalación)
3. [Macros](#macros)
4. [Raid y Sincronización](#raid-y-sincronización)
5. [Especializaciones](#especializaciones)
6. [Interfaz](#interfaz)
7. [Rendimiento](#rendimiento)
8. [Compatibilidad](#compatibilidad)
9. [Troubleshooting](#troubleshooting)

---

## 🅰️ General

### ¿Qué es Sequito?

Sequito es un addon universal de combate para World of Warcraft (WotLK 3.3.5a) que proporciona:
- Generación automática de macros por clase/spec
- Sincronización de información en raids de hasta 40 jugadores
- Seguimiento de combate (DPS/HPS)
- Panel visual de raid
- Inteligencia de raid (buffs, cooldowns, composición)

---

### ¿Sequito automatiza mi personaje?

**NO.** Sequito **NO automatiza** ningún ataque ni habilidad. Solo:
- Crea macros que **tú** debes ejecutar manualmente
- Proporciona información en tiempo real
- Facilita la comunicación en raid

Sequito cumple con los Términos de Servicio de WoW.

---

### ¿Qué clases soporta?

Sequito soporta **todas las 10 clases** de WotLK:
- Warrior (Guerrero)
- Paladin (Paladín)
- Hunter (Cazador)
- Rogue (Pícaro)
- Priest (Sacerdote)
- Death Knight (Caballero de la Muerte)
- Shaman (Chamán)
- Mage (Mago)
- Warlock (Brujo)
- Druid (Druida)

---

### ¿Es gratis?

Sí, Sequito es completamente **gratuito** y de código abierto.

---

### ¿Quién creó Sequito?

Sequito fue creado por **DarckRovert** (Ingame: Eljesuita), inspirado en el addon Necrosis.

---

## 📦 Instalación

### ¿Cómo instalo Sequito?

1. Descarga el addon
2. Extrae la carpeta `Sequito` en `Interface/AddOns/`
3. Reinicia WoW o escribe `/reload`
4. Activa el addon en el menú de AddOns

Ver [INSTALL.md](INSTALL.md) para detalles completos.

---

### ¿Dónde va la carpeta del addon?

**Windows:**
```
C:\Program Files (x86)\World of Warcraft\Interface\AddOns\Sequito\
```

**Para UltimoWoW:**
```
E:\[UltimoWoW] Client esMX\UltimoWoW esMX\Interface\AddOns\Sequito\
```

---

### El addon no aparece en la lista, ¿qué hago?

1. Verifica que la carpeta se llame exactamente `Sequito`
2. Asegúrate de que `Sequito.toc` esté en la raíz de la carpeta
3. Reinicia completamente WoW (no solo `/reload`)
4. Verifica que estés en la carpeta correcta de AddOns

---

### ¿Cómo actualizo Sequito?

1. Respalda tu configuración (opcional): `SavedVariables/Sequito.lua`
2. Elimina la carpeta `Sequito` antigua
3. Instala la nueva versión
4. Restaura tu configuración si la respaldaste
5. Ejecuta `/reload`

---

## 🔧 Macros

### ¿Cómo genero macros?

Escribe en el chat:
```
/sequito macros
```

Sequito detectará tu clase y especialización, y creará macros optimizadas.

---

### ¿Cuántas macros se crean?

Depende de tu clase y spec, generalmente entre 3-5 macros:
- Rotación principal
- AoE
- Cooldowns
- Utilidades (pet control, defensivos, etc.)

---

### Las macros no se crean, ¿qué pasa?

**Posibles causas:**

1. **No tienes espacio**: WoW limita a 36 macros generales + 18 por personaje
   - **Solución**: Elimina macros viejas

2. **Módulo desactivado**: Verifica en `/sequito options`
   - **Solución**: Activa "Generación de Macros"

3. **Error de carga**: Verifica que `MacroGenerator.lua` exista
   - **Solución**: Reinstala el addon

---

### ¿Puedo personalizar las macros?

**Sí**, las macros generadas son estándar de WoW. Puedes:
1. Editarlas manualmente en el menú de macros (`/macro`)
2. Modificar el código en `MacroGenerator.lua` (avanzado)

**Nota:** Si regeneras las macros, se sobrescribirán tus cambios.

---

### ¿Las macros se actualizan al cambiar de spec?

**Sí**, si activas la auto-actualización:
```
/sequito specauto
```

Cuando cambies de especialización, Sequito detectará el cambio y regenerará las macros automáticamente.

---

### ¿Qué significa "[SEQ]" en el nombre de las macros?

Es el prefijo de Sequito para identificar las macros generadas por el addon. Puedes renombrarlas si quieres.

---

## 👥 Raid y Sincronización

### ¿Cómo funciona la sincronización?

Sequito usa el sistema de comunicación de addons de WoW (`SendAddonMessage`) para compartir información entre miembros de raid que tengan Sequito instalado.

---

### ¿Todos en la raid necesitan Sequito?

**No**, pero:
- Solo verás información de jugadores que tengan Sequito
- Los comandos tácticos solo llegarán a quienes tengan Sequito
- Mientras más jugadores lo tengan, más útil será

---

### El panel de raid no muestra a todos, ¿por qué?

**Posibles causas:**

1. **No tienen Sequito instalado**: Solo aparecen jugadores con el addon
2. **Sincronización en progreso**: Espera 10-15 segundos
3. **Versión diferente**: Asegúrate de que todos tengan la misma versión

---

### ¿Cómo envío comandos tácticos?

**Focus en objetivo:**
```
/sequito focus NombreDelBoss
```

**Alpha Strike (usar cooldowns):**
```
/sequito alpha
```

Todos los miembros con Sequito recibirán la notificación.

---

### ¿Los comandos tácticos funcionan en party de 5?

**No**, solo funcionan en raids. En parties pequeñas no es necesaria la sincronización.

---

### ¿Qué buffs escanea Sequito?

- Blessing of Kings / Mark of the Wild
- Power Word: Fortitude
- Arcane Intellect
- Divine Spirit
- Blessing of Might

---

## 🔄 Especializaciones

### ¿Sequito detecta mi spec automáticamente?

**Sí**, Sequito analiza tus talentos para determinar tu especialización.

---

### ¿Funciona con Dual Spec?

**Sí**, Sequito soporta completamente Dual Spec de WotLK. Detecta cuando cambias de grupo de talentos.

---

### Cambié de spec pero las macros no se actualizaron

**Solución:**

1. Verifica que auto-update esté activado:
   ```
   /sequito specauto
   ```

2. Si no está activado, regenera manualmente:
   ```
   /sequito macros
   ```

---

### ¿Puedo ver mi spec actual?

**Sí:**
```
/sequito spec
```

Mostrará tu especialización, grupo de talentos y rol.

---

## 🎨 Interfaz

### ¿Cómo abro el panel de raid?

```
/sequito panel
```

---

### ¿Cómo muevo el panel?

1. Desbloquea el panel:
   ```
   /sequito lock
   ```

2. Arrastra el panel a la posición deseada

3. Bloquea el panel nuevamente:
   ```
   /sequito lock
   ```

---

### El panel está fuera de la pantalla, ¿qué hago?

```
/sequito reset
```

Esto reiniciará la posición del panel al centro de la pantalla.

---

### ¿Puedo cambiar el tamaño del panel?

**Sí**, en el panel de opciones:
```
/sequito options
```

Ajusta la escala (0.5 - 2.0) y la transparencia.

---

### ¿Cómo oculto el panel?

```
/sequito panel
```

El mismo comando abre/cierra el panel.

---

## ⚡ Rendimiento

### ¿Sequito consume muchos recursos?

**No**, Sequito está optimizado para:
- Bajo uso de CPU
- Bajo uso de memoria (~2 MB)
- Actualizaciones eficientes (no polling constante)

---

### Tengo lag desde que instalé Sequito

**Posibles causas:**

1. **Conflicto con otro addon**: Desactiva otros addons temporalmente
2. **Raid muy grande**: En raids de 40, la sincronización puede generar tráfico
   - **Solución**: Desactiva sincronización en `/sequito options`
3. **Versión antigua**: Actualiza a la última versión

---

### ¿Puedo desactivar módulos que no uso?

**Sí:**
```
/sequito options
```

Desactiva los módulos que no necesites:
- Generación de macros
- Sincronización de raid
- Seguimiento de combate
- Panel de raid

---

## 🔗 Compatibilidad

### ¿Sequito funciona con DBM?

**Sí**, Sequito es compatible con Deadly Boss Mods.

---

### ¿Funciona con Recount/Skada?

**Sí**, no hay conflictos con medidores de DPS.

---

### ¿Puedo usar Sequito y Necrosis al mismo tiempo?

**No recomendado**. Ambos intentan crear macros similares, lo que puede causar conflictos.

**Solución:**
- Usa solo uno de los dos
- O desactiva la generación de macros en uno de ellos

---

### ¿Funciona en servidores privados?

**Sí**, Sequito funciona en cualquier servidor de WotLK 3.3.5a, incluyendo:
- UltimoWoW
- Warmane
- Dalaran-WoW
- ChromieCraft
- Etc.

---

### ¿Funciona en Classic/TBC/Retail?

**No**, Sequito está diseñado específicamente para WotLK 3.3.5a.

Soporte para otras versiones está planeado para el futuro.

---

## 🐛 Troubleshooting

### Error: "Sequito failed to load"

**Solución:**

1. Verifica que todos los archivos estén presentes
2. Reinstala el addon
3. Verifica que no haya archivos corruptos
4. Revisa errores con `/console scriptErrors 1`

---

### Error: "MacroGenerator module not found"

**Solución:**

1. Verifica que `Modules/MacroGenerator.lua` exista
2. Verifica que `Embeds.xml` incluya MacroGenerator
3. Reinstala el addon

---

### Los comandos no funcionan

**Solución:**

1. Verifica que el addon esté activado en el menú de AddOns
2. Ejecuta `/reload`
3. Verifica que no haya errores de Lua
4. Reinstala si persiste el problema

---

### "You have too many macros"

**Solución:**

WoW limita a 36 macros generales + 18 por personaje.

1. Abre el menú de macros (`/macro`)
2. Elimina macros que no uses
3. Intenta generar las macros nuevamente

---

### El panel de raid está en blanco

**Solución:**

1. Verifica que estés en un grupo o raid
2. Espera unos segundos para sincronización
3. Ejecuta `/reload`
4. Verifica que `RaidPanel.lua` esté cargado

---

### "Addon communication throttled"

**Causa:** Demasiados mensajes de addon en poco tiempo.

**Solución:**

1. Espera unos segundos
2. Reduce la frecuencia de comandos tácticos
3. En raids muy grandes, la sincronización puede ser lenta

---

## 📝 Otras Preguntas

### ¿Cómo reporto un bug?

1. Verifica que no esté en [FAQ.md](FAQ.md)
2. Revisa [CHANGELOG.md](CHANGELOG.md) para problemas conocidos
3. Reporta con:
   - Versión de Sequito
   - Pasos para reproducir
   - Mensaje de error (si hay)
   - Otros addons instalados

---

### ¿Cómo sugiero una funcionalidad?

1. Verifica que no esté en el roadmap de [CHANGELOG.md](CHANGELOG.md)
2. Envía tu sugerencia con:
   - Descripción detallada
   - Caso de uso
   - Beneficio para la comunidad

---

### ¿Puedo contribuir al desarrollo?

**Sí**, ver [CONTRIBUTING.md](CONTRIBUTING.md) para guía de contribución.

---

### ¿Dónde está el código fuente?

El código fuente está en la carpeta del addon:
```
Interface/AddOns/Sequito/
```

Todos los archivos `.lua` son legibles y modificables.

---

### ¿Sequito recopila datos míos?

**No**, Sequito:
- No envía datos a servidores externos
- No rastrea tu actividad
- Solo guarda configuración local en SavedVariables
- Solo comunica con otros jugadores en tu raid (si está activado)

---

### ¿Cómo desinstalo Sequito?

1. Elimina la carpeta `Interface/AddOns/Sequito/`
2. (Opcional) Elimina `WTF/Account/TU_CUENTA/SavedVariables/Sequito.lua`
3. Ejecuta `/reload` en el juego

---

## 📚 Más Información

- [README.md](README.md) - Introducción general
- [INSTALL.md](INSTALL.md) - Guía de instalación
- [USAGE.md](USAGE.md) - Guía de uso
- [COMMANDS.md](COMMANDS.md) - Lista de comandos
- [MODULES.md](MODULES.md) - Documentación de módulos
- [API.md](API.md) - Para desarrolladores
- [CHANGELOG.md](CHANGELOG.md) - Historial de versiones

---

**Creado por DarckRovert (Ingame: Eljesuita)**
