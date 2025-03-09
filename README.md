A* ve Dijkstra Algoritmaları Karşılaştırması
Bu proje, A* ve Dijkstra algoritmalarının farklı labirentler üzerinde karşılaştırmasını yapmaktadır. Algoritmaların performansını analiz etmek için her iki algoritmanın yürütme süresi, ziyaret edilen düğüm sayısı ve yol uzunluğu gibi metrikler ölçülüp karşılaştırılmaktadır.

İçerik
A* Algoritması: Hedefe en kısa yolu bulmak için kullanılan bir yol bulma algoritmasıdır. Heuristic (bulma) fonksiyonu olarak Manhattan mesafesi kullanılmaktadır.
Dijkstra Algoritması: En kısa yolu bulmak için kullanılan, ancak heuristik fonksiyonu olmayan bir yol bulma algoritmasıdır. Tüm düğümleri eşit şekilde inceler.
Her iki algoritma için farklı labirentler üzerinde testler yapılarak karşılaştırma yapılır.

Gereksinimler
Proje, aşağıdaki Python kütüphanelerine ihtiyaç duyar:

numpy: Labirentlerin oluşturulması ve verilerin işlenmesi için.
heapq: A* ve Dijkstra algoritmalarındaki öncelikli kuyruk işlemleri için.
matplotlib: Algoritmaların sonuçlarını görselleştirmek için.
time: Algoritmaların çalışma süresini ölçmek için.

.
├── README.md            # Bu dosya
├── intro.py  # Algoritmaların ve testlerin bulunduğu ana Python dosyası
├── 10_labirent_karsilastirma.png  # A* ve Dijkstra algoritmalarının karşılaştırıldığı görsel
└── performans_karsilastirma.png    # Algoritmaların performans metriklerinin karşılaştırıldığı grafik

Kullanım
1. Labirent Oluşturulması
Proje, rastgele oluşturulmuş labirentler üzerinde çalışır. create_maze fonksiyonu, belirtilen boyutlardaki bir labirent ve duvar yoğunluğu (p_wall) ile labirenti oluşturur. Bu labirentte 0 yolları, 1 ise duvarları temsil eder.

2. Algoritmaların Çalıştırılması
PathFinder sınıfı içinde, A* ve Dijkstra algoritmalarını çalıştıran iki fonksiyon bulunmaktadır:

a_star(): A* algoritmasını kullanarak hedefe en kısa yolu bulur.
dijkstra(): Dijkstra algoritmasını kullanarak hedefe en kısa yolu bulur.
Her iki algoritmanın sonuçları karşılaştırılır.

3. Sonuçların Görselleştirilmesi
Her bir labirent için, A* ve Dijkstra algoritmalarının sonuçları görselleştirilir. Sonuçlar, yolların çizildiği labirentler olarak gösterilir. Aynı zamanda, her iki algoritmanın çalışma süresi, ziyaret edilen düğüm sayısı ve yol uzunluğu gibi performans metrikleri karşılaştırılır.

4. Karşılaştırmalı Analiz
run_multiple_comparisons fonksiyonu, 10 farklı labirent üzerinde her iki algoritmayı çalıştırarak performans karşılaştırmalarını yapar. Sonuçlar aşağıdaki gibi grafiklerde sunulur:

Labirent Görselleri: Her bir labirent ve algoritma sonuçları.
Performans Karşılaştırma Grafik: Ortalama yol uzunluğu, ziyaret edilen düğüm sayısı ve çalışma süresi karşılaştırılır.
5. Sonuçlar ve İstatistiksel Analiz
Sonuçlar hem görselleştirilir hem de yazılı olarak aşağıdaki gibi bir raporla özetlenir:

Yol Uzunluğu: Bulunan yolun uzunluğu.
Ziyaret Edilen Düğümler: Algoritma tarafından ziyaret edilen düğüm sayısı.
Süre (ms): Algoritmanın çalışma süresi (milisaniye cinsinden).

Sonuçlar
Her labirent için algoritmaların performansları karşılaştırılacak ve her iki algoritma için ortalama yol uzunluğu, ziyaret edilen düğüm sayısı ve çalışma süresi hesaplanacaktır.
Görselleştirilen sonuçlar, her iki algoritmanın çözüm yollarını ve performans farklarını gösterir
