---
layout: post
title: "Fase 11 — Deployment dan Production"
date: 2026-11-18 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, docker, devops, cicd, observability, prometheus]
permalink: /belajar-go/fase-11-deployment-production/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Deployment dan Production
---

# Deployment dan Production

Fase ini membawa aplikasi Go dari mesin development ke production:
build, container, deployment, observability, dan CI/CD.

## Tujuan

- Build binary production (cross-compile, build flags, version info).
- Menulis Dockerfile multi-stage dan Docker Compose.
- Deploy ke server: reverse proxy, HTTPS, systemd, container.
- Menambahkan logging, metrics, dan tracing.
- Membangun pipeline CI/CD lengkap.

---

## 1. Build dan Configuration

### Build binary production

```bash
# build dasar
go build -o app ./cmd/server

# build "benar" untuk production
CGO_ENABLED=0 go build \
  -trimpath \
  -ldflags="-s -w" \
  -o app ./cmd/server
```

| Flag | Fungsi |
|------|--------|
| `CGO_ENABLED=0` | Tanpa dependensi C — binary statis, cross-compile mulus |
| `-trimpath` | Hapus path lokal dari binary (reproducible + aman) |
| `-ldflags="-s -w"` | Strip symbol table & DWARF → binary lebih kecil |
| `-ldflags="-X main.version=..."` | Sisipkan variabel package `main` |

### Menyisipkan versi build

```go
package main

import "log"

var (
	version   = "dev"      // diset saat build
	commit    = "none"
	buildTime = "unknown"
)

func main() {
	log.Printf("app %s (commit %s, built %s)", version, commit, buildTime)
}
```

```bash
go build -ldflags="
  -X main.version=v1.2.3
  -X main.commit=$(git rev-parse --short HEAD)
  -X main.buildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)
" -o app ./cmd/server
```

```bash
# endpoint versi
mux.HandleFunc("GET /version", func(w http.ResponseWriter, r *http.Request) {
	tulisJSON(w, http.StatusOK, map[string]string{
		"version": version, "commit": commit, "build_time": buildTime,
	})
})
```

### Cross compile

```bash
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o app-linux ./cmd/server
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o app-arm64 ./cmd/server
GOOS=windows GOARCH=amd64 go build -o app.exe ./cmd/server
```

```bash
# build untuk semua platform (dengan skrip)
for os in linux darwin windows; do
  GOOS=$os GOARCH=amd64 CGO_ENABLED=0 \
    go build -trimpath -o "dist/app-$os-amd64" ./cmd/server
done
```

### Environment configuration

```go
// internal/config/config.go
type Config struct {
	Environment  string        // development | staging | production
	Port         string
	DatabaseURL  string
	RedisURL     string
	JWTSecret    string
	LogLevel     string
	ShutdownWait time.Duration
}

func Load() (*Config, error) {
	cfg := &Config{
		Environment:  getEnv("ENVIRONMENT", "development"),
		Port:         getEnv("PORT", "8080"),
		DatabaseURL:  os.Getenv("DATABASE_URL"),
		RedisURL:     os.Getenv("REDIS_URL"),
		JWTSecret:    os.Getenv("JWT_SECRET"),
		LogLevel:     getEnv("LOG_LEVEL", "info"),
		ShutdownWait: getDuration("SHUTDOWN_WAIT", 10*time.Second),
	}

	// validasi WAJIB — gagal cepat saat startup
	if cfg.DatabaseURL == "" {
		return nil, errors.New("DATABASE_URL wajib diisi")
	}
	if cfg.Environment == "production" {
		if len(cfg.JWTSecret) < 32 {
			return nil, errors.New("JWT_SECRET minimal 32 karakter")
		}
		if cfg.Environment == "" {
			return nil, errors.New("ENVIRONMENT wajib diset di production")
		}
	}
	return cfg, nil
}
```

**Aturan konfigurasi:**

1. **Env var** untuk nilai per-deployment.
2. **Validasi saat startup** — jangan jalan dengan config rusak.
3. **Default aman** untuk development, **wajib eksplisit** untuk production.
4. **Jangan pernah** hardcode secret; pakai secret manager.

### Build flags

```go
// informasi build otomatis dari VCS (Go 1.18+)
info, ok := debug.ReadBuildInfo()
fmt.Println(info.Main.Version)     // versi module
fmt.Println(info.GoVersion)        // versi Go yang membangun
for _, s := range info.Settings {
	// s.Key: "vcs.revision", "vcs.time", "vcs.modified"...
}
```

### Secrets management

| Environment | Cara |
|-------------|------|
| Development | `.env` + `.gitignore` |
| Staging/Production | Secret manager (Vault, AWS Secrets Manager, GCP Secret Manager) |
| Container | Docker/K8s secrets, injected sebagai env var |

```bash
# .gitignore
.env
*.pem
```

```bash
# rotasi secret secara berkala — dan pastikan aplikasi membaca ulang saat perlu
```

### Dockerfile multi-stage

```dockerfile
# ---------- STAGE 1: build ----------
FROM golang:1.27-alpine AS builder

# cache dependency layer
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# build binary statis
RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath -ldflags="-s -w" \
    -o /out/app ./cmd/server

# ---------- STAGE 2: runtime ----------
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /out/app /app

# port & env default
ENV PORT=8080
EXPOSE 8080

# distroless sudah nonroot, tidak ada shell — attack surface minimal
ENTRYPOINT ["/app"]
```

**Kenapa multi-stage?**

- Image akhir **hanya berisi binary** (±10-20 MB vs 800 MB+ image golang).
- Tidak ada compiler/sumber di image production.
- **Distroless/static** = tidak ada shell → penyerang sulit bergerak.

**Alternatif bila butuh timezone/data:**

```dockerfile
FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /out/app /app
USER nobody
ENTRYPOINT ["/app"]
```

**Praktik keamanan Dockerfile:**

- `USER nonroot` — jangan jankan sebagai root.
- Pin versi image (`golang:1.27-alpine`, bukan `latest`).
- `.dockerignore`: `.git`, `.env`, `README.md`, folder test.
- **Scan vulnerability**: `docker scout cves app` atau Trivy.

### Docker Compose untuk development

```yaml
# docker-compose.yml
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: root:rootpassword@tcp(db:3306)/belajar_go?parseTime=true
      REDIS_URL: redis://cache:6379
      ENVIRONMENT: development
      LOG_LEVEL: debug
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_started
    volumes:
      - .:/src          # hot reload untuk development (dengan air/air-compile)

  db:
    image: mariadb:11
    environment:
      MARIADB_ROOT_PASSWORD: rootpassword
      MARIADB_DATABASE: belajar_go
    ports:
      - "3306:3306"
    volumes:
      - dbdata:/var/lib/mysql
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 5s
      timeout: 3s
      retries: 10

  cache:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  dbdata:
```

```bash
docker compose up -d         # jalankan semua
docker compose logs -f app   # pantau log
docker compose down -v       # berhenti + hapus volume
```

---

## 2. Deployment

### Deploy ke Linux server

**Opsi:**

1. **Binary langsung + systemd** — paling sederhana dan cepat.
2. **Docker + Compose** — konsisten dengan development.
3. **Kubernetes** — untuk skala besar / banyak service (punya learning curve).

**Langkah binary:**

```bash
# 1. build di lokal/CI untuk linux
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -o app ./cmd/server

# 2. upload
scp app user@server:/opt/myapp/app

# 3. di server
sudo useradd --system --no-create-home --shell /usr/sbin/nologin myapp
sudo mkdir -p /opt/myapp
sudo chown -R myapp:myapp /opt/myapp
```

### Reverse proxy (Nginx / Caddy)

**Nginx:**

```nginx
server {
    listen 80;
    server_name api.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate     /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;

    # buffer & limit
    client_max_body_size 1m;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 30s;
    }
}
```

**Caddy (lebih simpel, auto-HTTPS):**

```
api.example.com {
	reverse_proxy 127.0.0.1:8080
}
```

Caddy otomatis mengurus **Let's Encrypt** dan renewal.

> **Kenapa butuh reverse proxy?**
> - TLS/HTTPS di satu tempat.
> - Terima **sinyal SIGTERM** lalu mengirim graceful shutdown ke aplikasi.
> - Compression, caching static, rate limit, dan logging di edge.

### HTTPS/TLS

```bash
# dengan certbot (Nginx)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.example.com

# atau Caddy: otomatis, tanpa konfigurasi
```

**Aturan:**

- Redirect HTTP → HTTPS.
- HSTS header.
- Sertifikat auto-renew (certbot/Caddy melakukannya).
- TLS 1.2+ saja.

### Systemd service

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Go Application
After=network.target
Wants=network-online.target

[Service]
Type=notify
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/app
Restart=always
RestartSec=5

# environment
EnvironmentFile=/opt/myapp/.env
Environment=PORT=8080

# keamanan
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ReadWritePaths=/opt/myapp/data

# graceful shutdown (beri waktu aplikasi menutup diri)
TimeoutStopSec=20
KillSignal=SIGTERM

# logging ke journald
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable myapp
sudo systemctl start myapp
sudo systemctl status myapp
journalctl -u myapp -f          # pantau log
```

> **Catatan:** `Type=notify` memerlukan aplikasi memberi sinyal ke systemd
> saat siap (via `github.com/oklog/run` atau `sd_notify`). `Type=simple`
> lebih mudah bila tidak perlu.

### Container deployment

```bash
# build & push ke registry
docker build -t registry.example.com/myapp:v1.2.3 .
docker push registry.example.com/myapp:v1.2.3

# jalankan
docker run -d --name myapp \
  --restart unless-stopped \
  -p 127.0.0.1:8080:8080 \
  -e DATABASE_URL="$DATABASE_URL" \
  -e ENVIRONMENT=production \
  --memory 512m \
  --health-cmd="wget -qO- localhost:8080/healthz || exit 1" \
  --health-interval=10s \
  registry.example.com/myapp:v1.2.3
```

**Kubernetes** (pokoknya untuk skala besar):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels: { app: myapp }
  template:
    metadata:
      labels: { app: myapp }
    spec:
      containers:
        - name: myapp
          image: registry.example.com/myapp:v1.2.3
          ports:
            - containerPort: 8080
          envFrom:
            - secretRef: { name: myapp-secret }
          resources:
            requests: { cpu: 100m, memory: 128Mi }
            limits:   { cpu: 500m, memory: 256Mi }
          readinessProbe:
            httpGet: { path: /readyz, port: 8080 }
            periodSeconds: 5
          livenessProbe:
            httpGet: { path: /healthz, port: 8080 }
            periodSeconds: 10
          lifecycle:
            preStop:
              exec: { command: ["sleep", "5"] }   # beri waktu drain
```

### Database migration saat deployment

```bash
# 1. jalankan migration SEBELUM deploy aplikasi baru
./app migrate up

# 2. baru deploy aplikasi
# 3. (opsional) cleanup migration lama setelah stabil
```

**Aturan:**

- **Backward compatible** — aplikasi lama harus tetap jalan dengan skema baru
  (tambah kolom dulu, isi data, baru berhenti pakai kolom lama).
- Migration otomatis di awal start **berisiko** bila ada beberapa instance —
  pakai **job terpisah** atau lock migration.
- Selalu **backup** sebelum migration besar.

### Rolling deployment dasar

```
SEBELUM:  [v1] [v1] [v1]     ← 3 instance v1

LANGKAH:  [v2] [v1] [v1]     ← ganti satu per satu
          [v2] [v2] [v1]
          [v2] [v2] [v2]     ← selesai

rollback: cukup deploy versi sebelumnya kembali
```

**Prasyarat:**

1. **Health check** → orchestrator tahu instance siap.
2. **Graceful shutdown** → request in-flight tidak terputus.
3. **Versi dalam URL/header** → mudah debugging.
4. **Skema DB backward-compatible** → v1 dan v2 bisa hidup bersamaan.

### Backup dan restore

```bash
# MariaDB — backup harian via cron
mariadb-dump -uroot -prootpassword belajar_go \
  | gzip > /backup/app_$(date +%F).sql.gz

# restore
gunzip -c /backup/app_2026-11-18.sql.gz | mariadb -uroot -prootpassword belajar_go
```

**Aturan backup:**

- **Otomatis** dan terjadwal.
- **Diuji restore-nya** secara berkala (backup yang belum pernah direstore = bukan backup).
- Simpan **di luar server** (off-site / object storage).
- Pertimbangkan **PITR** (point-in-time recovery) untuk database penting.
- Backup **sebelum migration besar**.

---

## 3. Observability

### Structured logging

```go
// production
log := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
	Level: slog.LevelInfo,
}))

// dengan konteks request
func Logging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		reqID := r.Header.Get("X-Request-Id")

		ctx := context.WithValue(r.Context(), reqIDKey{}, reqID)
		sw := &statusWriter{ResponseWriter: w, status: 200}

		next.ServeHTTP(sw, r.WithContext(ctx))

		log.InfoContext(ctx, "http_request",
			"method", r.Method,
			"path", r.URL.Path,
			"status", sw.status,
			"durasi_ms", time.Since(start).Milliseconds(),
			"user_agent", r.UserAgent(),
			"remote", r.RemoteAddr,
		)
	})
}
```

**Tiga pertanyaan observability (RED/USE method):**

- **Rate** — berapa request per detik?
- **Errors** — berapa yang gagal (4xx/5xx)?
- **Duration** — berapa lama (p50/p95/p99)?

### Metrics dengan Prometheus

```go
import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	httpRequests = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total jumlah request HTTP",
		},
		[]string{"method", "path", "status"},
	)

	httpDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "Durasi request HTTP",
			Buckets: prometheus.DefBuckets, // atau []float64{.01,.05,.1,.5,1}
		},
		[]string{"method", "path"},
	)

	inFlight = promauto.NewGauge(
		prometheus.GaugeOpts{Name: "http_requests_in_flight"},
	)
)

// middleware metrics
func Metrics(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		inFlight.Inc()
		defer inFlight.Dec()

		start := time.Now()
		sw := &statusWriter{ResponseWriter: w, status: 200}
		next.ServeHTTP(sw, r)

		// ⚠️ JANGAN pakai path mentah sebagai label — cardinality meledak!
		route := r.Pattern // Go 1.22+: pola rute, bukan path konkret
		httpRequests.WithLabelValues(r.Method, route, strconv.Itoa(sw.status)).Inc()
		httpDuration.WithLabelValues(r.Method, route).
			Observe(time.Since(start).Seconds())
	})
}

// endpoint scrape Prometheus
mux.Handle("/metrics", promhttp.Handler())
```

> **⚠️ Aturan metrics:** label harus **terbatas** dan **diketahui di depan**.
> Pakai **pola rute** (`/produk/{id}`), bukan URL mentah (`/produk/12345`) —
> kalau tidak, Prometheus kehabisan memori.

### Grafana

```
Prometheus (scrape /metrics) → Grafana (dashboard & alert)
```

Dashboard standar yang dibuat:

1. **Request rate** per route.
2. **Error rate** (rasio 5xx / total).
3. **Latency** p50/p95/p99.
4. **Resource**: CPU, memori, goroutine, GC.
5. **Saturation**: koneksi DB, queue depth, cache hit ratio.

### OpenTelemetry dan distributed tracing

```go
import (
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/propagation"
)

func initTracing(ctx context.Context) (func(context.Context) error, error) {
	exp, err := otlptracehttp.New(ctx,
		otlptracehttp.WithEndpoint("otel-collector:4318"),
		otlptracehttp.WithInsecure(),
	)
	if err != nil {
		return nil, err
	}

	tp := trace.NewTracerProvider(
		trace.WithBatcher(exp),
		trace.WithResource(resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceNameKey.String("myapp"),
		)),
	)
	otel.SetTracerProvider(tp)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{}, propagation.Baggage{},
	))
	return tp.Shutdown, nil
}
```

```go
// membuat span di handler
tracer := otel.Tracer("myapp")
ctx, span := tracer.Start(r.Context(), "handler.GetProduk")
defer span.End()

span.SetAttributes(attribute.Int("produk.id", id))
// ... operasi — trace otomatis merambat ke service lain
// (lewat header traceparent di HTTP headers)
```

**Konsep:**

- **Trace** = perjalanan satu request lintas service.
- **Span** = satu langkah dalam trace (handler, query DB, HTTP call).
- **Context propagation** — trace ID dibawa lewat header `traceparent`.

### Correlation / request ID

```go
// 1. ambil atau buat request ID
func RequestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		id := r.Header.Get("X-Request-Id")
		if id == "" {
			id = uuid.NewString()
		}
		w.Header().Set("X-Request-Id", id)

		ctx := context.WithValue(r.Context(), reqIDKey{}, id)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// 2. SEMUA log membawa request ID
log.InfoContext(ctx, "proses selesai", "request_id", DariContext(ctx))

// 3. kirim balik ke klien
w.Header().Set("X-Request-Id", id)
```

**Dengan request ID**, satu masalah di production bisa ditelusuri dari
log klien → proxy → aplikasi → database dengan satu string.

### Alerting

```yaml
# rules/alerts.yml
groups:
  - name: myapp
    rules:
      - alert: ErrorRateTinggi
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m]))
            / sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels: { severity: critical }
        annotations:
          summary: "Error rate > 5% selama 5 menit"

      - alert: LatencyP99Tinggi
        expr: |
          histogram_quantile(0.99,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) > 2
        for: 10m
        labels: { severity: warning }

      - alert: ServerDown
        expr: up == 0
        for: 1m
        labels: { severity: critical }
```

**Aturan alert yang baik:**

- Alert pada **dampak ke user** (error rate, latency), bukan CPU 80%.
- Setiap alert harus **punya runbook** (apa yang harus dilakukan).
- Hindari alert noise — alert yang sering diabaikan = alert mati.

### Monitoring checklist

| Aspek | Metrik | Sumber |
|-------|--------|--------|
| **Latency** | p50/p95/p99 per route | histogram |
| **Error** | rasio 5xx, panic count | counter |
| **Traffic** | request/detik | counter |
| **Saturation** | goroutine, heap, koneksi DB, queue | gauge |
| **Resource** | CPU, memori container | node exporter / cAdvisor |
| **Business** | order/menit, user aktif | custom counter |

---

## 4. CI/CD

### Git workflow

```
main ──┬──── feature/foo ──────┐
       │                       ├── PR ── review ── merge
       └──── fix/bar ──────────┘
```

**Praktik:**

- `main` selalu **siap deploy** (trunk-based).
- Setiap perubahan lewat **pull request** + review.
- **Conventional commits** (`feat:`, `fix:`, `chore:`) untuk changelog.
- Tag rilis (`v1.2.3`).

### Pipeline dengan GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version: "1.27"
          cache: true

      - name: Download dependencies
        run: go mod download

      - name: Verify go.mod bersih
        run: |
          go mod tidy
          git diff --exit-code go.mod go.sum

      - name: Format check
        run: test -z "$(gofmt -l .)"

      - name: Vet
        run: go vet ./...

      - name: Lint
        uses: golangci/golangci-lint-action@v6
        with:
          version: latest

      - name: Test dengan race detector
        run: go test -race -coverprofile=coverage.out ./...

      - name: Coverage threshold
        run: |
          COV=$(go tool cover -func=coverage.out | tail -1 | awk '{print $3}' | tr -d '%')
          echo "coverage: $COV%"
          awk -v c="$COV" 'BEGIN { exit !(c >= 70) }'

      - name: Vulnerability check
        run: |
          go install golang.org/x/vuln/cmd/govulncheck@latest
          govulncheck ./...

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with: { go-version: "1.27" }

      - name: Build
        run: CGO_ENABLED=0 go build -trimpath -o app ./cmd/server

      - uses: actions/upload-artifact@v4
        with:
          name: app
          path: app
```

### Docker image pipeline

```yaml
  docker:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/metadata-action@v5
        id: meta
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha
            type=semver,pattern={{version}}
            type=ref,event=branch

      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Deployment pipeline

```yaml
  deploy-staging:
    needs: docker
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy ke staging
        run: |
          ssh deploy@staging.example.com \
            "docker pull ghcr.io/${REPO}:${TAG} && docker compose up -d app"

      - name: Smoke test
        run: |
          sleep 10
          curl -fsS https://staging.example.com/readyz

  deploy-production:
    needs: deploy-staging
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    environment: production    # ← butuh approval manual
    steps:
      - name: Deploy ke production
        run: ./scripts/deploy.sh production ${{ github.ref_name }}
```

**Praktik:**

- Staging otomatis, **production dengan approval manual**.
- **Smoke test** setelah deploy — gagalkan pipeline bila tidak siap.
- **Database migration** sebagai langkah terpisah sebelum deploy.

### Release versioning

```bash
# Semantic Versioning
# MAJOR.MINOR.PATCH → 1.2.3
#   MAJOR: breaking change
#   MINOR: fitur baru, backward compatible
#   PATCH: perbaikan bug

git tag -a v1.2.3 -m "rilis: fitur export CSV"
git push origin v1.2.3
# pipeline mendeteksi tag → build + deploy versi itu
```

**Tools:** `goreleaser` untuk membangun binary lintas platform + changelog otomatis.

```yaml
# .goreleaser.yaml
builds:
  - main: ./cmd/server
    env: [CGO_ENABLED=0]
    goos: [linux, darwin, windows]
    goarch: [amd64, arm64]
    ldflags:
      - -s -w -X main.version={{.Version}} -X main.commit={{.Commit}}
```

```bash
goreleaser release --clean
```

### Rollback dasar

```bash
# 1. rollback container: pakai image versi sebelumnya
docker compose up -d app=ghcr.io/repo/app:v1.2.2

# 2. rollback systemd: binary versi lama (simpan di /opt/myapp/releases/)
ln -sfn /opt/myapp/releases/v1.2.2/app /opt/myapp/current
sudo systemctl restart myapp

# 3. Kubernetes
kubectl rollout undo deployment/myapp
```

**Prasyarat rollback yang cepat:**

- Versi sebelumnya **selalu tersedia** (image registry / folder releases).
- **Skema DB backward-compatible** — rollback tidak boleh merusak data.
- **Alert** memberi tahu cepat saat ada masalah pasca-deploy.

**Kapan rollback vs fix-forward?**

- Bug **kritis** (data corruption, down) → **rollback segera**.
- Bug kecil → **fix-forward** (rollback punya risiko sendiri).

---

## Praktik

### 1. Deploy REST API ke server

Checklist lengkap:

```bash
# 1. build
CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o app ./cmd/server

# 2. siapkan server
sudo useradd --system --no-create-home myapp
sudo mkdir -p /opt/myapp && sudo chown myapp /opt/myapp

# 3. upload binary + .env + systemd unit
scp app /etc/systemd/system/myapp.service user@server:/tmp/

# 4. jalankan sebagai service
sudo systemctl daemon-reload
sudo systemctl enable --now myapp

# 5. verifikasi
curl -fsS localhost:8080/healthz
curl -fsS localhost:8080/version

# 6. reverse proxy + HTTPS (Caddy)
echo 'api.example.com {
	reverse_proxy 127.0.0.1:8080
}' | sudo tee /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

### 2. Menjalankan aplikasi sebagai service

Selesaikan konfigurasi systemd di bagian 2 — pastikan:

- `Restart=always` agar otomatis pulih.
- `TimeoutStopSec` cukup untuk graceful shutdown.
- Log masuk `journalctl`.
- Aplikasi berjalan sebagai user non-root.

### 3. Menambahkan logging dan metrics

1. Ganti semua `fmt.Println` dengan `slog` JSON.
2. Tambah middleware logging dengan request ID.
3. Daftarkan `promauto` counters/histograms + endpoint `/metrics`.
4. Buat dashboard Grafana dasar (rate, error, latency).

### 4. Membuat CI pipeline

Aktifkan `.github/workflows/ci.yml` di atas dan pastikan:

- Test dengan `-race` lulus.
- Coverage di atas threshold yang ditentukan.
- `gofmt` dan `golangci-lint` bersih.
- Build artifact tersimpan.

---

## Checklist Fase 11

- [x] Build binary: flags, versi build, cross-compile, env config, secrets.
- [x] Dockerfile multi-stage, Docker Compose development.
- [x] Deploy ke Linux, reverse proxy (Nginx/Caddy), HTTPS/TLS, systemd.
- [x] Container deployment, K8s (pengenalan), migration saat deploy.
- [x] Health check, graceful shutdown, rolling deployment, backup & restore.
- [x] Structured logging, metrics, Prometheus, Grafana, OpenTelemetry, request ID, alerting.
- [x] Git workflow, CI test/lint, build pipeline, Docker image, deployment pipeline, release versioning, rollback.

## Ringkasan

- Build production: `CGO_ENABLED=0 -trimpath -ldflags="-s -w"` + versi build.
- **Multi-stage Docker** menghasilkan image kecil dan aman (distroless, nonroot).
- Reverse proxy menangani TLS, logging edge, dan **sinyal shutdown**.
- `/healthz` (liveness) ≠ `/readyz` (readiness) — keduanya punya arti berbeda.
- Observability = **logging terstruktur + metrics + tracing + request ID**.
- CI: `gofmt → vet → lint → test -race → coverage → govulncheck → build → docker → deploy`.
- Selalu siapkan **rollback** yang bisa dijalankan dalam hitungan menit.

---

Lanjut ke: [Fase 12 — Proyek Akhir (Capstone)]({{ site.baseurl }}/belajar-go/fase-12-proyek-akhir/)
