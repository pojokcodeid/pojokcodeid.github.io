---
layout: page
title: Belajar Go (Golang) dari 0 sampai Mahir
permalink: /belajar-go/
---

# Belajar Go (Golang) dari 0 sampai Mahir

Selamat datang di seri tutorial Go (Golang) lengkap — dari nol sampai level mahir.
Seri ini disusun mengikuti roadmap belajar Go dan dirancang untuk dibaca berurutan:
setiap fase memiliki penjelasan konsep, contoh kode yang bisa dijalankan, latihan,
dan mini project.

## Cara Menggunakan Seri Ini

- Ikuti urutan fase dari awal; jangan terburu-buru melewati fondasi.
- Setiap materi disertai latihan kode — ketik ulang kodenya, jangan hanya copy-paste.
- Selesaikan mini project pada setiap fase sebelum lanjut ke fase berikutnya.
- Simpan kode latihan di Git.
- Fokus pada pemahaman dan praktik, bukan menghafal sintaks.

> **Prasyarat:** kemampuan dasar memprogram (variabel, percabangan, loop) sangat membantu,
> tapi tidak wajib — fase 0 dan 1 menjelaskan semuanya dari nol.

## Daftar Isi

| # | Fase | Topik Utama |
|---|------|-------------|
| 0 | [Persiapan Environment]({{ site.baseurl }}/belajar-go/fase-0-persiapan-environment/) | Instalasi Go, `go run`, `go build`, Go module |
| 1 | [Fundamental Go]({{ site.baseurl }}/belajar-go/fase-1-fundamental-go/) | Variabel, tipe data, operator, control flow, fungsi |
| 2 | [Struktur Data dan Tipe Go]({{ site.baseurl }}/belajar-go/fase-2-struktur-data/) | Array, slice, map, pointer, struct, method |
| 3 | [Konsep Go yang Penting]({{ site.baseurl }}/belajar-go/fase-3-konsep-penting/) | Interface, error handling, generics, package, stdlib |
| 4 | [File, JSON, dan Data Persistence]({{ site.baseurl }}/belajar-go/fase-4-file-json-database/) | File system, JSON, database SQL, repository |
| 5 | [Testing dan Quality]({{ site.baseurl }}/belajar-go/fase-5-testing-quality/) | Unit test, benchmark, coverage, linting |
| 6 | [Concurrency dan Parallelism]({{ site.baseurl }}/belajar-go/fase-6-concurrency/) | Goroutine, channel, sync, context, pola concurrency |
| 7 | [HTTP dan REST API]({{ site.baseurl }}/belajar-go/fase-7-http-rest-api/) | `net/http`, routing, middleware, REST, framework |
| 8 | [Backend Architecture]({{ site.baseurl }}/belajar-go/fase-8-backend-architecture/) | Layered/clean architecture, auth, security |
| 9 | [Advanced Go]({{ site.baseurl }}/belajar-go/fase-9-advanced-go/) | Memory, profiling, pprof, reflection, embed |
| 10 | [Distributed Systems dan Integrasi]({{ site.baseurl }}/belajar-go/fase-10-distributed-systems/) | Cache, messaging, reliability pattern |
| 11 | [Deployment dan Production]({{ site.baseurl }}/belajar-go/fase-11-deployment-production/) | Docker, CI/CD, observability, deploy |
| 12 | [Proyek Akhir (Capstone)]({{ site.baseurl }}/belajar-go/fase-12-proyek-akhir/) | REST API production-ready, job system, microservices, CLI |

## Checklist Kompetensi: Siap ke Level Mahir

Setelah menyelesaikan seluruh seri, kamu seharusnya mampu:

- [ ] Menulis kode Go idiomatis.
- [ ] Memahami slice, map, pointer, struct, dan interface.
- [ ] Merancang package yang sederhana dan mudah diuji.
- [ ] Menangani error secara benar.
- [ ] Menulis unit test dan integration test.
- [ ] Memahami goroutine, channel, mutex, dan context.
- [ ] Menghindari race condition dan goroutine leak.
- [ ] Membangun REST API dengan database.
- [ ] Menerapkan authentication dan authorization.
- [ ] Menggunakan profiling untuk mencari bottleneck.
- [ ] Melakukan deployment dan graceful shutdown.
- [ ] Menambahkan logging, metrics, dan tracing.
- [ ] Membaca dokumentasi dan source code library.
- [ ] Menjelaskan trade-off desain yang dipilih.

## Referensi Belajar

- [Go Official Documentation](https://go.dev/doc/)
- [A Tour of Go](https://go.dev/tour/)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go by Example](https://gobyexample.com/)
- [Go Standard Library](https://pkg.go.dev/std)
- [Go Blog](https://go.dev/blog/)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)
- [Go Proverbs](https://go-proverbs.github.io/)

---

## Cara Menjalankan Contoh Kode

Semua contoh dalam seri ini adalah program Go yang valid. Untuk mencobanya:

```bash
# instal Go dari https://go.dev/dl/ lalu cek versi
go version

# buat folder latihan
mkdir latihan-go && cd latihan-go
go mod init latihan-go

# simpan kode contoh ke main.go, lalu jalankan
go run main.go

# atau build menjadi binary
go build -o program . && ./program
```

Mulai dari [Fase 0 — Persiapan Environment]({{ site.baseurl }}/belajar-go/fase-0-persiapan-environment/).
