---
layout: post
title: "Fase 5 — Testing dan Quality"
date: 2026-11-12 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, testing, benchmark, coverage, linting]
permalink: /belajar-go/fase-5-testing-quality/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Testing dan Quality
---

# Testing dan Quality

Go menyertakan framework testing di stdlib — tanpa dependensi eksternal.
Fase ini membahas unit test, testing lanjutan, dan menjaga kualitas kode.

## Tujuan

- Menulis unit test dengan package `testing`.
- Menguji dengan table-driven test dan subtest.
- Menulis benchmark, fuzz test, dan mengukur coverage.
- Mendeteksi race condition dengan `-race`.
- Menjaga kualitas dengan `gofmt`, `go vet`, dan `golangci-lint`.

---

## 1. Unit Testing

### Struktur file test

- File test berakhiran **`_test.go`**.
- Package test: `package mypkg` (internal test) atau `package mypkg_test` (external test).
- Fungsi test berawal **`Test`** diikuti huruf besar (`TestTambah`).

```go
// file: kalkulator/kalkulator.go
package kalkulator

import "errors"

var ErrPembagianNol = errors.New("pembagian dengan nol")

func Tambah(a, b int) int { return a + b }

func Bagi(a, b int) (int, error) {
	if b == 0 {
		return 0, ErrPembagianNol
	}
	return a / b, nil
}
```

```go
// file: kalkulator/kalkulator_test.go
package kalkulator

import "testing"

func TestTambah(t *testing.T) {
	hasil := Tambah(2, 3)
	if hasil != 5 {
		t.Errorf("Tambah(2, 3) = %d, want 5", hasil)
	}
}

func TestBagiError(t *testing.T) {
	_, err := Bagi(1, 0)
	if err == nil {
		t.Fatal("Bagi(1, 0) seharusnya mengembalikan error, dapat nil")
	}
}
```

Jalankan:

```bash
go test ./...          # semua package
go test ./kalkulator   # satu package
go test -v ./...       # verbose (tampilkan subtest)
go test -run TestTambah ./...   # hanya test tertentu (regex)
go test -count=1 ./...  # jangan pakai cache
```

### Assertion secara idiomatis

Go **tidak punya** assertion library bawaan — gaya Go adalah **if biasa**:

```go
if got != want {
	t.Errorf("got %v, want %v", got, want)
}

// untuk slice: pakai slices.Equal (Go 1.21+)
if !slices.Equal(got, want) {
	t.Errorf("got %v, want %v", got, want)
}

// untuk error: errors.Is
if !errors.Is(err, ErrNotFound) {
	t.Errorf("want ErrNotFound, got %v", err)
}
```

**Aturan:**

- `t.Errorf` — catat error, **lanjutkan** test (bisa mengecek banyak hal sekaligus).
- `t.Fatalf` — catat error, **hentikan** test (mis. setup gagal, lanjut tak berguna).

> Library assertion seperti `testify` populer (`require.Equal(t, want, got)`),
> tapi test stdlib sudah lebih dari cukup — pakai bila tim sudah menggunakannya.

### Table-driven test — idiom utama Go

```go
func TestGanjilGenap(t *testing.T) {
	tests := []struct {
		name string
		in   int
		want string
	}{
		{"nol", 0, "genap"},
		{"positif ganjil", 7, "ganjil"},
		{"positif genap", 8, "genap"},
		{"negatif ganjil", -3, "ganjil"},
		{"negatif genap", -4, "genap"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := GanjilGenap(tt.in)
			if got != tt.want {
				t.Errorf("GanjilGenap(%d) = %q, want %q", tt.in, got, tt.want)
			}
		})
	}
}
```

**Ciri table-driven yang baik:**

- Setiap kasus punya **`name` deskriptif** (tampil di output `-v`).
- Struktur **anonymous struct** — field `in`/`want` jelas.
- Loop `t.Run(tt.name, ...)` → subtest per kasus.

### Subtest dengan `t.Run`

```go
func TestHTTPStatus(t *testing.T) {
	t.Run("sukses", func(t *testing.T) {
		// ...
	})
	t.Run("gagal validasi", func(t *testing.T) {
		// ...
	})
}

// menjalankan hanya subtest tertentu
// go test -run 'TestHTTPStatus/sukses' ./...
```

Subtest berguna untuk menjalankan test secara paralel:

```go
for _, tt := range tests {
	tt := tt // ⚠️ capture variabel (penting sebelum Go 1.22)
	t.Run(tt.name, func(t *testing.T) {
		t.Parallel() // jalankan bersamaan
		// ...
	})
}
```

> **Catatan Go 1.22+:** variabel loop sudah per-iterasi, jadi `tt := tt`
> tidak lagi wajib — tapi masih umum ditemukan di kode lama.

### Test helper

Fungsi helper memanggil `t.Helper()` agar lokasi error menunjuk ke pemanggil:

```go
func assertEqual(t *testing.T, got, want any) {
	t.Helper() // ⚠️ penting: agar baris error menunjuk pemanggil, bukan helper
	if got != want {
		t.Errorf("got %v, want %v", got, want)
	}
}

func TestX(t *testing.T) {
	assertEqual(t, Tambah(1, 2), 3) // error dilaporkan di baris ini
}
```

Untuk setup yang gagal fatal di banyak test:

```go
func buatServer(t *testing.T) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(handler())
	t.Cleanup(srv.Close) // ⚠️ auto-cleanup saat test selesai
	return srv
}
```

`t.Cleanup` lebih baik daripada `defer` untuk resource yang hidup selama test.

### Menguji error dan edge case

```go
func TestBagi(t *testing.T) {
	t.Run("normal", func(t *testing.T) {
		got, err := Bagi(10, 2)
		if err != nil {
			t.Fatalf("tidak expect error, dapat %v", err)
		}
		if got != 5 {
			t.Errorf("got %d, want 5", got)
		}
	})

	t.Run("pembagian nol", func(t *testing.T) {
		_, err := Bagi(1, 0)
		if !errors.Is(err, ErrPembagianNol) {
			t.Errorf("want ErrPembagianNol, got %v", err)
		}
	})
}
```

**Edge case yang selalu diuji:**

- Nilai kosong / nol / negatif.
- Input terbesar dan terkecil (`math.MaxInt`).
- Slice/map nil vs kosong.
- Duplikat data.
- Error path (bukan hanya happy path!).

### Mengisolasi package saat test

- Test hanya memakai **API exported** → pakai `package mypkg_test`
  (mencegah test bergantung pada detail internal).
- Untuk pengujian internal yang butuh akses unexported → `package mypkg`.

```go
// external test — memakai kontrak publik
package kalkulator_test

import (
	"testing"
	"myapp/kalkulator"
)

func TestPublik(t *testing.T) {
	if kalkulator.Tambah(1, 2) != 3 {
		t.Error("gagal")
	}
}
```

---

## 2. Testing Lanjutan

### Benchmark

```go
func BenchmarkTambah(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Tambah(1, 2)
	}
}

// benchmark dengan setup per iterasi
func BenchmarkSliceAppend(b *testing.B) {
	for i := 0; i < b.N; i++ {
		b.StopTimer()
		s := make([]int, 0, 100) // setup tidak diukur
		b.StartTimer()
		for j := 0; j < 100; j++ {
			s = append(s, j)
		}
	}
}
```

```bash
go test -bench=. -benchmem ./...
# BenchmarkTambah-10   1000000000   0.25 ns/op   0 B/op   0 allocs/op
```

**Membaca hasil:**

- `ns/op` — nanosecond per operasi.
- `B/op` — alokasi memori per operasi.
- `allocs/op` — jumlah alokasi per operasi.

> **Aturan benchmark yang valid:**
> - Jangan menghitung di luar loop yang diukur (pakai `b.N`).
> - Laporkan hasil dengan `b.ReportAllocs()` bila perlu.
> - Gunakan `-benchtime` bila operasi sangat lambat.
> - Bandingkan dengan **profil**, bukan dugaan.

### Fuzz testing (Go 1.18+)

```go
func FuzzParse(f *testing.F) {
	f.Add("123")          // seed corpus
	f.Add("-1")
	f.Add("abc")

	f.Fuzz(func(t *testing.T, s string) {
		n, err := strconv.Atoi(s)
		if err != nil {
			return
		}
		// invarian: parse lalu format harus konsisten
		if strconv.Itoa(n) != s && s != "+"+strconv.Itoa(n) {
			t.Errorf("roundtrip gagal: %q → %d → %q", s, n, strconv.Itoa(n))
		}
	})
}
```

```bash
go test -fuzz=FuzzParse ./...
go test -fuzz=FuzzParse -fuzztime=30s ./...
```

Fuzzer menemukan input tak terduga yang memecah invarian program.
Test case yang ditemukan otomatis ditambahkan ke seed corpus.

### Test coverage

```bash
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html   # laporan HTML
go tool cover -func=coverage.out                    # per fungsi
```

Output:

```
ok  myapp/kalkulator   85.7% of statements
```

> **Catatan realistis:** coverage 100% bukan tujuan. Fokus pada **logic penting**
> (branch yang bila salah = bug serius). Test yang hanya menguji getter/setter
> menaikkan angka tanpa menambah keamanan.

### Race detector

```bash
go test -race ./...
go run -race main.go
go build -race -o app . // build dengan race detector
```

Race detector mendeteksi **data race** — akses ke memori yang sama dari
beberapa goroutine tanpa sinkronisasi.

```
WARNING: DATA RACE
Write at 0x00c00001a0e0 by goroutine 7:
  main.tambahCounter()
      main.go:10 +0x48
Previous read at 0x00c00001a0e0 by goroutine 6:
  main.bacaCounter()
      main.go:15 +0x44
```

> **⚠️** `-race` menambah overhead signifikan (~2-10x lebih lambat) — pakai saat
> test dan development, bukan di production build.

### Integration test

Test yang menyentuh dependensi nyata (database, HTTP):

```go
// file: repo/produk_integration_test.go
//go:build integration
// +build integration

package repo_test
```

```bash
# test biasa: integration test tidak ikut
go test ./...

# test integration (butuh database berjalan)
go test -tags=integration ./...
```

**Build tag** `//go:build integration` memisahkan test berat dari test cepat.

**Aturan integration test:**

- Jalankan dengan **database sungguhan** (MariaDB), bukan mock.
- Gunakan **schema terpisah** atau database per test.
- Selalu **cleanup** setelah test (`t.Cleanup`).
- Harus **deterministic** — tidak bergantung waktu/jam/urutan.

### Test HTTP handler

```go
func TestHandlerHello(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/hello?nama=Budi", nil)
	rec := httptest.NewRecorder()

	handler(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("status = %d, want %d", rec.Code, http.StatusOK)
	}

	var resp map[string]string
	if err := json.Unmarshal(rec.Body.Bytes(), &resp); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if resp["pesan"] != "Halo, Budi" {
		t.Errorf("pesan = %q", resp["pesan"])
	}
}
```

Untuk server penuh:

```go
srv := httptest.NewServer(mux)   // server HTTP sungguhan untuk test
defer srv.Close()

resp, err := http.Get(srv.URL + "/hello?nama=Budi")
```

### Mock / fake sederhana

Go menganut **"fakes over mocks"**: buat implementasi sederhana dari interface.

```go
// kontrak asli
type UserRepo interface {
	GetByID(ctx context.Context, id int) (User, error)
}

// fake untuk test — tanpa library mock
type fakeUserRepo struct {
	users map[int]User
	err   error // bila ingin mensimulasikan error
}

func (f *fakeUserRepo) GetByID(ctx context.Context, id int) (User, error) {
	if f.err != nil {
		return User{}, f.err
	}
	u, ok := f.users[id]
	if !ok {
		return User{}, ErrNotFound
	}
	return u, nil
}

// test memakai fake
func TestService(t *testing.T) {
	repo := &fakeUserRepo{users: map[int]User{1: {ID: 1, Nama: "Budi"}}}
	svc := NewService(repo)

	u, err := svc.Ambil(context.Background(), 1)
	if err != nil {
		t.Fatal(err)
	}
	if u.Nama != "Budi" {
		t.Errorf("got %q", u.Nama)
	}
}
```

> **Kapan mock diperlukan?** Ketika kamu perlu memverifikasi **interaksi**
> ("method X dipanggil tepat sekali dengan argumen Y") atau mensimulasikan
> timing/error yang sulit direproduksi. Untuk sebagian besar kasus, fake sederhana
> sudah cukup dan jauh lebih mudah dibaca.

---

## 3. Code Quality

### `gofmt` — formatter baku

```bash
gofmt -w .          # format dan simpan
gofmt -l .          # daftar file yang belum format
gofumpt -w .        # variant lebih ketat (opsional, populer)
```

> Sebagian besar editor meng-format otomatis saat save. Aktifkan.

### `go vet` — analisis statis bawaan

```bash
go vet ./...
```

Mendeteksi pola mencurigakan: format string salah, method yang salah dipanggil,
field struct yang salah urutan saat diisi positional, dll.

### Static analysis tambahan

```bash
go install honnef.co/go/tools/cmd/staticcheck@latest
staticcheck ./...     # analisis paling kuat (menggabungkan stylecheck + gosimple)
```

Contoh yang ditemukan `staticcheck`:

- Code tak terjangkau (`SA9003`).
- Kondisi kosong (`S1002` — `if x == true`).
- Efek samping yang tidak dipakai.

### Linting dengan golangci-lint

[golangci-lint](https://golangci-lint.run) menjalankan banyak linter sekaligus:

```bash
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
golangci-lint run ./...
```

Linter yang umum diaktifkan: `errcheck` (error tak dicek), `govet`, `staticcheck`,
`ineffassign`, `unused`, `gocritic`, `revive`.

`.golangci.yml` contoh:

```yaml
run:
  timeout: 3m

linters:
  enable:
    - errcheck
    - staticcheck
    - govet
    - ineffassign
    - unused
    - revive
    - gocritic

linters-settings:
  errcheck:
    check-blank: true   # bahkan _ = err harus dipertimbangkan
```

**Penting:** `errcheck` menangkap error yang diabaikan (`_ = f.Close()` tanpa
flush, misalnya) — salah satu sumber bug paling umum.

### Naming idiomatis Go

| Hindari | Lebih baik |
|---------|-----------|
| `ComputeValue()` | `Compute()` (package sudah menjelaskan konteks) |
| `ReadFromFile()` | `Read()` (di package `file`) |
| `if err == nil { return x } else { return y }` | langsung return |
| `doX()`, `handleX()`, `processX()` | `x()`, `updateX()` |
| `Data`, `Info`, `Manager` (terlalu umum) | nama spesifik |

**Effective Go:** nama harus pendek, konsisten, dan jelas dalam konteks package-nya.
Package bernama `pkg/utils` hampir selalu tanda peringatan desain.

### Menghindari duplikasi

- Duplikasi **kecil** boleh — jangan buru-buru abstraksi.
- Duplikasi **pola yang berulang** → ekstrak fungsi.
- Duplikasi **desain** (banyak package mirip) → refactor struktur.

### Komentar yang berguna

```go
// Package konversi menyediakan utilitas format angka dan tanggal.
package konversi

// PecahFaktorial memecah n menjadi faktorisasi prima.
// Mengembalikan error bila n < 1.
func PecahFaktorial(n int) ([]int, error) {
	// komentar di dalam: jelaskan MENGAPA, bukan APA yang dilakukan
	// (kode sudah menjelaskan "apa")
}
```

**Jangan berkomentar:**

```go
// tambah 1 ke i   ← hanya mengulang kode
i++
```

**Wajib berkomentar:**

- Exported identifier — menjelaskan tujuan (akan muncul di godoc).
- Keputusan non-obvious / trade-off.
- Peringatan jebakan.
- TODO dengan issue reference.

```bash
godoc -http=:6060   # browse dokumentasi package lokal
```

### Membaca Go Code Review Comments

Panduan resmi: <https://go.dev/wiki/CodeReviewComments>

Poin yang paling sering muncul di review:

- Jangan mengabaikan error (`_ = err` tanpa alasan).
- `if err != nil` langsung setelah pemanggilan, tanpa blank line berlebih.
- Kembalikan error dengan konteks (`fmt.Errorf("...: %w", err)`).
- Pakai `time.Duration` (`5 * time.Second`), bukan angka mentah.
- Struktur `TestXxx` dengan table-driven.
- Jangan pakai pointer receiver campuran pada tipe yang sama.

### Meninjau dependency dan vulnerability

```bash
# lihat daftar dependency
go list -m all

# perbarui
go get -u ./...
go mod tidy

# periksa vulnerability (Go 1.21+)
govulncheck ./...
```

**Aturan:**

- Minimalis — setiap dependency adalah risiko maintenance dan keamanan.
- Baca changelog sebelum upgrade mayor.
- `go.sum` harus selalu ikut di-commit.

---

## Praktik

### 1. Unit test pada project CRUD

```go
// service/produk_test.go
package service

import (
	"context"
	"errors"
	"testing"
)

func TestTambahProduk(t *testing.T) {
	tests := []struct {
		name    string
		req     TambahRequest
		wantErr error
	}{
		{"valid", TambahRequest{Nama: "Laptop", Harga: 1000}, nil},
		{"nama kosong", TambahRequest{Nama: "", Harga: 1000}, ErrValidasi},
		{"harga negatif", TambahRequest{Nama: "X", Harga: -1}, ErrValidasi},
		{"nama terlalu panjang", TambahRequest{Nama: strings.Repeat("a", 300)}, ErrValidasi},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			repo := &fakeProdukRepo{} // fake, bukan database
			svc := NewService(repo)

			_, err := svc.Tambah(context.Background(), tt.req)
			if !errors.Is(err, tt.wantErr) {
				t.Errorf("err = %v, want %v", err, tt.wantErr)
			}
		})
	}
}
```

### 2. Coverage pada logic penting

Fokuskan test pada:

- Validasi input (semua cabang error).
- Kalkulasi bisnis (total, diskon, pajak).
- Error path repository.
- Batas pagination (page pertama, terakhir, melewati akhir).

```bash
go test -coverprofile=c.out ./...
go tool cover -func=c.out | sort -t$'\t' -k3 -n | tail -20
```

### 3. Benchmark untuk potensi bottleneck

```go
func BenchmarkKonkatenasiString(b *testing.B) {
	b.Run("plus", func(b *testing.B) {
		for i := 0; i < b.N; i++ {
			s := ""
			for j := 0; j < 100; j++ {
				s += "x" // ❌ alokasi berulang
			}
		}
	})

	b.Run("strings.Builder", func(b *testing.B) {
		for i := 0; i < b.N; i++ {
			var sb strings.Builder
			for j := 0; j < 100; j++ {
				sb.WriteString("x") // ✅ alokasi tunggal
			}
			_ = sb.String()
		}
	})
}
```

```bash
go test -bench=Konkatenasi -benchmem ./...
# perbedaan ns/op dan allocs/op membuktikan optimasi — bukan asumsi
```

---

## Checklist Fase 5

- [x] Package `testing`, file `_test.go`, fungsi `Test...`, `go test`.
- [x] Table-driven test, subtest `t.Run`, assertion idiomatis, test helper (`t.Helper`, `t.Cleanup`).
- [x] Menguji error dan edge case, mengisolasi package.
- [x] Benchmark `testing.B`, fuzz testing, coverage (`-cover`, HTML).
- [x] Race detector (`-race`), integration test dengan build tag.
- [x] Test HTTP handler, mock/fake sederhana, kapan mock diperlukan.
- [x] `gofmt`, `go vet`, `staticcheck`, `golangci-lint`.
- [x] Naming idiomatis, hindari duplikasi, komentar bermakna.
- [x] Go Code Review Comments, `govulncheck`.

## Ringkasan

- Test adalah **fitur stdlib** — cukup `go test`, tanpa framework.
- **Table-driven + `t.Run`** adalah idiom test Go yang utama.
- `t.Helper()` dan `t.Cleanup()` menjadikan test lebih bersih dan akurat.
- `-race` wajib untuk kode concurrent; coverage fokus pada logic penting.
- `golangci-lint` (khususnya `errcheck`) menangkap error yang terlewat.
- Benchmark membuktikan optimasi — **jangan mengoptimalisasi tanpa data**.

---

Lanjut ke: [Fase 6 — Concurrency dan Parallelism]({{ site.baseurl }}/belajar-go/fase-6-concurrency/)
