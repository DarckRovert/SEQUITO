# 📜 Guía de Macros - Sequito (Necrosis Edition)

**Sequito** genera macros inteligentes inspiradas en Necrosis. Estas macros se adaptan dinámicamente a tu clase, especialización y hechizos aprendidos.

---

## 🔮 Universal (Todas las Clases)

Estas macros están disponibles para todos los personajes:

### [SeqRacial] (Macro Racial)
Utiliza tu habilidad racial activa con un grito de batalla personalizado.
- **Orc**: Furia Sangrienta ("¡Por el Sequito del Terror!")
- **Troll**: Rabiar
- **Human**: Sálvese quien pueda
- **Undead**: Voluntad de los Renegados
- ... y todas las demás razas.

### [SeqMount] (Montura Inteligente)
Un solo botón para todas tus necesidades de transporte.
- Detecta si puedes volar (Invoca montura voladora).
- Si no puedes volar, invoca montura terrestre.
- Desmonta si estás montado.

---

## ☠️ Death Knight (Necrosis Style)

### [SeqStart] (Inicio Inteligente)
- Selecciona enemigo más cercano.
- Manda a la pet a atacar.
- Lanza tu opener (Toque Helado).

### [SeqGrip] (Atracción)
- Prioridad: Focus > Mouseover > Target.
- Atrae al enemigo a tu posición.

### [SeqInt] (Interrumpir)
- Prioridad: Focus > Mouseover > Target.
- Usa Helada Mental.
- **Shift**: Usa Estrangular.

### [SeqHeal] (Autosanación)
- Transfusión de Runa.
- **Shift**: Pacto de la Muerte (Sacrifica pet).
- Usa Poción de Sanación Rúnica si está en la bolsa.

---

## 🔮 Warlock (Necrosis Style)

### [SeqStart]
- Opener inteligente según Spec (Corrupción / Inmolar / Metamorfosis).

### [SeqPet] (Control Total)
- **Clic**: Pet Atacar.
- **Clic Derecho**: Pet Seguir.
- **Shift + Clic**: Habilidad Especial (Prioridad Mouseover > Focus > Target).
  - Imp: Huida / Escudo de Fuego.
  - Voidwalker: Sacrificio / Consumir Sombras.
  - Succubus: Seducción.
  - Felhunter: Bloqueo de Hechizo / Devorar Magia.

### [SeqHeal] (Supervivencia)
- **Clic**: Usar Piedra de Salud.
- **Clic Derecho**: Crear Piedra de Salud (si no tienes).
- **Shift**: Canalizar Salud (Curar pet).

### [SeqBanish] / [SeqFear]
- Prioridad: Focus > Mouseover > Target.
- Mantiene a tu objetivo principal seleccionado mientras controlas al add.

---

## 🛡️ Paladin

### [SeqBubble] (La "Vieja Confiable")
- Lanza Escudo Divino.
- Usa Piedra de Hogar.
- Grita frase de inmunidad.

### [SeqPull]
- Lanza Escudo de Vengador.
- Grita aviso de Pull.

### [SeqHeal]
- Prioridad: Mouseover > Target > Self.
- Lanza Choque Sagrado (Holy) o Destello de Luz.
- Anuncia curación crítica.

---

## 🐺 Shaman

### [SeqLust] (Ansia/Heroísmo)
- Detecta automáticamente si eres Horda (Ansia de Sangre) o Alianza (Heroísmo).
- Grita a la raid para avisar del buff.

### [SeqWolves]
- Invoca Espíritu Feral + Ira del Chamán.
- Grita frase de manada.

---

## 🏹 Hunter / 🗡️ Rogue

### [SeqMD] (Hunter) / [SeqTricks] (Rogue)
- Redirección / Secretos del Oficio.
- Prioridad: Focus > Pet > Target.
- Avisa al objetivo por susurro/chat.

---

## ⚕️ Priest / 🌿 Druid / 🗡️ Warrior

### [SeqHymn] (Priest)
- Himno Divino con cuenta atrás en chat.

### [SeqRez] (Druid)
- Renacer (Brez) con frase de rol de Necrosis.

### [SeqWall] (Warrior)
- Muro de Escudo + Grito de batalla.

---

## ❓ Preguntas Frecuentes

**¿Por qué mis macros tienen texto de rol?**
Es una característica "Flavor" importada de Necrosis para mayor inmersión.

**¿Se actualizan solas?**
Sí, cada vez que aprendes un hechizo nuevo o cambias de talentos, Sequito regenera las macros para asegurar que siempre use el rango máximo y los hechizos correctos.

**¿Qué pasa si no tengo el hechizo?**
El sistema "Real Data" verifica si `IsSpellKnown` es verdadero. Si no sabes el hechizo, la macro no se creará o usará una alternativa válida.

---

## 🔄 MacroSync - Sistema de Macros Compartidos (v7.1.0)

Nuevo en v7.1.0: Comparte y sincroniza macros con otros usuarios de Sequito.

### Comandos de MacroSync

| Comando | Descripción |
|---------|-------------|
| `/sequito macro share <nombre>` | Comparte un macro con tu grupo/raid |
| `/sequito macro list` | Lista macros recibidos de otros jugadores |
| `/sequito macro import <nombre>` | Importa un macro compartido |
| `/sequito macro library` | Muestra biblioteca de macros de tu clase |
| `/sequito macro getlib <nombre>` | Importa macro de la biblioteca |
| `/sequito macro getall` | Importa todos los macros de tu clase |
| `/sequito macro request` | Solicita lista de macros del grupo |

### Biblioteca de Macros por Clase

MacroSync incluye una biblioteca integrada con macros probados para cada clase:

- **Warlock**: Drain Tank, Fear Juggling, Soulstone Macro, Pet Control, DoT Weaving
- **Death Knight**: Frost Opener, Blood Tank, Unholy Burst, AMS Timing, Chains Pull
- **Paladin**: Holy Shock Weave, Bubble Hearth, Righteous Defense, Sacred Shield, Divine Plea
- **Mage**: Spell Steal, Counterspell Focus, Ice Block Cancel, Arcane Blast Stack, Living Bomb Spread
- **Hunter**: Misdirection, Tranq Shot, Disengage Jump, Rapid Fire Macro, Pet Dismiss
- **Rogue**: Tricks of Trade, Cloak Cancel, Vanish Sap, Kidney Shot Focus, Fan of Knives
- **Priest**: Pain Suppression, Guardian Spirit, Mass Dispel, Prayer of Mending, Fade Macro
- **Warrior**: Heroic Throw Pull, Shield Wall, Spell Reflect, Charge Intercept, Sunder Stack
- **Shaman**: Bloodlust Announce, Wind Shear Focus, Grounding Totem, Chain Heal Bounce, Earth Shield
- **Druid**: Innervate, Rebirth Announce, Bear Form Panic, Cyclone Focus, Lifebloom Stack
