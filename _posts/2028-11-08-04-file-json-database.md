---
layout: post
title: "Fase 4 — File, JSON, dan Data Persistence"
date: 2026-11-11 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, json, file, database, sql]
permalink: /belajar-go/fase-4-filejson-database/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: File, JSON, dan Data Persistence
---

# File, JSON, dan Data Persistence

Fase ini membahas bagaimana Go membaca dan menulis file, memproses JSON,
dan berinteraksi dengan database relational menggunakan `database/sql`.

## Tujuan

- Membaca/menulis file dengan benar (`os`, `bufio`, `defer Close`).
- Memahami JSON marshal/unmarshal dan struct tag.
- Menggunakan `database/sql`: query, transaksi, context, dan mencegah SQL injection.
- Membentuk lapisan repository sebagai pemisahan akses data.

---

## 1. File System

### Membaca dan menulis file (cara sederhana)

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	// menulis — menimpa file yang sudah ada
	err := os.WriteFile("catatan.txt", []byte("Halo dari Go\n"), 0o644)
	if err != nil {
		fmt.Println("gagal menulis:", err)
		return
	}

	// membaca seluruh file
	data, err := os.ReadFile("catatan.txt")
	if err != nil {
		fmt.Println("gagal membaca:", err)
		return
	}
	fmt.Printf("isi: %q (%d byte)\n", string(data), len(data))
}
```

> **⚠️** `os.ReadFile`/`os.WriteFile` membaca/menulis **seluruh file ke memori**.
> Untuk file besar, pakai `os.Open` + `bufio` (lihat di bawah).

### Permission file

`0o644` = octal: pemilik baca-tulis, grup baca, lainnya baca.

```
0o755  → executable (untuk script/binary)
0o644  → file biasa
0o600  → hanya pemilik (aman untuk file rahasia)
```

### Membuka file dengan `os.Open` dan `defer Close`

```go
func Proses() error {
	f, err := os.Open("data.txt")
	if err != nil {
		return fmt.Errorf("buka file: %w", err)
	}
	defer f.Close() // dijalankan saat fungsi selesai

	// ... pakai f
	return nil
}
```

> **⚠️ Aturan:** `defer f.Close()` harus ditempatkan **tepat setelah** pengecekan
> error — jangan `defer` sebelum cek error (bisa menutup file yang tidak terbuka).

### Menulis file dengan `os.Create` dan buffered writer

```go
func Tulis() error {
	f, err := os.Create("keluaran.txt") // mode 0666, menimpa
	if err != nil {
		return err
	}
	defer f.Close()

	w := bufio.NewWriter(f)
	defer w.Flush() // ⚠️ WAJIB: bufio menahan data di buffer

	for i := 0; i < 1000; i++ {
		fmt.Fprintf(w, "baris %d\n", i)
	}
	return nil
}
```

> **⚠️ Jebakan klasik:** `bufio.Writer` menyimpan data di memori.
> Tanpa `Flush()`, file bisa kosong walau tidak ada error.
> `os.WriteFile` tidak memerlukan flush.

### Membaca file besar secara bertahap

```go
// cara 1: Scanner per baris (batas default 64KB per baris)
func BacaBaris(path string) error {
	f, err := os.Open(path)
	if err != nil {
		return err
	}
	defer f.Close()

	sc := bufio.NewScanner(f)
	sc.Buffer(make([]byte, 1024*1024), 1024*1024) // naikkan buffer bila baris panjang

	for sc.Scan() {
		baris := sc.Text()
		fmt.Println(baris)
	}
	return sc.Err() // ⚠️ selalu cek error scanner
}

// cara 2: Read per chunk (untuk data biner/stream)
func Salin(dst io.Writer, src io.Reader) (int64, error) {
	return io.Copy(dst, src)
}
```

**`io.Copy`** adalah cara paling idiomatis untuk menyalin dari reader ke writer
(sudah memakai buffer internal).

### Membaca dengan `bufio.Reader`

```go
f, _ := os.Open("data.txt")
defer f.Close()

r := bufio.NewReader(f)
// baca sampai delimiter tertentu
line, err := r.ReadString('\n')
// atau baca sejumlah byte
buf := make([]byte, 1024)
n, err := r.Read(buf)
```

### Membuat dan menghapus direktori

```go
err := os.MkdirAll("data/uploads", 0o755) // rekursif, tidak error bila sudah ada
err = os.Mkdir("temp", 0o755)             // harus parent sudah ada

err = os.Remove("data.txt")               // hapus file/dir (kosong)
err = os.RemoveAll("temp")                // hapus beserta isinya

err = os.Rename("old.txt", "new.txt")     // rename / pindah
```

### Memeriksa file dan direktori

```go
info, err := os.Stat("data.txt")
if err != nil {
	// os.IsNotExist(err) → file tidak ada
	return err
}

fmt.Println(info.Size())        // ukuran byte
fmt.Println(info.IsDir())       // direktori?
fmt.Println(info.ModTime())     // waktu modifikasi
fmt.Println(info.Mode())        // permission

// cara cepat cek keberadaan
if _, err := os.Stat(path); os.IsNotExist(err) {
	fmt.Println("file tidak ada")
}
```

### `path/filepath` — path portabel

```go
p := filepath.Join("data", "uploads", "gambar.png")
// "data/uploads/gambar.png" — otomatis pakai separator OS yang benar

dir, file := filepath.Split(p) // "data/uploads/" dan "gambar.png"
ext := filepath.Ext(file)      // ".png"

abs, _ := filepath.Abs("relatif.txt") // path absolut

// traversal direktori
filepath.WalkDir("data", func(path string, d fs.DirEntry, err error) error {
	if err != nil {
		return err
	}
	fmt.Println(path)
	return nil
})
```

> **⚠️** Selalu pakai `filepath.Join`, bukan string concatenation (`a + "/" + b`) —
> `"/"` tidak benar di Windows.

### Menangani error file

```go
f, err := os.Open("config.txt")
if err != nil {
	if os.IsNotExist(err) {
		fmt.Println("config belum dibuat — pakai default")
	} else {
		return fmt.Errorf("buka config: %w", err)
	}
}
// lanjut dengan default...

// atau dengan errors.Is (lebih modern)
if errors.Is(err, fs.ErrNotExist) {
	// tidak ada
}
if errors.Is(err, fs.ErrPermission) {
	// izin ditolak
}
```

---

## 2. JSON

### Marshal (Go → JSON)

```go
type Produk struct {
	ID    int     `json:"id"`
	Nama  string  `json:"nama"`
	Harga float64 `json:"harga"`
	Stok  int     `json:"stok,omitempty"`
}

p := Produk{ID: 1, Nama: "Laptop", Harga: 12_500_000, Stok: 5}

data, err := json.Marshal(p)
fmt.Println(string(data))
// {"id":1,"nama":"Laptop","harga":12500000,"stok":5}

// versi rapi
pretty, _ := json.MarshalIndent(p, "", "  ")
fmt.Println(string(pretty))
```

### Unmarshal (JSON → Go)

```go
raw := []byte(`{"id":1,"nama":"Laptop","harga":12500000,"stok":5}`)
var p Produk
err := json.Unmarshal(raw, &p)
// wajib lewat pointer &p agar bisa mengubah nilai asli
```

### Struct tag JSON

```go
type User struct {
	// tag: nama_json,opsi
	Nama    string `json:"nama"`                     // rename field
	Email   string `json:"email"`                    // nama beda dari field
	Telepon string `json:"telepon,omitempty"`        // hilangkan bila kosong
	Sandi    string `json:"-"`                       // JANGAN pernah diserialisasi
	Role    string `json:"role,omitempty"`           // ...
}

// bentuk tag umum untuk keamanan:
// `json:"nama" db:"nama"`  — dipakai juga oleh ORM/driver
```

**Opsi penting:**

| Opsi | Fungsi |
|------|--------|
| `omitempty` | Hilangkan field saat kosong (`""`, `0`, `nil`, slice kosong) |
| `-` | Abaikan field sepenuhnya |
| `string` | Serialisasi angka sebagai string (`"123"`) |

> **⚠️** Field yang **tidak exported** (huruf kecil) **tidak pernah** bisa
> di-unmarshal — Go tidak bisa mengaksesnya. Wajib exported + tag.

### Streaming dengan `json.Decoder` / `json.Encoder`

```go
// ✅ DECODER: untuk stream (baca banyak object dari reader tanpa memuat semua ke memori)
func BacaProduk(r io.Reader) ([]Produk, error) {
	dec := json.NewDecoder(r)
	var hasil []Produk
	for {
		var p Produk
		if err := dec.Decode(&p); err != nil {
			if errors.Is(err, io.EOF) {
				break // selesai
			}
			return nil, err
		}
		hasil = append(hasil, p)
	}
	return hasil, nil
}

// ✅ ENCODER: untuk stream
func TulisProduk(w io.Writer, ps []Produk) error {
	enc := json.NewEncoder(w)
	// enc.SetIndent("", "  ") // bila ingin rapi
	for _, p := range ps {
		if err := enc.Encode(p); err != nil {
			return err
		}
	}
	return nil
}
```

Untuk HTTP request/response body, `json.NewDecoder(r.Body).Decode(&v)`
adalah pola yang paling umum.

### Menangani JSON invalid

```go
var p Produk
err := json.Unmarshal([]byte(`{nama: tidak valid}`), err)
if err != nil {
	// err biasanya *json.SyntaxError
	var serr *json.SyntaxError
	if errors.As(err, &serr) {
		fmt.Println("JSON salah di offset:", serr.Offset)
	}
}
```

### Custom JSON handling

```go
// 1. MarshalJSON pada tipe sendiri
type Waktu time.Time

func (w Waktu) MarshalJSON() ([]byte, error) {
	return []byte(`"` + time.Time(w).Format("2006-01-02") + `"`), nil
}

func (w *Waktu) UnmarshalJSON(b []byte) error {
	s := strings.Trim(string(b), `"`)
	t, err := time.Parse("2006-01-02", s)
	if err != nil {
		return err
	}
	*w = Waktu(t)
	return nil
}

// 2. JSON dinamis bila struktur tidak diketahui
var data map[string]any
json.Unmarshal(raw, &data)
// atau
var arr []any
```

---

## 3. Database

### Konsep dasar relational database

- **Tabel** = kumpulan baris dengan kolom bertipe.
- **Primary key** = pengenal unik baris.
- **Foreign key** = relasi antar tabel.
- **SQL dasar:**

```sql
-- membaca
SELECT id, nama FROM produk WHERE harga > 1000 ORDER BY nama LIMIT 10;

-- menambah
INSERT INTO produk (nama, harga, stok) VALUES ('Laptop', 12500000, 5);

-- mengubah
UPDATE produk SET stok = stok - 1 WHERE id = 1;

-- menghapus
DELETE FROM produk WHERE id = 1;
```

### `database/sql` — API standar

`database/sql` adalah **interface saja** — driver database diinstal terpisah:

```go
import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql" // MariaDB/MySQL (register driver)
)
```

> **`_ "package"`** = import untuk **side effect** saja (mendaftarkan driver),
> tanpa memakai identifier-nya.

### Membuka koneksi

```go
func BukaDB() (*sql.DB, error) {
	// DSN: user:password@tcp(host:port)/nama_database?params
	db, err := sql.Open("mysql",
		"root:rootpassword@tcp(localhost:3306)/belajar_go?parseTime=true")
	if err != nil {
		return nil, fmt.Errorf("buka db: %w", err)
	}

	// ⚠️ sql.Open TIDAK membuka koneksi — hanya menyiapkan pool.
	// Verifikasi dengan Ping:
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("ping db: %w", err)
	}

	return db, nil
}
```

### Connection pool

`*sql.DB` adalah **pool koneksi**, bukan satu koneksi:

```go
db.SetMaxOpenConns(25)                  // maksimal koneksi terbuka
db.SetMaxIdleConns(10)                  // maksimal idle di pool
db.SetConnMaxLifetime(5 * time.Minute)  // umur maksimal koneksi
db.SetConnMaxIdleTime(1 * time.Minute)
```

> **Catatan:** satu `*sql.DB` dibuat **sekali di level aplikasi** dan dibagikan,
> bukan dibuat per request.

### `Query`, `QueryRow`, `Exec`, `Rows`, `Scan`

```go
// 1. Query menghasilkan banyak baris
rows, err := db.QueryContext(ctx,
	"SELECT id, nama, harga FROM produk WHERE stok > ?", 0)
if err != nil {
	return err
}
defer rows.Close() // ⚠️ WAJIB selalu Close (defer tepat setelah cek error)

for rows.Next() { // iterasi baris
	var (
		id    int
		nama  string
		harga float64
	)
	if err := rows.Scan(&id, &nama, &harga); err != nil {
		return err
	}
	fmt.Println(id, nama, harga)
}
return rows.Err() // ⚠️ WAJIB cek error akhir iterasi

// 2. QueryRow — tepat satu baris
var nama string
err := db.QueryRowContext(ctx,
	"SELECT nama FROM produk WHERE id = ?", 1).Scan(&nama)
if err != nil {
	if errors.Is(err, sql.ErrNoRows) {
		return ErrNotFound // bukan error database — data tidak ada
	}
	return err
}

// 3. Exec — INSERT/UPDATE/DELETE tanpa hasil baris
res, err := db.ExecContext(ctx,
	"UPDATE produk SET stok = stok - ? WHERE id = ?", 1, 1)
if err != nil {
	return err
}
n, _ := res.RowsAffected() // jumlah baris terpengaruh
if n == 0 {
	return ErrNotFound
}
```

### Scan ke struct dengan `Query` + loop

```go
func (r *ProdukRepo) List(ctx context.Context, minHarga float64) ([]Produk, error) {
	rows, err := r.db.QueryContext(ctx,
		`SELECT id, nama, harga, stok FROM produk
		 WHERE harga >= ? ORDER BY nama`, minHarga)
	if err != nil {
		return nil, fmt.Errorf("list produk: %w", err)
	}
	defer rows.Close()

	var hasil []Produk
	for rows.Next() {
		var p Produk
		if err := rows.Scan(&p.ID, &p.Nama, &p.Harga, &p.Stok); err != nil {
			return nil, fmt.Errorf("scan produk: %w", err)
		}
		hasil = append(hasil, p)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterasi produk: %w", err)
	}
	return hasil, nil
}
```

### Prepared statement

Driver biasanya menyiapkan prepared statement secara internal bila kamu
mengirim argumen terpisah seperti di atas (satu `?` untuk tiap argumen).

Untuk memaksa prepared dan memakainya berulang:

```go
stmt, err := db.PrepareContext(ctx, "SELECT nama FROM produk WHERE id = ?")
if err != nil {
	return err
}
defer stmt.Close()

for _, id := range []int{1, 2, 3} {
	var nama string
	if err := stmt.QueryRowContext(ctx, id).Scan(&nama); err != nil {
		return err
	}
}
```

### Transaction: commit dan rollback

```go
func Transfer(ctx context.Context, db *sql.DB, from, to int, amount float64) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("mulai tx: %w", err)
	}

	// defer rollback = jaring pengaman bila fungsi return sebelum Commit
	defer func() {
		if p := recover(); p != nil {
			_ = tx.Rollback()
			panic(p)
		}
	}()

	if _, err := tx.ExecContext(ctx,
		"UPDATE akun SET saldo = saldo - ? WHERE id = ?", amount, from); err != nil {
		_ = tx.Rollback()
		return fmt.Errorf("kurangi saldo: %w", err)
	}

	if _, err := tx.ExecContext(ctx,
		"UPDATE akun SET saldo = saldo + ? WHERE id = ?", amount, to); err != nil {
		_ = tx.Rollback()
		return fmt.Errorf("tambah saldo: %w", err)
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit: %w", err)
	}
	return nil
}
```

> **Aturan:** semua query dalam transaksi memakai **`tx`**, bukan `db`.
> `Commit` hanya dipanggil **satu kali** di akhir; `Rollback` bila gagal.
> Rollback setelah Commit mengembalikan `sql.ErrTxDone` (bukan error serius).

### Context pada query

```go
// timeout per query
ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
defer cancel()

row := db.QueryRowContext(ctx, "SELECT ...", args...)
// bila melebihi timeout → error context deadline exceeded
```

Semua metode query penting menerima `ctx` pertama — **selalu teruskan context**
dari handler ke repository.

### SQL injection dan parameterized query

```go
// ❌ SANGAT BERBAHAYA — string concatenation
q := "SELECT * FROM produk WHERE nama = '" + nama + "'"
// nama = "' OR '1'='1" → mengembalikan semua data!

// ✅ parameterized query — input TIDAK pernah jadi bagian SQL
q := "SELECT * FROM produk WHERE nama = ?"
db.Query(q, nama)
```

**Aturan:**

- Selalu pakai placeholder `?` (dialect MariaDB/MySQL; PostgreSQL memakai
  placeholder bernomor).
- **Tidak pernah** menyusun SQL dengan `fmt.Sprintf` dari input user.
- Identifier yang dinamis (nama kolom, ORDER BY) **tidak bisa** diparameterkan —
  validasi terhadap whitelist:

```go
kolomDiizinkan := map[string]string{
	"nama": "nama", "harga": "harga",
}
kolom, ada := kolomDiizinkan[sortField]
if !ada {
	return errors.New("kolom sorting tidak valid")
}
q := fmt.Sprintf("SELECT * FROM produk ORDER BY %s %s", kolom, direction)
// direction juga harus divalidasi: hanya "ASC" atau "DESC"
```

### Migration database

Migration = versioned perubahan skema. Cara manual:

```sql
-- migrations/001_init.sql
CREATE TABLE produk (
	id          BIGINT AUTO_INCREMENT PRIMARY KEY,
	nama        TEXT NOT NULL,
	harga       DECIMAL(15,2) NOT NULL DEFAULT 0,
	stok        INT NOT NULL DEFAULT 0,
	created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_produk_nama ON produk (nama);
```

Tool populer: **golang-migrate/migrate**, **pressly/goose**, atau **Atlas**.

```bash
# dengan goose (driver mysql)
goose -dir migrations mysql "root:rootpassword@tcp(localhost:3306)/belajar_go" up
goose -dir migrations mysql "root:rootpassword@tcp(localhost:3306)/belajar_go" status
```

**Aturan migration:**

- Satu arah (tidak edit migration yang sudah jalan di production).
- Bersifat idempoten bila memungkinkan.
- Pisahkan dari kode aplikasi, jalankan sebagai langkah deployment.

### Repository / data access layer

Pola **repository** memisahkan detail SQL dari business logic:

```go
// domain — definisi tipe
type Produk struct {
	ID    int
	Nama  string
	Harga float64
	Stok  int
}

// kontrak (interface di sisi consumer!)
type ProdukRepository interface {
	GetByID(ctx context.Context, id int) (Produk, error)
	List(ctx context.Context, f ProdukFilter) ([]Produk, error)
	Save(ctx context.Context, p *Produk) error
	Delete(ctx context.Context, id int) error
}

// implementasi SQL
type produkRepo struct {
	db *sql.DB
}

func NewProdukRepo(db *sql.DB) ProdukRepository {
	return &produkRepo{db: db}
}

func (r *produkRepo) GetByID(ctx context.Context, id int) (Produk, error) {
	var p Produk
	err := r.db.QueryRowContext(ctx,
		`SELECT id, nama, harga, stok FROM produk WHERE id = ?`, id).
		Scan(&p.ID, &p.Nama, &p.Harga, &p.Stok)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return Produk{}, ErrNotFound
		}
		return Produk{}, fmt.Errorf("get produk %d: %w", id, err)
	}
	return p, nil
}
```

Keuntungan: business logic (service) bisa diuji tanpa database —
service cukup memakai **fake/mock** implementasi interface.

---

## Praktik

### 1. Aplikasi CLI dengan penyimpanan JSON

```go
package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
)

type Tugas struct {
	ID      int    `json:"id"`
	Judul   string `json:"judul"`
	Selesai bool   `json:"selesai"`
}

type BukuTugas struct {
	path  string
	tugas []Tugas
}

func (b *BukuTugas) Muat() error {
	data, err := os.ReadFile(b.path)
	if err != nil {
		if os.IsNotExist(err) {
			return nil // file pertama kali — mulai kosong
		}
		return err
	}
	return json.Unmarshal(data, &b.tugas)
}

func (b *BukuTugas) Simpan() error {
	data, err := json.MarshalIndent(b.tugas, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(b.path, data, 0o644)
}

func (b *BukuTugas) Tambah(judul string) {
	id := 1
	if len(b.tugas) > 0 {
		id = b.tugas[len(b.tugas)-1].ID + 1
	}
	b.tugas = append(b.tugas, Tugas{ID: id, Judul: judul})
}

func (b *BukuTugas) Selesaikan(id int) error {
	for i := range b.tugas {
		if b.tugas[i].ID == id {
			b.tugas[i].Selesai = true
			return nil
		}
	}
	return errors.New("tugas tidak ditemukan")
}

func main() {
	buku := &BukuTugas{path: "tugas.json"}
	if err := buku.Muat(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	buku.Tambah("Belajar Go")
	buku.Tambah("Membuat REST API")
	_ = buku.Selesaikan(1)

	for _, t := range buku.tugas {
		status := "[ ]"
		if t.Selesai {
			status = "[x]"
		}
		fmt.Printf("%d. %s %s\n", t.ID, status, t.Judul)
	}

	if err := buku.Simpan(); err != nil {
		fmt.Println("gagal simpan:", err)
		os.Exit(1)
	}
}
```

### 2. CRUD dengan MariaDB

```go
package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	_ "github.com/go-sql-driver/mysql" // driver MariaDB/MySQL
)

var ErrNotFound = errors.New("tidak ditemukan")

type Produk struct {
	ID    int
	Nama  string
	Harga float64
	Stok  int
}

func main() {
	db, err := sql.Open("mysql",
		"root:rootpassword@tcp(localhost:3306)/belajar_go?parseTime=true")
	if err != nil {
		panic(err)
	}
	defer db.Close()

	ctx := context.Background()

	// CREATE (sekali saat start = migration sederhana)
	_, err = db.ExecContext(ctx, `
		CREATE TABLE IF NOT EXISTS produk (
			id BIGINT AUTO_INCREMENT PRIMARY KEY,
			nama TEXT NOT NULL,
			harga DECIMAL(15,2) NOT NULL DEFAULT 0,
			stok INT NOT NULL DEFAULT 0
		)`)
	if err != nil {
		panic(err)
	}

	// INSERT
	res, err := db.ExecContext(ctx,
		`INSERT INTO produk (nama, harga, stok) VALUES (?, ?, ?)`,
		"Laptop", 12500000, 5)
	if err != nil {
		panic(err)
	}
	id, _ := res.LastInsertId()
	fmt.Println("ID baru:", id)

	// READ
	var p Produk
	err = db.QueryRowContext(ctx,
		`SELECT id, nama, harga, stok FROM produk WHERE id = ?`, id).
		Scan(&p.ID, &p.Nama, &p.Harga, &p.Stok)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			fmt.Println("tidak ada")
			return
		}
		panic(err)
	}
	fmt.Printf("%+v\n", p)

	// UPDATE
	_, err = db.ExecContext(ctx,
		`UPDATE produk SET stok = stok - 1 WHERE id = ?`, id)
	if err != nil {
		panic(err)
	}

	// DELETE
	_, err = db.ExecContext(ctx, `DELETE FROM produk WHERE id = ?`, id)
	if err != nil {
		panic(err)
	}
}
```

> **Catatan:** DSN di atas memakai database `belajar_go` — buat dulu
> (`CREATE DATABASE belajar_go;`) sebelum menjalankan contoh.

### 3. Migration dan transaksi

```go
func Migrasi(db *sql.DB) error {
	migrasi := []string{
		`CREATE TABLE IF NOT EXISTS pengguna (
			id BIGINT AUTO_INCREMENT PRIMARY KEY,
			email TEXT NOT NULL UNIQUE,
			sandi TEXT NOT NULL,
			role TEXT NOT NULL DEFAULT 'user'
		)`,
		`CREATE INDEX idx_pengguna_email ON pengguna (email)`,
	}

	for _, q := range migrasi {
		if _, err := db.Exec(q); err != nil {
			return fmt.Errorf("migrasi gagal: %w", err)
		}
	}
	return nil
}

// transaksi dua langkah yang harus atomik
func AktifkanPaket(ctx context.Context, db *sql.DB, userID int, paket string) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() // no-op bila sudah Commit

	if _, err := tx.ExecContext(ctx,
		`UPDATE pengguna SET paket = ? WHERE id = ?`, paket, userID); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO riwayat (user_id, aksi) VALUES (?, 'aktifkan_paket')`, userID); err != nil {
		return err
	}
	return tx.Commit()
}
```

---

## Checklist Fase 4

- [x] `os.ReadFile`, `os.WriteFile`, `os.Open`, `defer Close`.
- [x] Membaca file besar: `bufio.Scanner`, `io.Copy`.
- [x] `MkdirAll`, `Remove`, `RemoveAll`, `Rename`, `Stat`.
- [x] `path/filepath`: `Join`, `Split`, `WalkDir`.
- [x] Error file: `os.IsNotExist`, `errors.Is(err, fs.ErrNotExist)`.
- [x] JSON: `Marshal`, `Unmarshal`, `MarshalIndent`.
- [x] Struct tag: `omitempty`, `-`, field wajib exported.
- [x] `json.Decoder`, `json.Encoder`, JSON invalid, custom marshaler.
- [x] SQL dasar: SELECT, INSERT, UPDATE, DELETE.
- [x] `database/sql`: `Open`, `Ping`, pool, `Query`, `QueryRow`, `Exec`, `Rows`, `Scan`, `Rows.Close`, `rows.Err`.
- [x] Prepared statement, transaction, commit/rollback.
- [x] Context pada query, SQL injection & parameterized query.
- [x] Migration dan repository layer.

## Ringkasan

- `os.ReadFile/WriteFile` untuk file kecil; `bufio` + `Flush` untuk file besar.
- Struct tag `json` mengatur nama dan opsi; `-` menyembunyikan field.
- `sql.Open` hanya menyiapkan pool — verifikasi dengan `Ping`.
- **Selalu** `defer rows.Close()` dan cek `rows.Err()`.
- Transaksi: satu `BeginTx`, semua query lewat `tx`, `Commit` sekali, `defer Rollback`.
- Parameterized query mencegah SQL injection; whitelist untuk kolom dinamis.

---
<!--
Lanjut ke: [Fase 5 — Testing dan Quality]({{ site.baseurl }}/belajar-go/fase-5-testing-quality/)
-->
