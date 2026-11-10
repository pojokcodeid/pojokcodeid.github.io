---
layout: post
title: "Fase 0 — Persiapan Environment"
date: 2026-11-07 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, pemula, environment, go-mod]
permalink: /belajar-go/fase-0-persiapan-environment/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Persiapan Environment GO
---

# Persiapan Environment

Fase ini menyiapkan lingkungan pengembangan Go dan memahami alur kerja dasar
sebelum menulis kode yang serius.

## Tujuan

- Mengenal Go dan karakteristiknya.
- Memahami compiler, runtime, dan executable Go secara garis besar.
- Instalasi Go dan memeriksa versinya.
- Memahami struktur workspace/project Go.
- Mengenal perintah `go run`, `go build`, `go fmt`, `go vet`.
- Mengenal Go Playground.
- Menggunakan editor/IDE dan ekstensi Go.
- Membuat project pertama dengan `go mod init`.

---

## 1. Mengenal Go

Go (Golang) adalah bahasa pemrograman yang dibuat di Google oleh Robert Griesemer,
Rob Pike, dan Ken Thompson, dirilis publik pada tahun 2009. Go dirancang untuk
menulis software yang sederhana, mudah dibaca, dan mudah di-*deploy* dalam skala besar.

### Karakteristik Go

- **Statically typed dengan type inference** — tipe data dicek saat kompilasi,
  tapi `:=` membuat penulisan variabel lebih ringkas.
- **Compiled** — kode dikompilasi menjadi binary native, bukan dijalankan lewat interpreter.
- **Single binary** — hasil build adalah satu file executable tanpa dependensi runtime
  (memudahkan deployment).
- **Fast compilation** — kompilasi Go dirancang cepat bahkan untuk codebase besar.
- **Garbage collected** — manajemen memori ditangani runtime.
- **Concurrency built-in** — goroutine dan channel menjadi fitur bahasa.
- **Standard library kaya** — HTTP server, JSON, crypto, testing, dan lainnya
  tersedia tanpa dependensi eksternal.
- **Formatting baku** — `gofmt` menyeragamkan gaya kode, menghilangkan debat format.

### Kapan Go cocok dipakai

- REST API dan microservices.
- CLI tools dan developer tools.
- Infrastructure/DevOps (Docker, Kubernetes, Terraform, dan banyak tool lain ditulis di Go).
- Sistem yang membutuhkan throughput tinggi dan pemakaian memory rendah.
- Concurrent processing (download, scraping, worker queue).

### Kapan Go kurang cocok

- UI desktop/mobile (ekosistemnya bukan di sana).
- Prototyping sangat cepat — Python/JS biasanya lebih ringkas.
- Machine learning / data science ekosistemnya masih kecil.

---

## 2. Compiler, Runtime, dan Executable

Go adalah bahasa **compiled**. Alurnya:

```
source code (.go)
      │  go build
      ▼
object/binary (executable native)
      │  dijalankan di OS
      ▼
program berjalan (menggunakan runtime Go di dalam binary)
```

Poin penting:

- **Compiler** (`go build`) menerjemahkan kode Go menjadi mesin code native
  untuk OS dan arsitektur target.
- **Runtime Go** *ditanam di dalam* binary (termasuk garbage collector dan scheduler
  goroutine), sehingga kamu tidak perlu menginstal Go di server production —
  cukup binary-nya.
- Hasil build berbeda untuk tiap kombinasi OS/architecture. Contoh: binary Linux
  tidak bisa langsung dijalankan di macOS.

Perintah untuk melihat daftar target lintas platform:

```bash
go tool dist list
```

Contoh output:

```
darwin/amd64
darwin/arm64
linux/amd64
linux/arm64
windows/amd64
...
```

---

## 3. Instalasi Go

### macOS

```bash
brew install go
```

Atau unduh installer dari <https://go.dev/dl/>.

### Windows

Unduh installer `.msi` dari <https://go.dev/dl/> lalu jalankan.

### Linux (Debian/Ubuntu)

```bash
# cara resmi: unduh tarball ke /usr/local
wget https://go.dev/dl/go1.27.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.27.3.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc
```

### Verifikasi instalasi

```bash
go version
```

Output contoh:

```
go version go1.27.3 darwin/arm64
```

### Variabel lingkungan penting

```bash
go env GOPATH    # lokasi workspace pribadi (default: ~/go)
go env GOROOT    # lokasi instalasi Go
go env GOPROXY   # proxy untuk mengunduh module (default proxy.golang.org)
```

---

## 4. Struktur Workspace dan Project Go

### Model lama (GOPATH) vs model modern (Go Modules)

Dulu Go menggunakan **GOPATH**: semua project harus berada di `~/go/src`.
Model ini sudah ditinggalkan. Sekarang semua project menggunakan **Go Modules** —
project bisa berada di mana saja di filesystem.

### Struktur project modern

```
my-project/
├── go.mod          # identitas module + daftar dependency
├── go.sum          # checksum dependency (dibuat otomatis)
├── main.go         # titik masuk program (package main)
├── internal/       # package internal (tidak bisa di-import luar)
├── pkg/            # package publik (opsional)
└── README.md
```

Aturan sederhana:

- Folder = package.
- Nama package biasanya nama folder terakhir (`folder util` → `package util`).
- File dengan `package main` dan fungsi `main()` adalah titik masuk program.

---

## 5. Go Playground

<https://go.dev/play> adalah REPL/penyunting online resmi untuk mencoba Go
tanpa instalasi. Cocok untuk bereksperimen cepat.

Catatan: Playground membatasi waktu eksekusi dan tidak memiliki akses jaringan,
jadi program yang membaca input keyboard tidak berjalan di sana.

---

## 6. Editor / IDE

Rekomendasi:

- **VS Code** + ekstensi resmi **Go** (`golang.go`) — paling umum.
- **GoLand** (JetBrains) — fitur refactoring paling lengkap.
- **Neovim/Vim** dengan `gopls` (language server Go).

Saat pertama membuka project Go, VS Code akan menawarkan instalasi tool:

```
gopls          # language server
dlv            # debugger
gofumpt/godoc  # formatter, docs
```

Setujui instalasinya — tool-tool ini penting untuk autocomplete dan debugging.

---

## 7. Perintah Go Dasar

### `go run` — jalankan langsung

```bash
go run main.go
```

Mengompilasi ke tempat lalu langsung menjalankan. Tidak menyisakan file binary.
Ideal untuk development.

### `go build` — hasilkan executable

```bash
go build -o program .
# hasilkan binary "program" (di Windows: program.exe)
./program
```

### `go fmt` — format kode

```bash
gofmt -w .        # format semua file di folder saat ini
gofmt -l .        # hanya tampilkan file yang belum terformat
```

> **Catatan:** ekstensi VS Code biasanya format otomatis saat menyimpan.
> Format bukan sekadar gaya — komunitas Go menyeragamkannya lewat `gofmt`.

### `go vet` — analisis statis

```bash
go vet ./...
```

`go vet` mendeteksi kode yang *mungkin* salah tapi lolos kompilasi, misalnya
format string yang salah atau method yang tidak dipanggil benar.

### Perintah lain yang sering dipakai

```bash
go test ./...      # jalankan test
go mod init <nama> # inisialisasi module
go mod tidy        # bersihkan + rapikan dependency
go get <package>   # tambahkan dependency
go doc fmt.Println # tampilkan dokumentasi fungsi
```

---

## 8. Go Module: `go mod init`

**Module** adalah kumpulan paket Go yang dikelola bersama dan memiliki versi.
Setiap project minimal punya satu module.

```bash
mkdir belajar-go && cd belajar-go
go mod init belajar-go
```

Menghasilkan `go.mod`:

```
module belajar-go

go 1.27
```

- Baris `module` = path import project kamu (`import "belajar-go/..."`).
- Baris `go` = versi minimum Go yang dibutuhkan.

`go.sum` akan dibuat otomatis saat kamu menambah dependency — berisi checksum
tiap versi dependency untuk keamanan. **Jangan dihapus atau diedit manual.**

### Menambah dependency

```bash
go get github.com/google/uuid@v1.6.0
```

Setelah menambah/menghapus import, jalankan:

```bash
go mod tidy
```

`go mod tidy` menambahkan module yang dipakai dan menghapus yang tidak dipakai.

---

## Praktik

### Latihan 1 — Hello World

Buat folder `latihan`, inisialisasi module, lalu tulis `main.go`:

```bash
mkdir latihan && cd latihan
go mod init latihan
```

```go
// file: main.go
package main

import "fmt"

func main() {
	fmt.Println("Hello, Go!")
}
```

Jalankan:

```bash
go run main.go
# output: Hello, Go!
```

### Latihan 2 — Build executable

```bash
go build -o hello .
./hello
```

Perhatikan bahwa file `hello` dibuat dan bisa dijalankan tanpa `go run`.

### Latihan 3 — Lintas platform build

```bash
GOOS=linux GOARCH=amd64 go build -o hello-linux .
file hello-linux
# ELF 64-bit LSB executable ... Linux
```

`GOOS`/`GOARCH` memungkinkan membangun binary untuk OS lain dari mesin kamu.

---

## Checklist Fase 0

- [x] Mengenal Go dan karakteristiknya.
- [x] Memahami compiler, runtime, dan executable Go secara garis besar.
- [x] Instalasi Go.
- [x] Memeriksa versi Go dengan `go version`.
- [x] Memahami struktur workspace/project Go.
- [x] Mengenal `go run`.
- [x] Mengenal `go build`.
- [x] Mengenal `go fmt`.
- [x] Mengenal `go vet`.
- [x] Mengenal Go Playground.
- [x] Menggunakan editor/IDE dan ekstensi Go.
- [x] Membuat project pertama dengan `go mod init`.
- [x] Membuat program Hello World.
- [x] Menjalankan program dengan `go run`.
- [x] Menghasilkan executable dengan `go build`.

## Ringkasan

- Go adalah bahasa compiled, statically typed, dengan stdlib yang kaya dan concurrency built-in.
- Project modern memakai **Go Modules** (`go.mod`), bukan GOPATH.
- `go run` untuk development, `go build` untuk menghasilkan binary.
- Selalu jalankan `gofmt` dan `go vet` sebelum menganggap kode selesai.
- `go mod tidy` menjaga dependency tetap bersih.

---

Lanjut ke: [Fase 1 — Fundamental Go]({{ site.baseurl }}/belajar-go/fase-1-fundamental-go/)
