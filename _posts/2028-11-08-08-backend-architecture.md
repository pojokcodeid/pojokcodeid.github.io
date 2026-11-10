---
layout: post
title: "Fase 8 — Backend Architecture"
date: 2026-11-15 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, architecture, clean-architecture, security, jwt]
permalink: /belajar-go/fase-8-backend-architecture/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Backend Architecture
---

# Backend Architecture

Fase ini membentuk aplikasi backend yang terstruktur: pemisahan lapisan,
pilihan arsitektur yang tepat, serta autentikasi dan keamanan.

## Tujuan

- Menerapkan separation of concerns: handler → service → repository.
- Memahami layered/clean/hexagonal architecture beserta trade-off-nya.
- Melakukan dependency injection secara manual.
- Mengelola konfigurasi dan logging terstruktur.
- Menerapkan auth (password hashing, JWT/session) dan praktik keamanan.

---

## 1. Struktur Aplikasi

### Separation of concerns

Setiap lapisan punya satu tanggung jawab:

```
HTTP Handler  → translate HTTP ↔ DTO, status code, validasi ringan
Service       → business logic, orkestrasi, aturan bisnis
Repository    → akses database, SQL, mapping ke domain
Model/Domain  → tipe inti aplikasi (Produk, User, dst.)
```

**Alur request:**

```
Client → Handler → Service → Repository → DB
              ↑         ↑         ↑
         DTO/HTTP   logika    SQL/query
```

### Contoh lengkap per lapisan

**Domain/model:**

```go
// internal/domain/produk.go
package domain

import (
	"errors"
	"time"
)

type Produk struct {
	ID        int
	Nama      string
	Harga     float64
	Stok      int
	CreatedAt time.Time
}

// error domain — dipahami semua lapisan
var ErrNotFound = errors.New("produk tidak ditemukan")
var ErrConflict = errors.New("produk sudah ada")
```

**Repository (kontrak + implementasi SQL):**

```go
// internal/repository/produk.go
package repository

type ProdukRepository interface {
	GetByID(ctx context.Context, id int) (domain.Produk, error)
	List(ctx context.Context, q ListQuery) ([]domain.Produk, int, error)
	Create(ctx context.Context, p *domain.Produk) error
	Update(ctx context.Context, p *domain.Produk) error
	Delete(ctx context.Context, id int) error
}

type produkRepo struct {
	db *sql.DB
}

func NewProdukRepo(db *sql.DB) ProdukRepository {
	return &produkRepo{db: db}
}

func (r *produkRepo) GetByID(ctx context.Context, id int) (domain.Produk, error) {
	var p domain.Produk
	err := r.db.QueryRowContext(ctx,
		`SELECT id, nama, harga, stok, created_at FROM produk WHERE id = ?`, id).
		Scan(&p.ID, &p.Nama, &p.Harga, &p.Stok, &p.CreatedAt)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return domain.Produk{}, domain.ErrNotFound
		}
		return domain.Produk{}, fmt.Errorf("get produk %d: %w", id, err)
	}
	return p, nil
}
```

**Service (business logic):**

```go
// internal/service/produk.go
package service

type ProdukService struct {
	repo  repository.ProdukRepository
	cache Cache               // interface kecil, opsional
	log   *slog.Logger
}

func NewProdukService(repo repository.ProdukRepository, log *slog.Logger) *ProdukService {
	return &ProdukService{repo: repo, log: log}
}

func (s *ProdukService) Get(ctx context.Context, id int) (domain.Produk, error) {
	p, err := s.repo.GetByID(ctx, id)
	if err != nil {
		s.log.Error("gagal ambil produk", "id", id, "err", err)
		return domain.Produk{}, err
	}
	return p, nil
}

func (s *ProdukService) Create(ctx context.Context, req CreateRequest) (domain.Produk, error) {
	nama, err := validasiNama(req.Nama)
	if err != nil {
		return domain.Produk{}, fmt.Errorf("validasi: %w", err)
	}
	if req.Harga <= 0 {
		return domain.Produk{}, fmt.Errorf("validasi: harga harus > 0")
	}

	p := domain.Produk{Nama: nama, Harga: req.Harga, Stok: req.Stok}
	if err := s.repo.Create(ctx, &p); err != nil {
		return domain.Produk{}, err
	}
	return p, nil
}
```

**Handler (transport HTTP):**

```go
// internal/handler/produk.go
package handler

type ProdukHandler struct {
	svc *service.ProdukService
}

func NewProdukHandler(svc *service.ProdukService) *ProdukHandler {
	return &ProdukHandler{svc: svc}
}

func (h *ProdukHandler) Get(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil {
		kirimError(w, http.StatusBadRequest, "ID_TIDAK_VALID", "id harus angka")
		return
	}

	p, err := h.svc.Get(r.Context(), id)
	if err != nil {
		switch {
		case errors.Is(err, domain.ErrNotFound):
			kirimError(w, http.StatusNotFound, "TIDAK_ADA", "produk tidak ditemukan")
		default:
			kirimError(w, http.StatusInternalServerError, "INTERNAL", "terjadi kesalahan")
		}
		return
	}

	tulisJSON(w, http.StatusOK, toResponse(p))
}
```

### Dependency injection manual

Tidak perlu framework DI — **constructor injection** sudah cukup:

```go
// cmd/server/main.go — composition root (satu-satunya tempat wiring)
func main() {
	cfg := muatConfig()

	db := bukaDB(cfg)
	defer db.Close()

	log := slog.New(slog.NewJSONHandler(os.Stdout, nil))

	// susun dari bawah ke atas
	produkRepo := repository.NewProdukRepo(db)
	produkSvc := service.NewProdukService(produkRepo, log)
	produkHdl := handler.NewProdukHandler(produkSvc)

	userRepo := repository.NewUserRepo(db)
	authSvc := service.NewAuthService(userRepo, cfg.JWTSecret, log)
	authHdl := handler.NewAuthService(authSvc)

	mux := daftarkanRute(produkHdl, authHdl)
	jalankanServer(mux, cfg)
}
```

**Keuntungan:** setiap komponen **tidak tahu** dari mana dependensinya datang —
memudahkan mengganti implementasi (mis. repository palsu saat test).

### Konfigurasi aplikasi

```go
// internal/config/config.go
package config

type Config struct {
	Port         string
	DatabaseURL  string
	JWTSecret    string
	Environment  string // development | production
	ReadTimeout  time.Duration
}

func Load() (*Config, error) {
	cfg := &Config{
		Port:        getEnv("PORT", "8080"),
		DatabaseURL: getEnv("DATABASE_URL", ""),
		JWTSecret:   os.Getenv("JWT_SECRET"),
		Environment: getEnv("ENV", "development"),
	}

	if cfg.DatabaseURL == "" {
		return nil, errors.New("DATABASE_URL wajib diisi")
	}
	if cfg.Environment == "production" && len(cfg.JWTSecret) < 32 {
		return nil, errors.New("JWT_SECRET minimal 32 karakter di production")
	}
	return cfg, nil
}

func getEnv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
```

**Prinsip konfigurasi:**

1. **Environment variable** untuk nilai per-deployment (port, DSN, secret).
2. **Default wajar** untuk pengembangan.
3. **Validasi saat startup** — gagal cepat, jangan crash di tengah jalan.
4. **Jangan commit secret** ke Git. Gunakan `.env` lokal (dev) + secret manager
   (production): AWS Secrets Manager, Vault, GCP Secret Manager.
5. Untuk multi-file config, library populer: `spf13/viper`.

```bash
# .env (dev saja — tambahkan ke .gitignore)
DATABASE_URL=root:rootpassword@tcp(localhost:3306)/belajar_go?parseTime=true
JWT_SECRET=panjang-dan-acak-minimal-32-karakter
PORT=8080
```

### Logging terstruktur

```go
import "log/slog"

// production: JSON ke stdout
log := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
	Level: slog.LevelInfo,
}))

// development: teks yang mudah dibaca
log := slog.New(slog.NewTextHandler(os.Stdout, nil))

// dengan konteks tetap (di-set per request via middleware)
log = log.With("request_id", id, "user_id", uid)

log.Info("produk dibuat",
	"produk_id", p.ID,
	"nama", p.Nama,
	"durasi_ms", elapsed.Milliseconds(),
)
```

**Mengapa bukan `fmt.Println`?**

- JSON bisa di-parse sistem observability (ELK, Datadog, CloudWatch).
- Level (`Debug/Info/Warn/Error`) bisa difilter per environment.
- Field konsisten — bisa dicari dan di-agregasi.

**Aturan:**

- **Jangan pernah** log password, token, atau data kartu.
- Log **error dengan konteks** (id, operasi), bukan hanya `err.Error()`.
- Satu kejadian penting cukup **satu** log — jangan log berlapis di banyak lapisan.
- Teruskan `*slog.Logger` via constructor, atau ambil dari context.

### Error boundary

```go
// lapisan service TIDAK menentukan status HTTP
func (s *ProdukService) Get(ctx context.Context, id int) (domain.Produk, error) {
	p, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return domain.Produk{}, fmt.Errorf("ambil produk %d: %w", id, err)
	}
	return p, nil
}

// handler yang MENERJEMAHKAN error domain → HTTP
switch {
case errors.Is(err, domain.ErrNotFound):
	kirimError(w, http.StatusNotFound, "TIDAK_ADA", "produk tidak ditemukan")
case errors.Is(err, domain.ErrConflict):
	kirimError(w, http.StatusConflict, "DUPLIKAT", "nama sudah dipakai")
default:
	log.Error("internal", "err", err)
	kirimError(w, http.StatusInternalServerError, "INTERNAL", "terjadi kesalahan")
}
```

**Aturan:** error naik dengan **context** (`%w`), diterjemahkan **hanya di
lapisan transport**. Hindari `panic` untuk kondisi bisnis yang wajar.

---

## 2. Arsitektur

### Layered architecture (paling umum)

```
Handler → Service → Repository → Database
   ↑          ↑
 Transport   Business logic
```

- Sederhana, mudah dipahami tim.
- Cocok untuk sebagian besar CRUD API dan aplikasi ukuran sedang.

### Clean architecture (konsep)

Prinsip inti: **dependency rule** — lapisan dalam tidak tahu lapisan luar.

```
        ┌────────────────────────────────────┐
        │  Frameworks/Drivers (HTTP, SQL)    │  ← lapisan terluar
        │  ┌──────────────────────────────┐  │
        │  │  Interface Adapters          │  │  ← handler, repository impl
        │  │  ┌────────────────────────┐  │  │
        │  │  │  Use Cases (Service)   │  │  │
        │  │  │  ┌──────────────────┐  │  │  │
        │  │  │  │  Entities        │  │  │  │  ← domain murni
        │  │  │  └──────────────────┘  │  │  │
        │  │  └────────────────────────┘  │  │
        │  └──────────────────────────────┘  │
        └────────────────────────────────────┘
```

- **Entities**: model domain + aturan bisnis inti.
- **Use cases**: skenario aplikasi (orchestration).
- **Interface adapters**: konversi DTO ↔ entity, implementasi repository.
- **Frameworks/drivers**: `net/http`, `database/sql`.

**Trade-off:**

- ✅ Business logic bebas dari framework/DB — mudah diuji.
- ✅ Ganti transport (HTTP → gRPC → CLI) tanpa menyentuh inti.
- ❌ **Banyak lapisan dan file** — overhead nyata untuk aplikasi kecil.
- ❌ Rawan **overengineering** bila tim tidak paham tujuannya.

### Hexagonal architecture (ports & adapters)

Konsep serupa: **port** (interface yang didefinisikan aplikasi) dan
**adapter** (implementasi eksternal yang dicolokkan).

```go
// PORT — didefinisikan oleh sisi aplikasi (consumer!)
type Notifier interface {
	Kirim(ctx context.Context, ke, pesan string) error
}

// ADAPTER — implementasi eksternal
type EmailNotifier struct{ smtp *smtp.Client }
func (e *EmailNotifier) Kirim(ctx context.Context, ke, pesan string) error { /* ... */ }

type WhatsAppNotifier struct{ api *wa.Client }
func (w *WhatsAppNotifier) Kirim(ctx context.Context, ke, pesan string) error { /* ... */ }

// use case hanya tahu interface Notifier
type PendaftaranService struct {
	notifier Notifier // bisa diganti tanpa mengubah service
}
```

### Domain-driven design dasar

- **Ubiquitous language**: nama kode = bahasa bisnis (bukan `DataMgr`).
- **Aggregate**: cluster objek yang selalu konsisten bersama.
- **Bounded context**: batas di mana arti sebuah istilah berbeda
  (mis. "produk" di katalog vs di gudang = dua model berbeda).
- **Repository pattern**: abstraksi akses ke aggregate.

> DDD penuh (event sourcing, CQRS, aggregate) hanya untuk domain yang benar-benar kompleks.

### Dependency direction dan interface di sisi consumer

```go
// ❌ interface di sisi produsen (repository)
package repository

type ProdukRepository interface {
	GetByID(ctx context.Context, id int) (domain.Produk, error)
}
// → service harus import repository: arah dependensi salah
```

```go
// ✅ interface di sisi consumer (service) — service mendefinisikan
//    sendiri interface yang ia butuhkan
package service

type ProdukRepo interface {
	GetByID(ctx context.Context, id int) (domain.Produk, error)
}
```

**Kenapa?** Service hanya menyatakan **apa yang ia butuhkan** — repository
tinggal memenuhi. Mengubah repository tidak memaksa service berubah.

> **Prinsip Go:** *"The interface belongs to the consumer."* — dan interface
> kecil di sisi pemakai adalah cara paling Go-idiomatic.

### Menghindari overengineering

**Tanda overengineering:**

- Satu interface untuk satu implementasi.
- Factory, strategy, dan abstract factory untuk aplikasi CRUD sederhana.
- 5 lapisan untuk memanggil satu query database.
- `utils`, `helpers`, `common` sebagai tempat sampah kode.

**Pedoman:**

1. Mulai dengan **struktur paling sederhana** yang jalan.
2. Tambah abstraksi saat muncul **kebutuhan kedua** (rule of three).
3. Refactor saat kompleksitas nyata tumbuh — jangan sebelumnya.
4. Setiap lapisan harus punya **alasan yang bisa kamu ucapkan**.

### Memilih struktur berdasarkan kompleksitas

| Skala | Struktur yang disarankan |
|-------|--------------------------|
| Script / tool kecil | Satu folder, beberapa file |
| API sederhana (1-3 resource) | `handler`, `service`, `repo` flat |
| Aplikasi menengah | `internal/{handler,service,repository,domain,config}` |
| Besar / banyak tim | Modul per fitur (`internal/produk`, `internal/user`) + shared |

---

## 3. Authentication dan Security

### Password hashing

```go
import "golang.org/x/crypto/bcrypt"

// hash saat registrasi
func HashSandi(sandi string) (string, error) {
	// cost 12 = cukup berat untuk CPU, wajar untuk login
	hash, err := bcrypt.GenerateFromPassword([]byte(sandi), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hash), nil
}

// verifikasi saat login
func CocokSandi(sandi, hash string) bool {
	// mengembalikan error bila tidak cocok (termasuk hash rusak)
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(sandi)) == nil
}
```

**Aturan keamanan password:**

- **Jangan pernah** menyimpan password plaintext.
- Gunakan **bcrypt** (populer), **Argon2id** (lebih modern), atau **scrypt**.
- **Jangan pakai SHA/MD5** untuk password — terlalu cepat untuk dipecahkan.
- Tambahkan **pepper** (secret tambahan di config) bila threat model memerlukan.
- Selalu beri **pesan error yang sama** untuk "email tidak ada" dan
  "password salah" — cegah user enumeration.
- Terapkan **rate limiting** pada endpoint login.

```go
// ❌ user enumeration
if !adaUser(email) { return "email tidak terdaftar" }
if !cocok { return "password salah" }

// ✅
if !adaUser(email) || !cocokSandi(sandi, user.SandiHash) {
	return "email atau password salah"
}
```

### JWT: access dan refresh token

```go
import "github.com/golang-jwt/jwt/v5"

type Klaim struct {
	UserID int    `json:"uid"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

func BuatAccessToken(secret string, uid int, role string) (string, error) {
	klaim := Klaim{
		UserID: uid,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(15 * time.Minute)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "myapp",
		},
	}
	return jwt.NewWithClaims(jwt.SigningMethodHS256, klaim).
		SignedString([]byte(secret))
}

func BuatRefreshToken(secret string, uid int) (string, error) {
	klaim := jwt.RegisteredClaims{
		Subject:   strconv.Itoa(uid),
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(30 * 24 * time.Hour)),
		Issuer:    "myapp",
	}
	return jwt.NewWithClaims(jwt.SigningMethodHS256, klaim).
		SignedString([]byte(secret))
}

// verifikasi
func ValidasiToken(secret, token string) (*Klaim, error) {
	klaim := &Klaim{}
	t, err := jwt.ParseWithClaims(token, klaim, func(t *jwt.Token) (any, error) {
		// ⚠️ WAJIB verifikasi algoritma — cegah algorithm confusion
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("algoritma tak diizinkan: %v", t.Header["alg"])
		}
		return []byte(secret), nil
	})
	if err != nil || !t.Valid {
		return nil, errors.New("token tidak valid")
	}
	return klaim, nil
}
```

**Alur refresh token:**

```
Login → access token (15 mnt) + refresh token (30 hari)
  ↓
API call pakai access token
  ↓
Access token expired → POST /auth/refresh (pakai refresh token)
  ↓
→ access token baru (+ rotate refresh token)
  ↓
Refresh token dicuri/dipakai ulang → revoke semua sesi user
```

**Praktik terbaik:**

- Simpan refresh token di **DB** (hashed) agar bisa dicabut.
- **Rotate** refresh token setiap dipakai.
- Untuk API browser: refresh token di **HttpOnly cookie**, access token di memori.
- Untuk API mobile: keduanya di secure storage (Keychain/Keystore).

### Session-based authentication

```go
type SesiStore struct {
	mu    sync.Mutex
	sesi  map[string]Sesi // token → data
}

type Sesi struct {
	UserID  int
	Role    string
	Expires time.Time
}

// login: buat token acak panjang, kirim via cookie
func (s *SesiStore) Buat(userID int, role string) string {
	token := acak(32) // crypto/rand, bukan math/rand!
	s.mu.Lock()
	s.sesi[token] = Sesi{
		UserID:  userID,
		Role:    role,
		Expires: time.Now().Add(24 * time.Hour),
	}
	s.mu.Unlock()
	return token
}
```

```go
// set cookie dengan atribut keamanan
http.SetCookie(w, &http.Cookie{
	Name:     "session",
	Value:    token,
	HttpOnly: true,                     // ✅ tidak bisa diakses JS (cegah XSS theft)
	Secure:   true,                     // ✅ hanya over HTTPS
	SameSite: http.SameSiteLaxMode,     // ✅ cegah CSRF (Lax/Strict)
	Path:     "/",
	Expires:  time.Now().Add(24 * time.Hour),
	MaxAge:   86400,
})
```

**JWT vs session:**

| | JWT (stateless) | Session (stateful) |
|---|---|---|
| Penyimpanan | Di klien (tanpa server state) | Di server/DB/Redis |
| Cepat | Ya (verifikasi signature) | Ya (lookup token) |
| Logout global | ❌ Sulit (perlu blocklist) | ✅ Hapus sesi |
| Masa berlaku | Bisa panjang / perlu refresh | Bisa dicabut kapan saja |
| Cocok untuk | API mobile, microservices | Aplikasi web klasik |

### Authorization (role dan permission)

```go
// role-based (RBAC)
func RequireRole(roles ...string, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		klaim := DariContext(r.Context())
		for _, role := range roles {
			if klaim.Role == role {
				next.ServeHTTP(w, r)
				return
			}
		}
		kirimError(w, http.StatusForbidden, "DILARANG", "tidak punya izin")
	})
}

// pemakaian
mux.Handle("GET /admin/pengguna", RequireRole("admin", adminHandler))

// resource-level: pastikan resource milik user
func (h *Handler) GetSaya(w http.ResponseWriter, r *http.Request) {
	klaim := DariContext(r.Context())
	uid, _ := strconv.Atoi(r.PathValue("id"))
	if klaim.UserID != uid && klaim.Role != "admin" {
		kirimError(w, http.StatusForbidden, "DILARANG", "bukan data anda")
		return
	}
}
```

> **⚠️ Selalu cek otorisasi di server** — menyembunyikan tombol di UI bukan otorisasi.

### Validasi input

- **Allowlist** — tentukan format yang diizinkan, bukan blokir yang dilarang.
- Batasi **panjang** input sebelum diproses.
- **Normalisasi** (trim, lowercase email).
- Hindari menerima path/nama file dari user tanpa sanitasi.

```go
var polaEmail = regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$`)

func validasiEmail(s string) error {
	s = strings.ToLower(strings.TrimSpace(s))
	if len(s) > 254 || !polaEmail.MatchString(s) {
		return errors.New("email tidak valid")
	}
	return nil
}
```

### Daftar cepat keamanan

| Ancaman | Pencegahan |
|---------|-----------|
| **SQL injection** | Parameterized query (placeholder `?`) — bukan string concat |
| **XSS** | Escape output HTML, `Content-Security-Policy`, JSON API |
| **CSRF** | SameSite cookie, token CSRF, atau API berbasis header |
| **CORS misconfig** | Whitelist origin, jangan `*` dengan credentials |
| **Brute force login** | Rate limiting + account lockout |
| **Secret bocor** | Env/secret manager, jangan commit, rotasi berkala |
| **Man-in-the-middle** | HTTPS/TLS di semua endpoint |
| **Dependency vulnerable** | `govulncheck`, update berkala |
| **Mass assignment** | DTO terpisah dari model DB |
| **DoS via body** | `http.MaxBytesReader` |

### Secrets management

```go
// ❌ JANGAN
jwtSecret := "rahasia123"          // hardcoded
jwtSecret := os.Getenv("JWT_SECRET") // tanpa validasi

// ✅
secret := os.Getenv("JWT_SECRET")
if cfg.Environment == "production" {
	if len(secret) < 32 {
		log.Fatal("JWT_SECRET tidak diset dengan benar")
	}
}
```

- Dev: `.env` + `gitignore`.
- Production: **secret manager** (Vault, AWS/GCP secret manager).
- **Rotasi** secret secara berkala.
- Pisahkan secret per environment (dev ≠ staging ≠ prod).

### TLS/HTTPS

```go
// wajib HTTPS di production — di depan reverse proxy (nginx/caddy) atau langsung:
srv := &http.Server{
	Addr:    ":8443",
	Handler: mux,
}
log.Fatal(srv.ListenAndServeTLS("cert.pem", "key.pem"))

// atau dengan Go 1.22+ dan Let's Encrypt
// autocert: manager sertifikat otomatis
```

**Praktik:**

- Redirect HTTP → HTTPS.
- HSTS header: `Strict-Transport-Security: max-age=31536000; includeSubDomains`.
- Sertifikat dikelola **reverse proxy** (Caddy/Nginx) atau `golang.org/x/crypto/acme/autocert`.

### Security headers

```go
func SecureHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h := w.Header()
		h.Set("X-Content-Type-Options", "nosniff")
		h.Set("X-Frame-Options", "DENY")
		h.Set("X-XSS-Protection", "0") // modern browser sudah punya CSP
		h.Set("Referrer-Policy", "strict-origin-when-cross-origin")
		h.Set("Content-Security-Policy", "default-src 'self'")
		h.Set("Permissions-Policy", "camera=(), microphone=(), geolocation=()")
		next.ServeHTTP(w, r)
	})
}
```

### Audit log

```go
type AuditLog struct {
	UserID    int
	Action    string    // "login", "hapus_produk", "ubah_role"
	Resource  string
	Detail    string
	IP        string
	Timestamp time.Time
}

// catat SETIAP aksi sensitif — jangan log password/token!
log.Info("audit",
	"user_id", uid,
	"action", "ubah_role",
	"target_user", targetID,
	"old_role", oldRole,
	"new_role", newRole,
	"ip", r.RemoteAddr,
)
```

---

## Praktik

### 1. Backend user management

Bangun endpoint:

```
POST   /api/v1/auth/register     → daftar
POST   /api/v1/auth/login        → dapat access + refresh token
POST   /api/v1/auth/refresh      → perpanjang token
POST   /api/v1/auth/logout       → revoke refresh token
GET    /api/v1/pengguna          → list (admin)
GET    /api/v1/pengguna/{id}     → detail
PATCH  /api/v1/pengguna/{id}     → ubah profil
DELETE /api/v1/pengguna/{id}     → hapus (admin)
```

### 2. Authentication dan authorization

- Hash password dengan bcrypt.
- Terbitkan JWT access (15 mnt) + refresh (30 hari).
- Middleware `Auth` menaruh klaim ke context.
- Middleware `RequireRole` untuk endpoint admin.
- Rate limit pada `/login`.

### 3. Role-based access control

```go
const (
	RoleUser  = "user"
	RoleAdmin = "admin"
)

// izin berbasis resource
func (h *Handler) bolehAkses(klaim Klaim, ownerID int) bool {
	return klaim.UserID == ownerID || klaim.Role == RoleAdmin
}
```

### 4. API dengan struktur service-repository

Terapkan pola lengkap pada satu resource (`produk`):

```
internal/
├── config/
├── domain/       → Produk, User, error
├── repository/   → interface + implementasi SQL
├── service/      → business logic
├── handler/      → HTTP transport
├── middleware/   → auth, logging, CORS
└── cmd/server/main.go  → wiring
```

### 5. Integration test untuk login dan CRUD

```go
//go:build integration

func TestAlurLoginDanCRUD(t *testing.T) {
	db := setupDB(t)        // database test terpisah
	srv := setupServer(t)   // httptest.Server dengan mux penuh

	// 1. register
	resp := postJSON(t, srv.URL+"/api/v1/auth/register", `{"email":"a@b.c","sandi":"rahasia123"}`)
	if resp.StatusCode != http.StatusCreated {
		t.Fatalf("register: %d", resp.StatusCode)
	}

	// 2. login
	resp = postJSON(t, srv.URL+"/api/v1/auth/login", `{"email":"a@b.c","sandi":"rahasia123"}`)
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("login: %d", resp.StatusCode)
	}
	token := ambilToken(t, resp)

	// 3. CRUD dengan token
	resp = postJSON(t, srv.URL+"/api/v1/produk", `{"nama":"Laptop","harga":1000}`)
	req, _ := http.NewRequest(http.MethodGet, srv.URL+"/api/v1/produk/1", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	resp, err = http.DefaultClient.Do(req)
	// ... verifikasi status & body
}
```

---

## Checklist Fase 8

- [x] Separation of concerns: handler, service, repository, model.
- [x] Dependency injection manual (constructor injection), konfigurasi + validasi env.
- [x] Error boundary, logging terstruktur (`slog`).
- [x] Layered architecture, clean architecture (konsep + trade-off), hexagonal, DDD dasar.
- [x] Dependency direction, interface di sisi consumer, hindari overengineering.
- [x] Password hashing (bcrypt/Argon2), JWT access+refresh, session auth.
- [x] Cookie HttpOnly/Secure/SameSite, authorization role/permission.
- [x] Validasi input, SQL injection, CORS, CSRF, rate limiting, secrets, TLS, security headers, audit log.

## Ringkasan

- **Handler → Service → Repository**: setiap lapisan satu tanggung jawab.
- Interface dideklarasikan **di sisi consumer** dan sekecil mungkin.
- Clean/hexagonal architecture membantu **saat kompleksitas nyata** — jangan sebelumnya.
- Hash password dengan bcrypt/Argon2; JWT pendek + refresh panjang; cookie `HttpOnly`.
- Keamanan adalah lapisan: validasi, parameterized query, rate limit, HTTPS, header.

---

Lanjut ke: [Fase 9 — Advanced Go]({{ site.baseurl }}/belajar-go/fase-9-advanced-go/)
