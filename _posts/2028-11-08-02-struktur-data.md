---
layout: post
title: "Fase 2 — Struktur Data dan Tipe Go"
date: 2026-11-09 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, slice, map, pointer, struct, method]
permalink: /belajar-go/fase-2-struktur-data/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Fundamental GO
---

# Struktur Data dan Tipe Go

Fase ini membahas tipe data kunci Go: array, slice, map, pointer, struct, dan method.
Pemahaman yang kuat di fase ini akan menentukan kualitas kode Go kamu selamanya.

## Tujuan

- Membedakan array dan slice, termasuk backing array.
- Mengoperasikan map dengan benar.
- Memahami pointer tanpa takut.
- Mendesain struct dan method dengan pilihan receiver yang tepat.

---

## 1. Array dan Slice

### Array

Array memiliki **panjang tetap** yang menjadi bagian dari tipenya.

```go
var a [3]int // [0 0 0]
a[0] = 10
a[1] = 20

fmt.Println(a)        // [10 20 0]
fmt.Println(len(a))   // 3

// panjang array = bagian dari tipe
var b [3]int = [3]int{1, 2, 3}
c := [3]int{1, 2, 3}
d := [...]int{1, 2, 3, 4} // panjang ditentukan otomatis = 4

// array adalah VALUE — disalin saat di-assign
x := [3]int{1, 2, 3}
y := x
y[0] = 99
fmt.Println(x, y) // [1 2 3] [99 2 3]
```

### Slice

Slice adalah **view tipis** ke sebuah array: punya panjang (`len`) dan kapasitas (`cap`),
dan nilainya bisa bertambah dengan `append`.

```go
// deklarasi
var s []int                // slice kosong, nil
s := []int{1, 2, 3}        // slice literal
s := make([]int, 5)        // make([]T, len) → [0 0 0 0 0]
s := make([]int, 3, 10)    // make([]T, len, cap)

fmt.Println(len(s), cap(s))
```

```go
s := []int{1, 2, 3}
s = append(s, 4) // [1 2 3 4]
s = append(s, 5, 6)

// menggabungkan slice
a := []int{1, 2}
b := []int{3, 4}
a = append(a, b...)
fmt.Println(a) // [1 2 3 4]
```

### Perbedaan array vs slice

| Aspek | Array | Slice |
|-------|-------|-------|
| Panjang | Tetap, bagian dari tipe | Dinamis, bisa berubah |
| Deklarasi | `[3]int` | `[]int` |
| Nilai | Value (disalin) | Reference-like (header) |
| Pembuatan | `var a [3]int` | `make`, literal, atau `[]T{}` |
| Penggunaan | Jarang (biasanya dalam slice) | Sangat sering |

### `len()` dan `cap()`

```go
s := make([]int, 3, 10) // len=3, cap=10
fmt.Println(len(s))     // 3 — jumlah elemen yang valid
fmt.Println(cap(s))     // 10 — kapasitas backing array dari posisi awal slice
```

**Kapan `append` mengalokasikan array baru?** Saat `len == cap`:

```go
s := make([]int, 2, 4) // len 2, cap 4
s = append(s, 1)       // muat → tidak realokasi
s = append(s, 2)       // muat → tidak realokasi
// s sekarang len 3, cap 4
```

### Slicing

```go
s := []int{0, 1, 2, 3, 4, 5}

a := s[1:4]   // [1 2 3] — dari indeks 1 sampai (tidak termasuk) 4
b := s[:3]    // [0 1 2] — dari awal
c := s[3:]    // [3 4 5] — sampai akhir
d := s[:]     // seluruh slice
e := s[1:4:4] // [1 2 3] — full slice expression: cap diset 4 (mencegah append "bocor")
```

**Aturan penting:** slice baru bisa dibuat dari slice lama, dan mereka
**berbagi backing array**.

```go
s := []int{1, 2, 3, 4, 5}
a := s[1:3] // [2 3]
a[0] = 99
fmt.Println(s) // [1 99 3 4 5] — s ikut berubah!
```

### Nilai `nil` pada slice

```go
var s []int
fmt.Println(s == nil) // true
fmt.Println(len(s))   // 0 — aman

s = append(s, 1)      // append bekerja pada slice nil
fmt.Println(s)        // [1]

// slice kosong vs nil: keduanya len 0, tapi beda cap dan ==nil
empty := []int{}
fmt.Println(empty == nil) // false
```

> **Aturan:** slice `nil` dan slice kosong diperlakukan sama oleh `append`,
> `len`, dan `range`. Hanya membedakan saat serialisasi JSON (`nil` → `null`,
> kosong → `[]`).

### Memahami backing array dan risiko berbagi

Slice disimpan sebagai **header 3 field**: pointer ke array, len, cap.

```go
s := []int{1, 2, 3, 4, 5}
a := s[:2] // header: ptr ke s[0], len 2, cap 5

// ⚠️ DANGER: slice dari tengah, lalu append
s2 := s[2:]
s2 = append(s2, 99)
// append muat (len 3, cap 3) → menulis ke s[3]!
fmt.Println(s) // [1 2 3 99 5] — data asli berubah
```

**Solusi aman** saat ingin memisah:

```go
// 1. pakai full slice expression: s[2:3:3] — cap dipotong, append wajib bikin array baru
s2 := s[2:3:3]
s2 = append(s2, 99)

// 2. atau copy secara eksplisit
s2 := append([]int(nil), s[2:]...)
// atau
s2 := make([]int, len(s[2:]))
copy(s2, s[2:])
```

> **⚠️ Jebakan umum:** fungsi yang menerima slice lalu `append` ke dalamnya bisa
> menimpa data pemanggil bila slice-nya masih punya sisa kapasitas.

### `copy`

```go
src := []int{1, 2, 3}
dst := make([]int, 3)
n := copy(dst, src) // 3 — jumlah elemen yang tersalin
fmt.Println(dst, n)

// memperkecil/menyalin bagian
a := []int{1, 2, 3, 4, 5}
b := make([]int, 2)
copy(b, a[1:3]) // [2 3]
```

`copy` menyalin **minimal** `len(dst)` dan `len(src)` — tidak pernah panic
karena kelebihan panjang.

### Membuat slice dengan `make`

```go
s1 := make([]int, 5)        // len 5, cap 5
s2 := make([]int, 0, 100)   // len 0, cap 100 — pralokasi untuk performa
```

**Kapan pralokasi penting?** Saat kamu tahu ukuran akhir dan banyak menambahkan:

```go
// ❌ lambat: append berulang memindahkan data berkali-kali
var s []int
for i := 0; i < 10000; i++ {
	s = append(s, i)
}

// ✅ cepat: alokasi sekali
s := make([]int, 0, 10000)
for i := 0; i < 10000; i++ {
	s = append(s, i)
}
```

---

## 2. Map

Map adalah struktur **key → value** yang tidak terurut dan tidak boleh duplikat.

### Membuat map

```go
// map literal
umur := map[string]int{
	"budi": 30,
	"andi": 25,
}

// make
umur := make(map[string]int)

// map kosong (bukan nil)
umur := map[string]int{}
```

### Menambah dan mengubah data

```go
umur := map[string]int{}
umur["budi"] = 30    // tambah
umur["andi"] = 25    // tambah
umur["budi"] = 31    // ubah

fmt.Println(umur) // map[andi:25 budi:31] (urutan acak)
fmt.Println(len(umur)) // 2
```

### Mengambil nilai dan mengecek keberadaan

```go
umur := map[string]int{"budi": 30}

// ❌ HANYA mengambil nilai — tidak bisa membedakan key tidak ada vs value 0
v := umur["andi"] // 0, tanpa error!

// ✅ comma-ok idiom
v, ok := umur["andi"]
fmt.Println(v, ok) // 0 false

v, ok = umur["budi"]
fmt.Println(v, ok) // 30 true
```

> **⚠️ Jebakan besar:** mengambil key yang tidak ada pada map `map[string]int`
> mengembalikan zero value (`0`), bukan error. **Selalu** pakai `, ok` bila
> key-nya mungkin tidak ada.

### Menghapus data

```go
delete(umur, "budi")

// aman menghapus key yang tidak ada
delete(umur, "tidak-ada") // tidak error
```

### Iterasi map

```go
for k, v := range umur {
	fmt.Printf("%s = %d\n", k, v)
}

// hanya key
for k := range umur { /* ... */ }

// hanya value
for _, v := range umur { /* ... */ }
```

> **⚠️** Urutan iterasi map **dijamin acak** oleh Go. Jangan pernah mengandalkan
> urutan map. Bila perlu urutan, kumpulkan key-nya lalu sort:
>
> ```go
> keys := slices.Sorted(maps.Keys(m)) // Go 1.23+
> // atau secara manual dengan slices.Sort
> ```

### Map nil dan operasi aman

```go
var m map[string]int
fmt.Println(m == nil) // true

// ❌ panic: assignment ke map nil
// m["a"] = 1

// ✅ membaca dari map nil AMAN (mengembalikan zero value)
v, ok := m["a"] // 0, false
fmt.Println(v, ok)

// ✅ delete pada map nil juga aman
delete(m, "a")

// perbaiki dengan make sebelum menulis
m = make(map[string]int)
m["a"] = 1
```

> Map juga **tidak aman untuk concurrent write** — lihat fase 6 (concurrency).

---

## 3. Pointer

Pointer adalah **alamat memori** ke sebuah nilai.

```go
x := 42
p := &x   // & = alamat x (pointer ke int)
fmt.Println(*p) // * = dereference: ambil nilai di alamat itu

*p = 100  // ubah nilai lewat pointer
fmt.Println(x) // 100
```

### Operator

| Operator | Nama | Fungsi |
|----------|------|--------|
| `&x` | address-of | ambil alamat x |
| `*p` | dereference | ambil nilai di alamat p |

Bedakan deklarasi pointer dan dereference:

```go
var p *int   // p adalah pointer ke int (nil)
*p = 5      // ❌ panic: nil pointer dereference
```

### Pointer pada parameter fungsi — kapan diperlukan

Go **selalu menyalin** argument saat dipanggil (*pass by value*).
Pointer membuat salinan *alamat*, sehingga fungsi bisa mengubah nilai asli.

```go
// ❌ nilai asli tidak berubah — ganti menyalin parameter
func salah(x int) { x = 99 }

// ✅ lewat pointer
func benar(x *int) { *x = 99 }

n := 1
benar(&n)
fmt.Println(n) // 99
```

### Kapan pointer diperlukan dan kapan tidak

**Perlu pointer:**

1. Fungsi perlu **mengubah** nilai argument (mutasi).
2. Menyalin objek **besar** agar tidak membebani memori/alokasi.
3. Menunjuk bahwa sebuah field bisa **tidak ada** (`*int` untuk optional).

**Tidak perlu pointer:**

1. Nilai kecil (`int`, `bool`, `float64`) yang tidak diubah.
2. Struct yang kecil dan hanya dibaca.
3. Slice/map — sudah "reference-like", tidak perlu di-wrap pointer.

```go
// Go umumnya MENGHINDARI pointer untuk value kecil
func tambah(a, b int) int { return a + b } // tanpa pointer, sudah cukup

// Tapi pointer sering dipakai pada method receiver (lihat bagian method)
```

> **Filosofi Go:** beda dengan C++, pointer di Go **aman** — garbage collector
> menangani memori, dan tidak ada pointer arithmetic. Tapi nil pointer dereference
> tetap menyebabkan panic.

### Nilai nil pada pointer

```go
var p *int
fmt.Println(p == nil) // true
fmt.Println(p)        // <nil>

if p != nil {
	fmt.Println(*p)
}

// dereference nil = panic (run-time error, bukan compile error)
```

---

## 4. Struct

Struct adalah **kumpulan field** dengan tipe berbeda — analogi record/class tanpa inheritance.

### Membuat dan memakai struct

```go
type Mahasiswa struct {
	Nama  string
	NIM   string
	Umur  float64
	Lulus bool
}

// struct literal (positional — kurang disarankan)
m1 := Mahasiswa{"Budi", "123", 20, false}

// struct literal (named — disarankan, tahan terhadap perubahan field)
m2 := Mahasiswa{
	Nama: "Budi",
	NIM:  "123",
}

// akses field
fmt.Println(m2.Nama)
m2.Umur = 21

// kosong lalu isi
var m3 Mahasiswa
m3.Nama = "Andi"
```

> **⚠️** `Mahasiswa{"Budi", "123"}` akan **error kompilasi** — semua field
> harus diisi dalam positional literal. Itu sebabnya named field lebih disukai.

### Struct dengan tipe yang sama

```go
type Celsius float64
type Fahrenheit float64

func ToF(c Celsius) Fahrenheit {
	return Fahrenheit(c*9/5 + 32)
}
```

### Nested struct

```go
type Alamat struct {
	Kota  string
	Jalan string
}

type Pelanggan struct {
	Nama   string
	Alamat Alamat // struct bersarang
}

p := Pelanggan{
	Nama: "Budi",
	Alamat: Alamat{
		Kota:  "Bandung",
		Jalan: "Jl. Merdeka 1",
	},
}
fmt.Println(p.Alamat.Kota) // Bandung
```

### Anonymous struct

```go
// berguna untuk data sekali pakai (mis. decoding JSON sementara)
config := struct {
	Host string
	Port int
}{
	Host: "localhost",
	Port: 8080,
}
fmt.Println(config.Host)
```

### Pointer ke struct

```go
func (m *Mahasiswa) SetNama(nama string) {
	m.Nama = nama // otomatis dereference: (*m).Nama = nama
}

// method pointer receiver bisa dipanggil pada addressable value
m := Mahasiswa{}
m.SetNama("Budi") // otomatis &m
```

**Mengakses field via pointer** — Go otomatis dereference:

```go
p := &Mahasiswa{}
p.Nama = "Budi"    // sama dengan (*p).Nama = "Budi"
fmt.Println(p.Nama)
```

### Struct composition (bukan inheritance)

Go tidak punya inheritance. Pola yang dipakai adalah **embedding**:

```go
type Entity struct {
	ID string
}

type User struct {
	Entity      // embedded — field-nya "terangkat" ke User
	Nama string
}

type Admin struct {
	Entity
	Role string
}

u := User{}
u.ID = "1"    // sama dengan u.Entity.ID = "1"
u.Nama = "Budi"

// method Entity juga terangkat
fmt.Println(u.Entity) // akses eksplisit bila perlu
```

> **Konsep:** Go menggunakan *composition over inheritance*.
> Lihat lebih lanjut pada interface di fase 3.

### Struct sebagai model data

```go
type Produk struct {
	ID       int     `json:"id"`
	Nama     string  `json:"nama"`
	Harga    float64 `json:"harga"`
	Stok     int     `json:"stok"`
	Kategori string  `json:"kategori"`
}
```

Tag struct (`json:"..."`) akan dipakai saat marshaling JSON — dibahas di fase 4.

---

## 5. Method

Method adalah fungsi dengan **receiver** — tipe yang menjadi "pemilik" fungsi tersebut.

```go
type Titik struct {
	X, Y float64
}

// method dengan VALUE receiver
func (t Titik) Jarak() float64 {
	return math.Sqrt(t.X*t.X + t.Y*t.Y)
}

// method dengan POINTER receiver — bisa mengubah nilai asli
func (t *Titik) Geser(dx, dy float64) {
	t.X += dx
	t.Y += dy
}

// pemakaian
p := Titik{3, 4}
fmt.Println(p.Jarak()) // 5
p.Geser(1, 1)           // otomatis jadi (&p).Geser(1,1)
fmt.Println(p)          // {4 5}
```

### Value receiver vs pointer receiver

| Value receiver | Pointer receiver |
|----------------|------------------|
| Bekerja pada **salinan** | Bekerja pada **nilai asli** |
| Tidak bisa mengubah field | Bisa mengubah field |
| Aman untuk tipe kecil/imutable | Efisien untuk struct besar |
| Method bisa dipanggil pada value non-addressable | Butuh value yang bisa di-address |

**Aturan praktis yang diikuti komunitas Go:**

1. **Konsisten** — semua method pada satu tipe pakai receiver yang sama.
2. Pakai **pointer receiver** jika method:
   - mengubah receiver, **atau**
   - struct-nya besar (menghindari salinan), **atau**
   - perlu konsistensi dengan method lain yang mutasi.
3. Pakai **value receiver** jika method hanya membaca dan tipe-nya kecil
   (`int`, `time.Time`, dst.).

```go
// ❌ campuran receiver — membingungkan
func (t Titik) A() {}
func (t *Titik) B() {}

// ✅ konsisten pointer receiver
func (t *Titik) A() {}
func (t *Titik) B() {}
```

### Method set (pengenal dasar)

Aturan **method set** menentukan method mana yang tersedia pada suatu tipe:

- Method set dari **value `T`** = semua method dengan **value receiver** `(T)`.
- Method set dari **pointer `*T`** = semua method dengan value receiver **dan**
  pointer receiver `(*T)`.

Konsekuensi praktis:

```go
type S struct{}

func (s S) Value()    {}
func (s *S) Pointer() {}

var v S
var p *S = &v

v.Value()    // ✅
v.Pointer()  // ✅ Go otomatis jadikan (&v).Pointer() — tapi hanya jika v addressable
p.Value()    // ✅ otomatis (*p).Value()
p.Pointer()  // ✅

// ❌ TIDAK bisa — interface hanya butuh method tertentu, lihat fase 3
// var i InterfaceWithValueMethod = v  // aman
// var j InterfaceWithPointerMethod = v // compile error: method set S tidak memuat Pointer()
```

> **Hubungan dengan interface:** jika sebuah tipe dipakai sebagai interface yang
> method-nya hanya value receiver, value biasa sudah cukup. Bila method interface
> ditulis dengan pointer receiver, kamu harus memakai `*T`. Detail di fase 3.

### Method bukan "milik" package

Method dideklarasikan **pada tipe yang sama package-nya**. Kamu tidak bisa
menambah method pada tipe dari package lain (seperti extension method di C#/Kotlin).

```go
// ❌ tidak valid — string berasal dari package string/builtin
// func (s string) Panjang() int { return len(s) }

// ✅ cara Go: bungkus sebagai fungsi, atau buat tipe baru
type Kueri string
func (k Kueri) Bersih() string { return strings.TrimSpace(string(k)) }
```

---

## Praktik

### 1. Manajemen data mahasiswa

```go
package main

import "fmt"

type Mahasiswa struct {
	Nama string
	NIM  string
	Umur int
}

func cari(nim string, daftar []Mahasiswa) (Mahasiswa, bool) {
	for _, m := range daftar {
		if m.NIM == nim {
			return m, true
		}
	}
	return Mahasiswa{}, false
}

func tambah(daftar *[]Mahasiswa, m Mahasiswa) {
	*daftar = append(*daftar, m)
}

func main() {
	var kelas []Mahasiswa
	tambah(&kelas, Mahasiswa{"Budi", "A01", 20})
	tambah(&kelas, Mahasiswa{"Andi", "A02", 21})

	if m, ok := cari("A02", kelas); ok {
		fmt.Printf("Ketemu: %s (umur %d)\n", m.Nama, m.Umur)
	}

	if _, ok := cari("A99", kelas); !ok {
		fmt.Println("Tidak ketemu")
	}
}
```

### 2. Aplikasi kontak dengan slice dan map

```go
type KontakBuku struct {
	byNIM map[string]Kontak
	urut  []string // menjaga urutan input
}

type Kontak struct {
	Nama  string
	Telepon string
}

func (k *KontakBuku) Tambah(nim string, ktc Kontak) {
	if k.byNIM == nil {
		k.byNIM = make(map[string]Kontak)
	}
	if _, ada := k.byNIM[nim]; !ada {
		k.urut = append(k.urut, nim)
	}
	k.byNIM[nim] = ktc
}

func (k KontakBuku) Cari(nim string) (Kontak, bool) {
	c, ok := k.byNIM[nim]
	return c, ok
}
```

Gabungkan **map** untuk pencarian cepat dan **slice** untuk menjaga urutan.

### 3. Model produk, kategori, dan transaksi

```go
type Kategori struct {
	ID   int
	Nama string
}

type Produk struct {
	ID       int
	Nama     string
	Harga    float64
	Kategori Kategori // composition
}

type ItemTransaksi struct {
	Produk  Produk
	Jumlah  int
}

type Transaksi struct {
	ID      string
	Item    []ItemTransaksi
}

func (t Transaksi) Total() float64 {
	var total float64
	for _, it := range t.Item {
		total += it.Produk.Harga * float64(it.Jumlah)
	}
	return total
}
```

---

## Checklist Fase 2

- [x] Array: deklarasi, literal, panjang tetap, value semantics.
- [x] Slice: literal, `make`, `append`, `len`/`cap`, slicing, `nil`.
- [x] Memahami backing array dan risiko berbagi data.
- [x] `copy`, full slice expression, pralokasi kapasitas.
- [x] Map: literal, `make`, tambah/ubah, `delete`, comma-ok, iterasi, map nil.
- [x] Pointer: `&`, `*`, parameter fungsi, kapan diperlukan, nil pointer.
- [x] Struct: literal, nested, anonymous, pointer, composition, model data.
- [x] Method: receiver, value vs pointer, method set.

## Ringkasan

- Slice = header (ptr, len, cap) di atas backing array — **berbagi data**.
- Selalu pakai `v, ok := m[key]` untuk membedakan key tak ada dari zero value.
- Pointer di Go aman (tanpa pointer arithmetic), tapi nil dereference tetap panic.
- Struct composition (embedding) menggantikan inheritance.
- Pilih pointer receiver bila method memutasi atau struct besar — dan tetap konsisten.

---

Lanjut ke: [Fase 3 — Konsep Go yang Penting]({{ site.baseurl }}/belajar-go/fase-3-konsep-penting/)
