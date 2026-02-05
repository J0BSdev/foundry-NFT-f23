# MoodNFT - Pregled Koda

## 📋 Općenito

`MoodNFT` je ERC721 NFT ugovor koji omogućava kreiranje NFT-ova s promjenjivim "moodom" (raspoloženjem). Svaki NFT može biti ili SREĆAN (HAPPY) ili TUŽAN (SAD), a to određuje koja se slika prikazuje.

---

## 🔧 Struktura Ugovora

### Importi i Nasljeđivanje

```solidity
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNFT is ERC721 {
```

**Zašto:**
- `ERC721` - Standardni NFT protokol koji omogućava transfer, ownership, itd.
- `Base64` - Potreban za enkodiranje JSON metadata u data URI format
- `is ERC721` - Nasljeđivanje daje sve standardne NFT funkcije

---

## 💾 State Varijable

### 1. `uint256 private s_tokenCounter;`
- **Svrha:** Broji koliko je tokena kreirano
- **Zašto `uint256`:** Standardni tip za token ID-jeve u ERC721
- **Zašto `private`:** Sprječava direktan pristup izvan ugovora
- **Zašto `s_` prefiks:** Konvencija za storage varijable (nije obavezno)

### 2. `string private s_sadSvgImageUri;`
- **Svrha:** Čuva URI slike za tužan mood
- **Tip:** String jer URI-jevi su tekstualni

### 3. `string private s_happySvgImageUri;`
- **Svrha:** Čuva URI slike za sretan mood

### 4. `enum Mood { HAPPY, SAD }`
- **Svrha:** Definira moguće stanja mood-a
- **Zašto enum:** Gas-efikasniji od stringova (HAPPY = 0, SAD = 1)
- **Proširivost:** Lako dodati nova stanja (npr. EXCITED, CALM)

### 5. `mapping(uint256 => Mood) private s_tokenIdToMood;`
- **Svrha:** Mapira token ID na njegov mood
- **Zašto mapping:** O(1) pristup, najefikasniji način
- **Struktura:** `tokenId => Mood enum`

---

## 🏗️ Konstruktor

```solidity
constructor(string memory sadSvg, string memory happySvg) ERC721("MoodNFT", "MN") {
    s_sadSvgImageUri = sadSvg;
    s_happySvgImageUri = happySvg;
    s_tokenCounter = 0;
}
```

**Parametri:**
- `sadSvg` - URI slike za tužan mood
- `happySvg` - URI slike za sretan mood

**Zašto `string memory`:**
- `memory` je obavezan za stringove u funkcijama (ne storage)

**Zašto `ERC721("MoodNFT", "MN")`:**
- Poziva parent konstruktor s imenom i simbolom kolekcije
- Mora biti prije tijela konstruktora

**Inicijalizacija:**
- Postavlja URI-jeve za oba mood-a
- Resetira brojač na 0 (iako je to default vrijednost)

---

## 🔄 Funkcije

### 1. `_baseURI()` - Override Funkcija

```solidity
function _baseURI() internal pure override returns (string memory) {
    return "data:application/json;base64,";
}
```

**Svrha:** Vraća prefiks za data URI format

**Zašto `internal`:**
- Može se pozivati samo unutar ugovora ili naslijeđenih ugovora

**Zašto `pure`:**
- Ne čita ni piše u storage (samo vraća konstantu)

**Zašto `override`:**
- Override-a funkciju iz ERC721 parent klase
- Obavezno ako se override-a funkcija

**Zašto ovaj string:**
- `data:application/json;base64,` je standardni format za data URI
- Označava da slijedi base64-encodiran JSON

---

### 2. `mintNFT()` - Kreiranje Novog NFT-a

```solidity
function mintNFT() public {
    _safeMint(msg.sender, s_tokenCounter);
    s_tokenCounter++;
    s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
}
```

**Svrha:** Kreiram novi NFT i dodjeljuje ga pozivatelju

**Koraci:**

1. **`_safeMint(msg.sender, s_tokenCounter)`**
   - Kreira token s ID-jem `s_tokenCounter`
   - Dodjeljuje ga `msg.sender` (onaj tko poziva funkciju)
   - `_safeMint` provjerava da li receiver može primiti ERC721 token
   - Sigurniji od `_mint` jer provjerava receiver

2. **`s_tokenCounter++`**
   - Inkrementira brojač za sljedeći token
   - Gas-efikasniji od `s_tokenCounter = s_tokenCounter + 1`

3. **`s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY`**
   - Postavlja mood za token
   - ⚠️ **BUG:** Koristi se `s_tokenCounter` NAKON inkrementa
   - Trebalo bi biti: `s_tokenIdToMood[s_tokenCounter - 1] = Mood.HAPPY;`

**Zašto `public`:**
- Omogućava poziv iz bilo gdje (wallet, drugi ugovor, itd.)

---

### 3. `tokenURI()` - Metadata Funkcija

```solidity
function tokenURI(uint256 tokenId) public view override returns (string memory) {
    string memory imageURI;
    if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
        imageURI = s_happySvgImageUri;
    } else {
        imageURI = s_sadSvgImageUri;
    }
    return string(
        abi.encodePacked(
            _baseURI(),
            Base64.encode( 
                bytes(
                    abi.encodePacked(
                        '{"name":"',
                        name(),
                        '", "description": "An NFT that reflects the owners mood.", ',
                        '"attributes": [{"trait_type": "moodiness", "value": 100}], "image": "',
                        imageURI,
                        '"}'
                    )
                )
            ),
            "}"
        )
    );
}
```

**Svrha:** Vraća metadata URI za token (standardna ERC721 funkcija)

**Zašto `public view override`:**
- `public` - Može se pozivati izvana
- `view` - Ne mijenja state (samo čita), jeftinije
- `override` - Override-a funkciju iz ERC721

**Logika:**

1. **Određivanje slike:**
   ```solidity
   if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
       imageURI = s_happySvgImageUri;
   } else {
       imageURI = s_sadSvgImageUri;
   }
   ```
   - Provjerava mood tokena
   - Postavlja odgovarajući URI

2. **Gradnja JSON-a:**
   - `abi.encodePacked()` - Spaja stringove u bytes
   - Jeftiniji od `abi.encode`, ali manje siguran (može dovesti do kolizija)
   - Za konkatenaciju stringova je dovoljno

3. **JSON struktura:**
   ```json
   {
     "name": "MoodNFT",
     "description": "An NFT that reflects the owners mood.",
     "attributes": [{"trait_type": "moodiness", "value": 100}],
     "image": "[URI slike]"
   }
   ```
   - Standardni NFT metadata format (ERC721 Metadata Extension)
   - Walleti i marketplacei očekuju ova polja

4. **Base64 enkodiranje:**
   - `Base64.encode()` - Enkodira JSON u base64
   - Potrebno za data URI format
   - Prima `bytes`, ne `string` (zato `bytes(...)`)

5. **Finalni format:**
   ```
   data:application/json;base64,[BASE64_ENCODED_JSON]
   ```
   - ⚠️ **BUG:** Dupla zatvorena zagrada (`"}"` na kraju JSON-a i još jedna `"}"`)

**Zašto sve ovo:**
- NFT standardi zahtijevaju da `tokenURI` vrati string
- Data URI omogućava metadata direktno na chainu (bez vanjskog servera)
- Base64 je standardni format za enkodiranje u data URI

---

## 🐛 Pronađeni Bugovi

### Bug 1: Pogrešan tokenId u `mintNFT()`
**Linija 32:**
```solidity
s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
```

**Problem:** Koristi se `s_tokenCounter` NAKON inkrementa, pa se mood postavlja za sljedeći token, ne za trenutni.

**Ispravka:**
```solidity
s_tokenIdToMood[s_tokenCounter - 1] = Mood.HAPPY;
```

### Bug 2: Dupla zatvorena zagrada u `tokenURI()`
**Linija 53 i 57:**
```solidity
'"}'
...
"}"
```

**Problem:** Dvostruka zatvorena zagrada u JSON-u.

**Ispravka:** Ukloniti jednu od njih.

---

## 📊 Tok Podataka

### Mint proces:
1. Korisnik poziva `mintNFT()`
2. `_safeMint()` kreira token s ID-jem `s_tokenCounter`
3. `s_tokenCounter++` - povećava se za sljedeći token
4. Mood se postavlja (ali na pogrešan tokenId - BUG)

### tokenURI proces:
1. Korisnik poziva `tokenURI(tokenId)`
2. Provjerava se mood tokena iz mapping-a
3. Određuje se odgovarajući image URI
4. Gradi se JSON metadata
5. JSON se enkodira u Base64
6. Vraća se data URI string

---

## 🔐 Sigurnost i Gas Optimizacije

### Sigurnost:
- ✅ `private` varijable - enkapsulacija
- ✅ `_safeMint` umjesto `_mint` - provjera receivera
- ⚠️ Nema provjere ownership-a u `mintNFT()` - svatko može mintati
- ⚠️ Nema funkcije za promjenu mood-a (ali postoji u novijoj verziji - `flipMood`)

### Gas optimizacije:
- ✅ `enum` umjesto stringova - jeftinije
- ✅ `mapping` umjesto array-a - O(1) pristup
- ✅ `view` funkcije - jeftinije od `pure` (ako ne treba čitati storage)
- ✅ `abi.encodePacked` - jeftiniji od `abi.encode`

---

## 📝 Napomene

1. **Nedostaje funkcija `flipMood()`:**
   - U ovoj verziji nema načina da se promijeni mood tokena
   - U novijoj verziji postoji `flipMood(uint256 tokenId)` funkcija

2. **Metadata format:**
   - Koristi se data URI (sve na chainu)
   - Alternativa: HTTP(S) URI koji vodi na vanjski server

3. **Proširivost:**
   - Lako dodati nova stanja u enum
   - Lako dodati nove atribute u JSON metadata

---

## 🎯 Sažetak

**MoodNFT** je jednostavan NFT ugovor koji:
- ✅ Omogućava mintanje NFT-ova
- ✅ Svaki NFT ima mood (HAPPY ili SAD)
- ✅ Mood određuje koja se slika prikazuje
- ✅ Metadata je na chainu (data URI)
- ⚠️ Ima bugove koje treba popraviti

**Ključne komponente:**
- ERC721 nasljeđivanje za standardne NFT funkcije
- Enum za gas-efikasno čuvanje mood-a
- Mapping za brz pristup mood-u po tokenId
- Base64 enkodiranje za data URI format

