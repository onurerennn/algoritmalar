# A* ve D* Yol Bulma Algoritmaları Karşılaştırması

Bu proje, robotik ve yapay zeka alanlarında sıkça kullanılan A* ve D* yol bulma algoritmalarını görselleştiren ve performanslarını karşılaştıran bir uygulamadır. Processing dili kullanılarak geliştirilmiştir.

## Proje Hakkında

Bu uygulama, aşağıdaki özelliklere sahiptir:

- **İki algoritmanın eş zamanlı görselleştirilmesi**: A* ve D* algoritmalarının aynı labirent üzerinde çalışması ve aşama aşama ilerleyişinin gözlenmesi
- **Detaylı performans karşılaştırması**: Çalışma süresi, yol uzunluğu, ziyaret edilen düğüm sayısı gibi metriklerin karşılaştırılması
- **Animasyonlu gösterim**: Düğümlerin keşif ve yol oluşturma süreçlerinin animasyonlu gösterimi
- **Kapsamlı raporlama**: Her algoritma için detaylı bilgi içeren raporlar ve karşılaştırma sonuçları

## Algoritmalar

### A* Algoritması
- **Forward Search** (İleri Arama) prensibiyle çalışır
- Başlangıç noktasından hedefe doğru arama yapar
- `f(n) = g(n) + h(n)` formülüyle en iyi yolu bulmaya çalışır
  - `g(n)`: Başlangıç noktasından n düğümüne kadar olan gerçek maliyet
  - `h(n)`: n düğümünden hedef noktaya tahmini maliyet (Manhattan mesafesi)

### D* Algoritması
- **Backward Search** (Geriye Doğru Arama) prensibiyle çalışır
- Hedef noktasından başlangıç noktasına doğru arama yapar
- Özellikle robotik uygulamalarda tercih edilir
- Dinamik ortamlara daha iyi adapte olabilir

## Kullanım

Projeyi çalıştırdıktan sonra şu kontrolleri kullanabilirsiniz:

- **R Tuşu**: Yeni bir rastgele labirent oluşturur
- **P Tuşu**: Algoritmaları çalıştırır ve animasyonu başlatır
- **SPACE Tuşu**: Görselleştirme ve detaylı rapor sayfası arasında geçiş yapar

## Animasyon Süreci

Programdaki animasyon süreci üç aşamadan oluşur:

1. **Keşif Aşaması**: Algoritmalar tarafından ziyaret edilen düğümlerin gösterilmesi
2. **Yol Oluşturma Aşaması**: Bulunan optimal yolun adım adım çizilmesi
3. **Rapor Aşaması**: Algoritmaların performans sonuçlarının gösterilmesi

## Teknik Detaylar

- **Grid Boyutu**: 30x30 hücreden oluşan bir ızgara
- **Engel Oranı**: Rastgele labirent oluşturmada %30 engel oranı
- **Yol Bulma Garantisi**: Başlangıç ve bitiş noktaları arasında her zaman en az bir yol olması garantilenir
- **Optimizasyonlar**: Hash tabanlı düğüm takibi ve verimli düğüm arama mekanizmaları

## Karşılaştırılan Metrikler

- **Çalışma Süresi (ms)**: Algoritmanın çalışması için geçen süre
- **Yol Uzunluğu (adım)**: Bulunan yolun toplam uzunluğu
- **Ziyaret Edilen Düğüm Sayısı**: Algoritmanın hedefi bulana kadar ziyaret ettiği toplam düğüm sayısı
- **Algoritma Adımları**: Yol bulma işlemi sırasında gerçekleştirilen toplam algoritma adımı sayısı

## Sonuçlar

Farklı labirent düzenlerinde, A* ve D* algoritmaları farklı performans gösterebilmektedir. Genel olarak:

- A* algoritması, genellikle daha az düğüm ziyaret ederek hedefe ulaşma eğilimindedir
- D* algoritması, dinamik ortamlarda daha etkili olabilir
- Her iki algoritma da optimal yol bulmada benzer performans gösterebilir

---

*Bu proje, algoritma karşılaştırma ve görselleştirme amacıyla eğitim için geliştirilmiştir.*
