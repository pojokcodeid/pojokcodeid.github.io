---
layout: post
title: "Fase 6 — Concurrency dan Parallelism"
date: 2026-11-13 09:00:00 +0700
categories: [golang, tutorial]
tags: [golang, goroutine, channel, concurrency, context, sync]
permalink: /belajar-go/fase-6-concurrency/
image:
  path: /assets/posts/2026-11-10-go.png
  alt: Concurrency dan Parallelism
---

# Concurrency dan Parallelism

Concurrency adalah keunggulan utama Go: **goroutine** dan **channel** adalah
fitur bahasa, bukan library. Fase ini membahas dari dasar sampai pola production.

## Tujuan

- Membedakan concurrency dan parallelism.
- Menulis goroutine dengan benar dan menghindari leak.
- Menggunakan channel (buffered/unbuffered), `close`, `range`, `select`.
- Mensinkronkan dengan `sync` dan mendeteksi data race.
- Menggunakan context untuk cancellation dan timeout.
- Menerapkan pola: worker pool, fan-out/fan-in, pipeline, rate limiting.

---

## 1. Goroutine

### Concurrency vs Parallelism

```
Concurrency  : mengelola banyak TUGAS dalam satu waktu (bisa di satu thread)
Parallelism  : mengeksekusi banyak TUGAS BERSAMAANAN (butuh lebih dari satu CPU)
```

- Satu goroutine ≠ satu thread. Runtime Go menjalankan ribuan goroutine di
  puluhan thread (M:N scheduler).
- Concurrency bisa berjalan di satu core; parallelism butuh banyak core.
- `runtime.GOMAXPROCS(n)` mengatur jumlah goroutine yang dieksekusi paralel
  (default = jumlah CPU).

### `go` statement

```go
package main

import (
	"fmt"
	"time"
)

func kerja(nama string) {
	for i := 0; i < 3; i++ {
		fmt.Printf("%s bekerja %d\n", nama, i)
		time.Sleep(100 * time.Millisecond)
	}
}

func main() {
	go kerja("A") // mulai goroutine A
	go kerja("B") // mulai goroutine B

	kerja("C")    // main juga sebuah goroutine

	time.Sleep(500 * time.Millisecond) // ⚠️ cara KASAR menunggu
}
```

> **⚠️ Jebakan pertama:** tanpa `time.Sleep`, program selesai sebelum goroutine
> A dan B sempat mencetak apa pun — **main exit = semua goroutine mati**.
> Cara benar menunggu: `sync.WaitGroup` atau channel (lihat di bawah),
> **bukan** `time.Sleep`.

### Lifecycle goroutine

```go
func main() {
	done := make(chan struct{}) // struct{} = channel tanpa data

	go func() {
		fmt.Println("goroutine bekerja")
		done <- struct{}{} // tanda selesai
	}()

	<-done // tunggu sinyal
}
```

### Risiko goroutine leak

**Goroutine leak** = goroutine yang tidak pernah selesai, menumpuk selamanya.

```go
func AmbilData() string {
	ch := make(chan string) // unbuffered!

	go func() {
		ch <- proses() // ← bila TIDAK ADA yang membaca, goroutine ini HANG selamanya
	}()

	// ❌ bila ada early return di sini sebelum <-ch:
	// goroutine di atas bocor selamanya
	return <-ch
}
```

**Penyebab umum leak:**

1. Membaca dari channel yang tidak pernah dikirim (`<-ch` tanpa pengirim).
2. Mengirim ke channel penuh tanpa penerima.
3. Goroutine yang menunggu timeout/context yang tidak pernah dibatalkan.
4. `time.After` dalam loop berulang (timer menumpuk).
5. Goroutine yang tidak pernah menerima cancellation.

**Deteksi:**

```go
fmt.Println(runtime.NumGoroutine()) // pantau jumlah goroutine hidup
// atau dengan goleak (uber) di test:
// goleak.VerifyNone(t)
```

**Pencegahan:**

```go
func AmbilData(ctx context.Context) (string, error) {
	ch := make(chan string, 1) // ✅ buffer 1 — pengirim tidak pernah hang
	done := make(chan struct{})

	go func() {
		defer close(done)
		ch <- proses()
	}()

	select {
	case v := <-ch:
		return v, nil
	case <-ctx.Done():
		return "", ctx.Err() // ✅ keluar saat context dibatalkan
	}
}
```

### Sinkronisasi goroutine — WaitGroup

```go
var wg sync.WaitGroup

for i := 0; i < 5; i++ {
	wg.Add(1)          // ⚠️ TAMBAH sebelum go — bukan di dalam goroutine
	go func(n int) {
		defer wg.Done() // selalu Done via defer
		fmt.Println("kerja", n)
	}(i)
}

wg.Wait() // tunggu sampai semua selesai
```

> **⚠️ `wg.Add(1)` harus dipanggil SEBELUM `go`.** Jika dipanggil di dalam
> goroutine, `Wait()` bisa terlebih dulu dan program selesai sebelum kerja mulai.

---

## 2. Channel

Channel adalah **pipa komunikasi** antar goroutine — *"Don't communicate by
sharing memory; share memory by communicating."*

### Membuat dan mengirim/menerima

```go
// unbuffered — pengirim TUNGGU sampai ada penerima (synchronizing)
ch := make(chan int)
ch <- 42      // kirim (blokir sampai diterima)
v := <-ch     // terima (blokir sampai ada pengirim)

// buffered — muat N data tanpa penerima
ch := make(chan int, 3)
ch <- 1
ch <- 2
fmt.Println(len(ch)) // 2 — jumlah data di buffer
fmt.Println(cap(ch)) // 3 — kapasitas buffer
```

**Perbedaan kunci:**

| | Unbuffered | Buffered |
|---|---|---|
| Pengirim | Blokir sampai diterima | Blokir hanya bila buffer penuh |
| Penerima | Blokir sampai ada pengirim | Blokir bila buffer kosong |
| Fungsi | Synchronization point | Decoupling / asynchronous |

### Close channel

```go
ch := make(chan int, 3)
ch <- 1
ch <- 2
close(ch) // ⚠️ hanya pengirim yang boleh close

// menerima dari channel yang sudah closed: mengembalikan zero value, ok=false
v, ok := <-ch // 1, true
v, ok = <-ch  // 2, true
v, ok = <-ch  // 0, false ← channel tertutup
```

**Aturan:**

- **Hanya pengirim** yang `close` — bukan penerima (menutup channel yang dikirim
  = panic *"close of closed channel"*).
- Kirim ke channel yang sudah `close` = **panic**.
- Menerima dari channel closed **aman** (mengembalikan zero value).
- `close` diperlukan agar penerima bisa tahu kapan data selesai.

### `range` pada channel

```go
func kirimAngka(ch chan int) {
	defer close(ch) // pengirim yang menutup
	for i := 1; i <= 5; i++ {
		ch <- i
	}
}

func main() {
	ch := make(chan int)
	go kirimAngka(ch)

	for v := range ch { // berhenti otomatis saat channel closed
		fmt.Println(v)
	}
}
```

`for range ch` berjalan sampai channel **ditutup** — tanpa `close`, loop ini
menggantung selamanya.

### Directional channel (tipe arah)

```go
// hanya boleh MENGIRIM
func pengirim(ch chan<- int) {
	ch <- 1
}

// hanya boleh MENERIMA
func penerima(ch <-chan int) {
	fmt.Println(<-ch)
}

// membatasi API → mencegah penyalahgunaan dan menangkap bug arah
```

### Deadlock

**Deadlock** = semua goroutine saling menunggu, tidak ada yang bisa lanjut.

```go
func main() {
	ch := make(chan int)
	ch <- 1 // ❌ DEADLOCK: tidak ada penerima — Go mendeteksinya
	// fatal error: all goroutines are asleep - deadlock!
}
```

Deadlock lain yang umum:

```go
// ❌ dua goroutine saling menunggu
go func() { a <- <-b }()
go func() { b <- <-a }()
```

Go **mendeteksi** deadlock program utama dan mempanic — tapi deadlock parsial
(pada sebagian goroutine) sering tidak terdeteksi dan program terlihat "macet".

**Solusi:** perhatikan arah data, gunakan timeout/`select`, dan pastikan selalu
ada jalur penyelesaian.

### `select` statement

`select` menunggu operasi channel mana pun yang siap pertama:

```go
select {
case v := <-chA:
	fmt.Println("dari A:", v)
case v := <-chB:
	fmt.Println("dari B:", v)
case chC <- 42:
	fmt.Println("kirim ke C")
case <-time.After(2 * time.Second):
	fmt.Println("timeout!")
default: // ✅ bila TIDAK ADA case siap — langsung lanjut (non-blocking)
	fmt.Println("tidak ada data")
}
```

**Penting:**

- `select` dengan **banyak case** dan **tanpa `default`** = blokir sampai ada
  satu yang siap (seperti `for` pada channel).
- **`default`** membuat `select` non-blocking.
- Bila **beberapa case siap** → pilihannya **acak** (fair, tidak berurutan).
- `time.After` berguna untuk timeout sekali pakai.

**Non-blocking receive:**

```go
select {
case v := <-ch:
	// ada data
default:
	// kosong
}
```

### Timeout dengan `time`

```go
select {
case res := <-hasil:
	fmt.Println(res)
case <-time.After(3 * time.Second):
	fmt.Println("timeout menunggu hasil")
}
```

> **⚠️** `time.After` dalam loop panjang membuat timer menumpuk (di Go < 1.23)
> — untuk timeout berulang pakai `time.NewTimer` + `Reset`, atau cukup
> gunakan `context.WithTimeout` (lihat bagian context).

---

## 3. Synchronization — `sync`

### `sync.WaitGroup`

Sudah dibahas di atas: menunggu kumpulan goroutine selesai.

```go
var wg sync.WaitGroup
for _, t := range tugas {
	wg.Add(1)
	go func(t Tugas) {
		defer wg.Done()
		proses(t)
	}(t)
}
wg.Wait()
```

### `sync.Mutex` — exclusion mutual

**Race condition** = hasil program bergantung pada urutan akses yang tak terduga.

```go
type Hitung struct {
	mu sync.Mutex
	n  int
}

func (h *Hitung) Tambah(v int) {
	h.mu.Lock()             // kunci — tunggu bila sudah dikunci
	defer h.mu.Unlock()     // buka saat keluar (termasuk saat return/panic)
	h.n += v
}

func (h *Hitung) Nilai() int {
	h.mu.Lock()
	defer h.mu.Unlock()
	return h.n
}
```

> **⚠️ Aturan:** `Lock`/`Unlock` selalu berpasangan, dan `defer Unlock` tepat
> setelah `Lock` agar tidak lupa saat ada `return` di tengah.

### `sync.RWMutex`

```go
type Cache struct {
	mu sync.RWMutex
	data map[string]string
}

func (c *Cache) Get(k string) string {
	c.mu.RLock()          // banyak pembaca boleh bersamaan
	defer c.mu.RUnlock()
	return c.data[k]
}

func (c *Cache) Set(k, v string) {
	c.mu.Lock()           // penulis eksklusif
	defer c.mu.Unlock()
	c.data[k] = v
}
```

**Kapan efektif:** saat pembaca **jauh lebih sering** daripada penulis.
Untuk operasi singkat/cepat, `Mutex` biasa sering kali sudah cukup.

### `sync.Once`

```go
var (
	cfg     *Config
	once    sync.Once
)

func muatConfig() *Config {
	once.Do(func() {          // hanya dijalankan TEPAT SATU KALI
		cfg = muatDariFile()
	})
	return cfg
}
```

Aman dipanggil dari banyak goroutine — hanya satu yang mengeksekusi.

### `sync.Map`

Map concurrent bawaan — bagus untuk kasus **read-heavy dengan key stabil**
(cache, registry), tapi **lebih lambat** dari `Mutex` + `map` biasa untuk
workload campuran. Untuk kebanyakan aplikasi, `Mutex` + map biasa lebih jelas.

### `sync/atomic`

Operasi pada angka **tanpa mutex** — sangat cepat untuk counter sederhana:

```go
type Counter struct {
	n atomic.Int64 // Go 1.19+: tipe atomik
}

func (c *Counter) Inc()         { c.n.Add(1) }
func (c *Counter) Get() int64   { return c.n.Load() }

// bentuk lama (pointer):
var count int64
atomic.AddInt64(&count, 1)
atomic.LoadInt64(&count)
```

**Kapan atomic vs mutex:**

- **Atomic**: operasi tunggal pada satu angka (counter, flag).
- **Mutex**: struktur data kompleks yang butuh banyak operasi konsisten.

### Data race dan race detector

**Data race**: dua goroutine menulis/membaca memori yang sama tanpa sinkronisasi.

```go
// ❌ DATA RACE
n := 0
var wg sync.WaitGroup
for i := 0; i < 1000; i++ {
	wg.Add(1)
	go func() {
		defer wg.Done()
		n++ // race!
	}()
}
wg.Wait()
fmt.Println(n) // tidak deterministik!
```

```bash
go run -race main.go
# WARNING: DATA RACE ... exit status 66
```

**Solusi:**

```go
// opsi 1: mutex
type Hitung struct { mu sync.Mutex; n int }
func (h *Hitung) Inc() { h.mu.Lock(); defer h.mu.Unlock(); h.n++ }

// opsi 2: channel (unik Go)
ch := make(chan int, 1000)
for i := 0; i < 1000; i++ { ch <- 1 }
close(ch)
total := 0
for range ch { total++ }

// opsi 3: atomic
var c atomic.Int64
c.Add(1)
```

> **Aturan:** jalankan test dengan `-race` secara rutin. Data race bisa
> menyebabkan bug yang hanya muncul di production dan sangat sulit direproduksi.

---

## 4. Context

Context membawa **deadline, cancellation, dan nilai lintas** goroutine/layer.

### Konsep

```go
import "context"

ctx := context.Background() // titik awal — tidak pernah dibatalkan
ctx := context.TODO()       // "belum tahu" — placeholder sementara
```

**Aturan konteks:**

1. Context selalu **parameter pertama** fungsi: `func Do(ctx context.Context, ...)`.
2. Context **tidak disimpan di struct** — diteruskan dari luar.
3. Selalu **teruskan** context ke fungsi bawahan.
4. `context.WithValue` hanya untuk data request-scoped (bukan parameter config).

### `WithCancel`

```go
ctx, cancel := context.WithCancel(context.Background())
defer cancel() // ⚠️ SELALU panggil — mencegah leak (biasanya via defer)

go func() {
	// pekerjaan yang bisa dibatalkan
	for {
		select {
		case <-ctx.Done():
			fmt.Println("dibatalkan:", ctx.Err())
			return
		default:
			// lanjut bekerja
		}
	}
}()

// pembatalan dari luar
cancel()
```

**Kapan membatalkan:** saat pemanggil tidak lagi membutuhkan hasilnya
(mis. request HTTP sudah ditutup).

### `WithTimeout` dan `WithDeadline`

```go
// timeout 2 detik
ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
defer cancel()

err := db.QueryRowContext(ctx, "SELECT ...").Scan(&x)
if errors.Is(err, context.DeadlineExceeded) {
	fmt.Println("query melebihi waktu")
}

// deadline absolut
ctx, cancel := context.WithDeadline(context.Background(), time.Now().Add(5*time.Second))
```

**⚠️ `cancel` harus selalu dipanggil** (via `defer`) — kalau tidak, resource
(timer, goroutine pemeriksa) bocor sampai timeout aslinya habis.

### `WithValue` dan batas penggunaannya

```go
type ctxKey string
const requestIDKey ctxKey = "request_id"

ctx = context.WithValue(ctx, requestIDKey, "abc-123")

id, ok := ctx.Value(requestIDKey).(string) // selalu type-assert + ok
```

> **⚠️ Hanya untuk:** request ID, trace ID, user yang sedang login (data yang
> hidup selama request). **Jangan** untuk dependency injection (db, config) —
> itu mengubah context jadi "service locator" yang tak terlihat.

### Propagasi dan graceful shutdown

```go
func main() {
	ctx, stop := signal.NotifyContext(context.Background(),
		os.Interrupt, syscall.SIGTERM) // tangkap Ctrl-C / SIGTERM
	defer stop()

	srv := &http.Server{Addr: ":8080", Handler: mux}

	go func() {
		<-ctx.Done() // sinyal shutdown diterima
		fmt.Println("memulai shutdown...")

		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		_ = srv.Shutdown(shutdownCtx) // tunggu request selesai
		fmt.Println("server berhenti")
	}()

	if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		fmt.Println(err)
	}
}
```

---

## 5. Pola Concurrency

### Worker pool

```go
type Tugas struct{ ID int }

func WorkerPool(ctx context.Context, tugas []Tugas, jumlahWorker int) []Hasil {
	tugasCh := make(chan Tugas)
	hasilCh := make(chan Hasil, len(tugas))

	var wg sync.WaitGroup
	for i := 0; i < jumlahWorker; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for t := range tugasCh { // pekerja mengambil tugas dari channel
				select {
				case <-ctx.Done():
					return // berhenti saat context dibatalkan
				default:
					hasilCh <- proses(t)
				}
			}
		}()
	}

	// pengirim
	go func() {
		defer close(tugasCh)
		for _, t := range tugas {
			select {
			case tugasCh <- t:
			case <-ctx.Done():
				return
			}
		}
	}()

	// menunggu semua worker selesai, lalu menutup hasil
	go func() {
		wg.Wait()
		close(hasilCh)
	}()

	var hasil []Hasil
	for h := range hasilCh { // berhenti otomatis saat hasilCh closed
		hasil = append(hasil, h)
	}
	return hasil
}
```

**Struktur klasik:** `input → workers → output`, dengan `close` yang benar
agar `range` bisa berakhir.

### Fan-out dan fan-in

```go
// FAN-OUT: satu channel → banyak worker membaca
for i := 0; i < 4; i++ {
	go worker(in, out)
}

// FAN-IN: banyak channel → satu channel menggabung
func gabung(ctx context.Context, chs ...<-chan int) <-chan int {
	out := make(chan int)
	var wg sync.WaitGroup
	for _, ch := range chs {
		wg.Add(1)
		go func(ch <-chan int) {
			defer wg.Done()
			for v := range ch {
				out <- v
			}
		}(ch)
	}
	go func() {
		wg.Wait()
		close(out)
	}()
	return out
}
```

### Pipeline

```go
// tahap 1: baca angka
func angka(ctx context.Context) <-chan int {
	out := make(chan int)
	go func() {
		defer close(out)
		for i := 1; i <= 10; i++ {
			select {
			case out <- i:
			case <-ctx.Done():
				return
			}
		}
	}()
	return out
}

// tahap 2: kuadratkan
func kuadrat(ctx context.Context, in <-chan int) <-chan int {
	out := make(chan int)
	go func() {
		defer close(out)
		for v := range in {
			select {
			case out <- v * v:
			case <-ctx.Done():
				return
			}
		}
	}()
	return out
}

// penyusunan
ctx := context.Background()
ch := kuadrat(ctx, angka(ctx))
for v := range ch {
	fmt.Println(v) // 1 4 9 16 ...
}
```

**Aturan pipeline:** tiap tahap `close` channel output-nya via `defer`,
membuat `range` di tahap berikutnya berakhir otomatis.

### Semaphore dan bounded concurrency

```go
sem := make(chan struct{}, 10) // kapasitas = batas serentak

var wg sync.WaitGroup
for _, url := range urls {
	wg.Add(1)
	sem <- struct{}{}            // "ambil izin" — blokir bila sudah 10
	go func(u string) {
		defer wg.Done()
		defer func() { <-sem }()   // "lepaskan izin"
		kunjungi(u)
	}(url)
}
wg.Wait()
```

Atau dengan pola yang lebih ringkas:

```go
// batasi N goroutine serentak
limiter := make(chan struct{}, N)
```

### Rate limiting

```go
// token bucket sederhana: 10 request per detik
ticker := time.NewTicker(100 * time.Millisecond)
defer ticker.Stop()

for _, req := range requests {
	<-ticker.T // tunggu token
	kirim(req)
}
```

Batas global dengan shared ticker:

```go
rate := time.NewTicker(50 * time.Millisecond)
defer rate.Stop()

go func() {
	for _, u := range urls {
		<-rate.C
		go unduh(u)
	}
}()
```

### Error handling pada worker

```go
type Hasil struct {
	Data  string
	Err error
}

// ✅ kirim error LEWAT channel, bukan return (worker tidak bisa return ke pemanggil)
go func() {
	defer wg.Done()
	data, err := proses(t)
	out <- Hasil{Data: data, Err: err}
}()

// kumpulkan
for h := range out {
	if h.Err != nil {
		errs = append(errs, h.Err)
	}
}
```

**Strategi:**

- **Collect semua error** → laporkan bersamaan di akhir.
- **Fail-fast** → batalkan sisa pekerjaan dengan `cancel()` begitu ada error pertama.
- Bungkus dengan `fmt.Errorf("proses tugas %d: %w", id, err)` agar konteks jelas.

```go
// fail-fast dengan errgroup (golang.org/x/sync/errgroup)
g, ctx := errgroup.WithContext(ctx)
for _, t := range tugas {
	g.Go(func() error {
		return proses(ctx, t) // error pertama membatalkan ctx
	})
}
if err := g.Wait(); err != nil {
	// error pertama
}
```

### Menghindari goroutine leak — ringkasan

1. Selalu ada **jalur keluar**: `select` + `ctx.Done()` atau timeout.
2. Pengirim menutup channel (`defer close(ch)`).
3. Buffer channel sesuai kebutuhan agar pengirim tidak bergantung penerima.
4. `defer cancel()` untuk setiap `context.WithXxx`.
5. Test dengan `go test -race` dan `goleak`.

---

## Praktik

### 1. Downloader file concurrent

```go
package main

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"sync"
	"time"
)

func unduh(ctx context.Context, url, folder string) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return err
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("%s: status %d", url, resp.StatusCode)
	}

	nama := filepath.Base(url)
	f, err := os.Create(filepath.Join(folder, nama))
	if err != nil {
		return err
	}
	defer f.Close()

	_, err = io.Copy(f, resp.Body)
	return err
}

func main() {
	urls := []string{
		"https://example.com/file1.zip",
		"https://example.com/file2.zip",
		"https://example.com/file3.zip",
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	sem := make(chan struct{}, 5) // maksimal 5 serentak
	var wg sync.WaitGroup
	var mu sync.Mutex
	var errs []error

	for _, u := range urls {
		wg.Add(1)
		sem <- struct{}{}
		go func(u string) {
			defer wg.Done()
			defer func() { <-sem }()

			if err := unduh(ctx, u, "unduhan"); err != nil {
				mu.Lock()
				errs = append(errs, err)
				mu.Unlock()
				fmt.Println("gagal:", err)
				return
			}
			fmt.Println("selesai:", u)
		}(u)
	}
	wg.Wait()
}
```

### 2. Worker pool untuk memproses data

Lihat contoh lengkap di bagian **Worker pool** di atas — sesuaikan `proses`
dengan kebutuhan (memproses baris CSV, transcode gambar, dsb).

### 3. Concurrent API checker

```go
func cekAPI(ctx context.Context, urls []string) map[string]int {
	hasil := sync.Map{} // atau Mutex + map biasa
	sem := make(chan struct{}, 20)
	var wg sync.WaitGroup

	for _, u := range urls {
		wg.Add(1)
		sem <- struct{}{}
		go func(u string) {
			defer wg.Done()
			defer func() { <-sem }()

			req, _ := http.NewRequestWithContext(ctx, http.MethodHead, u, nil)
			resp, err := http.DefaultClient.Do(req)
			if err != nil {
				hasil.Store(u, 0)
				return
			}
			defer resp.Body.Close()
			hasil.Store(u, resp.StatusCode)
		}(u)
	}
	wg.Wait()

	out := map[string]int{}
	hasil.Range(func(k, v any) bool {
		out[k.(string)] = v.(int)
		return true
	})
	return out
}
```

### 4. Pipeline pemrosesan data

Bangun pipeline 3 tahap: **baca baris → parse → simpan**, masing-masing
menjalankan beberapa worker dengan `close` yang benar.

### 5. Simulasi job queue sederhana

```go
type Job struct {
	ID   int
	Arg  string
}

type JobQueue struct {
	jobs chan Job
	wg   sync.WaitGroup
}

func NewJobQueue(n int, handler func(Job)) *JobQueue {
	q := &JobQueue{jobs: make(chan Job, 100)}
	for i := 0; i < n; i++ {
		q.wg.Add(1)
		go func() {
			defer q.wg.Done()
			for j := range q.jobs {
				handler(j) // tangani panic per job agar worker tidak mati
			}
		}()
	}
	return q
}

func (q *JobQueue) Tambah(j Job) { q.jobs <- j }

func (q *JobQueue) Tutup() {
	close(q.jobs)
	q.wg.Wait()
}
```

---

## Checklist Fase 6

- [x] Concurrency vs parallelism, goroutine, `go` statement, lifecycle, goroutine leak, sinkronisasi.
- [x] Channel: buffered/unbuffered, kirim/terima, `close`, `range`, directional, deadlock, `select`, timeout `time`.
- [x] `sync.WaitGroup`, `Mutex`, `RWMutex`, `Once`, `atomic`, race condition, data race, race detector.
- [x] Context: `Background`, `TODO`, `WithCancel`, `WithTimeout`, `WithDeadline`, `WithValue`, propagasi, graceful shutdown.
- [x] Pola: worker pool, fan-out, fan-in, pipeline, semaphore, bounded concurrency, rate limiting, error pada worker, anti leak.

## Ringkasan

- Goroutine murah (±2KB stack) tapi **bukan gratis** — selalu ada jalur selesai.
- Channel adalah alat komunikasi: pengirim `close`, penerima `range`.
- `select` + `ctx.Done()` adalah pola cancellation baku.
- **Selalu** `defer cancel()` pada context ber-`With*`.
- Mutex untuk struktur data, atomic untuk angka, channel untuk koordinasi.
- Jalankan test dengan `-race` — data race adalah bug nyata, bukan teori.

---

Lanjut ke: [Fase 7 — HTTP dan REST API]({{ site.baseurl }}/belajar-go/fase-7-http-rest-api/)
