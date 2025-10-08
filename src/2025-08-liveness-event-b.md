---
title: Modelando propiedades de liveness en Event-B
author: Ramiro Garay
date: Agosto, 2025
theme: simple
...

# Antes de empezar...

## Sobre mí

::::::: {.columns}

:::: {.column width="25%"}

![Ramiro Garay](../img/new_profile_cropped.png)

::::

:::: {.column width="75%"}

::: incremental

* Argentino, ex-estudiante de Ingeniería en Informática de la UNL, Santa Fe (2017-2022)
* Desarrollador a medio tiempo para MLabs, una consultora especializada en Blockchain (2022-)
* Estudiante avanzado de Licenciatura en Computación (2025-)
* Actualmente becario PREXI en el LINS

:::

::::

:::::::

## Agenda

::: notes

Objetivos:
  1. Aprender que son las props de liveness y porque importan
  2. como formalizar esto en una lenguaje formal (LTL))
  3. como formalizar propiedades de liveness en Event-B (que es mas que nada safety)
     3.1. Que se puede demostrar facilmente? Convergencia.
     3.2. Como demostrar cosas mas complejas (existencia, persistencia, etc).
     3.3. Desventajas y ventajas de utilizar SOLO event-b para liveness.
     3.4. Posibles soluciones (Meta-theory para hablar de trazas)
  4. Intro a model checking y verificacion de propiedades LTL con ProB
     4.1. Espacio de estados
     4.2. Checkeos exhaustivos vs. no exhaustivos
  5. Bibliografía
     
Ejemplo: PingPong? 

:::

1. Intro a propiedades de liveness
2. Lógica Temporal Lineal (LTL)
3. **Demostración** de propiedades de liveness
4. **Verificación** de propiedades de liveness usando _model checking_

# Propiedades de Liveness (Intro)

## Una definición informal

"Son aquellas propiedades que nos garantizan que el sistema eventualmente va a
hacer **algo**"

. . .

Son fundamentales, ya que permiten representar ciertos comportamientos dinámicos
del sistema.

## Ejemplo: ascensor (I)

Un ascensor debe cumplir propiedades de safety. Por ejemplo:

:::::: {.columns}
:::: {.column width="30%"}
![](../img/ascensor.jpg)
::::
:::: {.column width="70%"}
::: incremental
* El ascensor **nunca** se mueve con la puerta abierta
* El ascensor **nunca** cierra la puerta cuando un usuario es detectado en el umbral
:::
::::
::::::

## Ejemplo: ascensor (II)

Pero también de liveness!

:::::: {.columns}
:::: {.column width="30%"}
![](../img/ascensor.jpg)
::::
:::: {.column width="70%"}
::: incremental
* Si el usuario pide el ascensor, **eventualmente** el mismo viaja hacia
  el piso del usuario.
* Si el usuario seleccionó un piso, **eventualmente** el ascensor va
  a llegar al piso pedido.
:::
::::
::::::

## Ejemplo: ascensor (III)

Un ascensor sin propiedades de liveness puede ser muy seguro, pero también **inútil**.

. . . 

_Ejemplo_: Un ascensor que se mantiene cerrado e inmóvil satisface todas las
propiedades de safety pero **ninguna**  de liveness.

# Un poco de LTL

## Hacia una definición formal

Para hablar de propiedades de liveness es necesario hablar de _tiempo_.

. . .

La Lógica Temporal Lineal (LTL) es una extensión de la _lógica de 1er orden_
que incluye **operadores temporales**

. . .

Los operadores temporales de LTL nos permite expresar cosas como **siempre**,
**después**, **eventualmente**, etc.

::: notes

Por lo tanto, una fórmula LTL se ve muy parecida a una fórmula lógica de 1er orden:
con las conectivas lógicas que ya conocemos (AND, OR, NOT, etc.) y variables lógicas
que pueden ser TRUE o FALSE.

:::

## Estructura de Kripke (I)

La LTL adquiere significado en el contexto de una **estructura de Kripke**.

:::::: {.columns}
:::: {.column width="50%"}
![Máquina de estados](../img/ejemplo_automata.png)
::::
:::: {.column width="50%"}
![](../img/ejemplo_kripke.png)
::::
::::::

::: notes

Una estructura de Kripke es una máquina de estados enriquecida con una función
semántica que hace "labelling".

A cada estado de la máquina esta función asigna un sub-conjunto de todas las
variables lógicas. Este subconjunto nos dice qué variables lógicas son
verdaderas **en este estado particular**.

:::

## Estructura de Kripke (II)

La estructura de Kripke tiene asociada un conjunto de **trazas**. Por ejemplo:

:::::: {.columns}
::::: {.column width="50%"}
![](../img/ejemplo_kripke.png)
:::::
::::: {.column width="50%"}
::: incremental
* $\Omega = s_1, s_2, s_1, s_2, s_1, s_2 ...$
* Una _traza_ es una sucesión de estados generada por la maquina **respetando** las
  restricciones de la misma.
:::
:::::
::::::

::: notes

¿Qué restricciones? Todas las que queramos. En el caso de Event-B: las invariantes
que definamos, las pre-condiciones y post-condiciones de las transiciones, teoremas, etc.

:::

## LTL: Ejemplos (I)

Las trazas pueden satisfacer o no **una fórmula LTL**
$$(\Omega \vdash \phi)$$

. . .

Analizamos la traza:

$$ \Omega = s_1, s_2, s_1, s_2, s_1, s_2 ... $$

## LTL: Ejemplos (II)

:::::: {.columns}
::::: {.column width="50%"}
![](../img/ejemplo_kripke.png)
:::::
::::: {.column width="50%"}

::: incremental
* _Variables lógicas / proposiciones con conectivas lógicas_
  * $$ \Omega \vdash p $$
  * $$ \Omega \vdash \lnot q $$
* _**Operadores temporales**_
  * $$ \Omega \vdash \circ q $$
  * $$ \Omega \vdash \square (p \lor q) $$ 
  * ...
:::

::: notes

Aclarar que cualquier fórmula lógica puede ir a la derecha. Sin operadores temporales,
la misma debe ser cierta solo en el primer estado del camino.

:::

:::::
::::::

## LTL: Ejemplos (III)

Otro ejemplo (**finito**):

$$ \Gamma = s_1, s_2, s_1, s_2, s_3 $$

:::::: {.columns}
::::: {.column width="50%"}
![](../img/ejemplo_kripke.png)
:::::
::::: {.column width="50%"}

$\Gamma$ satisface las mismas propiedades que antes, pero también:

* $$ \Gamma \vdash \lozenge (p \land q) $$

:::::
::::::


# Propiedades de Liveness (en LTL)

## Existencia de $P$ (Definición)


"_**Siempre** es cierto que, **eventualmente** P es verdadero_"

. . .

En LTL:

$\square \lozenge P$

## Existencia de $P$ (Demostración)

Por medio de dos propiedades auxiliares:

1. **Convergencia en $\lnot P$**
2. **$\lnot P$ es libre de deadlocks**

. . .

![](../img/son_hoang_2014_existence_proof_rule.png)

## Persistencia de $P$ (Definición)


"_**Eventualmente** es cierto que, **siempre** P es verdadero_"

. . .

En LTL:

$\lozenge \square P$

## Persistencia de $P$ (Demostración)

Por medio de dos propiedades auxiliares:

1. **Divergencia en $P$**
2. **$\lnot P$ es libre de deadlocks**

. . .

![](../img/son_hoang_2014_persistence_proof_rule.png)

## Progreso de $P_1$ a $P_2$ (Definición)

"_**Siempre** es cierto que, si $P_1$ es verdadero, **eventualmente** $P_2$ lo va a ser_"

. . .

En LTL:

$\square (P_1 \implies \lozenge P_2)$

## Progreso de $P_1$ a $P_2$ (Demostración)

Por medio de varias propiedades auxiliares (no tan simples).

:::::: {.columns}
:::: {.column width="50%"}
![](../img/son_hoang_2014_progress_proof_rule.png)
::::
:::: {.column width="50%"}
![](../img/son_hoang_2014_until_proof_rule.png)
::::
::::::

# Propiedades auxiliares

## Convergencia de un evento (I)

Esta propiedad de liveness **sí** se puede representar en el lenguaje de Event-B.

_"Si un evento convergente está activado, entonces eventualmente va a dejar de estarlo"_

Para marcar un evento como convergente, se lo marca con la  palabra clave `convergent`.

Adicionalmente, al modelo se le debe agregar una _variante_.

## Convergencia de un evento (II)

La variante es un número que satisface las siguientes condiciones:

1. Cuando el evento está activo, **la variante es un número natural**.
2. Cuando el evento se ejecuta, **la variante disminuye**.

. . .

Intuitivamente, esto implica que cuando la variante deje de ser natural, el evento
**ya no va a estar activo** (_Modus tollens_ en proposición 1).

. . .

Así mísmo, la variantes **debe** dejar de ser natural, ya que el evento disminuye
la variante con cada ejecución.

## Convergencia de un evento (III)

Cuando varios eventos son convergentes, la elección de la variante se complica.

¿Por qué? Porque Event-B permite **solo una variante por modelo**.

La solución para este problema es combinar las variantes de cada evento convergente
en una única _variante lexicográfica_.

. . .

(TODO: mostrar Variante en modelo PingPongEnd)

## Convergencia en P

TODO

## Divergencia

TODO

## Transiciona de $P_1$ a $P_2$

TODO

# Verificación en ProB

## "Model check" (I)

Esta funcionalidad explora lo máximo posible el espacio de estados del modelo para
encontrar _violaciones de invariantes/teoremas_ y _deadlocks_.

Es útil para verificar que el modelo cumple con las variantes **antes de demostrarlo**.

(TODO: Mostrar espacio de estados generado por ProB)

## "Model check" (II)

Hay dos casos donde el model check no es exhaustivo:

* **No se exploró el espacio de estados completo**
* **No se exploraron todos los eventos posibles**

Ambos se pueden remediar aumentando los valores de las constantes `MAX_INITIALIZATIONS`
y `MAX_OPERATIONS` y **acotando las constantes del modelo** (fundamental).

## "Model check" (III)

El _model checking_ nos permite **sólo verificar**, no demostrar.

En el mejor de los casos (cuando el chequeo es exhaustivo), nos permite **demostrar**
las propiedades deseadas en un modelo más pequeño que el "real".

## LTL checking (I)

Esta funcionalidad nos permite escribir fórmulas LTL que son verificadas por ProB.

ProB soporta todos los operadores temporales e incluso algunos operadores específico
a B/Event-B que facilitan la escritura de propiedades útiles.

## LTL checking (II)

Las propiedades de liveness se pueden escribir del siguiente modo:

```
G F ({is_pinging = 1}))
G F ({is_pinging = 0}))
F G ({runs_counter = RUNS_LIMIT})
G (e(ping) => F (e(pong)))
```

Donde `e(<evento>)` es la _guarda del evento en cuestión_ (i.e: el evento está activado).
