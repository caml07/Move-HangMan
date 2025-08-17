module hangman::hangman {
  use std::string::{String, utf8, bytes, as_bytes};
  // use std::debug;
  use sui::vec_map;
  use sui::vec_map::VecMap;
  // use sui::object;
  // use sui::transfer;
  use sui::tx_context::{TxContext, sender};
  // use std::vector;
  use std::option::{Option, some, none}; 

  // --- Errores como constantes textuales ---
  #[error]
  const E_ID_YA_EXISTE: vector<u8> = b"ERROR: El ID ya existe";
  #[error]
  const E_LETRA_YA_ADIVINADA: vector<u8> = b"ERROR: Letra ya adivinada";
  #[error]
  const E_JUEGO_FINALIZADO: vector<u8> = b"ERROR: El juego ya terminó";
  #[error]
  const E_NO_ES_TU_JUEGO: vector<u8> = b"ERROR: No eres el dueño de este juego";
  #[error]
  const E_PALABRA_NO_EXISTE: vector<u8> = b"ERROR: La palabra no existe";

  // --- Structs ---
  public struct Keywords has key {
    id: object::UID,
    palabras: VecMap<u8, Palabra>,
  }

  public struct Palabra has store {
    texto: String,
    pista: String,
  }

  public struct Juego has key {
    id: object::UID,
    jugador: address,
    palabra_id: u8,
    letras_adivinadas: vector<u8>,
    intentos_restantes: u8,
    finalizado: bool,
    partida: Option<String>,
    ultima_letra: Option<u8>,
  }

  // --- Validaciones ---
  fun validar_juego(juego: &Juego, user: address) {
    assert!(!juego.finalizado, E_JUEGO_FINALIZADO);
    assert!(juego.jugador == user, E_NO_ES_TU_JUEGO);
  }

  fun validar_palabra(keywords: &Keywords, palabra_id: u8) {
    assert!(vec_map::contains(&keywords.palabras, &palabra_id), E_PALABRA_NO_EXISTE);
  }

  // --- Gestión de palabras ---
  public fun crear_keywords(ctx: &mut TxContext) {
    let keywords = Keywords {
      id: object::new(ctx),
      palabras: vec_map::empty<u8, Palabra>(),
    };
    transfer::transfer(keywords, sender(ctx));
  }

  public fun agregar_palabra(
    keywords: &mut Keywords,
    identificador: u8,
    texto: String,
    pista: String
  ) {
    assert!(!vec_map::contains(&keywords.palabras, &identificador), E_ID_YA_EXISTE);
    let palabra = Palabra { texto, pista };
    vec_map::insert(&mut keywords.palabras, identificador, palabra);
  }

  // --- Crear juego ---
  public fun crear_juego(keywords: &Keywords, palabra_id: u8, ctx: &mut TxContext) {
    validar_palabra(keywords, palabra_id);
    let juego = Juego {
      id: object::new(ctx),
      jugador: sender(ctx),
      palabra_id,
      letras_adivinadas: vector::empty<u8>(),
      intentos_restantes: 6,
      finalizado: false,
      partida: none<String>(),
      ultima_letra: none<u8>(),
    };
    transfer::transfer(juego, sender(ctx));
  }

  // --- Adivinar letra ---
  public fun adivinar_letra(juego: &mut Juego, keywords: &Keywords, letra: u8, ctx: &mut TxContext) {
    // validar ownership del jugador actual
    validar_juego(juego, sender(ctx));

    // Verifica si la letra ya fue adivinada
    let mut i = 0;
    let n = vector::length(&juego.letras_adivinadas);
    while (i < n) {
      let l = *vector::borrow(&juego.letras_adivinadas, i);
      assert!(l != letra, E_LETRA_YA_ADIVINADA);
      i = i + 1;
    };

    // Agrega la letra a las letras adivinadas
    vector::push_back(&mut juego.letras_adivinadas, letra);
    juego.ultima_letra = some(letra);

    // Obtiene la palabra a adivinar
    let palabra = vec_map::get(&keywords.palabras, &juego.palabra_id);
    let palabra_bytes_ref = as_bytes(&palabra.texto); // &vector<u8>
    let acierto = contiene_byte(palabra_bytes_ref, letra);

    // Si no acertó, resta un intento
    if (!acierto) {
      juego.intentos_restantes = juego.intentos_restantes - 1;
    };

    // Verifica si el juego terminó
    if (juego.intentos_restantes == 0 || todas_letras_adivinadas(palabra_bytes_ref, &juego.letras_adivinadas)) {
      juego.finalizado = true;
      if (juego.intentos_restantes > 0) {
        juego.partida = some(utf8(b"\xF0\x9F\x8E\x89\x20\xC2\xA1Ganaste!")); // "🎉 ¡Ganaste!"
      } else {
        juego.partida = some(utf8(b"Perdiste"));
      }
    };
  }

  // --- Auxiliares ---
  fun contiene_byte(palabra_bytes: &vector<u8>, letra: u8): bool {
    let mut j = 0;
    let m = vector::length(palabra_bytes);
    while (j < m) {
      if (*vector::borrow(palabra_bytes, j) == letra) {
        return true
      };
      j = j + 1;
    };
    false
  }

  fun todas_letras_adivinadas(palabra_bytes: &vector<u8>, letras_adivinadas: &vector<u8>): bool {
    let mut i = 0;
    let n = vector::length(palabra_bytes);
    while (i < n) {
      let letra = *vector::borrow(palabra_bytes, i);
      if (!letra_en_vector(letra, letras_adivinadas)) {
        return false
      };
      i = i + 1;
    };
    true
  }

  fun letra_en_vector(letra: u8, letras: &vector<u8>): bool {
    let mut i = 0;
    let n = vector::length(letras);
    while (i < n) {
      if (*vector::borrow(letras, i) == letra) {
        return true
      };
      i = i + 1;
    };
    false
  }
}