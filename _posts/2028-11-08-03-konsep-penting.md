---
layout: post
title: "Fase 3 — Konsep Go yang Penting"
date: 2026-11-10 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, interface, error-handling, generics, package]
permalink: /belajar-go/fase-3-konsep-penting/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Konsep Go yang Penting
---

# Konsep Go yang Penting

Fase ini membahas empat pilar Go: **interface**, **error handling**,
**generics**, dan **package/module** — plus standard library yang wajib dikenal.

## Tujuan

- Memahami interface dan implementasi implicit.
- Menangani error secara idiomatis (`errors.Is`, `errors.As`, wrapping).
- Menulis generic function dan type dengan constraint.
- Mengatur package, module, dan dependency.
- Mengenal stdlib inti.

---

## 1. Interface

Interface mendefinisikan **kontrak perilaku** (kumpulan method) tanpa peduli
tipe konkretnya.

### Deklarasi dan implementasi implicit

```go
type Pengguna interface {
	Sapa() string
	Detail() string
}

// Tidak ada kata kunci "implements" — cukup implementasi semua method-nya
type Manusia struct{ Nama string }

func (m Manusia) Sapa() string   { return "Halo, " + m.Nama }
func (m Manusia) Detail() string { return "Manusia: " + m.Nama }

type Robot struct{ ID string }

func (r Robot) Sapa() string   { return "Beep boop" }
func (r Robot) Detail() string { return "Robot: " + r.ID }

// Keduanya kini memenuhi interface Pengguna
func Perkenalan(p Pengguna) {
	fmt.Println(p.Sapa())
}

func main() {
	Perkenalan(Manusia{"Budi"})  // Halo, Budi
	Perkenalan(Robot{"R2"})      // Beep boop
}
```

### Interface kecil dan fokus

Go menganut prinsip **interface kecil**. Lihat `io.Reader` di stdlib:

```go
type Reader interface {
	Read(p []byte) (n int, err error)
}
```

Satu method! Karena kecil, banyak tipe yang bisa memenuhinya tanpa beban.

```go
// Konvensi penamaan: -er untuk satu method
type Stringer interface {
	String() string
}
```

> **Aturan:** deklarasikan interface di **sisi konsumen** (yang memakai),
> bukan di sisi implementer. Interface kecil lebih mudah dipenuhi dan diuji.

### Interface sebagai parameter dan return value

```go
// parameter: menerima tipe apapun yang memenuhi kontrak
func Salin(dst io.Writer, src io.Reader) (int64, error) {
	return io.Copy(dst, src)
}

// return value: menyembunyikan tipe konkret
func BukaKoneksi(cfg Config) (io.Closer, error) {
	// ...
}
```

### `any` / `interface{}`

```go
// any = alias untuk interface{} — tanpa method
func Cetak(v any) {
	fmt.Printf("%v (%T)\n", v, v)
}

Cetak(42)        // 42 (int)
Cetak("halo")    // halo (string)
```

`any` dipakai saat tipe benar-benar tidak diketahui (mis. data JSON dinamis).
Gunakan seperlunya — interface tipis tetap lebih baik.

### Type assertion

```go
var i any = "halo"

// cara 1: panic bila salah tipe
s := i.(string)

// cara 2: comma-ok — TIDAK panik (disarankan)
s, ok := i.(string)
if ok {
	fmt.Println(s)
}

// ❌ panic — i bukan int
// n := i.(int)
```

### Type switch

```go
func Describe(v any) string {
	switch t := v.(type) {
	case int:
		return fmt.Sprintf("int: %d", t)
	case string:
		return fmt.Sprintf("string: %q", t)
	case bool:
		return fmt.Sprintf("bool: %v", t)
	case nil:
		return "nil"
	default:
		return fmt.Sprintf("tipe lain: %T", t)
	}
}
```

> **⚠️** `t` di dalam tiap case bertipe sesuai case tersebut — periksa kebenarannya
> dengan `ok` bila ragu.

### Nilai nil pada interface dan *typed nil*

Ini salah satu jebakan paling sering di Go:

```go
func CetakError(err error) {
	if err == nil {              // ❌ belum tentu benar!
		fmt.Println("tidak ada error")
		return
	}
	fmt.Println("error:", err)
}

func GetError() error {
	var p *MyError = nil
	return p // mengembalikan interface yang TIDAK nil, tapi isinya nil pointer
}

err := GetError()
if err == nil {   // FALSE — err != nil karena tipenya *MyError
	fmt.Println("tidak ada error")   // tidak dieksekusi!
}
// err.(*MyError) == nil → typed nil
```

**Penyebab:** interface punya dua bagian — **(tipe, nilai)**. Interface dianggap
`nil` hanya jika **keduanya** nil. Mengembalikan pointer nil dari fungsi yang
mengembalikan `error` membuat interface-nya non-nil.

**Solusi:**

```go
func GetError() error {
	var p *MyError
	if false {
		p = &MyError{} // pointer non-nil
	}
	return p // tetap bermasalah...

	// ✅ benar: return nil eksplisit saat tidak ada error
	if !adaError {
		return nil
	}
	return p
}
```

> **Aturan emas:** fungsi yang mengembalikan `error` harus mengembalikan
> `nil` (bukan typed nil) saat tidak ada error. Untuk pointer internal,
> tambahkan pemeriksaan eksplisit di dalam fungsi sebelum mengembalikannya.

### Interface composition

```go
type Reader interface { Read(p []byte) (n int, err error) }
type Writer interface { Write(p []byte) (n int, err error) }

// menggabungkan interface
type ReadWriter interface {
	Reader
	Writer
}
```

### Kapan memakai interface (dan kapan tidak)

**Pakai ketika:**

- Perlu menukar implementasi (mis. `os.File` vs buffer untuk testing).
- Polimorfisme: banyak tipe dengan perilaku serupa.
- Memotong dependensi antar package.

**Jangan pakai ketika:**

- Hanya ada satu implementasi (interface premature = kompleksitas gratis).
- Sekadar untuk "pola desain" tanpa kebutuhan nyata.
- Tipe-nya dipakai internal package (buka saat benar-benar perlu).

```go
// ❌ overengineering: interface dengan satu implementasi
type UserStore interface { Get(id int) User }
type userStore struct{}
func (s userStore) Get(id int) User { ... }

// ✅ pakai struct langsung dulu; abstraksi saat muncul kebutuhan kedua
type userStore struct{}
```

---

## 2. Error Handling

Di Go, **error adalah value biasa** — bukan exception.

### Bentuk dasar

```go
import (
	"errors"
	"fmt"
)

// error adalah interface dengan satu method
type error interface {
	Error() string
}

// membuat error
var ErrNotFound = errors.New("tidak ditemukan")

// dengan formatting
func BacaConfig(path string) ([]byte, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("baca config %q: %w", path, err)
	}
	return data, nil
}
```

### Pola penanganan error yang idiomatis

```go
data, err := os.ReadFile("config.json")
if err != nil {
	return fmt.Errorf("baca config: %w", err) // wrapping + konteks
}
// lanjut tanpa perlu else
```

> **Gaya Go:** `if err != nil { return ... }` lalu lanjut. Hindari nested
> `if err == nil { ... } else { ... }` — code akan menjorok terlalu dalam.

### Error wrapping dengan `%w`

`fmt.Errorf` dengan `%w` menyimpan error asli sehingga bisa diperiksa:

```go
func Proses() error {
	err := BukaFile("data.txt")
	if err != nil {
		return fmt.Errorf("proses: %w", err) // rantai error
	}
	return nil
}
```

Rantai error bisa **diperiksa** dengan `errors.Is` dan **diekstrak** dengan `errors.As`.

### `errors.Is` — membandingkan error (identity)

```go
var ErrTimeout = errors.New("timeout")

func Request() error { return ErrTimeout }

err := Request()
if errors.Is(err, ErrTimeout) {
	fmt.Println("request timeout")
}
```

Bekerja juga melalui rantai wrapping:

```go
err := fmt.Errorf("lapisan atas: %w", fmt.Errorf("lapisan tengah: %w", ErrTimeout))
fmt.Println(errors.Is(err, ErrTimeout)) // true
```

### `errors.As` — mengekstrak tipe error

```go
type ValidationError struct {
	Field   string
	Message string
}

func (e *ValidationError) Error() string {
	return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

// ...

var ve *ValidationError
if errors.As(err, &ve) {
	fmt.Println("field bermasalah:", ve.Field)
}
```

> **⚠️** Argument kedua `errors.As` harus berupa **pointer ke tipe error**
> (`*ValidationError`), karena nilainya akan diisi.

### Custom error type

```go
type HTTPError struct {
	Code    int
	Message string
}

func (e *HTTPError) Error() string {
	return fmt.Sprintf("http %d: %s", e.Code, e.Message)
}

// pemakaian
func AmbilUser(id int) (*User, error) {
	resp, err := http.Get(fmt.Sprintf("/users/%d", id))
	if err != nil {
		return nil, err
	}
	if resp.StatusCode == 404 {
		return nil, &HTTPError{Code: 404, Message: "user tidak ada"}
	}
	// ...
}
```

### Error sentinel

Sentinel = error yang dibuat sekali sebagai `var Err...` dan diperiksa dengan `errors.Is`:

```go
var (
	ErrNotFound     = errors.New("not found")
	ErrUnauthorized = errors.New("unauthorized")
)

func Hapus(id int) error {
	if !ada(id) {
		return ErrNotFound
	}
	return nil
}

// konsumen
if errors.Is(err, ErrNotFound) {
	w.WriteHeader(http.StatusNotFound)
	return
}
```

**⚠️ Sentinel dibuat dengan `errors.New`, bukan `fmt.Errorf` (tanpa `%w`) —
agar identitasnya stabil untuk `errors.Is`.**

### Strategi error pada aplikasi

1. **Tambahkan konteks** saat error naik lapisan: `fmt.Errorf("baca user %d: %w", id, err)`.
2. **Jangan tahan error** — tangani atau teruskan.
3. **Jangan log lalu return** — biarkan caller yang memutuskan (atau log sekali di lapisan atas).
4. **Bandingkan dengan `errors.Is`**, bukan `err == ErrX` (karena wrapping).
5. **Return error terakhir yang bermakna** — jangan menelan error.
6. Untuk error yang akan ditampilkan ke user, pisahkan **error teknis** vs **error domain**.

```go
// ✅ contoh lengkap
func (s *Service) Ambil(ctx context.Context, id string) (*User, error) {
	u, err := s.repo.Get(ctx, id)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			return nil, fmt.Errorf("ambil user %s: %w", id, ErrNotFound)
		}
		return nil, fmt.Errorf("ambil user %s: %w", id, err)
	}
	return u, nil
}
```

---

## 3. Generics (Go 1.18+)

Generics memungkinkan fungsi/tipe bekerja dengan beberapa tipe tanpa kehilangan
type safety.

### Generic function

```go
func Max[T constraints.Ordered](a, b T) T {
	if a > b {
		return a
	}
	return b
}

fmt.Println(Max(10, 20))       // 20 (int)
fmt.Println(Max(3.14, 2.71))   // 3.14 (float64)
fmt.Println(Max("a", "b"))     // b (string)
```

### Type parameter dan type inference

```go
// eksplisit
result := Max[int](10, 20)

// inference — biasanya tidak perlu menulis [int]
result := Max(10, 20)

// multiple type parameter
func Merge[T any](a, b []T) []T {
	return append(append([]T{}, a...), b...)
}
```

### Generic type

```go
// stack generik
type Stack[T any] struct {
	items []T
}

func (s *Stack[T]) Push(v T) {
	s.items = append(s.items, v)
}

func (s *Stack[T]) Pop() (T, bool) {
	if len(s.items) == 0 {
		var zero T
		return zero, false
	}
	v := s.items[len(s.items)-1]
	s.items = s.items[:len(s.items)-1]
	return v, true
}

// pemakaian
var angka Stack[int]
angka.Push(1)

var nama Stack[string]
nama.Push("budi")
```

### Type constraint

Constraint mendefinisikan tipe mana yang boleh dipakai.

```go
// built-in: comparable — untuk tipe yang bisa == dan !=
func Cari[T comparable](xs []T, target T) int {
	for i, v := range xs {
		if v == target {
			return i
		}
	}
	return -1
}

Cari([]int{1, 2, 3}, 2)    // ✅
// Cari([]map[string]int{...}, m) // ❌ map tidak comparable
```

**Constraint adalah interface:**

```go
import "golang.org/x/exp/constraints"

// constraint umum (sekarang banyak di stdlib: cmp, slices)
type Number interface {
	~int | ~int8 | ~int16 | ~int32 | ~int64 |
		~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 |
		~float32 | ~float64
}

func Jumlah[T Number](xs []T) T {
	var total T
	for _, v := range xs {
		total += v
	}
	return total
}
```

### Union constraint (`|`) dan underlying type (`~`)

```go
// union: tipe yang diizinkan dipisah |
type StringOrInt interface {
	string | int
}

// ~T berarti "tipe yang underlying-nya T" — termasuk type alias baru
type Celsius float64

// ~float64 mengizinkan Celsius dan float64
func Panas[T ~float64](c T) T { return c + 10 }
```

> **⚠️** Tanpa `~`, `Celsius` tidak akan lolos constraint `float64` karena
> tipe namanya berbeda meski underlying sama.

### Kapan generics berguna

- Koleksi generik (stack, queue, set, cache).
- Fungsi utilitas yang bekerja pada banyak tipe: `slices.Contains`, `maps.Clone`.
- Menghilangkan duplikasi kode yang hanya beda tipe.

```go
// tanpa generics — duplikat
func SumInt(xs []int) int { ... }
func SumFloat(xs []float64) float64 { ... }

// dengan generics — satu fungsi
func Sum[T Number](xs []T) T { ... }
```

### Menghindari generics berlebihan

```go
// ❌ tidak perlu — hanya satu tipe yang masuk akal
func Tambah(a, b int) int

// ❌ interface biasa sudah cukup bila hanya butuh method
func Proses(r io.Reader) error

// ✅ generics tepat: tipe beragam + logika sama + tetap type-safe
func Filter[T any](xs []T, fn func(T) bool) []T { ... }
```

> **Catatan:** setiap `any` yang kamu hilangkan lewat generics adalah runtime
> type assertion yang tidak perlu. Tapi generics juga bisa mempersulit pembacaan
> kode — pakai saat ada keuntungan nyata.

---

## 4. Package dan Module

### Membuat package sendiri

```
project/
├── go.mod
├── main.go
└── util/
    ├── util.go       // package util
    └── util_test.go
```

```go
// file: util/util.go
package util

// Exported — bisa dipakai dari luar
func Sapa(nama string) string {
	return "Halo, " + nama
}

// unexported
func rahasia() {}
```

```go
// file: main.go
package main

import (
	"fmt"

	"belajar-go/util"
)

func main() {
	fmt.Println(util.Sapa("Budi")) // ✅
	// util.rahasia()               // ❌ unexported
}
```

### Visibility

- `func Sapa` → publik (`util.Sapa`).
- `func sapadi` → privasi (hanya dalam package `util`).
- Berlaku untuk tipe, variabel, method, dan konstanta.
- Satu package = satu folder. Banyak file dalam folder itu adalah **satu package**.

### Circular dependency dilarang

```
package A import B
package B import A
→ compile error: import cycle not allowed
```

**Solusi:**

1. Pindahkan kode yang dipakai bersama ke package ketiga.
2. Gunakan interface di sisi consumer untuk memutus siklus.
3. Refleksikan: seringnya ada masalah desain yang lebih dalam.

### Go module dan `go.mod`

```bash
go mod init myapp
go mod tidy      # tambah/hapus dependency sesuai import
go get github.com/joho/godotenv@v1.5.1
go mod download  # unduh semua dependency
```

`go.mod`:

```
module myapp

go 1.27

require (
	github.com/joho/godotenv v1.5.1
)
```

`go.sum` berisi **checksum hash** tiap versi dependency — memastikan dependency
tidak diubah orang lain. **Jangan diedit manual, jangan dihapus.**

### Versioning dependency

Go memakai **Semantic Import Versioning**:

- v0.x.x dan v1.x.x → path tanpa suffix (`github.com/go-sql-driver/mysql`)
- v2+ → suffix `/v2` (`github.com/foo/bar/v2`)

```bash
go get github.com/foo/bar@v1.2.3   # pilih versi
go get github.com/foo/bar@latest   # versi stabil terbaru
go get github.com/foo/bar@main     # langsung ke branch main (hindari di production)
```

### Struktur package yang sederhana

```
myapp/
├── go.mod
├── cmd/
│   └── server/
│       └── main.go        # titik masuk (executable)
├── internal/
│   ├── handler/           # HTTP handler
│   ├── service/           # business logic
│   └── repo/              # akses database
├── pkg/                   # library publik (hanya jika benar-benar dipakai luas)
└── configs/
```

- **`cmd/`** — binary yang di-build.
- **`internal/`** — tidak bisa di-import package lain di luar module ini.
- **`pkg/`** — hanya jika kamu memang mendistribusikan library.

> **⚠️** Jangan terburu-buru membuat banyak folder. Struktur harus mengikuti
> kebutuhan — bukan sebaliknya. Mulai sederhana, refactor saat tumbuh.

---

## 5. Standard Library yang Perlu Dikenal

Berikut peta singkat stdlib — semua tersedia tanpa dependensi eksternal.

| Package | Fungsi | Contoh singkat |
|---------|--------|----------------|
| `fmt` | Format I/O | `Printf`, `Sprintf`, `Errorf` |
| `strings` | Operasi string | `Contains`, `Split`, `TrimSpace`, `Builder` |
| `strconv` | String ↔ number | `Atoi`, `Itoa`, `ParseFloat` |
| `math` | Matematika | `Sqrt`, `Ceil`, `Abs`, konstanta `math.Pi` |
| `math/rand/v2` | Random | `rand.IntN(100)`, `rand.Float64()` |
| `time` | Waktu & durasi | `Now`, `Since`, `After`, `Parse` |
| `sort` | Pengurutan | `Sort`, `Slice`, `Search` |
| `slices` | Operasi slice generik | `Contains`, `Sort`, `Compact`, `Index` |
| `maps` | Operasi map generik | `Keys`, `Clone`, `Equal` |
| `os` | Akses OS | `ReadFile`, `Getenv`, `Exit`, `Args` |
| `io` | I/O antarmuka | `Copy`, `Reader`, `Writer`, `EOF` |
| `bufio` | Buffered I/O | `NewScanner`, `NewReader` |
| `path/filepath` | Path | `Join`, `Split`, `Abs` |
| `encoding/json` | JSON | `Marshal`, `Unmarshal` |
| `encoding/csv` | CSV | `Reader`, `Writer` |
| `log` | Logging sederhana | `Printf`, `Fatal` |
| `log/slog` | Structured logging | `Info`, `With`, handler JSON |

### Contoh penggunaan umum

```go
// strings
s := "  Halo, Go  "
fmt.Println(strings.TrimSpace(s))          // "Halo, Go"
fmt.Println(strings.Contains(s, "Go"))     // true
parts := strings.Split("a,b,c", ",")       // [a b c]

// strconv
n, err := strconv.Atoi("42")               // 42, nil
s := strconv.FormatFloat(3.14, 'f', 2, 64) // "3.14"

// time
start := time.Now()
time.Sleep(100 * time.Millisecond)
fmt.Println(time.Since(start)) // durasi

t, _ := time.Parse(time.RFC3339, "2026-11-10T09:00:00+07:00")

// slices (generik, Go 1.21+)
xs := []int{3, 1, 2}
slices.Sort(xs)                 // [1 2 3]
fmt.Println(slices.Contains(xs, 2)) // true

// maps
m := map[string]int{"a": 1}
keys := slices.Sorted(maps.Keys(m)) // ["a"]

// math/rand/v2
fmt.Println(rand.IntN(6) + 1)   // dadu 1-6
```

---

## Praktik

### 1. Package validasi

Buat folder `validasi/`:

```go
// validasi/validasi.go
package validasi

import (
	"errors"
	"strings"
	"unicode"
)

var ErrKosong = errors.New("nilai kosong")

func Wajib(v string) (string, error) {
	v = strings.TrimSpace(v)
	if v == "" {
		return "", ErrKosong
	}
	return v, nil
}

func Email(v string) (string, error) {
	v, err := Wajib(v)
	if err != nil {
		return "", err
	}
	if !strings.Contains(v, "@") || !strings.Contains(v, ".") {
		return "", errors.New("format email tidak valid")
	}
	return strings.ToLower(v), nil
}

func Password(v string) (string, error) {
	if len(v) < 8 {
		return "", errors.New("password minimal 8 karakter")
	}
	// periksa ada huruf dan angka
	var huruf, angka bool
	for _, r := range v {
		switch {
		case unicode.IsLetter(r):
			huruf = true
		case unicode.IsDigit(r):
			angka = true
		}
	}
	if !huruf || !angka {
		return "", errors.New("password harus memuat huruf dan angka")
	}
	return v, nil
}
```

Lalu tambahkan unit test `validasi/validasi_test.go` (dibahas di fase 5).

### 2. Package utilitas dengan unit test

```go
// util/util.go
package util

import "strings"

// Kapitalisasi kata pertama
func Kapitalisasi(s string) string {
	if s == "" {
		return s
	}
	return strings.ToUpper(s[:1]) + s[1:]
}

// Potong string dengan ellipsis
func Potong(s string, max int) string {
	if len(s) <= max {
		return s
	}
	return s[:max-3] + "..."
}
```

### 3. Program membaca dan menulis JSON

```go
package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type Produk struct {
	ID    int     `json:"id"`
	Nama  string  `json:"nama"`
	Harga float64 `json:"harga"`
	Stok  int     `json:"stok,omitempty"` // 0 tidak ikut diserialisasi
}

func main() {
	p := Produk{ID: 1, Nama: "Laptop", Harga: 12_500_000, Stok: 5}

	// marshal → []byte
	data, err := json.MarshalIndent(p, "", "  ")
	if err != nil {
		fmt.Println("gagal marshal:", err)
		return
	}
	fmt.Println(string(data))

	// tulis ke file
	_ = os.WriteFile("produk.json", data, 0o644)

	// unmarshal dari file
	raw, _ := os.ReadFile("produk.json")
	var hasil Produk
	if err := json.Unmarshal(raw, &hasil); err != nil {
		fmt.Println("gagal unmarshal:", err)
		return
	}
	fmt.Printf("%+v\n", hasil)
}
```

### 4. Program import/export CSV
{% raw %}
```go
package main

import (
	"encoding/csv"
	"fmt"
	"os"
	"strconv"
)

type Mahasiswa struct {
	NIM  string
	Nama string
	Umur int
}

func ExportCSV(path string, daftar []Mahasiswa) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()

	w := csv.NewWriter(f)
	defer w.Flush()

	_ = w.Write([]string{"nim", "nama", "umur"})
	for _, m := range daftar {
		err := w.Write([]string{m.NIM, m.Nama, strconv.Itoa(m.Umur)})
		if err != nil {
			return err
		}
	}
	return w.Error()
}

func ImportCSV(path string) ([]Mahasiswa, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	r := csv.NewReader(f)
	records, err := r.ReadAll()
	if err != nil {
		return nil, err
	}

	var hasil []Mahasiswa
	for i, rec := range records {
		if i == 0 { // lewati header
			continue
		}
		umur, _ := strconv.Atoi(rec[2])
		hasil = append(hasil, Mahasiswa{NIM: rec[0], Nama: rec[1], Umur: umur})
	}
	return hasil, nil
}

func main() {
	data := []Mahasiswa{{"A01", "Budi", 20}, {"A02", "Andi", 21}}
	if err := ExportCSV("kelas.csv", data); err != nil {
		fmt.Println(err)
		return
	}
	baca, err := ImportCSV("kelas.csv")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(baca)
}
```
{% endraw %}

---

## Checklist Fase 3

- [x] Interface: kontrak, implementasi implicit, interface kecil.
- [x] Interface sebagai parameter dan return value.
- [x] `any`, type assertion, type switch.
- [x] Nil interface, typed nil, interface composition.
- [x] Kapan memakai / tidak memakai interface.
- [x] Error sebagai value, `errors.New`, `fmt.Errorf`, `%w`.
- [x] `errors.Is`, `errors.As`, custom error, sentinel, strategi error.
- [x] Generics: type parameter, generic function/type, constraint, `comparable`, union `|`, type inference.
- [x] Package: pembuatan, visibility, import lokal, hindari circular dependency.
- [x] Go module: `go.mod`, `go.sum`, `go mod tidy`, `go get`, versioning, struktur folder.
- [x] Stdlib: `fmt`, `strings`, `strconv`, `math`, `rand/v2`, `time`, `sort`, `slices`, `maps`, `os`, `io`, `bufio`, `filepath`, `json`, `csv`, `log`, `slog`.
- [x] Praktik: package validasi, utilitas + test, JSON, CSV.

## Ringkasan

- Interface diimplementasikan **implicit** — buat kecil dan deklarasikan di sisi konsumen.
- Error adalah value: bungkus dengan `%w` dan konteks, periksa dengan `errors.Is`/`errors.As`.
- **Typed nil** penyebab bug interface paling umum — return `nil` eksplisit.
- Generics menghilangkan duplikasi tanpa kehilangan type safety — jangan berlebihan.
- `internal/` menyembunyikan package; `go mod tidy` menjaga dependency tetap bersih.

---
<!--
Lanjut ke: [Fase 4 — File, JSON, dan Data Persistence]({{ site.baseurl }}/belajar-go/fase-4-file-json-database/)
-->