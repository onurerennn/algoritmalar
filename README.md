# A* ve Dijkstra Algoritmaları Karşılaştırması

Bu proje, A* ve Dijkstra algoritmalarının farklı labirentler üzerinde karşılaştırılmasını yapmaktadır. Algoritmaların performansını analiz etmek için her iki algoritmanın yürütme süresi, ziyaret edilen düğüm sayısı ve yol uzunluğu gibi metrikler ölçülüp karşılaştırılmaktadır.

## İçerik

### **A* Algoritması**
A* algoritması, hedefe en kısa yolu bulmak için kullanılan bir yol bulma algoritmasıdır. Bu algoritmada **Manhattan mesafesi** heuristik fonksiyonu olarak kullanılmaktadır. A* algoritması, hedefe en hızlı ve verimli şekilde ulaşmak için yol bulma sürecini optimize eder.

### **Dijkstra Algoritması**
Dijkstra algoritması, en kısa yolu bulmak için kullanılan bir başka yol bulma algoritmasıdır ancak heuristik bir fonksiyon kullanmaz. Tüm düğümleri eşit şekilde inceleyerek hedefe ulaşmaya çalışır.

Her iki algoritma için farklı labirentler üzerinde testler yapılarak performansları karşılaştırılacaktır.

## Gereksinimler
Proje, aşağıdaki Python kütüphanelerine ihtiyaç duyar:

- **numpy**: Labirentlerin oluşturulması ve verilerin işlenmesi için.
- **heapq**: A* ve Dijkstra algoritmalarındaki öncelikli kuyruk işlemleri için.
- **matplotlib**: Algoritmaların sonuçlarını görselleştirmek için.
- **time**: Algoritmaların çalışma süresini ölçmek için.


## Kullanım

### **Labirent Oluşturulması**
Proje, rastgele oluşturulmuş labirentler üzerinde çalışır. `create_maze` fonksiyonu, belirtilen boyutlardaki bir labirent ve duvar yoğunluğu (`p_wall`) ile labirenti oluşturur. Labirentte **0** yolları, **1** ise duvarları temsil eder.

### **Algoritmaların Çalıştırılması**
Proje, **PathFinder** sınıfı içinde, A* ve Dijkstra algoritmalarını çalıştıran iki fonksiyon içerir:

- **a_star()**: A* algoritmasını kullanarak hedefe en kısa yolu bulur.
- **dijkstra()**: Dijkstra algoritmasını kullanarak hedefe en kısa yolu bulur.

Her iki algoritmanın sonuçları karşılaştırılacaktır.

### **Sonuçların Görselleştirilmesi**
Her bir labirent için, A* ve Dijkstra algoritmalarının sonuçları görselleştirilir. Sonuçlar, yolların çizildiği labirentler olarak gösterilecektir. Ayrıca, her iki algoritmanın:
- Çalışma süresi
- Ziyaret edilen düğüm sayısı
- Yol uzunluğu

gibi performans metrikleri karşılaştırılacaktır.

### **Karşılaştırmalı Analiz**
`run_multiple_comparisons` fonksiyonu, 10 farklı labirent üzerinde her iki algoritmayı çalıştırarak performans karşılaştırmalarını yapar. Sonuçlar aşağıdaki gibi grafiklerde sunulur:
- **Labirent Görselleri**: Her bir labirent ve algoritma sonuçları.
- **Performans Karşılaştırma Grafik**: Ortalama yol uzunluğu, ziyaret edilen düğüm sayısı ve çalışma süresi karşılaştırılır.

## Sonuçlar ve İstatistiksel Analiz
Sonuçlar, hem görselleştirilmiş şekilde hem de yazılı olarak aşağıdaki gibi bir raporla özetlenir:

- **Yol Uzunluğu**: Bulunan yolun uzunluğu.
- **Ziyaret Edilen Düğümler**: Algoritma tarafından ziyaret edilen düğüm sayısı.
- **Süre (ms)**: Algoritmanın çalışma süresi (milisaniye cinsinden).

Her labirent için algoritmaların performansları karşılaştırılacak ve her iki algoritma için ortalama yol uzunluğu, ziyaret edilen düğüm sayısı ve çalışma süresi hesaplanacaktır. Görselleştirilen sonuçlar, her iki algoritmanın çözüm yollarını ve performans farklarını açıkça gösterecektir.
