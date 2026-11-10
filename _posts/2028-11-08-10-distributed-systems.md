---
layout: post
title: "Fase 10 — Distributed Systems dan Integrasi"
date: 2026-11-17 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, redis, messaging, reliability, distributed]
permalink: /belajar-go/fase-10-distributed-systems/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Distributed Systems dan Integrasi
---

# Distributed Systems dan Integrasi

Saat aplikasi tumbuh, kamu membutuhkan **cache**, **message broker**, dan
**pola reliability** agar sistem tetap sehat saat komponen gagal.

## Tujuan

- Menerapkan cache in-memory dan Redis dengan invalidation serta TTL.
- Memahami message broker: producer, consumer, ack, retry, DLQ, idempotency.
- Menerapkan pola reliability: timeout, retry backoff, circuit breaker, health check.

---

## 1. Cache

### Konsep caching

```
tanpa cache:   Client → API → Database          (lambat, DB kelebihan beban)
dengan cache:  Client → API → Cache → Database  (cepat, DB hanya saat miss)
```

**Trade-off:** cache menambah kecepatan dengan **kemungkinan data stale**
(data kadaluarsa). Keputusan selalu antara **kecepatan vs konsistensi**.

### Cache in-memory

```go
package cache

import (
	"sync"
	"time"
)

type item struct {
	value     any
	expiresAt time.Time
}

type Cache struct {
	mu    sync.RWMutex
	items map[string]item
}

func New() *Cache {
	c := &Cache{items: make(map[string]item)}
	go c.pembersih() // bersihkan item kadaluwarsa berkala
	return c
}

func (c *Cache) Set(key string, val any, ttl time.Duration) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.items[key] = item{
		value:     val,
		expiresAt: time.Now().Add(ttl),
	}
}

// Get mengembalikan (nilai, true) bila ada dan belum kadaluwarsa
func (c *Cache) Get(key string) (any, bool) {
	c.mu.RLock()
	it, ok := c.items[key]
	c.mu.RUnlock()

	if !ok {
		return nil, false
	}
	if time.Now().After(it.expiresAt) {
		c.Delete(key) // expired
		return nil, false
	}
	return it.value, true
}

func (c *Cache) Delete(key string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	delete(c.items, key)
}

// pembersih berjalan tiap menit, menghapus item kadaluwarsa
func (c *Cache) pembersih() {
	for range time.Tick(time.Minute) {
		now := time.Now()
		c.mu.Lock()
		for k, it := range c.items {
			if now.After(it.expiresAt) {
				delete(c.items, k)
			}
		}
		c.mu.Unlock()
	}
}
```

> **⚠️ Cache in-memory tidak bisa dibagikan** antar instance aplikasi.
> Untuk banyak instance → pakai Redis.

### Redis

```go
import "github.com/redis/go-redis/v9"

rdb := redis.NewClient(&redis.Options{
	Addr:     "localhost:6379",
	Password: "",
	DB:       0,
})

ctx := context.Background()

// SET dengan TTL
err := rdb.Set(ctx, "produk:1", `{"id":1,"nama":"Laptop"}`, 5*time.Minute).Err()

// GET
val, err := rdb.Get(ctx, "produk:1").Result()
if errors.Is(err, redis.Nil) {
	// cache miss — ambil dari DB
}

// hapus (invalidation)
rdb.Del(ctx, "produk:1")

// cache-aside dengan singleflight agar tidak stampede
```

### Cache-aside (pola paling umum)

```go
func (s *ProdukService) Get(ctx context.Context, id int) (domain.Produk, error) {
	key := fmt.Sprintf("produk:%d", id)

	// 1. coba cache
	if data, ok := s.cache.Get(ctx, key); ok {
		var p domain.Produk
		if json.Unmarshal(data, &p) == nil {
			return p, nil
		}
	}

	// 2. miss → ambil dari DB
	p, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return domain.Produk{}, err
	}

	// 3. tulis ke cache (jangan gagalkan request bila cache error)
	if data, err := json.Marshal(p); err == nil {
		_ = s.cache.Set(ctx, key, data, 5*time.Minute)
	}
	return p, nil
}
```

**Aturan:**

- **Cache-aside**: aplikasi yang mengelola cache (read: cache dulu; write: hapus cache).
- **Write-through**: tulis ke cache dan DB bersamaan.
- **Write-behind**: tulis ke cache, DB menyusul (risiko kehilangan data).
- Untuk kebanyakan aplikasi: **cache-aside + TTL** adalah titik mulai terbaik.

### Cache invalidation

> *"There are only two hard problems in Computer Science: cache invalidation
> and naming things."* — Phil Karlton

**Strategi invalidation:**

1. **TTL (Time-To-Live)** — otomatis kadaluwarsa. Paling sederhana.
   Data stale maksimum = TTL.
2. **Hapus saat write** (delete-on-write) — hapus key terkait saat data berubah.
3. **Versioned key** — ganti prefix saat data berubah:
   `produk:{version}:1` → increment version = semua key lama tak terpakai.

```go
// delete-on-write
func (s *ProdukService) Update(ctx context.Context, p domain.Produk) error {
	if err := s.repo.Update(ctx, &p); err != nil {
		return err
	}
	// invalidasi semua key yang terkait
	_ = s.cache.Delete(ctx, fmt.Sprintf("produk:%d", p.ID))
	_ = s.cache.Delete(ctx, "produk:list:v1") // cache list juga
	return nil
}
```

**Keputusan:** bila data boleh stale beberapa detik → TTL saja cukup.
Bila harus selalu konsisten → delete-on-write + TTL sebagai jaring pengaman.

### Cache stampede

**Stampede**: banyak request **bersamaan** menemui **cache kosong** lalu
serentak membebani database.

```go
// ❌ STAMPEDE — 100 request miss bersamaan = 100 query DB
if val, ok := cache.Get(key); !ok {
	val = queryDB(key) // semua berlari ke sini
	cache.Set(key, val)
}

// ✅ SOLUSI 1: singleflight — hanya SATU yang query, lainnya menunggu
import "golang.org/x/sync/singleflight"

var group singleflight.Group

func ambilDenganSingleflight(key string) (string, error) {
	val, err, _ := group.Do(key, func() (any, error) {
		return queryDB(key) // hanya berjalan sekali untuk key yang sama
	})
	return val.(string), err
}

// ✅ SOLUSI 2: stale-while-revalidate — sajikan data lama, refresh di latar belakang
if val, ok := cache.Get(key); ok {
	if val.Kadaluwarsa() && !val.SedangRefresh() {
		go refresh(key) // refresh async
	}
	return val.Data // tetap layani yang lama
}

// ✅ SOLUSI 3: hard TTL — set ulang TTL saat akses (memperpanjang hidup item aktif)
```

**Bonus: pre-warming** — isi cache saat aplikasi start atau sebelum periode ramai.

### Strategi fallback

```go
func (s *ProdukService) Get(ctx context.Context, id int) (domain.Produk, error) {
	// cache gagal? tetap lanjut ke DB
	p, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return domain.Produk{}, err
	}
	return p, nil
}

// level berikutnya: bila DB juga gagal → serve data stale terakhir
if p, ok := s.cache.Get(ctx, key); ok {
	log.Warn("melayani data stale karena DB error", "key", key)
	return p, nil
}
```

**Prinsip graceful degradation:** satu komponen gagal tidak boleh menjatuhkan
seluruh sistem.

---

## 2. Messaging

### Konsep message broker

```
Producer → [ Broker (queue/topic) ] → Consumer
              │
              ├─ RabbitMQ (AMQP, queue per consumer group)
              └─ Kafka   (log terurut, partition, replay)
```

**Kapan pakai messaging:**

- **Async processing** — request tidak perlu menunggu pekerjaan berat.
- **Decoupling** — pengirim tidak tahu siapa penerima.
- **Buffering** — menyerap lonjakan trafik (peak shaving).
- **Event-driven** — banyak layanan bereaksi terhadap satu kejadian.

### Producer dengan RabbitMQ

```go
import amqp "github.com/rabbitmq/amqp091-go"

func Hubungkan() (*amqp.Connection, error) {
	return amqp.Dial("amqp://guest:guest@localhost:5672/")
}

func Publish(ch *amqp.Channel, body []byte) error {
	return ch.PublishWithContext(context.Background(),
		"exchange_orders",  // exchange
		"orders.created",   // routing key
		false,              // mandatory
		false,              // immediate
		amqp.Publishing{
			ContentType:  "application/json",
			DeliveryMode: amqp.Persistent, // ✅ tahan restart broker
			MessageId:    uuid.NewString(), // untuk idempotency/dedup
			Timestamp:    time.Now(),
			Body:         body,
		},
	)
}
```

### Consumer dengan acknowledgment

```go
func Consumer(conn *amqp.Connection) error {
	ch, err := conn.Channel()
	if err != nil {
		return err
	}

	// prefetch: jangan tarik terlalu banyak (fair dispatch)
	if err := ch.Qos(10, 0, false); err != nil {
		return err
	}

	msgs, err := ch.Consume("orders", "worker-1",
		false, // autoAck = FALSE → manual ack (WAJIB)
		false, false, false, nil,
	)
	if err != nil {
		return err
	}

	for msg := range msgs {
		var order Order
		if err := json.Unmarshal(msg.Body, &order); err != nil {
			// pesan rusak — jangan retry terus: kirim ke DLQ
			_ = msg.Reject(false) // requeue=false
			continue
		}

		if err := proses(order); err != nil {
			log.Printf("proses gagal: %v", err)
			if msg.Headers["x-retry-count"].(int64) < 3 {
				_ = msg.Nack(false, true)  // requeue → retry
			} else {
				_ = msg.Reject(false)      // lempar ke DLQ
			}
			continue
		}

		_ = msg.Ack(false) // ✅ hanya setelah BERHASIL
	}
	return nil
}
```

> **⚠️ Aturan emas:** **jangan auto-ack**. Ack hanya setelah pekerjaan benar-benar
> selesai. Kalau consumer mati sebelum ack, pesan akan dikirim ulang — itu
> justru yang diinginkan (at-least-once).

### Retry dengan backoff

```go
func DenganRetry(ctx context.Context, maks int, fn func(context.Context) error) error {
	var err error
	for i := 0; i < maks; i++ {
		if err = fn(ctx); err == nil {
			return nil
		}
		if ctx.Err() != nil {
			return ctx.Err()
		}

		// exponential backoff dengan jitter
		delay := time.Duration(1<<uint(i)) * time.Second // 1s, 2s, 4s, 8s...
		jitter := time.Duration(rand.IntN(1000)) * time.Millisecond
		delay += jitter

		// batas atas
		if delay > 30*time.Second {
			delay = 30 * time.Second
		}

		select {
		case <-time.After(delay):
		case <-ctx.Done():
			return ctx.Err()
		}
	}
	return fmt.Errorf("gagal setelah %d percobaan: %w", maks, err)
}
```

**Mengapa jitter?** Tanpa jitter, semua client gagal pada saat yang sama dan
kembali bersamaan (*thundering herd*).

### Dead-letter queue (DLQ)

```go
// pesan yang gagal berulang kali dialihkan ke DLQ
_, err := ch.QueueDeclare("orders.dlq", true, false, false, false, nil)
_, err = ch.QueueBind("orders.dlq", "orders.*", "exchange_orders", false, nil)

// konsumen khusus DLQ untuk inspeksi/manual retry
```

**Alur:**

```
queue utama → gagal 3x → DLQ → monitoring/alarm → diperbaiki → requeue
```

DLQ mencegah **poison message** (pesan yang selalu gagal) memblokir queue.

### Idempotency

Karena delivery **at-least-once**, pemrosesan harus **idempotent**
(mengulang = hasil sama).

```go
func ProsesOrder(ctx context.Context, o Order) error {
	// 1. cek apakah sudah pernah diproses (dedup)
	ada, err := sudahDiproses(ctx, o.ID)
	if err != nil || ada {
		return err // sudah pernah → langsung sukses (anggap ack)
	}

	// 2. lakukan pekerjaan + tandai "sudah" dalam SATU transaksi
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx,
		`INSERT INTO diproses (message_id) VALUES (?) ON DUPLICATE KEY UPDATE message_id = message_id`,
		o.ID); err != nil {
		return err
	}

	// ... kerjakan pemrosesan

	return tx.Commit()
}
```

**Teknik idempotency:**

- **Unique key** pada sumber pesan (`message_id`, `idempotency-key`).
- `INSERT ... ON DUPLICATE KEY UPDATE` — operasi "sekali kerja".
- Status state machine: `pending → processed` — hanya transisi valid yang jalan.

### Event-driven architecture

```go
// mendefinisikan event
type Event struct {
	ID        string    `json:"id"`
	Type      string    `json:"type"`      // "order.created"
	Payload   []byte    `json:"payload"`
	Timestamp time.Time `json:"timestamp"`
	Source    string    `json:"source"`
}

// producer
EventBus.Publish(ctx, Event{
	Type:    "order.created",
	Payload: mustMarshal(order),
})
```

```go
// consumer per layanan — setiap layanan berlangganan event yang relevan
func (h *Handler) tanganiEvent(ctx context.Context, ev Event) error {
	switch ev.Type {
	case "order.created":
		kecilService.kirimEmailKonfirmasi(ctx, ev.Payload)
		analytics.catatPenjualan(ctx, ev.Payload)
		gudang.tandaiStok(ctx, ev.Payload)
	}
	return nil
}
```

**Keuntungan:** pengirim tidak perlu tahu siapa saja yang peduli —
menambah layanan baru tidak menyentuh kode lama.

### Outbox pattern (konsep)

**Masalah:** "tulis DB + kirim event" adalah dua operasi — bila salah satu
gagal, data tidak konsisten.

```
❌ tanpa outbox:
   INSERT ke DB → sukses → Publish gagal → event hilang!

✅ dengan outbox:
   dalam SATU transaksi:
     INSERT ke DB
     INSERT event ke TABEL outbox
   → poller/scheduler membaca outbox lalu publish
   → event dijamin terkirim (setidaknya sekali)
```

```go
func BuatOrder(ctx context.Context, tx *sql.Tx, o Order) error {
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO orders (id, total) VALUES (?, ?)`, o.ID, o.Total); err != nil {
		return err
	}
	// event ditulis dalam transaksi yang sama
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO outbox (event_type, payload, created_at)
		 VALUES (?, ?, NOW())`,
		"order.created", mustMarshal(o)); err != nil {
		return err
	}
	return tx.Commit() // atomik: keduanya berhasil atau keduanya gagal
}
```

Populasi: **transactional outbox** + relay (poller, atau Debezium untuk CDC).

---

## 3. Reliability

### Timeout

```go
// 1. HTTP client dengan timeout
client := &http.Client{Timeout: 5 * time.Second}

// 2. per panggilan dengan context
ctx, cancel := context.WithTimeout(ctx, 2*time.Second)
defer cancel()
resp, err := client.Do(req.WithContext(ctx))

// 3. timeout di seluruh rantai — timeout lapisan luar harus > dalam
//    handler 10s > service 8s > repo 5s > db 3s
```

> **Aturan:** **selalu** ada timeout di setiap panggilan lintas jaringan.
> Tanpa timeout, satu layanan lambat bisa menahan seluruh goroutine.

### Retry dengan backoff

Sudah dibahas di atas. Prinsipnya:

```go
// ✅ Retry HANYA untuk error yang idempotent-safe
retryable := func(err error) bool {
	switch {
	case errors.Is(err, context.DeadlineExceeded): // timeout — kemungkinan sudah diproses
		return false // hati-hati: bisa jadi sudah sukses
	case isNetworkError(err):
		return true
	case isServerError(err): // 5xx
		return true
	default: // 4xx — jangan retry, pasti gagal lagi
		return false
	}
}
```

**Aturan retry:**

- **Exponential backoff + jitter.**
- **Batas jumlah** percobaan (mis. 3-5).
- **Hanya** untuk operasi idempotent (GET, PUT dengan key sama) —
  POST berulang bisa membuat data ganda (solusi: idempotency key).
- Sertakan **timeout global** agar retry tidak berjalan tanpa batas.

### Circuit breaker

```
CLOSED    → semua request normal
  ↓ error rate melewati threshold
OPEN      → request DITOLAK langsung (fast-fail), panggilan ke downstream DIBLOKIR
  ↓ setelah interval cool-down
HALF-OPEN → izinkan beberapa request percobaan
  ↓ semua sukses
CLOSED    → normal kembali
  ↓ ada yang gagal lagi
OPEN      → kembali membuka
```

```go
type CircuitBreaker struct {
	mu          sync.Mutex
	state       State
	failures    int
	threshold   int
	resetAfter  time.Time
	cooldown    time.Duration
}

func (cb *CircuitBreaker) Panggil(fn func() error) error {
	if !cb.izinkan() {
		return ErrCircuitTerbuka // fast-fail — jangan tunggu downstream
	}

	err := fn()
	cb.catat(err)
	return err
}

// penggunaan pada HTTP call eksternal
if err := cb.Panggil(func() error {
	return panggilLayananEksternal(ctx)
}); err != nil {
	if errors.Is(err, ErrCircuitTerbuka) {
		return fallback() // graceful degradation
	}
	return err
}
```

**Library:** `sony/gobreaker` atau `github.com/uber-go/ratelimit`.

**Kapan berguna:** saat memanggil **layanan eksternal** yang bisa lambat —
mencegah thread/goroutine menumpuk menunggu yang sudah pasti gagal.

### Bulkhead

**Bulkhead** = membatasi jumlah request yang boleh masuk ke setiap dependensi,
sehingga kegagalan satu bagian tidak menjatuhkan seluruh aplikasi.

```go
// batasi concurrency ke database
dbSem := make(chan struct{}, 20) // maks 20 query serentak

func (r *repo) Query(ctx context.Context, q string, args ...any) (*sql.Rows, error) {
	select {
	case dbSem <- struct{}{}:
		defer func() { <-dbSem }()
		return r.db.QueryContext(ctx, q, args...)
	case <-ctx.Done():
		return nil, ctx.Err() // menunggu terlalu lama → batalkan
	}
}
```

Pola yang sama berlaku untuk pool koneksi (`SetMaxOpenConns`) dan HTTP client.

### Idempotent API

```go
// klien mengirim header Idempotency-Key
func (h *Handler) Bayar(w http.ResponseWriter, r *http.Request) {
	key := r.Header.Get("Idempotency-Key")
	if key == "" {
		kirimError(w, http.StatusBadRequest, "KEY_KURANG", "Idempotency-Key wajib")
		return
	}

	// cek apakah key ini sudah pernah diproses
	if hasil, ada := h.store.Get(key); ada {
		// ✅ kembalikan hasil SAMA — bukan error
		tulisJSON(w, hasil.Status, hasil.Body)
		return
	}

	// proses, simpan hasil dengan key
	hasil := h.lakukanPembayaran(r.Context(), key)
	h.store.Put(key, hasil)
	tulisJSON(w, hasil.Status, hasil.Body)
}
```

**Aturan:** hasil pertama **disimpan** dan **dikembalikan ulang** untuk permintaan
berikutnya dengan key yang sama.

### Graceful degradation

```go
func (s *Service) Rekomendasi(ctx context.Context, userID int) ([]Produk, error) {
	// 1. coba layanan rekomendasi (ML)
	hasil, err := s.rekomendasiSvc.Panggil(ctx, userID)
	if err == nil {
		return hasil, nil
	}
	s.log.Warn("rekomendasi gagal — fallback", "err", err)

	// 2. fallback: produk populer dari cache
	if populer, ok := s.cache.Get(ctx, "produk:populer"); ok {
		return decodeProduk(populer), nil
	}

	// 3. fallback terakhir: query paling sederhana
	return s.repo.Populer(ctx, 10)
}
```

**Prinsip:** setiap fitur non-kritis punya **rencana turunan** —
sistem tetap berguna walau bagian rusak.

### Health check dan readiness

```go
// LIVENESS: apakah proses hidup? (untuk restart container)
mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "ok")
})

// READINESS: apakah siap menerima trafik? (untuk load balancer)
mux.HandleFunc("GET /readyz", func(w http.ResponseWriter, r *http.Request) {
	checks := map[string]error{
		"database": db.PingContext(r.Context()),
		"cache":    rdb.Ping(ctx).Err(),
	}

	mu := map[string]bool{}
	var gagal []string
	for nama, err := range checks {
		if err != nil {
			gagal = append(gagal, nama)
			mu[nama] = false
		}
		mu[nama] = err == nil
	}

	if len(gagal) > 0 {
		tulisJSON(w, http.StatusServiceUnavailable, map[string]any{
			"status": "unready",
			"failed": gagal,
		})
		return
	}
	tulisJSON(w, http.StatusOK, map[string]any{"status": "ready"})
})
```

**Bedanya:**

- `/healthz` gagal → proses **harus di-restart** (deadlock, panic terus).
- `/readyz` gagal → **jangan kirim trafik** (DB down), tapi proses tetap hidup.

### Graceful shutdown

Sudah dibahas di fase 7/9. Untuk worker:

```go
<-ctx.Done()
log.Println("shutdown: berhenti menerima job baru")
close(jobs)               // beri tahu worker berhenti
wg.Wait()                 // tunggu job yang sedang berjalan selesai
log.Println("shutdown selesai")
```

**Urutan shutdown yang benar:**

1. Terima sinyal → berhenti menerima request baru (`srv.Shutdown`).
2. Tunggu request in-flight selesai (dengan timeout).
3. Tutup koneksi ke downstream (DB, cache, broker).
4. Tutup server HTTP terakhir.

### Konsistensi data dan transaksi

```
SINGLE DATABASE  → transaksi ACID biasa (cukup untuk banyak kasus)

DUA DATABASE     → tidak ada transaksi global gratis:
  ✅ Sagas        → langkah kompensasi (rollback manual per langkah)
  ✅ Outbox       → event dalam transaksi lokal
  ⚠️ Two-phase commit → kompleks, jarang dipakai di microservice
```

```go
// Saga sederhana: dua langkah + kompensasi
func PesanDenganSaga(ctx context.Context, o Order) error {
	// langkah 1: kurangi stok
	if err := kurangiStok(ctx, o); err != nil {
		return err // gagal → tidak ada yang perlu dikompensasi
	}

	// langkah 2: buat pembayaran
	if err := buatPembayaran(ctx, o); err != nil {
		// KOMPENSASI: kembalikan stok
		if compErr := tambahStokKembali(ctx, o); compErr != nil {
			log.Error("kompensasi gagal — perlu manual intervention",
				"order", o.ID, "err", compErr)
		}
		return err
	}
	return nil
}
```

> **Catatan:** kompensasi yang gagal harus **di-log dan dipantau** —
> itu pekerjaan manual (atau workflow engine).

---

## Praktik

### 1. API dengan Redis cache

Terapkan cache-aside pada endpoint `GET /produk/{id}`:

- Hit: balas dari Redis, header `X-Cache: HIT`.
- Miss: query DB, set Redis dengan TTL 5 menit.
- Update produk: hapus key terkait.
- Ukur: bandingkan latensi sebelum/sesudah.

### 2. Background worker

```go
func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	queue := make(chan Job, 100)

	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			for job := range queue {
				if err := job.Jalan(ctx); err != nil {
					log.Error("job gagal", "worker", id, "job", job.ID, "err", err)
				}
			}
		}(i)
	}

	// producer dari HTTP handler
	mux.HandleFunc("POST /jobs", func(w http.ResponseWriter, r *http.Request) {
		var job Job
		json.NewDecoder(r.Body).Decode(&job)
		select {
		case queue <- job:
			w.WriteHeader(http.StatusAccepted)
		case <-ctx.Done():
			w.WriteHeader(http.StatusServiceUnavailable)
		}
	})

	go http.ListenAndServe(":8080", mux)

	<-ctx.Done()
	close(queue)
	wg.Wait()
}
```

### 3. Job queue dengan retry

Gabungkan pola: worker pool + `DenganRetry` + backoff + DLQ (bila memakai broker).

```go
func (w *Worker) prosesJob(ctx context.Context, job Job) error {
	err := DenganRetry(ctx, 3, func(ctx context.Context) error {
		return w.handler(ctx, job)
	})
	if err != nil {
		// lempar ke DLQ / tabel gagal
		return w.dlq.Enqueue(ctx, job, err)
	}
	return nil
}
```

### 4. Event publisher dan consumer

1. Satu service menerbitkan `order.created` ke RabbitMQ/Kafka.
2. Service lain mengkonsumsi dan mengirim email.
3. Tambahkan DLQ, retry, dan dedup.

### 5. Proses idempotent

Ambil operasi `POST /transfer` lalu buat idempotent dengan `Idempotency-Key`
(disimpan di tabel/Redis, hasil pertama dikembalikan ulang).

---

## Checklist Fase 10

- [x] Konsep caching, cache in-memory, Redis.
- [x] Cache invalidation, TTL, delete-on-write, versioned key.
- [x] Cache stampede + singleflight, stale-while-revalidate, fallback.
- [x] Message broker: producer, consumer, manual ack, prefetch.
- [x] Retry + exponential backoff + jitter, dead-letter queue, idempotency.
- [x] Event-driven architecture, outbox pattern.
- [x] Timeout, retry, circuit breaker, bulkhead, idempotent API.
- [x] Graceful degradation, health check/readiness, graceful shutdown, konsistensi (saga).

## Ringkasan

- Cache menambah kecepatan dengan biaya **kemungkinan data stale** — pilih TTL
  vs konsistensi secara sadar.
- **Singleflight** mencegah stampede; **stale-while-revalidate** menjaga latensi.
- Consumer **manual ack**; pesan gagal → **retry + backoff + DLQ**.
- Delivery **at-least-once** → pemrosesan **wajib idempotent**.
- **Timeout selalu ada** di setiap panggilan lintas jaringan.
- Circuit breaker + fallback menjaga satu kegagalan tidak menjatuhkan sistem.

---

Lanjut ke: [Fase 11 — Deployment dan Production]({{ site.baseurl }}/belajar-go/fase-11-deployment-production/)
