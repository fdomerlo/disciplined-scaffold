# Manual — disciplined-scaffold

Guía de uso completa para el equipo. Cubre instalación en las superficies
soportadas, los tres flujos de trabajo, gobernanza para uso en equipo, y
troubleshooting.

*(Este manual está en español porque es la lengua de trabajo del equipo.
El contenido que la skill genera — código, commits, `AGENTS.md`,
`PLAN-N.md` — siempre queda en inglés, por diseño; ver sección 2.)*

---

## 1. Qué es, en tres líneas

`disciplined-scaffold` es una skill que instala dos cosas en un repo:
un contrato de convenciones para cualquier agente de IA que trabaje ahí
(commits convencionales, tests antes de cada commit, nunca dejar la suite
en rojo), y — cuando el trabajo lo amerita — un ciclo de planificación por
fases (`PLAN-N.md`) donde el agente ejecuta una fase por sesión, marca los
criterios cumplidos al cerrarla, y el humano audita cada diff antes de
mergear.

No reemplaza buen criterio. Formaliza el que ya tenían las personas del
equipo que trabajaban bien con agentes, para que todos lo tengan desde el
primer día en cualquier repo nuevo.

## 2. Alcance honesto — leer antes de instalar

Esto es un **contrato de prosa**: un archivo que el agente lee y, con
buena probabilidad, sigue. No hay estado en disco a prueba de crash, no
hay locks, no hay nada que se recupere solo si una sesión muere a mitad de
una fase. Eso es aceptable para la enorme mayoría del trabajo — es
literalmente lo mismo que ya hacía cualquier desarrollador disciplinado
antes de que existieran agentes. Si algún proyecto del equipo necesita
memoria transaccional real (estado que sobrevive un crash, aprobación
enforced en código, múltiples agentes coordinando sobre el mismo estado),
esa es una herramienta distinta — ver sección 9.

Esto incluye los checkboxes de los planes: **marcar un criterio como
cumplido es un acto cooperativo del mismo agente que hizo el trabajo.**
Hace visible el estado, no lo hace verdadero. La skill le exige marcar
solo lo que puede demostrar en el momento, y dejar sin marcar lo que
requiere verificación humana — pero eso sigue siendo una regla que se
respeta, no un mecanismo que se impone.

La única pieza de esta skill que **sí** está enforced en código, no en
prosa, es el hook de commits (sección 8). Todo lo demás depende de que el
agente lo respete.

## 3. Instalación

### 3.1 Decisión de equipo: scope de proyecto, no personal

Instalá la skill **dentro de cada repo** (`.claude/skills/`), commiteada
al control de versiones — no como skill global personal de cada
integrante (`~/.claude/skills/`). Razón concreta, no preferencia
estética: si cada persona la instala globalmente y alguien edita su copia
para un caso puntual, en semanas el equipo termina con N versiones
ligeramente distintas del mismo contrato, sin que nadie lo note hasta que
alguien pregunta por qué el review de otro compañero exige cosas
distintas. Con la skill versionada en el repo, un cambio al contrato es un
PR normal, revisado como cualquier otro — el propio proceso de review es
el control de calidad de la skill.

```bash
mkdir -p .claude/skills
# extraer el .skill (es un zip) directo en el destino:
unzip disciplined-scaffold.skill -d .claude/skills/
git add .claude/skills/disciplined-scaffold
git commit -m "chore: add disciplined-scaffold skill"
```

Con esto, cualquiera que clone el repo la tiene disponible sin paso manual.

### 3.2 Claude Code CLI

Cubierto por 3.1 si se instaló a nivel de proyecto. Se descubre sola al
abrir Claude Code en el repo. Invocación manual disponible con
`/disciplined-scaffold` si querés forzarla sin depender de que el agente
la considere relevante por su cuenta.

### 3.3 Antigravity CLI

Misma carpeta sirve: Antigravity CLI lee skills de workspace en
`.agents/skills/`. Si preferís consistencia entre hosts, copiá el mismo
contenido ahí también:

```bash
mkdir -p .agents/skills
cp -r .claude/skills/disciplined-scaffold .agents/skills/
```

*(Nota de mantenimiento: son dos copias físicas hasta que unifiquemos el
mecanismo de instalación entre hosts — si el equipo actualiza el
contrato, hay que actualizar las dos carpetas en el mismo commit. Vale la
pena automatizar esto con un script si el equipo crece.)*

### 3.4 OpenCode — requiere un paso extra

OpenCode no carga skills de forma nativa. Hace falta un command que
apunte al contenido en vez de duplicarlo:

`.opencode/commands/scaffold.md`:
```markdown
---
description: Bootstrap this repo or start a plan cycle using disciplined-scaffold
---
Read `.claude/skills/disciplined-scaffold/SKILL.md` and follow it for: $ARGUMENTS
```

### 3.5 Claude Chat (para uso individual, no de equipo)

Cada persona puede además guardarla en su cuenta personal de Claude vía el
botón *Save skill* al recibir el archivo `.skill` — útil para planificar
desde el chat antes de tener un repo abierto. Esto es individual y no
sustituye la instalación de equipo de 3.1.

## 4. Los archivos de contrato: `AGENTS.md` + `CLAUDE.md`

La skill escribe el contrato **una sola vez**, en `AGENTS.md` en la raíz
del repo. Ese es el formato que leen de forma nativa OpenCode,
Antigravity, Codex y Cursor.

Claude Code **no lee `AGENTS.md`** (sigue sin soportarlo a julio de 2026,
pese a un pedido muy votado en su repositorio). La solución, que es la que
la propia documentación de Anthropic recomienda, es un `CLAUDE.md` en la
raíz con una sola línea:

```
@AGENTS.md
```

Eso importa el contrato sin duplicarlo. Existe también la variante de
symlink (`ln -s AGENTS.md CLAUDE.md`), igual de oficial, pero requiere
modo desarrollador o permisos elevados en Windows — por eso la skill usa
el import por defecto.

**Regla de oro del equipo: nunca copiar la prosa del contrato en los dos
archivos.** Dos copias de un contrato son dos contratos, y van a divergir.
Si alguien encuentra un `CLAUDE.md` con contenido propio en un repo del
equipo, es un bug: hay que consolidarlo en `AGENTS.md` y dejar el import.

## 5. Flujo A — Bootstrap de un repo

Cuándo: repo nuevo, o uno existente sin convenciones claras para agentes.

**Ejemplo de interacción real:**

> **Vos:** "Arrancamos un proyecto nuevo en Python con FastAPI, quiero
> setear las convenciones para trabajar con agentes."
>
> **Agente** (consulta la skill, pregunta lo mínimo):
> "¿Qué comando corre la suite de tests? ¿Instalo también el git hook que
> rechaza commits que no sigan conventional commits?"
>
> **Vos:** "pytest, y sí al hook."
>
> **Agente:** escribe `AGENTS.md` con el contrato completo (commits
> convencionales, `pytest` como test command, la cláusula de "plan mode"),
> escribe `CLAUDE.md` con el import de una línea, instala
> `.git/hooks/commit-msg`, y reporta qué escribió.

Resultado: dos archivos y un hook, listos para que cualquier persona o
agente que trabaje en ese repo desde ahora siga las mismas reglas.

## 6. Flujo B — Ciclo de plan por fases

Cuándo: el trabajo va a llevar más de una sesión, más de una persona va a
tocar el diff antes de mergear, o un error ahí sale caro. Un fix de un
archivo no necesita esto — pedirlo directo, con buen mensaje de commit, es
más disciplinado que la ceremonia de un plan innecesario.

**Ejemplo de interacción real:**

> **Vos:** "Necesitamos migrar el sistema de autenticación de sesiones a
> JWT. Es grande, va a llevar varias sesiones de trabajo."
>
> **Agente** (antes de escribir nada, pregunta lo que cambiaría la forma
> del plan, con su recomendación adjunta):
> "¿Los refresh tokens rotativos entran en este ciclo o quedan para otro?
> Recomiendo dejarlos afuera: duplican el alcance de F1 y no bloquean la
> migración. ¿De acuerdo?"
>
> **Vos:** "De acuerdo, afuera."
>
> **Agente:** crea `PLAN-1.md` en la raíz del repo, con el objetivo en una
> oración, evidencia de por qué, y fases concretas (F1: capa de emisión y
> validación de tokens; F2: migración de los endpoints; F3: deprecar el
> sistema viejo), cada una con spec, tests, y criterios de aceptación
> **como checkboxes**. Incluye "Out of scope" explícito con los refresh
> tokens. Antes de entregarlo hace una auto-auditoría y te la reporta en
> dos líneas: *"revisé el plan: F2 tenía un criterio no verificable, lo
> reescribí."*
>
> **Vos:** revisás el plan, ajustás lo que haga falta, y confirmás.
>
> **En cada sesión posterior**, alguien del equipo tipea:
> "Ejecutá la Fase F1 según PLAN-1.md."
>
> El agente trabaja *solo esa fase*, y al terminar hace el cierre de fase
> (sección 7). Se detiene ahí — alguien del equipo audita el diff antes de
> mergear, como cualquier PR.

Si el agente encuentra el plan ambiguo o cree que está mal planteado,
**para y pregunta** en vez de adivinar — es la regla no negociable de todo
el sistema. Si hay una decisión que solo el equipo puede tomar, el plan
puede entregarse igual, pero con esa decisión marcada como bloque
`## DECISIÓN ABIERTA` que el ejecutor tiene prohibido pasar de largo.

## 7. Flujo C — Cierre de fase y cierre de ciclo

Novedad de la v2. Son dos momentos distintos:

**Al terminar una fase**, antes de que nadie empiece la siguiente, el
agente:

1. Marca `- [x]` **solo** los criterios de aceptación que puede demostrar
   en ese momento — un test que corrió recién, un comando cuya salida
   tiene a la vista. Lo que requiere verificación humana (una sesión real
   en un host, algo visual) queda sin marcar y lo dice explícitamente:
   *"el criterio 3 de F2 necesita tu chequeo en OpenCode real, lo dejo sin
   marcar."*
2. Escribe el reporte: tabla de archivos cambiados, tests agregados **con
   qué ataque o regresión protege cada uno**, desviaciones del plan con su
   justificación, hallazgos que van a "Out of scope", y preguntas abiertas.
3. Se detiene.

**Al cerrar el ciclo** (después de la última fase, o cuando alguien
pregunta "¿qué falta?"), el agente hace una pasada de solo lectura:
lista los criterios sin marcar y clasifica cada uno (no hecho / hecho pero
no verificable por él / obsoleto porque el diseño cambió), compara el diff
real del ciclo contra lo que el plan pedía **en ambas direcciones** (¿hay
algo en el repo que ninguna fase pidió? ¿algo que una fase pidió y no
está?), nombra cualquier fuga de "Out of scope", y escribe los pendientes
donde el equipo los guarde. No abre el plan siguiente por su cuenta — eso
lo decide el equipo.

## 8. El git hook de commits convencionales

Instalado en `.git/hooks/commit-msg`. Rechaza cualquier primera línea de
commit que no siga el patrón `tipo(scope): descripción`, con tipos
`feat, fix, docs, refactor, test, chore, release`. Ejemplos:

| Mensaje | Resultado |
|---|---|
| `feat(auth): add JWT validation` | ✅ pasa |
| `fix: correct token expiry check` | ✅ pasa |
| `Update auth.py` | ❌ rechazado |

Bypass para una emergencia real: `git commit --no-verify`. Cada persona
del equipo debería saber que existe — un hook que nadie sabe esquivar en
un apuro termina desinstalado en vez de respetado.

**Antes de instalar el hook en un repo del equipo, alguien debería leer
`scripts/commit-msg-hook.sh` una vez** — es corto (20 líneas) y no hace
nada más que lo descripto acá, pero cualquier script que se instala como
git hook merece esa revisión, sin excepciones, aunque lo hayamos escrito
nosotros mismos.

## 9. Relación con context-guard — cuándo usar cada una

`disciplined-scaffold` y `context-guard` son herramientas hermanas, no una
reemplaza a la otra:

- **Solo disciplina de commits + ciclos planificados**, sin necesidad de
  que el estado sobreviva un crash entre sesiones → `disciplined-scaffold`
  alcanza, y es más liviano.
- **Memoria transaccional real** — estado que se recupera solo tras un
  crash, aprobación humana enforced en código (no solo en texto), conteo
  determinista de tareas que el agente no puede falsear, varios agentes
  coordinando sobre el mismo trabajo sin pisarse → hace falta
  `context-guard` (`uv tool install context-guard-cli`).

**Camino de ascenso:** un `PLAN-N.md` generado por esta skill es el
formato de entrada que `context-guard` sabe leer. Si a mitad de un ciclo
el trabajo resulta más caro de lo previsto, se puede subir de categoría
sin reescribir el plan a mano.

No se instalan una dentro de la otra. Un mismo repo puede perfectamente
tener las dos si el proyecto lo justifica: el contrato de
`disciplined-scaffold` para el día a día, y `context-guard` para los
ciclos de trabajo donde perder una sesión sería costoso.

## 10. Troubleshooting

**"El agente no usa la skill aunque describí una tarea grande."**
La activación es por relevancia de la description, no garantizada.
Invocación manual: `/disciplined-scaffold` en Claude Code fuerza la carga.
En claude.ai chat, sé más explícito en el pedido ("quiero un PLAN de
fases para esto").

**"Claude Code no ve el contrato."** Verificá que exista `CLAUDE.md` en la
raíz con la línea `@AGENTS.md`. Sin ese archivo, Claude Code ignora el
`AGENTS.md` por completo — no es un bug de la skill, es una limitación
conocida de Claude Code (sección 4).

**"El agente marcó un criterio que no está cumplido."** Es el modo de
falla conocido de los checkboxes (sección 2): son cooperativos. Corregilo
en el plan, y si pasa seguido con un modelo en particular, considerá
`context-guard` para ese proyecto — su conteo de tareas es determinista y
no depende del criterio del agente.

**"El hook rechaza un mensaje que me parece válido."**
Revisá que tenga el formato `tipo(scope): descripción` — el scope entre
paréntesis es opcional, pero el `tipo:` y el espacio después de los dos
puntos son obligatorios. Si de verdad hace falta un commit fuera de
formato (un merge automático, por ejemplo), `--no-verify`.

**"Dos integrantes tienen contratos distintos en el mismo repo."** Solo
puede pasar si alguien editó el `AGENTS.md` generado directamente en vez
de proponer el cambio por PR contra la skill (sección 11). El contrato de
un repo es único y versionado como cualquier otro archivo — no hay copias
personales.

**"¿Puedo usar esto sin instalar el hook?"** Sí, es opcional en ambos
flujos. El contrato en `AGENTS.md` sigue pidiendo commits convencionales;
sin el hook, esa regla queda como las demás — cooperativa, no forzada.

## 11. Gobernanza — cómo evoluciona el contrato sin divergir

Una vez que la skill está en varios repos del equipo, van a surgir pedidos
de cambio: un tipo de commit adicional, una regla nueva de estilo. Tratarlo
como código, no como convención verbal:

1. Cambios al `SKILL.md`, a los templates de `assets/` o a las referencias
   de `references/` se proponen por PR contra el repo donde vive la skill
   (o contra cada proyecto, si no hay un repo central — ver punto 3).
2. El PR se revisa como cualquier otro — la revisión de equipo es el
   control de calidad del contrato en sí.
3. Si el equipo tiene varios repos con esta skill instalada, considerá
   centralizarla en un repo propio (`team-skills` o similar) e
   incorporarla a cada proyecto como submódulo o mediante un script de
   sync corto — evita que un fix al contrato tenga que repetirse a mano en
   cada repo. No lo automaticen antes de que la fricción de mantenerlo a
   mano sea real; con dos o tres repos, copiar a mano en el mismo PR
   alcanza.

## 12. Referencia rápida

| Acción | Comando / paso |
|---|---|
| Instalar en un repo (equipo) | `unzip disciplined-scaffold.skill -d .claude/skills/`, commitear |
| Arrancar el contrato en un repo nuevo | Pedile al agente que bootstrapee el repo (Flujo A) |
| Empezar un trabajo grande | Pedile al agente un plan de fases (Flujo B) |
| Ejecutar una fase | `"Ejecutá la Fase F{N} según PLAN-{N}.md"` |
| Cerrar una fase | `"Terminé F{N}"` → marca checkboxes y reporta (Flujo C) |
| Ver qué falta al final del ciclo | `"¿Qué quedó pendiente?"` (Flujo C) |
| Forzar la skill en Claude Code | `/disciplined-scaffold` |
| Bypass del hook en una emergencia | `git commit --no-verify` |
| ¿Necesito memoria transaccional real? | Ver sección 9 → `context-guard` |

---

## Changelog del manual

**v2** — `AGENTS.md` pasa a ser el contrato único (con `CLAUDE.md` como
import de una línea); criterios de aceptación como checkboxes que se
marcan al cerrar cada fase; nuevo Flujo C (cierre de fase y de ciclo); el
agente interroga ambigüedades de alto impacto y auto-audita el plan antes
de entregarlo; camino de ascenso a `context-guard` documentado.
