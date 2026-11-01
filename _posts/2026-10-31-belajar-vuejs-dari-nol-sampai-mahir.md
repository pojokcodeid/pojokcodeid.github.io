---
layout: post
title: "Belajar Vue.js dari Nol sampai Mahir: Panduan Lengkap Bahasa Indonesia"
date: 2026-10-31 08:00:00 +0700
categories: [frontend, vuejs]
tags: [vue, vuejs, vue3, javascript, frontend, pinia, vue-router, vite, tutorial, indonesia]
description: "Panduan belajar Vue.js 3 lengkap dalam bahasa Indonesia: dari persiapan, dasar, routing, state management, API, testing, deployment, hingga kontribusi open source."
toc: true
image:
  path: /assets/posts/2026-10-31-vue-js.jpg
  alt: VUE JS 
---

{% raw %}

Selamat datang di panduan belajar **Vue.js dari nol sampai mahir**. Materi ini disusun berurutan: setiap bab membangun di atas bab sebelumnya, lengkap dengan **teori, penjelasan, dan contoh kode** yang bisa langsung kamu praktikkan.

> **Catatan versi:** Seluruh materi memakai **Vue 3** dengan **Composition API** dan `<script setup>`, yang merupakan gaya penulisan yang direkomendasikan tim Vue saat ini. Vue 2 sudah mencapai *end of life* sejak 31 Desember 2023, sehingga tidak dibahas. Karena ekosistem cepat berubah, selalu cocokkan versi library (Vue Router, Pinia, Vite, dll.) dengan dokumentasi resminya di [vuejs.org](https://vuejs.org).

**Cara memakai panduan ini**

1. Ikuti bab secara berurutan, jangan melompat jika kamu pemula.
2. **Ketik sendiri** kode contoh, jangan hanya copy-paste.
3. Di akhir setiap bab ada latihan singkat. Kerjakan sebelum lanjut.
4. Bab 11 adalah proyek besar yang menyatukan semuanya.

* TOC
{:toc}

---

## Bab 1. Persiapan & Prasyarat

Sebelum menyentuh Vue, pastikan fondasi berikut sudah cukup kuat. Melewatkan bagian ini adalah penyebab utama pemula merasa Vue "susah".

### 1.1 Prasyarat Pengetahuan

| Topik | Level minimal | Kenapa penting |
|---|---|---|
| **HTML** | Tag umum, form, semantic element | Template Vue adalah HTML yang diperluas |
| **CSS** | Selector, box model, flexbox, grid | Styling komponen |
| **JavaScript modern (ES6+)** | Lihat daftar di bawah | Vue ditulis dan dipakai dengan JS modern |
| **Terminal / CLI** | `cd`, `ls`, `mkdir`, menjalankan perintah | Semua tooling berjalan via terminal |
| **Git dasar** | `init`, `add`, `commit`, `push` | Menyimpan proyek dan portofolio |

### 1.2 JavaScript yang Wajib Dikuasai

Kamu **tidak perlu** ahli JavaScript, tetapi konsep berikut harus dipahami karena muncul di hampir setiap baris kode Vue.

**a. `let`, `const`, dan arrow function**

```js
const nama = 'Budi'            // tidak bisa di-assign ulang
let umur = 20                  // bisa diubah

const sapa = (nama) => `Halo, ${nama}!`   // arrow function + template literal
console.log(sapa(nama))
```

**b. Destructuring dan spread**

```js
const user = { id: 1, nama: 'Sari', kota: 'Bandung' }
const { nama, kota } = user              // destructuring objek

const angka = [1, 2, 3]
const [pertama, ...sisa] = angka         // destructuring array + rest

const userBaru = { ...user, kota: 'Jakarta' }   // spread: salin & ubah
const semua = [...angka, 4, 5]
```

**c. Method array: `map`, `filter`, `find`, `reduce`**

Sangat sering dipakai untuk mengolah daftar data sebelum ditampilkan.

```js
const produk = [
  { id: 1, nama: 'Buku', harga: 50000 },
  { id: 2, nama: 'Pensil', harga: 5000 },
  { id: 3, nama: 'Tas', harga: 150000 },
]

const murah = produk.filter((p) => p.harga < 100000)
const namaSaja = produk.map((p) => p.nama)
const tas = produk.find((p) => p.nama === 'Tas')
const total = produk.reduce((jumlah, p) => jumlah + p.harga, 0)
```

**d. Modul ES (`import` / `export`)**

```js
// utils/format.js
export function rupiah(angka) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0,
  }).format(angka)
}

export default function ucapkan() {
  return 'Halo'
}

// file lain
import ucapkan, { rupiah } from './utils/format.js'
```

**e. Asynchronous: Promise dan `async/await`**

```js
async function ambilUser() {
  try {
    const res = await fetch('https://jsonplaceholder.typicode.com/users/1')
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    const data = await res.json()
    console.log(data.name)
  } catch (err) {
    console.error('Gagal:', err.message)
  }
}
```

**f. DOM dasar & event.** Pahami `document.querySelector`, `addEventListener`, dan event bubbling. Dengan memahami cara "lama" memanipulasi DOM, kamu akan menghargai apa yang Vue lakukan untukmu.

### 1.3 Menyiapkan Lingkungan Pengembangan

**1) Node.js**

Vue tidak membutuhkan Node.js untuk *berjalan di browser*, tetapi tooling modern (Vite, npm, test runner) membutuhkannya. Pasang versi **LTS terbaru** dari [nodejs.org](https://nodejs.org). Untuk mengelola banyak versi Node, gunakan `nvm` (macOS/Linux), `nvm-windows`, atau `fnm`.

```bash
node -v     # cek versi Node
npm -v      # cek versi npm
```

> Template resmi `create-vue` mensyaratkan versi Node minimum tertentu yang bisa berubah antar rilis. Jika muncul pesan error versi, upgrade Node ke LTS terbaru.

**2) Code editor: Visual Studio Code**

Ekstensi yang disarankan:

- **Vue (Official)**: dukungan syntax, TypeScript, dan IntelliSense untuk file `.vue` (sebelumnya bernama *Volar*)
- **ESLint** dan **Prettier**: konsistensi kode
- **Vue DevTools** (ekstensi browser): inspeksi komponen, state, dan routing

**3) Browser:** Chrome / Firefox / Edge terbaru, dengan Vue DevTools terpasang.

**4) Git:** pasang dari [git-scm.com](https://git-scm.com), lalu atur identitas:

```bash
git config --global user.name "Nama Kamu"
git config --global user.email "email@contoh.com"
```

### 1.4 Latihan Bab 1

1. Tulis fungsi yang menerima array produk dan mengembalikan **nama produk dengan harga di atas 10.000**, dalam huruf besar.
2. Buat modul `format.js` yang mengekspor fungsi `rupiah`, lalu impor di file lain.
3. Pastikan `node -v` dan `git --version` berjalan di terminalmu.

---

## Bab 2. Pengenalan Vue.js & Kenapa Harus Vue

### 2.1 Apa itu Vue.js?

**Vue.js** (dibaca "view") adalah *framework JavaScript progresif* untuk membangun antarmuka pengguna (UI). Dibuat oleh **Evan You** pada 2014 dan kini dikembangkan oleh komunitas open source.

Tiga ide utama Vue:

1. **Deklaratif**: kamu menjelaskan *seperti apa tampilan untuk suatu state*, bukan *langkah-langkah mengubah DOM*.
2. **Reaktif**: ketika data berubah, tampilan ikut diperbarui otomatis.
3. **Berbasis komponen**: UI dipecah menjadi potongan kecil yang bisa dipakai ulang.

**Contoh perbandingan.** Menampilkan counter dengan JavaScript biasa:

```html
<button id="btn">Klik</button>
<p id="teks">Jumlah: 0</p>

<script>
  let jumlah = 0
  const btn = document.querySelector('#btn')
  const teks = document.querySelector('#teks')

  btn.addEventListener('click', () => {
    jumlah++
    teks.textContent = `Jumlah: ${jumlah}`   // update DOM manual
  })
</script>
```

Versi Vue:

```vue
<script setup>
import { ref } from 'vue'
const jumlah = ref(0)
</script>

<template>
  <button @click="jumlah++">Klik</button>
  <p>Jumlah: {{ jumlah }}</p>
</template>
```

Di versi Vue, kita tidak pernah menyentuh DOM. Cukup ubah `jumlah`, dan Vue mengurus sisanya.

### 2.2 Konsep "Progresif"

Vue bisa diadopsi bertahap:

- **Tanpa build tool:** cukup tambahkan satu tag `<script>` dari CDN untuk "menyuntik" interaktivitas ke halaman HTML biasa.
- **Aplikasi SPA penuh:** dengan Vite, Vue Router, dan Pinia.
- **Full-stack / SSR / SSG:** dengan Nuxt.

Contoh Vue via CDN (tanpa instalasi apa pun, cocok untuk eksperimen cepat):

```html
<!DOCTYPE html>
<html lang="id">
<body>
  <div id="app">
    <input v-model="nama" placeholder="Nama kamu" />
    <p>Halo, {{ nama || 'Tamu' }}!</p>
  </div>

  <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
  <script>
    const { createApp, ref } = Vue
    createApp({
      setup() {
        const nama = ref('')
        return { nama }
      },
    }).mount('#app')
  </script>
</body>
</html>
```

### 2.3 Kenapa Harus Vue? (Kelebihan)

| Alasan | Penjelasan |
|---|---|
| **Kurva belajar landai** | Kalau sudah paham HTML, CSS, dan JS, kamu bisa produktif dalam hitungan hari |
| **Dokumentasi sangat baik** | Dokumentasi resmi terstruktur, jelas, dan tersedia banyak terjemahan |
| **Reaktivitas otomatis** | Tidak perlu `setState` manual atau memikirkan kapan harus render ulang |
| **Single-File Component (SFC)** | Template, logika, dan style dalam satu file `.vue` yang rapi |
| **Performa baik** | Compiler Vue mengoptimalkan template dan hanya memperbarui bagian yang berubah |
| **Ekosistem resmi terpadu** | Router, state management, tooling, dan devtools dirawat tim inti sehingga kompatibilitasnya terjaga |
| **Fleksibel** | Bisa dari widget kecil hingga aplikasi enterprise |
| **Komunitas besar & ramah** | Banyak library, template, dan tutorial |

### 2.4 Kekurangan & Hal yang Perlu Diperhatikan

- Lowongan kerja di sebagian pasar bisa lebih sedikit dibanding React. Cek pasar kerja di kotamu.
- Fleksibilitas membuat tim perlu **menyepakati konvensi** (struktur folder, gaya penulisan).
- Ekosistem library pihak ketiga lebih kecil dibanding React, meski untuk kebutuhan umum sudah sangat memadai.

### 2.5 Vue vs React vs Angular (Ringkas)

| Aspek | Vue | React | Angular |
|---|---|---|---|
| Jenis | Framework progresif | Library UI | Framework lengkap |
| Template | HTML-based (SFC) | JSX | HTML + decorator (TypeScript) |
| Reaktivitas | Otomatis (Proxy) | Eksplisit (`useState`, dll.) | Signals / RxJS |
| Kurva belajar | Landai | Sedang | Curam |
| Router / State | Resmi (Vue Router, Pinia) | Pihak ketiga (umumnya) | Bawaan |

Tidak ada yang "terbaik secara mutlak". Pilih sesuai kebutuhan proyek dan tim. Konsep yang kamu pelajari di Vue (komponen, props, state, routing) sangat bisa ditransfer ke framework lain.

### 2.6 Options API vs Composition API

Vue 3 mendukung dua gaya penulisan:

```vue
<!-- Options API -->
<script>
export default {
  data() {
    return { jumlah: 0 }
  },
  methods: {
    tambah() {
      this.jumlah++
    },
  },
}
</script>
```

```vue
<!-- Composition API dengan <script setup> (dipakai di panduan ini) -->
<script setup>
import { ref } from 'vue'

const jumlah = ref(0)
const tambah = () => jumlah.value++
</script>
```

Composition API unggul dalam **reuse logika** (lewat *composables*), dukungan TypeScript, dan pengorganisasian kode di komponen besar. Options API tetap valid dan masih banyak ditemui di kode lama, jadi sebaiknya kamu bisa **membacanya**.

### 2.7 Latihan Bab 2

1. Buat file `index.html` dengan Vue via CDN yang menampilkan input nama dan sapaan.
2. Ubah contoh counter menjadi tombol **tambah**, **kurang**, dan **reset**.

---

## Bab 3. Dasar-dasar Vue.js

### 3.1 Membuat Proyek dengan Vite (`create-vue`)

Cara resmi membuat proyek Vue 3:

```bash
npm create vue@latest
```

Kamu akan ditanya beberapa pilihan interaktif. Untuk belajar, pilihan awal yang disarankan:

| Pertanyaan | Saran saat belajar |
|---|---|
| Project name | `belajar-vue` |
| TypeScript | No (aktifkan nanti di Bab 7) |
| JSX Support | No |
| Vue Router | Boleh No dulu (dibahas di Bab 5) |
| Pinia | Boleh No dulu (Bab 5) |
| Vitest / E2E | No dulu (Bab 8) |
| ESLint / Prettier | Yes |

Lalu jalankan:

```bash
cd belajar-vue
npm install
npm run dev
```

Buka alamat yang tampil di terminal (biasanya `http://localhost:5173`). Perubahan kode akan langsung tampil berkat **Hot Module Replacement (HMR)**.

### 3.2 Struktur Proyek

```text
belajar-vue/
├── index.html          # titik masuk HTML
├── package.json        # dependensi & script
├── vite.config.js      # konfigurasi Vite
├── public/             # aset statis (disalin apa adanya)
└── src/
    ├── main.js         # titik masuk aplikasi
    ├── App.vue         # komponen root
    ├── assets/         # gambar, css (diproses bundler)
    └── components/     # komponen reusable
```

`src/main.js`:

```js
import { createApp } from 'vue'
import App from './App.vue'
import './assets/main.css'

createApp(App).mount('#app')
```

Penjelasan: `createApp(App)` membuat *instance aplikasi* dengan `App.vue` sebagai komponen root, lalu `.mount('#app')` menempelkannya ke elemen `<div id="app">` di `index.html`.

### 3.3 Anatomi Single-File Component (SFC)

File `.vue` terdiri dari tiga blok:

```vue
<script setup>
// 1. LOGIKA: state, fungsi, import
import { ref } from 'vue'
const pesan = ref('Halo Vue!')
</script>

<template>
  <!-- 2. TAMPILAN: HTML + sintaks Vue -->
  <h1 class="judul">{{ pesan }}</h1>
</template>

<style scoped>
/* 3. STYLE: scoped = hanya berlaku di komponen ini */
.judul {
  color: #42b883;
}
</style>
```

- Semua variabel dan fungsi yang dideklarasikan di `<script setup>` **otomatis tersedia di template**.
- `scoped` membuat Vue menambahkan atribut unik sehingga CSS tidak "bocor" ke komponen lain.

### 3.4 Template Syntax

**a. Interpolasi teks: `{{ }}`**

```vue
<script setup>
const nama = 'Rina'
const harga = 25000
</script>

<template>
  <p>Halo, {{ nama }}!</p>
  <p>Total: {{ harga * 2 }}</p>
  <p>{{ nama.toUpperCase() }}</p>
  <p>{{ harga > 20000 ? 'Mahal' : 'Murah' }}</p>
</template>
```

Di dalam `{{ }}` kamu bisa menulis **satu ekspresi JavaScript** (bukan statement seperti `if` atau `for`).

**b. Mengikat atribut: `v-bind` (singkatan `:`)**

```vue
<script setup>
import { ref } from 'vue'
const url = ref('https://vuejs.org')
const aktif = ref(true)
const ukuran = ref(24)
</script>

<template>
  <a :href="url">Situs Vue</a>
  <button :disabled="!aktif">Kirim</button>

  <!-- class dinamis -->
  <p :class="{ aktif: aktif, 'teks-besar': ukuran > 20 }">Contoh</p>
  <p :class="[aktif ? 'a' : 'b', 'selalu']">Array class</p>

  <!-- style dinamis -->
  <p :style="{ fontSize: ukuran + 'px', color: 'tomato' }">Contoh style</p>
</template>
```

**c. Event handling: `v-on` (singkatan `@`)**

```vue
<script setup>
import { ref } from 'vue'
const jumlah = ref(0)

function tambah(n) {
  jumlah.value += n
}

function kirim(event) {
  console.log('Form dikirim', event)
}
</script>

<template>
  <button @click="tambah(1)">+1</button>
  <button @click="tambah(5)">+5</button>

  <!-- modifier: .prevent = event.preventDefault() -->
  <form @submit.prevent="kirim">
    <button type="submit">Kirim</button>
  </form>

  <!-- modifier tombol keyboard -->
  <input @keyup.enter="tambah(1)" placeholder="Tekan Enter" />
</template>
```

Modifier yang sering dipakai: `.prevent`, `.stop`, `.once`, `.self`, `.enter`, `.esc`, `.ctrl`, `.left`/`.right`.

**d. Rendering kondisional: `v-if`, `v-else-if`, `v-else`, `v-show`**

```vue
<script setup>
import { ref } from 'vue'
const nilai = ref(75)
const tampil = ref(true)
</script>

<template>
  <p v-if="nilai >= 80">Nilai A</p>
  <p v-else-if="nilai >= 70">Nilai B</p>
  <p v-else>Nilai C</p>

  <p v-show="tampil">Saya disembunyikan dengan CSS display</p>
</template>
```

| | `v-if` | `v-show` |
|---|---|---|
| Cara kerja | Elemen dibuat/dihapus dari DOM | Hanya toggle `display: none` |
| Biaya | Lebih mahal saat sering toggle | Lebih murah saat sering toggle |
| Cocok untuk | Kondisi jarang berubah | Sering di-toggle |

**e. Rendering daftar: `v-for`**

```vue
<script setup>
import { ref } from 'vue'

const buah = ref([
  { id: 1, nama: 'Apel' },
  { id: 2, nama: 'Jeruk' },
  { id: 3, nama: 'Mangga' },
])
</script>

<template>
  <ul>
    <li v-for="(item, index) in buah" :key="item.id">
      {{ index + 1 }}. {{ item.nama }}
    </li>
  </ul>

  <!-- iterasi objek & angka -->
  <span v-for="n in 5" :key="n">{{ n }} </span>
</template>
```

> **Wajib pakai `:key`** yang unik dan stabil (misalnya `id`), jangan memakai `index` jika urutan daftar bisa berubah. `key` membantu Vue melacak elemen mana yang berubah.

Jangan gabungkan `v-if` dan `v-for` pada elemen yang sama. Bungkus dengan `<template v-for>` atau filter datanya dulu menggunakan `computed`.

**f. Two-way binding: `v-model`**

```vue
<script setup>
import { ref } from 'vue'

const nama = ref('')
const setuju = ref(false)
const hobi = ref([])
const kota = ref('bandung')
const pesan = ref('')
</script>

<template>
  <input v-model="nama" placeholder="Nama" />

  <label><input type="checkbox" v-model="setuju" /> Setuju</label>

  <label><input type="checkbox" value="baca" v-model="hobi" /> Baca</label>
  <label><input type="checkbox" value="game" v-model="hobi" /> Game</label>

  <select v-model="kota">
    <option value="jakarta">Jakarta</option>
    <option value="bandung">Bandung</option>
  </select>

  <textarea v-model="pesan"></textarea>

  <pre>{{ { nama, setuju, hobi, kota, pesan } }}</pre>
</template>
```

Modifier `v-model`: `.trim` (hapus spasi tepi), `.number` (ubah ke angka), `.lazy` (sinkron saat `change`, bukan `input`).

Ringkasan direktif:

| Direktif | Singkatan | Fungsi |
|---|---|---|
| `v-bind:attr` | `:attr` | Ikat atribut ke ekspresi |
| `v-on:event` | `@event` | Dengarkan event |
| `v-if` / `v-else` | | Render kondisional |
| `v-show` | | Toggle visibilitas |
| `v-for` | | Render daftar |
| `v-model` | | Binding dua arah |
| `v-html` | | Render HTML mentah (**hati-hati XSS**) |
| `v-once` | | Render sekali saja |

### 3.5 Latihan Bab 3

Buat aplikasi **To-Do List sederhana** dalam satu komponen:

- Input teks + tombol tambah (`v-model`, `@click`)
- Daftar tugas (`v-for` dengan `key`)
- Tombol hapus per tugas
- Checkbox "selesai" yang mencoret teks (`:class`)
- Pesan "Belum ada tugas" saat kosong (`v-if`)

<details>
<summary>Contoh solusi</summary>

```vue
<script setup>
import { ref } from 'vue'

const teks = ref('')
const tugas = ref([])
let idBerikut = 1

function tambah() {
  const isi = teks.value.trim()
  if (!isi) return
  tugas.value.push({ id: idBerikut++, isi, selesai: false })
  teks.value = ''
}

function hapus(id) {
  tugas.value = tugas.value.filter((t) => t.id !== id)
}
</script>

<template>
  <h2>To-Do List</h2>
  <form @submit.prevent="tambah">
    <input v-model="teks" placeholder="Tugas baru..." />
    <button>Tambah</button>
  </form>

  <p v-if="tugas.length === 0">Belum ada tugas</p>
  <ul v-else>
    <li v-for="t in tugas" :key="t.id">
      <input type="checkbox" v-model="t.selesai" />
      <span :style="{ textDecoration: t.selesai ? 'line-through' : 'none' }">
        {{ t.isi }}
      </span>
      <button @click="hapus(t.id)">Hapus</button>
    </li>
  </ul>
</template>
```

</details>

---

## Bab 4. Konsep Inti Vue.js

### 4.1 Reaktivitas: `ref` dan `reactive`

**Teori.** Reaktivitas berarti Vue *melacak* data mana yang dipakai oleh tampilan, dan saat data itu berubah, Vue memperbarui hanya bagian tampilan terkait.

**`ref`**: membungkus nilai apa pun (primitif maupun objek) dalam objek dengan properti `.value`.

```vue
<script setup>
import { ref } from 'vue'

const jumlah = ref(0)
const user = ref({ nama: 'Andi', umur: 20 })

function naik() {
  jumlah.value++            // di script: pakai .value
  user.value.umur++
}
</script>

<template>
  <!-- di template: .value otomatis dibuka (unwrap) -->
  <p>{{ jumlah }} | {{ user.nama }} ({{ user.umur }})</p>
  <button @click="naik">Naik</button>
</template>
```

**`reactive`**: membuat objek menjadi reaktif langsung (tanpa `.value`), tetapi hanya untuk **objek/array/Map/Set**.

```js
import { reactive } from 'vue'

const form = reactive({ email: '', password: '' })
form.email = 'a@b.com'      // reaktif
```

| | `ref` | `reactive` |
|---|---|---|
| Tipe data | Apa saja | Hanya objek |
| Akses | `.value` (di script) | Langsung |
| Assign ulang seluruh nilai | Aman | **Tidak aman** (kehilangan reaktivitas) |
| Destructuring | Aman bila ref | Kehilangan reaktivitas |

> **Rekomendasi praktis:** pakai `ref` sebagai pilihan utama. Ia konsisten dan menghindari jebakan `reactive`.

Jebakan umum:

```js
const state = reactive({ jumlah: 0 })
let { jumlah } = state      // SALAH: jumlah kini angka biasa, tidak reaktif

import { toRefs } from 'vue'
const { jumlah: j } = toRefs(state)   // BENAR: j adalah ref
```

### 4.2 Computed Property

**Teori.** `computed` adalah nilai turunan dari state lain. Hasilnya **di-cache** dan hanya dihitung ulang bila dependensinya berubah.

```vue
<script setup>
import { ref, computed } from 'vue'

const keranjang = ref([
  { nama: 'Buku', harga: 50000, qty: 2 },
  { nama: 'Pena', harga: 5000, qty: 10 },
])
const kataKunci = ref('')

const total = computed(() =>
  keranjang.value.reduce((sum, i) => sum + i.harga * i.qty, 0)
)

const hasilFilter = computed(() =>
  keranjang.value.filter((i) =>
    i.nama.toLowerCase().includes(kataKunci.value.toLowerCase())
  )
)
</script>

<template>
  <input v-model="kataKunci" placeholder="Cari..." />
  <p>Total: Rp {{ total.toLocaleString('id-ID') }}</p>
  <li v-for="i in hasilFilter" :key="i.nama">{{ i.nama }} x{{ i.qty }}</li>
</template>
```

**Computed vs method:** method dijalankan setiap render, computed hanya saat dependensi berubah. Untuk nilai turunan, pilih `computed`.

Computed yang bisa **ditulis** (getter + setter):

```js
const namaDepan = ref('Budi')
const namaBelakang = ref('Santoso')

const namaLengkap = computed({
  get: () => `${namaDepan.value} ${namaBelakang.value}`,
  set(nilai) {
    [namaDepan.value, namaBelakang.value] = nilai.split(' ')
  },
})
```

> Getter `computed` sebaiknya **bebas efek samping** (jangan mengubah state atau memanggil API di dalamnya).

### 4.3 Watcher

**Teori.** Gunakan `watch` ketika perubahan data harus memicu **efek samping**: memanggil API, menyimpan ke `localStorage`, dll.

```vue
<script setup>
import { ref, watch, watchEffect } from 'vue'

const pertanyaan = ref('')
const jawaban = ref('Ketik pertanyaan...')

// watch: sumber eksplisit, ada nilai baru & lama
watch(pertanyaan, async (baru, lama) => {
  if (!baru.includes('?')) return
  jawaban.value = 'Berpikir...'
  try {
    const res = await fetch('https://yesno.wtf/api')
    jawaban.value = (await res.json()).answer
  } catch {
    jawaban.value = 'Gagal memuat'
  }
})

// watchEffect: otomatis melacak semua ref yang dipakai & langsung jalan
watchEffect(() => {
  localStorage.setItem('pertanyaan', pertanyaan.value)
})
</script>

<template>
  <input v-model="pertanyaan" />
  <p>{{ jawaban }}</p>
</template>
```

Opsi penting:

```js
watch(sumber, callback, {
  immediate: true,   // jalankan sekali saat dibuat
  deep: true,        // amati perubahan nested pada objek
  once: true,        // jalankan sekali lalu berhenti
})

// mengamati properti objek reaktif: gunakan getter
watch(() => user.value.nama, (n) => console.log(n))
```

**Aturan praktis:** nilai turunan → `computed`; efek samping → `watch`.

### 4.4 Lifecycle Hooks

Setiap komponen melewati siklus: **dibuat → dipasang ke DOM → diperbarui → dilepas**. Hook memungkinkan kita menjalankan kode pada tahap tertentu.

| Hook | Kapan | Contoh pemakaian |
|---|---|---|
| `onBeforeMount` | Sebelum dipasang | Jarang dipakai |
| `onMounted` | Setelah DOM terpasang | Fetch data awal, akses elemen DOM, inisialisasi library |
| `onBeforeUpdate` / `onUpdated` | Sebelum/sesudah DOM diperbarui | Debug, sinkronisasi DOM |
| `onBeforeUnmount` | Sebelum dilepas | Persiapan pembersihan |
| `onUnmounted` | Setelah dilepas | Hapus event listener, timer |

```vue
<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const lebar = ref(window.innerWidth)
const update = () => (lebar.value = window.innerWidth)

onMounted(() => window.addEventListener('resize', update))
onUnmounted(() => window.removeEventListener('resize', update))   // bersihkan!
</script>

<template>
  <p>Lebar jendela: {{ lebar }}px</p>
</template>
```

> Selalu **bersihkan** listener, timer (`setInterval`), dan subscription di `onUnmounted` agar tidak terjadi *memory leak*.

### 4.5 Komponen, Props, dan Emits

**Teori.** Komponen adalah blok UI yang bisa dipakai ulang. Aliran data standar Vue:

> **Props ke bawah, events ke atas.** Induk mengirim data ke anak via *props*; anak memberi tahu induk via *emit*.

**Komponen anak `KartuProduk.vue`:**

```vue
<script setup>
const props = defineProps({
  nama: { type: String, required: true },
  harga: { type: Number, default: 0 },
  stok: { type: Number, default: 0 },
})

const emit = defineEmits(['beli'])

function beli() {
  emit('beli', props.nama)
}
</script>

<template>
  <div class="kartu">
    <h3>{{ nama }}</h3>
    <p>Rp {{ harga.toLocaleString('id-ID') }}</p>
    <button :disabled="stok === 0" @click="beli">
      {{ stok > 0 ? 'Beli' : 'Habis' }}
    </button>
  </div>
</template>

<style scoped>
.kartu { border: 1px solid #ddd; padding: 1rem; border-radius: 8px; }
</style>
```

**Induk `App.vue`:**

```vue
<script setup>
import { ref } from 'vue'
import KartuProduk from './components/KartuProduk.vue'

const produk = ref([
  { id: 1, nama: 'Keyboard', harga: 350000, stok: 5 },
  { id: 2, nama: 'Mouse', harga: 150000, stok: 0 },
])

function onBeli(nama) {
  alert(`Kamu membeli ${nama}`)
}
</script>

<template>
  <KartuProduk
    v-for="p in produk"
    :key="p.id"
    :nama="p.nama"
    :harga="p.harga"
    :stok="p.stok"
    @beli="onBeli"
  />
</template>
```

Aturan emas props:

1. Props bersifat **satu arah** (one-way). **Jangan mengubah props di anak.** Jika perlu, salin ke state lokal atau emit event ke induk.
2. Deklarasikan tipe dan nilai default agar aman dan terdokumentasi.
3. Nama props di script `camelCase`, di template boleh `kebab-case` (`:nama-produk`).

**`v-model` pada komponen** memakai `defineModel` (Vue 3.4+):

```vue
<!-- InputTeks.vue -->
<script setup>
const model = defineModel()
</script>

<template>
  <input v-model="model" />
</template>
```

```vue
<!-- Induk -->
<InputTeks v-model="nama" />
```

### 4.6 Slots

**Teori.** Slot memungkinkan induk "menyisipkan" konten ke dalam template anak, membuat komponen sangat fleksibel.

```vue
<!-- Kartu.vue -->
<template>
  <div class="kartu">
    <header><slot name="judul">Judul default</slot></header>
    <main><slot /></main>
    <footer><slot name="aksi" /></footer>
  </div>
</template>
```

```vue
<!-- Pemakaian -->
<Kartu>
  <template #judul>Profil Pengguna</template>

  <p>Ini isi utama (slot default).</p>

  <template #aksi>
    <button>Simpan</button>
  </template>
</Kartu>
```

**Scoped slot**: anak mengirim data ke slot yang dirender induk.

```vue
<!-- DaftarItem.vue -->
<script setup>
defineProps({ items: Array })
</script>

<template>
  <ul>
    <li v-for="item in items" :key="item.id">
      <slot :item="item">{{ item.nama }}</slot>
    </li>
  </ul>
</template>
```

```vue
<DaftarItem :items="buah">
  <template #default="{ item }">
    <strong>{{ item.nama }}</strong>
  </template>
</DaftarItem>
```

### 4.7 Provide / Inject

Untuk melewatkan data ke komponen keturunan **tanpa props drilling** (mengoper props lewat banyak level).

```vue
<!-- Leluhur -->
<script setup>
import { ref, provide } from 'vue'

const tema = ref('terang')
provide('tema', tema)
provide('ubahTema', () => {
  tema.value = tema.value === 'terang' ? 'gelap' : 'terang'
})
</script>
```

```vue
<!-- Keturunan (kedalaman berapa pun) -->
<script setup>
import { inject } from 'vue'

const tema = inject('tema')
const ubahTema = inject('ubahTema')
</script>

<template>
  <button @click="ubahTema">Tema: {{ tema }}</button>
</template>
```

### 4.8 Template Refs

Mengakses elemen DOM atau instance komponen secara langsung.

```vue
<script setup>
import { useTemplateRef, onMounted } from 'vue'

const inputEl = useTemplateRef('inputNama')   // Vue 3.5+

onMounted(() => inputEl.value.focus())
</script>

<template>
  <input ref="inputNama" />
</template>
```

> Pada Vue versi sebelum 3.5, gunakan `const inputNama = ref(null)` dengan nama variabel yang sama dengan atribut `ref`.

### 4.9 Composables: Reuse Logika

**Composable** adalah fungsi yang membungkus logika reaktif agar bisa dipakai ulang. Ini adalah **fitur terkuat Composition API**. Konvensi nama: awalan `use`.

```js
// src/composables/useCounter.js
import { ref, computed } from 'vue'

export function useCounter(awal = 0) {
  const jumlah = ref(awal)
  const ganda = computed(() => jumlah.value * 2)

  const tambah = () => jumlah.value++
  const kurang = () => jumlah.value--
  const reset = () => (jumlah.value = awal)

  return { jumlah, ganda, tambah, kurang, reset }
}
```

```vue
<script setup>
import { useCounter } from '@/composables/useCounter'

const { jumlah, ganda, tambah, reset } = useCounter(10)
</script>

<template>
  <p>{{ jumlah }} (ganda: {{ ganda }})</p>
  <button @click="tambah">+</button>
  <button @click="reset">Reset</button>
</template>
```

Contoh composable berguna dengan *cleanup*:

```js
// src/composables/useLocalStorage.js
import { ref, watch } from 'vue'

export function useLocalStorage(kunci, nilaiAwal) {
  const tersimpan = localStorage.getItem(kunci)
  const data = ref(tersimpan ? JSON.parse(tersimpan) : nilaiAwal)

  watch(data, (baru) => localStorage.setItem(kunci, JSON.stringify(baru)), {
    deep: true,
  })

  return data
}
```

### 4.10 Latihan Bab 4

1. Pecah To-Do List Bab 3 menjadi komponen `TodoForm`, `TodoList`, dan `TodoItem` (props + emit).
2. Tambahkan computed: jumlah tugas selesai / total.
3. Simpan daftar tugas dengan `useLocalStorage`.
4. Buat komponen `Modal` yang memakai slot `judul`, default, dan `aksi`.

---

## Bab 5. Routing & State Management

### 5.1 Vue Router

**Teori.** Pada *Single Page Application (SPA)*, halaman tidak dimuat ulang saat berpindah "halaman". **Vue Router** memetakan URL ke komponen sehingga aplikasi terasa seperti multi-halaman, tetapi tetap satu halaman HTML.

**Instalasi** (lewati bila sudah dipilih saat `create-vue`):

```bash
npm install vue-router@4
```

> Selalu cek dokumentasi [router.vuejs.org](https://router.vuejs.org) untuk versi terbaru, karena API inti tetap serupa tetapi ada fitur baru dari waktu ke waktu.

**Konfigurasi dasar `src/router/index.js`:**

```js
import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '@/views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', name: 'home', component: HomeView },
    {
      path: '/tentang',
      name: 'tentang',
      // lazy loading: file baru diunduh saat halaman dikunjungi
      component: () => import('@/views/TentangView.vue'),
    },
    { path: '/:pathMatch(.*)*', name: 'not-found', component: () => import('@/views/NotFoundView.vue') },
  ],
})

export default router
```

**Daftarkan di `main.js`:**

```js
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

createApp(App).use(router).mount('#app')
```

**`App.vue`:**

```vue
<template>
  <nav>
    <RouterLink to="/">Beranda</RouterLink> |
    <RouterLink :to="{ name: 'tentang' }">Tentang</RouterLink>
  </nav>

  <!-- tempat komponen halaman dirender -->
  <RouterView />
</template>
```

`RouterLink` otomatis menambahkan class `router-link-active` pada link yang sedang aktif, berguna untuk styling menu.

**Route dinamis & parameter**

```js
{ path: '/produk/:id', name: 'detail-produk', component: () => import('@/views/ProdukDetail.vue'), props: true }
```

```vue
<!-- ProdukDetail.vue -->
<script setup>
import { useRoute, useRouter } from 'vue-router'
import { watch } from 'vue'

const route = useRoute()      // info rute aktif (params, query)
const router = useRouter()    // untuk navigasi programatik

watch(
  () => route.params.id,
  (id) => console.log('Memuat produk', id),
  { immediate: true }
)

function kembali() {
  router.push({ name: 'home' })   // atau router.back()
}
</script>

<template>
  <h1>Produk #{{ route.params.id }}</h1>
  <p>Query: {{ route.query.warna }}</p>   <!-- /produk/5?warna=merah -->
  <button @click="kembali">Kembali</button>
</template>
```

> Saat berpindah dari `/produk/1` ke `/produk/2`, komponen **dipakai ulang** (tidak dibuat ulang), jadi `onMounted` tidak terpanggil lagi. Gunakan `watch` pada `route.params` untuk memuat data baru.

**Nested routes (rute bersarang)**

```js
{
  path: '/dashboard',
  component: () => import('@/layouts/DashboardLayout.vue'),   // berisi <RouterView />
  children: [
    { path: '', name: 'dashboard', component: () => import('@/views/dashboard/Ringkasan.vue') },
    { path: 'profil', name: 'profil', component: () => import('@/views/dashboard/Profil.vue') },
    { path: 'pengaturan', name: 'pengaturan', component: () => import('@/views/dashboard/Pengaturan.vue') },
  ],
}
```

**Navigation guards (proteksi halaman)**

```js
// Menandai rute yang butuh login lewat meta
{ path: '/dashboard', component: DashboardLayout, meta: { requiresAuth: true } }

// Guard global
router.beforeEach((to) => {
  const token = localStorage.getItem('token')

  if (to.meta.requiresAuth && !token) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  // return undefined / true = lanjutkan navigasi
})
```

> Guard di sisi klien hanya mengatur **pengalaman pengguna**. Keamanan sebenarnya **harus** ditegakkan di server/API.

**Mode history:** `createWebHistory` menghasilkan URL bersih (`/tentang`) tetapi server perlu dikonfigurasi agar semua path mengarah ke `index.html` (lihat Bab 9). `createWebHashHistory` memakai `/#/tentang` dan tidak butuh konfigurasi server.

### 5.2 State Management: Kenapa Dibutuhkan?

State yang hanya dipakai satu komponen cukup disimpan secara lokal (`ref`). Namun saat **banyak komponen yang berjauhan** perlu berbagi data (user login, keranjang belanja, tema), mengoper lewat props menjadi merepotkan. Solusinya adalah **store global**.

**Pinia** adalah library state management **resmi** Vue (pengganti Vuex). Ringan, intuitif, dan mendukung TypeScript dengan baik.

```bash
npm install pinia
```

```js
// main.js
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

createApp(App).use(createPinia()).mount('#app')
```

### 5.3 Membuat Store dengan Pinia

Pinia menyediakan dua gaya. Gaya **Setup Store** mirip Composition API dan dipakai di sini:

```js
// src/stores/keranjang.js
import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export const useKeranjangStore = defineStore('keranjang', () => {
  // state  -> ref()
  const items = ref([])

  // getters -> computed()
  const totalItem = computed(() => items.value.reduce((n, i) => n + i.qty, 0))
  const totalHarga = computed(() =>
    items.value.reduce((n, i) => n + i.harga * i.qty, 0)
  )

  // actions -> function()
  function tambah(produk) {
    const ada = items.value.find((i) => i.id === produk.id)
    if (ada) ada.qty++
    else items.value.push({ ...produk, qty: 1 })
  }

  function hapus(id) {
    items.value = items.value.filter((i) => i.id !== id)
  }

  function kosongkan() {
    items.value = []
  }

  return { items, totalItem, totalHarga, tambah, hapus, kosongkan }
})
```

Padanan konsep:

| Konsep Pinia | Padanan Composition API |
|---|---|
| state | `ref()` / `reactive()` |
| getters | `computed()` |
| actions | fungsi biasa (boleh `async`) |

**Memakai store di komponen:**

```vue
<script setup>
import { storeToRefs } from 'pinia'
import { useKeranjangStore } from '@/stores/keranjang'

const keranjang = useKeranjangStore()

// destructure state/getter reaktif: WAJIB lewat storeToRefs
const { items, totalHarga } = storeToRefs(keranjang)

// actions boleh di-destructure langsung
const { tambah, hapus } = keranjang
</script>

<template>
  <p>Total: Rp {{ totalHarga.toLocaleString('id-ID') }}</p>
  <ul>
    <li v-for="i in items" :key="i.id">
      {{ i.nama }} x{{ i.qty }}
      <button @click="hapus(i.id)">Hapus</button>
    </li>
  </ul>
  <button @click="tambah({ id: 1, nama: 'Buku', harga: 50000 })">Tambah Buku</button>
</template>
```

**Store dengan aksi asinkron & autentikasi:**

```js
// src/stores/auth.js
import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(localStorage.getItem('token'))
  const loading = ref(false)
  const error = ref(null)

  const isLoggedIn = computed(() => !!token.value)

  async function login(email, password) {
    loading.value = true
    error.value = null
    try {
      const res = await fetch('/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })
      if (!res.ok) throw new Error('Email atau password salah')
      const data = await res.json()
      token.value = data.token
      user.value = data.user
      localStorage.setItem('token', data.token)
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  function logout() {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
  }

  return { user, token, loading, error, isLoggedIn, login, logout }
})
```

Gunakan store ini di navigation guard:

```js
import { useAuthStore } from '@/stores/auth'

router.beforeEach((to) => {
  const auth = useAuthStore()          // aman dipakai di dalam guard
  if (to.meta.requiresAuth && !auth.isLoggedIn) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
})
```

**Persist state** (tersimpan setelah refresh): gunakan plugin seperti `pinia-plugin-persistedstate`, atau simpan manual dengan `watch` seperti contoh `useLocalStorage`.

### 5.4 Kapan Pakai State Lokal vs Global?

| Situasi | Pilihan |
|---|---|
| Nilai input form, toggle dropdown | `ref` lokal |
| Data dipakai induk-anak langsung | Props + emit |
| Data dipakai keturunan dalam satu cabang | Provide/inject |
| Data dipakai banyak halaman (auth, keranjang, tema) | **Pinia** |
| Data dari server (cache, refetch) | Library data-fetching (lihat Bab 6) |

### 5.5 Latihan Bab 5

1. Buat aplikasi dengan 3 halaman: Beranda, Daftar Produk, Detail Produk (`/produk/:id`).
2. Buat store `keranjang`, tombol "Tambah ke keranjang" di detail produk, dan badge jumlah item di navbar.
3. Buat halaman `/checkout` yang hanya bisa dibuka bila keranjang tidak kosong (navigation guard).

---

## Bab 6. API & Komunikasi Data

### 6.1 Konsep Dasar

Aplikasi frontend berkomunikasi dengan backend lewat **HTTP API** (umumnya REST dengan format JSON).

| Method | Fungsi | Contoh |
|---|---|---|
| `GET` | Ambil data | `GET /posts` |
| `POST` | Buat data | `POST /posts` |
| `PUT` / `PATCH` | Ubah data (penuh / sebagian) | `PUT /posts/1` |
| `DELETE` | Hapus data | `DELETE /posts/1` |

Kode status penting: `200` OK, `201` Created, `400` Bad Request, `401` Unauthorized, `403` Forbidden, `404` Not Found, `500` Server Error.

Setiap permintaan data memiliki **tiga state** yang harus ditangani di UI: **loading**, **error**, dan **data**.

### 6.2 Fetch Data dengan `fetch`

```vue
<script setup>
import { ref, onMounted } from 'vue'

const posts = ref([])
const loading = ref(false)
const error = ref(null)

async function muatPosts() {
  loading.value = true
  error.value = null
  try {
    const res = await fetch('https://jsonplaceholder.typicode.com/posts?_limit=10')
    if (!res.ok) throw new Error(`Gagal memuat (HTTP ${res.status})`)
    posts.value = await res.json()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

onMounted(muatPosts)
</script>

<template>
  <p v-if="loading">Memuat...</p>
  <div v-else-if="error">
    <p>{{ error }}</p>
    <button @click="muatPosts">Coba lagi</button>
  </div>
  <ul v-else>
    <li v-for="p in posts" :key="p.id">{{ p.title }}</li>
  </ul>
</template>
```

> `fetch` **tidak melempar error** untuk status 4xx/5xx. Itulah kenapa kita cek `res.ok` secara manual.

### 6.3 Composable `useFetch` Reusable

```js
// src/composables/useFetch.js
import { ref, watchEffect, toValue } from 'vue'

export function useFetch(url) {
  const data = ref(null)
  const error = ref(null)
  const loading = ref(false)

  async function muat() {
    data.value = null
    error.value = null
    loading.value = true
    try {
      const res = await fetch(toValue(url))     // url boleh string, ref, atau getter
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      data.value = await res.json()
    } catch (e) {
      error.value = e
    } finally {
      loading.value = false
    }
  }

  watchEffect(muat)    // otomatis fetch ulang saat url (reaktif) berubah
  return { data, error, loading, muat }
}
```

Pemakaian:

```vue
<script setup>
import { ref } from 'vue'
import { useFetch } from '@/composables/useFetch'

const halaman = ref(1)
const { data, loading, error } = useFetch(
  () => `https://jsonplaceholder.typicode.com/posts?_page=${halaman.value}&_limit=5`
)
</script>
```

### 6.4 Axios dan Instance Terpusat

Axios adalah library HTTP populer dengan fitur *interceptor*, transformasi otomatis JSON, dan penanganan error status yang lebih nyaman.

```bash
npm install axios
```

```js
// src/services/api.js
import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,   // dari file .env
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' },
})

// Interceptor request: sisipkan token di setiap permintaan
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Interceptor response: tangani error global
api.interceptors.response.use(
  (res) => res,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default api
```

Variabel lingkungan Vite harus diawali `VITE_` agar dapat diakses di kode klien:

```bash
# .env
VITE_API_URL=https://jsonplaceholder.typicode.com
```

> **Jangan pernah menaruh rahasia** (API secret, password database) di `.env` frontend. Semua yang ada di bundle klien bisa dibaca siapa pun.

**Layer service**: pisahkan pemanggilan API dari komponen.

```js
// src/services/postService.js
import api from './api'

export const postService = {
  daftar: (params) => api.get('/posts', { params }).then((r) => r.data),
  detail: (id) => api.get(`/posts/${id}`).then((r) => r.data),
  buat: (payload) => api.post('/posts', payload).then((r) => r.data),
  ubah: (id, payload) => api.put(`/posts/${id}`, payload).then((r) => r.data),
  hapus: (id) => api.delete(`/posts/${id}`),
}
```

### 6.5 CRUD Lengkap dengan Pinia

```js
// src/stores/post.js
import { ref } from 'vue'
import { defineStore } from 'pinia'
import { postService } from '@/services/postService'

export const usePostStore = defineStore('post', () => {
  const posts = ref([])
  const loading = ref(false)
  const error = ref(null)

  async function muat() {
    loading.value = true
    error.value = null
    try {
      posts.value = await postService.daftar({ _limit: 10 })
    } catch (e) {
      error.value = e.response?.data?.message ?? e.message
    } finally {
      loading.value = false
    }
  }

  async function tambah(payload) {
    const baru = await postService.buat(payload)
    posts.value.unshift(baru)
  }

  async function hapus(id) {
    const cadangan = [...posts.value]
    posts.value = posts.value.filter((p) => p.id !== id)    // optimistic update
    try {
      await postService.hapus(id)
    } catch (e) {
      posts.value = cadangan                                // rollback jika gagal
      throw e
    }
  }

  return { posts, loading, error, muat, tambah, hapus }
})
```

### 6.6 Server State dengan TanStack Query (Vue Query)

Data dari server berbeda dari state UI: ia butuh **cache, refetch otomatis, deduplikasi request, retry, dan sinkronisasi**. Daripada menulis semuanya manual, gunakan **TanStack Query**.

```bash
npm install @tanstack/vue-query
```

```js
// main.js
import { VueQueryPlugin } from '@tanstack/vue-query'
app.use(VueQueryPlugin)
```

```vue
<script setup>
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { postService } from '@/services/postService'

const queryClient = useQueryClient()

const { data: posts, isPending, isError, error } = useQuery({
  queryKey: ['posts'],
  queryFn: () => postService.daftar({ _limit: 10 }),
})

const hapus = useMutation({
  mutationFn: (id) => postService.hapus(id),
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['posts'] }),
})
</script>

<template>
  <p v-if="isPending">Memuat...</p>
  <p v-else-if="isError">Error: {{ error.message }}</p>
  <ul v-else>
    <li v-for="p in posts" :key="p.id">
      {{ p.title }}
      <button @click="hapus.mutate(p.id)">Hapus</button>
    </li>
  </ul>
</template>
```

Panduan memilih: **Pinia** untuk state klien (UI, auth, preferensi); **TanStack Query** untuk state server (daftar data dari API).

### 6.7 CORS dan Proxy Saat Pengembangan

Jika browser memblokir permintaan karena **CORS**, itu masalah konfigurasi **server API** (header `Access-Control-Allow-Origin`). Selama pengembangan kamu bisa memakai proxy dari Vite:

```js
// vite.config.js
export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
    },
  },
})
```

### 6.8 Upload File & Form Validasi Singkat

```vue
<script setup>
import { ref } from 'vue'
import api from '@/services/api'

const file = ref(null)

function pilih(e) {
  file.value = e.target.files[0]
}

async function unggah() {
  const form = new FormData()
  form.append('berkas', file.value)
  await api.post('/upload', form)       // Content-Type diatur otomatis
}
</script>

<template>
  <input type="file" @change="pilih" accept="image/*" />
  <button :disabled="!file" @click="unggah">Unggah</button>
</template>
```

Untuk form kompleks, pertimbangkan **VeeValidate** atau **FormKit** dengan skema validasi seperti **Zod** / **Yup**.

### 6.9 Latihan Bab 6

1. Tampilkan daftar post dari JSONPlaceholder dengan state loading/error/empty.
2. Tambahkan pencarian dengan **debounce** (tunda request 300 ms setelah user berhenti mengetik).
3. Implementasikan CRUD: tambah, ubah, hapus, dengan *optimistic update*.
4. Ulangi fitur daftar dengan TanStack Query dan bandingkan jumlah kode.

---

## Bab 7. Vue Lanjutan

### 7.1 TypeScript di Vue

TypeScript menambahkan **tipe statis** sehingga bug terdeteksi sebelum aplikasi dijalankan, dan editor memberi autocompletion yang akurat. Saat `npm create vue@latest`, pilih **TypeScript: Yes**.

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

interface Produk {
  id: number
  nama: string
  harga: number
  stok?: number
}

// props bertipe (type-based declaration)
const props = defineProps<{
  produk: Produk
  tampilkanHarga?: boolean
}>()

// default untuk props opsional
// (Vue 3.5+ mendukung destructure reaktif dengan nilai default)
const { tampilkanHarga = true } = defineProps<{ tampilkanHarga?: boolean }>()

// emits bertipe
const emit = defineEmits<{
  (e: 'beli', id: number): void
}>()

const daftar = ref<Produk[]>([])
const total = computed<number>(() => daftar.value.reduce((n, p) => n + p.harga, 0))
</script>
```

Tips: gunakan `vue-tsc` untuk type-check di CI.

```bash
npx vue-tsc --noEmit
```

### 7.2 Composables Tingkat Lanjut

Composable yang baik: menerima input fleksibel (nilai, ref, atau getter via `toValue`), mengembalikan ref, dan membersihkan efek sampingnya.

```js
// useDebounce.js
import { ref, watch, toValue, onScopeDispose } from 'vue'

export function useDebounce(sumber, jeda = 300) {
  const nilai = ref(toValue(sumber))
  let timer

  watch(
    () => toValue(sumber),
    (baru) => {
      clearTimeout(timer)
      timer = setTimeout(() => (nilai.value = baru), jeda)
    }
  )

  onScopeDispose(() => clearTimeout(timer))   // cleanup saat komponen dilepas
  return nilai
}
```

```vue
<script setup>
import { ref, watch } from 'vue'
import { useDebounce } from '@/composables/useDebounce'

const kataKunci = ref('')
const kataKunciTunda = useDebounce(kataKunci, 400)

watch(kataKunciTunda, (q) => console.log('Cari:', q))
</script>
```

Sebelum menulis composable sendiri, cek **VueUse** (Bab 10) karena banyak kebutuhan umum sudah tersedia.

### 7.3 Custom Directive

Directive kustom berguna untuk manipulasi DOM tingkat rendah yang dipakai berulang.

```js
// src/directives/clickOutside.js
export const vClickOutside = {
  mounted(el, binding) {
    el._handler = (e) => {
      if (!el.contains(e.target)) binding.value(e)
    }
    document.addEventListener('click', el._handler)
  },
  unmounted(el) {
    document.removeEventListener('click', el._handler)
  },
}
```

```vue
<script setup>
import { ref } from 'vue'
import { vClickOutside } from '@/directives/clickOutside'

const buka = ref(false)
</script>

<template>
  <div v-if="buka" v-click-outside="() => (buka = false)" class="dropdown">
    Menu...
  </div>
  <button @click.stop="buka = !buka">Toggle</button>
</template>
```

Di `<script setup>`, variabel berawalan `v` (camelCase) otomatis dikenali sebagai directive: `vClickOutside` → `v-click-outside`.

### 7.4 Plugin

Plugin menambahkan fungsionalitas level aplikasi (komponen global, provide, directive).

```js
// src/plugins/toast.js
import { reactive } from 'vue'

export const toasts = reactive([])

export default {
  install(app, opsi = {}) {
    const durasi = opsi.durasi ?? 3000

    app.provide('toast', (pesan) => {
      const item = { id: Date.now(), pesan }
      toasts.push(item)
      setTimeout(() => {
        const i = toasts.findIndex((t) => t.id === item.id)
        if (i !== -1) toasts.splice(i, 1)
      }, durasi)
    })
  },
}
```

```js
// main.js
import toast from './plugins/toast'
app.use(toast, { durasi: 4000 })
```

```js
// di komponen
const toast = inject('toast')
toast('Tersimpan!')
```

### 7.5 Teleport

`<Teleport>` merender sebagian template ke **lokasi DOM lain** (misalnya `body`), ideal untuk modal, tooltip, dan notifikasi supaya terbebas dari `overflow`/`z-index` induk.

```vue
<template>
  <button @click="buka = true">Buka Modal</button>

  <Teleport to="body">
    <div v-if="buka" class="overlay" @click.self="buka = false">
      <div class="modal">
        <slot />
        <button @click="buka = false">Tutup</button>
      </div>
    </div>
  </Teleport>
</template>
```

### 7.6 Transition & Animasi

```vue
<script setup>
import { ref } from 'vue'
const tampil = ref(true)
</script>

<template>
  <button @click="tampil = !tampil">Toggle</button>

  <Transition name="fade">
    <p v-if="tampil">Halo, aku muncul dan hilang dengan halus</p>
  </Transition>
</template>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.4s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
```

Untuk daftar (tambah/hapus/urut ulang item), gunakan `<TransitionGroup>`.

### 7.7 Async Component, Suspense, dan KeepAlive

**Async component**: komponen berat dimuat hanya saat dibutuhkan.

```js
import { defineAsyncComponent } from 'vue'

const GrafikBerat = defineAsyncComponent(() => import('./GrafikBerat.vue'))
```

**KeepAlive**: menyimpan state komponen saat dinonaktifkan (misalnya tab).

```vue
<KeepAlive include="FormPendaftaran">
  <component :is="tabAktif" />
</KeepAlive>
```

**Suspense** (fitur *experimental*, API-nya masih dapat berubah): menampilkan fallback sampai komponen dengan `await` di `<script setup>` selesai.

```vue
<Suspense>
  <template #default><DaftarProduk /></template>
  <template #fallback><p>Memuat...</p></template>
</Suspense>
```

### 7.8 Optimasi Performa Reaktivitas

| Teknik | Kapan dipakai |
|---|---|
| `shallowRef` / `shallowReactive` | Data besar yang tidak perlu dilacak mendalam (misal respons list ribuan item) |
| `computed` untuk turunan | Hindari kalkulasi berulang di template |
| `v-once` / `v-memo` | Bagian template statis atau jarang berubah |
| `markRaw` | Objek pihak ketiga (instance peta, chart) yang tidak boleh dijadikan reaktif |
| Virtual scrolling | Daftar sangat panjang (library: `vue-virtual-scroller`, `@tanstack/vue-virtual`) |
| Lazy loading | Komponen dan route berat |

```js
import { shallowRef, triggerRef } from 'vue'

const besar = shallowRef([])        // hanya .value yang reaktif
besar.value = dataBaru               // memicu update
besar.value.push(x); triggerRef(besar)   // untuk mutasi dalam, picu manual
```

> **Ukur sebelum mengoptimasi.** Gunakan tab *Performance* di Vue DevTools dan Chrome DevTools. Optimasi prematur sering memperumit kode tanpa manfaat nyata.

### 7.9 Render Function & JSX (Sekilas)

Untuk kasus dinamis yang sulit diungkapkan dengan template, Vue menyediakan fungsi `h()`:

```js
import { h } from 'vue'

export default {
  props: ['level'],
  setup(props, { slots }) {
    return () => h(`h${props.level}`, {}, slots.default?.())
  },
}
```

JSX juga didukung lewat plugin `@vitejs/plugin-vue-jsx`. Untuk 95% kasus, template tetap pilihan terbaik karena dioptimasi compiler.

### 7.10 Rendering Mode: SPA, SSR, SSG

| Mode | Cara kerja | Cocok untuk |
|---|---|---|
| **SPA** | Render di browser | Dashboard, aplikasi di balik login |
| **SSR** | Render HTML di server tiap request | Konten dinamis + SEO |
| **SSG** | HTML dibuat saat build | Blog, dokumentasi, landing page |

Untuk SSR/SSG gunakan **Nuxt** (Bab 10) dan jangan membangunnya dari nol kecuali kamu punya alasan kuat.

### 7.11 Latihan Bab 7

1. Ubah proyek To-Do ke TypeScript dan definisikan `interface Tugas`.
2. Buat directive `v-focus` dan `v-click-outside`.
3. Buat plugin `toast` plus komponen `ToastContainer` memakai `TransitionGroup` dan `Teleport`.
4. Buat composable `useDebounce` dan pakai pada fitur pencarian Bab 6.

---

## Bab 8. Testing

### 8.1 Kenapa & Apa yang Diuji?

Testing memberi keyakinan bahwa perubahan kode tidak merusak fitur lama. Pendekatan umum (*testing pyramid*):

| Jenis | Yang diuji | Alat | Kecepatan |
|---|---|---|---|
| **Unit** | Fungsi, composable, store | Vitest | Sangat cepat |
| **Component** | Satu komponen (render, props, event) | Vitest + Vue Test Utils | Cepat |
| **End-to-End (E2E)** | Alur pengguna sebenarnya di browser | Playwright / Cypress | Lambat |

Prinsip: **uji perilaku yang dilihat pengguna, bukan detail implementasi.**

### 8.2 Setup Vitest

Pilih **Vitest** saat `create-vue`, atau tambahkan manual:

```bash
npm install -D vitest @vue/test-utils jsdom
```

```js
// vite.config.js
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
  },
})
```

```json
// package.json
{ "scripts": { "test": "vitest", "test:run": "vitest run", "coverage": "vitest run --coverage" } }
```

### 8.3 Unit Test: Fungsi dan Composable

```js
// src/utils/format.test.js
import { describe, it, expect } from 'vitest'
import { rupiah } from './format'

describe('rupiah', () => {
  it('memformat angka ke Rupiah', () => {
    expect(rupiah(15000)).toContain('15.000')
  })

  it('menangani nol', () => {
    expect(rupiah(0)).toContain('0')
  })
})
```

```js
// src/composables/useCounter.test.js
import { describe, it, expect } from 'vitest'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('menambah dan mereset', () => {
    const { jumlah, tambah, reset } = useCounter(5)
    tambah()
    expect(jumlah.value).toBe(6)
    reset()
    expect(jumlah.value).toBe(5)
  })
})
```

### 8.4 Component Test dengan Vue Test Utils

```js
// src/components/KartuProduk.test.js
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import KartuProduk from './KartuProduk.vue'

describe('KartuProduk', () => {
  const props = { nama: 'Keyboard', harga: 350000, stok: 3 }

  it('menampilkan nama produk', () => {
    const wrapper = mount(KartuProduk, { props })
    expect(wrapper.text()).toContain('Keyboard')
  })

  it('emit event "beli" saat tombol diklik', async () => {
    const wrapper = mount(KartuProduk, { props })
    await wrapper.find('button').trigger('click')

    expect(wrapper.emitted('beli')).toBeTruthy()
    expect(wrapper.emitted('beli')[0]).toEqual(['Keyboard'])
  })

  it('menonaktifkan tombol saat stok habis', () => {
    const wrapper = mount(KartuProduk, { props: { ...props, stok: 0 } })
    expect(wrapper.find('button').attributes('disabled')).toBeDefined()
    expect(wrapper.text()).toContain('Habis')
  })
})
```

Pola penting: gunakan `await` pada `trigger`/`setValue`, karena Vue memperbarui DOM secara asinkron.

### 8.5 Menguji Pinia dan Router

```js
import { setActivePinia, createPinia } from 'pinia'
import { beforeEach, it, expect } from 'vitest'
import { useKeranjangStore } from '@/stores/keranjang'

beforeEach(() => setActivePinia(createPinia()))

it('menghitung total harga', () => {
  const store = useKeranjangStore()
  store.tambah({ id: 1, nama: 'Buku', harga: 50000 })
  store.tambah({ id: 1, nama: 'Buku', harga: 50000 })
  expect(store.totalHarga).toBe(100000)
})
```

Untuk komponen yang memakai router atau Pinia:

```js
import { createRouter, createMemoryHistory } from 'vue-router'
import { createPinia } from 'pinia'

const router = createRouter({
  history: createMemoryHistory(),
  routes: [{ path: '/', component: { template: '<div />' } }],
})

const wrapper = mount(Komponen, {
  global: { plugins: [router, createPinia()] },
})
```

### 8.6 Mock Panggilan API

```js
import { vi, it, expect } from 'vitest'
import { flushPromises, mount } from '@vue/test-utils'
import * as svc from '@/services/postService'
import DaftarPost from './DaftarPost.vue'

it('menampilkan daftar post', async () => {
  vi.spyOn(svc.postService, 'daftar').mockResolvedValue([
    { id: 1, title: 'Judul A' },
    { id: 2, title: 'Judul B' },
  ])

  const wrapper = mount(DaftarPost)
  await flushPromises()               // tunggu promise selesai

  expect(wrapper.findAll('li')).toHaveLength(2)
})
```

Alternatif yang lebih realistis: **MSW (Mock Service Worker)** untuk mencegat request di level jaringan.

### 8.7 E2E dengan Playwright

```bash
npm init playwright@latest
```

```js
// e2e/todo.spec.js
import { test, expect } from '@playwright/test'

test('menambah dan menyelesaikan tugas', async ({ page }) => {
  await page.goto('/')

  await page.getByPlaceholder('Tugas baru...').fill('Belajar Vue')
  await page.getByRole('button', { name: 'Tambah' }).click()

  await expect(page.getByText('Belajar Vue')).toBeVisible()

  await page.getByRole('checkbox').check()
  await expect(page.getByText('Belajar Vue')).toHaveCSS('text-decoration-line', 'line-through')
})
```

Cypress adalah alternatif populer dengan antarmuka interaktif.

### 8.8 Praktik Baik Testing

- Beri nama tes seperti kalimat: *"menampilkan pesan error saat login gagal"*.
- Pola **Arrange → Act → Assert**.
- Satu tes, satu perilaku.
- Hindari menguji internal (`wrapper.vm.xxx`); uji output DOM dan event.
- Jalankan tes di **CI** setiap push (lihat Bab 9).
- Jangan mengejar 100% coverage. Fokus pada logika bisnis dan alur kritis.

### 8.9 Latihan Bab 8

1. Tulis 3 unit test untuk store `keranjang` (tambah, hapus, total).
2. Tulis component test untuk `TodoItem` (render, emit hapus, toggle selesai).
3. Tulis 1 E2E test untuk alur login → lihat dashboard.

---

## Bab 9. Build, Optimasi & Deployment

### 9.1 Build untuk Produksi

```bash
npm run build      # hasil di folder dist/
npm run preview    # simulasi server produksi secara lokal
```

Saat build, Vite (dengan bundler di baliknya) melakukan: minifikasi, *tree-shaking* (membuang kode tak terpakai), *code splitting*, dan hashing nama file (`app.3f2a1b.js`) agar cache browser bisa dipakai maksimal.

### 9.2 Variabel Lingkungan & Mode

```bash
.env                # selalu dimuat
.env.development    # saat npm run dev
.env.production     # saat npm run build
.env.local          # lokal, JANGAN di-commit (otomatis di-ignore)
```

```js
const api = import.meta.env.VITE_API_URL
const prod = import.meta.env.PROD    // boolean
const base = import.meta.env.BASE_URL
```

### 9.3 Teknik Optimasi

**1) Code splitting & lazy loading route** (sudah dibahas di Bab 5):

```js
component: () => import('@/views/Laporan.vue')
```

**2) Analisis ukuran bundle:**

```bash
npm install -D rollup-plugin-visualizer
```

```js
// vite.config.js
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [vue(), visualizer({ open: true })],
})
```

**3) Optimasi aset**
- Gunakan format gambar modern (**WebP/AVIF**) dan atribut `loading="lazy"`.
- Kompres gambar (Squoosh, `vite-plugin-image-optimizer`).
- Gunakan `font-display: swap` dan batasi jumlah font.

**4) Impor yang hemat**
```js
// Boros: mengimpor seluruh library
import _ from 'lodash'
// Hemat: hanya fungsi yang dipakai
import debounce from 'lodash/debounce'
// atau gunakan alternatif ringan seperti lodash-es / es-toolkit
```

**5) Core Web Vitals.** Ukur dengan **Lighthouse** dan perhatikan LCP, INP, dan CLS. Hal yang membantu: lazy load, ukuran gambar eksplisit (hindari layout shift), kurangi JavaScript awal, dan manfaatkan caching/CDN.

### 9.4 Konfigurasi Server untuk SPA (History Mode)

Jika memakai `createWebHistory`, semua path harus diarahkan ke `index.html`.

**Nginx:**

```nginx
server {
  listen 80;
  root /usr/share/nginx/html;
  index index.html;

  location / {
    try_files $uri $uri/ /index.html;
  }

  # cache panjang untuk aset ber-hash
  location /assets/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
  }
}
```

### 9.5 Deployment

**a. Netlify / Vercel / Cloudflare Pages** (paling mudah)

1. Push proyek ke GitHub.
2. Hubungkan repositori di dashboard layanan.
3. Isi pengaturan build: *Build command* `npm run build`, *Output directory* `dist`.
4. Setiap `git push` ke branch utama akan otomatis ter-deploy.

Untuk Netlify, tambahkan `public/_redirects` agar SPA routing berfungsi:

```text
/*    /index.html   200
```

Untuk Vercel, buat `vercel.json`:

```json
{ "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }] }
```

**b. GitHub Pages**

Jika situs berada di `https://username.github.io/nama-repo/`, atur `base`:

```js
// vite.config.js
export default defineConfig({
  base: '/nama-repo/',
  plugins: [vue()],
})
```

Gunakan `createWebHashHistory` atau tambahkan file `404.html` yang menyalin `index.html`, karena GitHub Pages tidak mendukung fallback SPA secara bawaan.

**c. Docker**

```dockerfile
# Tahap 1: build
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Tahap 2: sajikan dengan Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```bash
docker build -t vue-app .
docker run -p 8080:80 vue-app
```

### 9.6 CI/CD dengan GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm

      - run: npm ci
      - run: npm run lint
      - run: npx vue-tsc --noEmit    # hapus jika tidak memakai TypeScript
      - run: npm run test:run
      - run: npm run build
```

> Versi action (`@v4`) dan versi Node bisa bertambah seiring waktu. Cek halaman resmi masing-masing action untuk versi terbaru.

### 9.7 Keamanan Frontend (Ringkas)

- Hindari `v-html` dengan konten yang tidak tepercaya (risiko **XSS**). Jika perlu, sanitasi dengan **DOMPurify**.
- Jangan simpan rahasia di kode frontend.
- Simpan token sensitif dengan hati-hati. Cookie `HttpOnly` yang diatur server umumnya lebih aman dibanding `localStorage` untuk token sesi.
- Update dependensi rutin dan jalankan `npm audit`.
- Validasi **selalu** dilakukan lagi di server.

### 9.8 Latihan Bab 9

1. Build proyekmu, jalankan `npm run preview`, lalu analisis bundle dengan visualizer.
2. Deploy ke Netlify/Vercel dan pastikan refresh di halaman `/produk/1` tidak 404.
3. Buat workflow GitHub Actions yang menjalankan lint, test, dan build.

---

## Bab 10. Ekosistem & Tools Modern

### 10.1 Peta Ekosistem Vue

| Kategori | Tool | Fungsi |
|---|---|---|
| Build tool | **Vite** | Dev server cepat (HMR), bundling produksi |
| Framework full-stack | **Nuxt** | SSR, SSG, file-based routing, auto-import, server API |
| Router | **Vue Router** | Routing SPA |
| State | **Pinia** | State management resmi |
| Utility composables | **VueUse** | Ratusan composable siap pakai |
| Server state | **TanStack Query** | Cache & sinkronisasi data API |
| Testing | **Vitest**, **Vue Test Utils**, **Playwright** | Unit, component, E2E |
| Dokumentasi | **VitePress** | Generator situs dokumentasi/blog berbasis Vue |
| Dev tools | **Vue DevTools** | Inspeksi komponen, Pinia, router, performa |
| Dokumentasi komponen | **Storybook** | Katalog & pengujian visual komponen |
| Bahasa | **TypeScript**, **vue-tsc** | Tipe statis |

### 10.2 Nuxt: Framework Full-Stack Vue

Jika butuh SEO, performa awal tinggi, atau struktur proyek yang siap pakai, **Nuxt** adalah pilihan utama. Fitur menonjol:

- **File-based routing**: file di `pages/` otomatis menjadi route.
- **Auto-import**: komponen, composable, dan fungsi Vue tidak perlu di-import manual.
- **Mode rendering fleksibel**: SSR, SSG, SPA, atau hibrida per-route.
- **Server routes**: tulis endpoint API di folder `server/`.
- **Modul**: ekosistem plugin (image, content, i18n, UI, dll.).

```bash
npm create nuxt@latest nama-proyek
cd nama-proyek
npm run dev
```

```text
nama-proyek/
├── pages/
│   ├── index.vue          →  /
│   ├── tentang.vue        →  /tentang
│   └── blog/[slug].vue    →  /blog/:slug
├── components/            # auto-import
├── composables/           # auto-import
├── server/api/halo.get.ts # endpoint GET /api/halo
└── nuxt.config.ts
```

```vue
<!-- pages/blog/[slug].vue -->
<script setup>
const route = useRoute()

// useFetch: aman untuk SSR, tanpa double-fetch di klien
const { data: artikel, pending, error } = await useFetch(`/api/artikel/${route.params.slug}`)

useSeoMeta({
  title: () => artikel.value?.judul,
  description: () => artikel.value?.ringkasan,
})
</script>

<template>
  <p v-if="pending">Memuat...</p>
  <article v-else-if="artikel">
    <h1>{{ artikel.judul }}</h1>
    <div>{{ artikel.isi }}</div>
  </article>
</template>
```

### 10.3 VueUse

Kumpulan composable utilitas: sensor browser, state, elemen, jaringan, dll.

```bash
npm install @vueuse/core
```

```vue
<script setup>
import { useLocalStorage, useDark, useToggle, useMouse, useDebounceFn, useWindowSize } from '@vueuse/core'

const catatan = useLocalStorage('catatan', '')   // otomatis sinkron ke localStorage
const isDark = useDark()
const toggleDark = useToggle(isDark)
const { x, y } = useMouse()
const { width } = useWindowSize()

const cari = useDebounceFn((q) => console.log(q), 300)
</script>
```

### 10.4 Library UI & Styling

| Library | Karakter |
|---|---|
| **Tailwind CSS** | Utility-first CSS, sangat fleksibel |
| **Vuetify** | Material Design lengkap |
| **PrimeVue** | Komponen enterprise lengkap (tabel, chart, form) |
| **Element Plus** | Populer untuk dashboard admin |
| **Naive UI** | Komponen modern, TypeScript-friendly |
| **Quasar** | Framework untuk web, mobile, dan desktop dari satu basis kode |
| **Nuxt UI / shadcn-vue / Radix Vue** | Komponen modern, *headless* atau berbasis Tailwind |

Menambahkan Tailwind ke proyek Vite mengikuti panduan terbaru di [tailwindcss.com/docs](https://tailwindcss.com/docs), karena cara pemasangannya berubah antar versi mayor. Contoh pemakaian:

```vue
<template>
  <button
    class="rounded-lg bg-emerald-500 px-4 py-2 font-semibold text-white
           hover:bg-emerald-600 disabled:opacity-50"
    :disabled="loading"
  >
    Simpan
  </button>
</template>
```

### 10.5 Tools Pendukung Lain

- **Vue DevTools**: tab *Components*, *Pinia*, *Routes*, *Timeline*, *Performance*.
- **ESLint** (`eslint-plugin-vue`) dan **Prettier** / **Oxlint**: kualitas & format kode.
- **unplugin-auto-import** dan **unplugin-vue-components**: auto-import di proyek Vite non-Nuxt.
- **vue-i18n**: internasionalisasi (multi-bahasa).
- **VeeValidate / FormKit**: form dan validasi.
- **Zod / Valibot**: skema validasi bertipe.
- **VitePress**: bangun dokumentasi atau blog statis.
- **Histoire / Storybook**: dokumentasi dan eksperimen komponen.
- **Husky + lint-staged**: jalankan lint/test otomatis sebelum commit.

### 10.6 Tren yang Perlu Dipantau

- **Vapor Mode**: strategi kompilasi alternatif Vue yang tidak memakai Virtual DOM untuk performa lebih tinggi. Perkembangannya aktif, jadi cek blog dan roadmap resmi Vue untuk status terbaru sebelum dipakai di produksi.
- **Toolchain berbasis Rust** (Rolldown, Oxc): bundler dan linter yang lebih cepat di ekosistem Vite.
- **Pengembangan berbantuan AI**: asisten kode membantu menulis boilerplate dan tes, tetapi **tinjau dan pahami** setiap kode yang dihasilkan.

### 10.7 Latihan Bab 10

1. Pasang VueUse dan ganti `useLocalStorage` buatanmu dengan versi VueUse.
2. Tambahkan dark mode memakai `useDark`.
3. Buat proyek Nuxt kecil dengan 3 halaman dan satu endpoint di `server/api`.

---

## Bab 11. Project Portofolio

Portofolio yang bagus **membuktikan kemampuan**, bukan sekadar memamerkan jumlah proyek. Rekruter dan klien melihat: kerapian kode, struktur, kemampuan menyelesaikan masalah, dan kualitas tampilan.

### 11.1 Daftar Ide Proyek Berdasarkan Level

| Level | Proyek | Konsep yang dilatih |
|---|---|---|
| **Pemula** | To-Do List dengan localStorage | Reaktivitas, v-for, komponen |
| **Pemula** | Aplikasi Cuaca (API publik) | Fetch, loading/error state |
| **Pemula** | Kalkulator & Pengubah Satuan | Event, computed |
| **Menengah** | Katalog Produk + Keranjang | Router, Pinia, filter/sort |
| **Menengah** | Aplikasi Catatan Keuangan | CRUD, chart, form validasi |
| **Menengah** | Movie Browser (TMDB API) | Pagination, pencarian, detail page |
| **Lanjut** | Dashboard Admin dengan Auth & Role | Guard, layout, tabel data, TanStack Query |
| **Lanjut** | Aplikasi Kolaborasi Real-time (kanban/chat) | WebSocket, drag-and-drop, optimistic UI |
| **Lanjut** | Blog/E-commerce dengan Nuxt (SSR) | SEO, SSR, server routes |

### 11.2 Studi Kasus: "TokoKu": Katalog + Keranjang + Auth

Proyek ini mencakup hampir semua materi Bab 1-10. Kamu bisa memakai API publik seperti **FakeStore API** atau **DummyJSON** sebagai backend.

**Fitur wajib:**

1. Daftar produk dengan pencarian (debounce), filter kategori, dan urut harga
2. Halaman detail produk (`/produk/:id`)
3. Keranjang belanja (Pinia) yang tersimpan di `localStorage`
4. Login/logout (simulasi token) + halaman yang diproteksi
5. Halaman checkout dengan validasi form
6. Loading skeleton, tampilan error, dan state kosong
7. Responsif (mobile-first) dan dark mode
8. Unit test untuk store + 1 E2E test alur beli
9. Deploy dengan CI/CD

**Struktur folder yang disarankan:**

```text
tokoku/
├── .github/workflows/ci.yml
├── e2e/                      # test Playwright
├── public/
└── src/
    ├── assets/
    ├── components/
    │   ├── ui/               # tombol, input, modal (generik)
    │   └── produk/           # KartuProduk, FilterProduk, ...
    ├── composables/          # useDebounce, useProdukFilter
    ├── layouts/
    ├── router/index.js
    ├── services/             # api.js, produkService.js
    ├── stores/               # auth.js, keranjang.js
    ├── views/                # HomeView, ProdukView, DetailView, CheckoutView, LoginView
    ├── App.vue
    └── main.js
```

**Cuplikan inti: filter produk dengan composable**

```js
// src/composables/useProdukFilter.js
import { ref, computed } from 'vue'
import { useDebounce } from './useDebounce'

export function useProdukFilter(daftar) {
  const kataKunci = ref('')
  const kategori = ref('semua')
  const urut = ref('default')
  const q = useDebounce(kataKunci, 300)

  const hasil = computed(() => {
    let data = [...daftar.value]

    if (kategori.value !== 'semua') {
      data = data.filter((p) => p.category === kategori.value)
    }
    if (q.value) {
      data = data.filter((p) => p.title.toLowerCase().includes(q.value.toLowerCase()))
    }
    if (urut.value === 'termurah') data.sort((a, b) => a.price - b.price)
    if (urut.value === 'termahal') data.sort((a, b) => b.price - a.price)

    return data
  })

  return { kataKunci, kategori, urut, hasil }
}
```

**Cuplikan inti: halaman daftar produk**

```vue
<script setup>
import { computed } from 'vue'
import { useQuery } from '@tanstack/vue-query'
import { produkService } from '@/services/produkService'
import { useProdukFilter } from '@/composables/useProdukFilter'
import { useKeranjangStore } from '@/stores/keranjang'
import KartuProduk from '@/components/produk/KartuProduk.vue'

const { data, isPending, isError, refetch } = useQuery({
  queryKey: ['produk'],
  queryFn: produkService.daftar,
})

const daftar = computed(() => data.value ?? [])
const { kataKunci, kategori, urut, hasil } = useProdukFilter(daftar)
const keranjang = useKeranjangStore()
</script>

<template>
  <section>
    <input v-model="kataKunci" placeholder="Cari produk..." />
    <select v-model="urut">
      <option value="default">Urutkan</option>
      <option value="termurah">Termurah</option>
      <option value="termahal">Termahal</option>
    </select>

    <p v-if="isPending">Memuat produk...</p>
    <div v-else-if="isError">
      <p>Gagal memuat.</p>
      <button @click="refetch()">Coba lagi</button>
    </div>
    <p v-else-if="hasil.length === 0">Produk tidak ditemukan.</p>

    <div v-else class="grid">
      <KartuProduk
        v-for="p in hasil"
        :key="p.id"
        :produk="p"
        @beli="keranjang.tambah(p)"
      />
    </div>
  </section>
</template>
```

**Tahapan pengerjaan (disarankan):**

| Minggu | Target |
|---|---|
| 1 | Setup, layout, daftar produk dari API |
| 2 | Router, detail produk, pencarian/filter |
| 3 | Pinia: keranjang, auth, guard |
| 4 | Checkout + validasi, polish UI, responsif |
| 5 | Testing + CI/CD + deploy |
| 6 | README, dokumentasi, refactor, demo video |

### 11.3 Checklist Kualitas Portofolio

- [ ] Repositori punya **README** yang jelas (lihat template di bawah)
- [ ] Ada **demo live** (link) dan screenshot/GIF
- [ ] Commit rapi dengan pesan bermakna (mis. *Conventional Commits*: `feat:`, `fix:`, `docs:`)
- [ ] Tidak ada rahasia ter-commit; ada `.env.example`
- [ ] Linting & test lolos di CI
- [ ] Aksesibilitas dasar: label form, kontras warna, navigasi keyboard, atribut `alt`
- [ ] Responsif di layar ponsel
- [ ] Penanganan loading, error, dan data kosong

### 11.4 Template README

```markdown
# Nama Proyek

Deskripsi singkat 1-2 kalimat: apa ini dan masalah apa yang diselesaikan.

![Screenshot](docs/screenshot.png)

**Demo:** https://tokoku.contoh.app

## Fitur
- Pencarian dengan debounce
- Keranjang tersimpan di localStorage
- Autentikasi dengan route guard

## Tech Stack
Vue 3, Vite, Pinia, Vue Router, TanStack Query, Vitest, Playwright

## Menjalankan Secara Lokal
    git clone https://github.com/username/tokoku.git
    cd tokoku
    cp .env.example .env
    npm install
    npm run dev

## Testing
    npm run test:run
    npm run test:e2e

## Keputusan Teknis
- Kenapa Pinia + TanStack Query: memisahkan state klien dan state server.
- Tantangan: mengelola race condition saat pencarian cepat.

## Lisensi
MIT
```

> Bagian **"Keputusan Teknis"** sangat dihargai rekruter karena menunjukkan cara berpikirmu, bukan hanya hasil akhirnya.

### 11.5 Mempresentasikan Portofolio

- Buat situs portofolio pribadi (bisa dengan Nuxt atau VitePress).
- Sematkan 3-5 proyek **terbaik**, bukan 20 proyek setengah jadi.
- Tulis studi kasus singkat: masalah → solusi → hasil/pelajaran.
- Rekam demo singkat (1-2 menit) tiap proyek.

---

## Bab 12. Mahir & Kontribusi

### 12.1 Memahami Cara Kerja Vue di Balik Layar

Pemahaman internal membedakan pengguna biasa dari developer mahir. Tiga pilar utama Vue:

1. **Sistem reaktivitas**: melacak dependensi & memicu update.
2. **Compiler**: mengubah template menjadi *render function* yang dioptimasi.
3. **Renderer**: membandingkan *virtual DOM* lama vs baru dan memperbarui DOM nyata secara efisien.

**Mini sistem reaktivitas dari nol** (konsep sebenarnya sama dengan Vue 3, hanya disederhanakan):

```js
const targetMap = new WeakMap()   // objek -> (properti -> set efek)
let activeEffect = null

function track(target, key) {
  if (!activeEffect) return
  let depsMap = targetMap.get(target)
  if (!depsMap) targetMap.set(target, (depsMap = new Map()))
  let dep = depsMap.get(key)
  if (!dep) depsMap.set(key, (dep = new Set()))
  dep.add(activeEffect)               // "efek ini bergantung pada properti ini"
}

function trigger(target, key) {
  const dep = targetMap.get(target)?.get(key)
  if (dep) [...dep].forEach((efek) => efek())   // jalankan ulang efek terkait
}

function reactive(obj) {
  return new Proxy(obj, {
    get(target, key, receiver) {
      track(target, key)
      return Reflect.get(target, key, receiver)
    },
    set(target, key, value, receiver) {
      const ok = Reflect.set(target, key, value, receiver)
      trigger(target, key)
      return ok
    },
  })
}

function effect(fn) {
  activeEffect = fn
  fn()                    // eksekusi pertama mengumpulkan dependensi
  activeEffect = null
}

// Uji coba
const state = reactive({ jumlah: 0 })
effect(() => console.log('Jumlah sekarang:', state.jumlah))
state.jumlah++   // log otomatis: "Jumlah sekarang: 1"
```

Alur: saat `effect` berjalan dan **membaca** `state.jumlah`, `get` mencatat ketergantungan (*track*). Saat nilai **diubah**, `set` menjalankan ulang efek terkait (*trigger*). Itulah inti `watchEffect`, `computed`, dan render komponen di Vue.

**Pelajari juga:**

- Cara kerja *Virtual DOM* dan algoritma *diffing* dengan `key`
- *Compiler optimizations*: static hoisting, patch flags, block tree
- Scheduler dan *batching* update (kenapa `nextTick` ada)

```js
import { ref, nextTick } from 'vue'

const teks = ref('a')
teks.value = 'b'
// DOM belum diperbarui di sini
await nextTick()
// DOM sudah diperbarui
```

Eksplorasi praktis: buka [Vue SFC Playground](https://play.vuejs.org) dan lihat tab **JS/Output** untuk melihat hasil kompilasi template-mu.

### 12.2 Pola Arsitektur untuk Aplikasi Besar

**a. Struktur berbasis fitur (feature-based):**

```text
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   ├── composables/
│   │   ├── stores/
│   │   ├── services/
│   │   └── routes.js
│   ├── produk/
│   └── keranjang/
├── shared/           # komponen, util, tipe yang dipakai lintas fitur
└── app/              # router, bootstrap, provider global
```

Dibanding struktur berbasis jenis file (`components/`, `stores/`, ...), pendekatan berbasis fitur menjaga kode yang berubah bersama tetap berdekatan.

**b. Prinsip desain komponen**

- **Single responsibility**: satu komponen, satu tujuan.
- Pisahkan komponen **presentasional** (menerima props, tanpa logika bisnis) dari komponen **kontainer** (mengambil data, memanggil store).
- Pilih **komposisi** (slot, composable) di atas pewarisan.
- Hindari komponen "dewa" berisi ratusan baris. Pecah menjadi komponen dan composable.

**c. Konvensi tim:** gaya penulisan seragam (`<script setup lang="ts">`), penamaan konsisten (komponen `PascalCase`, composable `useXxx`), ESLint + Prettier wajib, dan review kode lewat Pull Request.

### 12.3 Aksesibilitas (a11y) & Internasionalisasi

- Gunakan elemen semantik (`<button>`, `<nav>`, `<main>`), bukan `<div @click>`.
- Pastikan semua input punya `<label>`, dan modal mengelola *focus trap*.
- Uji dengan keyboard saja, lalu dengan pembaca layar.
- Pasang `eslint-plugin-vuejs-accessibility`.
- Untuk multi-bahasa, pakai **vue-i18n** dan pisahkan teks ke file terjemahan sejak awal.

### 12.4 Berkontribusi ke Open Source

Berkontribusi mempercepat belajar secara drastis: kamu membaca kode berkualitas, menerima *review* dari developer berpengalaman, dan membangun reputasi.

**Tingkat kontribusi, dari mudah ke sulit:**

| Tingkat | Bentuk kontribusi |
|---|---|
| 1 | Melaporkan bug dengan **reproduksi minimal** (Vue SFC Playground / StackBlitz) |
| 2 | Memperbaiki typo & memperjelas dokumentasi |
| 3 | **Menerjemahkan** dokumentasi |
| 4 | Menjawab pertanyaan di Discord, forum, atau Stack Overflow |
| 5 | Memperbaiki bug / menambah tes di library ekosistem |
| 6 | Mengerjakan issue di repositori inti (`vuejs/core`) |
| 7 | Mengusulkan fitur lewat **RFC** (`vuejs/rfcs`) |

**Alur kontribusi lewat GitHub:**

```bash
# 1. Fork repositori di GitHub, lalu clone fork-mu
git clone https://github.com/USERNAME/nama-repo.git
cd nama-repo

# 2. Tambahkan remote upstream agar bisa sinkron
git remote add upstream https://github.com/ORGANISASI/nama-repo.git

# 3. Buat branch khusus
git checkout -b fix/perbaiki-typo-dokumentasi

# 4. Kerjakan perubahan, jalankan lint & test sesuai CONTRIBUTING.md
# 5. Commit dengan format yang diminta proyek
git commit -m "docs: perbaiki typo pada panduan reaktivitas"

# 6. Push, lalu buka Pull Request dari GitHub
git push origin fix/perbaiki-typo-dokumentasi
```

**Langkah pertama yang disarankan:**

1. Baca **CONTRIBUTING.md** dan *Code of Conduct* repositori target. Setiap proyek punya aturan sendiri (format commit, cara menjalankan tes, dll.). Repositori inti Vue, misalnya, memakai monorepo dengan `pnpm`.
2. Cari issue berlabel **`good first issue`** atau **`help wanted`**.
3. **Komentar di issue** untuk memastikan belum ada yang mengerjakan dan arahnya sesuai.
4. Buat PR **kecil dan fokus**. Satu PR, satu tujuan, dengan deskripsi jelas.
5. Terima *review* dengan terbuka. Revisi adalah bagian normal dari proses.

**Menerjemahkan dokumentasi:** komunitas Vue mengelola terjemahan lewat organisasi `vuejs-translations` di GitHub. Cek di sana status terjemahan bahasa Indonesia terbaru dan cara bergabung. Bila belum aktif, kamu bisa menginisiasi dan berkoordinasi dengan komunitas.

**Membuat library/komponen sendiri:** mulai dari masalah nyata yang kamu temui. Gunakan template **`create-vue`** dengan mode library (Vite *library mode*), tulis dokumentasi dengan VitePress, beri tes, lalu publikasikan ke npm dengan **semantic versioning**.

### 12.5 Berbagi Ilmu

- Tulis blog (seperti panduan ini!) tentang hal yang baru kamu pelajari.
- Buat video, thread, atau sesi sharing di komunitas lokal.
- Ikut komunitas, misalnya grup Vue Indonesia, meetup, atau Discord Vue, dan hadiri konferensi (VueConf, Vue.js Nation, dan sejenisnya).
- Mengajar adalah cara terbaik menguji pemahamanmu.

### 12.6 Ciri Developer Vue yang "Mahir"

- [ ] Menjelaskan cara kerja reaktivitas Vue tanpa melihat catatan
- [ ] Memilih alat state dengan tepat (lokal vs Pinia vs TanStack Query)
- [ ] Menulis composable yang bersih, teruji, dan reusable
- [ ] Mendesain struktur proyek yang tetap rapi saat skala membesar
- [ ] Men-debug performa dengan DevTools dan memperbaiki *bottleneck* nyata
- [ ] Menulis tes yang bermakna dan mengatur pipeline CI/CD
- [ ] Membaca source code library dan dokumentasi dengan nyaman
- [ ] Pernah berkontribusi ke proyek open source atau membagikan ilmu ke orang lain

---

## Bab 13. Tips Belajar Efektif

### 13.1 Roadmap Belajar 12 Minggu

| Minggu | Fokus | Output |
|---|---|---|
| 1 | Persiapan, JavaScript modern, Git | Latihan JS, repo pertama |
| 2 | Pengenalan Vue, template syntax | To-Do List satu komponen |
| 3 | Reaktivitas, computed, watch, lifecycle | Aplikasi Cuaca |
| 4 | Komponen, props, emits, slots, composables | To-Do versi komponen |
| 5 | Vue Router | Aplikasi multi-halaman |
| 6 | Pinia | Keranjang belanja |
| 7 | API: fetch/Axios, TanStack Query | Movie Browser |
| 8 | TypeScript + Vue lanjutan | Refactor ke TypeScript |
| 9 | Testing | Cakupan tes pada proyek |
| 10 | Build, optimasi, deployment, CI/CD | Proyek live + pipeline |
| 11 | Nuxt & ekosistem | Blog/situs SSR kecil |
| 12 | Proyek portofolio final + README | Portofolio siap tampil |

Sesuaikan tempo. Belajar paruh waktu bisa memakan 4-6 bulan, dan itu wajar.

### 13.2 Strategi Belajar yang Terbukti Efektif

1. **Belajar sambil membangun.** Untuk setiap konsep baru, langsung terapkan di proyek kecil. Menonton tutorial tanpa mengetik kode menciptakan ilusi paham (*tutorial hell*).
2. **Aturan 70/30:** 70% waktu praktik, 30% membaca/menonton.
3. **Baca dokumentasi resmi.** [vuejs.org](https://vuejs.org) adalah sumber paling akurat dan terbaru. Biasakan membacanya sejak awal.
4. **Bangun dulu, sempurnakan kemudian.** Buat versi jelek yang jalan, baru refactor.
5. **Pakai teknik *Feynman*:** jelaskan konsep dengan bahasa sederhana. Jika tak bisa, berarti belum paham.
6. **Konsisten > intens.** 1 jam setiap hari lebih baik daripada 7 jam di akhir pekan.
7. **Jadikan error sebagai guru.** Baca pesan error dengan teliti, ia sering menunjukkan masalahnya.
8. **Tuliskan catatan** dengan kata-katamu sendiri (blog/Notion/Obsidian).
9. **Ulas ulang secara berkala** (*spaced repetition*): ulangi konsep lama setelah 1 hari, 1 minggu, 1 bulan.
10. **Belajar bersama.** Cari teman belajar, ikut komunitas, dan lakukan *code review* saling silang.

### 13.3 Cara Debugging yang Benar

1. **Reproduksi** masalahnya secara konsisten.
2. **Baca** pesan error lengkap, mulai dari baris pertama.
3. **Persempit** penyebab: matikan/komentari bagian kode sampai masalah hilang.
4. Gunakan `console.log`, `debugger`, dan **Vue DevTools** untuk melihat state/props nyata.
5. **Cek dokumentasi** sebelum bertanya.
6. Jika harus bertanya, siapkan: apa yang diharapkan, apa yang terjadi, **kode minimal**, pesan error, dan apa yang sudah dicoba.

### 13.4 Kesalahan Umum Pemula (dan Cara Menghindarinya)

| Kesalahan | Solusi |
|---|---|
| Lupa `.value` pada `ref` di script | Ingat: `.value` di script, otomatis di template |
| Destructure `reactive` / store → kehilangan reaktivitas | Pakai `toRefs` / `storeToRefs` |
| Mengubah props langsung di anak | Emit event / gunakan `defineModel` |
| `v-for` tanpa `key`, atau `key` memakai index | Pakai ID unik yang stabil |
| Menaruh logika berat di template | Pindahkan ke `computed` |
| Lupa membersihkan listener/timer | Bersihkan di `onUnmounted` / `onScopeDispose` |
| Semua state dijadikan global | Mulai lokal, naikkan hanya bila perlu |
| Satu komponen ratusan baris | Pecah jadi komponen & composable |
| Mengoptimasi sebelum mengukur | Ukur dulu dengan DevTools/Lighthouse |
| Menyalin kode tanpa paham | Ketik ulang, ubah, dan jelaskan per baris |
| Menaruh rahasia di `.env` frontend | Simpan di server/backend |

### 13.5 Sumber Belajar Rekomendasi

| Jenis | Sumber |
|---|---|
| Dokumentasi resmi | [vuejs.org](https://vuejs.org) · [router.vuejs.org](https://router.vuejs.org) · [pinia.vuejs.org](https://pinia.vuejs.org) · [vitest.dev](https://vitest.dev) · [nuxt.com](https://nuxt.com) |
| Latihan interaktif | [Vue Tutorial resmi](https://vuejs.org/tutorial/) · [Vue SFC Playground](https://play.vuejs.org) |
| Referensi JavaScript | [javascript.info](https://javascript.info) · [MDN Web Docs](https://developer.mozilla.org) |
| Kursus berbayar | Vue Mastery, Vue School (cek ketersediaan promo & materi terbaru) |
| Komunitas | Discord Vue Land, GitHub Discussions, grup Telegram/Facebook Vue Indonesia, Stack Overflow |
| Berita | [Vue.js News](https://news.vuejs.org), blog resmi Vue, newsletter komunitas |

### 13.6 Menjaga Motivasi

- Pecah target besar jadi **kemenangan kecil** yang bisa diselesaikan dalam sehari.
- Rayakan progres: simpan jejak di GitHub, lihat proyek lamamu dan sadari kemajuanmu.
- Jangan membandingkan bab 1 milikmu dengan bab 20 orang lain.
- Normal untuk merasa stuck. Istirahat, jalan sebentar, lalu kembali dengan kepala segar.
- Ingat alasanmu belajar: karier, proyek sampingan, atau sekadar rasa penasaran.

### 13.7 Setelah Menyelesaikan Panduan Ini

1. Selesaikan **proyek portofolio** dan deploy.
2. Pelajari **Nuxt** untuk SEO dan aplikasi full-stack.
3. Perdalam **backend dasar** (Node.js/Express, database, autentikasi) agar bisa membangun aplikasi *end-to-end*.
4. Perdalam **TypeScript**, **aksesibilitas**, dan **performa web**.
5. **Kontribusi** ke open source dan **bagikan** ilmumu.
6. Lamar magang/freelance. Pengalaman nyata adalah guru terbaik.

---

## Penutup

Kamu sekarang memiliki peta lengkap dari **persiapan hingga kontribusi open source**. Ingat bahwa menjadi mahir bukan soal menghafal semua API, melainkan **memahami konsep, terbiasa membangun, dan terus belajar**.

> *"Cara terbaik untuk belajar adalah dengan membangun sesuatu."* Mulailah dari proyek kecil hari ini.

Jika panduan ini bermanfaat, bagikan kepada temanmu yang sedang belajar Vue. Selamat belajar dan selamat berkarya! 🚀

---

### Referensi

- Dokumentasi resmi Vue.js: <https://vuejs.org>
- Vue Router: <https://router.vuejs.org>
- Pinia: <https://pinia.vuejs.org>
- Vite: <https://vite.dev>
- Vitest: <https://vitest.dev>
- Vue Test Utils: <https://test-utils.vuejs.org>
- Nuxt: <https://nuxt.com>
- VueUse: <https://vueuse.org>
- TanStack Query (Vue): <https://tanstack.com/query/latest/docs/framework/vue/overview>
- MDN Web Docs: <https://developer.mozilla.org>

{% endraw %}
