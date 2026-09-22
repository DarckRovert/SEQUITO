# 📦 Guía de Instalación - Sequito

**Versión:** 10.1.0 (The Final Polish)  
**Autor:** DarckRovert (Ingame: Thesaviour)

---

## 📍 Requisitos

- **World of Warcraft:** 3.3.5a (Wrath of the Lich King)
- **Sistema Operativo:** Windows, macOS o Linux
- **Espacio en Disco:** ~3 MB

---

## 🚀 Instalación Rápida

### Paso 1: Descargar el Addon

1. Descarga la última versión de Sequito (v10.1+)
2. Asegúrate de tener el archivo `Sequito.zip`

### Paso 2: Extraer Archivos

1. Extrae el `.zip`
2. Deberías tener una carpeta llamada `Sequito`

### Paso 3: Copiar a la Carpeta de AddOns

**Ruta típica en Windows:**
```
World of Warcraft\Interface\AddOns\Sequito\
```

### Paso 4: Verificar Estructura

Dentro de `Sequito/`, deberías ver:
- `Sequito.toc`
- `Sequito.lua`
- `Modules/` (que contiene `Core`, `Raid`, `PvP`, `Utility`)
- `Locales/`
- `Data/`

*Nota: En v10.0, los archivos Lua ya no están sueltos en Modules, sino organizados en carpetas.*

Asegúrate de que la estructura sea:
```
AddOns/
└── Sequito/
    ├── Sequito.toc
    ├── Sequito.lua
    ├── Embeds.xml
    ├── Core/
    ├── Data/
    ├── Locales/
    └── Modules/
```

### Paso 5: Activar en el Juego

1. Inicia World of Warcraft
2. En la pantalla de selección de personaje, haz clic en **"AddOns"** (esquina inferior izquierda)
3. Busca **"Sequito"** en la lista
4. Asegúrate de que esté **marcado** (checkbox activado)
5. Haz clic en **"Okay"**
6. Entra al juego con tu personaje

### Paso 6: Verificar Instalación

En el chat del juego, escribe:
```
/sequito
```

Deberías ver el mensaje de bienvenida de Sequito.

---

## ⚙️ Configuración Inicial

### Generar Macros

Para generar macros personalizadas para tu clase:
```
/sequito macros
```

Esto creará macros optimizadas según tu clase y especialización actual.

### Abrir Panel de Opciones

```
/sequito options
```

Aquí puedes configurar:
- Activar/desactivar módulos
- Ajustar notificaciones
- Configurar sincronización de raid
- Personalizar interfaz

### Abrir Panel de Raid

```
/sequito panel
```

Muestra información en tiempo real de tu raid.

---

## 🔄 Actualización

### Desde una Versión Anterior

1. **Respalda tu configuración** (opcional):
   - Copia `WTF/Account/TU_CUENTA/SavedVariables/Sequito.lua`

2. **Elimina la versión anterior**:
   - Borra la carpeta `AddOns/Sequito/`

3. **Instala la nueva versión**:
   - Sigue los pasos de instalación normal

4. **Restaura configuración** (si respaldaste):
   - Copia de vuelta el archivo `Sequito.lua` a SavedVariables

5. **Recarga la interfaz**:
   ```
   /reload
   ```

---

## 🐛 Solución de Problemas

### El addon no aparece en la lista

**Problema:** Sequito no aparece en el menú de AddOns.

**Solución:**
1. Verifica que la carpeta se llame exactamente `Sequito`
2. Verifica que `Sequito.toc` esté en la raíz de la carpeta
3. Asegúrate de estar en la carpeta correcta de AddOns
4. Reinicia completamente WoW

### Error al cargar el addon

**Problema:** Mensaje de error al iniciar sesión.

**Solución:**
1. Verifica que todos los archivos estén presentes
2. Revisa que no haya archivos corruptos
3. Descarga nuevamente el addon
4. Desactiva otros addons para verificar conflictos

### Los comandos no funcionan

**Problema:** `/sequito` no hace nada.

**Solución:**
1. Verifica que el addon esté activado en el menú de AddOns
2. Escribe `/reload` para recargar la interfaz
3. Revisa si hay errores con `/console scriptErrors 1`

### Las macros no se generan

**Problema:** `/sequito macros` no crea macros.

**Solución:**
1. Asegúrate de tener espacio libre en tu lista de macros
2. Elimina macros viejas si es necesario
3. Verifica que `MacroGenerator.lua` esté presente

### El panel de raid no se muestra

**Problema:** `/sequito panel` no abre nada.

**Solución:**
1. Verifica que estés en un grupo o raid
2. Intenta `/sequito reset` para reiniciar la posición
3. Revisa que `RaidPanel.lua` esté cargado

---

## 📝 Archivos de Configuración

### Ubicación de SavedVariables

**Windows:**
```
WTF\Account\TU_CUENTA\SavedVariables\Sequito.lua
```

**Por Personaje:**
```
WTF\Account\TU_CUENTA\SERVIDOR\PERSONAJE\SavedVariables\Sequito.lua
```

### Resetear Configuración

Para resetear completamente la configuración:

1. Cierra WoW
2. Elimina `SavedVariables/Sequito.lua`
3. Inicia WoW
4. Sequito usará configuración por defecto

---

## 🔗 Compatibilidad con Otros Addons

### Addons Compatibles

- ✅ **DBM** (Deadly Boss Mods)
- ✅ **Recount** / **Skada**
- ✅ **Bartender** / **Dominos**
- ✅ **Grid** / **Healbot**
- ✅ **Omen** (Threat Meter)
- ✅ **AtlasLoot**

### Posibles Conflictos

- ⚠️ **Necrosis**: Puede haber conflictos si ambos intentan crear las mismas macros
- ⚠️ **Otros addons de macros**: Desactiva generación automática en uno de ellos

---

## ✅ Verificación Post-Instalación

Después de instalar, verifica que todo funcione:

```
/sequito info      - Debe mostrar tu clase y spec
/sequito macros    - Debe generar macros
/sequito raid      - Debe mostrar composición (si estás en grupo)
/sequito panel     - Debe abrir el panel
/sequito options   - Debe abrir configuración
```

Si todos estos comandos funcionan, ¡la instalación fue exitosa! 🎉

---

## 📞 Soporte

Si sigues teniendo problemas:

1. Revisa [FAQ.md](FAQ.md) para preguntas comunes
2. Verifica [CHANGELOG.md](CHANGELOG.md) para problemas conocidos
3. Reporta el bug con detalles específicos

---

**Creado por DarckRovert (Ingame: Thesaviour)**
