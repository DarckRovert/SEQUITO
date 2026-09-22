## 📋 Resumen del Cambio

Por favor incluye un resumen de los cambios introducidos y el problema o funcionalidad que resuelve.

- **Tipo de cambio:**
  - [ ] Corrección de bug (`fix`)
  - [ ] Nueva funcionalidad (`feat`)
  - [ ] Optimización de rendimiento / memoria (`perf`)
  - [ ] Refactorización (`refactor`)
  - [ ] Documentación (`docs`)
  - [ ] Localización / Traducción (`locale`)

---

## 🧪 Pruebas Realizadas

Describe cómo verificaste los cambios:
- [ ] Verificación sintáctica en Lua 5.1 (sin errores de compilación).
- [ ] Probado en cliente World of Warcraft 3.3.5a (Build 12340).
- [ ] Verificado en combate (`InCombatLockdown`): Cero errores de Taint / interfaz bloqueada.
- [ ] Verificado con locales `esMX` y `enUS`.
- [ ] Probado en grupo o banda (si afecta mensajería de addon).

---

## 🛡️ Lista de Verificación (Checklist)

- [ ] Mi código sigue las pautas de estilo descritas en [CONTRIBUTING.md](../CONTRIBUTING.md).
- [ ] He realizado una auto-revisión meticulosa de mi propio código.
- [ ] No se utilizan APIs de versiones posteriores a 3.3.5a (e.g. `GROUP_ROSTER_UPDATE`, `C_Timer`, etc.).
- [ ] Los nombres de módulos siguen la convención `S.<Modulo>`.
- [ ] Mis cambios no generan advertencias ni llamadas huérfanas en el arranque.
