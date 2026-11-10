---
layout: post
title: "Fase 1 — Fundamental Go"
date: 2026-11-08 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, pemula, variabel, fungsi, control-flow]
permalink: /belajar-go/fase-1-fundamental-go/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Fundamental GO
---

# Fundamental Go

Fase ini adalah fondasi: struktur program, variabel, tipe data, operator,
input/output, control flow, dan fungsi. Kuasai fase ini sebelum lanjut —
semua materi berikutnya bertumpu di sini.

## Tujuan

- Memahami struktur file dan package Go.
- Mendeklarasikan variabel, konstanta, dan mengenal zero value.
- Mengenal tipe data dasar dan type conversion.
- Menggunakan operator dan control flow.
- Menulis fungsi: multiple return, variadic, closure, defer.

---

## 1. Struktur Program

### File Go

Setiap file Go berakhiran `.go` dan wajib deklarasikan package di baris pertama.

```go
package main

import "fmt"

// Komentar satu baris
/*
   Komentar blok
*/

func main() {
	fmt.Println("Halo dunia")
}
```

### Package

- **Package** = kumpulan file Go dalam satu folder dengan deklarasi `package` yang sama.
- Folder `strings/` berisi file-file dengan `package strings`.
- Nama package biasanya nama folder (kecuali folder `main`).

### `package main`

- `package main` khusus untuk **executable** (bukan library).
- Wajib memiliki fungsi `func main()`.
- Package lain (mis. `fmt`, `math`) adalah **library** — dipakai lewat `import`,
  tidak punya `main()`.

### Import

```go
import "fmt"              // import satu package
import (
	"fmt"
	"math/rand/v2"
)                          // import blok (disarankan)
```

### Exported dan unexported identifier

Aturan emas Go: **huruf awal menentukan visibilitas**.

```go
package util

var Nama = "exported"   // huruf besar → bisa diakses dari package lain: util.Nama
var nama = "unexported" // huruf kecil → hanya bisa dipakai di dalam package util

func ExportedFunc() {}   // bisa dipanggil util.ExportedFunc()
func unexportedFunc() {} // tidak bisa dipanggil dari luar
```

Tidak ada kata kunci `public`/`private` — cukup kapitalisasi.

### Naming convention Go

- **Package**: satu kata, huruf kecil, tanpa underline (`jsonutil`, bukan `JSONUtil`).
- **Variabel/parameter**: `camelCase` (`userName`, `maxRetry`).
- **Fungsi/method**: `camelCase` (`getUserByID`).
- **Exported**: `PascalCase` (`ParseConfig`).
- **Interface**: biasanya `-er` (`Reader`, `Stringer`).
- **SNAKE_CASE tidak dipakai** di Go (kecuali nama file/variabel di konvensi tertentu).
- Singkatan yang umum: `id`, `url`, `http`, `db` — jangan `iD`, `Url`, `Http`.

---

## 2. Variabel dan Tipe Data

### Deklarasi dengan `var`

```go
var umur int = 25
var nama string = "Budi"

// type inference
var tinggi = 170.5      // otomatis float64

// deklarasi blok
var (
	a int    = 1
	b string = "dua"
)
```

### Short declaration `:=`

Hanya berlaku **di dalam fungsi**, dan minimal satu variabel di kiri harus baru:

```go
func main() {
	x := 10          // int
	nama := "Andi"   // string
	x, y := 1, 2     // multiple assignment dengan variabel baru
	x = 20           // := bukan assignment biasa — pakai = untuk mengubah nilai
	_ = y            // _ = blank identifier, membuang nilai
}
```

> **⚠️ Jebakan:** `:=` di luar fungsi tidak valid, dan `x := 5` akan error jika
> `x` sudah dideklarasikan dan tidak ada variabel baru di kiri.

### Konstanta dengan `const`

```go
const Pi = 3.14159
const AppName = "belajar-go"

const (
	StatusOK    = 200
	StatusError = 500
)
```

Konstanta harus bisa dievaluasi saat kompilasi (tidak bisa `const x = os.Getenv(...)`,
itu harus `var`).

### Zero value

Setiap tipe punya nilai awal bila tidak diinisialisasi — **tidak ada variabel "uninitialized"**:

| Tipe | Zero value |
|------|-----------|
| `int`, `int64`, dll. | `0` |
| `float32/64` | `0.0` |
| `bool` | `false` |
| `string` | `""` (string kosong) |
| pointer, slice, map, chan, func, interface | `nil` |
| struct | nilai per field-nya (recursive) |

```go
var umur int
fmt.Println(umur) // 0
var aktif bool
fmt.Println(aktif) // false
```

### Tipe data dasar

```go
// Bilangan bulat
var a int = 42          // platform-dependent (32/64 bit)
var b int8 = 127
var c int16 = 32767
var d int32 = 2147483647
var e int64 = 9223372036854775807

// Bilangan tanpa tanda (unsigned)
var f uint = 42
var g uint8 = 255        // alias: byte
var h uint16 = 65535
var i uint32 = 4294967295
var j uint64 = 18446744073709551615

// Floating point
var k float32 = 3.14     // presisi ~6-7 digit
var l float64 = 3.141592653589793 // presisi ~15 digit (default)

// Boolean dan string
var m bool = true
var n string = "halo"

// byte dan rune
var o byte = 65        // alias uint8 — 1 byte, untuk data biner/ASCII
var p rune = 'A'       // alias int32 — 1 karakter Unicode (code point)
```

**Kapan pakai `byte` vs `rune`:**

```go
s := "Golang"

// byte → bekerja pada ASCII/UTF-8 mentah
for i := 0; i < len(s); i++ {
	fmt.Printf("%d ", s[i]) // 71 111 108 97 110 103 (byte UTF-8)
}
fmt.Println()

// rune → bekerja pada karakter Unicode
for _, r := range s {
	fmt.Printf("%c ", r) // G o l a n g
}

emoji := "🎉"
fmt.Println(len(emoji)) // 4 panjang dalam BYTE (UTF-8 4 byte)
fmt.Println(len([]rune(emoji))) // 1 panjang dalam KARAKTER
```

### Type conversion (bukan coercion)

Go **tidak melakukan implicit conversion**. Harus eksplisit:

```go
var i int = 42
var f float64 = float64(i)  // wajib
var u uint = uint(i)
```

```go
// float → int membuang bagian desimal (bukan rounding!)
var pi float64 = 3.99
n := int(pi) // 3
```

**String ↔ number** memerlukan package `strconv`:

```go
import "strconv"

s := strconv.Itoa(99)          // "99"
num, err := strconv.Atoi("99") // 99, nil
```

### Multiple assignment

```go
a, b := 1, 2
a, b = b, a      // tukar nilai tanpa variabel sementara

// nilai dari fungsi juga bisa
x, y := someFunc()
```

### `iota`

`iota` adalah counter konstanta yang bertambah otomatis di dalam blok `const`:

```go
type Direction int

const (
	North Direction = iota // 0
	South                   // 1
	East                    // 2
	West                    // 3
)

// Pola umum: bit flag
const (
	FlagRead    = 1 << iota // 1  (0001)
	FlagWrite               // 2  (0010)
	FlagExecute             // 4  (0100)
)

// Pola umum: skip nilai
const (
	_  = iota // 0 (dibuang)
	KB = 1 << (10 * iota) // 1 << 10 = 1024
	MB                     // 1 << 20
	GB                     // 1 << 30
)
```

---

## 3. Operator

```text
// Aritmatika
+  -  *  /  %
a++  // statement, BUKAN expression (a++ tidak bisa dipakai sebagai nilai)
a--

// Perbandingan
==  !=  <  >  <=  >=

// Logika (short-circuit)
&&  ||  !

// Assignment
=  +=  -=  *=  /=  %=

// Bitwise
&  |  ^  &^  <<  >>
```

```go
fmt.Println(7 / 2)    // 3 — pembulatan ke bawah untuk integer
fmt.Println(7.0 / 2)  // 3.5
fmt.Println(-7 % 2)   // -1 — tanda hasil mengikuti operand kiri

fmt.Println(true && false) // false
fmt.Println(true || false) // true

a := 0b1010 // 10
b := 0b0110 // 6
fmt.Println(a & b)  // 2  (0010)
fmt.Println(a | b)  // 14 (1110)
fmt.Println(a ^ b)  // 12 (1100)
fmt.Println(a << 2) // 40 (101000)
fmt.Println(a >> 1) // 5  (101)
```

> **⚠️** `++` dan `--` adalah **statement** di Go, bukan expression.
> `y := x++` tidak valid.

---

## 4. Input dan Output

### Output

```go
import "fmt"

fmt.Print("tanpa newline")     // tanpa baris baru
fmt.Println("dengan newline")  // + \n
fmt.Printf("nilai: %d\n", 42)  // format string
```

**Format specifier** yang paling sering dipakai:

| Spec | Untuk |
|------|-------|
| `%v` | nilai apapun (default) |
| `%+v` | struct dengan nama field |
| `%#v` | representasi Go-syntax |
| `%T` | tipe data |
| `%d` | integer |
| `%f` | float (`%.2f` untuk 2 desimal) |
| `%t` | boolean |
| `%s` | string |
| `%c` | karakter (rune) |
| `%p` | alamat pointer |
| `%%` | literal `%` |

```go
type User struct {
	Name string
	Age  int
}

u := User{"Budi", 30}
fmt.Printf("%v\n", u)   // {Budi 30}
fmt.Printf("%+v\n", u)  // {Name:Budi Age:30}
fmt.Printf("%T\n", u)   // main.User
fmt.Printf("Halo %s, umur %d\n", u.Name, u.Age)
fmt.Printf("%08.2f\n", 3.14159) // 0003.14
```

### Input

```go
// cara sederhana
var nama string
var umur int
fmt.Print("Nama: ")
fmt.Scan(&nama)
fmt.Print("Umur: ")
fmt.Scan(&umur)
fmt.Printf("Halo %s, umur %d\n", nama, umur)

// Scanln: berhenti di newline, memisahkan input dengan spasi
var a, b int
fmt.Scanln(&a, &b)
```

### `bufio` — input yang lebih fleksibel

`fmt.Scan` terbatas (tidak menangani spasi dengan baik untuk satu baris utuh).
Untuk input yang lebih kontrol, pakai `bufio`:

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Masukkan nama: ")
	nama, _ := reader.ReadString('\n') // baca sampai newline
	nama = strings.TrimSpace(nama)      // buang \n
	fmt.Println("Halo,", nama)

	scanner := bufio.NewScanner(os.Stdin)
	fmt.Print("Masukkan kata: ")
	scanner.Scan()
	kata := scanner.Text()
	fmt.Println("Kata:", kata)
}
```

---

## 5. Control Flow

### `if` — tanpa kurung, dengan statement inisialisasi

```go
if umur := 20; umur >= 17 {
	fmt.Println("dewasa")
} else if umur >= 13 {
	fmt.Println("remaja")
} else {
	fmt.Println("anak-anak")
}
```

Perbedaan dengan bahasa lain: Go **tidak memakai kurung** untuk kondisi, dan
`if` bisa diawali **statement inisialisasi** yang scope-nya hanya di blok `if`.

```go
if err := doSomething(); err != nil {
	return err
} // err tidak terlihat di sini
```

### `switch` — tanpa `break` otomatis, bisa tanpa expression

```go
// switch pada nilai
switch hari := "senin"; hari {
case "senin", "selasa":
	fmt.Println("hari kerja awal")
case "jumat":
	fmt.Println("hari jumat")
default:
	fmt.Println("lainnya")
}

// switch tanpa expression = if-else chain
switch {
case umur < 13:
	fmt.Println("anak")
case umur < 18:
	fmt.Println("remaja")
default:
	fmt.Println("dewasa")
}

// fallthrough — lanjut ke case berikutnya (harus eksplisit)
switch n {
case 0:
	fmt.Println("nol")
	fallthrough
case 1:
	fmt.Println("satu atau nol")
}
```

> **⚠️** Tidak ada *implicit fallthrough* — setelah case cocok, switch berhenti.
> Tidak perlu `break` di akhir case.

### `for` — satu-satunya loop di Go

```go
// 1. for klasik
for i := 0; i < 5; i++ {
	fmt.Println(i)
}

// 2. while-style
for kondisi {
	// ...
}

// 3. infinite loop
for {
	// pakai break untuk keluar
	break
}

// 4. for dengan range (lihat di bawah)
```

> **⚠️** Go tidak punya `while` dan `do-while`. `for` adalah loop tunggal.

### `break` dan `continue`

```go
for i := 0; i < 10; i++ {
	if i%2 == 0 {
		continue // lewati genap
	}
	if i > 7 {
		break // keluar dari loop
	}
	fmt.Println(i)
}
```

**Labeled break/continue** untuk keluar dari loop bersarang:

```
outer:
	for i := 0; i < 3; i++ {
		for j := 0; j < 3; j++ {
			if j == 2 {
				break outer // keluar dari KEDUA loop
			}
		}
	}
```

### `range`

```go
// slice/array
for i, v := range []string{"a", "b", "c"} {
	fmt.Println(i, v) // 0 a, 1 b, 2 c
}

// string → rune Unicode (bukan byte!)
for i, r := range "Golang" {
	fmt.Println(i, r)
}

// map (urutan TIDAK dijamin)
for k, v := range map[string]int{"a": 1, "b": 2} {
	fmt.Println(k, v)
}
```

Gunakan `_` bila tidak memakai salah satu nilai: `for _, v := range xs`.

### `goto` (sekadar pengenal)

```go
// goto umumnya dihindari dalam kode sehari-hari.
// Penggunaan wajar: jumping ke label cleanup di code pendek.
i := 0
loop:
	if i < 3 {
		i++
		goto loop
	}
```

> **⚠️** `goto` tidak boleh melompati deklarasi variabel.
> Dalam praktik, hampir selalu ada solusi lebih baik (`break` berlabel, fungsi terpisah).

---

## 6. Fungsi

### Deklarasi dasar

```go
func tambah(a, b int) int {
	return a + b
}

func sapa(nama string) {
	fmt.Println("Halo,", nama)
}
```

- Parameter dengan tipe yang sama bisa digabung: `func f(a, b int)`.
- Tidak ada *overloading* — satu nama fungsi, satu implementasi.
- Fungsi tanpa `return` mengembalikan "nothing".

### Multiple return values

```go
func bagi(a, b int) (int, error) {
	if b == 0 {
		return 0, errors.New("pembagian dengan nol")
	}
	return a / b, nil
}

hasil, err := bagi(10, 2)
if err != nil {
	// tangani error
}
_ = hasil
```

Pola **comma-ok** sangat umum di Go:

```go
v, ok := m["key"]   // map lookup
v, ok := i.(Type)   // type assertion
```

### Named return values

```go
func hitung(a, b int) (hasil int, err error) {
	if b == 0 {
		err = errors.New("nol")
		return // naked return — mengembalikan nilai saat ini
	}
	hasil = a * b
	return
}
```

> **Catatan:** *naked return* hanya disarankan untuk fungsi pendek.
> Pada fungsi panjang, `return hasil` lebih jelas.

### Variadic function

```go
func jumlah(values ...int) int { // ...int = slice of int
	total := 0
	for _, v := range values {
		total += v
	}
	return total
}

fmt.Println(jumlah(1, 2, 3)) // 6
nums := []int{4, 5, 6}
fmt.Println(jumlah(nums...)) // 15 — unpack slice
```

Hanya boleh **satu** parameter variadic, dan harus terakhir.

### Function sebagai value

```go
func kuadrat(n int) int { return n * n }

func terapkan(fn func(int) int, nilai int) int {
	return fn(nilai)
}

fmt.Println(terapkan(kuadrat, 5)) // 25
fmt.Println(terapkan(func(n int) int { return n * 2 }, 5)) // 10
```

### Anonymous function dan closure

```go
// anonymous function langsung dipanggil
func() {
	fmt.Println("saya langsung jalan")
}()

// closure: fungsi yang "mengingat" variabel di sekitarnya
func counter() func() int {
	n := 0
	return func() int {
		n++ // n hidup selama closure dipakai
		return n
	}
}

c := counter()
fmt.Println(c()) // 1
fmt.Println(c()) // 2
```

> **⚠️ Jebakan loop klasik:**
>
> ```go
> for i := 0; i < 3; i++ {
> 	funcs = append(funcs, func() { fmt.Println(i) })
> }
> // semua closure mencetak 3 — karena i adalah variabel yang sama
> ```
>
> Solusi: `i := i` di dalam loop untuk membuat variabel baru tiap iterasi.

### `defer`

`defer` menunda pemanggilan fungsi sampai **fungsi sekitarnya selesai**,
dijalankan LIFO (terakhir dipanggil, pertama dieksekusi):

```go
func bacaFile() {
	f, err := os.Open("data.txt")
	if err != nil {
		return
	}
	defer f.Close() // dijalankan saat fungsi selesai, walau ada return di tengah

	// ... proses file
}
```

**Urutan evalusi argumen vs eksekusi:**

```go
func main() {
	x := 10
	defer fmt.Println("defer:", x) // argumen dievaluasi SEKARANG → 10
	x = 99
	fmt.Println("main:", x) // 99
}
// output:
// main: 99
// defer: 10
```

**Penggunaan `defer` yang umum:**

```go
// 1. resource cleanup
defer mu.Unlock()
defer resp.Body.Close()

// 2. logging durasi
defer func() {
	fmt.Printf("fungsi berjalan %v\n", time.Since(start))
}()

// 3. recover dari panic (dibahas lebih lanjut di fase berikutnya)
defer func() {
	if r := recover(); r != nil {
		log.Println("panic tertangkap:", r)
	}
}()
```

> **⚠️** `defer` tidak boleh dalam loop dengan banyak iterasi (menumpuk fungsi
> yang belum dieksekusi). Dan `defer` dijalankan setelah fungsi selesai —
> tidak menunda sampai akhir program.

---

## Latihan Fundamental

Kerjakan latihan berikut tanpa melihat solusi terlebih dahulu.

### 1. Kalkulator sederhana

Program membaca dua angka dan operator (`+ - * /`), lalu mencetak hasil.
Tangani pembagian dengan nol.

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	var a float64
	var op string
	var b float64

	fmt.Print("Masukkan a, op, b (contoh: 8 * 3): ")
	_, err := fmt.Scan(&a, &op, &b)
	if err != nil {
		fmt.Println("Input tidak valid")
		os.Exit(1)
	}

	var hasil float64
	switch op {
	case "+":
		hasil = a + b
	case "-":
		hasil = a - b
	case "*":
		hasil = a * b
	case "/":
		if b == 0 {
			fmt.Println("Pembagian dengan nol tidak diizinkan")
			return
		}
		hasil = a / b
	default:
		fmt.Println("Operator tidak dikenal:", op)
		return
	}
	fmt.Printf("%g %s %g = %g\n", a, op, b, hasil)
}
```

### 2. Konversi suhu

```go
func celsiusKeFahrenheit(c float64) float64 { return c*9/5 + 32 }
func fahrenheitKeCelsius(f float64) float64 { return (f - 32) * 5 / 9 }
func celsiusKeKelvin(c float64) float64     { return c + 273.15 }
```

Buat menu: pilih konversi, masukkan nilai, cetak hasil.

### 3. Ganjil / genap

```go
func ganjilGenap(n int) string {
	if n%2 == 0 {
		return "genap"
	}
	return "ganjil"
}
```

### 4. Faktorial

```go
func faktorial(n int) int {
	if n <= 1 {
		return 1
	}
	return n * faktorial(n-1)
}
```

Perhatikan bahwa `faktorial(0) = 1` dan negatif harus ditangani.

### 5. Bilangan prima

```go
func prima(n int) bool {
	if n < 2 {
		return false
	}
	if n%2 == 0 {
		return n == 2
	}
	for i := 3; i*i <= n; i += 2 {
		if n%i == 0 {
			return false
		}
	}
	return true
}
```

### 6. Pola dengan loop

```
*
**
***
****
*****
```

```go
for i := 1; i <= 5; i++ {
	fmt.Println(strings.Repeat("*", i))
}
```

Coba juga pola terbalik, pola piramida, dan pola angka.

### 7. Menu program berbasis terminal

Gabungkan semua: tampilkan menu (`1. Kalkulator`, `2. Konversi suhu`,
`3. Cek prima`, `0. Keluar`) menggunakan `for` + `switch` sampai user memilih keluar.

```go
for {
	fmt.Println("\n=== MENU ===")
	fmt.Println("1. Kalkulator")
	fmt.Println("2. Konversi suhu")
	fmt.Println("3. Cek prima")
	fmt.Println("0. Keluar")
	fmt.Print("Pilihan: ")

	var pilihan int
	fmt.Scan(&pilihan)

	switch pilihan {
	case 1:
		// ...
	case 2:
		// ...
	case 3:
		// ...
	case 0:
		fmt.Println("Sampai jumpa!")
		return
	default:
		fmt.Println("Pilihan tidak valid")
	}
}
```

---

## Checklist Fase 1

- [x] Struktur file Go, package, `package main`, `main()`, import, komentar.
- [x] Exported/unexported identifier dan naming convention.
- [x] Deklarasi `var`, short declaration `:=`, `const`, zero value.
- [x] Tipe data dasar: integer, unsigned, float, bool, string, byte, rune.
- [x] Type conversion, multiple assignment, `iota`.
- [x] Operator aritmatika, perbandingan, logika, assignment, bitwise, `++`/`--`.
- [x] `fmt.Print`, `Println`, `Printf`, format specifier, `fmt.Scan`, `bufio`.
- [x] `if`, `switch`, `for`, `range`, `break`, `continue`, `goto`.
- [x] Fungsi: parameter, return, multiple return, named return, variadic.
- [x] Function sebagai value, anonymous function, closure, `defer`.
- [x] Latihan: kalkulator, konversi suhu, ganjil/genap, faktorial, prima, pola, menu.

## Ringkasan

- Huruf besar = exported (visibel dari package lain).
- Zero value menghilangkan masalah "variabel tidak terinisialisasi".
- Go tidak melakukan implicit conversion — selalu eksplisit.
- `for` adalah satu-satunya loop; `switch` tidak jatuh otomatis ke case berikutnya.
- Multiple return (terutama `(value, error)`) adalah idiom inti Go.
- `defer` untuk cleanup, dengan argumen yang dievaluasi saat `defer` ditulis.

---

Lanjut ke: [Fase 2 — Struktur Data dan Tipe Go]({{ site.baseurl }}/belajar-go/fase-2-struktur-data/)
