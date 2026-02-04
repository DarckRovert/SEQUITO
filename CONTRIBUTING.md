# 🤝 Guía de Contribución - Sequito

**Versión:** 7.1.0  
**Autor:** DarckRovert (Ingame: Eljesuita)

---

## 👋 Bienvenido

¡Gracias por tu interés en contribuir a Sequito! Este documento proporciona guías y mejores prácticas para contribuir al proyecto.

---

## 📝 Índice

1. [Código de Conducta](#código-de-conducta)
2. [Cómo Contribuir](#cómo-contribuir)
3. [Reportar Bugs](#reportar-bugs)
4. [Sugerir Funcionalidades](#sugerir-funcionalidades)
5. [Desarrollo](#desarrollo)
6. [Estilo de Código](#estilo-de-código)
7. [Testing](#testing)
8. [Documentación](#documentación)
9. [Pull Requests](#pull-requests)

---

## 📜 Código de Conducta

### Nuestro Compromiso

En el interés de fomentar un ambiente abierto y acogedor, nos comprometemos a hacer de la participación en nuestro proyecto una experiencia libre de acoso para todos.

### Nuestros Estándares

**Comportamientos que contribuyen a crear un ambiente positivo:**

- ✅ Usar lenguaje acogedor e inclusivo
- ✅ Respetar puntos de vista y experiencias diferentes
- ✅ Aceptar críticas constructivas con gracia
- ✅ Enfocarse en lo que es mejor para la comunidad
- ✅ Mostrar empatía hacia otros miembros

**Comportamientos inaceptables:**

- ❌ Uso de lenguaje o imágenes sexualizadas
- ❌ Trolling, comentarios insultantes o ataques personales
- ❌ Acoso público o privado
- ❌ Publicar información privada de otros sin permiso
- ❌ Conducta que podría considerarse inapropiada en un entorno profesional

---

## 🚀 Cómo Contribuir

Hay muchas formas de contribuir a Sequito:

### 1. 🐛 Reportar Bugs

Encontraste un bug? ¡Ayúdanos a arreglarlo!

### 2. 💡 Sugerir Funcionalidades

¿Tienes una idea para mejorar Sequito? ¡Queremos escucharla!

### 3. 📝 Mejorar Documentación

La documentación siempre puede mejorar. Correcciones, aclaraciones o traducciones son bienvenidas.

### 4. 🛠️ Desarrollar Código

Contribuye con código para nuevas funcionalidades o correcciones de bugs.

### 5. 🧪 Testing

Prueba nuevas versiones y reporta problemas.

### 6. 🎨 Diseño

Mejora la interfaz visual del addon.

---

## 🐛 Reportar Bugs

### Antes de Reportar

1. **Verifica que sea un bug**: Asegúrate de que no sea un problema de configuración
2. **Busca duplicados**: Revisa si ya fue reportado
3. **Verifica la versión**: Asegúrate de usar la última versión
4. **Lee el FAQ**: Revisa [FAQ.md](FAQ.md) para soluciones comunes

### Cómo Reportar un Bug

Incluye la siguiente información:

#### 1. Información del Sistema
```
- Versión de Sequito: 2.2.0
- Versión de WoW: 3.3.5a
- Servidor: UltimoWoW / Warmane / etc.
- Otros addons instalados: DBM, Recount, etc.
```

#### 2. Descripción del Bug
- **Título claro**: "Error al generar macros para Warlock Affliction"
- **Descripción detallada**: Qué esperabas vs qué sucedió

#### 3. Pasos para Reproducir
```
1. Entra al juego con un Warlock nivel 80
2. Cambia a spec Affliction
3. Ejecuta /sequito macros
4. Observa el error
```

#### 4. Mensaje de Error
```lua
[Sequito] Error: MacroGenerator.lua:123: attempt to index nil value
```

#### 5. Comportamiento Esperado
"Debería crear 4 macros para Affliction Warlock"

#### 6. Screenshots (si aplica)
Adjunta capturas de pantalla del error.

---

## 💡 Sugerir Funcionalidades

### Antes de Sugerir

1. **Verifica el roadmap**: Revisa [CHANGELOG.md](CHANGELOG.md) para ver si ya está planeado
2. **Busca duplicados**: Verifica si alguien más ya lo sugirió
3. **Considera el alcance**: ¿Es apropiado para Sequito?

### Cómo Sugerir una Funcionalidad

Incluye:

#### 1. Título Descriptivo
"Añadir soporte para macros de PvP"

#### 2. Problema que Resuelve
"Actualmente las macros solo están optimizadas para PvE, pero muchos jugadores hacen PvP"

#### 3. Solución Propuesta
"Añadir un comando `/sequito macros pvp` que genere macros optimizadas para arenas y battlegrounds"

#### 4. Alternativas Consideradas
"Podría ser un toggle en opciones, pero un comando separado es más flexible"

#### 5. Beneficio para la Comunidad
"Beneficiaría a jugadores que hacen tanto PvE como PvP"

---

## 🛠️ Desarrollo

### Configuración del Entorno

#### 1. Requisitos
- World of Warcraft 3.3.5a instalado
- Editor de texto (VS Code, Sublime, Notepad++)
- Conocimientos de Lua 5.1
- Conocimientos de WoW API

#### 2. Clonar el Proyecto
```bash
cd "Interface/AddOns"
git clone [URL_DEL_REPO] Sequito
```

#### 3. Estructura del Proyecto
```
Sequito/
├── Sequito.toc          # Tabla de contenidos
├── Sequito.lua          # Core principal
├── Embeds.xml           # Orden de carga
├── Core/                # Módulos core
├── Data/                # Datos estáticos
├── Locales/             # Localizaciones
├── Modules/             # Módulos funcionales
└── Docs/                # Documentación
```

#### 4. Habilitar Errores de Lua
En el juego:
```
/console scriptErrors 1
```

---

### Crear un Nuevo Módulo

#### 1. Crear el Archivo
```lua
-- Modules/MiModulo.lua

local MODULE_NAME = "MiModulo"

-- Variables privadas
local miVariable = {}

-- Función de inicialización
function Sequito_MiModulo_Init()
    print("[Sequito] MiModulo inicializado")
end

-- Funciones públicas
function Sequito_MiModulo_MiFuncion()
    -- Tu código aquí
end

-- Funciones privadas
local function FuncionPrivada()
    -- Código interno
end
```

#### 2. Registrar en Embeds.xml
```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
    <!-- ... otros módulos ... -->
    <Script file="Modules/MiModulo.lua"/>
</Ui>
```

#### 3. Inicializar en Sequito.lua
```lua
function Sequito_OnLoad()
    -- ... otras inicializaciones ...
    Sequito_MiModulo_Init()
end
```

---

## 🎨 Estilo de Código

### Convenciones de Nombres

#### Funciones Públicas
```lua
function Sequito_ModuleName_FunctionName()
    -- CamelCase después del prefijo
end
```

#### Funciones Privadas
```lua
local function PrivateFunctionName()
    -- CamelCase, sin prefijo
end
```

#### Variables Globales
```lua
SEQUITO_MODULE_VARIABLE = "value"
-- MAYUSCULAS con guiones bajos
```

#### Variables Locales
```lua
local myVariable = "value"
-- camelCase
```

---

### Formato de Código

#### Indentación
- **4 espacios** (no tabs)

```lua
function MyFunction()
    if condition then
        DoSomething()
    end
end
```

#### Líneas en Blanco
- Una línea en blanco entre funciones
- Dos líneas en blanco entre secciones

```lua
function Function1()
    -- code
end

function Function2()
    -- code
end


-- Nueva sección
function Function3()
    -- code
end
```

#### Comentarios
```lua
-- Comentario de una línea

--[[
    Comentario de
    múltiples líneas
]]

--- Comentario de documentación
-- @param name string - Nombre del jugador
-- @return boolean - true si exitoso
function MyFunction(name)
    -- code
end
```

---

### Mejores Prácticas

#### 1. Usar Variables Locales
```lua
-- Mal
function MyFunction()
    result = DoSomething()  -- Variable global
end

-- Bien
function MyFunction()
    local result = DoSomething()  -- Variable local
end
```

#### 2. Validar Parámetros
```lua
function Sequito_MyFunction(name)
    if not name or name == "" then
        Sequito_Print("Error: nombre inválido")
        return false
    end
    
    -- Código principal
    return true
end
```

#### 3. Manejar Errores
```lua
function Sequito_SafeFunction()
    local success, result = pcall(function()
        -- Código que puede fallar
        return RiskyOperation()
    end)
    
    if not success then
        Sequito_Print("Error: " .. tostring(result))
        return nil
    end
    
    return result
end
```

#### 4. Documentar Funciones Públicas
```lua
--- Genera macros para la clase y spec actual
-- @return boolean - true si se generaron exitosamente
function Sequito_MacroGenerator_CreateMacros()
    -- code
end
```

---

## 🧪 Testing

### Testing Manual

#### 1. Prueba Básica
- Carga el addon sin errores
- Ejecuta comandos principales
- Verifica que no haya errores de Lua

#### 2. Prueba por Clase
- Prueba con diferentes clases
- Verifica generación de macros
- Verifica detección de spec

#### 3. Prueba en Raid
- Prueba sincronización con otros jugadores
- Verifica comandos tácticos
- Verifica panel de raid

#### 4. Prueba de Rendimiento
- Verifica uso de memoria
- Verifica lag en raids grandes
- Verifica actualizaciones frecuentes

---

### Checklist de Testing

```markdown
- [ ] El addon carga sin errores
- [ ] Todos los comandos funcionan
- [ ] Las macros se generan correctamente
- [ ] La detección de spec funciona
- [ ] El cambio de spec actualiza macros (si auto-update está activado)
- [ ] La sincronización de raid funciona
- [ ] El panel de raid muestra información correcta
- [ ] Los comandos tácticos se envían/reciben
- [ ] El seguimiento de combate funciona
- [ ] Las opciones se guardan correctamente
- [ ] No hay conflictos con otros addons comunes
- [ ] La documentación está actualizada
```

---

## 📚 Documentación

### Actualizar Documentación

Cuando añades o cambias funcionalidad, actualiza:

1. **README.md** - Si cambia la descripción general
2. **USAGE.md** - Si añades comandos o funcionalidades
3. **COMMANDS.md** - Si añades nuevos comandos
4. **MODULES.md** - Si creas o modificas módulos
5. **API.md** - Si añades funciones públicas
6. **CHANGELOG.md** - Siempre documenta cambios
7. **FAQ.md** - Si hay preguntas comunes sobre la nueva funcionalidad

---

### Formato de Documentación

- Usa **Markdown** para todos los documentos
- Incluye ejemplos de código cuando sea relevante
- Usa emojis para mejorar legibilidad (🚀 🐛 💡 etc.)
- Mantén un tono amigable y accesible

---

## 🔀 Pull Requests

### Antes de Enviar un PR

1. **Crea un branch**: No trabajes directamente en `main`
   ```bash
   git checkout -b feature/mi-nueva-funcionalidad
   ```

2. **Sigue el estilo de código**: Revisa la sección de estilo

3. **Prueba tu código**: Asegúrate de que funciona

4. **Actualiza documentación**: Documenta tus cambios

5. **Actualiza CHANGELOG.md**: Añade tus cambios

---

### Estructura del PR

#### Título
```
[Feature] Añadir soporte para macros de PvP
[Fix] Corregir error en detección de spec para Druids
[Docs] Actualizar guía de instalación
```

#### Descripción
```markdown
## Descripción
Añade soporte para generar macros optimizadas para PvP.

## Cambios
- Añadido comando `/sequito macros pvp`
- Añadidas macros de PvP para todas las clases
- Actualizada documentación en USAGE.md y COMMANDS.md

## Testing
- [x] Probado con Warlock en arenas
- [x] Probado con Mage en battlegrounds
- [x] Verificado que no rompe macros de PvE

## Screenshots
[Adjuntar si aplica]

## Checklist
- [x] Código sigue el estilo del proyecto
- [x] Documentación actualizada
- [x] CHANGELOG.md actualizado
- [x] Testing completado
```

---

### Proceso de Revisión

1. **Envía el PR**: Describe claramente tus cambios
2. **Revisión**: El mantenedor revisará tu código
3. **Feedback**: Puede haber comentarios o solicitudes de cambios
4. **Iteración**: Realiza los cambios solicitados
5. **Aprobación**: Una vez aprobado, se fusionará
6. **Merge**: Tu código se integrará al proyecto

---

## 🎉 Reconocimientos

Todos los contribuidores serán reconocidos en:

- **README.md** - Sección de agradecimientos
- **CHANGELOG.md** - En la versión correspondiente
- **Créditos en el juego** - En el addon

---

## 📞 Contacto

Si tienes preguntas sobre cómo contribuir:

- Revisa la documentación existente
- Pregunta en los issues
- Contacta al mantenedor

---

## 📝 Licencia

Al contribuir a Sequito, aceptas que tus contribuciones serán licenciadas bajo la misma licencia que el proyecto.

Ver [LICENSE.md](LICENSE.md) para detalles.

---

## 🙏 Agradecimientos

¡Gracias por contribuir a Sequito! Tu ayuda hace que este proyecto sea mejor para toda la comunidad.

---

**Creado por DarckRovert (Ingame: Eljesuita)**
