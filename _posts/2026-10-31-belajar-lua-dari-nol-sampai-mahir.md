---
layout: post
title: "Belajar Lua dari Nol sampai Mahir: Panduan Lengkap Bahasa Indonesia"
date: 2026-10-31 09:00:00 +0700
categories: [programming, lua]
tags: [lua, lua54, luajit, luarocks, neovim, metatable, coroutine, scripting, tutorial, indonesia]
description: "Panduan belajar bahasa Lua dalam bahasa Indonesia: dari dasar, table, metatable, OOP, coroutine, hingga Lua C API dan pengembangan plugin Neovim."
toc: true
---

{% raw %}

Panduan ini adalah materi lengkap untuk belajar **bahasa pemrograman Lua dari nol sampai level advanced**, mengikuti roadmap bertahap seperti kurikulum perkuliahan: fundamental, struktur data, pemrograman modular, OOP, fitur advanced, ekosistem, hingga implementasi nyata. Setiap tahap berisi **teori, penjelasan, contoh kode, latihan, dan target kelulusan**.

## Target Pembelajaran

| Aspek | Keterangan |
|---|---|
| **Durasi estimasi** | 4–6 bulan |
| **Waktu belajar** | 10–15 jam per minggu |
| **Level akhir** | Advanced hingga Expert |
| **Pendekatan** | 30% teori, 70% praktik dan proyek |
| **Fokus tambahan** | Scripting, automation, dan pengembangan plugin Neovim |

Setelah menyelesaikan panduan ini, kamu diharapkan mampu:

1. Memahami syntax dan karakteristik bahasa Lua.
2. Membuat aplikasi CLI dan program modular.
3. Menguasai table, function, closure, metatable, dan coroutine.
4. Membuat library dan package Lua.
5. Memahami memory management dan garbage collection.
6. Menggunakan Lua untuk scripting dan automation.
7. Membuat konfigurasi dan plugin Neovim.
8. Memahami integrasi Lua dengan C/C++.

> **Catatan versi:** Panduan ini memakai **Lua 5.4** sebagai acuan. Ada beberapa bagian yang berbeda di Lua 5.1 / LuaJIT (misalnya `//`, operator bitwise, `utf8`, `goto` pada 5.1 murni, dan `<close>`), dan perbedaannya ditandai di tempat yang relevan. Bagian Neovim memakai semantik **LuaJIT / Lua 5.1**, jadi baca Tahap 11 dan Tahap 13 dengan teliti. Selalu cocokkan dengan [Lua 5.4 Reference Manual](https://www.lua.org/manual/5.4/).

**Cara memakai panduan ini**

1. Ikuti tahap secara berurutan. Jangan melompat ke metatable sebelum paham table dan function.
2. **Ketik sendiri** setiap contoh dan jalankan. Ubah sedikit, lalu amati hasilnya.
3. Kerjakan latihan di setiap tahap sebelum lanjut.
4. Centang checklist "Target kelulusan" dengan jujur.

* TOC
{:toc}

---

# Bagian 1: Fundamental Lua

## Tahap 1. Pengenalan Lua dan Lingkungan Pengembangan

**Level:** Beginner · **Estimasi:** Minggu 1

### 1.1 Apa itu Lua?

**Lua** adalah bahasa pemrograman *scripting* yang ringan (*lightweight*), cepat, dan mudah ditanamkan (*embeddable*) ke aplikasi lain. Kata *lua* berarti **"bulan"** dalam bahasa Portugis. Lua dibuat tahun 1993 oleh tim di **PUC-Rio**, Brasil (Roberto Ierusalimschy, Luiz Henrique de Figueiredo, dan Waldemar Celes).

### 1.2 Filosofi Desain

Lua sengaja dibuat **kecil dengan sedikit fitur, tetapi fitur-fiturnya sangat fleksibel**. Alih-alih menyediakan banyak struktur bawaan, Lua memberi *mekanisme* untuk membangunnya sendiri:

| Mekanisme | Dipakai untuk membangun |
|---|---|
| **Table** | Array, dictionary, set, objek, modul, namespace |
| **Function first-class + closure** | Callback, iterator, enkapsulasi |
| **Metatable** | OOP, operator overloading, proxy |
| **Coroutine** | Generator, cooperative multitasking |

Itulah mengapa seluruh bahasa Lua hanya memiliki **8 tipe data** dan interpreter-nya berukuran sekitar ratusan KB.

### 1.3 Karakteristik Utama

- **Ringan & cepat**: footprint kecil, startup instan.
- **Embeddable**: dirancang agar mudah ditanam di aplikasi C/C++ sebagai *scripting engine*.
- **Dynamic typing**: tipe melekat pada **nilai**, bukan variabel.
- **Garbage collected**: memori dikelola otomatis.
- **Portabel**: ditulis dalam ANSI C; berjalan di hampir semua platform.
- **Sintaks sederhana**: terbaca seperti pseudo-code, memakai kata kunci seperti `then`, `end`, `do`.

### 1.4 Use Case Lua

| Bidang | Contoh |
|---|---|
| **Embedded scripting** | Redis (script server-side), Nginx/OpenResty, Wireshark |
| **Game development** | LÖVE2D, Defold, addon World of Warcraft, Roblox (memakai Luau, turunan Lua) |
| **Automation** | Skrip utilitas, filter Pandoc, konfigurasi alat |
| **Konfigurasi** | Neovim, WezTerm, Awesome WM |
| **Perangkat IoT** | NodeMCU / ESP |

### 1.5 Lua vs Python vs JavaScript vs Go

| Aspek | Lua | Python | JavaScript | Go |
|---|---|---|---|---|
| Tipe | Dinamis | Dinamis | Dinamis | Statis |
| Eksekusi | Bytecode VM | Bytecode VM | JIT (V8, dll.) | Kompilasi native |
| Struktur data bawaan | Hanya **table** | list, dict, set, tuple | Array, Object, Map, Set | slice, map, struct |
| Indeks array mulai dari | **1** | 0 | 0 | 0 |
| Ukuran runtime | Sangat kecil | Besar | Sedang–besar | Binary mandiri |
| Kekuatan | Embedding, ringan | Ekosistem luas | Web | Concurrency, tooling |
| Standard library | Minimalis | Sangat lengkap | Tergantung runtime | Lengkap |

### 1.6 Instalasi Lua

**Linux (Debian/Ubuntu):**

```bash
sudo apt update
sudo apt install lua5.4
lua5.4 -v
```

**macOS (Homebrew):**

```bash
brew install lua
lua -v
```

**Windows:** pilihan termudah adalah memakai **WSL** (lalu ikuti langkah Linux), atau package manager seperti **Scoop** (`scoop install lua`) atau **Chocolatey**.

**Dari source (semua platform dengan compiler C):**

```bash
# unduh arsip versi 5.4.x terbaru dari https://www.lua.org/download.html
tar -zxf lua-5.4.x.tar.gz
cd lua-5.4.x
make
sudo make install
```

Cek instalasi:

```bash
lua -v
# Lua 5.4.x  Copyright (C) 1994-20xx Lua.org, PUC-Rio
```

### 1.7 Menjalankan Lua: REPL dan File

**REPL** (*Read-Eval-Print Loop*) adalah mode interaktif:

```text
$ lua
Lua 5.4.x  Copyright (C) 1994-20xx Lua.org, PUC-Rio
> 1 + 2
3
> print("Halo")
Halo
> x = 10
> x * 2
20
> os.exit()
```

> Pada Lua 5.3+ ekspresi langsung dicetak hasilnya. Pada Lua 5.1/5.2 gunakan `= 1 + 2`.

**Menjalankan file `.lua`:**

```lua
-- halo.lua
print("Hello, World!")
```

```bash
lua halo.lua
```

**Opsi baris perintah yang berguna:**

```bash
lua -e "print(2^10)"       # jalankan potongan kode
lua -i halo.lua            # jalankan file lalu masuk REPL
lua skrip.lua a b c        # kirim argumen ke skrip
```

Argumen dapat dibaca lewat tabel global `arg`:

```lua
-- args.lua
print("Nama skrip:", arg[0])
for i = 1, #arg do
  print(i, arg[i])
end
```

**Shebang** (Linux/macOS): baris pertama yang diawali `#` diabaikan oleh Lua.

```lua
#!/usr/bin/env lua
print("Aku bisa dieksekusi langsung")
```

```bash
chmod +x halo.lua
./halo.lua
```

### 1.8 Struktur Dasar Program Lua

Program Lua adalah urutan **statement** yang dieksekusi dari atas ke bawah. Satu file = satu **chunk**.

```lua
-- Ini komentar satu baris

--[[
  Ini komentar
  multiline
]]

local nama = "Dina"          -- statement: deklarasi variabel
print("Halo, " .. nama)      -- statement: pemanggilan function
print(1 + 2 * 3)             -- ekspresi dievaluasi lalu dikirim ke print
```

Hal-hal penting:

- **Titik koma `;` opsional.** Biasanya tidak dipakai.
- **Indentasi tidak bermakna** (berbeda dengan Python). Blok diakhiri `end`.
- **Komentar multiline dengan level**: `--[==[ ... ]==]` berguna jika di dalamnya ada `]]`.

```lua
--[==[
  Komentar ini aman meskipun berisi ]] di dalamnya
]==]
```

Trik umum untuk menonaktifkan blok kode dengan cepat:

```lua
---[[ tambahkan satu tanda minus di depan untuk MENGAKTIFKAN blok
print("Blok ini aktif")
--]]
```

**Statement vs expression.** *Expression* menghasilkan nilai (`1 + 2`, `f(x)`, `a and b`); *statement* melakukan aksi (assignment, `if`, `for`). Pemanggilan function bisa menjadi keduanya.

**Case sensitivity.** `Nama`, `nama`, dan `NAMA` adalah tiga identifier berbeda.

**Kata kunci (reserved words)** tidak boleh dipakai sebagai nama variabel:

```text
and    break   do     else   elseif  end    false  for
function goto  if     in     local   nil    not    or
repeat return  then   true   until   while
```

Konvensi penamaan yang lazim: `snake_case` untuk variabel dan function, `PascalCase` untuk "class", `UPPER_CASE` untuk konstanta.

### 1.9 Praktik

**1. Hello, World!**

```lua
print("Hello, World!")
```

**2-3.** Jalankan lewat REPL (ketik langsung) dan lewat file (`lua halo.lua`).

**4. Kalkulator sederhana**

```lua
-- kalkulator.lua
io.write("Angka pertama : ")
local a = io.read("n")      -- baca sebagai angka
io.write("Angka kedua   : ")
local b = io.read("n")

print("Tambah :", a + b)
print("Kurang :", a - b)
print("Kali   :", a * b)
print("Bagi   :", a / b)
```

`io.write` tidak menambah newline (berbeda dengan `print`), sedangkan `io.read("n")` membaca sebuah angka dari input.

**5. Konversi suhu**

```lua
-- suhu.lua
io.write("Masukkan suhu Celsius: ")
local c = io.read("n")

local f = c * 9 / 5 + 32
local k = c + 273.15

print(string.format("%.1f °C = %.1f °F = %.2f K", c, f, k))
```

### 1.10 Target Kelulusan Tahap 1

- [ ] Dapat menginstal dan menjalankan Lua.
- [ ] Memahami alur eksekusi program Lua (atas ke bawah, per chunk).
- [ ] Dapat membuat program sederhana tanpa mengikuti tutorial.

---

## Tahap 2. Variables, Data Types, dan Operators

**Level:** Beginner · **Estimasi:** Minggu 1–2

### 2.1 Variables dan Scope

**Variabel** adalah nama yang merujuk ke sebuah nilai. Di Lua ada dua jenis:

```lua
local umur = 20      -- variabel LOKAL (disarankan)
nama = "Budi"        -- variabel GLOBAL (tanpa kata kunci local)
```

| | `local` | Global |
|---|---|---|
| Jangkauan | Blok tempat dideklarasikan | Seluruh program |
| Penyimpanan | Register VM (cepat) | Tabel `_G` (lebih lambat) |
| Risiko | Rendah | Bentrok nama, bug sulit dilacak |

> **Aturan emas: selalu pakai `local`.** Variabel global yang tidak sengaja (misalnya salah ketik) adalah sumber bug klasik di Lua.

Variabel yang belum diberi nilai berisi `nil`:

```lua
print(belum_ada)   --> nil
```

**Scope dan blok.** Blok dibuat oleh `do ... end`, `if`, `while`, `for`, dan `function`.

```lua
local x = 10

do
  local x = 20        -- variabel baru yang "menutupi" x luar (shadowing)
  print(x)            --> 20
end

print(x)              --> 10
```

**Lexical scope**: sebuah variabel terlihat di blok tempat ia dideklarasikan dan blok-blok bersarang di dalamnya, **ditentukan oleh posisi dalam kode**, bukan oleh urutan pemanggilan.

```lua
local a = 1
local function f()
  return a            -- f "melihat" a karena ditulis di dalam jangkauan a
end
print(f())            --> 1
```

**Multiple assignment**: semua sisi kanan dievaluasi dulu, baru ditugaskan.

```lua
local a, b = 1, 2
a, b = b, a           -- tukar nilai tanpa variabel bantu
print(a, b)           --> 2   1

local x, y, z = 1, 2          -- z = nil (kekurangan nilai diisi nil)
local p, q = 1, 2, 3          -- 3 dibuang (kelebihan nilai diabaikan)
```

**Multiple return values**: function dapat mengembalikan banyak nilai.

```lua
local function min_max(a, b)
  if a < b then return a, b else return b, a end
end

local kecil, besar = min_max(9, 3)
print(kecil, besar)   --> 3   9
```

**Atribut variabel (Lua 5.4):**

```lua
local PI <const> = 3.14159
-- PI = 3        --> error saat kompilasi: attempt to assign to const variable 'PI'
```

### 2.2 Data Types

Lua memiliki **8 tipe dasar**. Gunakan `type()` untuk memeriksanya:

| Tipe | Deskripsi | Contoh |
|---|---|---|
| `nil` | Ketiadaan nilai | `nil` |
| `boolean` | Benar/salah | `true`, `false` |
| `number` | Angka: *integer* dan *float* | `42`, `3.14`, `0xFF`, `1e3` |
| `string` | Teks tak-berubah (immutable), berbasis byte | `"halo"`, `'hai'` |
| `table` | Struktur data serbaguna | `{1, 2, 3}`, `{a = 1}` |
| `function` | Function (nilai kelas satu) | `function() end` |
| `thread` | Coroutine | `coroutine.create(f)` |
| `userdata` | Data C arbitrer (dari C API) | file handle (`io.stdout`) |

```lua
print(type(nil))             --> nil
print(type(true))            --> boolean
print(type(42))              --> number
print(type("hai"))           --> string
print(type({}))              --> table
print(type(print))           --> function
print(type(coroutine.create(print)))  --> thread
print(type(io.stdout))       --> userdata
print(type(type(1)))         --> string   (type() mengembalikan string)
```

**Dynamic typing:** tipe melekat pada **nilai**, bukan pada variabel.

```lua
local v = 10         -- number
v = "sepuluh"        -- sekarang string; sah di Lua
v = { 10 }           -- sekarang table
```

**Number: integer dan float (Lua 5.3+).**

```lua
print(math.type(3))       --> integer
print(math.type(3.0))     --> float
print(math.type("3"))     --> nil  (bukan number; math.type mengembalikan nil/fail)

print(7 / 2)              --> 3.5   (operator / SELALU menghasilkan float)
print(7 // 2)             --> 3     (floor division, integer)
print(7.0 // 2)           --> 3.0
print(7 % 3)              --> 1
print(-7 % 3)             --> 2     (hasil modulo mengikuti tanda pembagi)
print(2 ^ 10)             --> 1024.0 (^ SELALU float)

print(math.maxinteger)            --> 9223372036854775807
print(math.maxinteger + 1 == math.mininteger)  --> true (wrap-around!)
```

Hati-hati dengan **presisi float**:

```lua
print(0.1 + 0.2 == 0.3)                      --> false
print(math.abs(0.1 + 0.2 - 0.3) < 1e-9)      --> true (bandingkan dengan toleransi)
```

**String:**

```lua
local s1 = "petik ganda"
local s2 = 'petik tunggal'
local s3 = "baris1\nbaris2\ttab"      -- escape sequence
local s4 = [[
string panjang
bisa multi-baris, \n tidak diproses
]]
print(#"halo")                        --> 4 (panjang dalam BYTE)
```

### 2.3 Type Checking dan Type Conversion

**Konversi eksplisit:**

```lua
print(tostring(123))        --> "123"
print(tostring(true))       --> "true"
print(tostring(nil))        --> "nil"

print(tonumber("42"))       --> 42
print(tonumber("3.14"))     --> 3.14
print(tonumber("0x1F"))     --> 31
print(tonumber("  7  "))    --> 7      (spasi tepi diizinkan)
print(tonumber("abc"))      --> nil    (gagal -> nil, BUKAN error)
print(tonumber("101", 2))   --> 5      (basis 2)
print(tonumber("ff", 16))   --> 255
```

**Konversi otomatis (coercion):**

```lua
print("10" + 5)       --> 15      (string -> number untuk operasi aritmetika)
print(10 .. 20)       --> 1020    (number -> string untuk konkatenasi)
print("10" == 10)     --> false   (== TIDAK melakukan coercion)
```

> Hindari mengandalkan coercion. Konversi secara eksplisit agar niatnya jelas.

Pola validasi input yang aman:

```lua
local function baca_angka(teks)
  local n = tonumber(teks)
  if n == nil then
    return nil, "'" .. tostring(teks) .. "' bukan angka"
  end
  return n
end

print(baca_angka("12"))     --> 12
print(baca_angka("dua"))    --> nil   'dua' bukan angka
```

### 2.4 Operators

**Aritmetika**

| Operator | Arti | Contoh | Hasil |
|---|---|---|---|
| `+` `-` `*` | Tambah, kurang, kali | `3 * 4` | `12` |
| `/` | Bagi (float) | `7 / 2` | `3.5` |
| `//` | Bagi bulat (floor) | `7 // 2` | `3` |
| `%` | Modulo | `7 % 3` | `1` |
| `^` | Pangkat (float) | `2 ^ 3` | `8.0` |
| `-x` | Negasi (unary) | `-5` | `-5` |

> `//` diperkenalkan di Lua 5.3. Di Lua 5.1/LuaJIT gunakan `math.floor(a / b)`.

**Relasional** (hasilnya boolean)

```lua
print(1 == 1)         --> true
print(1 ~= 2)         --> true   (~= artinya "tidak sama dengan")
print(3 < 5, 3 >= 5)  --> true   false
print("a" < "b")      --> true   (perbandingan string leksikografis)
-- print(1 < "2")     --> ERROR: attempt to compare number with string
```

**Logika**: `and`, `or`, `not`

```lua
print(true and false)   --> false
print(true or false)    --> true
print(not true)         --> false
```

`and` dan `or` memakai **short-circuit** dan **mengembalikan salah satu operandnya**, bukan sekadar boolean:

```lua
print(nil or "default")      --> default
print(false or nil)          --> nil
print(10 and 20)             --> 20     (pertama truthy -> hasil operand kedua)
print(nil and 20)            --> nil    (pertama falsy -> hasil operand pertama)

local nama = input_user or "Tamu"    -- idiom nilai default
```

**Konkatenasi `..`** dan **panjang `#`**

```lua
print("Halo, " .. "dunia" .. "!")     --> Halo, dunia!
print("n = " .. 5)                    --> n = 5
print(1 .. 2)                         --> 12   (spasi penting; "1..2" salah sintaks)
print(#"abc", #{10, 20, 30})          --> 3   3
```

**Bitwise (Lua 5.3+):** `&`, `|`, `~` (XOR), `~x` (NOT), `<<`, `>>`.

```lua
print(5 & 3, 5 | 3, 5 ~ 3, ~5)   --> 1   7   6   -6
print(1 << 4)                    --> 16
```

**Presedensi** (dari terendah ke tertinggi):

```text
or
and
<     >     <=    >=    ~=    ==
|
~
&
<<    >>
..                  (asosiatif kanan)
+     -
*     /     //    %
unary: not  #  -  ~
^                   (asosiatif kanan)
```

```lua
print(2 + 3 * 4)       --> 14
print(-2 ^ 2)          --> -4     (^ lebih tinggi dari unary minus)
print(2 ^ 3 ^ 2)       --> 512.0  (dibaca 2 ^ (3 ^ 2))
print(not nil == true) --> true   (dibaca (not nil) == true, karena not lebih tinggi dari ==)
```

> Bila ragu, **pakai tanda kurung**.

### 2.5 `nil`, `false`, dan Truthy/Falsy

Di Lua, **hanya `nil` dan `false` yang dianggap salah (falsy)**. Segala nilai lain adalah **truthy**, termasuk `0` dan string kosong `""`.

```lua
if 0 then print("0 itu truthy") end       --> tercetak
if "" then print("'' itu truthy") end     --> tercetak
if nil then print("tidak tercetak") end
if false then print("tidak tercetak") end
```

| Nilai | Truthy? |
|---|---|
| `nil` | ❌ |
| `false` | ❌ |
| `0`, `0.0` | ✅ |
| `""` | ✅ |
| `{}` | ✅ |

`nil` dan `false` **tidak sama**:

```lua
print(nil == false)    --> false
```

Ini penting saat membedakan "tidak ada nilai" dengan "nilai false" (misalnya konfigurasi `opsi = false` vs opsi belum diatur).

**Perbedaan `==` dan `~=`:** `==` menguji kesamaan; `~=` menguji ketidaksamaan (bukan `!=` seperti bahasa lain). Untuk tipe berbeda, `==` langsung `false` tanpa error. Untuk table, `==` membandingkan **identitas** (referensi), bukan isi:

```lua
print({} == {})        --> false (dua table berbeda)
local t = {}
print(t == t)          --> true
```

### 2.6 Praktik

**1. Kalkulator dengan berbagai operator**

```lua
local a, b = 17, 5
print(("%d + %d = %d"):format(a, b, a + b))
print(("%d / %d = %.2f"):format(a, b, a / b))
print(("%d // %d = %d"):format(a, b, a // b))
print(("%d %% %d = %d"):format(a, b, a % b))
print(("%d ^ %d = %.0f"):format(a, b, a ^ b))
```

**2. Validasi input**

```lua
io.write("Umur: ")
local umur = tonumber(io.read())
if not umur then
  print("Input harus berupa angka")
elseif umur < 0 or umur > 150 then
  print("Umur tidak masuk akal")
else
  print("Umur valid: " .. umur)
end
```

**3. Penghitungan nilai mahasiswa**

```lua
local tugas, uts, uas = 80, 75, 90
local akhir = tugas * 0.3 + uts * 0.3 + uas * 0.4
print(string.format("Nilai akhir: %.1f", akhir))
```

**4. Konversi tipe data:** buat tabel kecil berisi `"10"`, `"3.5"`, `"0xA"`, `"abc"` lalu cetak hasil `tonumber` dan `math.type` untuk masing-masing.

**5. Manipulasi string sederhana**

```lua
local s = "belajar lua"
print(s:upper())          --> BELAJAR LUA
print(s:len())            --> 11
print(s:sub(1, 7))        --> belajar
print(s:rep(2, " | "))    --> belajar lua | belajar lua
```

### 2.7 Target Kelulusan Tahap 2

- [ ] Memahami seluruh tipe data dasar Lua.
- [ ] Memahami perbedaan `nil`, `false`, dan nilai truthy lainnya.
- [ ] Mampu menggunakan operator sesuai kebutuhan, termasuk presedensinya.

---

## Tahap 3. Control Flow dan Looping

**Level:** Beginner · **Estimasi:** Minggu 2

### 3.1 Percabangan: `if`, `elseif`, `else`

```lua
local nilai = 78

if nilai >= 85 then
  print("A")
elseif nilai >= 70 then
  print("B")
elseif nilai >= 55 then
  print("C")
else
  print("D")
end
```

Aturan: kondisi tidak butuh tanda kurung; blok `if` harus diakhiri `end`; ada `elseif` (satu kata), bukan `else if` (itu membuat `if` bersarang yang butuh `end` tambahan).

**Nested condition:**

```lua
local umur, punya_ktp = 20, true
if umur >= 17 then
  if punya_ktp then
    print("Boleh mendaftar")
  else
    print("Buat KTP dulu")
  end
end
```

**Conditional expression dengan `and`/`or` (pseudo-ternary):**

```lua
local status = (umur >= 17) and "dewasa" or "anak"
print(status)
```

> **Jebakan:** pola `cond and X or Y` gagal jika `X` bernilai falsy (`nil`/`false`). Dalam kasus itu, `Y` selalu terpilih. Gunakan `if` biasa bila `X` bisa falsy.

```lua
local x = true and false or "fallback"
print(x)     --> fallback  (bukan false!)
```

### 3.2 Perulangan `while` dan `repeat ... until`

```lua
-- while: cek kondisi DULU
local i = 1
while i <= 3 do
  print("while", i)
  i = i + 1
end

-- repeat-until: jalankan DULU, cek kondisi di akhir (minimal 1x)
local n = 1
repeat
  print("repeat", n)
  n = n + 1
until n > 3
```

Perbedaan penting pada `repeat ... until`: variabel `local` di dalam blok **masih terlihat di kondisi `until`**.

```lua
local k = 0
repeat
  local selesai = (k >= 2)
  k = k + 1
until selesai          -- 'selesai' terlihat di sini
```

### 3.3 `for` Numerik dan `for` Generik

**Numeric `for`:** `for var = awal, akhir [, langkah]`

```lua
for i = 1, 5 do print(i) end            -- 1 2 3 4 5
for i = 10, 1, -3 do print(i) end       -- 10 7 4 1
for x = 0, 1, 0.25 do print(x) end      -- 0.0 0.25 0.5 0.75 1.0
for i = 5, 1 do print(i) end            -- tidak berjalan sama sekali (langkah default +1)
```

- Ekspresi awal, akhir, dan langkah **dievaluasi sekali** di awal.
- Variabel loop adalah **variabel lokal baru** pada tiap iterasi; mengubahnya di dalam loop tidak memengaruhi jumlah iterasi (dan sebaiknya tidak dilakukan).
- Langkah `0` menimbulkan error.

**Generic `for`:** `for k, v in <iterator> do`

```lua
local buah = { "apel", "jeruk", "mangga" }

for index, nama in ipairs(buah) do
  print(index, nama)
end

local umur = { budi = 20, sari = 22 }
for kunci, nilai in pairs(umur) do
  print(kunci, nilai)
end
```

### 3.4 `break`, `goto`, dan Label

```lua
for i = 1, 10 do
  if i == 4 then break end     -- keluar dari loop
  print(i)
end
```

Lua **tidak punya `continue`**. Gunakan `goto`:

```lua
for i = 1, 6 do
  if i % 2 == 0 then goto continue end
  print("ganjil:", i)
  ::continue::
end
```

Aturan `goto`: label ditulis `::nama::`; `goto` tidak boleh melompat ke dalam blok lain atau melompati deklarasi `local` yang masih terlihat di label. Pakai secukupnya.

> `goto` ada sejak Lua 5.2 dan didukung LuaJIT. Tidak ada di Lua 5.1 murni.

### 3.5 Nested Loop dan Iterasi

```lua
-- pola segitiga
for baris = 1, 4 do
  print(string.rep("*", baris))
end
```

```lua
-- tabel perkalian
for i = 1, 3 do
  local kolom = {}
  for j = 1, 5 do
    kolom[#kolom + 1] = string.format("%3d", i * j)
  end
  print(table.concat(kolom, " "))
end
```

**`ipairs` vs `pairs` (ringkas, dibahas penuh di Tahap 6):**

| | `ipairs(t)` | `pairs(t)` |
|---|---|---|
| Yang diiterasi | Indeks `1, 2, 3, ...` berurutan | Semua pasangan key-value |
| Berhenti saat | Menemui `nil` pertama | Semua key habis |
| Urutan | Terjamin | **Tidak terjamin** |
| Cocok untuk | Array/list | Dictionary |

### 3.6 Praktik

**1. Penilaian mahasiswa:** ubah contoh `if/elseif` menjadi function `grade(nilai)` dan uji dengan beberapa nilai.

**2. Login sederhana**

```lua
local PASSWORD <const> = "rahasia"
local kesempatan = 3

while kesempatan > 0 do
  io.write("Password: ")
  local input = io.read()
  if input == PASSWORD then
    print("Login berhasil")
    break
  end
  kesempatan = kesempatan - 1
  print("Salah. Sisa kesempatan: " .. kesempatan)
end

if kesempatan == 0 then print("Akun terkunci") end
```

**3. Tebak angka**

```lua
-- Lua 5.4 sudah menyeed generator acak otomatis.
-- Pada Lua <= 5.3 / LuaJIT panggil: math.randomseed(os.time())
local rahasia = math.random(1, 100)
local percobaan = 0

repeat
  io.write("Tebak (1-100): ")
  local tebakan = tonumber(io.read())
  percobaan = percobaan + 1
  if not tebakan then
    print("Masukkan angka!")
  elseif tebakan < rahasia then
    print("Terlalu kecil")
  elseif tebakan > rahasia then
    print("Terlalu besar")
  end
until tebakan == rahasia

print("Benar! Percobaan:", percobaan)
```

**4. Menu interaktif di terminal**

```lua
while true do
  print("\n=== MENU ===")
  print("1. Sapa")
  print("2. Hitung kuadrat")
  print("0. Keluar")
  io.write("Pilih: ")
  local pilih = io.read()

  if pilih == "1" then
    print("Halo!")
  elseif pilih == "2" then
    io.write("Angka: ")
    local n = tonumber(io.read())
    print(n and n * n or "Bukan angka")
  elseif pilih == "0" then
    print("Sampai jumpa")
    break
  else
    print("Pilihan tidak dikenal")
  end
end
```

**5. Pola dengan nested loop:** buat pola piramida dan papan catur 8×8.

**6. Pencarian data**

```lua
local data = { 4, 8, 15, 16, 23, 42 }
local target, posisi = 23, nil

for i, v in ipairs(data) do
  if v == target then posisi = i; break end
end
print(posisi and ("Ditemukan di indeks " .. posisi) or "Tidak ditemukan")
```

### 3.7 Target Kelulusan Tahap 3

- [ ] Dapat menentukan struktur kontrol yang tepat.
- [ ] Memahami perbedaan `while`, `repeat until`, dan `for`.
- [ ] Mampu melakukan iterasi terhadap table.

---

# Bagian 2: Functions dan Data Manipulation

## Tahap 4. Functions, Scope, dan Closure

**Level:** Beginner – Intermediate · **Estimasi:** Minggu 3

### 4.1 Function Fundamentals

**Function** adalah blok kode yang diberi nama (atau tidak), menerima input (*parameter*), dan menghasilkan output (*return value*). Function adalah fondasi *reusability* dan abstraksi.

```lua
-- deklarasi
local function sapa(nama)
  return "Halo, " .. nama .. "!"
end

-- pemanggilan (invocation)
print(sapa("Dina"))       --> Halo, Dina!
```

**Tiga bentuk penulisan yang ekuivalen:**

```lua
local function f(x) return x * 2 end        -- 1. local function (disarankan)
local f = function(x) return x * 2 end      -- 2. anonymous function dimasukkan ke variabel
function f(x) return x * 2 end              -- 3. global function (hindari)
```

**Parameter vs argument:** parameter adalah nama di definisi; argument adalah nilai saat pemanggilan. Lua **tidak memeriksa jumlah argumen**:

```lua
local function tampil(a, b)
  print(a, b)
end

tampil(1)          --> 1   nil     (kekurangan -> nil)
tampil(1, 2, 3)    --> 1   2       (kelebihan -> dibuang)
```

**Nilai default** dibuat dengan `or` (hati-hati pada nilai `false`):

```lua
local function salam(nama, sapaan)
  sapaan = sapaan or "Halo"
  return sapaan .. ", " .. (nama or "Tamu")
end
print(salam())                 --> Halo, Tamu
print(salam("Budi", "Hai"))    --> Hai, Budi
```

**Multiple return values:**

```lua
local function statistik(a, b, c)
  local total = a + b + c
  return total, total / 3
end

local jumlah, rata = statistik(10, 20, 30)
print(jumlah, rata)     --> 60   20.0
```

Aturan penyesuaian (*adjustment*) hasil function:

```lua
local function dua() return 1, 2 end

local a, b, c = dua()           -- a=1, b=2, c=nil
local t = { dua(), dua() }      -- {1, 1, 2}: yang bukan terakhir dipotong jadi 1 nilai
print((dua()))                  --> 1   (kurung memaksa 1 nilai)
print(dua(), 10)                --> 1   10   (dua() di tengah -> 1 nilai)
print(10, dua())                --> 10  1  2 (dua() di akhir -> semua nilai)
```

**Recursive function:** function yang memanggil dirinya sendiri. Gunakan `local function` agar nama terlihat di dalam badan function.

```lua
local function faktorial(n)
  if n <= 1 then return 1 end
  return n * faktorial(n - 1)
end
print(faktorial(5))      --> 120
```

```lua
-- SALAH: 'local f = function' membuat nama f belum ada di dalam badan function
local f = function(n) return n <= 1 and 1 or n * f(n - 1) end   -- f di sini global/nil!
```

**Variadic arguments (`...`):**

```lua
local function jumlah(...)
  local total = 0
  for _, v in ipairs({ ... }) do
    total = total + v
  end
  return total
end
print(jumlah(1, 2, 3, 4))     --> 10
```

`{ ... }` bermasalah jika ada `nil` di antara argumen. Gunakan `select` atau `table.pack`:

```lua
local function hitung(...)
  print(select("#", ...))        -- jumlah argumen SEBENARNYA (termasuk nil)
  print(select(2, ...))          -- semua argumen mulai ke-2
  local p = table.pack(...)      -- table dengan field n
  print(p.n)
end
hitung("a", nil, "c", nil)       --> 4 / nil c nil / 4
```

`table.unpack(t, i, j)` adalah kebalikan dari `pack`: memecah table menjadi banyak nilai.

```lua
local angka = { 5, 3, 9 }
print(math.max(table.unpack(angka)))   --> 9
-- Lua 5.1 / LuaJIT: gunakan unpack(angka) (global)
```

**Gula sintaks pemanggilan:**

```lua
print "halo"                     -- f"string" : argumen string literal tunggal
local function atur(opsi) return opsi.lebar * opsi.tinggi end
print(atur { lebar = 3, tinggi = 4 })    -- f{...} : argumen table literal tunggal -> 12
```

Pola `f{...}` dipakai luas sebagai *named arguments* dan DSL (misalnya konfigurasi plugin).

### 4.2 Function sebagai First-Class Value

Function di Lua adalah **nilai biasa**: bisa disimpan, dikirim, dan dikembalikan.

```lua
-- disimpan di variabel & table
local op = {
  tambah = function(a, b) return a + b end,
  kali   = function(a, b) return a * b end,
}
print(op.tambah(2, 3), op.kali(2, 3))   --> 5   6

-- dikirim sebagai argumen (callback)
local function ulangi(n, aksi)
  for i = 1, n do aksi(i) end
end
ulangi(3, function(i) print("iterasi", i) end)

-- dikembalikan dari function lain
local function pengali(faktor)
  return function(x) return x * faktor end
end
local kali3 = pengali(3)
print(kali3(10))    --> 30
```

**Higher-order functions** (menerima atau mengembalikan function):

```lua
local function map(t, f)
  local hasil = {}
  for i, v in ipairs(t) do hasil[i] = f(v) end
  return hasil
end

local function filter(t, pred)
  local hasil = {}
  for _, v in ipairs(t) do
    if pred(v) then hasil[#hasil + 1] = v end
  end
  return hasil
end

local function reduce(t, f, awal)
  local acc = awal
  for _, v in ipairs(t) do acc = f(acc, v) end
  return acc
end

local angka = { 1, 2, 3, 4, 5, 6 }
local genap   = filter(angka, function(x) return x % 2 == 0 end)
local kuadrat = map(genap, function(x) return x * x end)
local total   = reduce(kuadrat, function(a, b) return a + b end, 0)
print(total)    --> 56   (4 + 16 + 36)
```

**Callback** adalah function yang diserahkan agar dipanggil nanti oleh kode lain, pola utama pada event handler, iterator, dan API plugin.

### 4.3 Scope dan Closure

**Closure** = function + variabel dari scope luar yang ia "tangkap". Variabel tertangkap itu disebut **upvalue**.

```lua
local function buat_counter()
  local hitung = 0                -- upvalue: hidup selama closure masih dipakai
  return function()
    hitung = hitung + 1
    return hitung
  end
end

local c1 = buat_counter()
local c2 = buat_counter()
print(c1(), c1(), c1())     --> 1   2   3
print(c2())                 --> 1   (state c2 terpisah dari c1)
```

**Closure sebagai state privat (enkapsulasi):**

```lua
local function rekening(saldo_awal)
  local saldo = saldo_awal          -- tidak bisa diakses dari luar

  local function setor(n)  saldo = saldo + n end
  local function tarik(n)
    if n > saldo then return nil, "saldo tidak cukup" end
    saldo = saldo - n
    return saldo
  end
  local function cek() return saldo end

  return { setor = setor, tarik = tarik, cek = cek }
end

local r = rekening(100)
r.setor(50)
print(r.cek())          --> 150
print(r.tarik(500))     --> nil   saldo tidak cukup
```

**Upvalue dibagi oleh closure yang sama-sama menangkapnya:**

```lua
local function pasangan()
  local x = 0
  return function() x = x + 1 end, function() return x end
end
local naik, lihat = pasangan()
naik(); naik()
print(lihat())    --> 2
```

**Closure di dalam loop:** setiap iterasi `for` membuat variabel baru, sehingga tiap closure menangkap nilainya sendiri.

```lua
local fs = {}
for i = 1, 3 do
  fs[i] = function() return i end
end
print(fs[1](), fs[2](), fs[3]())    --> 1   2   3
```

**Function environment.** Variabel global sebenarnya adalah field di sebuah table *environment* (`_ENV` pada Lua 5.2+). Ini dibahas mendalam di Tahap 9.

**Tail call.** Pemanggilan `return f(x)` adalah *proper tail call*: tidak menambah ukuran call stack, sehingga rekursi ekor tidak menyebabkan *stack overflow*.

```lua
local function hitung_mundur(n)
  if n == 0 then return "selesai" end
  return hitung_mundur(n - 1)       -- tail call
end
print(hitung_mundur(1000000))       --> selesai

-- Bentuk di bawah BUKAN tail call (ada operasi setelah pemanggilan):
-- return 1 + f(n - 1)
```

**Memoization dengan closure:**

```lua
local function memoize(f)
  local cache = {}
  return function(n)
    local v = cache[n]
    if v == nil then
      v = f(n)
      cache[n] = v
    end
    return v
  end
end

local fib
fib = memoize(function(n)
  if n < 2 then return n end
  return fib(n - 1) + fib(n - 2)
end)
print(fib(80))     --> 23416728348467685
```

### 4.4 Praktik

1. **Library kalkulator:** buat table `kalkulator` berisi `tambah`, `kurang`, `kali`, `bagi` (bagi mengembalikan `nil, "pembagian dengan nol"` jika pembagi 0).
2. **Validasi data:** function `valid_email(s)` dan `valid_umur(n)` yang mengembalikan `true` atau `false, pesan`.
3. **Recursive factorial** dan **Fibonacci** (bandingkan versi biasa vs memoized dengan `os.clock()`).
4. **Multiple return values:** function `bagi_sisa(a, b)` yang mengembalikan hasil bagi dan sisa.
5. **Closure counter** dengan method `naik`, `turun`, `reset`.
6. **Callback sederhana:** function `setelah(n, aksi)` yang memanggil `aksi` setelah `n` iterasi.
7. **Higher-order filtering:** `filter(data, pred)` untuk memilih mahasiswa dengan nilai di atas 75.

### 4.5 Target Kelulusan Tahap 4

- [ ] Mampu membuat function reusable.
- [ ] Memahami lexical scope dan closure.
- [ ] Memahami function sebagai first-class value.
- [ ] Mampu menggunakan callback dan variadic arguments.

---

## Tahap 5. String Manipulation dan Pattern Matching

**Level:** Intermediate · **Estimasi:** Minggu 4

### 5.1 String Fundamentals

String di Lua adalah **urutan byte yang tidak dapat diubah (immutable)**. Operasi "mengubah" string selalu menghasilkan string baru.

```lua
local a = "petik ganda"
local b = 'petik tunggal'
local c = "Dia berkata: \"halo\""           -- escape
local d = 'It\'s fine'
local e = "tab:\t| newline:\n| backslash:\\"
local f = "\65\066\x43"                      --> ABC  (desimal & hex)
local g = "\u{48}\u{49}"                     --> HI   (escape Unicode, Lua 5.3+)
```

**Long string** (`[[ ... ]]`) menyimpan teks apa adanya, termasuk multi-baris; newline pertama diabaikan.

```lua
local html = [[
<div>
  <p>Halo</p>
</div>
]]

local level = [==[ boleh mengandung ]] di dalamnya ]==]
```

**Konkatenasi dan panjang:**

```lua
local nama = "Lua"
print("Belajar " .. nama)      --> Belajar Lua
print(#nama)                   --> 3
```

> Konkatenasi di dalam loop besar (`s = s .. x`) membuat banyak string sementara dan lambat. Kumpulkan ke table lalu panggil `table.concat` (lihat Tahap 6 dan 11).

**Immutability:**

```lua
local s = "halo"
-- s[1] = "H"          -- tidak bisa
local s2 = "H" .. s:sub(2)
print(s, s2)           --> halo   Halo
```

### 5.2 String Library

Semua function `string.*` juga dapat dipanggil sebagai method: `s:upper()` ≡ `string.upper(s)`. **Indeks string mulai dari 1**, dan indeks negatif menghitung dari belakang.

```lua
local s = "Belajar Lua"

print(s:sub(1, 7))        --> Belajar
print(s:sub(-3))          --> Lua
print(s:sub(9, -1))       --> Lua

print(s:upper(), s:lower())   --> BELAJAR LUA   belajar lua
print(s:len())                --> 11
print(("ab"):rep(3, "-"))     --> ab-ab-ab
print(s:reverse())            --> auL rajaleB

print(s:byte(1))              --> 66
print(string.char(72, 105))   --> Hi
```

**`string.find`**: mencari posisi.

```lua
print(("hello world"):find("world"))        --> 7   11
print(("hello"):find("xyz"))                --> nil
print(("a.b"):find(".", 1, true))           --> 2   2   (argumen ke-4 true = pencarian polos/plain)
```

Tanpa `plain = true`, argumen pencarian dianggap **pattern** (bukan teks biasa).

**`string.format`**: pemformatan ala `printf`.

| Spesifikasi | Arti | Contoh |
|---|---|---|
| `%d` | Integer | `("%d"):format(42)` → `42` |
| `%5d` / `%-5d` / `%05d` | Lebar / rata kiri / padding nol | `   42` / `42   ` / `00042` |
| `%f` / `%.2f` | Float | `3.14` |
| `%e`, `%g` | Notasi ilmiah / ringkas | `1.5e+03` |
| `%s` | String | `("%s"):format("hai")` |
| `%q` | String dengan quoting aman | `"ha\"i"` |
| `%x` / `%X` | Hex | `ff` / `FF` |
| `%c` | Karakter dari kode | `A` |
| `%%` | Tanda `%` literal | `%` |

```lua
print(string.format("%-10s|%6.2f|%03d", "Apel", 12.5, 7))
--> Apel      | 12.50|007
print(string.format("Nilai: %d%%", 95))   --> Nilai: 95%
```

> `%d` hanya menerima angka yang bisa direpresentasikan sebagai integer. `("%d"):format(3.5)` memicu error. Gunakan `%.0f` atau `math.floor`.

**Iterasi karakter:**

```lua
for i = 1, #"Lua" do
  print(("Lua"):sub(i, i))
end

for ch in ("Lua"):gmatch(".") do print(ch) end
```

### 5.3 Pattern Matching

**Pattern Lua bukan regular expression penuh.** Ia lebih sederhana, tanpa alternasi `|` dan tanpa kuantifier pada grup. Tetapi cukup ampuh untuk sebagian besar pekerjaan parsing.

**Character classes** (huruf kecil = cocok; huruf BESAR = kebalikannya):

| Class | Cocok dengan |
|---|---|
| `.` | Karakter apa saja |
| `%a` | Huruf |
| `%d` | Digit |
| `%l` / `%u` | Huruf kecil / kapital |
| `%s` | Whitespace |
| `%w` | Alfanumerik |
| `%p` | Tanda baca |
| `%x` | Digit heksadesimal |
| `%c` | Karakter kontrol |
| `%g` | Karakter yang dapat dicetak (kecuali spasi) |

`%A`, `%D`, `%S`, `%W` adalah negasinya.

**Character set** memakai `[...]`:

```text
[abc]      a, b, atau c
[a-z]      rentang
[%w_]      alfanumerik atau underscore
[^0-9]     BUKAN digit (negasi)
```

**Modifier pengulangan** (berlaku pada satu karakter / class / set):

| Modifier | Arti |
|---|---|
| `+` | 1 atau lebih (serakah) |
| `*` | 0 atau lebih (serakah) |
| `-` | 0 atau lebih (**tidak serakah** / *lazy*) |
| `?` | 0 atau 1 |

**Anchor:** `^` di awal pattern = awal string; `$` di akhir = akhir string.

**Karakter magis** `^$()%.[]*+-?` harus di-escape dengan `%` bila ingin dicocokkan secara literal: `%.`, `%%`, `%(`.

**Captures** `( ... )` menangkap bagian yang cocok:

```lua
local tgl = "Tanggal: 2026-10-31"

local th, bl, hr = tgl:match("(%d+)-(%d+)-(%d+)")
print(th, bl, hr)           --> 2026   10   31

print(("  halo  "):match("^%s*(.-)%s*$"))     --> halo   (trim)
print(("key=value"):match("(%w+)=(%w+)"))     --> key   value
print(("abc123"):match("%a+"), ("abc123"):match("%d+"))   --> abc   123
```

**Position capture** `()` mengembalikan posisi:

```lua
print(("hello"):find("l+"))        --> 3   4
print(("hello"):match("()ll()"))   --> 3   5
```

**`string.gmatch`**: iterator atas semua kecocokan.

```lua
for kata in ("satu dua tiga"):gmatch("%a+") do
  print(kata)
end

for k, v in ("a=1, b=2, c=3"):gmatch("(%w+)=(%w+)") do
  print(k, v)
end
```

**`string.gsub`**: substitusi. Mengembalikan string baru **dan** jumlah penggantian.

```lua
print(("halo dunia"):gsub("o", "0"))             --> hal0 dunia   2
print(("halo dunia"):gsub("o", "0", 1))          --> hal0 dunia   1  (maksimum 1 penggantian)

-- Backreference %1 pada replacement
print(("john smith"):gsub("(%w+) (%w+)", "%2, %1"))   --> smith, john   1

-- Replacement berupa function
print(("1 2 3"):gsub("%d+", function(n) return n * 10 end))   --> 10 20 30   3

-- Replacement berupa table (lookup)
local peta = { nama = "Dina", kota = "Bandung" }
print(("Halo $nama dari $kota"):gsub("%$(%w+)", peta))
--> Halo Dina dari Bandung   2
```

**Pattern lanjutan:**

```lua
-- %b: pasangan seimbang
print(("f(a(b)c) sisa"):match("%b()"))       --> (a(b)c)

-- %f: frontier (batas kata)
print(("THE (quick) fox"):find("%f[%a]%a+%f[%A]"))   --> 1  3   (kata pertama)

-- Back-reference di dalam pattern: karakter yang berulang
print(("abccba"):match("(.)%1"))              --> c

-- Lazy vs greedy
print(("<a><b>"):match("<(.*)>"))   --> a><b   (serakah)
print(("<a><b>"):match("<(.-)>"))   --> a      (tidak serakah)
```

### 5.4 Lua Patterns vs Regular Expressions

| Fitur | Lua pattern | Regex (PCRE) |
|---|---|---|
| Alternasi `a\|b` | ❌ | ✅ |
| Kuantifier pada grup `(ab)+` | ❌ | ✅ |
| Lookahead / lookbehind | ❌ | ✅ |
| Escape | `%` | `\` |
| Lazy quantifier | `-` | `*?` |
| Pencocokan seimbang | `%b()` | Tidak ada (umumnya) |
| Frontier | `%f[set]` | `\b` (kira-kira) |
| Kecepatan & ukuran | Sangat ringan | Lebih berat |

**Keterbatasan penting:**

- Tidak ada alternasi: untuk "foo atau bar", lakukan dua `find`/`match`.
- Pattern bekerja per **byte**, bukan per karakter Unicode. Untuk teks UTF-8 gunakan `utf8.charpattern`, `utf8.len`, `utf8.codes`.
- Pattern kompleks bisa lambat (backtracking). Untuk grammar yang rumit, pertimbangkan **LPeg** (library parsing berbasis PEG).

```lua
print(#"é")             --> 2   (dua byte)
print(utf8.len("é"))    --> 1   (satu karakter)
for _, kode in utf8.codes("hé!") do print(kode) end   --> 104  233  33
```

> `utf8` ada sejak Lua 5.3. Di LuaJIT/Neovim gunakan `vim.str_utfindex` atau library lain.

### 5.5 Praktik

**1. Validator input**

```lua
local function valid_email(s)
  return s:match("^[%w._%-]+@[%w.-]+%.%a%a+$") ~= nil
end
print(valid_email("dina@contoh.com"))   --> true
print(valid_email("dina@@contoh"))      --> false
```

**2. Parser log**

```lua
local baris = '2026-10-31 08:15:42 ERROR [db] koneksi gagal'
local tgl, jam, level, modul, pesan =
  baris:match("^(%S+) (%S+) (%u+) %[(%w+)%] (.+)$")
print(level, modul, pesan)     --> ERROR   db   koneksi gagal
```

**3. Pencarian teks:** hitung berapa kali sebuah kata muncul memakai `gmatch` (ingat batas kata dengan `%f`).

**4. Replace string:** ubah `snake_case` menjadi `camelCase`:

```lua
local function ke_camel(s)
  return (s:gsub("_(%w)", string.upper))
end
print(ke_camel("nama_depan_user"))   --> namaDepanUser
```

**5. Parser tanggal:** ubah `"31/10/2026"` menjadi table `{hari=31, bulan=10, tahun=2026}`.

**6. Ekstraktor informasi:** ambil semua URL dari teks dengan `gmatch("https?://[%w%.%-_/%%?=&]+")`.

**7. Pemisah string (split) & trim** yang reusable:

```lua
local function split(s, pemisah)
  local hasil = {}
  for bagian in (s .. pemisah):gmatch("(.-)" .. pemisah:gsub("%p", "%%%0")) do
    hasil[#hasil + 1] = bagian
  end
  return hasil
end
print(table.concat(split("a,b,c", ","), "|"))   --> a|b|c
```

### 5.6 Target Kelulusan Tahap 5

- [ ] Mampu memanipulasi string menggunakan standard library.
- [ ] Memahami Lua pattern matching.
- [ ] Mampu membuat parser teks sederhana.

---

## Tahap 6. Tables dan Data Structures

**Level:** Intermediate · **Estimasi:** Minggu 5–6

### 6.1 Table Fundamentals

**Table** adalah satu-satunya mekanisme struktur data di Lua. Table berupa *associative array*: kumpulan pasangan **key → value**. Key boleh bertipe apa saja **kecuali `nil` (dan NaN)**; value boleh apa saja.

```lua
-- Membuat table
local kosong = {}

-- Array-like (indeks mulai 1!)
local buah = { "apel", "jeruk", "mangga" }
print(buah[1], buah[3], #buah)      --> apel   mangga   3

-- Dictionary-like
local orang = { nama = "Dina", umur = 22 }
print(orang.nama, orang["umur"])    --> Dina   22
-- orang.nama  ≡  orang["nama"]   (gula sintaks untuk key string yang valid sebagai identifier)

-- Key bebas tipe
local t = {}
t[1] = "satu"
t["dua"] = 2
t[true] = "boolean"
t[3.5] = "float"

-- Mixed table
local campur = { "a", "b", judul = "Campur", [10] = "sepuluh" }
```

**Nested table:**

```lua
local kelas = {
  nama = "Lua 101",
  mahasiswa = {
    { nama = "Budi", nilai = { 80, 75 } },
    { nama = "Sari", nilai = { 90, 95 } },
  },
}
print(kelas.mahasiswa[2].nama)          --> Sari
print(kelas.mahasiswa[2].nilai[1])      --> 90
```

**Table adalah reference type** (disimpan sebagai referensi, bukan disalin):

```lua
local a = { 1, 2, 3 }
local b = a              -- b menunjuk table YANG SAMA
b[1] = 99
print(a[1])              --> 99

print({} == {})          --> false  (identitas berbeda)
print(a == b)            --> true
```

**Panjang `#` dan perilaku `nil`.** Operator `#` mengembalikan sebuah *border*. Pada **sequence** (indeks 1..n tanpa lubang) hasilnya pasti n. Jika ada lubang (`nil` di tengah), hasilnya **tidak dapat diandalkan**.

```lua
local t = { 1, 2, 3 }
t[#t + 1] = 4           -- append
print(#t)               --> 4

t[2] = nil              -- membuat lubang
print(#t)               --> bisa 4 atau 1 (jangan diandalkan!)
```

Menetapkan `t[k] = nil` **menghapus** field tersebut. Karena itu table tidak bisa menyimpan nilai `nil`; gunakan sentinel (mis. `false` atau object khusus) bila perlu.

### 6.2 Iteration

```lua
local data = { "a", "b", "c", x = 1, y = 2 }

-- ipairs: 1..n berurutan, berhenti di nil pertama
for i, v in ipairs(data) do print(i, v) end         -- a b c saja

-- pairs: semua pasangan, URUTAN TIDAK TERJAMIN
for k, v in pairs(data) do print(k, v) end

-- next: primitif di balik pairs
print(next({}))                  --> nil  (table kosong)
local k, v = next({ z = 26 })    --> z  26
```

Pengecekan table kosong:

```lua
local function kosong(t) return next(t) == nil end
print(kosong({}), kosong({ 1 }))    --> true   false
```

**Aturan memodifikasi table saat traversal:** boleh **menghapus/mengubah** field yang sudah ada (set ke `nil` atau nilai lain), tetapi **menambah key baru** saat `pairs` berjalan menghasilkan perilaku tidak terdefinisi.

```lua
for k in pairs(t) do
  if kondisi(k) then t[k] = nil end    -- aman
end
```

Untuk iterasi **berurutan terurut kunci**, kumpulkan key lalu urutkan:

```lua
local function pairs_terurut(t)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys)
  local i = 0
  return function()
    i = i + 1
    local k = keys[i]
    if k ~= nil then return k, t[k] end
  end
end

for k, v in pairs_terurut({ c = 3, a = 1, b = 2 }) do print(k, v) end   --> a b c
```

### 6.3 Table Library

```lua
local t = { "b", "d" }

table.insert(t, "e")          -- tambah di akhir:       b d e
table.insert(t, 1, "a")       -- sisip di posisi 1:     a b d e
table.insert(t, 3, "c")       -- sisip di posisi 3:     a b c d e

print(table.remove(t))        --> e   (hapus & kembalikan elemen terakhir)
print(table.remove(t, 1))     --> a   (hapus elemen posisi 1; elemen lain bergeser)

print(table.concat(t, ", "))              --> b, c, d
print(table.concat({ 1, 2, 3 }, "-"))     --> 1-2-3
print(table.concat({ "x", "y", "z" }, "", 2, 3))   --> yz
```

**`table.sort`**

```lua
local angka = { 5, 2, 8, 1 }
table.sort(angka)                          -- ascending
table.sort(angka, function(a, b) return a > b end)   -- descending

local org = {
  { nama = "Budi", umur = 30 },
  { nama = "Sari", umur = 25 },
}
table.sort(org, function(a, b) return a.umur < b.umur end)
```

Catatan: `table.sort` **tidak stabil**; fungsi pembanding harus *strict ordering* (gunakan `<`, bukan `<=`) atau bisa memicu error "invalid order function".

**`table.move(a1, f, e, t [, a2])`** menyalin elemen `a1[f..e]` ke `a2[t..]`:

```lua
local a = { 1, 2, 3 }
local b = table.move(a, 1, #a, 1, {})       -- salin a ke table baru
table.move(a, 1, #a, 2)                     -- geser elemen ke kanan sejauh 1 (in-place)
```

**`table.pack` / `table.unpack`:**

```lua
local p = table.pack(1, nil, 3)
print(p.n)                       --> 3
print(table.unpack(p, 1, p.n))   --> 1   nil   3
```

### 6.4 Data Structures

> Contoh Stack dan Queue di bawah memakai `setmetatable` dan sintaks `obj:method()`. Mekanismenya dijelaskan penuh di Tahap 8. Untuk sekarang, cukup perhatikan pola penyimpanan datanya.

**Stack (LIFO):**

```lua
local Stack = {}
Stack.__index = Stack

function Stack.new() return setmetatable({ items = {}, n = 0 }, Stack) end
function Stack:push(v) self.n = self.n + 1; self.items[self.n] = v end
function Stack:pop()
  if self.n == 0 then return nil end
  local v = self.items[self.n]
  self.items[self.n] = nil
  self.n = self.n - 1
  return v
end

local s = Stack.new()
s:push(1); s:push(2)
print(s:pop(), s:pop(), s:pop())     --> 2   1   nil
```

**Queue (FIFO) yang efisien** (dua indeks, bukan `table.remove(t, 1)` yang O(n)):

```lua
local Queue = {}
Queue.__index = Queue

function Queue.new() return setmetatable({ first = 1, last = 0, items = {} }, Queue) end
function Queue:push(v) self.last = self.last + 1; self.items[self.last] = v end
function Queue:pop()
  if self.first > self.last then return nil end
  local v = self.items[self.first]
  self.items[self.first] = nil
  self.first = self.first + 1
  return v
end
```

**Set** (key = anggota):

```lua
local function Set(daftar)
  local s = {}
  for _, v in ipairs(daftar) do s[v] = true end
  return s
end

local warna = Set { "merah", "hijau", "biru" }
print(warna["hijau"])     --> true
print(warna["ungu"])      --> nil (falsy)

warna["ungu"] = true      -- tambah
warna["merah"] = nil      -- hapus
```

**Map/dictionary** sudah berupa table biasa. Hitung frekuensi kata:

```lua
local frek = {}
for kata in ("a b a c b a"):gmatch("%a") do
  frek[kata] = (frek[kata] or 0) + 1
end
-- frek = { a = 3, b = 2, c = 1 }
```

**Linked list:**

```lua
local list = nil                               -- list kosong
for i = 3, 1, -1 do list = { nilai = i, berikut = list } end

local node = list
while node do
  print(node.nilai)                            --> 1 2 3
  node = node.berikut
end
```

**Shallow copy vs deep copy:**

```lua
local function salin_dangkal(t)
  local hasil = {}
  for k, v in pairs(t) do hasil[k] = v end
  return hasil
end

local function salin_dalam(t, terlihat)
  if type(t) ~= "table" then return t end
  terlihat = terlihat or {}
  if terlihat[t] then return terlihat[t] end          -- tangani referensi melingkar
  local hasil = {}
  terlihat[t] = hasil
  for k, v in pairs(t) do
    hasil[salin_dalam(k, terlihat)] = salin_dalam(v, terlihat)
  end
  return setmetatable(hasil, getmetatable(t))
end

local asli = { a = { b = 1 } }
local dangkal = salin_dangkal(asli)
local dalam = salin_dalam(asli)
asli.a.b = 99
print(dangkal.a.b, dalam.a.b)    --> 99   1
```

**Perbandingan isi table:**

```lua
local function sama(a, b)
  if a == b then return true end
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  for k, v in pairs(a) do
    if not sama(v, b[k]) then return false end
  end
  for k in pairs(b) do
    if a[k] == nil then return false end
  end
  return true
end
print(sama({ 1, { 2 } }, { 1, { 2 } }))   --> true
```

**Serialisasi table** (menjadi teks Lua yang bisa dimuat kembali):

```lua
local function serialisasi(v, indent)
  indent = indent or ""
  if type(v) == "table" then
    local bagian = {}
    local ind = indent .. "  "
    for k, val in pairs(v) do
      local kunci = type(k) == "string" and ("[%q]"):format(k) or ("[" .. tostring(k) .. "]")
      bagian[#bagian + 1] = ind .. kunci .. " = " .. serialisasi(val, ind)
    end
    return "{\n" .. table.concat(bagian, ",\n") .. "\n" .. indent .. "}"
  elseif type(v) == "string" then
    return ("%q"):format(v)
  else
    return tostring(v)
  end
end

local teks = "return " .. serialisasi({ nama = "Dina", skor = { 90, 85 } })
local dimuat = load(teks)()           -- load() dibahas di Tahap 9
print(dimuat.skor[2])                 --> 85
```

> Untuk format pertukaran data lintas bahasa, gunakan JSON (library seperti `dkjson` atau `lua-cjson`). Di Neovim tersedia `vim.json`.

**Immutable data pattern:** buat table *read-only* dengan metatable (detail di Tahap 8).

```lua
local function readonly(t)
  return setmetatable({}, {
    __index = t,
    __newindex = function() error("table ini read-only", 2) end,
    __len = function() return #t end,
  })
end

local KONFIG = readonly { host = "localhost", port = 8080 }
print(KONFIG.port)                  --> 8080
-- KONFIG.port = 1                  --> error: table ini read-only
```

### 6.5 Praktik

1. **CRUD dengan table:** kelola daftar kontak (`tambah`, `cari`, `ubah`, `hapus`, `daftar`).
2. **Struktur data mahasiswa:** table berisi `nama`, `nim`, `nilai = {}`; hitung rata-rata per mahasiswa dan peringkat kelas.
3. **Sorting & filtering:** urutkan mahasiswa berdasarkan rata-rata (menurun); tampilkan yang di atas 80.
4. **Nested data:** modelkan "toko" dengan kategori → produk → varian.
5. **Stack dan Queue:** implementasikan, lalu pakai stack untuk memvalidasi tanda kurung seimbang.
6. **Deep copy:** uji pada table dengan referensi melingkar (`a.self = a`).
7. **Data manager sederhana:** modul dengan `load(path)`/`save(path)` berbasis serialisasi.

### 6.6 Target Kelulusan Tahap 6

- [ ] Memahami table sebagai reference type.
- [ ] Mampu mengelola array dan dictionary.
- [ ] Mampu membuat struktur data sendiri.
- [ ] Memahami perbedaan `pairs()` dan `ipairs()`.

---

# Bagian 3: Modular Programming dan OOP

## Tahap 7. Modules, Packages, dan Error Handling

**Level:** Intermediate · **Estimasi:** Minggu 7

### 7.1 Konsep Modular Programming

Program yang membesar harus dipecah menjadi bagian-bagian kecil dengan tanggung jawab jelas. Di Lua, **module adalah file yang mengembalikan sebuah nilai (biasanya table)**. Tidak ada sintaks khusus "module"; cukup `return`.

```lua
-- mathx.lua
local M = {}

local function validasi(x)            -- PRIVAT: local, tidak diekspor
  assert(type(x) == "number", "argumen harus angka")
end

function M.kuadrat(x)                 -- PUBLIK: dimasukkan ke table M
  validasi(x)
  return x * x
end

function M.rata_rata(t)
  local total = 0
  for _, v in ipairs(t) do total = total + v end
  return total / #t
end

M.VERSI = "1.0.0"

return M                              -- nilai inilah yang diterima require
```

```lua
-- main.lua
local mathx = require("mathx")         -- tanpa ekstensi .lua
print(mathx.kuadrat(7))                --> 49
print(mathx.rata_rata({ 2, 4, 6 }))    --> 4.0
```

### 7.2 Cara Kerja `require`

Saat `require("nama")` dipanggil, Lua:

1. Memeriksa **`package.loaded["nama"]`**. Jika sudah ada, langsung dikembalikan (**caching**).
2. Memeriksa **`package.preload["nama"]`** (loader yang didaftarkan manual).
3. Mencari file Lua lewat **`package.path`**.
4. Mencari library C lewat **`package.cpath`**.
5. Menjalankan file tersebut **sekali**, menyimpan nilai return di `package.loaded`, lalu mengembalikannya.

```lua
print(package.path)
--> ./?.lua;/usr/local/share/lua/5.4/?.lua;/usr/local/share/lua/5.4/?/init.lua;...
```

Tanda `?` diganti nama module; **titik diubah menjadi pemisah direktori**:

| Pemanggilan | File yang dicari |
|---|---|
| `require("util")` | `./util.lua` |
| `require("app.util")` | `./app/util.lua` |
| `require("app")` | `./app.lua` atau `./app/init.lua` |

Menambahkan lokasi pencarian:

```lua
package.path = "./src/?.lua;./src/?/init.lua;" .. package.path
```

Mencari lokasi file module, berguna untuk debugging:

```lua
print(package.searchpath("mathx", package.path))   --> ./mathx.lua
```

**Module caching**: file hanya dieksekusi sekali.

```lua
-- counter.lua
print("counter.lua dimuat")
local n = 0
return { naik = function() n = n + 1; return n end }
```

```lua
local a = require("counter")      --> tercetak: counter.lua dimuat
local b = require("counter")      --> (tidak tercetak lagi)
print(a == b)                     --> true  (instance sama)
print(a.naik(), b.naik())         --> 1   2  (state dibagi)

-- Memaksa muat ulang (mis. saat development):
package.loaded["counter"] = nil
local c = require("counter")      --> tercetak lagi
```

**`package.preload`:** mendaftarkan module tanpa file.

```lua
package.preload["virtual"] = function(nama)
  return { pesan = "aku module tanpa file: " .. nama }
end
print(require("virtual").pesan)
```

**Module initialization:** kode di level atas file dijalankan saat pertama kali di-`require`. Hindari efek samping besar di sana (I/O, koneksi jaringan); lebih baik sediakan function `init()` atau `setup()`.

**Circular dependencies** (A butuh B, B butuh A) menyebabkan masalah: pada Lua 5.4 memicu rekursi tak berujung hingga error stack overflow (versi lain bisa memberi pesan *loop or previous error loading module*). Solusi:

```lua
-- 1. Require lambat (di dalam function, saat dibutuhkan)
local M = {}
function M.proses()
  local b = require("b")      -- baru dimuat saat dipanggil
  return b.kerja()
end
return M

-- 2. Ekstrak kode bersama ke module ketiga (c.lua) yang dipakai A dan B
-- 3. Daftarkan module lebih awal: package.loaded[...] = M sebelum require lain
```

**Mengatur path relatif terhadap skrip** (agar tidak bergantung pada direktori kerja):

```lua
local dir = arg and arg[0] and arg[0]:match("^(.*)[/\\]") or "."
package.path = dir .. "/?.lua;" .. dir .. "/?/init.lua;" .. package.path
```

### 7.3 Organisasi Folder dan Public/Private API

Struktur proyek yang direkomendasikan:

```text
proyek/
├── main.lua
├── src/
│   └── tugas/
│       ├── init.lua        -- require("tugas")
│       ├── model.lua       -- require("tugas.model")
│       ├── storage.lua
│       └── util.lua
├── spec/                   -- test (Busted)
├── README.md
└── proyek-scm-1.rockspec   -- (Tahap 11)
```

Pola **fasad** pada `init.lua`: hanya mengekspos API publik, menyembunyikan sisanya.

```lua
-- src/tugas/init.lua
local model   = require("tugas.model")
local storage = require("tugas.storage")

local M = {}
M.baru   = model.baru            -- publik
M.simpan = storage.simpan        -- publik
-- util.lua tidak diekspor: privat bagi package ini
return M
```

Konvensi privat: awalan underscore (`_internal`) menandai "jangan dipakai dari luar", atau sembunyikan benar-benar dengan `local`.

### 7.4 Error Handling

Ada dua jenis kegagalan:

1. **Kegagalan yang diperkirakan** (file tidak ada, input salah) → kembalikan `nil, pesan`.
2. **Kesalahan pemrograman / kondisi tak mungkin** (argumen salah tipe) → lempar `error`.

**`error(pesan [, level])`**

```lua
local function bagi(a, b)
  if b == 0 then
    error("pembagian dengan nol")          -- menambah info "file:baris:"
  end
  return a / b
end

-- error("x", 0)  -> tanpa info posisi
-- error("x", 2)  -> posisi menunjuk ke PEMANGGIL function (cocok untuk validasi argumen)
```

**`assert(v [, pesan])`**: melempar error bila `v` falsy; jika tidak, mengembalikan semua argumennya.

```lua
local f = assert(io.open("data.txt", "r"))      -- error: data.txt: No such file or directory
local n = assert(tonumber("42"), "bukan angka")
```

**`pcall(f, ...)`**: *protected call*. Menjalankan `f` tanpa menghentikan program bila terjadi error.

```lua
local ok, hasil = pcall(bagi, 10, 0)
if ok then
  print("hasil:", hasil)
else
  print("gagal:", hasil)       --> gagal: contoh.lua:3: pembagian dengan nol
end

print(pcall(bagi, 10, 2))      --> true   5.0
```

**`xpcall(f, handler, ...)`**: sama seperti `pcall`, tetapi `handler` dipanggil **di titik terjadinya error** sehingga bisa mengambil stack trace.

```lua
local function handler(err)
  return debug.traceback("ERROR: " .. tostring(err), 2)
end

local ok, jejak = xpcall(function() bagi(1, 0) end, handler)
if not ok then print(jejak) end
```

**Error propagation & rethrow:**

```lua
local function lapisan_bawah() error("disk penuh") end

local function lapisan_tengah()
  local ok, err = pcall(lapisan_bawah)
  if not ok then
    error("gagal menyimpan: " .. err, 0)     -- bungkus dengan konteks, lempar lagi
  end
end
```

**Error object:** `error` bisa melempar **nilai apa saja**, termasuk table. Ini memungkinkan error terstruktur:

```lua
local ErrorApp = {}
ErrorApp.__index = ErrorApp
ErrorApp.__tostring = function(e) return ("[%s] %s"):format(e.kode, e.pesan) end

local function new_error(kode, pesan)
  return setmetatable({ kode = kode, pesan = pesan }, ErrorApp)
end

local function cari_user(id)
  if id ~= 1 then error(new_error("NOT_FOUND", "user " .. id .. " tidak ada")) end
  return { nama = "Dina" }
end

local ok, err = pcall(cari_user, 99)
if not ok then
  if getmetatable(err) == ErrorApp and err.kode == "NOT_FOUND" then
    print("Ditangani:", tostring(err))        --> Ditangani: [NOT_FOUND] user 99 tidak ada
  else
    error(err, 0)                              -- error lain: lempar kembali
  end
end
```

**Idiom `nil, err` untuk kegagalan yang diperkirakan:**

```lua
local function baca_file(path)
  local f, err = io.open(path, "r")
  if not f then return nil, err end
  local isi = f:read("a")
  f:close()
  return isi
end

local isi, err = baca_file("tidak-ada.txt")
if not isi then print("Gagal:", err) end
```

**Pesan error dari Lua sendiri:** `attempt to index a nil value (field 'x')`, `attempt to call a nil value (global 'foo')`, `attempt to perform arithmetic on a nil value`. Baca baris dan nama variabel yang disebut; biasanya itu sudah menunjuk akar masalah.

### 7.5 Debugging: Stack Trace dan Debug Library

```lua
print(debug.traceback("titik ini"))

local info = debug.getinfo(1, "Sl")
print(info.short_src, info.currentline)         --> contoh.lua   12
```

`debug.getinfo(f_atau_level, "nSl")` memberi nama, sumber, dan baris. `debug.sethook` memungkinkan pelacakan (dipakai profiler dan debugger).

**Debug dengan print terstruktur:**

```lua
local function dump(v) 
  print(require("inspect")(v))     -- library pihak ketiga "inspect.lua" (via LuaRocks)
end
```

> Library `debug` bersifat kuat dan **tidak aman diberikan ke kode tak tepercaya** (lihat sandbox di Tahap 9).

### 7.6 Praktik

**1. Aplikasi multi-module:** pecah program daftar tugas menjadi `model.lua`, `storage.lua`, `ui.lua`, `main.lua`.

**2. Custom error handler:** bungkus `main()` dengan `xpcall` dan cetak traceback ke `stderr`, lalu `os.exit(1)`.

**3. Logger**

```lua
-- logger.lua
local Logger = {}

local LEVEL = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4 }
local minimum = LEVEL.INFO

function Logger.set_level(nama)
  minimum = assert(LEVEL[nama], "level tidak dikenal: " .. tostring(nama))
end

local function catat(nama, fmt, ...)
  if LEVEL[nama] < minimum then return end
  local pesan = select("#", ...) > 0 and fmt:format(...) or fmt
  io.stderr:write(("%s [%s] %s\n"):format(os.date("%Y-%m-%d %H:%M:%S"), nama, pesan))
end

for nama in pairs(LEVEL) do
  Logger[nama:lower()] = function(...) catat(nama, ...) end
end

return Logger
```

```lua
local log = require("logger")
log.set_level("DEBUG")
log.info("Server jalan di port %d", 8080)
log.error("Koneksi gagal")
```

**4. Utility library:** `util.lua` berisi `split`, `trim`, `map`, `filter`, `keys`, `values`, `merge`.

**5. CLI modular:** parse `arg` menjadi sub-perintah (`tambah`, `daftar`, `hapus`) dan dispatch ke function di module terpisah:

```lua
local perintah = {
  tambah = function(args) --[[ ... ]] end,
  daftar = function(args) --[[ ... ]] end,
}
local nama = arg[1]
local fn = perintah[nama]
if not fn then
  io.stderr:write("Perintah tidak dikenal. Gunakan: tambah | daftar\n")
  os.exit(1)
end
fn({ table.unpack(arg, 2) })
```

**6. CRUD terpisah module:** `repository` (akses data), `service` (aturan bisnis), `cli` (tampilan).

### 7.7 Target Kelulusan Tahap 7

- [ ] Mampu membangun aplikasi modular.
- [ ] Memahami bagaimana `require()` memuat dan menyimpan module.
- [ ] Mampu menangani error secara terstruktur.

---

## Tahap 8. Object-Oriented Programming (OOP) Lua

**Level:** Intermediate – Advanced · **Estimasi:** Minggu 8–9

### 8.1 Konsep OOP dan Model OOP Lua

OOP mengorganisasi program sebagai kumpulan **objek** yang menggabungkan **data (state)** dan **perilaku (method)**. Pilar umum: *encapsulation*, *inheritance*, *polymorphism*, *abstraction*.

**Lua tidak memiliki `class`.** Yang ada hanya table dan metatable, dan dari keduanya kita membangun OOP bergaya **prototype-based** (seperti JavaScript): objek mewarisi dari objek lain lewat rantai `__index`.

| Konsep | Bahasa berbasis class (Java, Python) | Lua |
|---|---|---|
| Class | Konstruksi bahasa | Table biasa yang berperan sebagai "cetakan" |
| Instance | `new Kelas()` | Table baru dengan metatable menunjuk ke class |
| Method | Didefinisikan dalam class | Function di table class |
| `self` / `this` | Implisit | Parameter pertama (otomatis lewat `:`) |
| Inheritance | `extends` | Rantai `__index` antar table |

**Sintaks `:` (titik dua)** adalah gula sintaks:

```lua
obj:metode(a)      -- sama dengan  obj.metode(obj, a)

function Kelas:metode(a) ... end     -- sama dengan  function Kelas.metode(self, a) ... end
```

### 8.2 Metatable: Fondasi OOP

**Metatable** adalah table biasa yang menetapkan **perilaku khusus** (lewat *metamethod*) bagi table lain.

```lua
local t = {}
local mt = { __index = function(_, key) return "tidak ada: " .. key end }
setmetatable(t, mt)          -- mengembalikan t
print(getmetatable(t) == mt) --> true
print(t.foo)                 --> tidak ada: foo
```

**`__index`**: dipakai saat **membaca** key yang tidak ada di table.

- Jika berupa **table**, Lua mencari key itu di table tersebut (dan seterusnya, membentuk *rantai pewarisan*).
- Jika berupa **function** `(table, key)`, function dipanggil dan nilai returnnya jadi hasil.

```lua
local default = { warna = "putih", ukuran = "M" }
local baju = setmetatable({ warna = "merah" }, { __index = default })

print(baju.warna)     --> merah   (ada di baju)
print(baju.ukuran)    --> M       (diteruskan ke default)
print(baju.merek)     --> nil     (tidak ada di keduanya)
```

**`__newindex`**: dipanggil saat **menulis** key yang **belum ada** di table.

```lua
local log = {}
local proxy = setmetatable({}, {
  __newindex = function(t, k, v)
    print("set", k, v)
    rawset(t, k, v)        -- rawset: menulis tanpa memicu metamethod
  end,
})
proxy.a = 1       --> set   a   1
proxy.a = 2       --> (tidak tercetak: key sudah ada, __newindex tidak dipanggil)
```

`rawget(t, k)`, `rawset(t, k, v)`, `rawequal(a, b)`, dan `rawlen(t)` melewati metamethod.

### 8.3 Membuat Class, Constructor, dan Method

Pola standar:

```lua
local User = {}
User.__index = User              -- instance akan mencari method di User

-- constructor
function User.new(nama, email)
  local self = setmetatable({}, User)
  self.nama = nama
  self.email = email
  self.aktif = true
  return self
end

-- method (memakai self)
function User:sapa()
  return "Halo, aku " .. self.nama
end

function User:nonaktifkan()
  self.aktif = false
end

local u = User.new("Dina", "dina@contoh.com")
print(u:sapa())        --> Halo, aku Dina
u:nonaktifkan()
print(u.aktif)         --> false
```

Urutan pencarian `u:sapa()`: Lua mencari `sapa` di `u` → tidak ada → lihat metatable `u` (`User`) → `__index` = `User` → ketemu di `User.sapa`.

**Memanggil dengan `.` vs `:`** (kesalahan umum pemula):

```lua
print(u.sapa(u))   -- benar
print(u:sapa())    -- benar (sama)
-- print(u.sapa()) -- salah: self = nil -> error "attempt to index a nil value (local 'self')"
```

**Class Product dengan metamethod `__tostring`:**

```lua
local Product = {}
Product.__index = Product
Product.__tostring = function(p) return ("%s (Rp %d)"):format(p.nama, p.harga) end

function Product.new(nama, harga)
  return setmetatable({ nama = nama, harga = harga }, Product)
end

function Product:diskon(persen)
  return self.harga * (100 - persen) / 100
end

local p = Product.new("Keyboard", 350000)
print(p)                 --> Keyboard (Rp 350000)
print(p:diskon(10))      --> 315000.0
```

### 8.4 Encapsulation

Lua tidak punya `private`. Ada beberapa teknik:

**1. Konvensi:** awalan `_` menandai privat.

```lua
function Akun.new(saldo) return setmetatable({ _saldo = saldo }, Akun) end
```

**2. Closure (benar-benar privat):**

```lua
local function Akun(saldo_awal)
  local saldo = saldo_awal              -- tidak bisa diakses dari luar
  local self = {}
  function self.setor(n) saldo = saldo + n end
  function self.saldo() return saldo end
  return self
end

local a = Akun(100)
a.setor(50)
print(a.saldo())      --> 150
print(a.saldo_awal)   --> nil
```

Kekurangan closure: setiap objek menyimpan salinan function sendiri (lebih boros memori dibanding method yang dibagi lewat metatable).

**3. Proxy table:** simpan data di table tersembunyi, ekspos proxy.

```lua
local Kelas = {}
local data_privat = setmetatable({}, { __mode = "k" })   -- weak keys; lihat Tahap 9

function Kelas.new(rahasia)
  local obj = setmetatable({}, Kelas)
  data_privat[obj] = { rahasia = rahasia }
  return obj
end

function Kelas:buka() return data_privat[self].rahasia end
Kelas.__index = Kelas
```

### 8.5 Inheritance dan Polymorphism

```lua
-- Class dasar
local Hewan = {}
Hewan.__index = Hewan

function Hewan.new(nama)
  return setmetatable({ nama = nama }, Hewan)
end
function Hewan:bersuara() return "..." end
function Hewan:perkenalan() return self.nama .. " berkata " .. self:bersuara() end

-- Class turunan: mewarisi Hewan
local Kucing = setmetatable({}, { __index = Hewan })   -- rantai pewarisan
Kucing.__index = Kucing

function Kucing.new(nama, warna)
  local self = Hewan.new(nama)            -- panggil konstruktor induk
  self.warna = warna
  return setmetatable(self, Kucing)       -- ganti metatable ke Kucing
end

function Kucing:bersuara() return "meong" end   -- override

local Anjing = setmetatable({}, { __index = Hewan })
Anjing.__index = Anjing
function Anjing.new(nama) return setmetatable(Hewan.new(nama), Anjing) end
function Anjing:bersuara() return "guk" end

-- Polymorphism: satu antarmuka, perilaku berbeda
local daftar = { Kucing.new("Mimi", "putih"), Anjing.new("Bruno"), Hewan.new("???") }
for _, h in ipairs(daftar) do
  print(h:perkenalan())
end
--> Mimi berkata meong
--> Bruno berkata guk
--> ??? berkata ...
```

**Memanggil method induk dari method override:**

```lua
function Kucing:perkenalan()
  return Hewan.perkenalan(self) .. " (bulu " .. self.warna .. ")"
end
```

**Helper `class` yang reusable** (tanpa library eksternal):

```lua
local function class(induk)
  local c = {}
  c.__index = c
  if induk then setmetatable(c, { __index = induk }) end
  c.super = induk

  c.new = function(...)
    local obj = setmetatable({}, c)
    if obj.init then obj:init(...) end
    return obj
  end
  return c
end

-- Pemakaian
local Bentuk = class()
function Bentuk:init(nama) self.nama = nama end
function Bentuk:luas() return 0 end
function Bentuk:info() return ("%s luas=%.2f"):format(self.nama, self:luas()) end

local Lingkaran = class(Bentuk)
function Lingkaran:init(r)
  Bentuk.init(self, "lingkaran")
  self.r = r
end
function Lingkaran:luas() return math.pi * self.r ^ 2 end

print(Lingkaran.new(2):info())      --> lingkaran luas=12.57
```

**`is_a` / instanceof:**

```lua
local function is_a(obj, kelas)
  local mt = getmetatable(obj)
  while mt do
    if mt == kelas then return true end
    local parent = getmetatable(mt)
    mt = parent and parent.__index
  end
  return false
end
```

### 8.6 Composition vs Inheritance

Pewarisan menciptakan hubungan **"adalah-sebuah"** (*is-a*) yang kaku dan hierarki dalam. **Komposisi** menciptakan hubungan **"memiliki"** (*has-a*) / "bisa melakukan", dan lebih fleksibel.

```lua
-- "Kemampuan" sebagai potongan perilaku yang bisa dicampur
local Bisa = {
  terbang = function(self) return self.nama .. " terbang" end,
  berenang = function(self) return self.nama .. " berenang" end,
}

local function campur(obj, ...)
  for _, nama in ipairs({ ... }) do obj[nama] = Bisa[nama] end
  return obj
end

local bebek = campur({ nama = "Bebek" }, "terbang", "berenang")
print(bebek:terbang(), bebek:berenang())

-- Atau: objek MENYIMPAN objek lain
local Mobil = {}
Mobil.__index = Mobil
function Mobil.new(mesin) return setmetatable({ mesin = mesin }, Mobil) end
function Mobil:jalan() return self.mesin:nyalakan() end     -- delegasi
```

**Kapan memilih komposisi:** ketika perilaku bisa berasal dari banyak sumber, ketika hierarki mulai lebih dari 2-3 level, atau ketika hubungannya bukan benar-benar *is-a*. Aturan praktis: **utamakan komposisi, pakai inheritance seperlunya**.

### 8.7 Prototype-based Programming

Karena objek hanya table dengan `__index`, kita dapat membuat objek baru dengan **mengkloning/mewarisi dari objek lain** (bukan dari class):

```lua
local function turunkan(prototipe, ubah)
  ubah = ubah or {}
  return setmetatable(ubah, { __index = prototipe })
end

local kendaraan = { roda = 4, bunyi = function() return "brum" end }
local motor = turunkan(kendaraan, { roda = 2 })
print(motor.roda, motor.bunyi())     --> 2   brum
```

### 8.8 Metamethods Lengkap

| Metamethod | Dipicu oleh | Catatan |
|---|---|---|
| `__index` | Membaca key yang tidak ada | table atau function |
| `__newindex` | Menulis key yang tidak ada | table atau function |
| `__call` | `obj(args)` | Membuat table "callable" |
| `__tostring` | `tostring(obj)`, `print(obj)` | Harus mengembalikan string |
| `__len` | `#obj` | |
| `__pairs` | `pairs(obj)` | Bisa meng-override iterasi |
| `__add` `__sub` `__mul` `__div` | `+` `-` `*` `/` | |
| `__mod` `__pow` `__unm` `__idiv` | `%` `^` unary `-` `//` | |
| `__band` `__bor` `__bxor` `__shl` `__shr` `__bnot` | operator bitwise | Lua 5.3+ |
| `__eq` | `==` | Hanya dipanggil bila kedua operand sama-sama table (atau userdata) |
| `__lt` | `<` | |
| `__le` | `<=` | Pada 5.4, tidak lagi diemulasi lewat `__lt` |
| `__concat` | `..` | |
| `__close` | Keluar dari scope variabel `<close>` | Lua 5.4 |
| `__gc` | Objek akan di-garbage-collect | Finalizer |
| `__mode` | Mengatur weak table | `"k"`, `"v"`, `"kv"` |
| `__metatable` | `getmetatable`/`setmetatable` | Melindungi metatable |
| `__name` | Pesan error | Nama tipe untuk userdata/table |

**Studi kasus: class `Vector` dengan operator overloading**

```lua
local Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
  return setmetatable({ x = x, y = y }, Vector)
end

Vector.__add = function(a, b) return Vector.new(a.x + b.x, a.y + b.y) end
Vector.__sub = function(a, b) return Vector.new(a.x - b.x, a.y - b.y) end

Vector.__mul = function(a, b)               -- vektor * skalar ATAU skalar * vektor
  if type(a) == "number" then return Vector.new(a * b.x, a * b.y) end
  if type(b) == "number" then return Vector.new(a.x * b, a.y * b) end
  return a.x * b.x + a.y * b.y              -- dot product
end

Vector.__unm = function(a) return Vector.new(-a.x, -a.y) end
Vector.__eq  = function(a, b) return a.x == b.x and a.y == b.y end
Vector.__lt  = function(a, b) return a:panjang() < b:panjang() end
Vector.__le  = function(a, b) return a:panjang() <= b:panjang() end
Vector.__len = function(a) return 2 end
Vector.__tostring = function(a) return ("(%g, %g)"):format(a.x, a.y) end
Vector.__concat = function(a, b) return tostring(a) .. tostring(b) end
Vector.__call = function(a, i) return i == 1 and a.x or a.y end

function Vector:panjang() return math.sqrt(self.x ^ 2 + self.y ^ 2) end

local a, b = Vector.new(1, 2), Vector.new(3, 4)
print(a + b)                  --> (4, 6)
print(b - a)                  --> (2, 2)
print(a * 3, 2 * a)           --> (3, 6)   (2, 4)
print(a * b)                  --> 11
print(-a)                     --> (-1, -2)
print(a == Vector.new(1, 2))  --> true     (berkat __eq)
print(a < b, a <= b)          --> true   true
print(#a)                     --> 2
print(a .. b)                 --> (1, 2)(3, 4)
print(a(1), a(2))             --> 1   2
```

**`__call` untuk constructor:** agar `User(...)` menggantikan `User.new(...)`.

```lua
setmetatable(Vector, { __call = function(cls, ...) return cls.new(...) end })
print(Vector(5, 6))           --> (5, 6)
```

**`__index` function: nilai default & properti terhitung (computed property)**

```lua
local Persegi = {}
Persegi.__index = function(t, key)
  if key == "luas" then return t.sisi ^ 2 end        -- properti terhitung
  return Persegi[key]                                 -- fallback ke method class
end
function Persegi.new(sisi) return setmetatable({ sisi = sisi }, Persegi) end

print(Persegi.new(4).luas)    --> 16.0
```

**`__newindex` untuk validasi & read-only:**

```lua
local function terkunci(t)
  return setmetatable({}, {
    __index = t,
    __newindex = function(_, k) error("tidak boleh mengubah '" .. tostring(k) .. "'", 2) end,
    __metatable = "dilindungi",         -- getmetatable() akan mengembalikan string ini
  })
end
```

**`__pairs`** (Lua 5.2+, dan didukung LuaJIT bila dikompilasi dengan opsi kompatibilitas 5.2; pada Neovim jangan diandalkan):

```lua
local obj = setmetatable({}, {
  __pairs = function(t)
    local i = 0
    return function() i = i + 1; if i <= 3 then return i, i * i end end, t, nil
  end,
})
for k, v in pairs(obj) do print(k, v) end    --> 1 1 / 2 4 / 3 9
```

**`__close` (Lua 5.4):** pembersihan otomatis saat variabel `<close>` keluar dari scope, bahkan ketika terjadi error.

```lua
local function sumber_daya(nama)
  return setmetatable({}, {
    __close = function() print("menutup " .. nama) end,
  })
end

do
  local r <close> = sumber_daya("koneksi")
  print("bekerja dengan koneksi")
end
--> bekerja dengan koneksi
--> menutup koneksi
```

Handle file standar (`io.open`) juga bisa dipakai dengan `<close>`.

### 8.9 Praktik

1. **Class User:** atribut, `sapa`, validasi email di constructor (`error` jika salah).
2. **Class Product:** harga, stok, `kurangi_stok(n)` yang melempar error bila stok kurang.
3. **Inheritance:** `Karyawan` → `Manajer` dengan `hitung_gaji()` yang di-override.
4. **Custom collection:** class `List` dengan `__len`, `__index` (indeks negatif dari belakang), `__tostring`, `__concat`, dan method `map`/`filter` yang mengembalikan `List`.
5. **OOP tanpa library:** tulis ulang helper `class()` sendiri, lengkap dengan `super` dan `is_a`.
6. **Operator overloading:** class `Fraction` (pecahan) dengan `+ - * /`, penyederhanaan (FPB), `__eq`, `__lt`, `__tostring`.
7. **Object system reusable:** modul `oop.lua` berisi `class`, `mixin`, dan `is_a`, lengkap dengan test.

### 8.10 Target Kelulusan Tahap 8

- [ ] Memahami hubungan table dan metatable.
- [ ] Mampu menggunakan `__index` dan `__newindex`.
- [ ] Mampu membuat abstraction OOP sendiri.
- [ ] Memahami kapan composition lebih tepat daripada inheritance.

---

# Bagian 4: Advanced Lua

## Tahap 9. Advanced Lua Programming

**Level:** Advanced · **Estimasi:** Minggu 10–11

### 9.1 Functional Programming

**Prinsip:**

- **Pure function:** hasil hanya bergantung pada argumen, tanpa efek samping.
- **Immutability:** hindari mengubah data; buat salinan baru.
- **Function composition:** menyusun function kecil menjadi pipeline.

```lua
-- Pure vs impure
local function tambah(a, b) return a + b end                -- pure
local total = 0
local function tambah_ke_total(n) total = total + n end     -- impure (mengubah state luar)

-- Komposisi
local function compose(...)
  local fs = { ... }
  return function(...)
    local hasil = table.pack(...)
    for i = #fs, 1, -1 do
      hasil = table.pack(fs[i](table.unpack(hasil, 1, hasil.n)))
    end
    return table.unpack(hasil, 1, hasil.n)
  end
end

local tambah1 = function(x) return x + 1 end
local kali2   = function(x) return x * 2 end
print(compose(kali2, tambah1)(5))       --> 12   (kali2(tambah1(5)))

-- Currying & partial application
local function curry2(f) return function(a) return function(b) return f(a, b) end end end
local tambah_curry = curry2(function(a, b) return a + b end)
print(tambah_curry(3)(4))               --> 7
```

**Map, filter, reduce generik** (versi yang menjaga `nil` dan bekerja dengan iterator ada di Tahap 4); sekarang versi **immutable** pada table:

```lua
local function pluck(t, kunci)
  local hasil = {}
  for i, v in ipairs(t) do hasil[i] = v[kunci] end
  return hasil
end

local function group_by(t, f)
  local grup = {}
  for _, v in ipairs(t) do
    local k = f(v)
    grup[k] = grup[k] or {}
    table.insert(grup[k], v)
  end
  return grup
end
```

**Lazy evaluation:** hitung nilai hanya saat dibutuhkan, mis. dengan *thunk* atau iterator.

```lua
local function lazy(f)
  local dihitung, nilai = false, nil
  return function()
    if not dihitung then nilai, dihitung = f(), true end
    return nilai
  end
end

local mahal = lazy(function() print("menghitung..."); return 42 end)
print(mahal())     --> menghitung...   42
print(mahal())     --> 42  (dari cache)
```

### 9.2 Iterators

**Cara kerja generic `for`.** Pernyataan `for v1, v2 in explist do ... end` setara dengan:

```lua
do
  local f, s, var = explist          -- tiga nilai: fungsi iterator, state tetap, nilai kontrol awal
  while true do
    local v1, v2 = f(s, var)
    if v1 == nil then break end      -- berhenti saat variabel pertama nil
    var = v1
    -- badan loop
  end
end
```

(Lua 5.4 menambahkan nilai ke-4 opsional: *closing value* yang ditutup saat loop berakhir.)

**Stateless iterator:** tidak menyimpan state sendiri; semua state dikirim lewat `s` dan `var`.

```lua
local function iter_kuadrat(maks, i)
  i = i + 1
  if i <= maks then return i, i * i end
end

local function kuadrat(maks) return iter_kuadrat, maks, 0 end

for n, k in kuadrat(4) do print(n, k) end     --> 1 1 / 2 4 / 3 9 / 4 16
```

**Stateful iterator (closure):**

```lua
local function mundur(t)
  local i = #t + 1
  return function()
    i = i - 1
    if i >= 1 then return i, t[i] end
  end
end

for i, v in mundur({ "a", "b", "c" }) do print(i, v) end   --> 3 c / 2 b / 1 a
```

**Iterator factory & composition:**

```lua
local function range(n)
  local i = 0
  return function() i = i + 1; if i <= n then return i end end
end

local function imap(iter, f)
  return function() local v = iter(); if v ~= nil then return f(v) end end
end

local function ifilter(iter, pred)
  return function()
    for v in iter do if pred(v) then return v end end
  end
end

local function take(iter, n)
  local c = 0
  return function() c = c + 1; if c <= n then return iter() end end
end

-- 5 bilangan genap pertama yang dikuadratkan
local pipeline = take(imap(ifilter(range(100), function(x) return x % 2 == 0 end),
                           function(x) return x * x end), 5)
for v in pipeline do io.write(v, " ") end     --> 4 16 36 64 100
print()
```

### 9.3 Coroutines

**Coroutine** adalah function yang dapat **dihentikan sementara (`yield`) dan dilanjutkan (`resume`)** tanpa kehilangan state. Ia adalah fondasi *cooperative multitasking* di Lua.

| Function | Fungsi |
|---|---|
| `coroutine.create(f)` | Membuat coroutine (status awal `suspended`) |
| `coroutine.resume(co, ...)` | Menjalankan/melanjutkan; mengembalikan `true, ...` atau `false, err` |
| `coroutine.yield(...)` | Menjeda coroutine dan mengirim nilai ke `resume` |
| `coroutine.status(co)` | `"suspended"`, `"running"`, `"normal"`, `"dead"` |
| `coroutine.wrap(f)` | Membuat function yang melanjutkan coroutine (error dilempar ulang) |
| `coroutine.running()` | Coroutine aktif dan boolean "apakah main thread" |
| `coroutine.isyieldable()` | Apakah boleh `yield` di titik ini |
| `coroutine.close(co)` | Menutup coroutine (Lua 5.4) |

```lua
local co = coroutine.create(function(a, b)
  print("mulai", a, b)
  local c = coroutine.yield(a + b)           -- jeda; kirim a+b keluar
  print("lanjut dengan", c)
  local d, e = coroutine.yield(c * 2)
  print("lanjut dengan", d, e)
  return "selesai"
end)

print(coroutine.resume(co, 1, 2))      --> mulai 1 2  /  true  3
print(coroutine.status(co))            --> suspended
print(coroutine.resume(co, 10))        --> lanjut dengan 10  /  true  20
print(coroutine.resume(co, "x", "y"))  --> lanjut dengan x y  /  true  selesai
print(coroutine.status(co))            --> dead
print(coroutine.resume(co))            --> false   cannot resume dead coroutine
```

Alur data: argumen `resume` menjadi **return value `yield`**; argumen `yield` menjadi **return value `resume`**.

**Generator dengan `wrap`:**

```lua
local function fibonacci()
  return coroutine.wrap(function()
    local a, b = 0, 1
    while true do
      coroutine.yield(a)
      a, b = b, a + b
    end
  end)
end

local n = 0
for f in fibonacci() do
  io.write(f, " ")
  n = n + 1
  if n == 10 then break end
end
print()      --> 0 1 1 2 3 5 8 13 21 34
```

**Producer–consumer / pipeline:**

```lua
local function produser(daftar)
  return coroutine.wrap(function()
    for _, v in ipairs(daftar) do coroutine.yield(v) end
  end)
end

local function filter_co(sumber, pred)
  return coroutine.wrap(function()
    for v in sumber do
      if pred(v) then coroutine.yield(v) end
    end
  end)
end

local function transform(sumber, f)
  return coroutine.wrap(function()
    for v in sumber do coroutine.yield(f(v)) end
  end)
end

local alur = transform(filter_co(produser({ 1, 2, 3, 4, 5, 6 }),
                                 function(x) return x % 2 == 0 end),
                       function(x) return x * 10 end)
for v in alur do print(v) end     --> 20 / 40 / 60
```

**Error di dalam coroutine:**

```lua
local co = coroutine.create(function() error("meledak") end)
print(coroutine.resume(co))        --> false   contoh.lua:1: meledak
print(coroutine.status(co))        --> dead
-- coroutine.wrap meneruskan error ke pemanggil (tidak mengembalikan false)
```

**Scheduler berbasis coroutine (cooperative multitasking):**

```lua
local Scheduler = { tugas = {}, waktu = 0 }

function Scheduler.spawn(nama, fn)
  local co = coroutine.create(fn)
  table.insert(Scheduler.tugas, { nama = nama, co = co, bangun = 0 })
end

function Scheduler.tidur(n) coroutine.yield(n) end    -- hanya dipanggil dari dalam tugas

function Scheduler.jalan()
  while #Scheduler.tugas > 0 do
    for i = #Scheduler.tugas, 1, -1 do
      local t = Scheduler.tugas[i]
      if t.bangun <= Scheduler.waktu then
        local ok, tunda = coroutine.resume(t.co)
        if not ok then
          print("tugas gagal:", t.nama, tunda)
          table.remove(Scheduler.tugas, i)
        elseif coroutine.status(t.co) == "dead" then
          table.remove(Scheduler.tugas, i)
        else
          t.bangun = Scheduler.waktu + (tunda or 1)
        end
      end
    end
    Scheduler.waktu = Scheduler.waktu + 1
  end
end

Scheduler.spawn("A", function() for i = 1, 3 do print("A", i); Scheduler.tidur(2) end end)
Scheduler.spawn("B", function() for i = 1, 3 do print("B", i); Scheduler.tidur(1) end end)
Scheduler.jalan()
```

**Coroutine vs thread OS:**

| | Coroutine Lua | Thread OS |
|---|---|---|
| Penjadwalan | **Kooperatif** (berpindah hanya saat `yield`) | Preemptif (OS yang menentukan) |
| Eksekusi paralel | ❌ Tidak (satu waktu) | ✅ Bisa di banyak core |
| Biaya | Sangat murah | Lebih mahal |
| Race condition | Tidak ada di antara yield | Mungkin terjadi |

> **Coroutine bukan parallelism otomatis.** Operasi pemblokir (mis. `io.read`, `os.execute`) menahan seluruh program. Coroutine berguna untuk mengatur **alur** (generator, state machine, async berbasis event loop), bukan untuk mempercepat kerja CPU.

### 9.4 Runtime dan Memory

**Garbage collection (GC).** Lua mengelola memori otomatis dengan GC. Algoritmanya *mark-and-sweep*; Lua 5.4 menyediakan dua mode:

- **Incremental** (default): kerja GC dipecah dalam langkah kecil di sela eksekusi program.
- **Generational** (Lua 5.4): memisahkan objek muda dan tua; sering lebih efisien untuk program yang membuat banyak objek berumur pendek.

```lua
print(collectgarbage("count"))           -- memori terpakai (KB, float)
collectgarbage("collect")                -- paksa siklus GC penuh
print(collectgarbage("count"))

collectgarbage("generational")           -- ganti ke mode generational (5.4)
collectgarbage("incremental")            -- kembali ke incremental
collectgarbage("stop")                   -- hentikan GC otomatis
collectgarbage("restart")
collectgarbage("step", 100)              -- jalankan satu langkah GC
```

Mengamati kebocoran memori secara kasar:

```lua
local function ukur(f)
  collectgarbage(); collectgarbage()
  local sebelum = collectgarbage("count")
  f()
  collectgarbage(); collectgarbage()
  return collectgarbage("count") - sebelum
end
print(ukur(function() local t = {} for i = 1, 1e5 do t[i] = {} end end))  --> mendekati 0
```

**Penyebab "kebocoran" di Lua** (objek yang tidak pernah dibebaskan karena **masih direferensikan**): cache global yang tumbuh terus, closure/callback yang tidak pernah dilepas, listener yang tidak di-unregister. Solusi: batasi cache, lepaskan referensi (`= nil`), atau gunakan weak table.

**Weak tables dan weak references.** Table dengan metatable `__mode` tidak "menahan" objek yang menjadi key/value-nya dari GC.

| `__mode` | Arti |
|---|---|
| `"k"` | Key lemah |
| `"v"` | Value lemah |
| `"kv"` | Key dan value lemah |

```lua
-- Cache dengan value lemah: entri hilang otomatis bila objek tak dipakai lagi
local cache = setmetatable({}, { __mode = "v" })

local function ambil(id)
  local obj = cache[id]
  if not obj then
    obj = { id = id, data = string.rep("x", 1000) }
    cache[id] = obj
  end
  return obj
end

local o = ambil(1)
print(cache[1] ~= nil)        --> true
o = nil
collectgarbage()
print(cache[1])               --> nil  (sudah dibersihkan)
```

```lua
-- Key lemah: menempelkan metadata pada objek tanpa menahan objek
local metadata = setmetatable({}, { __mode = "k" })
local obj = {}
metadata[obj] = { dibuat = os.time() }
obj = nil
collectgarbage()
print(next(metadata))         --> nil
```

> Hanya **objek** (table, function, thread, userdata) yang bisa dikumpulkan dari weak table. String, angka, dan boolean adalah *value*, bukan objek yang dikoleksi dari sana.

**Finalizers (`__gc`).** Dipanggil sebelum objek dibebaskan. Penting: `__gc` harus sudah ada di metatable **saat** `setmetatable` dipanggil.

```lua
local mt = { __gc = function(o) print("membersihkan", o.nama) end }
local obj = setmetatable({ nama = "resource" }, mt)
obj = nil
collectgarbage()              --> membersihkan resource
```

Jangan bergantung pada waktu pemanggilan `__gc`. Untuk pelepasan sumber daya yang deterministik, gunakan `<close>` / `__close` (Lua 5.4) atau method `close()` eksplisit.

**Stack behavior.** Setiap pemanggilan function memakai ruang pada call stack. Rekursi non-ekor yang terlalu dalam menghasilkan error `stack overflow` (batas default kira-kira satu juta slot). Tail call tidak menambah stack (Tahap 4).

```lua
local function dalam(n) return 1 + dalam(n + 1) end   -- bukan tail call
print(pcall(dalam, 1))     --> false   ...stack overflow...
```

### 9.5 Environment dan `_ENV`

Setiap nama global `x` sebenarnya adalah `_ENV.x`. `_ENV` adalah **upvalue** yang secara default menunjuk ke table global `_G`.

```lua
x = 10
print(_ENV.x, _G.x, _ENV == _G)     --> 10   10   true
```

Mengganti `_ENV` mengubah "dunia" global bagi kode di scope itu:

```lua
local function terisolasi()
  local _ENV = { print = print }      -- hanya print yang terlihat
  nilai = 5                           -- membuat field di env BARU, bukan global sebenarnya
  print(nilai)                        --> 5
  -- os.exit()                        --> error: attempt to index a nil value (global 'os')
end
terisolasi()
print(nilai)                          --> nil (global asli tidak tercemar)
```

Teknik ini juga dipakai untuk membuat **DSL** dan melindungi dari global tak sengaja:

```lua
-- Strict mode sederhana: error bila membaca/menulis global yang belum dideklarasikan
setmetatable(_G, {
  __newindex = function(_, k) error("deklarasi global tidak diizinkan: " .. k, 2) end,
  __index    = function(_, k) error("variabel tidak dikenal: " .. k, 2) end,
})
```

> Pada Lua 5.1 / LuaJIT, mekanismenya `setfenv`/`getfenv`, bukan `_ENV`. Neovim memakai LuaJIT/5.1.

### 9.6 `load`, `loadfile`, `dofile`

```lua
-- load(chunk [, chunkname [, mode [, env]]]) -> function atau nil, pesan_error
local f, err = load("return 1 + 2")
print(f())                      --> 3

local g = load("x = 10; return x * 2", "=kode-ku", "t", {})   -- env kosong
print(g())                      --> 20
print(x)                        --> nil  (x berada di env tersebut, bukan global)

local bad, pesan = load("return +")
print(bad, pesan)               --> nil   [string "return +"]:1: unexpected symbol near <eof>
```

| Function | Fungsi |
|---|---|
| `load(string_atau_function, ...)` | Mengompilasi kode dari string/function |
| `loadfile(nama, mode, env)` | Mengompilasi file tanpa menjalankannya |
| `dofile(nama)` | Mengompilasi **dan menjalankan** file |
| `loadstring(s)` | Lua 5.1 saja (digantikan `load`) |

`mode`: `"t"` (hanya teks), `"b"` (hanya bytecode), `"bt"` (keduanya). **Selalu gunakan `"t"` untuk kode yang tidak tepercaya**, karena bytecode berbahaya dapat merusak VM.

### 9.7 Sandboxing dan Batas Keamanan

**Sandbox** menjalankan kode pihak lain dengan akses terbatas lewat environment yang disaring (whitelist):

```lua
local function jalankan_aman(kode)
  local env = {
    print = print, pairs = pairs, ipairs = ipairs, type = type,
    tostring = tostring, tonumber = tonumber, select = select,
    math = { floor = math.floor, max = math.max, min = math.min, sqrt = math.sqrt },
    table = { insert = table.insert, concat = table.concat },
  }
  local fn, err = load(kode, "=sandbox", "t", env)
  if not fn then return nil, err end
  return pcall(fn)
end

print(jalankan_aman("return math.sqrt(16)"))        --> true   4.0
print(jalankan_aman("os.execute('echo bahaya')"))   --> false  ...attempt to index a nil value (global 'os')
```

**Membatasi waktu eksekusi** dengan *hook*:

```lua
local function dengan_batas(fn, instruksi)
  local co = coroutine.create(fn)
  debug.sethook(co, function() error("batas eksekusi terlampaui") end, "", instruksi)
  return coroutine.resume(co)
end

print(dengan_batas(function() while true do end end, 1e6))
--> false   ...batas eksekusi terlampaui
```

**Batas keamanan sandbox, jangan terkecoh:**

- Whitelist harus **ketat**. Jangan ekspos `debug`, `load`, `loadfile`, `dofile`, `require`, `io`, `os`, `package`, `setmetatable` ke objek bersama, atau `getmetatable` (bisa membocorkan metatable string).
- String memiliki metatable bersama (`("x"):rep(1e9)` dapat menghabiskan memori). Batasi memori secara terpisah (pantau `collectgarbage("count")` via hook atau jalankan proses terpisah dengan limit OS).
- Loop tak berujung dan konsumsi CPU hanya dibatasi lewat hook/timeout.
- Fungsi yang diekspos dengan environment penuh (mis. `print` yang dipasang ulang) bisa dimanfaatkan untuk escape bila Anda memberi function yang mengembalikan referensi ke object internal.
- Untuk **kode benar-benar tidak tepercaya**, sandbox Lua saja **tidak cukup**: gabungkan dengan isolasi tingkat OS (proses terpisah, container, `seccomp`, batas CPU/memori).

### 9.8 Praktik

1. **Custom iterator:** `chunks(t, n)` yang membagi array menjadi potongan berukuran `n`; `zip(a, b)`.
2. **Generator dengan coroutine:** bilangan prima tak hingga, dan pembaca file per baris (lazy).
3. **Event dispatcher**

```lua
local Emitter = {}
Emitter.__index = Emitter

function Emitter.new() return setmetatable({ handlers = {} }, Emitter) end

function Emitter:on(event, fn)
  local daftar = self.handlers[event] or {}
  self.handlers[event] = daftar
  daftar[#daftar + 1] = fn
  return function()                      -- mengembalikan fungsi unsubscribe
    for i, h in ipairs(daftar) do
      if h == fn then table.remove(daftar, i); break end
    end
  end
end

function Emitter:emit(event, ...)
  for _, fn in ipairs(self.handlers[event] or {}) do
    local ok, err = pcall(fn, ...)       -- isolasi error handler
    if not ok then io.stderr:write("handler error: ", tostring(err), "\n") end
  end
end

local e = Emitter.new()
local off = e:on("pesan", function(teks) print("menerima:", teks) end)
e:emit("pesan", "halo")     --> menerima: halo
off()
e:emit("pesan", "tidak terkirim")
```

4. **Plugin loader:** baca daftar nama dari konfigurasi, `pcall(require, "plugins." .. nama)`, panggil `setup()` bila ada, dan catat plugin yang gagal tanpa menghentikan program.
5. **Pipeline pemrosesan data:** baca CSV → filter → transformasi → agregasi memakai iterator atau coroutine.
6. **Sandbox:** jalankan skrip pengguna dengan whitelist, batas instruksi, dan pesan error yang ramah.
7. **Task scheduler:** kembangkan scheduler di atas dengan prioritas dan `sleep` berbasis `os.clock`.

### 9.9 Target Kelulusan Tahap 9

- [ ] Memahami cara kerja closure dan upvalues.
- [ ] Mampu membuat iterator sendiri.
- [ ] Memahami lifecycle coroutine.
- [ ] Memahami garbage collection dan weak table.
- [ ] Mampu menggunakan environment untuk membatasi akses script.

---

## Tahap 10. File System, OS, dan Standard Libraries

**Level:** Advanced · **Estimasi:** Minggu 12

### 10.1 IO Library

**Membuka file: `io.open(nama, mode)`**. Mengembalikan *file handle*, atau `nil, pesan_error, kode` jika gagal. **Selalu cek hasilnya.**

| Mode | Arti |
|---|---|
| `"r"` | Baca (default); file harus ada |
| `"w"` | Tulis; **menimpa** isi lama atau membuat baru |
| `"a"` | Tambah di akhir (append) |
| `"r+"` | Baca + tulis; file harus ada |
| `"w+"` | Baca + tulis; menimpa |
| `"a+"` | Baca + append |
| tambahkan `"b"` | Mode biner (penting di Windows), mis. `"rb"`, `"wb"` |

```lua
-- Menulis
local f, err = io.open("catatan.txt", "w")
if not f then error("gagal membuka: " .. err) end
f:write("Baris 1\n", "Baris 2\n", 42, "\n")      -- write menerima string dan angka
f:close()

-- Membaca seluruh isi
local f2 = assert(io.open("catatan.txt", "r"))
local isi = f2:read("a")                          -- "a" = all
f2:close()
print(isi)
```

**Format `read`:**

| Format | Arti |
|---|---|
| `"l"` | Satu baris (tanpa newline) — default |
| `"L"` | Satu baris (dengan newline) |
| `"n"` | Satu angka |
| `"a"` | Seluruh sisa file |
| `5` (angka) | Sebanyak 5 byte |

> Lua 5.1/LuaJIT menulis format dengan tanda bintang: `"*l"`, `"*a"`, `"*n"`. Lua 5.4 menerima kedua gaya.

**Membaca per baris (sequential access):**

```lua
for baris in io.lines("catatan.txt") do        -- membuka & menutup file otomatis
  print(baris)
end

-- atau dengan handle
local f = assert(io.open("catatan.txt"))
for baris in f:lines() do print(baris) end
f:close()
```

**Pola aman dengan `<close>` (Lua 5.4):** file ditutup otomatis walau terjadi error.

```lua
local function baca_semua(path)
  local f <close> = assert(io.open(path, "rb"))
  return f:read("a")
end
```

**File biner:**

```lua
local f = assert(io.open("gambar.png", "rb"))
local header = f:read(8)                       -- 8 byte pertama
print(header:byte(1, -1))                      -- 137 80 78 71 13 10 26 10
f:close()
```

`f:seek(whence, offset)` memindahkan posisi baca/tulis: `"set"` (dari awal), `"cur"` (dari posisi sekarang), `"end"` (dari akhir).

```lua
local f = assert(io.open("catatan.txt"))
local ukuran = f:seek("end")        -- ukuran file dalam byte
f:seek("set", 0)                    -- kembali ke awal
f:close()
```

**Standard input/output/error:**

```lua
io.stdout:write("ke stdout\n")
io.stderr:write("ke stderr\n")           -- pesan error/log sebaiknya ke stderr
local nama = io.read("l")                -- dari stdin
```

**Buffering:**

```lua
io.stdout:setvbuf("no")       -- tanpa buffer: keluaran langsung tampil
f:setvbuf("full", 8192)       -- buffer penuh 8 KB
f:flush()                     -- paksa tulis buffer ke disk
```

### 10.2 OS Library

```lua
print(os.time())                         -- epoch detik, mis. 1793000000
print(os.date("%Y-%m-%d %H:%M:%S"))      -- tanggal/jam lokal terformat
print(os.date("!%Y-%m-%dT%H:%M:%SZ"))    -- tanda "!" = UTC

local t = os.date("*t")                  -- table: year, month, day, hour, min, sec, wday, yday, isdst
print(t.year, t.month, t.day)

local besok = os.time({ year = 2026, month = 10, day = 31 + 1, hour = 12 })   -- normalisasi otomatis
print(os.date("%A, %d %B %Y", besok))
print(os.difftime(besok, os.time()))     -- selisih detik (float)

print(os.getenv("HOME") or os.getenv("USERPROFILE"))   -- nil bila tidak ada

local mulai = os.clock()                 -- waktu CPU (detik, untuk benchmark)
for i = 1, 1e7 do end
print(("%.3f detik"):format(os.clock() - mulai))

os.rename("lama.txt", "baru.txt")        -- mengembalikan true atau nil, err
os.remove("baru.txt")
local sementara = os.tmpname()           -- nama file sementara (hati-hati: race condition di Unix)
os.exit(0)                               -- keluar; os.exit(true, true) menutup state & memanggil finalizer
```

**`os.execute(perintah)`** menjalankan perintah shell dan mengembalikan `true|nil, "exit"|"signal", kode`:

```lua
local ok, jenis, kode = os.execute("ls -l")
print(ok, jenis, kode)                   --> true   exit   0
```

**`io.popen(perintah, mode)`** menangkap keluaran proses:

```lua
local p = io.popen("date +%Y", "r")
local tahun = p:read("l")
p:close()
```

> **Keamanan:** jangan pernah menyusun perintah shell dari input pengguna tanpa sanitasi (*command injection*). Contoh berbahaya: `os.execute("rm " .. input_user)`. Validasi dengan whitelist atau hindari shell sama sekali.

**Portabilitas & keterbatasan:**

- Standard library **tidak menyediakan** fungsi daftar direktori, `mkdir`, atau `stat`. Gunakan library **LuaFileSystem** (`luarocks install luafilesystem`, `require("lfs")`) atau perintah shell (kurang portabel).
- Pemisah path berbeda (`/` vs `\`); `os.execute` bergantung pada shell OS.
- Kode keluar (exit code) dan format `os.date` dapat bervariasi antar platform.

```lua
local sep = package.config:sub(1, 1)       -- "/" di Unix, "\" di Windows
local function gabung(...) return table.concat({ ... }, sep) end
```

### 10.3 Standard Libraries

| Library | Isi utama | Catatan |
|---|---|---|
| `_G` / basic | `print`, `type`, `pairs`, `pcall`, `select`, `load`, `require`, `setmetatable`, ... | Selalu tersedia |
| `string` | Manipulasi teks, pattern, `format`, `pack`/`unpack` (5.3+) | Tahap 5 |
| `table` | `insert`, `remove`, `concat`, `sort`, `move`, `pack`, `unpack` | Tahap 6 |
| `math` | `floor`, `ceil`, `abs`, `max`, `min`, `sqrt`, `random`, `pi`, `huge`, `tointeger`, `type`, `fmod` | Lihat contoh di bawah |
| `coroutine` | `create`, `resume`, `yield`, `wrap`, ... | Tahap 9 |
| `io` | File & stdin/stdout | Tahap ini |
| `os` | Waktu, lingkungan, proses | Tahap ini |
| `utf8` | `char`, `codepoint`, `len`, `offset`, `codes`, `charpattern` | Lua 5.3+ |
| `debug` | `traceback`, `getinfo`, `sethook`, ... | Hati-hati, alat tingkat rendah |

```lua
print(math.floor(3.7), math.ceil(3.2), math.abs(-5))     --> 3   4   5
print(math.max(3, 9, 2), math.min(3, 9, 2))              --> 9   2
print(math.sqrt(16), math.pi)                            --> 4.0   3.1415926535898
print(math.huge, -math.huge)                             --> inf   -inf
print(math.tointeger(3.0), math.tointeger(3.5))          --> 3   nil
print(math.fmod(-7, 3), -7 % 3)                          --> -1   2  (beda perilaku untuk angka negatif)
print(math.random(), math.random(10), math.random(5, 8)) -- [0,1), [1,10], [5,8]
```

**Keterbatasan standard library** dan kapan butuh library eksternal:

| Kebutuhan | Library populer |
|---|---|
| Direktori, atribut file | LuaFileSystem (`lfs`) |
| JSON | `dkjson`, `lua-cjson`, `rapidjson` |
| HTTP / jaringan | `luasocket`, `lua-http` |
| Regex penuh / parser | `lpeg`, `lrexlib` |
| Date/time lanjutan | `luatz`, `date` |
| Utility umum & fungsional | `penlight`, `luafun` |
| Pencetakan struktur data | `inspect.lua` |

### 10.4 Praktik

**1. File manager sederhana:** menu `lihat`, `salin`, `ganti nama`, `hapus` (gunakan `io` dan `os.rename`/`os.remove`; tambahkan konfirmasi sebelum hapus).

**2. Log reader**

```lua
local function ringkas_log(path)
  local hitung = { INFO = 0, WARN = 0, ERROR = 0 }
  for baris in io.lines(path) do
    local level = baris:match("%[(%u+)%]")
    if level and hitung[level] then hitung[level] = hitung[level] + 1 end
  end
  return hitung
end

for level, n in pairs(ringkas_log("app.log")) do print(level, n) end
```

**3. Environment variable reader:** tampilkan variabel dari daftar (`PATH`, `HOME`, `USER`) dan beri tanda yang tidak diatur.

**4. CLI automation:** skrip yang menjalankan beberapa perintah (`git status`, dll.) memakai `io.popen`, menangkap keluarannya, dan menulis laporan.

**5. Backup utility**

```lua
local function salin(sumber, tujuan)
  local ins <close>  = assert(io.open(sumber, "rb"))
  local outs <close> = assert(io.open(tujuan, "wb"))
  while true do
    local blok = ins:read(2 ^ 13)       -- 8 KB per blok
    if not blok then break end
    outs:write(blok)
  end
end

local stempel = os.date("%Y%m%d-%H%M%S")
salin("data.db", ("data-%s.bak"):format(stempel))
```

**6. Pemroses CSV sederhana**

```lua
local function parse_baris(baris)
  local kolom = {}
  for sel in (baris .. ","):gmatch("([^,]*),") do kolom[#kolom + 1] = sel end
  return kolom
end

local header
local data = {}
for baris in io.lines("nilai.csv") do
  local k = parse_baris(baris)
  if not header then header = k
  else
    local rec = {}
    for i, nama in ipairs(header) do rec[nama] = k[i] end
    data[#data + 1] = rec
  end
end
```

> CSV asli bisa memuat kutip dan koma di dalam sel. Untuk data nyata gunakan library parser CSV.

### 10.5 Target Kelulusan Tahap 10

- [ ] Mampu membaca dan menulis file.
- [ ] Mampu menjalankan perintah sistem dengan pertimbangan keamanan.
- [ ] Memahami fasilitas standard library Lua.

---

# Bagian 5: Ekosistem dan Professional Development

## Tahap 11. Lua Ecosystem dan Software Engineering

**Level:** Advanced – Expert · **Estimasi:** Minggu 13–14

### 11.1 LuaRocks dan Package Management

**LuaRocks** adalah package manager untuk Lua (setara `pip`/`npm`). Paket Lua disebut **rock**, dan didefinisikan oleh file **rockspec**.

**Instalasi:** lewat package manager OS (`sudo apt install luarocks`, `brew install luarocks`) atau dari [luarocks.org](https://luarocks.org). Pastikan LuaRocks terhubung dengan versi Lua yang benar:

```bash
luarocks --version
luarocks config lua_version
luarocks --lua-version 5.4 install inspect    # target versi tertentu
```

**Perintah dasar:**

```bash
luarocks search busted              # cari
luarocks install busted             # pasang (global/sistem)
luarocks install --local busted     # pasang untuk pengguna saat ini saja
luarocks list                       # daftar terpasang
luarocks show busted                # info paket
luarocks remove busted              # hapus
luarocks path                       # tampilkan LUA_PATH/LUA_CPATH yang sesuai
```

Agar `require` menemukan paket yang dipasang secara lokal, set variabel lingkungan:

```bash
eval "$(luarocks path --bin)"
```

**Dependency per proyek (tree lokal):**

```bash
luarocks --tree ./lua_modules install inspect
# lalu: eval "$(luarocks --tree ./lua_modules path)"
```

**Membuat rockspec:**

```lua
-- tugas-0.1.0-1.rockspec
rockspec_format = "3.0"
package = "tugas"
version = "0.1.0-1"           -- <versi-paket>-<revisi-rockspec>

source = {
  url = "git+https://github.com/username/tugas.git",
  tag = "v0.1.0",
}

description = {
  summary = "Library manajemen tugas sederhana",
  detailed = "Menyediakan model tugas, penyimpanan, dan API CLI.",
  homepage = "https://github.com/username/tugas",
  license = "MIT",
}

dependencies = {
  "lua >= 5.1, < 5.5",
  "inspect >= 3.1",
}

test_dependencies = { "busted" }

build = {
  type = "builtin",
  modules = {
    ["tugas"]         = "src/tugas/init.lua",
    ["tugas.model"]   = "src/tugas/model.lua",
    ["tugas.storage"] = "src/tugas/storage.lua",
  },
}
```

**Siklus kerja:**

```bash
luarocks make tugas-0.1.0-1.rockspec     # build & pasang dari direktori lokal
luarocks test                            # jalankan test (butuh test_dependencies)
luarocks pack tugas                      # buat arsip .src.rock / .rock
luarocks upload tugas-0.1.0-1.rockspec --api-key=KUNCI_API_ANDA   # publikasikan ke luarocks.org
```

> Opsi dan sintaks `luarocks` bisa berubah antar versi. Cek `luarocks help <perintah>` serta dokumentasi di luarocks.org.

**Versioning:** gunakan **Semantic Versioning** (`MAJOR.MINOR.PATCH`): naikkan MAJOR bila ada perubahan API yang tidak kompatibel, MINOR untuk fitur baru kompatibel, PATCH untuk perbaikan bug. Bagian `-1` pada versi rockspec adalah revisi rockspec.

**Memilih library pihak ketiga:** periksa aktivitas pemeliharaan, versi Lua yang didukung, lisensi, jumlah dependency, serta apakah berupa pure Lua atau perlu kompilasi C.

### 11.2 Testing dan Quality

**Jenis test:**

| Jenis | Yang diuji |
|---|---|
| **Unit** | Satu function/module secara terisolasi |
| **Integration** | Beberapa module bekerja bersama (mis. service + storage ke file) |
| **End-to-end** | Aplikasi dari input sampai output |

**Busted** adalah framework testing paling umum untuk Lua.

```bash
luarocks install busted
busted                       # jalankan semua test di folder spec/
busted --verbose spec/model_spec.lua
```

```lua
-- spec/model_spec.lua
local Model = require("tugas.model")

describe("Tugas", function()
  local t

  before_each(function()
    t = Model.baru("Belajar Lua")
  end)

  it("dibuat dengan status belum selesai", function()
    assert.is_false(t.selesai)
    assert.are.equal("Belajar Lua", t.judul)
  end)

  it("dapat ditandai selesai", function()
    t:selesaikan()
    assert.is_true(t.selesai)
  end)

  it("menolak judul kosong", function()
    assert.has_error(function() Model.baru("") end)
  end)

  describe("serialisasi", function()
    it("menghasilkan table yang sama", function()
      assert.are.same({ judul = "Belajar Lua", selesai = false }, t:ke_table())
    end)
  end)
end)
```

Assertion umum: `assert.are.equal(a, b)` (identitas `==`), `assert.are.same(a, b)` (perbandingan dalam/isi), `assert.is_nil`, `assert.is_true`, `assert.truthy`, `assert.has_error(fn, pesan?)`, `assert.matches(pattern, str)`.

**Test-Driven Development (TDD):** siklus **Red → Green → Refactor**: tulis test yang gagal, buat kode paling sederhana agar lulus, lalu rapikan tanpa merusak test.

**Mocking dan stubbing:** ganti dependensi nyata agar test deterministik dan cepat.

```lua
describe("pembuat laporan", function()
  it("memakai waktu yang di-stub", function()
    local asli = os.time
    os.time = function() return 1000000000 end     -- stub manual
    assert.are.equal(1000000000, os.time())
    os.time = asli                                 -- WAJIB dipulihkan
  end)

  it("memanggil logger", function()
    local logger = { info = function() end }
    spy.on(logger, "info")                         -- Busted: spy
    logger.info("halo")
    assert.spy(logger.info).was.called_with("halo")
  end)
end)
```

> Rancang kode dengan **dependency injection** (kirim `storage`, `waktu`, `logger` sebagai argumen) agar mudah diuji tanpa tambal-sulam global.

**Test coverage:** pasang **LuaCov** (`luarocks install luacov`), jalankan `busted --coverage`, lalu `luacov` untuk laporan. Coverage menunjukkan baris yang belum diuji, bukan jaminan kualitas test.

**Static analysis & linting:**

```bash
luarocks install luacheck
luacheck src/ spec/          # deteksi variabel global tak sengaja, variabel tak terpakai, dll.
```

```lua
-- .luacheckrc
std = "lua54"                -- atau "luajit", "lua51"
globals = {}                 -- global yang diizinkan
ignore = { "212" }           -- abaikan peringatan "unused argument"
```

**Formatting:** **StyLua** (`stylua .`) memformat kode secara konsisten; konfigurasi di `stylua.toml`. Tambahkan **lua-language-server (LuaLS)** di editor untuk diagnostik, autocompletion, dan anotasi tipe.

**Dokumentasi kode:** komentar bergaya LuaLS/EmmyLua memberi anotasi tipe sekaligus dokumentasi:

```lua
---Menjumlahkan seluruh elemen array angka.
---@param daftar number[] Daftar angka
---@return number total Jumlah seluruh angka
local function jumlah(daftar)
  local total = 0
  for _, v in ipairs(daftar) do total = total + v end
  return total
end
```

Untuk dokumentasi API yang dibangkitkan otomatis, pakai **LDoc**. Selalu sertakan `README.md` berisi instalasi, contoh pemakaian, dan lisensi.

**Coding conventions:** `snake_case` untuk variabel/function, `PascalCase` untuk class, `UPPER_SNAKE` untuk konstanta, indentasi 2 atau 4 spasi (konsisten), selalu `local`, satu module satu tanggung jawab, kembalikan `nil, err` untuk kegagalan yang diperkirakan.

### 11.3 Performance

**Prinsip: ukur dulu, optimasi kemudian.** Jangan menebak bottleneck.

**Benchmarking sederhana:**

```lua
local function benchmark(nama, fn, ulangi)
  collectgarbage(); collectgarbage()
  local mulai = os.clock()
  for _ = 1, ulangi do fn() end
  local selesai = os.clock() - mulai
  print(("%-28s %.3f detik"):format(nama, selesai))
end

benchmark("konkatenasi s = s .. x", function()
  local s = ""
  for i = 1, 5000 do s = s .. "x" end
end, 200)

benchmark("table.concat", function()
  local t = {}
  for i = 1, 5000 do t[#t + 1] = "x" end
  local s = table.concat(t)
end, 200)
```

**Profiling:** cari function yang paling banyak memakan waktu. Pilihan: profiler berbasis `debug.sethook` (mis. *ProFi*, *LuaProfiler*), profiler bawaan LuaJIT, atau profiler editor/IDE. Untuk memori: pantau `collectgarbage("count")` sebelum/sesudah operasi dan cari referensi yang tertahan.

**Teknik optimasi yang umum efektif:**

| Teknik | Penjelasan |
|---|---|
| Pakai `local` | Akses variabel lokal (register) jauh lebih cepat dari global |
| Cache function dari library | `local insert = table.insert`, `local floor = math.floor` di awal file |
| Hindari konkatenasi string di loop | Kumpulkan ke table, lalu `table.concat` |
| Preallocate / hindari table baru di loop panas | Gunakan ulang table, kurangi tekanan GC |
| Hindari `table.insert(t, 1, x)` / `table.remove(t, 1)` pada array besar | O(n); pakai queue dua indeks |
| Pilih `t[#t + 1] = v` untuk append | Lebih ringan daripada `table.insert` pada kasus panas |
| Pakai `ipairs`/numeric `for` untuk array | Lebih ringan dari `pairs` |
| Tuning GC | `collectgarbage("generational")` atau parameter incremental untuk beban tertentu |
| Algoritma & struktur data | Biasanya pengaruh terbesar |

```lua
local insert, floor = table.insert, math.floor      -- cache di scope file

-- Preallocation (Lua 5.4 tidak punya API langsung; di LuaJIT: table.new)
```

> **Optimasi berdasarkan pengukuran.** Optimasi prematur membuat kode sulit dibaca tanpa manfaat. Jalankan benchmark sebelum dan sesudah perubahan, dan pastikan hasil tetap benar lewat test.

### 11.4 Versi dan Implementasi Lua

| Versi | Tahun | Perubahan penting |
|---|---|---|
| **5.1** | 2006 | Baseline luas; basis LuaJIT; `setfenv/getfenv`, `unpack`, `module()`, `loadstring` |
| **5.2** | 2011 | `_ENV` (menggantikan `setfenv`), `goto`, `bit32`, `table.pack/unpack`, `load` dengan env, `__gc` pada table |
| **5.3** | 2015 | Subtipe **integer** vs float, operator `//` dan bitwise native, library `utf8`, `table.move`, `string.pack/unpack` |
| **5.4** | 2020 | Atribut `<const>` dan `<close>`, GC **generational**, `coroutine.close`, `warn()`, perubahan semantik loop integer |

Perubahan yang sering menimbulkan masalah kompatibilitas:

```lua
-- 5.1:   unpack(t)          5.2+:  table.unpack(t)
-- 5.1:   loadstring(s)      5.2+:  load(s)
-- 5.1:   setfenv(f, env)    5.2+:  _ENV / load(..., env)
-- 5.1:   math.pow(a, b)     5.3+:  a ^ b     (math.pow dihapus/deprecated)
-- 5.3+:  a // b, a & b      5.1 : tidak ada
-- 5.3+:  1 / 2 = 0.5, 3 // 2 = 1, 3.0 // 2 = 1.0   (integer vs float lebih ketat)
-- 5.4:   __lt tidak lagi mengemulasi __le
```

**Menulis kode lintas versi** (kompatibilitas 5.1–5.4):

```lua
local unpack = table.unpack or unpack
local load_str = loadstring or load

local function setfenv_compat(f, env)
  if setfenv then return setfenv(f, env) end
  -- 5.2+: pakai load(..., env) saat membuat function
end
```

**LuaJIT** adalah implementasi terpisah dengan **Just-In-Time compiler**, sangat cepat, dan menyertakan **FFI** (memanggil function C langsung dari Lua tanpa menulis kode C). LuaJIT kompatibel dengan **Lua 5.1** serta menambahkan beberapa fitur dari 5.2 dan ekstensi sendiri (`bit`, `ffi`, `jit`).

| | PUC-Rio Lua 5.4 | LuaJIT |
|---|---|---|
| Kompatibilitas bahasa | 5.4 | 5.1 (+ ekstensi) |
| Kecepatan | Interpreter | JIT, umumnya jauh lebih cepat |
| Integer 64-bit native | Ya | Tidak (semua number = double) |
| Operator `//`, bitwise | Ya | Tidak (pakai library `bit`) |
| FFI | Tidak (butuh C API) | Ya |
| Dipakai oleh | Redis, banyak embedded | OpenResty, **Neovim** |

> Selalu tulis dan uji kode pada **versi Lua yang menjadi target**. Library yang Anda publikasikan sebaiknya mendeklarasikan versi yang didukung di rockspec, dan di-test pada beberapa versi (CI dengan matriks 5.1, 5.3, 5.4, LuaJIT).

### 11.5 Praktik

1. **Buat package Lua sendiri:** mis. `strutil` berisi `split`, `trim`, `startswith`, `endswith`, `pad`.
2. **Tulis unit test** dengan Busted (minimal 15 test, termasuk kasus tepi: string kosong, `nil`, karakter khusus).
3. **Dokumentasi API:** anotasi LuaLS atau LDoc, plus `README.md` dengan contoh.
4. **Benchmark** beberapa implementasi `split` (gmatch vs find berulang vs loop `byte`).
5. **Publikasikan** ke LuaRocks (mulai dari `luarocks pack`/`make` lokal sebelum `upload`).
6. **Aplikasi dengan dependency management:** gunakan `luarocks --tree ./lua_modules` dan skrip `Makefile`/`run.sh` yang menyiapkan path.

### 11.6 Target Kelulusan Tahap 11

- [ ] Mampu membuat dan mengelola package.
- [ ] Mampu menulis automated test.
- [ ] Mampu mengukur dan memperbaiki performa.
- [ ] Memahami perbedaan implementasi dan versi Lua.

---

## Tahap 12. Lua C API dan Embedding Lua

**Level:** Expert · **Estimasi:** Minggu 15–16

### 12.1 Konsep Embedded Scripting

Lua dirancang sebagai **library C**. Aplikasi *host* (C/C++) menanamkan interpreter Lua untuk:

- **Konfigurasi dan logika yang dapat diubah tanpa kompilasi ulang** (game: perilaku musuh, level, UI).
- **Ekstensi/plugin** oleh pengguna.
- **Otomatisasi** dalam aplikasi besar.

Dua arah komunikasi:

1. **Embedding:** program C menjalankan kode Lua dan memanggil function Lua.
2. **Extending:** Lua memanggil function yang ditulis di C (membentuk *C module*).

**Arsitektur singkat:** interpreter Lua memuat kode, mengompilasinya menjadi **bytecode**, lalu dijalankan oleh **Lua virtual machine** (VM berbasis register). Seluruh status program (global, stack, GC) terkandung dalam satu struktur **`lua_State`**, sehingga Lua *reentrant* dan mudah ditanam di banyak instance.

### 12.2 Lua State dan Program Pertama

Header yang dibutuhkan:

```c
#include <lua.h>      /* API inti (lua_*)         */
#include <lauxlib.h>  /* fungsi bantu (luaL_*)    */
#include <lualib.h>   /* pembuka standard library */
```

```c
/* host.c */
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main(void) {
    lua_State *L = luaL_newstate();   /* buat state baru */
    if (L == NULL) {
        fprintf(stderr, "gagal membuat Lua state\n");
        return 1;
    }
    luaL_openlibs(L);                 /* muat standard library */

    if (luaL_dofile(L, "skrip.lua") != LUA_OK) {
        fprintf(stderr, "Error: %s\n", lua_tostring(L, -1));
        lua_pop(L, 1);                /* buang pesan error dari stack */
    }

    lua_close(L);                     /* bebaskan semua sumber daya */
    return 0;
}
```

```lua
-- skrip.lua
print("Halo dari Lua yang dijalankan oleh program C!")
```

**Kompilasi** (nama paket/flag bergantung distro):

```bash
# Linux (Debian/Ubuntu): sudo apt install liblua5.4-dev pkg-config
gcc host.c -o host $(pkg-config --cflags --libs lua5.4)
# atau manual:
gcc host.c -o host -I/usr/include/lua5.4 -llua5.4 -lm -ldl
./host
```

### 12.3 Lua Stack: Konsep Kunci C API

Lua dan C **tidak bertukar nilai langsung**. Semuanya lewat **stack virtual** yang dikelola Lua. C mendorong (*push*) nilai ke stack, lalu memanggil API untuk mengambilnya.

**Indeks stack:**

| Indeks | Arti |
|---|---|
| `1`, `2`, `3`, ... | Dari **dasar** stack (elemen pertama = 1) |
| `-1`, `-2`, ... | Dari **puncak** stack (`-1` = elemen teratas) |
| `lua_upvalueindex(i)` | Upvalue function C |
| `LUA_REGISTRYINDEX` | Registry (tabel rahasia C) |

```text
 stack (puncak di atas)
   ┌───────────┐
   │ "halo"    │   indeks 3  (juga -1)
   ├───────────┤
   │ 42        │   indeks 2  (juga -2)
   ├───────────┤
   │ true      │   indeks 1  (juga -3)
   └───────────┘
```

**Push (C → stack):**

```c
lua_pushnil(L);
lua_pushboolean(L, 1);
lua_pushinteger(L, 42);
lua_pushnumber(L, 3.14);
lua_pushstring(L, "halo");          /* menyalin string, null-terminated */
lua_pushlstring(L, buf, panjang);   /* dengan panjang eksplisit */
lua_newtable(L);                    /* table kosong */
lua_pushcfunction(L, fungsi_c);     /* function C */
```

**Baca (stack → C):**

```c
int         b = lua_toboolean(L, idx);
lua_Integer i = lua_tointeger(L, idx);
lua_Number  n = lua_tonumber(L, idx);
const char *s = lua_tostring(L, idx);        /* string sah selama masih di stack */
size_t len;   s = lua_tolstring(L, idx, &len);
int tipe = lua_type(L, idx);                 /* LUA_TNIL, LUA_TNUMBER, LUA_TSTRING, LUA_TTABLE, ... */
int adalah_angka = lua_isnumber(L, idx);
```

**Manipulasi stack:**

```c
int jumlah = lua_gettop(L);   /* jumlah elemen di stack */
lua_settop(L, 0);             /* kosongkan stack */
lua_pop(L, n);                /* buang n elemen teratas */
lua_pushvalue(L, idx);        /* salin elemen idx ke puncak */
lua_remove(L, idx);
lua_insert(L, idx);
```

**Aturan penting:** pastikan ada ruang stack (`lua_checkstack`) bila banyak push; **jaga keseimbangan stack** (setiap push harus punya pop); string dari `lua_tostring` hanya valid selama nilainya masih ada di stack.

### 12.4 Mengakses Variabel dan Memanggil Function Lua dari C

**Membaca/menulis global:**

```c
lua_pushinteger(L, 100);
lua_setglobal(L, "batas");          /* batas = 100 di Lua */

lua_getglobal(L, "nama_app");       /* push nilai global ke stack */
const char *nama = lua_tostring(L, -1);
lua_pop(L, 1);
```

**Membaca field table (mis. konfigurasi):**

```c
/* skrip konfigurasi:  config = { lebar = 800, tinggi = 600 } */
lua_getglobal(L, "config");
lua_getfield(L, -1, "lebar");       /* push config.lebar */
int lebar = (int)lua_tointeger(L, -1);
lua_pop(L, 2);                      /* buang lebar dan config */
```

**Memanggil function Lua dari C**

```lua
-- skrip.lua
function tambah(a, b)
  return a + b, a * b
end
```

```c
luaL_dofile(L, "skrip.lua");

lua_getglobal(L, "tambah");   /* 1. push function            */
lua_pushnumber(L, 3);         /* 2. push argumen             */
lua_pushnumber(L, 4);

/* 3. panggil: 2 argumen, 2 hasil, handler error = 0 (tanpa) */
if (lua_pcall(L, 2, 2, 0) != LUA_OK) {
    fprintf(stderr, "error: %s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
} else {
    double jumlah = lua_tonumber(L, -2);   /* hasil pertama  */
    double kali   = lua_tonumber(L, -1);   /* hasil kedua    */
    printf("jumlah=%g kali=%g\n", jumlah, kali);   /* jumlah=7 kali=12 */
    lua_pop(L, 2);
}
```

Gunakan **`lua_pcall`** (protected) di host agar error Lua tidak membuat program C crash. `lua_call` (tanpa proteksi) hanya aman bila Anda sudah berada dalam konteks yang terlindungi.

### 12.5 Memanggil Function C dari Lua

Sebuah function C yang dapat dipanggil Lua memiliki signature tetap: menerima `lua_State *` dan mengembalikan **jumlah nilai yang di-push sebagai hasil**.

```c
#include <math.h>

/* panggilan Lua: hasil = hipotenusa(3, 4) */
static int l_hipotenusa(lua_State *L) {
    lua_Number a = luaL_checknumber(L, 1);   /* argumen 1 (error otomatis bila bukan angka) */
    lua_Number b = luaL_checknumber(L, 2);
    lua_pushnumber(L, sqrt(a * a + b * b));  /* push hasil */
    return 1;                                /* jumlah hasil */
}

/* di main(): daftarkan sebagai global */
lua_pushcfunction(L, l_hipotenusa);
lua_setglobal(L, "hipotenusa");
/* atau pintas: lua_register(L, "hipotenusa", l_hipotenusa); */
```

```lua
print(hipotenusa(3, 4))        --> 5.0
print(hipotenusa("x", 4))      --> error: bad argument #1 to 'hipotenusa' (number expected, got string)
```

Fungsi `luaL_check*` dan `luaL_opt*` memvalidasi argumen: `luaL_checkinteger`, `luaL_checkstring`, `luaL_checktype`, `luaL_optinteger(L, idx, default)`, `luaL_argcheck`.

**Mengembalikan banyak nilai dan error:**

```c
static int l_bagi(lua_State *L) {
    lua_Number a = luaL_checknumber(L, 1);
    lua_Number b = luaL_checknumber(L, 2);
    if (b == 0) {
        lua_pushnil(L);
        lua_pushstring(L, "pembagian dengan nol");
        return 2;                          /* nil, "pesan"  (idiom Lua) */
        /* atau lempar error: return luaL_error(L, "pembagian dengan nol"); */
    }
    lua_pushnumber(L, a / b);
    return 1;
}
```

### 12.6 Membuat C Module

Module C dikompilasi menjadi *shared library* yang dapat di-`require`.

```c
/* mymath.c */
#include <lua.h>
#include <lauxlib.h>

static int l_kuadrat(lua_State *L) {
    lua_Number x = luaL_checknumber(L, 1);
    lua_pushnumber(L, x * x);
    return 1;
}

static int l_jumlah(lua_State *L) {
    int n = lua_gettop(L);                /* jumlah argumen */
    lua_Number total = 0;
    for (int i = 1; i <= n; i++) total += luaL_checknumber(L, i);
    lua_pushnumber(L, total);
    return 1;
}

static const luaL_Reg fungsi[] = {
    {"kuadrat", l_kuadrat},
    {"jumlah",  l_jumlah},
    {NULL, NULL}                          /* penanda akhir */
};

/* nama harus luaopen_<nama module> */
int luaopen_mymath(lua_State *L) {
    luaL_newlib(L, fungsi);               /* buat table berisi fungsi di atas */
    return 1;                             /* kembalikan table sebagai hasil require */
}
```

```bash
# Linux
gcc -shared -fPIC -o mymath.so mymath.c $(pkg-config --cflags lua5.4)
# macOS:  gcc -shared -undefined dynamic_lookup -o mymath.so mymath.c -I/path/ke/lua/include
```

```lua
-- main.lua   (mymath.so ada di package.cpath, mis. direktori kerja)
package.cpath = "./?.so;" .. package.cpath
local m = require("mymath")
print(m.kuadrat(9), m.jumlah(1, 2, 3))     --> 81.0   6.0
```

Untuk distribusi, rockspec memakai `build = { type = "builtin", modules = { mymath = "mymath.c" } }`.

### 12.7 Userdata dan Metatable untuk Userdata

**Userdata** adalah blok memori C yang dikelola GC Lua; cocok merepresentasikan *struct* C sebagai objek Lua.

```c
/* counter.c */
#include <lua.h>
#include <lauxlib.h>

typedef struct { long nilai; } Counter;

#define NAMA_METATABLE "contoh.Counter"

static int c_baru(lua_State *L) {
    long awal = (long)luaL_optinteger(L, 1, 0);
    Counter *c = (Counter *)lua_newuserdatauv(L, sizeof(Counter), 0);  /* 5.4; 5.1-5.3: lua_newuserdata */
    c->nilai = awal;
    luaL_setmetatable(L, NAMA_METATABLE);       /* pasang metatable */
    return 1;
}

static Counter *cek_counter(lua_State *L, int idx) {
    return (Counter *)luaL_checkudata(L, idx, NAMA_METATABLE);   /* validasi tipe */
}

static int c_naik(lua_State *L) {
    Counter *c = cek_counter(L, 1);
    c->nilai++;
    lua_pushinteger(L, c->nilai);
    return 1;
}

static int c_tostring(lua_State *L) {
    Counter *c = cek_counter(L, 1);
    lua_pushfstring(L, "Counter(%d)", (int)c->nilai);
    return 1;
}

static const luaL_Reg metode[] = {
    {"naik", c_naik},
    {"__tostring", c_tostring},
    {NULL, NULL}
};

int luaopen_counter(lua_State *L) {
    luaL_newmetatable(L, NAMA_METATABLE);   /* buat & daftarkan metatable di registry */
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");         /* metatable.__index = metatable */
    luaL_setfuncs(L, metode, 0);            /* isi method */
    lua_pop(L, 1);

    lua_newtable(L);
    lua_pushcfunction(L, c_baru);
    lua_setfield(L, -2, "new");
    return 1;
}
```

```lua
local Counter = require("counter")
local c = Counter.new(10)
print(c:naik(), c:naik())     --> 11   12
print(c)                      --> Counter(12)
```

Jika userdata memegang sumber daya eksternal (file, socket), tambahkan metamethod **`__gc`** (dan `__close` pada Lua 5.4) untuk melepaskannya.

### 12.8 Error Handling dan Memory Management di C API

- Lua melempar error dengan `longjmp` (atau exception bila dikompilasi sebagai C++). Function C **tidak boleh** melanjutkan eksekusi normal setelah `lua_error`/`luaL_error` (keduanya tidak kembali).
- Di host, bungkus pemanggilan dengan `lua_pcall` dan baca pesan error di puncak stack.
- Gunakan **message handler** untuk traceback:

```c
static int pesan_error(lua_State *L) {
    const char *msg = lua_tostring(L, 1);
    luaL_traceback(L, L, msg, 1);       /* push traceback */
    return 1;
}

lua_pushcfunction(L, pesan_error);
int handler = lua_gettop(L);
/* ... push fungsi & argumen ... */
if (lua_pcall(L, nargs, nresults, handler) != LUA_OK) { /* error + traceback di -1 */ }
```

- **Memori:** `luaL_newstate` memakai allocator default; gunakan `lua_newstate(alloc_fn, ud)` untuk allocator kustom (pembatasan memori, pelacakan). Objek Lua dikelola GC; memori yang Anda alokasikan sendiri di C (`malloc`) **harus dibebaskan sendiri**, biasanya di `__gc`.
- **Jangan menyimpan pointer** ke string Lua setelah nilainya keluar dari stack: salin dulu bila perlu.
- Untuk nilai yang harus bertahan lama dari C, simpan di **registry** (`luaL_ref` / `luaL_unref`).

```c
/* simpan callback Lua agar bisa dipanggil nanti */
lua_pushvalue(L, 1);                          /* function callback di argumen 1 */
int ref = luaL_ref(L, LUA_REGISTRYINDEX);     /* simpan; dapatkan ID */
/* nanti: */
lua_rawgeti(L, LUA_REGISTRYINDEX, ref);       /* ambil function lagi */
/* lua_pcall(...) */
luaL_unref(L, LUA_REGISTRYINDEX, ref);        /* lepaskan bila tidak dipakai */
```

### 12.9 Interoperability dan Batas Keamanan

- **Versi API berbeda** antar Lua 5.1/5.2/5.3/5.4 (mis. `lua_newuserdata` vs `lua_newuserdatauv`, `luaL_register` vs `luaL_newlib`). Gunakan `#if LUA_VERSION_NUM` atau layer kompatibilitas bila mendukung banyak versi.
- **Batasi apa yang diekspos ke skrip.** Jangan `luaL_openlibs` penuh bila skrip tidak tepercaya; buka hanya library yang perlu (`luaL_requiref(L, "_G", luaopen_base, 1)`, dst.). Ingat batas keamanan sandbox (Tahap 9).
- **Validasi setiap argumen** di function C (`luaL_check*`) karena skrip dapat mengirim apa saja.
- **Hindari bug memori klasik** (buffer overflow, use-after-free, stack tak seimbang): bug di C dapat merusak seluruh proses.
- **Thread-safety:** satu `lua_State` tidak boleh dipakai bersamaan oleh banyak thread OS tanpa sinkronisasi. Gunakan satu state per thread (atau kunci).
- **Alternatif tanpa menulis C:** pada LuaJIT gunakan **FFI**; pada Lua standar, untuk binding besar gunakan generator seperti **SWIG**, **sol2** (C++), atau **LuaBridge**.

### 12.10 Praktik

1. **Program C menjalankan file Lua** (`luaL_dofile`) dengan penanganan error.
2. **C function dari Lua:** `hipotenusa`, `bagi` (dengan idiom `nil, err`), dan function yang menerima table.
3. **Lua module berbasis C:** `mymath` dengan 4-5 function; muat via `require`.
4. **C → Lua:** baca konfigurasi `config = { lebar, tinggi, judul }` dari file Lua ke `struct` C.
5. **Lua → C:** kirim array angka dari Lua ke fungsi C yang menghitung rata-rata dan deviasi standar.
6. **Aplikasi kecil dengan Lua sebagai scripting engine:** mis. simulator "robot" di terminal; C menyediakan API (`gerak`, `putar`, `lihat`), Lua menulis *strategi*; tambahkan callback `on_tick()` dan batas waktu/instruksi untuk skrip.

### 12.11 Target Kelulusan Tahap 12

- [ ] Memahami stack-based API Lua.
- [ ] Mampu memanggil Lua dari C.
- [ ] Mampu mengekspos function C ke Lua.
- [ ] Memahami konsep embedding dan extension.

---

# Bagian 6: Spesialisasi Lua untuk Neovim

## Tahap 13. Lua untuk Neovim Configuration dan Plugin Development

**Level:** Advanced – Expert · **Estimasi:** Minggu 17–18

### 13.1 Lua di Neovim: Hal yang Perlu Diketahui Dulu

Neovim menanamkan **LuaJIT** (atau Lua 5.1 pada platform tanpa LuaJIT) sebagai bahasa konfigurasi dan plugin kelas satu. Konsekuensinya, kode Neovim memakai **semantik Lua 5.1**:

| Fitur | Di Neovim (LuaJIT / 5.1) | Pengganti / catatan |
|---|---|---|
| `table.unpack` | Tidak ada (secara default) | `local unpack = table.unpack or unpack` |
| `//` dan operator bitwise | Tidak ada | `math.floor(a / b)`; library `bit` |
| `<const>`, `<close>` | **Tidak didukung** | Gunakan `local` biasa |
| `utf8` library | Tidak ada | `vim.str_utfindex`, `vim.fn.strchars`, dst. |
| Integer 64-bit | Tidak ada (semua number = double) | Hati-hati dengan angka besar |
| `goto` | Didukung (LuaJIT) | |
| `load` dengan env | `load` hanya memuat; atur env dengan `setfenv(fn, env)` | Berbeda dari Lua 5.2+ |
| `string.format("%d", 3.0)` | Boleh | Berbeda dengan Lua 5.4 |

> Kode di Tahap 1–12 yang memakai fitur khusus 5.3/5.4 perlu disesuaikan bila ingin dijalankan di dalam Neovim. Untuk fitur terbaru Neovim (mis. `vim.system`, `vim.iter`, API LSP baru) selalu cek versi yang kamu pakai: `:version` atau `:help news`.

**Mencoba kode Lua di Neovim:**

```vim
:lua print("halo dari Neovim")
:lua =vim.o.tabstop            " tanda = mencetak hasil ekspresi
:luafile %                     " jalankan file Lua yang sedang dibuka
:lua vim.print(vim.api.nvim_list_bufs())
```

### 13.2 Struktur Konfigurasi dan Module Loading

Lokasi konfigurasi (cek dengan `:echo stdpath("config")`):

| OS | Lokasi |
|---|---|
| Linux / macOS | `~/.config/nvim/` (atau `$XDG_CONFIG_HOME/nvim`) |
| Windows | `%LOCALAPPDATA%\nvim\` |

Gunakan **`init.lua`** sebagai titik masuk (hindari memakai `init.vim` bersamaan).

```text
~/.config/nvim/
├── init.lua                 -- titik masuk
└── lua/
    ├── config/
    │   ├── options.lua      -- require("config.options")
    │   ├── keymaps.lua
    │   ├── autocmds.lua
    │   └── lazy.lua         -- bootstrap plugin manager
    └── plugins/
        ├── editor.lua
        └── lsp.lua
```

**Mekanisme module:** Neovim menambahkan subfolder `lua/` dari setiap direktori di **runtimepath** ke pencarian `require`. Jadi `require("config.options")` memuat `lua/config/options.lua` dan `require("config")` memuat `lua/config/init.lua`.

```lua
-- init.lua
vim.g.mapleader = " "            -- WAJIB diatur sebelum plugin/keymap dimuat
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
```

> Gunakan `pcall(require, "modul")` untuk module opsional agar konfigurasi tidak rusak total bila satu file bermasalah.

### 13.3 Global `vim` dan Opsi

| API | Fungsi | Contoh |
|---|---|---|
| `vim.g` | Variabel global (`g:`) | `vim.g.mapleader = " "` |
| `vim.b` / `vim.w` / `vim.t` | Variabel buffer / window / tab | `vim.b.minianimate_disable = true` |
| `vim.o` | Opsi global (`:set`) | `vim.o.tabstop = 2` |
| `vim.bo` / `vim.wo` | Opsi lokal buffer / window | `vim.bo.filetype = "lua"` |
| `vim.opt` | Antarmuka opsi berorientasi object (list/set) | `vim.opt.listchars:append({ eol = "↴" })` |
| `vim.env` | Environment variable | `vim.env.EDITOR` |
| `vim.fn` | Memanggil function Vimscript | `vim.fn.expand("%:p")` |
| `vim.api` | Neovim API (`nvim_*`) | `vim.api.nvim_get_current_buf()` |
| `vim.cmd` | Menjalankan perintah Ex | `vim.cmd("colorscheme habamax")` |

```lua
-- lua/config/options.lua
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.wrap = false
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true
opt.completeopt = { "menu", "menuone", "noselect" }
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- opsi bertipe list/set dapat dimodifikasi:
opt.path:append("**")
opt.shortmess:append("c")
-- baca nilai opsi: vim.print(opt.listchars:get())
```

**`vim.opt` vs `vim.o`:** `vim.o.tabstop = 2` adalah penugasan langsung (cocok untuk nilai skalar). `vim.opt` memudahkan opsi berupa list/map (`:append`, `:remove`, `:prepend`) dan menerima table Lua.

### 13.4 Keymap

```lua
-- vim.keymap.set(mode, lhs, rhs, opts)
local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Simpan file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Keluar" })
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Salin ke clipboard" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Hapus sorotan pencarian" })

-- rhs berupa function Lua
map("n", "<leader>cd", function()
  vim.cmd.cd(vim.fn.expand("%:p:h"))
  vim.notify("cwd: " .. vim.fn.getcwd())
end, { desc = "cd ke folder file ini" })

-- keymap lokal buffer
map("n", "q", "<cmd>close<cr>", { buffer = 0, silent = true, desc = "Tutup" })

-- expr: rhs mengembalikan string yang dieksekusi
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
```

Opsi umum: `desc` (selalu isi, muncul di *which-key*/`:map`), `silent`, `buffer` (angka buffer atau `true`), `expr`, `remap`. `vim.keymap.set` secara default **non-recursive** (setara `noremap`).

**Keymap manager sederhana** (praktik kustom):

```lua
local M = {}
local terdaftar = {}

function M.peta(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
  terdaftar[#terdaftar + 1] = { mode = mode, lhs = lhs, desc = opts.desc or "" }
end

function M.daftar() return terdaftar end
return M
```

### 13.5 Neovim API

**Konvensi:** fungsi `vim.api.nvim_*`; baris pada API umumnya **0-indexed**, tetapi `nvim_win_get_cursor` mengembalikan `{baris (1-indexed), kolom (0-indexed)}`. Buffer/window `0` = yang aktif.

**Buffer**

```lua
local buf = vim.api.nvim_get_current_buf()
local nama = vim.api.nvim_buf_get_name(buf)

-- baca baris 0..9 (end eksklusif); strict_indexing = false
local baris = vim.api.nvim_buf_get_lines(buf, 0, 10, false)

-- tulis: ganti seluruh isi
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "baris 1", "baris 2" })

-- buffer scratch baru (tidak listed, scratch)
local scratch = vim.api.nvim_create_buf(false, true)

print(vim.api.nvim_buf_line_count(buf))
print(vim.api.nvim_buf_is_valid(buf))
```

**Window & Tabpage**

```lua
local win = vim.api.nvim_get_current_win()
local baris, kolom = unpack(vim.api.nvim_win_get_cursor(win))
vim.api.nvim_win_set_cursor(win, { 1, 0 })
print(vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win))

for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
  print(tab, #vim.api.nvim_tabpage_list_wins(tab))
end
```

**Autocommand**

```lua
local grup = vim.api.nvim_create_augroup("MyConfig", { clear = true })   -- clear mencegah duplikasi

-- sorot teks yang disalin
vim.api.nvim_create_autocmd("TextYankPost", {
  group = grup,
  desc = "Sorot teks yang di-yank",
  callback = function()
    (vim.hl or vim.highlight).on_yank({ timeout = 150 })   -- vim.hl pada versi baru
  end,
})

-- hapus spasi di akhir baris sebelum menyimpan
vim.api.nvim_create_autocmd("BufWritePre", {
  group = grup,
  pattern = { "*.lua", "*.md" },
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})
```

Event yang sering dipakai: `BufReadPost`, `BufWritePre`/`BufWritePost`, `BufEnter`, `FileType`, `InsertEnter`, `CursorHold`, `VimEnter`, `LspAttach`, `DiagnosticChanged`, `TextYankPost`, `WinClosed`.

**User command**

```lua
vim.api.nvim_create_user_command("Halo", function(opts)
  -- opts.args (string), opts.fargs (table), opts.bang, opts.range, opts.line1, opts.line2
  local nama = opts.fargs[1] or "dunia"
  vim.notify("Halo, " .. nama .. "!")
end, {
  nargs = "?",                       -- 0 atau 1 argumen
  desc = "Menyapa seseorang",
  complete = function() return { "Dina", "Budi" } end,
})
-- :Halo Dina
```

**Namespace, extmark, dan highlight**

```lua
local ns = vim.api.nvim_create_namespace("contoh")

vim.api.nvim_set_hl(0, "CatatanKu", { fg = "#ff9e64", bold = true, italic = true })

local buf = vim.api.nvim_get_current_buf()
-- teks virtual di akhir baris 0 + sorotan pada kolom 0..5
vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
  virt_text = { { " ← catatan", "CatatanKu" } },
  virt_text_pos = "eol",
  end_col = 5,
  hl_group = "Search",
})

vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)    -- bersihkan semua extmark di namespace
```

**Floating window**

```lua
local function buka_float(baris_teks)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, baris_teks)

  local lebar, tinggi = 40, #baris_teks
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = lebar,
    height = tinggi,
    row = math.floor((vim.o.lines - tinggi) / 2),
    col = math.floor((vim.o.columns - lebar) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  return win, buf
end
```

**Notifikasi, input, dan seleksi**

```lua
vim.notify("Berhasil disimpan", vim.log.levels.INFO)
vim.notify("Ada masalah", vim.log.levels.WARN)

vim.ui.input({ prompt = "Nama file: " }, function(input)
  if input then vim.notify("Kamu mengetik: " .. input) end
end)

vim.ui.select({ "apel", "jeruk", "mangga" }, { prompt = "Pilih buah:" }, function(pilihan, idx)
  if pilihan then print(idx, pilihan) end
end)
```

`vim.ui.input` dan `vim.ui.select` bersifat **asinkron berbasis callback** dan dapat digantikan tampilannya oleh plugin UI (Telescope, snacks, dll.) tanpa mengubah kode plugin kamu.

**Utility Lua bawaan Neovim yang sangat berguna:**

```lua
vim.inspect({ a = 1 })                              -- table -> string
vim.print({ a = 1 })                                -- cetak terformat
vim.split("a,b,c", ",", { plain = true })           -- { "a", "b", "c" }
vim.trim("  x  ")
vim.startswith("neovim", "neo")
vim.tbl_deep_extend("force", { a = { b = 1 } }, { a = { c = 2 } })   -- gabung bertingkat
vim.deepcopy(tabel)
vim.tbl_contains({ "a", "b" }, "b")
vim.json.encode({ a = 1 }); vim.json.decode('{"a":1}')
vim.fs.joinpath("a", "b"); vim.fs.dirname("/x/y.lua"); vim.fs.find("init.lua", { upward = true })
```

### 13.6 Scheduling, Event Loop, dan Async

Neovim **single-threaded** dengan event loop berbasis **libuv**. Operasi I/O (proses, file, timer, jaringan) berjalan asinkron dan memanggil **callback** saat selesai.

- Callback dari libuv (`vim.uv` / `vim.loop`) berjalan di **fast event context**, tempat sebagian besar fungsi `vim.api` **tidak boleh** dipanggil. Pindahkan ke main loop dengan **`vim.schedule(fn)`** atau bungkus `vim.schedule_wrap(fn)`.
- `vim.defer_fn(fn, ms)` menjadwalkan eksekusi setelah jeda.

```lua
-- timer
vim.defer_fn(function() vim.notify("3 detik berlalu") end, 3000)

-- menjalankan proses eksternal tanpa memblokir editor (Neovim 0.10+)
vim.system({ "git", "status", "--short" }, { text = true }, function(hasil)
  -- hasil.code, hasil.stdout, hasil.stderr; callback di fast context
  vim.schedule(function()
    vim.notify(hasil.stdout ~= "" and hasil.stdout or "bersih")
  end)
end)

-- versi sinkron (memblokir): :wait()
local r = vim.system({ "echo", "hai" }, { text = true }):wait()
print(r.stdout)
```

Pada versi lama gunakan `vim.fn.jobstart` atau `vim.loop.spawn`. Cek `:help vim.system()` pada versi yang kamu pakai.

**Gaya async/await dengan coroutine** (pola yang dipakai library seperti plenary.async / nvim-nio, versi minimal):

```lua
-- lua/myasync.lua
local M = {}
local unpack = table.unpack or unpack

local function lanjutkan(co, ...)
  local ok, err = coroutine.resume(co, ...)
  if not ok then
    vim.notify(debug.traceback(co, tostring(err)), vim.log.levels.ERROR)
  end
end

function M.run(fn)
  lanjutkan(coroutine.create(fn))
end

-- starter(callback): fungsi yang memulai pekerjaan async dan memanggil callback saat selesai
function M.await(starter)
  local co = coroutine.running()
  assert(co, "await harus dipanggil di dalam run()")
  starter(function(...)
    local args = { n = select("#", ...), ... }
    vim.schedule(function() lanjutkan(co, unpack(args, 1, args.n)) end)
  end)
  return coroutine.yield()
end

return M
```

```lua
local async = require("myasync")

async.run(function()
  local hasil = async.await(function(cb)
    vim.system({ "git", "log", "--oneline", "-n", "3" }, { text = true }, cb)
  end)
  vim.notify(hasil.stdout)          -- ditulis berurutan, tanpa callback bersarang
end)
```

Inilah penerapan nyata coroutine dari Tahap 9: mengubah kode berbasis callback menjadi kode yang terbaca berurutan, **tanpa** membuat editor berhenti merespons.

### 13.7 Arsitektur Plugin

**Struktur direktori standar:**

```text
quicknote.nvim/
├── lua/
│   └── quicknote/
│       ├── init.lua        -- API publik: setup(), open(), close(), toggle()
│       ├── config.lua      -- default + merge opsi pengguna
│       └── ui.lua          -- (opsional) window/float
├── plugin/
│   └── quicknote.lua       -- dimuat otomatis saat startup: daftarkan user command (sangat ringan)
├── doc/
│   └── quicknote.txt       -- dokumentasi :help
├── tests/
│   ├── minimal_init.lua
│   └── config_spec.lua
├── README.md
└── LICENSE
```

**Entry point & lifecycle:**

1. **Instalasi** (plugin manager menambahkan folder plugin ke `runtimepath`).
2. File di **`plugin/`** otomatis di-*source* saat startup (jaga tetap ringan; definisikan command saja).
3. Pengguna memanggil **`require("quicknote").setup(opts)`** untuk konfigurasi.
4. Kode berat dimuat **lambat** (*lazy*) saat command/keymap dipakai.
5. Event/autocommand menjalankan fungsi sesuai aktivitas.

**Pola `setup(opts)` dengan nilai default:**

```lua
-- lua/quicknote/config.lua
local M = {}

M.defaults = {
  width = 0.6,          -- rasio lebar layar
  height = 0.5,
  border = "rounded",
  path = vim.fn.stdpath("data") .. "/quicknote.md",
  keymap = nil,         -- mis. "<leader>qn"
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  opts = opts or {}
  assert(type(opts) == "table", "quicknote: opts harus berupa table")
  M.options = vim.tbl_deep_extend("force", M.defaults, opts)

  local o = M.options
  assert(type(o.width) == "number" and o.width > 0 and o.width <= 1, "quicknote: width harus 0 < w <= 1")
  assert(type(o.height) == "number" and o.height > 0 and o.height <= 1, "quicknote: height harus 0 < h <= 1")
  return o
end

return M
```

**API publik:**

```lua
-- lua/quicknote/init.lua
local config = require("quicknote.config")

local M = {}
local state = { buf = nil, win = nil }

local function baca(path)
  local f = io.open(path, "r")
  if not f then return { "" } end
  local isi = f:read("*a")        -- "*a" kompatibel dengan LuaJIT
  f:close()
  return vim.split(isi, "\n", { plain = true })
end

local function simpan(path, baris)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local f, err = io.open(path, "w")
  if not f then
    vim.notify("QuickNote gagal menyimpan: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  f:write(table.concat(baris, "\n"))
  f:close()
end

function M.is_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

function M.open()
  if M.is_open() then
    vim.api.nvim_set_current_win(state.win)
    return
  end
  local o = config.options
  local lebar = math.floor(vim.o.columns * o.width)
  local tinggi = math.floor(vim.o.lines * o.height)

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, baca(o.path))

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = lebar,
    height = tinggi,
    row = math.floor((vim.o.lines - tinggi) / 2),
    col = math.floor((vim.o.columns - lebar) / 2),
    style = "minimal",
    border = o.border,
    title = " QuickNote ",        -- opsi title membutuhkan Neovim 0.9+
    title_pos = "center",
  })

  vim.keymap.set("n", "q", M.close, { buffer = state.buf, desc = "Simpan & tutup" })
end

function M.close()
  if not M.is_open() then return end
  local baris = vim.api.nvim_buf_get_lines(state.buf, 0, -1, false)
  simpan(config.options.path, baris)
  vim.api.nvim_win_close(state.win, true)
  state.win, state.buf = nil, nil
end

function M.toggle()
  if M.is_open() then M.close() else M.open() end
end

function M.setup(opts)
  local o = config.setup(opts)
  if o.keymap then
    vim.keymap.set("n", o.keymap, M.toggle, { desc = "QuickNote: buka/tutup" })
  end
end

return M
```

```lua
-- plugin/quicknote.lua  (jaga seringan, require hanya di dalam callback => lazy)
if vim.g.loaded_quicknote then return end
vim.g.loaded_quicknote = 1

vim.api.nvim_create_user_command("QuickNote", function()
  require("quicknote").toggle()
end, { desc = "Buka/tutup catatan cepat" })
```

**Pemakaian oleh pengguna (dengan lazy.nvim):**

```lua
{
  "username/quicknote.nvim",
  cmd = "QuickNote",                                   -- lazy: dimuat saat command dipanggil
  keys = { { "<leader>qn", "<cmd>QuickNote<cr>", desc = "QuickNote" } },
  opts = { width = 0.5, border = "single" },           -- diteruskan ke setup()
}
```

**Event-driven programming:** plugin bereaksi terhadap **event** lewat autocommand, bukan dengan polling. Contoh: simpan otomatis note saat jendela float ditutup lewat event `WinClosed`:

```lua
vim.api.nvim_create_autocmd("WinClosed", {
  pattern = tostring(state.win),        -- pattern berisi ID window
  once = true,
  callback = function() --[[ simpan ]] end,
})
```

**Integrasi LSP:** gunakan event `LspAttach` untuk memasang keymap hanya ketika language server aktif di buffer.

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("MyLsp", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local function m(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = "LSP: " .. desc })
    end
    m("gd", vim.lsp.buf.definition, "Ke definisi")
    m("K", vim.lsp.buf.hover, "Hover")
    m("<leader>rn", vim.lsp.buf.rename, "Ganti nama")
    m("<leader>ca", vim.lsp.buf.code_action, "Code action")
    m("<leader>e", vim.diagnostic.open_float, "Diagnostik")
    if client and client.name == "lua_ls" then
      -- pengaturan khusus Lua language server
    end
  end,
})
```

Konfigurasi server bergantung versi: Neovim terbaru menyediakan `vim.lsp.config()` / `vim.lsp.enable()`, sedangkan versi/konfigurasi lama banyak memakai plugin **nvim-lspconfig**. Pilih sesuai versi Neovim kamu dan baca `:help lsp`.

**Integrasi completion:** plugin dapat menyediakan sumber completion ke plugin seperti *nvim-cmp* atau *blink.cmp*, atau memakai mekanisme bawaan (`completefunc`/`omnifunc`; Neovim terbaru juga memiliki `vim.lsp.completion`). Karena ekosistem ini cepat berubah, rujuk dokumentasi plugin completion yang kamu target.

**Error handling pada plugin:** jangan biarkan error plugin merusak editor pengguna. Bungkus operasi berisiko dengan `pcall`, laporkan lewat `vim.notify` (level yang tepat), dan validasi input `setup()` dengan pesan jelas. Untuk deprecated API, beri peringatan sekali saja.

**Testing plugin.** Opsi populer: **plenary.nvim** (test bergaya Busted yang dijalankan di dalam Neovim), **mini.test**, atau Busted + runner Neovim. Contoh dengan plenary:

```lua
-- tests/config_spec.lua
describe("quicknote.config", function()
  local config = require("quicknote.config")

  it("memakai nilai default", function()
    config.setup()
    assert.are.equal("rounded", config.options.border)
  end)

  it("menggabungkan opsi pengguna", function()
    config.setup({ width = 0.8 })
    assert.are.equal(0.8, config.options.width)
    assert.are.equal("rounded", config.options.border)   -- default tetap ada
  end)

  it("menolak width tidak valid", function()
    assert.has_error(function() config.setup({ width = 5 }) end)
  end)
end)
```

```bash
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
```

`tests/minimal_init.lua` menambahkan plugin ini dan plenary ke `runtimepath`. Jalankan pula di CI (GitHub Actions) pada beberapa versi Neovim (stable dan nightly).

**Dokumentasi plugin:** sediakan `README.md` (instalasi, konfigurasi default, contoh) dan `doc/quicknote.txt` (format vimdoc) agar `:help quicknote` bekerja. Bangkitkan tag dengan `:helptags doc`.

```text
*quicknote.txt*   Catatan cepat dalam floating window

COMMANDS                                                    *quicknote-commands*
:QuickNote      Buka atau tutup jendela catatan.

CONFIGURATION                                              *quicknote-configuration*
Panggil require("quicknote").setup({ ... }) dengan opsi: width, height, border, path, keymap.
```

### 13.8 Praktik

1. **Konfigurasi modular:** pecah `init.lua` menjadi `options`, `keymaps`, `autocmds`, `lazy`, dan folder `plugins/`; tambahkan `pcall(require, ...)` untuk module opsional.
2. **Custom keymap manager** (lihat 13.4) yang menampilkan daftar keymap lewat `vim.ui.select`.
3. **Statusline sederhana**

```lua
function _G.StatusLineKu()
  local nama = vim.fn.expand("%:t")
  if nama == "" then nama = "[Tanpa Nama]" end
  local ubah = vim.bo.modified and " [+]" or ""
  return table.concat({ " ", nama, ubah, "%=", "%l:%c ", "%p%% " })
end
vim.o.statusline = "%!v:lua.StatusLineKu()"
```

4. **Floating terminal:** buka window float lalu `vim.fn.termopen(vim.o.shell)` (atau `vim.fn.jobstart(..., { term = true })` pada versi baru) dan masuk insert mode; tutup dengan keymap.
5. **Plugin Neovim sederhana:** implementasikan `quicknote.nvim` di atas, lalu tambah fitur (beberapa catatan, pencarian).
6. **Plugin loader:** baca daftar plugin kecil dari table, tambah ke `runtimepath` (`vim.opt.runtimepath:prepend(path)`), lalu panggil `setup()`.
7. **Asynchronous task runner:** command `:Run <cmd>` yang menjalankan proses lewat `vim.system`, menampilkan output di buffer split, dan menandai sukses/gagal dengan highlight.
8. **Plugin lengkap:** konfigurasi + API publik + user command + keymap + autocommand + tes + `README` + vimdoc.

### 13.9 Target Kelulusan Tahap 13

- [ ] Mampu membaca dan menggunakan Neovim API.
- [ ] Mampu membuat konfigurasi modular.
- [ ] Mampu membuat plugin Neovim.
- [ ] Memahami lifecycle dan event-driven architecture Neovim.

### 13.10 Referensi Neovim

- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [Neovim Lua Reference](https://neovim.io/doc/user/lua.html)
- [Neovim API Documentation](https://neovim.io/doc/user/api.html)

---

# Bagian 7: Final Projects

Kerjakan proyek berikut **secara berurutan**. Jangan hanya menyalin tutorial: rancang struktur program, implementasikan, tulis test, dan dokumentasikan. Simpan semuanya di Git dengan commit yang rapi.

## Project 1: CLI Calculator

**Level:** Beginner

**Fitur**

- [ ] Operasi tambah, kurang, kali, dan bagi.
- [ ] Validasi input.
- [ ] Penanganan pembagian dengan nol.
- [ ] Menu interaktif.
- [ ] Pemisahan function.
- [ ] Error handling.

**Konsep yang digunakan:** variables, data types, operators, control flow, functions.

**Contoh implementasi:**

```lua
-- kalkulator.lua
local operasi = {
  ["+"] = function(a, b) return a + b end,
  ["-"] = function(a, b) return a - b end,
  ["*"] = function(a, b) return a * b end,
  ["/"] = function(a, b)
    if b == 0 then return nil, "tidak bisa membagi dengan nol" end
    return a / b
  end,
}

local function baca_angka(prompt)
  while true do
    io.write(prompt)
    local teks = io.read("l")
    if teks == nil then os.exit(0) end            -- EOF (Ctrl-D)
    local n = tonumber(teks)
    if n then return n end
    print("Input harus berupa angka, coba lagi.")
  end
end

local function hitung(a, op, b)
  local fn = operasi[op]
  if not fn then return nil, "operator tidak dikenal: " .. tostring(op) end
  return fn(a, b)
end

print("Kalkulator CLI (ketik 'q' pada operator untuk keluar)")
while true do
  local a = baca_angka("Angka pertama: ")
  io.write("Operator (+ - * /) atau q: ")
  local op = io.read("l")
  if op == nil or op == "q" then break end
  local b = baca_angka("Angka kedua  : ")

  local hasil, err = hitung(a, op, b)
  if hasil then
    print(("%g %s %g = %g"):format(a, op, b, hasil))
  else
    print("Error: " .. err)
  end
  print()
end
print("Sampai jumpa!")
```

**Tantangan tambahan:** dukung ekspresi seperti `3 + 4 * 2` (parser sederhana), riwayat perhitungan, dan test dengan Busted.

## Project 2: Task Manager CLI

**Level:** Intermediate

**Fitur**

- [ ] Menambahkan task.
- [ ] Melihat seluruh task.
- [ ] Mengubah task.
- [ ] Menghapus task.
- [ ] Menandai task selesai.
- [ ] Menyimpan data ke file.
- [ ] Memuat data ketika aplikasi dijalankan.
- [ ] Validasi input.
- [ ] Pemisahan module.

**Konsep yang digunakan:** tables, functions, file IO, modules, error handling.

**Struktur:**

```text
taskcli/
├── main.lua
├── src/
│   ├── model.lua       -- struktur & aturan task
│   ├── storage.lua     -- baca/tulis file
│   └── commands.lua    -- tambah, daftar, selesai, hapus
└── spec/
```

**Storage yang aman (memuat file dengan environment kosong):**

```lua
-- src/storage.lua
local M = {}

local function ke_teks(v)
  if type(v) == "table" then
    local bagian = {}
    for _, item in ipairs(v) do bagian[#bagian + 1] = ke_teks(item) end          -- array
    local kunci = {}
    for k in pairs(v) do
      if type(k) ~= "number" then kunci[#kunci + 1] = k end
    end
    table.sort(kunci)
    for _, k in ipairs(kunci) do
      bagian[#bagian + 1] = ("[%q] = %s"):format(k, ke_teks(v[k]))
    end
    return "{" .. table.concat(bagian, ", ") .. "}"
  elseif type(v) == "string" then
    return ("%q"):format(v)
  else
    return tostring(v)
  end
end

function M.simpan(path, data)
  local tmp = path .. ".tmp"
  local f, err = io.open(tmp, "w")
  if not f then return nil, err end
  f:write("return ", ke_teks(data), "\n")
  f:close()
  local ok, err2 = os.rename(tmp, path)          -- tulis atomik: tmp lalu rename
  if not ok then return nil, err2 end
  return true
end

function M.muat(path)
  local f = io.open(path, "r")
  if not f then return {} end                    -- belum ada file = data kosong
  local isi = f:read("a")
  f:close()
  local fn, err = load(isi, "=" .. path, "t", {})      -- "t" + env kosong: tidak bisa memanggil apa pun
  if not fn then return nil, "file rusak: " .. err end
  local ok, data = pcall(fn)
  if not ok then return nil, "file rusak: " .. tostring(data) end
  return data
end

return M
```

> Pada Windows, `os.rename` ke file yang sudah ada dapat gagal; hapus target dulu atau pakai strategi lain bila perlu.

**Model dan perintah (kerangka):**

```lua
-- src/model.lua
local M = {}

function M.baru(id, judul)
  assert(type(judul) == "string" and judul:match("%S"), "judul tidak boleh kosong")
  return { id = id, judul = judul, selesai = false, dibuat = os.time() }
end

return M
```

```lua
-- main.lua
package.path = "./src/?.lua;" .. package.path
local storage  = require("storage")
local model    = require("model")

local FILE = "tugas.db"
local data = assert(storage.muat(FILE))
data.tugas = data.tugas or {}
data.berikut = data.berikut or 1

local perintah = {}

function perintah.tambah(args)
  local t = model.baru(data.berikut, table.concat(args, " "))
  data.berikut = data.berikut + 1
  table.insert(data.tugas, t)
  print("Ditambahkan #" .. t.id)
end

function perintah.daftar()
  if #data.tugas == 0 then print("(belum ada tugas)") return end
  for _, t in ipairs(data.tugas) do
    print(("[%s] #%d %s"):format(t.selesai and "x" or " ", t.id, t.judul))
  end
end

function perintah.selesai(args)
  local id = tonumber(args[1])
  for _, t in ipairs(data.tugas) do
    if t.id == id then t.selesai = true; print("Selesai #" .. id); return end
  end
  error("tugas tidak ditemukan: " .. tostring(args[1]), 0)
end

local nama = arg[1]
local fn = perintah[nama or ""]
if not fn then
  io.stderr:write("Pemakaian: lua main.lua tambah <judul> | daftar | selesai <id>\n")
  os.exit(1)
end

local ok, err = pcall(fn, { table.unpack(arg, 2) })
if not ok then io.stderr:write("Error: ", tostring(err), "\n"); os.exit(1) end
assert(storage.simpan(FILE, data))
```

**Lengkapi sendiri:** perintah `ubah` dan `hapus`, filter `daftar --selesai`, urutan, tenggat waktu, dan test Busted untuk `model` dan `storage`.

## Project 3: Plugin Manager Sederhana

**Level:** Advanced

**Fitur**

- [ ] Registrasi plugin.
- [ ] Mengaktifkan dan menonaktifkan plugin.
- [ ] Dependency antarplugin.
- [ ] Plugin lifecycle.
- [ ] Dynamic module loading.
- [ ] Error isolation.
- [ ] Konfigurasi plugin.
- [ ] Logging.

**Konsep yang digunakan:** module system, metatable, closures, dynamic loading, dependency management.

**Rancangan:**

```lua
-- Bentuk sebuah plugin (plugins/halo.lua)
return {
  name = "halo",
  version = "1.0.0",
  depends = { "logger" },                       -- plugin lain yang dibutuhkan
  defaults = { sapaan = "Halo" },
  on_load   = function(self, config) end,       -- dipanggil saat dimuat
  on_enable = function(self) print(self.config.sapaan .. " dari plugin!") end,
  on_disable = function(self) end,
}
```

**Inti: resolusi dependency (urutan muat) dengan deteksi siklus:**

```lua
local function urutan_muat(daftar)
  local hasil, status = {}, {}            -- status[nama] = "proses" | "selesai"

  local function kunjungi(nama, jejak)
    if status[nama] == "selesai" then return end
    if status[nama] == "proses" then
      error("dependency melingkar: " .. table.concat(jejak, " -> ") .. " -> " .. nama, 0)
    end
    local p = daftar[nama]
    if not p then error("plugin tidak ditemukan: " .. nama, 0) end

    status[nama] = "proses"
    jejak[#jejak + 1] = nama
    for _, dep in ipairs(p.depends or {}) do kunjungi(dep, jejak) end
    jejak[#jejak] = nil
    status[nama] = "selesai"
    hasil[#hasil + 1] = nama               -- dependency selalu muncul sebelum pemakainya
  end

  local nama_urut = {}
  for nama in pairs(daftar) do nama_urut[#nama_urut + 1] = nama end
  table.sort(nama_urut)
  for _, nama in ipairs(nama_urut) do kunjungi(nama, {}) end
  return hasil
end
```

**Error isolation & lifecycle:**

```lua
local Manager = {}
Manager.__index = Manager

function Manager.new() return setmetatable({ plugins = {}, aktif = {} }, Manager) end

function Manager:daftar(nama)
  local ok, p = pcall(require, "plugins." .. nama)      -- isolasi error loading
  if not ok then return nil, "gagal memuat '" .. nama .. "': " .. tostring(p) end
  self.plugins[p.name or nama] = p
  return p
end

function Manager:aktifkan(nama, config)
  local p = self.plugins[nama]
  if not p then return nil, "belum terdaftar: " .. nama end
  p.config = vim and vim.tbl_deep_extend("force", p.defaults or {}, config or {}) or config or p.defaults
  local ok, err = pcall(p.on_enable, p)
  if not ok then return nil, "plugin '" .. nama .. "' error: " .. tostring(err) end
  self.aktif[nama] = true
  return true
end
```

> Contoh di atas sengaja memakai pengecekan `vim` agar bisa dijalankan di luar Neovim. Untuk proyek murni Lua, buat fungsi `merge(defaults, config)` sendiri.

**Lengkapi sendiri:** `nonaktifkan` (urutan terbalik, periksa pemakai), event bus untuk komunikasi antarplugin (Tahap 9), logger terpusat (Tahap 7), versi minimum plugin, dan test untuk dependency melingkar.

## Project 4: Neovim Plugin

**Level:** Expert

**Fitur**

- [ ] Memiliki konfigurasi sendiri.
- [ ] Memiliki public API.
- [ ] Memiliki user commands.
- [ ] Memiliki keymaps.
- [ ] Memanfaatkan Neovim API.
- [ ] Mendukung autocommand.
- [ ] Error handling.
- [ ] Dokumentasi penggunaan.
- [ ] Automated test jika memungkinkan.

**Konsep yang digunakan:** Lua advanced, Neovim API, event-driven architecture, plugin architecture, async programming.

**Ide plugin (pilih satu, bukan hanya meniru `quicknote`):**

| Ide | Fitur utama | Yang dilatih |
|---|---|---|
| **todo-hl** | Menyorot `TODO:`, `FIXME:` di komentar, daftar ke quickfix | Extmark, autocmd, quickfix |
| **run-task** | `:Run <cmd>` async, output di split, status sukses/gagal | `vim.system`, buffer/window, async |
| **buffer-stats** | Statistik kata/baris/waktu edit untuk statusline | Autocmd, cache, statusline |
| **session-lite** | Simpan/pulihkan layout window & buffer per proyek | Penyimpanan, API window/buffer |
| **scratchpad** | Buffer scratch per proyek dengan persist | Float, file I/O, `setup()` |

**Kriteria selesai:** `setup(opts)` tervalidasi, API publik terdokumentasi di vimdoc, minimal 10 test, berjalan di versi Neovim stable terbaru, README lengkap dengan GIF/screenshot, dan tidak melambatkan startup (ukur dengan `nvim --startuptime log.txt`).

## Project 5: Lua dan C Integration

**Level:** Expert

**Fitur**

- [ ] Aplikasi C menjalankan script Lua.
- [ ] Lua memanggil function dari C.
- [ ] C memanggil function dari Lua.
- [ ] Pertukaran data.
- [ ] Error handling.
- [ ] Pengelolaan memory.

**Konsep yang digunakan:** Lua C API, Lua stack, userdata, embedding, interoperability.

**Rancangan yang disarankan, "Robot Arena":**

```text
robot/
├── robot.c          -- host: dunia 2D sederhana, loop simulasi
├── api.c            -- function C untuk Lua: robot.maju(n), robot.putar(derajat), robot.lihat()
├── strategi.lua     -- skrip pengguna: function on_tick(state)
└── Makefile
```

Alur: C membuat `lua_State`, membuka library terbatas, mendaftarkan tabel `robot` (userdata `Robot` dengan metatable), memuat `strategi.lua`, lalu setiap *tick* memanggil `on_tick` dengan `lua_pcall`. Error di skrip ditangkap, dilaporkan, dan robot dihentikan (tanpa membuat host crash). Tambahkan batas instruksi lewat `lua_sethook` agar skrip tak bisa menggantung simulasi.

**Kriteria selesai:** tidak ada kebocoran memori (cek dengan `valgrind` bila tersedia), seluruh argumen dari Lua divalidasi, dan ada dokumentasi API untuk penulis skrip.

---

# Bagian 8: Timeline Belajar

Timeline berikut adalah **estimasi**. Kecepatan penyelesaian bergantung pada waktu praktik dan pengalaman pemrograman sebelumnya.

| Periode | Materi | Target |
|---|---|---|
| Minggu 1 | Pengenalan Lua dan environment | Menjalankan program Lua |
| Minggu 2 | Variables, data types, operators, control flow | Program dasar |
| Minggu 3 | Functions, scope, closure | Function reusable |
| Minggu 4 | String dan pattern matching | Text processing |
| Minggu 5–6 | Tables dan data structures | Mengelola data |
| Minggu 7 | Modules dan error handling | Aplikasi modular |
| Minggu 8–9 | OOP dan metatable | Object system |
| Minggu 10–11 | Iterator, coroutine, memory | Advanced Lua |
| Minggu 12 | File, OS, standard library | Automation |
| Minggu 13–14 | Ecosystem, testing, performance | Package berkualitas |
| Minggu 15–16 | Lua C API | Embedding dan extension |
| Minggu 17–18 | Neovim Lua dan plugin | Plugin Neovim |

Setelah minggu ke-18, sisakan waktu untuk menyelesaikan proyek akhir, merapikan portofolio, dan mengulang topik yang masih lemah (4-6 bulan total adalah rentang realistis untuk 10-15 jam/minggu).

---

# Bagian 9: Sumber Belajar

Utamakan dokumentasi resmi agar pemahaman sesuai dengan versi Lua yang digunakan.

## Dokumentasi Utama

1. [Lua Official Website](https://www.lua.org/)
2. [Lua 5.4 Reference Manual](https://www.lua.org/manual/5.4/)
3. [Programming in Lua](https://www.lua.org/pil/): buku resmi oleh pencipta Lua. Versi online gratis mengacu pada versi Lua yang lebih lama (konsepnya tetap relevan, tetapi ada detail yang berbeda); edisi yang lebih baru tersedia untuk dibeli dan mencakup Lua 5.3.
4. [Lua Frequently Asked Questions](https://www.lua.org/faq.html)

## Tools dan Ecosystem

1. [LuaRocks](https://luarocks.org/): package manager Lua.
2. [LuaJIT](https://luajit.org/): implementasi Lua dengan Just-In-Time compiler.
3. [Busted](https://lunarmodules.github.io/busted/): testing framework.
4. [Luacheck](https://luacheck.readthedocs.io/): static analyzer dan linter.
5. [StyLua](https://github.com/JohnnyMorganz/StyLua): formatter Lua.
6. [Neovim](https://neovim.io/): editor yang menggunakan Lua untuk konfigurasi dan plugin.

## Catatan Versi

- Lua 5.1, 5.2, 5.3, dan 5.4 memiliki perbedaan fitur dan perilaku.
- Gunakan **satu versi utama** sebagai target belajar terlebih dahulu. Panduan ini memakai **Lua 5.4** sebagai acuan. Periksa [lua.org](https://www.lua.org/) untuk rilis terbaru.
- Perhatikan perbedaan API jika menggunakan **LuaJIT**, karena LuaJIT umumnya kompatibel dengan Lua 5.1 dan menyediakan sejumlah ekstensi. **Neovim** memakai semantik ini.
- Saat membaca dokumentasi atau source code library, **selalu periksa versi Lua yang didukung**.

---

# Bagian 10: Strategi dan Evaluasi Pembelajaran

## Komposisi Waktu Belajar

| Aktivitas | Alokasi |
|---|---:|
| Membaca dokumentasi | 20% |
| Memahami konsep dan membuat catatan | 20% |
| Coding dan eksperimen | 40% |
| Mengerjakan proyek | 20% |

## Aturan Belajar

1. Jangan melompat ke metatable sebelum memahami table dan function.
2. Biasakan menggunakan `local` daripada global variable.
3. Pahami konsep, jangan hanya menghafal syntax.
4. Setiap materi harus menghasilkan minimal satu program.
5. Biasakan membaca source code library Lua.
6. Pelajari error message dan debugging.
7. Tulis test untuk kode yang mulai kompleks.
8. Gunakan Git untuk menyimpan perkembangan proyek.
9. Dokumentasikan keputusan desain dan cara penggunaan program.
10. Lakukan refactoring setelah program berjalan.

## Kesalahan Umum Pemula Lua

| Kesalahan | Penjelasan / solusi |
|---|---|
| Lupa `local` | Variabel jadi global; aktifkan `luacheck` untuk menangkapnya |
| Mengira indeks mulai 0 | Array Lua mulai dari **1** |
| `obj.method()` padahal butuh `obj:method()` | `self` jadi `nil`; perhatikan `.` vs `:` |
| Memakai `#` pada table berlubang | Hasil tidak dapat diandalkan; jaga sequence tanpa `nil` |
| Mengira `0` dan `""` itu falsy | Hanya `nil` dan `false` yang falsy |
| `a ~= b` ditulis `a != b` | Operator "tidak sama" di Lua adalah `~=` |
| Konkatenasi string dalam loop besar | Pakai `table.concat` |
| Mengandalkan urutan `pairs()` | Urutan tidak terjamin; urutkan key bila perlu |
| Menambah key baru saat iterasi `pairs` | Perilaku tidak terdefinisi |
| Salah paham `==` pada table | Membandingkan identitas, bukan isi |
| Mencampur versi Lua | Cek `_VERSION`; sesuaikan fitur (mis. `//` tidak ada di LuaJIT) |
| Menyalin tanpa memahami | Ketik ulang, ubah, dan jelaskan per baris |

## Indikator Kompetensi

| Level | Kompetensi |
|---|---|
| Beginner | Mampu membuat program sederhana dengan syntax Lua |
| Intermediate | Mampu membangun aplikasi modular dan mengelola data |
| Upper Intermediate | Memahami closure, table, metatable, dan OOP |
| Advanced | Menguasai coroutine, iterator, memory, dan runtime |
| Expert | Mampu membuat library, plugin, dan integrasi dengan C/C++ |

## Checklist Akhir

- [ ] Saya dapat membuat program Lua dari nol.
- [ ] Saya memahami seluruh tipe data dan operator.
- [ ] Saya dapat menggunakan function, scope, dan closure.
- [ ] Saya dapat mengelola data dengan table.
- [ ] Saya dapat membuat module dan package.
- [ ] Saya memahami metatable dan metamethod.
- [ ] Saya dapat membuat iterator dan coroutine.
- [ ] Saya memahami garbage collection dan memory management.
- [ ] Saya dapat membaca dan menulis file.
- [ ] Saya dapat menulis automated test.
- [ ] Saya dapat membuat package Lua.
- [ ] Saya dapat melakukan profiling dan optimasi.
- [ ] Saya memahami Lua C API.
- [ ] Saya dapat membuat plugin Neovim.

## Rekomendasi Fokus

Untuk menguasai Lua secara mendalam, berikan perhatian khusus pada konsep berikut:

1. **Table**: fondasi utama struktur data dan object di Lua.
2. **Function dan closure**: fondasi modularitas, callback, dan abstraction.
3. **Metatable**: fondasi operator overloading dan implementasi object system.
4. **Coroutine**: fondasi cooperative multitasking.
5. **Module system**: fondasi pengembangan aplikasi dan library.
6. **Memory management**: penting untuk aplikasi yang berjalan lama.
7. **Neovim API**: jalur praktik nyata untuk menerapkan Lua dalam pengembangan plugin.

Jangan menganggap selesai hanya karena seluruh checklist sudah dicentang. Ukur penguasaan dari kemampuan **membangun proyek sendiri, menjelaskan alasan desain, menulis test, membaca source code, dan memperbaiki masalah tanpa bergantung pada tutorial**.

---

## Penutup

Lua mungkin terlihat sederhana di permukaan, tetapi kekuatannya terletak pada **kombinasi sedikit konsep yang sangat fleksibel**: table, function, metatable, dan coroutine. Begitu kamu benar-benar menguasainya, kamu bisa membangun sistem objek, modul, iterator, hingga plugin dan engine scripting dengan perangkat yang sama.

> *"Cara terbaik untuk belajar bahasa pemrograman adalah dengan menulis program di dalamnya."* Mulailah dari Project 1 hari ini, lalu naik satu tingkat setiap kali kamu merasa nyaman.

Selamat belajar dan selamat berkarya! 🌙

---

### Referensi

- Lua: <https://www.lua.org/>
- Lua 5.4 Reference Manual: <https://www.lua.org/manual/5.4/>
- Programming in Lua: <https://www.lua.org/pil/>
- LuaRocks: <https://luarocks.org/>
- LuaJIT: <https://luajit.org/>
- Busted: <https://lunarmodules.github.io/busted/>
- Luacheck: <https://luacheck.readthedocs.io/>
- StyLua: <https://github.com/JohnnyMorganz/StyLua>
- Neovim Lua Guide: <https://neovim.io/doc/user/lua-guide.html>
- Neovim Lua Reference: <https://neovim.io/doc/user/lua.html>
- Neovim API: <https://neovim.io/doc/user/api.html>

{% endraw %}
