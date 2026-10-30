---
layout: post
title: "Panduan Lengkap Algoritma Sorting: Teori, Implementasi JavaScript, dan Analisis Performa"
date: 2026-10-30 08:00:00 +0700
categories: [Algoritma, Struktur Data]
tags: [sorting, javascript, jekyll, computer-science]
math: true
---

Selamat datang di panduan komprehensif mengenai **Algoritma Sorting (Pengurutan)**. Pengurutan data merupakan salah satu operasi mendasar yang paling sering digunakan dalam ilmu komputer dan pengembangan perangkat lunak. 

Pada artikel ini, kita akan mempelajari berbagai algoritma sorting—mulai dari tingkat dasar (*elementary*), menengah (*intermediate*), hingga non-perbandingan (*non-comparison*)—dilengkapi dengan konsep-konsep penting, implementasi kode JavaScript, ilustrasi visual, serta uji benchmark performa.

---
## Daftar Isi

* TOC
{:toc}

## 1. Konsep Tambahan dalam Sorting

Sebelum mendalami tiap algoritma, penting untuk memahami karakteristik serta istilah teoretis berikut:

* **Stable Sorting (Pengurutan Stabil):** Algoritma dikatakan *stable* jika tidak mengubah urutan relatif dari elemen-elemen yang memiliki nilai kunci yang sama.
* **In-place Sorting:** Algoritma yang hanya membutuhkan alokasi memori tambahan dalam jumlah konstan ($O(1)$ auxiliary space) di luar memori array utama.
* **Adaptive Sorting:** Algoritma yang dapat memanfaatkan kondisi awal data. Jika data sudah dalam kondisi terurut sebagian (*partially sorted*), waktu eksekusinya menjadi lebih cepat.
* **Comparison-based Sorting:** Algoritma yang menentukan urutan elemen dengan cara membandingkan nilai dua elemen ($a > b$, $a < b$, atau $a = b$).
* **Sorting Lower Bound:** Batas matematis minimum kompleksitas waktu untuk algoritma berbasis perbandingan pada kasus terburuk (*worst-case*) dan rata-rata (*average-case*), yaitu $\Omega(n \log n)$.

---

## 2. Elementary Sorting (Pengurutan Dasar)

Algoritma dalam kategori ini umumnya mudah dipahami dan diimplementasikan, namun memiliki kompleksitas waktu $O(n^2)$ pada kasus rata-rata dan terburuk.

### A. Bubble Sort
Bubble Sort bekerja dengan membandingkan pasangan elemen yang bersebelahan dan menukarnya jika urutannya salah. Proses ini diulang sampai seluruh array terurut.

![Visualisasi Bubble Sort](https://upload.wikimedia.org/wikipedia/commons/c/c8/Bubble-sort-example-300px.gif)

```javascript
function bubbleSort(arr) {
    let len = arr.length;
    let swapped;
    do {
        swapped = false;
        for (let i = 0; i < len - 1; i++) {
            if (arr[i] > arr[i + 1]) {
                let temp = arr[i];
                arr[i] = arr[i + 1];
                arr[i + 1] = temp;
                swapped = true;
            }
        }
        len--;
    } while (swapped);
    return arr;
}
```

### B. Selection Sort
Selection Sort membagi array menjadi dua bagian: bagian yang sudah terurut dan yang belum. Algoritma ini secara berulang mencari elemen terkecil dari bagian yang belum terurut dan menempatkannya di akhir bagian yang sudah terurut.

![Visualisasi Selection Sort](https://upload.wikimedia.org/wikipedia/commons/9/94/Selection-Sort-Animation.gif)

```javascript
function selectionSort(arr) {
    let n = arr.length;
    for (let i = 0; i < n - 1; i++) {
        let minIdx = i;
        for (let j = i + 1; j < n; j++) {
            if (arr[j] < arr[minIdx]) {
                minIdx = j;
            }
        }
        if (minIdx !== i) {
            let temp = arr[i];
            arr[i] = arr[minIdx];
            arr[minIdx] = temp;
        }
    }
    return arr;
}
```

### C. Insertion Sort
Insertion Sort membangun array hasil secara bertahap. Pada setiap iterasi, satu elemen diambil dari data tersisa dan disisipkan pada posisi yang tepat di dalam sub-array yang sudah terurut.

![Visualisasi Insertion Sort](https://upload.wikimedia.org/wikipedia/commons/0/0f/Insertion-sort-example-300px.gif)

```javascript
function insertionSort(arr) {
    let n = arr.length;
    for (let i = 1; i < n; i++) {
        let key = arr[i];
        let j = i - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
        }
        arr[j + 1] = key;
    }
    return arr;
}
```

---

## 3. Intermediate Sorting (Pengurutan Menengah)

Algoritma pengurutan menengah memanfaatkan pendekatan efisien seperti *Divide and Conquer* atau struktur data khusus untuk mencapai kompleksitas waktu rata-rata $O(n \log n)$.

### A. Merge Sort
Merge Sort membagi array menjadi dua sub-array secara rekursif hingga berukuran 1, kemudian menggabungkan (*merge*) sub-array tersebut kembali dalam kondisi terurut.

![Visualisasi Merge Sort](https://upload.wikimedia.org/wikipedia/commons/c/cc/Merge-sort-example-300px.gif)

```javascript
function mergeSort(arr) {
    if (arr.length <= 1) return arr;

    const mid = Math.floor(arr.length / 2);
    const left = mergeSort(arr.slice(0, mid));
    const right = mergeSort(arr.slice(mid));

    return merge(left, right);
}

function merge(left, right) {
    let result = [], i = 0, j = 0;
    while (i < left.length && j < right.length) {
        if (left[i] <= right[j]) {
            result.push(left[i]);
            i++;
        } else {
            result.push(right[j]);
            j++;
        }
    }
    return result.concat(left.slice(i)).concat(right.slice(j));
}
```

### B. Quick Sort
Quick Sort memilih sebuah elemen sebagai *pivot*, lalu mempartisi array sedemikian rupa sehingga elemen yang lebih kecil dari pivot berada di sebelah kiri dan yang lebih besar di sebelah kanan.

![Visualisasi Quick Sort](https://upload.wikimedia.org/wikipedia/commons/6/6a/Sorting_quicksort_anim.gif)

```javascript
function quickSort(arr) {
    if (arr.length <= 1) return arr;

    let pivot = arr[Math.floor(arr.length / 2)];
    let left = [];
    let right = [];
    let equal = [];

    for (let val of arr) {
        if (val < pivot) left.push(val);
        else if (val > pivot) right.push(val);
        else equal.push(val);
    }

    return [...quickSort(left), ...equal, ...quickSort(right)];
}
```

### C. Shell Sort
Shell Sort adalah variasi dari Insertion Sort yang membandingkan dan menukar elemen yang terpisah sejauh interval (*gap*) tertentu, kemudian secara bertahap mengencangkan interval tersebut hingga bernilai 1.

```javascript
function shellSort(arr) {
    let n = arr.length;
    for (let gap = Math.floor(n / 2); gap > 0; gap = Math.floor(gap / 2)) {
        for (let i = gap; i < n; i++) {
            let temp = arr[i];
            let j = i;
            while (j >= gap && arr[j - gap] > temp) {
                arr[j] = arr[j - gap];
                j -= gap;
            }
            arr[j] = temp;
        }
    }
    return arr;
}
```

### D. Heap Sort
Heap Sort mengubah array input menjadi struktur data Binary Heap (Max-Heap), lalu secara bertahap mengekstrak elemen maksimum dan mereorganisasi heap.

![Visualisasi Heap Sort](https://upload.wikimedia.org/wikipedia/commons/1/1b/Sorting_heapsort_anim.gif)

```javascript
function heapSort(arr) {
    let n = arr.length;

    for (let i = Math.floor(n / 2) - 1; i >= 0; i--) {
        heapify(arr, n, i);
    }

    for (let i = n - 1; i > 0; i--) {
        let temp = arr[0];
        arr[0] = arr[i];
        arr[i] = temp;
        heapify(arr, i, 0);
    }
    return arr;
}

function heapify(arr, n, i) {
    let largest = i;
    let left = 2 * i + 1;
    let right = 2 * i + 2;

    if (left < n && arr[left] > arr[largest]) largest = left;
    if (right < n && arr[right] > arr[largest]) largest = right;

    if (largest !== i) {
        let swap = arr[i];
        arr[i] = arr[largest];
        arr[largest] = swap;
        heapify(arr, n, largest);
    }
}
```

---

## 4. Non-Comparison Sorting

Algoritma non-perbandingan tidak melakukan operasi perbandingan antar-elemen langsung, melainkan menggunakan sifat internal data (seperti digit atau rentang integer) untuk mengurutkan dengan kompleksitas $O(n)$.

### A. Counting Sort
Counting Sort menghitung frekuensi setiap nilai elemen unik, lalu menghitung posisi relatif tiap nilai untuk membentuk hasil terurut. Sangat cocok jika rentang nilai ($k$) tidak jauh lebih besar dari jumlah elemen ($n$).

```javascript
function countingSort(arr) {
    if (arr.length === 0) return arr;
    let max = Math.max(...arr);
    let count = new Array(max + 1).fill(0);
    let output = new Array(arr.length);

    for (let i = 0; i < arr.length; i++) {
        count[arr[i]]++;
    }

    let idx = 0;
    for (let i = 0; i <= max; i++) {
        while (count[i] > 0) {
            output[idx++] = i;
            count[i]--;
        }
    }
    return output;
}
```

### B. Radix Sort
Radix Sort mengurutkan angka berdasarkan posisi digit individualnya, mulai dari digit bernilai terkecil (*Least Significant Digit*) hingga terbesar, biasanya menggunakan Counting Sort sebagai sub-rutin stabil.

```javascript
function getMax(arr) {
    return Math.max(...arr);
}

function countSortForRadix(arr, exp) {
    let output = new Array(arr.length).fill(0);
    let count = new Array(10).fill(0);

    for (let i = 0; i < arr.length; i++) {
        let digit = Math.floor(arr[i] / exp) % 10;
        count[digit]++;
    }

    for (let i = 1; i < 10; i++) {
        count[i] += count[i - 1];
    }

    for (let i = arr.length - 1; i >= 0; i--) {
        let digit = Math.floor(arr[i] / exp) % 10;
        output[count[digit] - 1] = arr[i];
        count[digit]--;
    }

    for (let i = 0; i < arr.length; i++) {
        arr[i] = output[i];
    }
}

function radixSort(arr) {
    if (arr.length === 0) return arr;
    let max = getMax(arr);
    for (let exp = 1; Math.floor(max / exp) > 0; exp *= 10) {
        countSortForRadix(arr, exp);
    }
    return arr;
}
```

### C. Bucket Sort
Bucket Sort membagi elemen-elemen ke dalam beberapa wadah (*bucket*). Setiap *bucket* kemudian diurutkan secara terpisah (menggunakan algoritma lain seperti Insertion Sort) lalu digabungkan.

```javascript
function bucketSort(arr, bucketSize = 5) {
    if (arr.length === 0) return arr;

    let min = Math.min(...arr);
    let max = Math.max(...arr);

    let bucketCount = Math.floor((max - min) / bucketSize) + 1;
    let buckets = new Array(bucketCount).fill(0).map(() => []);

    for (let i = 0; i < arr.length; i++) {
        let bucketIndex = Math.floor((arr[i] - min) / bucketSize);
        buckets[bucketIndex].push(arr[i]);
    }

    arr.length = 0;
    for (let i = 0; i < buckets.length; i++) {
        insertionSort(buckets[i]);
        arr.push(...buckets[i]);
    }
    return arr;
}
```

---

## 5. Praktik dan Benchmark Performa

### Script Pengujian Benchmark

Berikut adalah script pengujian yang dapat dijalankan di lingkungan Node.js atau Console Browser untuk mengukur waktu eksekusi masing-masing algoritma pada variasi ukuran data (100, 1.000, 10.000, dan 100.000 elemen) serta kondisi data (Acak, Terurut, dan Terbalik).

```javascript
// Generator Data Test
function generateData(size, type) {
    let arr = Array.from({ length: size }, () => Math.floor(Math.random() * 100000));
    if (type === 'sorted') {
        return arr.sort((a, b) => a - b);
    } else if (type === 'reversed') {
        return arr.sort((a, b) => a - b).reverse();
    }
    return arr; // random
}

// Helper Pengukur Waktu Ekskesusi
function measureExecutionTime(sortFunc, data) {
    let dataCopy = [...data];
    let start = performance.now();
    sortFunc(dataCopy);
    let end = performance.now();
    return (end - start).toFixed(3); // dalam ms
}

// Runner Benchmark
function runAllBenchmarks() {
    const sizes = [100, 1000, 10000, 100000];
    const dataTypes = ['random', 'sorted', 'reversed'];
    
    const algorithms = {
        'Bubble Sort': bubbleSort,
        'Selection Sort': selectionSort,
        'Insertion Sort': insertionSort,
        'Merge Sort': mergeSort,
        'Quick Sort': quickSort,
        'Shell Sort': shellSort,
        'Heap Sort': heapSort,
        'Counting Sort': countingSort,
        'Radix Sort': radixSort,
        'Bucket Sort': bucketSort
    };

    sizes.forEach(size => {
        console.log(`========================================`);
        console.log(` BENCHMARK UKURAN DATA: ${size} ELEMEN `);
        console.log(`========================================`);

        dataType.forEach(type => {
            console.log(`\n--- Tipe Data: ${type.toUpperCase()} ---`);
            const data = generateData(size, type);

            for (let [name, func] of Object.entries(algorithms)) {
                // Lewati algoritma O(n^2) pada data besar agar tidak crash/hang
                if (size >= 100000 && ['Bubble Sort', 'Selection Sort', 'Insertion Sort'].includes(name)) {
                    console.log(`${name}: Skipped (terlalu lambat untuk N=100.000)`);
                    continue;
                }
                let time = measureExecutionTime(func, data);
                console.log(`${name}: ${time} ms`);
            }
        });
    });
}

// Jalankan benchmark
// runAllBenchmarks();
```

---

## 6. Analisis Kelebihan dan Kekurangan

Tabel ringkasan karakteristik dan komparasi performa dari setiap algoritma pengurutan:

| Algoritma | Time (Best) | Time (Average) | Time (Worst) | Space Complexity | Stable? | In-Place? | Kelebihan & Kekurangan Utama |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Bubble Sort** | $O(n)$ | $O(n^2)$ | $O(n^2)$ | $O(1)$ | Ya | Ya | Sederhana, namun sangat tidak efisien untuk dataset besar. |
| **Selection Sort** | $O(n^2)$ | $O(n^2)$ | $O(n^2)$ | $O(1)$ | Tidak | Ya | Jumlah operasi pertukaran (*swap*) minimal, tetapi lambat di semua kondisi. |
| **Insertion Sort** | $O(n)$ | $O(n^2)$ | $O(n^2)$ | $O(1)$ | Ya | Ya | Sangat cepat untuk data kecil atau data yang hampir terurut (*adaptive*). |
| **Merge Sort** | $O(n \log n)$ | $O(n \log n)$ | $O(n \log n)$ | $O(n)$ | Ya | Tidak | Performa terjamin konsisten $O(n \log n)$, namun membutuhkan memori tambahan $O(n)$. |
| **Quick Sort** | $O(n \log n)$ | $O(n \log n)$ | $O(n^2)$ | $O(\log n)$ | Tidak | Ya | Sangat cepat dalam praktik umum, namun rentan mengalami $O(n^2)$ jika *pivot* buruk. |
| **Shell Sort** | $O(n \log n)$ | $O(n^{1.5})$ | $O(n^2)$ | $O(1)$ | Tidak | Ya | Efisien untuk ukuran sedang tanpa membutuhkan rekursi overhead. |
| **Heap Sort** | $O(n \log n)$ | $O(n \log n)$ | $O(n \log n)$ | $O(1)$ | Tidak | Ya | Menjamin waktu $O(n \log n)$ pada *worst-case* dengan penggunaan memori terhemat. |
| **Counting Sort**| $O(n + k)$ | $O(n + k)$ | $O(n + k)$ | $O(k)$ | Ya | Tidak | Sangat cepat untuk rentang angka kecil ($k$), namun tidak efisien jika $k \gg n$. |
| **Radix Sort** | $O(nk)$ | $O(nk)$ | $O(nk)$ | $O(n + k)$ | Ya | Tidak | Sangat efisien untuk bilangan bulat berdigit pendek, terbatas pada struktur data tertentu. |
| **Bucket Sort** | $O(n + k)$ | $O(n + k)$ | $O(n^2)$ | $O(n)$ | Ya | Tidak | Sangat cepat jika data terdistribusi secara seragam (*uniform distribution*). |

---

## Kesimpulan

1. **Untuk Data Kecil ($N \le 50$):** **Insertion Sort** sering kali merupakan pilihan paling efisien karena *overhead* yang rendah.
2. **Untuk Kasus Umum (General Purpose):** **Quick Sort** dan **Merge Sort** adalah pilihan utama. Jika membutuhkan jaminan memori hemat dan performa stabil, gunakan **Heap Sort**.
3. **Untuk Data Khusus (Kunci Integer/Rentang Terbatas):** Algoritma non-perbandingan seperti **Counting Sort** atau **Radix Sort** mampu memberikan waktu eksekusi linier $O(n)$ yang jauh melampaui batas $\Omega(n \log n)$.