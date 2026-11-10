---
layout: post
title: "Fase 12 — Proyek Akhir (Capstone)"
date: 2026-11-19 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, capstone, project, portfolio]
permalink: /belajar-go/fase-12-proyek-akhir/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Proyek Akhir (Capstone)
---

# Proyek Akhir (Capstone)

Capstone adalah tempat semua materi bertemu. Pilih **satu proyek** untuk
diselesaikan penuh, atau kerjakan bertahap — yang penting sampai
**deployment dan monitoring**, bukan berhenti di "bisa jalan di laptop".

## Tujuan

- Mengintegrasikan seluruh fase (0–11) dalam satu aplikasi nyata.
- Menerapkan kualitas: test, dokumentasi, CI/CD, observability.
- Menghasilkan portfolio yang bisa ditunjukkan ke recruiter/klien.

---

## Proyek A — REST API Production-ready

**Paling direkomendasikan** sebagai proyek pertama — mencakup hampir semua materi.

### Fitur

- [ ] **User authentication**: register, login, refresh token (JWT).
- [ ] **CRUD resource**: minimal 2 resource berelasi (mis. produk ↔ kategori).
- [ ] **Database** MariaDB + `database/sql` (atau SQLx).
- [ ] **Migration** (golang-migrate/goose) + seed data.
- [ ] **Validation** pada semua request masuk.
- [ ] **Pagination, filtering, sorting** pada endpoint list.
- [ ] **Unit test** (service + repository dengan fake) dan **integration test**.
- [ ] **OpenAPI documentation** (`docs/openapi.yaml` atau swaggo).
- [ ] **Structured logging** (`slog` JSON) + request ID.
- [ ] **Docker** (multi-stage) + docker-compose.
- [ ] **CI/CD** (GitHub Actions: lint → test → build → push image → deploy).
- [ ] **Deployment** ke server + reverse proxy + HTTPS.
- [ ] **Monitoring**: `/healthz`, `/readyz`, `/metrics` (Prometheus).

### Struktur folder

```
myapp/
├── cmd/
│   └── server/
│       └── main.go              # wiring & startup
├── internal/
│   ├── config/                  # konfigurasi + validasi env
│   ├── domain/                  # model & error domain
│   ├── repository/              # akses data (interface + SQL)
│   ├── service/                 # business logic
│   ├── handler/                 # HTTP handler + DTO
│   ├── middleware/              # auth, logging, CORS, metrics
│   └── pkg/                     # utilitas bersama (opsional)
├── migrations/                  # SQL migration
├── docs/                        # openapi.yaml
├── deploy/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── systemd/myapp.service
├── .github/workflows/ci.yml
├── go.mod
├── go.sum
└── README.md
```

### Contoh endpoint lengkap

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout

GET    /api/v1/produk?page=1&per_page=20&sort=harga&order=ASC&kategori=laptop
POST   /api/v1/produk
GET    /api/v1/produk/{id}
PUT    /api/v1/produk/{id}
DELETE /api/v1/produk/{id}

GET    /api/v1/kategori
POST   /api/v1/kategori

GET    /healthz
GET    /readyz
GET    /metrics
GET    /version
```

### Urutan pengerjaan

1. **Hari 1–2**: setup project, config, struktur, `go mod`, CI dasar.
2. **Hari 3–5**: repository + migration + model.
3. **Hari 6–8**: service + handler + validasi + pagination.
4. **Hari 9–10**: auth (JWT + middleware) + role.
5. **Hari 11–12**: test (unit + integration) + coverage.
6. **Hari 13–14**: Docker + deploy + reverse proxy + HTTPS.
7. **Hari 15**: logging + metrics + dashboard + dokumentasi + README.

### Kriteria "selesai"

```markdown
□ `go test -race ./...` lulus
□ coverage logic penting ≥ 70%
□ `golangci-lint run` bersih
□ docker compose up berjalan dengan satu perintah
□ Terdeploy dengan HTTPS + health check
□ README: cara menjalankan, endpoint, contoh curl
□ OpenAPI tersedia dan sinkron dengan implementasi
```

---

## Proyek B — Background Job System

**Cocok** bila ingin mendalami concurrency dan reliability (fase 6 & 10).

### Fitur

- [ ] **Producer API**: endpoint menerima job (`POST /jobs`).
- [ ] **Worker**: goroutine pool memproses job.
- [ ] **Queue** Redis atau RabbitMQ (bukan channel in-memory saja).
- [ ] **Retry dengan exponential backoff** + batas percobaan.
- [ ] **Dead-letter handling**: job gagal berulang → tabel/DLQ + alert.
- [ ] **Idempotency**: job diproses sekali meski delivery berulang.
- [ ] **Job status**: `pending`, `processing`, `failed`, `completed` + bisa dicek via API.
- [ ] **Metrics**: antrian, throughput, waktu proses, jumlah gagal.
- [ ] **Deployment** + graceful shutdown (selesaikan job in-flight).

### Contoh job nyata

```
- kirim email (welcome, reset password, notifikasi)
- generate laporan PDF
- resize/optimasi gambar
- kirim webhook ke pihak ketiga
- sinkronisasi data ke sistem lain
```

### Struktur

```
jobapp/
├── cmd/producer/         # API penerima job
├── cmd/worker/           # proses worker terpisah
├── internal/
│   ├── queue/            # abstraksi broker (interface)
│   ├── job/              # definisi job + registry handler
│   ├── worker/           # pool, retry, DLQ
│   └── store/            # status job di database
```

### Tantangan tambahan

- Tambahkan **rate limiting** per jenis job.
- Tambahkan **prioritas** (urgent vs bulk).
- Buat **dashboard sederhana** untuk melihat antrian.

---

## Proyek C — Microservices Mini

**Cocok** untuk memahami distributed systems (fase 10).

### Fitur

- [ ] **Service user**: registrasi, profil, auth.
- [ ] **Service product/order**: katalog dan pemesanan.
- [ ] **Komunikasi** HTTP (REST) — opsional gRPC untuk perbandingan.
- [ ] **Message broker** (RabbitMQ/Kafka) untuk event async
      (`order.created` → notifikasi user).
- [ ] **Database per service** (database per layanan — jangan dibagi).
- [ ] **Observability**: request ID lintas service + tracing.
- [ ] **Docker Compose** menjalankan semua layanan + broker + DB.
- [ ] **Failure handling**: timeout, retry, circuit breaker, fallback.
- [ ] **Dokumentasi arsitektur**: diagram alur, keputusan desain, trade-off.

### Layout

```
microservices/
├── services/
│   ├── user/         # service terpisah, bisa di-build sendiri
│   │   ├── cmd/
│   │   ├── internal/
│   │   ├── Dockerfile
│   │   └── go.mod    # module terpisah!
│   └── order/
│       ├── cmd/
│       ├── internal/
│       ├── Dockerfile
│       └── go.mod
├── shared/           # paket bersama (opsional — hati-hati jadi god-package)
├── docker-compose.yml
├── gateway/          # API gateway / BFF sederhana
└── docs/architecture.md
```

### Diagram yang harus kamu buat

1. **Context diagram** — siapa saja yang berinteraksi dengan sistem.
2. **Sequence diagram** — alur `POST /orders` end-to-end.
3. **Event flow** — siapa menerbitkan dan memproses tiap event.
4. **Failure scenarios** — apa yang terjadi bila service X down.

---

## Proyek D — CLI Developer Tool

**Cocok** untuk mendalami stdlib, testing, dan distribusi binary (fase 1, 5, 9).

### Fitur

- [ ] **Command dan subcommand** (mis. `mytool add`, `mytool list`, `mytool export`).
- [ ] **Flag dan konfigurasi** (`flag` atau `spf13/cobra` untuk struktur cobra-style).
- [ ] **File input/output** (`--input`, `--output`, format yaml/json/toml).
- [ ] **Logging** dengan level (`--verbose`, `--quiet`) dan output ke stderr.
- [ ] **Error handling** yang ramah: pesan jelas + exit code benar.
- [ ] **Unit test** untuk logika inti.
- [ ] **Build binary lintas platform** (`GOOS`/`GOARCH`, goreleaser).
- [ ] **Dokumentasi penggunaan**: `README.md` + `--help` yang informatif.

### Contoh ide tool

```
✓ converter format data (CSV ↔ JSON ↔ YAML)
✓ scaffolder project (generates boilerplate)
✓ client API sederhana (postman-like, dari terminal)
✓ log analyzer (filter, agregasi, report)
✓ dummy data generator (faker untuk testing)
✓ dotfiles manager / dev environment bootstrapper
```

### Contoh dengan stdlib `flag`

```go
func main() {
	if len(os.Args) < 2 {
		tampilkanHelp()
		os.Exit(2)
	}

	switch os.Args[1] {
	case "add":
		fs := flag.NewFlagSet("add", flag.ExitOnError)
		judul := fs.String("judul", "", "judul tugas (wajib)")
		prioritas := fs.Int("prioritas", 3, "1-5, default 3")
		_ = fs.Parse(os.Args[2:])

		if *judul == "" {
			fmt.Fprintln(os.Stderr, "error: --judul wajib diisi")
			fs.Usage()
			os.Exit(2)
		}
		tambah(*judul, *prioritas)

	case "list":
		fs := flag.NewFlagSet("list", flag.ExitOnError)
		format := fs.String("format", "text", "text|json")
		_ = fs.Parse(os.Args[2:])
		list(*format)

	case "help", "--help", "-h":
		tampilkanHelp()

	default:
		fmt.Fprintf(os.Stderr, "command tidak dikenal: %s\n", os.Args[1])
		os.Exit(1)
	}
}
```

### Exit code yang konsisten

| Code | Arti |
|------|------|
| `0` | Sukses |
| `1` | Error umum / gagal proses |
| `2` | Penggunaan salah (usage error) |

---

## Tips Sukses Mengerjakan Capstone

1. **Mulai dari inti** — buat alur utama jalan dulu (happy path), baru fitur tambahan.
2. **Commit kecil dan sering** — commit per fitur, bukan "semua sekaligus di malam terakhir".
3. **Tulis README sejak awal** — cara menjalankan, kenapa desainnya begitu.
4. **Test saat menulis**, bukan di akhir.
5. **Deploy lebih awal** — masalah deployment paling cepat ketemu saat dicoba sejak hari pertama.
6. **Dokumentasikan keputusan** — `docs/adr/0001-pilih-mariadb.md` menunjukkan kemampuan berpikir teknis.
7. **Jangan overengineering** — pilih teknologi sesuai kebutuhan, bukan tren.

### README minimal yang baik

````markdown
# Nama Proyek

Deskripsi singkat: apa, untuk siapa, masalah apa yang diselesaikan.

## Fitur
- ...

## Arsitektur
Penjelasan singkat + diagram.

## Menjalankan
```bash
git clone ...
docker compose up -d
curl localhost:8080/healthz
```

## Konfigurasi
Tabel env var + keterangan.

## API
Tautan ke OpenAPI / daftar endpoint.

## Testing
```bash
go test -race ./...
```

## Deployment
Langkah singkat.
````

---

## Checklist Kompetensi: Siap ke Level Mahir

Setelah menyelesaikan capstone, evaluasi diri:

- [ ] Mampu menulis kode Go idiomatis.
- [ ] Memahami slice, map, pointer, struct, dan interface.
- [ ] Mampu merancang package yang sederhana dan mudah diuji.
- [ ] Mampu menangani error secara benar (wrapping, `errors.Is`/`As`).
- [ ] Mampu menulis unit test dan integration test.
- [ ] Memahami goroutine, channel, mutex, dan context.
- [ ] Mampu menghindari race condition dan goroutine leak.
- [ ] Mampu membangun REST API dengan database.
- [ ] Mampu menerapkan authentication dan authorization.
- [ ] Mampu menggunakan profiling untuk mencari bottleneck.
- [ ] Mampu melakukan deployment dan graceful shutdown.
- [ ] Mampu menambahkan logging, metrics, dan tracing.
- [ ] Mampu membaca dokumentasi dan source code library.
- [ ] Mampu menjelaskan trade-off desain yang dipilih.

> **Bila ada yang belum tercentang** — kembali ke fase terkait, kerjakan
> latihannya, lalu evaluasi lagi. Tidak apa-apa mengulang.

---

## Referensi Belajar Lanjutan

### Dokumentasi resmi (wajib)

- [Go Official Documentation](https://go.dev/doc/)
- [A Tour of Go](https://go.dev/tour/) — tutorial interaktif resmi
- [Effective Go](https://go.dev/doc/effective_go) — gaya dan filosofi Go
- [Go by Example](https://gobyexample.com/) — contoh berbasis kasus
- [Go Standard Library](https://pkg.go.dev/std) — referensi stdlib
- [Go Blog](https://go.dev/blog/) — tulisan tim Go (sangat berharga)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)
- [Go Proverbs](https://go-proverbs.github.io/)

### Buku

- *The Go Programming Language* — Alan Donovan & Brian Kernighan (terbaik untuk fondasi)
- *Concurrency in Go* — Katherine Cox-Buday (wajib untuk fase 6)
- *Learning Go* — Jon Bodner (pembaruan modern, mencakup generics)
- *100 Go Mistakes and How to Avoid Them* — Teiva Harsanyi

### Latihan dan praktik

- [Exercism — Go track](https://exercism.org/tracks/go) — latihan + mentoring
- [Advent of Code](https://adventofcode.com/) — tantangan algoritma tahunan
- Membaca source code proyek open-source Go:
  - [`golang/go`](https://github.com/golang/go) — compiler & stdlib-nya
  - [`prometheus/prometheus`](https://github.com/prometheus/prometheus)
  - [`traefik/traefik`](https://github.com/traefik/traefik) — proxy modern
  - [`go-gitea/gitea`](https://github.com/go-gitea/gitea) — aplikasi web lengkap

### Komunitas

- [Go forum](https://forum.go.dev/)
- [Gophers Slack](https://gophers.slack.com/)
- Reddit r/golang
- Meetup Go lokal (Jakarta Gophers, Bandung Gophers, dll.)

---

## Catatan Belajar

### Progress

- **Fase saat ini:**
- **Tanggal mulai:**
- **Target selesai:**
- **Proyek yang sedang dikerjakan:**

### Catatan / Kendala

-
-
-

### Ide Project Berikutnya

-
-
-

---

🎉 **Selamat!** Kamu telah menyelesaikan seri *Belajar Go dari 0 sampai Mahir*.
Langkah terbaik berikutnya: **bangun sesuatu yang nyata**, bagikan ke GitHub,
dan terus membaca source code Go.

Kembali ke [Daftar Isi]({{ site.baseurl }}/belajar-go/).
