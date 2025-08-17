# Hangman en Move/Sui

Este proyecto implementa el clásico juego del ahorcado (Hangman) como smart contract en Move para la blockchain Sui. Permite crear colecciones de palabras clave, iniciar juegos y adivinar letras, todo desde la línea de comandos (CLI) de Sui.

## Lógica y Estructura

- El módulo principal es `hangman`.
- Se manejan dos tipos de objetos principales:
  - **Keywords**: Colección de palabras y sus pistas.
  - **Game**: Estado de una partida de ahorcado, asociada a una palabra de `Keywords`.
- Los identificadores (`PACKAGE_ID`, `KEYWORDS_ID`, `GAME_ID`) son esenciales para interactuar con los objetos creados.

---

## Cómo usarlo desde la CLI

### 1. Crear el objeto Keywords

Crea una colección vacía de palabras clave:

```sh
sui client call ^
  --package <PACKAGE_ID> ^
  --module hangman ^
  --function crear_keywords ^
  --gas-budget 100000000
```

Guarda el `KEYWORDS_ID` que se genera.

---

### 2. Agregar Palabras

Agrega palabras y pistas a tu colección de keywords. El índice (`0`, `1`, `2`, ...) es el identificador interno de la palabra:

NOTA: Añade solo palabras en minuscula, y sin ñ (se debe al encode qu es UTF8)

```sh
sui client call ^
  --package <PACKAGE_ID> ^
  --module hangman ^
  --function agregar_palabra ^
  --args <KEYWORDS_ID> 0 "gato" "animal domestico" ^
  --gas-budget 100000000
```

Repite el comando cambiando el índice y la palabra para agregar más.

---

### 3. Crear un Juego

Inicia una nueva partida de ahorcado usando una palabra de tu colección:

```sh
sui client call ^
  --package <PACKAGE_ID> ^
  --module hangman ^
  --function crear_juego ^
  --args <KEYWORDS_ID> 0 ^
  --gas-budget 100000000
```

Guarda el `GAME_ID` que se genera.

---

### 4. Adivinar Letras

Adivina letras usando su valor ASCII (por ejemplo, 'a' = 97):

```sh
sui client call ^
  --package <PACKAGE_ID> ^
  --module hangman ^
  --function adivinar_letra ^
  --args <GAME_ID> <KEYWORDS_ID> 97 ^
  --gas-budget 100000000
```

Repite este comando cambiando el valor ASCII para adivinar otras letras.

---

## IDs a Guardar

- `PACKAGE_ID`: ID del paquete publicado.
- `KEYWORDS_ID`: ID del objeto de palabras clave.
- `GAME_ID`: ID de la partida de ahorcado.

Guarda estos IDs tras cada operación, ya que los necesitarás para los siguientes comandos.

---

## Notas

- Todos los comandos usan un `--gas-budget` alto para evitar errores por falta de gas.
- El flujo recomendado es: crear keywords → agregar palabras → crear juego → adivinar letras.
- Puedes consultar el estado del juego y las palabras usando funciones adicionales del módulo (ver código fuente para detalles).

---

## Abecedario y códigos ASCII

| Letra | Código ASCII |
|-------|--------------|
|   a   |     97       |
|   b   |     98       |
|   c   |     99       |
|   d   |    100       |
|   e   |    101       |
|   f   |    102       |
|   g   |    103       |
|   h   |    104       |
|   i   |    105       |
|   j   |    106       |
|   k   |    107       |
|   l   |    108       |
|   m   |    109       |
|   n   |    110       |
|   o   |    111       |
|   p   |    112       |
|   q   |    113       |
|   r   |    114       |
|   s   |    115       |
|   t   |    116       |
|   u   |    117       |
|   v   |    118       |
|   w   |    119       |
|   x   |    120       |
|   y   |    121       |
|   z   |    122       |
---

## Move registry
https://www.moveregistry.com/package/@pkg/hangman
