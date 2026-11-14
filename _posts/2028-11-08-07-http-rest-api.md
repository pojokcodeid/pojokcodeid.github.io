---
layout: post
title: "Fase 7 — HTTP dan REST API"
date: 2026-11-14 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, http, rest-api, middleware, gin]
permalink: /belajar-go/fase-7-http-rest-api/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: HTTP dan REST API
---

# HTTP dan REST API

Stdlib Go (`net/http`) sudah sangat lengkap — kamu bisa membangun REST API
production tanpa framework. Fase ini dimulai dari dasar HTTP sampai framework.

## Tujuan

- Memahami HTTP request/response, method, status code, header.
- Membangun HTTP server dengan `net/http`, routing, middleware.
- Merancang REST API: CRUD, validasi, pagination, error konsisten.
- Menambahkan auth, CORS, rate limiting, dokumentasi OpenAPI.
- Membandingkan framework (Gin, Echo, Chi).

---

## 1. HTTP Fundamental

### Request dan response

```
GET /api/produk?kategori=laptop&page=1 HTTP/1.1
Host: localhost:8080
Authorization: Bearer <token>
Accept: application/json

─────────────────────────────────

HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: max-age=60

{"data": [...], "page": 1}
```

### Method HTTP

| Method | Arti | Idempoten | Body |
|--------|------|-----------|------|
| `GET` | Ambil data | Ya | Tidak boleh (biasanya) |
| `POST` | Buat data baru | Tidak | Ya |
| `PUT` | Ganti seluruh data | Ya | Ya |
| `PATCH` | Ubah sebagian | Tidak | Ya |
| `DELETE` | Hapus data | Ya | Opsional |

**Idempoten** = permintaan berulang menghasilkan efek yang sama
(aman dipanggil ulang, mis. saat retry).

### Status code

| Kelas | Arti | Contoh |
|-------|------|--------|
| 2xx | Sukses | `200 OK`, `201 Created`, `204 No Content` |
| 3xx | Redirect | `301 Moved Permanently`, `304 Not Modified` |
| 4xx | Error client | `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict`, `422 Unprocessable Entity`, `429 Too Many Requests` |
| 5xx | Error server | `500 Internal Server Error`, `503 Service Unavailable` |

**Bedanya 401 vs 403:**

- `401 Unauthorized` — belum login / token tidak valid (identitas tak dikenal).
- `403 Forbidden` — sudah login tapi tidak punya izin.

### Header penting

| Header | Fungsi |
|--------|--------|
| `Content-Type` | Tipe isi body (`application/json`) |
| `Accept` | Tipe yang diharapkan klien |
| `Authorization` | Token: `Bearer <jwt>` |
| `Cache-Control` | Instruksi cache |
| `X-Request-Id` | ID request untuk tracing |
| `Set-Cookie` | Menyetel cookie |

### Query, path, dan body parameter

```
GET    /api/produk?kategori=laptop   → query parameter
GET    /api/produk/123               → path parameter
POST   /api/produk                   → request body (JSON)
```

---

## 2. HTTP Server Go

### Server pertama

```go
package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Halo dari Go!")
	})

	mux.HandleFunc("GET /halo/{nama}", func(w http.ResponseWriter, r *http.Request) {
		nama := r.PathValue("nama") // path parameter (Go 1.22+)
		fmt.Fprintf(w, "Halo, %s!\n", nama)
	})

	srv := &http.Server{
		Addr:         ":8080",
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("server berjalan di :8080")
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}
}
```

> **Catatan:** sejak **Go 1.22**, `ServeMux` mendukung method + path parameter
> (`"GET /produk/{id}"`) — routing bawaan sudah memadai untuk banyak kasus.

### `http.Handler` dan `http.HandlerFunc`

```go
// Handler = interface inti HTTP di Go
type Handler interface {
	ServeHTTP(w http.ResponseWriter, r *http.Request)
}

// HandlerFunc = adapter fungsi biasa menjadi Handler
func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "halo")
}

// pemakaian
mux.Handle("/x", http.HandlerFunc(handler))
// atau singkat (ServeMux.HandleFunc otomatis mengonversi):
mux.HandleFunc("/x", handler)
```

**Semua middleware/framework di Go pada akhirnya mengimplementasikan `http.Handler`.**

### Membaca request

```go
func buatProduk(w http.ResponseWriter, r *http.Request) {
	// 1. method check (bila routing tidak menanganinya)
	if r.Method != http.MethodPost {
		w.Header().Set("Allow", http.MethodPost)
		http.Error(w, "method tidak diizinkan", http.StatusMethodNotAllowed)
		return
	}

	// 2. query parameter
	kategori := r.URL.Query().Get("kategori")       // string
	page := r.URL.Query().Get("page")               // string, parse manual
	hargaMin := r.URL.Query().Get("harga_min")

	// 3. path parameter (Go 1.22+)
	id := r.PathValue("id")

	// 4. header
	token := r.Header.Get("Authorization")

	// 5. body JSON — batasi ukuran body!
	r.Body = http.MaxBytesReader(w, r.Body, 1<<20) // maks 1 MB
	var req BuatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "JSON tidak valid", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	// 6. form data (application/x-www-form-urlencoded atau multipart)
	if err := r.ParseForm(); err == nil {
		nilai := r.FormValue("field")
		_ = nilai
	}
}
```

### Menulis response

```go
// 1. JSON (paling umum untuk API)
func tulisJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)               // ⚠️ PANGGIL SEBELUM menulis body
	if err := json.NewEncoder(w).Encode(data); err != nil {
		// header sudah terkirim — hanya bisa log
		log.Printf("gagal encode response: %v", err)
	}
}

// 2. JSON error konsisten
type APIError struct {
	Message string `json:"message"`
	Code    string `json:"code,omitempty"`
}

// 3. teks biasa
fmt.Fprintln(w, "halo")

// 4. redirect
http.Redirect(w, r, "/login", http.StatusFound)

// 5. file
http.FileServer(http.Dir("./static")).ServeHTTP(w, r)
```

> **⚠️** `WriteHeader` hanya efektif **sekali dan sebelum** body ditulis.
> Memanggilnya dua kali menghasilkan warning `"superfluous WriteHeader call"`.

### Membaca dan memodifikasi header

```go
w.Header().Set("X-Content-Type-Options", "nosniff")
w.Header().Add("Set-Cookie", "session=abc; HttpOnly; Secure")

// status default = 200 bila tidak dipanggil
w.WriteHeader(http.StatusCreated)
```

### Routing dengan Go 1.22+

```go
mux := http.NewServeMux()

// method + wildcard
mux.HandleFunc("GET /api/produk", listProduk)
mux.HandleFunc("GET /api/produk/{id}", getProduk)
mux.HandleFunc("POST /api/produk", buatProduk)
mux.HandleFunc("PUT /api/produk/{id}", updateProduk)
mux.HandleFunc("DELETE /api/produk/{id}", hapusProduk)

// wildcard akhir = catch-all untuk static file
mux.Handle("GET /static/", http.StripPrefix("/static/",
	http.FileServer(http.Dir("./static"))))

// rute khusus lebih diprioritaskan daripada catch-all
```

### Middleware

Middleware = fungsi yang membungkus `http.Handler`:

```go
type Middleware func(http.Handler) http.Handler

// 1. logging
func Logging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		sw := &statusWriter{ResponseWriter: w, status: http.StatusOK}

		next.ServeHTTP(sw, r) // lanjut ke handler berikutnya

		log.Printf("%s %s → %d (%v)",
			r.Method, r.URL.Path, sw.status, time.Since(start))
	})
}

// helper untuk menangkap status code yang ditulis handler
type statusWriter struct {
	http.ResponseWriter
	status int
}

func (w *statusWriter) WriteHeader(code int) {
	w.status = code
	w.ResponseWriter.WriteHeader(code)
}

// 2. recovery dari panic
func Recover(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				log.Printf("panic: %v", err)
				http.Error(w, "internal server error", http.StatusInternalServerError)
			}
		}()
		next.ServeHTTP(w, r)
	})
}

// 3. request ID + context
func RequestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		id := r.Header.Get("X-Request-Id")
		if id == "" {
			id = uuid.NewString()
		}
		w.Header().Set("X-Request-Id", id)
		ctx := context.WithValue(r.Context(), requestIDKey{}, id)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// 4. CORS
func CORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// penyusunan (middleware terakhir = paling luar)
mux := http.NewServeMux()
// ... daftarkan rute
var h http.Handler = mux
h = Recover(h)
h = RequestID(h)
h = Logging(h)
h = CORS(h)
```

**Prinsip:** middleware dijalankan berlapis — `Recover → RequestID → Logging → CORS → handler`.
Urutan penting: `Recover` harus **paling luar** agar menangkap panic dari semua lapisan.

### Request context

```go
func handler(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context() // sudah berisi cancellation dari koneksi klien

	// bila klien menutup koneksi, ctx.Done() tertutup
	select {
	case <-ctx.Done():
		log.Println("klien memutus koneksi")
		return
	default:
	}

	// teruskan ke service/repository
	data, err := service.Ambil(ctx, id)
	_ = data
	_ = err
}
```

> **Aturan:** `r.Context()` selalu diteruskan ke semua operasi I/O
> (query DB, HTTP call) sehingga pembatalan otomatis merambat.

### Timeout server

```go
srv := &http.Server{
	Addr:              ":8080",
	Handler:           mux,
	ReadHeaderTimeout: 2 * time.Second,  // ⚠️ lindungi dari slowloris
	ReadTimeout:       5 * time.Second,
	WriteTimeout:      10 * time.Second,
	IdleTimeout:       60 * time.Second,
}
```

Untuk timeout per-handler:

```go
ctx, cancel := context.WithTimeout(r.Context(), 3*time.Second)
defer cancel()
result, err := service.Proses(ctx)
```

### Graceful shutdown

```go
func main() {
	srv := &http.Server{Addr: ":8080", Handler: mux}

	go func() {
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("server error: %v", err)
		}
	}()
	log.Println("server berjalan di :8080")

	// tunggu sinyal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit
	log.Println("mematikan server...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// berhenti menerima request baru, tunggu yang berjalan selesai
	if err := srv.Shutdown(ctx); err != nil {
		log.Printf("shutdown dipaksa: %v", err)
		srv.Close()
	}
	log.Println("server berhenti dengan bersih")
}
```

### Static file server

```go
mux.Handle("GET /static/", http.StripPrefix("/static/",
	http.FileServer(http.Dir("./static"))))

// embed file ke dalam binary (fase 9 membahas lebih lanjut)
//go:embed static
var staticFS embed.FS
mux.Handle("/static/", http.FileServer(http.FS(staticFS)))
```

---

## 3. REST API

### Merancang endpoint REST

Resource-based, konsisten, dan predictable:

```
GET    /api/v1/produk           → list (dengan query param)
POST   /api/v1/produk           → create
GET    /api/v1/produk/{id}      → detail
PUT    /api/v1/produk/{id}      → update penuh
PATCH  /api/v1/produk/{id}      → update sebagian
DELETE /api/v1/produk/{id}      → hapus

GET    /api/v1/produk/{id}/ulasan → sub-resource
```

**Konvensi:**

- Resource **bentuk jamak** dan **lowercase** (`/produk`, bukan `/Produk`).
- **Versioning** di path (`/v1`) — cara paling umum dan mudah.
- Mengembalikan **collection** sebagai objek `{data, meta}` untuk pagination.

### DTO / request-response model

```go
// request DTO — terpisah dari model DB!
type BuatProdukRequest struct {
	Nama     string  `json:"nama"`
	Harga    float64 `json:"harga"`
	Stok     int     `json:"stok"`
	Kategori string  `json:"kategori"`
}

type UpdateProdukRequest struct {
	Nama  *string  `json:"nama,omitempty"`  // pointer = optional
	Harga *float64 `json:"harga,omitempty"`
}

// response DTO — tidak pernah membocorkan field internal
type ProdukResponse struct {
	ID    int     `json:"id"`
	Nama  string  `json:"nama"`
	Harga float64 `json:"harga"`
}

type ListResponse[T any] struct {
	Data []T      `json:"data"`
	Meta PageInfo `json:"meta"`
}

type PageInfo struct {
	Page       int `json:"page"`
	PerPage    int `json:"per_page"`
	Total      int `json:"total"`
	TotalPages int `json:"total_pages"`
}
```

> **⚠️ Jangan** memakai struct DB langsung sebagai response API — field `password_hash`
> bisa bocor saat lupa menambah tag `json:"-"`. Pisahkan DTO.

### Validasi request

```go
func (r BuatProdukRequest) Validasi() error {
	var errs []string

	r.Nama = strings.TrimSpace(r.Nama)
	if r.Nama == "" {
		errs = append(errs, "nama wajib diisi")
	} else if len(r.Nama) > 200 {
		errs = append(errs, "nama maksimal 200 karakter")
	}
	if r.Harga < 0 {
		errs = append(errs, "harga tidak boleh negatif")
	}
	if r.Stok < 0 {
		errs = append(errs, "stok tidak boleh negatif")
	}

	if len(errs) > 0 {
		return fmt.Errorf("%s", strings.Join(errs, "; "))
	}
	return nil
}
```

Untuk validasi kompleks, library populer: **go-playground/validator/v10**
(`binding:"required,email,min=8"` — dipakai Gin/Echo).

### Pagination, filtering, sorting

```go
type ListQuery struct {
	Page    int
	PerPage int
	Sort    string // whitelist!
	Order   string
	Filter  map[string]string
}

func parseListQuery(r *http.Request) ListQuery {
	q := r.URL.Query()

	page, _ := strconv.Atoi(q.Get("page"))
	if page < 1 {
		page = 1
	}
	perPage, _ := strconv.Atoi(q.Get("per_page"))
	if perPage < 1 || perPage > 100 {
		perPage = 20 // default + batas wajar
	}

	order := strings.ToUpper(q.Get("order"))
	if order != "ASC" && order != "DESC" {
		order = "DESC"
	}

	// ⚠️ SORTING: whitelist kolom — jangan terima input mentah!
	sortCol := map[string]string{
		"nama": "nama", "harga": "harga", "created_at": "created_at",
	}[q.Get("sort")]
	if sortCol == "" {
		sortCol = "created_at"
	}

	return ListQuery{
		Page: page, PerPage: perPage,
		Sort: sortCol, Order: order,
	}
}

// offset = (page - 1) * perPage
```

### Error response konsisten

```go
type ErrorResponse struct {
	Error ErrorBody `json:"error"`
}

type ErrorBody struct {
	Message string            `json:"message"`
	Code    string            `json:"code"`
	Details map[string]string `json:"details,omitempty"`
}

func kirimError(w http.ResponseWriter, status int, code, message string) {
	tulisJSON(w, status, ErrorResponse{
		Error: ErrorBody{Message: message, Code: code},
	})
}

// penggunaan
kirimError(w, http.StatusNotFound, "PRODUK_TIDAK_ADA", "produk tidak ditemukan")
kirimError(w, http.StatusBadRequest, "VALIDASI_GAGAL", "nama wajib diisi")
```

**Aturan:** semua endpoint memakai **bentuk error yang sama** — klien cukup
memproses satu format.

### Handler utuh

```go
func (h *ProdukHandler) List(w http.ResponseWriter, r *http.Request) {
	q := parseListQuery(r)

	ctx := r.Context()
	produk, total, err := h.svc.List(ctx, q)
	if err != nil {
		log.Printf("list produk: %v", err)
		kirimError(w, http.StatusInternalServerError, "INTERNAL", "terjadi kesalahan")
		return
	}

	tulisJSON(w, http.StatusOK, ListResponse[ProdukResponse]{
		Data: toResponses(produk),
		Meta: PageInfo{
			Page: q.Page, PerPage: q.PerPage, Total: total,
			TotalPages: int(math.Ceil(float64(total) / float64(q.PerPage))),
		},
	})
}

func (h *ProdukHandler) Get(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil {
		kirimError(w, http.StatusBadRequest, "ID_TIDAK_VALID", "id harus angka")
		return
	}

	p, err := h.svc.Get(r.Context(), id)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			kirimError(w, http.StatusNotFound, "TIDAK_ADA", "produk tidak ditemukan")
			return
		}
		log.Printf("get produk %d: %v", id, err)
		kirimError(w, http.StatusInternalServerError, "INTERNAL", "terjadi kesalahan")
		return
	}

	tulisJSON(w, http.StatusOK, toResponse(p))
}

func (h *ProdukHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req BuatProdukRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		kirimError(w, http.StatusBadRequest, "JSON_TIDAK_VALID", "body bukan JSON valid")
		return
	}
	if err := req.Validasi(); err != nil {
		kirimError(w, http.StatusUnprocessableEntity, "VALIDASI_GAGAL", err.Error())
		return
	}

	p, err := h.svc.Create(r.Context(), req)
	if err != nil {
		if errors.Is(err, ErrConflict) {
			kirimError(w, http.StatusConflict, "DUPLIKAT", "nama produk sudah ada")
			return
		}
		log.Printf("create produk: %v", err)
		kirimError(w, http.StatusInternalServerError, "INTERNAL", "terjadi kesalahan")
		return
	}

	w.Header().Set("Location", fmt.Sprintf("/api/v1/produk/%d", p.ID))
	tulisJSON(w, http.StatusCreated, toResponse(p))
}
```

### CORS

```go
func CORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")

		// ✅ di production: whitelist domain tertentu, jangan "*"
		allowed := map[string]bool{
			"https://app.example.com": true,
			"https://www.example.com": true,
		}
		if allowed[origin] {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			w.Header().Set("Vary", "Origin")
			w.Header().Set("Access-Control-Allow-Credentials", "true")
		}

		if r.Method == http.MethodOptions {
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
			w.Header().Set("Access-Control-Max-Age", "600")
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}
```

### Authentication dan authorization (dasar)

```go
func Auth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		hdr := r.Header.Get("Authorization")
		if !strings.HasPrefix(hdr, "Bearer ") {
			kirimError(w, http.StatusUnauthorized, "TOKEN_KURANG", "token wajib")
			return
		}

		klaim, err := token.Validasi(strings.TrimPrefix(hdr, "Bearer "))
		if err != nil {
			kirimError(w, http.StatusUnauthorized, "TOKEN_TIDAK_VALID", "token tidak valid")
			return
		}

		ctx := context.WithValue(r.Context(), userKey{}, klaim)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func RequireRole(role string, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		klaim := DariContext(r.Context())
		if klaim.Role != role {
			kirimError(w, http.StatusForbidden, "DILARANG", "tidak punya izin")
			return
		}
		next.ServeHTTP(w, r)
	})
}
```

### Logging request

Sudah ada pada middleware Logging. Untuk production, pakai **structured logging**:

```go
slog.Info("request",
	r.Method, r.Method,
	"path", r.URL.Path,
	"status", sw.status,
	"durasi", time.Since(start),
	"request_id", requestID(r.Context()),
	"remote", r.RemoteAddr,
)
```

### Rate limiting

```go
func RateLimit(n int, per time.Duration) Middleware {
	return func(next http.Handler) http.Handler {
		// token bucket per IP (sederhana — pakai golang.org/x/time/rate untuk production)
		var mu sync.Mutex
		visitors := make(map[string]*rate.Limiter)

		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ip, _, _ := net.SplitHostPort(r.RemoteAddr)

			mu.Lock()
			lim, ok := visitors[ip]
			if !ok {
				lim = rate.NewLimiter(rate.Every(per/time.Duration(n)), n)
				visitors[ip] = lim
			}
			mu.Unlock()

			if !lim.Allow() {
				kirimError(w, http.StatusTooManyRequests, "RATE_LIMIT", "terlalu banyak permintaan")
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}
```

### Health check

```go
mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
	// liveness: apakah proses hidup?
	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "ok")
})

mux.HandleFunc("GET /readyz", func(w http.ResponseWriter, r *http.Request) {
	// readiness: apakah dependensi siap? (DB, cache)
	if err := db.PingContext(r.Context()); err != nil {
		kirimError(w, http.StatusServiceUnavailable, "DB_TIDAK_SIAP", "database tidak terhubung")
		return
	}
	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "ready")
})
```

### OpenAPI / Swagger

Dokumentasi API bisa dibuat:

1. **Tulis `openapi.yaml` manual** — paling umum untuk API kecil.
2. **Annotasi kode** dengan `swaggo/swag` → menghasilkan spec + UI.

```bash
go install github.com/swaggo/swag/cmd/swag@latest
swag init -g main.go -o docs
```

```go
// @Summary Buat produk baru
// @Tags produk
// @Accept json
// @Produce json
// @Param produk body BuatProdukRequest true "data produk"
// @Success 201 {object} ProdukResponse
// @Router /api/v1/produk [post]
func (h *ProdukHandler) Create(w http.ResponseWriter, r *http.Request) { ... }
```

---

## 4. Framework (Opsional)

Pelajari framework **setelah** memahami `net/http` — sebagian besar konsep
(middleware, handler) 100% kompatibel.

### Perbandingan singkat

| | **Chi** | **Gin** | **Echo** |
|---|---|---|---|
| Kompatibilitas | 100% `net/http` | Adapter sendiri | Adapter sendiri |
| Routing | stdlib pattern | custom | custom |
| Kecepatan | sangat cepat | sangat cepat | sangat cepat |
| Fitur | minimalis, middleware stdlib | binding, validasi, render | validasi, middleware bawaan |
| Filosofi | "middleware first", ringan | lengkap & populer | cepat & lengkap |

### Contoh dengan Chi

```go
import "github.com/go-chi/chi/v5"

func main() {
	r := chi.NewRouter()

	r.Use(middleware.Logger)      // middleware bawaan chi
	r.Use(middleware.Recoverer)

	r.Route("/api/v1", func(r chi.Router) {
		r.Get("/produk", h.List)
		r.Post("/produk", h.Create)

		r.Route("/produk/{id}", func(r chi.Router) {
			r.Get("/", h.Get)
			r.Put("/", h.Update)
			r.Delete("/", h.Delete)
		})
	})

	http.ListenAndServe(":8080", r)
}
```

### Contoh dengan Gin

```go
import "github.com/gin-gonic/gin"

func main() {
	r := gin.Default() // logger + recovery

	r.GET("/produk/:id", func(c *gin.Context) {
		id := c.Param("id")
		c.JSON(http.StatusOK, gin.H{"id": id})
	})

	r.POST("/produk", func(c *gin.Context) {
		var req BuatProdukRequest
		if err := c.ShouldBindJSON(&req); err != nil { // validasi + binding
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusCreated, gin.H{"nama": req.Nama})
	})

	r.Run(":8080")
}
```

### Kapan memakai framework

- **`net/http` murni**: API sederhana, tim ingin dependensi minimal.
- **Chi**: ingin routing modern + middleware stdlib, tetap kompatibel penuh.
- **Gin/Echo**: butuh binding/validasi bawaan dan kecepatan routing tinggi.

> **Saran:** mulai dengan `net/http` (Go 1.22+) — pindah ke framework hanya
> saat ada kebutuhan nyata. Skill `net/http` tetap berlaku di semua framework.

---

## Praktik

### 1. REST API Todo (tanpa database — in-memory)

```go
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"strings"
	"sync"
)

type Todo struct {
	ID     int    `json:"id"`
	Judul  string `json:"judul"`
	Selesai bool  `json:"selesai"`
}

type TodoStore struct {
	mu     sync.RWMutex
	todos  map[int]Todo
	nextID int
}

func (s *TodoStore) List() []Todo {
	s.mu.RLock()
	defer s.mu.RUnlock()
	out := make([]Todo, 0, len(s.todos))
	for _, t := range s.todos {
		out = append(out, t)
	}
	return out
}

func (s *TodoStore) Tambah(judul string) Todo {
	s.mu.Lock()
	defer s.mu.Unlock()
	t := Todo{ID: s.nextID, Judul: judul}
	s.todos[t.ID] = t
	s.nextID++
	return t
}

func (s *TodoStore) Hapus(id int) bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.todos[id]; !ok {
		return false
	}
	delete(s.todos, id)
	return true
}

func tulisJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("gagal encode response: %v", err)
	}
}

func main() {
	store := &TodoStore{todos: map[int]Todo{}, nextID: 1}
	mux := http.NewServeMux()

	mux.HandleFunc("GET /todos", func(w http.ResponseWriter, r *http.Request) {
		tulisJSON(w, http.StatusOK, map[string]any{"data": store.List()})
	})

	mux.HandleFunc("POST /todos", func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Judul string `json:"judul"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil || strings.TrimSpace(req.Judul) == "" {
			tulisJSON(w, http.StatusBadRequest, map[string]any{
				"error": map[string]string{"message": "judul wajib diisi"},
			})
			return
		}
		t := store.Tambah(req.Judul)
		w.Header().Set("Location", "/todos/"+strconv.Itoa(t.ID))
		tulisJSON(w, http.StatusCreated, t)
	})

	mux.HandleFunc("DELETE /todos/{id}", func(w http.ResponseWriter, r *http.Request) {
		id, err := strconv.Atoi(r.PathValue("id"))
		if err != nil || !store.Hapus(id) {
			tulisJSON(w, http.StatusNotFound, map[string]any{
				"error": map[string]string{"message": "todo tidak ada"},
			})
			return
		}
		w.WriteHeader(http.StatusNoContent)
	})

	log.Println("server di :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}
```

### 2. REST API Product dengan database

Gabungkan materi fase 4 (repository) + fase 7 (handler):
`handler → service → repository → database`. Struktur lengkapnya dibahas
di [Fase 8 — Backend Architecture]({{ site.baseurl }}/belajar-go/fase-8-backend-architecture/).

### 3. API authentication berbasis JWT

```go
// membuat token
func BuatToken(userID int, role string) (string, error) {
	klaim := jwt.MapClaims{
		"sub":  userID,
		"role": role,
		"iat":  time.Now().Unix(),
		"exp":  time.Now().Add(15 * time.Minute).Unix(),
	}
	t := jwt.NewWithClaims(jwt.SigningMethodHS256, klaim)
	return t.SignedString([]byte(os.Getenv("JWT_SECRET")))
}

// middleware memverifikasi
func Auth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		hdr := r.Header.Get("Authorization")
		if !strings.HasPrefix(hdr, "Bearer ") {
			kirimError(w, http.StatusUnauthorized, "TOKEN_KURANG", "")
			return
		}

		tok, err := jwt.Parse(strings.TrimPrefix(hdr, "Bearer "),
			func(t *jwt.Token) (any, error) {
				if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, fmt.Errorf("metode tanda tangan tak dikenal")
				}
				return []byte(os.Getenv("JWT_SECRET")), nil
			})
		if err != nil || !tok.Valid {
			kirimError(w, http.StatusUnauthorized, "TOKEN_TIDAK_VALID", "")
			return
		}
		// simpan klaim ke context, lanjutkan
		next.ServeHTTP(w, r)
	})
}
```

**Praktik terbaik:**

- Access token **pendek** (15 menit) + refresh token **panjang** (30 hari).
- Refresh token disimpan di **HttpOnly + Secure + SameSite** cookie.
- Verifikasi `exp`, `iss`, `aud` — jangan hanya signature.
- **Jangan** simpan data sensitif di payload JWT (bisa dibaca siapa pun).

### 4. Dokumentasi OpenAPI

Tulis `docs/openapi.yaml` yang mencakup semua endpoint, schema request/response,
contoh, dan error code. Bisa diverifikasi dengan Spectral/Redocly CLI.

---

## Checklist Fase 7

- [x] HTTP: request/response, method, status code, header, query/path/body, JSON, Content-Type.
- [x] `net/http`: `ListenAndServe`, `Handler`, `HandlerFunc`, `ServeMux`, routing, baca/tulis request, status code.
- [x] Middleware, request context, timeout server, graceful shutdown, static file server.
- [x] REST: endpoint design, CRUD, validasi, DTO, pagination, filtering, sorting, error konsisten, versioning, CORS, auth, logging, rate limiting, OpenAPI, health check.
- [x] Framework: Gin, Echo, Chi, perbandingan, kapan memakai.

## Ringkasan

- `net/http` sudah cukup untuk API production — Go 1.22 menambah routing modern.
- **Satu bentuk response, satu bentuk error** di seluruh API.
- Pisahkan **DTO request/response** dari model database.
- Middleware berlapis; `Recover` paling luar; `r.Context()` diteruskan ke semua I/O.
- **Selalu** `defer r.Body.Close()`, batasi ukuran body, dan validasi input.
- Mulai tanpa framework; tambah hanya saat butuh.

---
<!--
Lanjut ke: [Fase 8 — Backend Architecture]({{ site.baseurl }}/belajar-go/fase-8-backend-architecture/)
-->