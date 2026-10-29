# Catatan Developer — Jekyll + Chirpy + Podman

Situs GitHub Pages dengan [Jekyll](https://jekyllrb.com/) dan tema
[Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy). Development
berjalan penuh di container Podman, jadi Ruby tidak perlu diinstal di host.

## Struktur

```
.
├── _config.yml              # konfigurasi situs
├── _posts/                  # postingan (YYYY-MM-DD-judul.md)
├── _drafts/                 # draft, tampil hanya saat development
├── _tabs/                   # halaman sidebar (about, archives, ...)
├── assets/img/              # gambar
├── Gemfile                  # dependensi Ruby
├── Containerfile            # image development
├── compose.yaml             # alternatif: podman compose
├── Makefile                 # shortcut perintah
└── .github/workflows/       # CI/CD ke GitHub Pages
```

## Mulai Cepat

1. Instal Podman dan `make`.
2. Edit `_config.yml`: ganti `USERNAME`, `url`, `baseurl`, `title`, dan data `social`.
3. Jalankan:

```bash
make build   # sekali saja
make up      # http://localhost:4000
```

Hentikan dengan `Ctrl+C`. Tanpa `make`, gunakan `podman compose up --build`.

## Perintah

| Perintah | Fungsi |
|---|---|
| `make build` | Build image |
| `make up` | Dev server (foreground, LiveReload) |
| `make start` / `make stop` / `make logs` | Dev server di background |
| `make shell` | Masuk shell container |
| `make new-post TITLE="Judul"` | Buat postingan baru |
| `make prod` | Build produksi ke `_site/` |
| `make test` | Build produksi + html-proofer |
| `make lock` | Update `Gemfile.lock` |
| `make clean` | Hapus `_site` dan cache |

## Catatan

- Perubahan `_config.yml` butuh restart (`Ctrl+C`, lalu `make up`).
- Flag `:Z` pada volume untuk SELinux (Fedora/RHEL); aman di sistem lain.
- Project page (bukan `USERNAME.github.io`): isi `baseurl: "/nama-repo"`,
  lalu akses `http://localhost:4000/nama-repo/`.
- macOS/Windows: jalankan `podman machine start` dulu. Bila port 4000 terpakai,
  ubah mapping menjadi `-p 4001:4000`.
- Ubah versi tema di `Gemfile`, lalu `make build`. Cek rilis terbaru di
  https://github.com/cotes2020/jekyll-theme-chirpy/releases.
- Commit `Gemfile.lock` setelah build pertama agar versi gem konsisten dengan CI
  (jalankan `make lock` bila belum ada).

## Deploy

1. Buat repo di GitHub (`USERNAME.github.io` untuk situs utama), lalu push:

```bash
git init -b main
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/USERNAME/REPO.git
git push -u origin main
```

2. Di **Settings → Pages**, pilih **Source: GitHub Actions**.
3. Setiap push ke `main` akan membangun dan men-deploy situs otomatis.

## Menambah Fitur

- **Komentar**: isi `comments.provider` (giscus/utterances/disqus) di `_config.yml`.
- **Analytics**: bagian `analytics` di `_config.yml`.
- **Avatar**: taruh gambar di `assets/img/`, set `avatar:` di `_config.yml`.
- **Tab baru**: tambah file di `_tabs/` dengan `order` dan `icon`.
