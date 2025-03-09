// A* ve Dijkstra Algoritmaları Karşılaştırması - Processing
// Grid tabanlı yol bulma ve performans karşılaştırması

// Grid ayarları
int cols = 25;
int rows = 25;
int cellSize = 20;

// Izgara ve düğümler
Node[][] grid;
Node[][] gridDijkstra;
ArrayList<Node> openSetAStar = new ArrayList<Node>();
ArrayList<Node> closedSetAStar = new ArrayList<Node>();
ArrayList<Node> pathAStar = new ArrayList<Node>();
ArrayList<Node> openSetDijkstra = new ArrayList<Node>();
ArrayList<Node> closedSetDijkstra = new ArrayList<Node>();
ArrayList<Node> pathDijkstra = new ArrayList<Node>();

// Başlangıç ve bitiş noktaları
Node startAStar, endAStar;
Node startDijkstra, endDijkstra;

// Algoritma durumları
boolean aStarComplete = false;
boolean dijkstraComplete = false;
boolean aStarFailed = false;
boolean dijkstraFailed = false;

// Performans ölçümleri
int aStarSteps = 0;
int dijkstraSteps = 0;
int aStarNodesVisited = 0;
int dijkstraNodesVisited = 0;
int aStarPathLength = 0;
int dijkstraPathLength = 0;
float aStarStartTime = 0;
float dijkstraStartTime = 0;
float aStarEndTime = 0;
float dijkstraEndTime = 0;

// Görünüm kontrolü
boolean showBothGrids = true;
int activePage = 0; // 0: görselleştirme, 1: rapor

void setup() {
  size(1110, 700);
  
  // A* ızgarasını oluştur
  grid = new Node[cols][rows];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j] = new Node(i, j);
    }
  }
  
  // A* için komşuları ayarla
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j].addNeighbors(grid);
    }
  }
  
  // Dijkstra ızgarasını oluştur
  gridDijkstra = new Node[cols][rows];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      gridDijkstra[i][j] = new Node(i, j);
    }
  }
  
  // Dijkstra için komşuları ayarla
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      gridDijkstra[i][j].addNeighbors(gridDijkstra);
    }
  }
  
  // Başlangıç ve bitiş noktalarını ayarla
  startAStar = grid[0][0];
  endAStar = grid[cols-1][rows-1];
  startDijkstra = gridDijkstra[0][0];
  endDijkstra = gridDijkstra[cols-1][rows-1];
  
  // Engelleri rastgele ayarla ve her iki ızgaraya da uygula
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (random(1) < 0.3 && (i != 0 || j != 0) && (i != cols-1 || j != rows-1)) {
        boolean isWall = true;
        grid[i][j].wall = isWall;
        gridDijkstra[i][j].wall = isWall;
      }
    }
  }
  
  // Algoritmaları başlat
  openSetAStar.add(startAStar);
  openSetDijkstra.add(startDijkstra);
  
  // Performans ölçümlerini başlat
  aStarStartTime = millis();
  dijkstraStartTime = millis();
}

void draw() {
  background(255);
  
  if (activePage == 0) {
    // Görselleştirme sayfası
    
    // A* Algoritması adımı
    if (!aStarComplete && !aStarFailed) {
      if (openSetAStar.size() > 0) {
        aStarSteps++;
        
        // En düşük f değerine sahip düğümü bul
        int winner = 0;
        for (int i = 0; i < openSetAStar.size(); i++) {
          if (openSetAStar.get(i).f < openSetAStar.get(winner).f) {
            winner = i;
          }
        }
        
        Node current = openSetAStar.get(winner);
        
        // Eğer hedef bulunduysa
        if (current == endAStar) {
          aStarEndTime = millis();
          pathAStar = new ArrayList<Node>();
          Node temp = current;
          pathAStar.add(temp);
          while (temp.previous != null) {
            pathAStar.add(temp.previous);
            temp = temp.previous;
          }
          aStarComplete = true;
          aStarPathLength = pathAStar.size() - 1; // Başlangıç düğümünü sayma
          aStarNodesVisited = closedSetAStar.size() + 1; // Şu anki düğümü ekle
          println("A* yolu bulundu! Adım sayısı: " + aStarSteps);
        }
        
        // Mevcut düğümü kapalı listeye taşı
        openSetAStar.remove(current);
        closedSetAStar.add(current);
        
        // Komşuları kontrol et
        ArrayList<Node> neighbors = current.neighbors;
        for (int i = 0; i < neighbors.size(); i++) {
          Node neighbor = neighbors.get(i);
          
          // Eğer duvar değilse ve kapalı listede değilse
          if (!closedSetAStar.contains(neighbor) && !neighbor.wall) {
            
            // Geçici g değeri hesapla
            float tempG = current.g + 1;
            
            // Eğer komşu açık listede değilse ekle
            boolean newPath = false;
            if (openSetAStar.contains(neighbor)) {
              if (tempG < neighbor.g) {
                neighbor.g = tempG;
                newPath = true;
              }
            } else {
              neighbor.g = tempG;
              newPath = true;
              openSetAStar.add(neighbor);
            }
            
            // Eğer yeni bir yolsa, h ve f değerlerini hesapla
            if (newPath) {
              neighbor.h = heuristic(neighbor, endAStar);
              neighbor.f = neighbor.g + neighbor.h;
              neighbor.previous = current;
            }
          }
        }
      } else {
        aStarEndTime = millis();
        aStarFailed = true;
        aStarNodesVisited = closedSetAStar.size();
        println("A* yolu bulunamadı!");
      }
    }
    
    // Dijkstra Algoritması adımı
    if (!dijkstraComplete && !dijkstraFailed) {
      if (openSetDijkstra.size() > 0) {
        dijkstraSteps++;
        
        // En düşük g değerine sahip düğümü bul
        int winner = 0;
        for (int i = 0; i < openSetDijkstra.size(); i++) {
          if (openSetDijkstra.get(i).g < openSetDijkstra.get(winner).g) {
            winner = i;
          }
        }
        
        Node current = openSetDijkstra.get(winner);
        
        // Eğer hedef bulunduysa
        if (current == endDijkstra) {
          dijkstraEndTime = millis();
          pathDijkstra = new ArrayList<Node>();
          Node temp = current;
          pathDijkstra.add(temp);
          while (temp.previous != null) {
            pathDijkstra.add(temp.previous);
            temp = temp.previous;
          }
          dijkstraComplete = true;
          dijkstraPathLength = pathDijkstra.size() - 1; // Başlangıç düğümünü sayma
          dijkstraNodesVisited = closedSetDijkstra.size() + 1; // Şu anki düğümü ekle
          println("Dijkstra yolu bulundu! Adım sayısı: " + dijkstraSteps);
        }
        
        // Mevcut düğümü kapalı listeye taşı
        openSetDijkstra.remove(current);
        closedSetDijkstra.add(current);
        
        // Komşuları kontrol et
        ArrayList<Node> neighbors = current.neighbors;
        for (int i = 0; i < neighbors.size(); i++) {
          Node neighbor = neighbors.get(i);
          
          // Eğer duvar değilse ve kapalı listede değilse
          if (!closedSetDijkstra.contains(neighbor) && !neighbor.wall) {
            
            // Geçici g değeri hesapla
            float tempG = current.g + 1;
            
            // Eğer komşu açık listede değilse ekle
            boolean newPath = false;
            if (openSetDijkstra.contains(neighbor)) {
              if (tempG < neighbor.g) {
                neighbor.g = tempG;
                newPath = true;
              }
            } else {
              neighbor.g = tempG;
              newPath = true;
              openSetDijkstra.add(neighbor);
            }
            
            // Eğer yeni bir yolsa, h ve f değerlerini hesapla (Dijkstra için h=0)
            if (newPath) {
              neighbor.h = 0;
              neighbor.f = neighbor.g; // Dijkstra için f = g
              neighbor.previous = current;
            }
          }
        }
      } else {
        dijkstraEndTime = millis();
        dijkstraFailed = true;
        dijkstraNodesVisited = closedSetDijkstra.size();
        println("Dijkstra yolu bulunamadı!");
      }
    }
    
    // Izgaraları çiz
    if (showBothGrids) {
      // A* ızgarasını çiz
      pushMatrix();
      translate(50, 50);
      
      for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
          grid[i][j].show(color(255));
        }
      }
      
      for (int i = 0; i < closedSetAStar.size(); i++) {
        closedSetAStar.get(i).show(color(255, 0, 0, 100));
      }
      
      for (int i = 0; i < openSetAStar.size(); i++) {
        openSetAStar.get(i).show(color(0, 255, 0, 100));
      }
      
      for (int i = 0; i < pathAStar.size(); i++) {
        pathAStar.get(i).show(color(0, 0, 255, 100));
      }
      
      startAStar.show(color(0, 255, 0));
      endAStar.show(color(255, 0, 0));
      
      textSize(16);
      fill(0);
      text("A* Algoritması", 0, -10);
      popMatrix();
      
      // Dijkstra ızgarasını çiz
      pushMatrix();
      translate(cols * cellSize + 100, 50);
      
      for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
          gridDijkstra[i][j].show(color(255));
        }
      }
      
      for (int i = 0; i < closedSetDijkstra.size(); i++) {
        closedSetDijkstra.get(i).show(color(255, 0, 0, 100));
      }
      
      for (int i = 0; i < openSetDijkstra.size(); i++) {
        openSetDijkstra.get(i).show(color(0, 255, 0, 100));
      }
      
      for (int i = 0; i < pathDijkstra.size(); i++) {
        pathDijkstra.get(i).show(color(0, 0, 255, 100));
      }
      
      startDijkstra.show(color(0, 255, 0));
      endDijkstra.show(color(255, 0, 0));
      
      textSize(16);
      fill(0);
      text("Dijkstra Algoritması", 0, -10);
      popMatrix();
    }
    
    // Açıklama metni
    fill(0);
    textSize(14);
    text("Yeşil: Başlangıç", 50, height - 100);
    text("Kırmızı: Hedef", 50, height - 80);
    text("Açık Yeşil: İncelenecek Düğümler", 50, height - 60);
    text("Açık Kırmızı: İncelenmiş Düğümler", 50, height - 40);
    text("Mavi: Bulunan Yol", 50, height - 20);
    
    text("KONTROLLER:", width - 350, height - 100);
    text("SPACE: Görselleştirme ve Rapor Arasında Geçiş", width - 350, height - 80);
    text("R: Yeni Harita Oluştur", width - 350, height - 60);
    
    // Mevcut durum bilgisi
    fill(0);
    textSize(14);
    String aStarStatus = aStarComplete ? "TAMAMLANDI" : (aStarFailed ? "BAŞARISIZ" : "ÇALIŞIYOR");
    String dijkstraStatus = dijkstraComplete ? "TAMAMLANDI" : (dijkstraFailed ? "BAŞARISIZ" : "ÇALIŞIYOR");
    
    text("A* Durum: " + aStarStatus + " - Adım: " + aStarSteps, 300, height - 60);
    text("Dijkstra Durum: " + dijkstraStatus + " - Adım: " + dijkstraSteps, 300, height - 40);
  }
  else {
    // Rapor sayfası
    displayReport();
  }
}

void displayReport() {
  background(255);
  
  float pageWidth = width - 100;
  float pageHeight = height - 100;
  float startX = 50;
  float startY = 50;
  
  // Rapor çerçevesi
  fill(252);
  stroke(200);
  rect(startX, startY, pageWidth, pageHeight);
  
  // Rapor başlığı
  fill(0);
  textSize(24);
  textAlign(CENTER);
  text("A* ve Dijkstra Algoritmaları Karşılaştırma Raporu", width/2, startY + 30);
  
  textAlign(LEFT);
  float lineY = startY + 70;
  float colWidth = pageWidth / 3;
  
  // Sonuç bilgisi
  String aStarResult = aStarComplete ? "Yol Bulundu" : (aStarFailed ? "Yol Bulunamadı" : "Çalışıyor");
  String dijkstraResult = dijkstraComplete ? "Yol Bulundu" : (dijkstraFailed ? "Yol Bulunamadı" : "Çalışıyor");
  
  float aStarTime = (aStarEndTime - aStarStartTime) / 1000.0;
  float dijkstraTime = (dijkstraEndTime - dijkstraStartTime) / 1000.0;
  
  // Tablo başlığı
  textSize(18);
  fill(50);
  text("Metrik", startX + 20, lineY);
  text("A* Algoritması", startX + 20 + colWidth, lineY);
  text("Dijkstra Algoritması", startX + 20 + 2*colWidth, lineY);
  
  lineY += 20;
  stroke(200);
  line(startX + 10, lineY, startX + pageWidth - 10, lineY);
  lineY += 20;
  
  // Tablo içeriği
  textSize(14);
  fill(0);
  
  // Sonuç satırı
  text("Sonuç", startX + 20, lineY);
  text(aStarResult, startX + 20 + colWidth, lineY);
  text(dijkstraResult, startX + 20 + 2*colWidth, lineY);
  lineY += 30;
  
  // Adım sayısı satırı
  text("Algoritma Adım Sayısı", startX + 20, lineY);
  text(String.valueOf(aStarSteps), startX + 20 + colWidth, lineY);
  text(String.valueOf(dijkstraSteps), startX + 20 + 2*colWidth, lineY);
  lineY += 30;
  
  // Ziyaret edilen düğüm satırı
  text("Ziyaret Edilen Düğüm Sayısı", startX + 20, lineY);
  text(String.valueOf(aStarNodesVisited), startX + 20 + colWidth, lineY);
  text(String.valueOf(dijkstraNodesVisited), startX + 20 + 2*colWidth, lineY);
  lineY += 30;
  
  // Yol uzunluğu satırı - DÜZELTME YAPILDI
  text("Bulunan Yol Uzunluğu", startX + 20, lineY);
  text(aStarComplete ? String.valueOf(aStarPathLength) : "-", startX + 20 + colWidth, lineY);
  text(dijkstraComplete ? String.valueOf(dijkstraPathLength) : "-", startX + 20 + 2*colWidth, lineY);
  lineY += 30;
  
  // Çalışma süresi satırı
  text("Çalışma Süresi (saniye)", startX + 20, lineY);
  text(nf(aStarTime, 0, 3), startX + 20 + colWidth, lineY);
  text(nf(dijkstraTime, 0, 3), startX + 20 + 2*colWidth, lineY);
  lineY += 30;
  
  // Performans yorumları
  lineY += 20;
  textSize(18);
  fill(50);
  text("Performans Analizi:", startX + 20, lineY);
  lineY += 30;
  
  textSize(14);
  fill(0);
  
  // Algoritmaların karşılaştırmalı performans analizi
  String performanceAnalysis = "";
  
  if (aStarComplete && dijkstraComplete) {
    performanceAnalysis += "• Her iki algoritma da hedef noktaya ulaşmayı başardı.\n\n";
    
    if (aStarSteps < dijkstraSteps) {
      performanceAnalysis += "• A* algoritması daha az adımda (" + aStarSteps + " vs " + dijkstraSteps + ") çözüme ulaştı.\n\n";
    } else if (aStarSteps > dijkstraSteps) {
      performanceAnalysis += "• Dijkstra algoritması daha az adımda (" + dijkstraSteps + " vs " + aStarSteps + ") çözüme ulaştı.\n\n";
    } else {
      performanceAnalysis += "• Her iki algoritma da aynı adım sayısında çözüme ulaştı.\n\n";
    }
    
    if (aStarNodesVisited < dijkstraNodesVisited) {
      performanceAnalysis += "• A* algoritması daha az düğümü ziyaret ederek (" + aStarNodesVisited + " vs " + dijkstraNodesVisited + ") çalıştı.\n\n";
    } else if (aStarNodesVisited > dijkstraNodesVisited) {
      performanceAnalysis += "• Dijkstra algoritması daha az düğümü ziyaret ederek (" + dijkstraNodesVisited + " vs " + aStarNodesVisited + ") çalıştı.\n\n";
    } else {
      performanceAnalysis += "• Her iki algoritma da aynı sayıda düğümü ziyaret etti.\n\n";
    }
    
    if (aStarPathLength == dijkstraPathLength) {
      performanceAnalysis += "• Her iki algoritma da aynı uzunlukta optimal yol buldu (" + aStarPathLength + " adım).\n\n";
    } else {
      String shorter = aStarPathLength < dijkstraPathLength ? "A*" : "Dijkstra";
      int diff = Math.abs(aStarPathLength - dijkstraPathLength);
      performanceAnalysis += "• " + shorter + " algoritması " + diff + " adım daha kısa bir yol buldu.\n\n";
    }
    
    if (aStarTime < dijkstraTime) {
      performanceAnalysis += "• A* algoritması daha hızlı çalıştı (" + nf(aStarTime, 0, 3) + "s vs " + nf(dijkstraTime, 0, 3) + "s).\n\n";
    } else if (aStarTime > dijkstraTime) {
      performanceAnalysis += "• Dijkstra algoritması daha hızlı çalıştı (" + nf(dijkstraTime, 0, 3) + "s vs " + nf(aStarTime, 0, 3) + "s).\n\n";
    } else {
      performanceAnalysis += "• Her iki algoritma da aynı sürede çalıştı.\n\n";
    }
    
    performanceAnalysis += "• A*, sezgisel (heuristic) fonksiyon kullanarak aramayı hedef yönünde odaklarken, Dijkstra tüm yönlere eşit şekilde yayıldı.";
  } 
  else if (aStarComplete && !dijkstraComplete) {
    performanceAnalysis += "• Sadece A* algoritması hedef noktaya ulaştı, Dijkstra başarısız oldu veya henüz tamamlanmadı.\n\n";
    performanceAnalysis += "• A* algoritması, hedef yönünde ilerlemek için sezgisel fonksiyon kullanarak engelleri daha etkili bir şekilde aşabildi.";
  } 
  else if (!aStarComplete && dijkstraComplete) {
    performanceAnalysis += "• Sadece Dijkstra algoritması hedef noktaya ulaştı, A* başarısız oldu veya henüz tamamlanmadı.\n\n";
    performanceAnalysis += "• Bu durum olağandışıdır, A* genellikle Dijkstra'dan daha hızlı sonuç verir. Sezgisel fonksiyonun bu problem için uygun olmamış olabilir.";
  } 
  else {
    performanceAnalysis += "• Her iki algoritma da henüz çözüme ulaşamadı veya başarısız oldu.\n\n";
    performanceAnalysis += "• Başlangıç ve hedef noktaları arasında geçerli bir yol olmayabilir.";
  }
  
  // Performans analizini göster
  String[] analysisLines = split(performanceAnalysis, '\n');
  for (String line : analysisLines) {
    text(line, startX + 20, lineY);
    lineY += 20;
  }
  
  // Sayfa geçiş bilgisi
  textSize(14);
  fill(100);
  text("Görselleştirmeye geri dönmek için SPACE tuşuna basın", width/2 - 150, height - 30);
}

// Öklidyen mesafe hesaplama (A* için)
float heuristic(Node a, Node b) {
  return dist(a.i, a.j, b.i, b.j);
}

// Tuş kontrolleri
void keyPressed() {
  if (key == ' ') {
    // Görselleştirme ve rapor sayfaları arasında geçiş
    activePage = 1 - activePage;
  }
  
  // Yeni harita
  if (key == 'r' || key == 'R') {
    resetSimulation();
  }
}

// Simulasyonu sıfırla
void resetSimulation() {
  // Izgaraları temizle
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j].g = 0;
      grid[i][j].f = 0;
      grid[i][j].h = 0;
      grid[i][j].previous = null;
      grid[i][j].wall = false;
      
      gridDijkstra[i][j].g = 0;
      gridDijkstra[i][j].f = 0;
      gridDijkstra[i][j].h = 0;
      gridDijkstra[i][j].previous = null;
      gridDijkstra[i][j].wall = false;
    }
  }
  
  // Engelleri rastgele ayarla ve her iki ızgaraya da uygula
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (random(1) < 0.3 && (i != 0 || j != 0) && (i != cols-1 || j != rows-1)) {
        boolean isWall = true;
        grid[i][j].wall = isWall;
        gridDijkstra[i][j].wall = isWall;
      }
    }
  }
  
  // Algoritma durumlarını sıfırla
  aStarComplete = false;
  dijkstraComplete = false;
  aStarFailed = false;
  dijkstraFailed = false;
  
  // Listeleri temizle
  openSetAStar = new ArrayList<Node>();
  closedSetAStar = new ArrayList<Node>();
  pathAStar = new ArrayList<Node>();
  openSetDijkstra = new ArrayList<Node>();
  closedSetDijkstra = new ArrayList<Node>();
  pathDijkstra = new ArrayList<Node>();
  
  // Algoritmaları yeniden başlat
  openSetAStar.add(startAStar);
  openSetDijkstra.add(startDijkstra);
  
  // Performans ölçümlerini sıfırla
  aStarSteps = 0;
  dijkstraSteps = 0;
  aStarNodesVisited = 0;
  dijkstraNodesVisited = 0;
  aStarPathLength = 0;
  dijkstraPathLength = 0;
  aStarStartTime = millis();
  dijkstraStartTime = millis();
  aStarEndTime = 0;
  dijkstraEndTime = 0;
}

// Düğüm sınıfı
class Node {
  int i, j;
  float f, g, h;
  ArrayList<Node> neighbors;
  Node previous;
  boolean wall;
  
  Node(int i, int j) {
    this.i = i;
    this.j = j;
    this.f = 0;
    this.g = 0;
    this.h = 0;
    this.neighbors = new ArrayList<Node>();
    this.previous = null;
    this.wall = false;
  }
  
  // Düğümü çiz
  void show(color col) {
    fill(wall ? 0 : col);
    stroke(0);
    rect(i * cellSize, j * cellSize, cellSize, cellSize);
  }
  
  // Komşuları ekle
  void addNeighbors(Node[][] grid) {
    if (i < cols - 1) {
      neighbors.add(grid[i + 1][j]);
    }
    if (i > 0) {
      neighbors.add(grid[i - 1][j]);
    }
    if (j < rows - 1) {
      neighbors.add(grid[i][j + 1]);
    }
    if (j > 0) {
      neighbors.add(grid[i][j - 1]);
    }
    
    // Köşegen komşuları eklemek için kodlar. A* algoritması köşegen olduğunda daha hızlı çalışıyor
    // if (i > 0 && j > 0) {
    //   neighbors.add(grid[i - 1][j - 1]);
    // }
    // if (i < cols - 1 && j > 0) {
    //   neighbors.add(grid[i + 1][j - 1]);
    // }
    // if (i > 0 && j < rows - 1) {
    //   neighbors.add(grid[i - 1][j + 1]);
    // }
    // if (i < cols - 1 && j < rows - 1) {
    //   neighbors.add(grid[i + 1][j + 1]);
    // }
  }
}
