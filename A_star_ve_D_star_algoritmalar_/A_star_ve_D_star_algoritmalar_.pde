import java.util.*;

// Grid boyutları
int GRID_SIZE = 30;
int CELL_SIZE = 20;
int[][] grid;
Node startNode;
Node endNode;
List<Node> pathAStar;
List<Node> pathDStar;
boolean isAnimating = false;
int animationSpeed = 50; // milisaniye
int lastAnimationTime = 0;
int currentPathIndex = 0;
int currentVisitedIndex = 0;
Map<String, Double> comparisonStats = new HashMap<String, Double>();

// İki algoritmanın ziyaret ettiği düğümleri takip etmek için
Set<Node> visitedNodesAStar = new HashSet<Node>();
Set<Node> visitedNodesDStar = new HashSet<Node>();
List<Node> visitedNodesAStarOrdered = new ArrayList<Node>();
List<Node> visitedNodesDStarOrdered = new ArrayList<Node>();
int totalNodesVisitedAStar = 0;
int totalNodesVisitedDStar = 0;

// Algoritma adımları
int aStarSteps = 0;
int dStarSteps = 0;

// Aktivite/sayfa durumu
int activePage = 0; // 0: görselleştirme, 1: rapor

// Animasyon aşaması
enum AnimationPhase { EXPLORING, PATH_BUILDING, COMPLETED }
AnimationPhase currentPhase = AnimationPhase.EXPLORING;

void setup() {
  size(1600, 900); // Daha yüksek bir pencere boyutu
  background(255);
  initializeGrid();
  startNode = new Node(0, 0);
  endNode = new Node(GRID_SIZE-1, GRID_SIZE-1);
  pathAStar = new ArrayList<Node>();
  pathDStar = new ArrayList<Node>();
  visitedNodesAStarOrdered = new ArrayList<Node>();
  visitedNodesDStarOrdered = new ArrayList<Node>();
}

void draw() {
  background(255);
  
  if (activePage == 0) {
    // Görselleştirme sayfası
    int gridYOffset = 30; // Grid'ler için yukarıdan boşluk
    
    // Aşama bilgisini göster
    if (isAnimating) {
      drawAnimationPhaseInfo();
    }
    
    // A* grid'i
    pushMatrix();
    translate(200, gridYOffset);
    drawGrid();
    drawVisitedNodesAnimated(visitedNodesAStarOrdered, color(200, 200, 255), pathAStar); // Açık mavi
    if (currentPhase != AnimationPhase.EXPLORING) {
      drawPathAnimated(pathAStar, color(0, 0, 255)); // Mavi
    }
    drawStartEndPoints();
    drawLegend("A*", 0);
    popMatrix();
    
    // D* grid'i
    pushMatrix();
    translate(800, gridYOffset);
    drawGrid();
    drawVisitedNodesAnimated(visitedNodesDStarOrdered, color(255, 200, 255), pathDStar); // Açık mor
    if (currentPhase != AnimationPhase.EXPLORING) {
      drawPathAnimated(pathDStar, color(255, 0, 255)); // Mor
    }
    drawStartEndPoints();
    drawLegend("D*", 0);
    popMatrix();
    
    // Grid'lerin altındaki raporlar
    if (!isAnimating) {
      // A* raporu
      if (pathAStar.size() > 0) {
        drawDetailedAlgorithmReport("A*", 200, gridYOffset + GRID_SIZE * CELL_SIZE + 20);
      }
      
      // D* raporu
      if (pathDStar.size() > 0) {
        drawDetailedAlgorithmReport("D*", 800, gridYOffset + GRID_SIZE * CELL_SIZE + 20);
      }
      
      // Karşılaştırma raporu
      if (pathAStar.size() > 0 && pathDStar.size() > 0) {
        drawComparisonSummary();
      }
    }
    
    // Durum bilgisi ve kontroller
    drawStatusAndControls();
    
    // Animasyon mantığı
    updateAnimation();
  } else {
    // Detaylı rapor sayfası
    displayDetailedReport();
  }
}

void displayDetailedReport() {
  background(255);
  
  float pageWidth = width - 100;
  float pageHeight = height - 100;
  float startX = 50;
  float startY = 50;
  
  // Başlık
  fill(0);
  textSize(30);
  textAlign(CENTER, TOP);
  text("A* ve D* YOL BULMA ALGORİTMALARI KARŞILAŞTIRMASI", width/2, 20);
  
  // Ekran yakalama gizli butonları
  fill(240);
  noStroke();
  rect(10, 20, 30, 30);
  rect(width - 40, 20, 30, 30);
  
  // Sol panel - A* algoritması açıklaması
  fill(240, 245, 255);
  stroke(180);
  rect(startX, startY, pageWidth/2 - 25, pageHeight/2 - 25, 10);
  
  textAlign(LEFT, TOP);
  fill(0);
  textSize(20);
  text("A* Algoritması", startX + 20, startY + 20);
  
  textSize(14);
  String aStarText = 
    "A* (A-Star), hedef-tabanlı yol bulma problemlerinde optimum çözüm bulmak için kullanılan bir arama algoritmasıdır.\n\n" +
    "Temel Özellikleri:\n" +
    "• Forward search (ileri arama) prensibiyle çalışır\n" +
    "• Başlangıç noktasından hedefe doğru arama yapar\n" +
    "• Heuristic (sezgisel) fonksiyon kullanarak hedefin yerini tahmin eder\n" +
    "• f(n) = g(n) + h(n) formülü ile çalışır\n" +
    "   - g(n): Başlangıç noktasından n düğümüne kadar olan gerçek maliyet\n" +
    "   - h(n): n düğümünden hedef noktaya tahmini maliyet (Manhattan mesafesi)\n\n" +
    "Avantajları:\n" +
    "• En kısa yolu bulma garantisi\n" +
    "• Hızlı ve verimli çalışma\n" +
    "• Sezgisel fonksiyon sayesinde hedefe yönelimli arama";
    
  text(aStarText, startX + 20, startY + 60, pageWidth/2 - 65, pageHeight/2 - 85);
  
  // Sağ panel - D* algoritması açıklaması
  fill(255, 245, 255);
  stroke(180);
  rect(startX + pageWidth/2 + 25, startY, pageWidth/2 - 25, pageHeight/2 - 25, 10);
  
  textAlign(LEFT, TOP);
  fill(0);
  textSize(20);
  text("D* Algoritması", startX + pageWidth/2 + 45, startY + 20);
  
  textSize(14);
  String dStarText = 
    "D* (D-Star), dinamik ortamlarda yol bulma için geliştirilmiş bir arama algoritmasıdır.\n\n" +
    "Temel Özellikleri:\n" +
    "• Backward search (geriye doğru arama) prensibiyle çalışır\n" +
    "• Hedef noktasından başlangıç noktasına doğru arama yapar\n" +
    "• Dinamik ortamlara adapte olabilir\n" +
    "• Özellikle robot navigasyonu için tasarlanmıştır\n\n" +
    "Avantajları:\n" +
    "• Dinamik ortamlarda verimli çalışma\n" +
    "• Engeller değiştiğinde yolu yeniden hesaplayabilme\n" +
    "• Gerçek zamanlı sistemlerde kullanışlı\n" +
    "• Robotik ve otonom sistem uygulamalarında tercih edilir";
    
  text(dStarText, startX + pageWidth/2 + 45, startY + 60, pageWidth/2 - 65, pageHeight/2 - 85);
  
  // Alt panel - Karşılaştırma tablosu
  fill(248, 248, 255);
  rect(startX, startY + pageHeight/2 + 25, pageWidth, pageHeight/2 - 25, 10);
  
  // Karşılaştırma tablosu başlık
  fill(0);
  textSize(20);
  textAlign(CENTER, TOP);
  text("ALGORİTMA PERFORMANS KARŞILAŞTIRMA TABLOSU", width/2, startY + pageHeight/2 + 45);
  
  // Tablo başlıkları
  float colWidth = pageWidth / 6;
  float tableStartY = startY + pageHeight/2 + 85;
  
  fill(230, 230, 240);
  noStroke();
  rect(startX + 20, tableStartY, pageWidth - 40, 30);
  
  fill(0);
  textSize(14);
  textAlign(CENTER, CENTER);
  text("Metrik", startX + 20 + colWidth/2, tableStartY + 15);
  text("A* Değeri", startX + 20 + colWidth*1.5, tableStartY + 15);
  text("D* Değeri", startX + 20 + colWidth*2.5, tableStartY + 15);
  text("Fark", startX + 20 + colWidth*3.5, tableStartY + 15);
  text("Kazanan", startX + 20 + colWidth*4.5, tableStartY + 15);
  
  // Güvenli şekilde değerlere eriş
  double aStarTime = 0.0;
  double dStarTime = 0.0;
  double aStarLength = 0.0;
  double dStarLength = 0.0;
  
  if (comparisonStats.containsKey("A*_time")) {
    aStarTime = comparisonStats.get("A*_time");
  }
  
  if (comparisonStats.containsKey("D*_time")) {
    dStarTime = comparisonStats.get("D*_time");
  }
  
  if (comparisonStats.containsKey("A*_path_length")) {
    aStarLength = comparisonStats.get("A*_path_length");
  }
  
  if (comparisonStats.containsKey("D*_path_length")) {
    dStarLength = comparisonStats.get("D*_path_length");
  }
  
  // Tablo içeriği
  stroke(220);
  float rowHeight = 35;
  
  // 1. Satır - Çalışma Süresi
  tableStartY += 35;
  line(startX + 20, tableStartY, startX + pageWidth - 20, tableStartY);
  
  textAlign(LEFT, CENTER);
  fill(0);
  text("Çalışma Süresi (ms)", startX + 30, tableStartY + rowHeight/2);
  
  textAlign(CENTER, CENTER);
  text(nf((float)aStarTime, 0, 2), startX + 20 + colWidth*1.5, tableStartY + rowHeight/2);
  text(nf((float)dStarTime, 0, 2), startX + 20 + colWidth*2.5, tableStartY + rowHeight/2);
  
  double timeDiff = dStarTime - aStarTime;
  text(nf(abs((float)timeDiff), 0, 2), startX + 20 + colWidth*3.5, tableStartY + rowHeight/2);
  
  fill(timeDiff > 0 ? color(0, 100, 0) : (timeDiff < 0 ? color(100, 0, 0) : color(0)));
  text(timeDiff == 0 ? "Eşit" : (timeDiff > 0 ? "A*" : "D*"), startX + 20 + colWidth*4.5, tableStartY + rowHeight/2);
  
  // 2. Satır - Yol Uzunluğu
  tableStartY += rowHeight;
  line(startX + 20, tableStartY, startX + pageWidth - 20, tableStartY);
  
  textAlign(LEFT, CENTER);
  fill(0);
  text("Yol Uzunluğu (adım)", startX + 30, tableStartY + rowHeight/2);
  
  textAlign(CENTER, CENTER);
  text(nf((float)aStarLength, 0, 0), startX + 20 + colWidth*1.5, tableStartY + rowHeight/2);
  text(nf((float)dStarLength, 0, 0), startX + 20 + colWidth*2.5, tableStartY + rowHeight/2);
  
  double pathDiff = dStarLength - aStarLength;
  text(nf(abs((float)pathDiff), 0, 0), startX + 20 + colWidth*3.5, tableStartY + rowHeight/2);
  
  fill(pathDiff > 0 ? color(0, 100, 0) : (pathDiff < 0 ? color(100, 0, 0) : color(0)));
  text(pathDiff == 0 ? "Eşit" : (pathDiff > 0 ? "A*" : "D*"), startX + 20 + colWidth*4.5, tableStartY + rowHeight/2);
  
  // 3. Satır - Ziyaret Edilen Düğümler
  tableStartY += rowHeight;
  line(startX + 20, tableStartY, startX + pageWidth - 20, tableStartY);
  
  textAlign(LEFT, CENTER);
  fill(0);
  text("Ziyaret Edilen Düğüm", startX + 30, tableStartY + rowHeight/2);
  
  textAlign(CENTER, CENTER);
  text(String.valueOf(totalNodesVisitedAStar), startX + 20 + colWidth*1.5, tableStartY + rowHeight/2);
  text(String.valueOf(totalNodesVisitedDStar), startX + 20 + colWidth*2.5, tableStartY + rowHeight/2);
  
  double visitedDiff = totalNodesVisitedDStar - totalNodesVisitedAStar;
  text(str(abs((int)visitedDiff)), startX + 20 + colWidth*3.5, tableStartY + rowHeight/2);
  
  fill(visitedDiff > 0 ? color(0, 100, 0) : (visitedDiff < 0 ? color(100, 0, 0) : color(0)));
  text(visitedDiff == 0 ? "Eşit" : (visitedDiff > 0 ? "A*" : "D*"), startX + 20 + colWidth*4.5, tableStartY + rowHeight/2);
  
  // 4. Satır - Adım Sayısı
  tableStartY += rowHeight;
  line(startX + 20, tableStartY, startX + pageWidth - 20, tableStartY);
  
  textAlign(LEFT, CENTER);
  fill(0);
  text("Algoritma Adımları", startX + 30, tableStartY + rowHeight/2);
  
  textAlign(CENTER, CENTER);
  text(String.valueOf(aStarSteps), startX + 20 + colWidth*1.5, tableStartY + rowHeight/2);
  text(String.valueOf(dStarSteps), startX + 20 + colWidth*2.5, tableStartY + rowHeight/2);
  
  double stepsDiff = dStarSteps - aStarSteps;
  text(str(abs((int)stepsDiff)), startX + 20 + colWidth*3.5, tableStartY + rowHeight/2);
  
  fill(stepsDiff > 0 ? color(0, 100, 0) : (stepsDiff < 0 ? color(100, 0, 0) : color(0)));
  text(stepsDiff == 0 ? "Eşit" : (stepsDiff > 0 ? "A*" : "D*"), startX + 20 + colWidth*4.5, tableStartY + rowHeight/2);
  
  // Çerçeve
  noFill();
  stroke(200);
  rect(startX + 20, tableStartY - rowHeight*3, pageWidth - 40, rowHeight*4);
  
  for (int i = 1; i < 5; i++) {
    line(startX + 20 + colWidth*i, tableStartY - rowHeight*3, startX + 20 + colWidth*i, tableStartY + rowHeight);
  }
  
  // Sonuç bölümü
  fill(245, 245, 255);
  noStroke();
  rect(startX + 20, tableStartY + rowHeight + 20, pageWidth - 40, 60, 10);
  
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  
  String conclusion = "";
  int aStarWins = 0;
  int dStarWins = 0;
  
  if (timeDiff > 0) aStarWins++; else if (timeDiff < 0) dStarWins++;
  if (pathDiff > 0) aStarWins++; else if (pathDiff < 0) dStarWins++;
  if (visitedDiff > 0) aStarWins++; else if (visitedDiff < 0) dStarWins++;
  if (stepsDiff > 0) aStarWins++; else if (stepsDiff < 0) dStarWins++;
  
  if (aStarWins > dStarWins) {
    conclusion = "SONUÇ: Bu test durumunda A* algoritması " + aStarWins + " metrikte daha iyi performans gösterdi.";
  } else if (dStarWins > aStarWins) {
    conclusion = "SONUÇ: Bu test durumunda D* algoritması " + dStarWins + " metrikte daha iyi performans gösterdi.";
  } else {
    conclusion = "SONUÇ: Bu test durumunda her iki algoritma da eşit performans gösterdi.";
  }
  
  text(conclusion, width/2, tableStartY + rowHeight + 50);
  
  // Sayfa geçiş bilgisi
  textSize(14);
  fill(100);
  textAlign(CENTER, BOTTOM);
  text("Görselleştirmeye geri dönmek için SPACE tuşuna basın", width/2, height - 20);
}

void initializeGrid() {
  grid = new int[GRID_SIZE][GRID_SIZE];
  
  // Labirenti temizle
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      grid[i][j] = 0;
    }
  }
  
  // Engelleri ekle
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      // Başlangıç ve bitiş noktaları ile çevresindeki hücrelere engel koyma
      if ((i == 0 && j == 0) || (i == GRID_SIZE-1 && j == GRID_SIZE-1) ||
          (i == 1 && j == 0) || (i == 0 && j == 1) ||
          (i == GRID_SIZE-2 && j == GRID_SIZE-1) || (i == GRID_SIZE-1 && j == GRID_SIZE-2)) {
        continue;
      }
      
      if (random(1) < 0.3) { // %30 engel olasılığı
        grid[i][j] = 1;
      }
    }
  }
  
  // Yol olabilmesi için bazı engelleri kaldır (labirent oluşturma)
  ensurePathExists();
}

// Başlangıç ve bitiş arasında bir yol olmasını sağla
void ensurePathExists() {
  // Flood fill algoritması ile kontrol et
  boolean[][] visited = new boolean[GRID_SIZE][GRID_SIZE];
  Queue<int[]> queue = new LinkedList<>();
  queue.add(new int[]{0, 0}); // Başlangıç noktası
  visited[0][0] = true;
  
  while (!queue.isEmpty()) {
    int[] current = queue.poll();
    int x = current[0];
    int y = current[1];
    
    // Komşuları kontrol et
    int[][] directions = {{-1,0}, {1,0}, {0,-1}, {0,1}};
    for (int[] dir : directions) {
      int newX = x + dir[0];
      int newY = y + dir[1];
      
      if (newX >= 0 && newX < GRID_SIZE && newY >= 0 && newY < GRID_SIZE && 
          !visited[newX][newY] && grid[newX][newY] == 0) {
        visited[newX][newY] = true;
        queue.add(new int[]{newX, newY});
      }
    }
  }
  
  // Bitiş noktasına ulaşılamıyorsa, bir yol aç
  if (!visited[GRID_SIZE-1][GRID_SIZE-1]) {
    println("Yol bulunamadı, yeni bir yol açılıyor...");
    
    // Açgözlü bir yaklaşımla yol oluştur
    int x = 0, y = 0;
    while (x < GRID_SIZE-1 || y < GRID_SIZE-1) {
      // Sağa veya aşağı hareket et
      if (x < GRID_SIZE-1 && (y == GRID_SIZE-1 || random(1) < 0.5)) {
        x++;
      } else if (y < GRID_SIZE-1) {
        y++;
      }
      
      // Yolu aç
      grid[x][y] = 0;
    }
  }
}

void drawGrid() {
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      if (grid[i][j] == 1) {
        fill(0);
      } else {
        fill(255);
      }
      rect(j * CELL_SIZE, i * CELL_SIZE, CELL_SIZE, CELL_SIZE);
      stroke(200);
    }
  }
}

void drawStartEndPoints() {
  // Başlangıç ve bitiş noktalarını çiz
  fill(0, 255, 0);
  rect(startNode.y * CELL_SIZE, startNode.x * CELL_SIZE, CELL_SIZE, CELL_SIZE);
  fill(255, 0, 0);
  rect(endNode.y * CELL_SIZE, endNode.x * CELL_SIZE, CELL_SIZE, CELL_SIZE);
}

void drawVisitedNodesAnimated(List<Node> visitedOrdered, color nodeColor, List<Node> path) {
  noStroke();
  fill(nodeColor);
  
  for (int i = 0; i < Math.min(currentVisitedIndex, visitedOrdered.size()); i++) {
    Node node = visitedOrdered.get(i);
    
    // Yol üzerinde değilse göster
    boolean onPath = false;
    if (path != null) {
      for (Node pathNode : path) {
        if (node.equals(pathNode)) {
          onPath = true;
          break;
        }
      }
    }
    
    if (!onPath || currentPhase == AnimationPhase.EXPLORING) {
      rect(node.y * CELL_SIZE + 2, node.x * CELL_SIZE + 2, CELL_SIZE - 4, CELL_SIZE - 4);
    }
  }
  stroke(0);
}

void drawPathAnimated(List<Node> path, color pathColor) {
  if (path != null && path.size() > 0) {
    // Önce ziyaret edilen noktaları kenarları olan kareler olarak çiz
    stroke(pathColor);
    strokeWeight(2);
    noFill();
    for (int i = 0; i <= Math.min(currentPathIndex, path.size()-1); i++) {
      Node node = path.get(i);
      rect(node.y * CELL_SIZE + 1, node.x * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2);
    }
    
    // Sonra çizgiyi çiz
    stroke(pathColor);
    strokeWeight(3);
    beginShape();
    for (int i = 0; i <= Math.min(currentPathIndex, path.size()-1); i++) {
      Node node = path.get(i);
      vertex(node.y * CELL_SIZE + CELL_SIZE/2, node.x * CELL_SIZE + CELL_SIZE/2);
    }
    endShape();
    
    // Eğer animasyon bittiyse, adım numaralarını göster
    if (currentPhase == AnimationPhase.COMPLETED) {
      textSize(10);
      fill(0);
      for (int i = 0; i < path.size(); i++) {
        Node node = path.get(i);
        text(i+1, node.y * CELL_SIZE + CELL_SIZE/2 - 3, node.x * CELL_SIZE + CELL_SIZE/2 + 4);
      }
    }
  }
}

void drawAnimationPhaseInfo() {
  fill(0);
  textSize(18);
  textAlign(CENTER, TOP);
  
  String phaseText = "";
  switch (currentPhase) {
    case EXPLORING:
      phaseText = "Keşif Aşaması - Düğümler Ziyaret Ediliyor";
      break;
    case PATH_BUILDING:
      phaseText = "Yol Oluşturma Aşaması - En İyi Yol Bulunuyor";
      break;
    case COMPLETED:
      phaseText = "Tamamlandı - Sonuçlar Değerlendiriliyor";
      break;
  }
  
  text(phaseText, width/2, 5);
}

void drawDetailedAlgorithmReport(String algorithmName, int xOffset, int yOffset) {
  int reportWidth = 400;
  int reportHeight = 200;
  
  // Rapor arka planı
  fill(240, 240, 255, 220);
  if (algorithmName.equals("D*")) {
    fill(255, 240, 255, 220);
  }
  stroke(180);
  rect(xOffset, yOffset, reportWidth, reportHeight, 10);
  
  // Rapor içeriği
  fill(0);
  textSize(16);
  textAlign(LEFT, TOP);
  
  // Güvenli şekilde değerlere eriş
  double timeMs = 0.0;
  double pathLength = 0.0;
  int visitedNodes = algorithmName.equals("A*") ? totalNodesVisitedAStar : totalNodesVisitedDStar;
  int steps = algorithmName.equals("A*") ? aStarSteps : dStarSteps;
  
  if (comparisonStats.containsKey(algorithmName + "_time")) {
    timeMs = comparisonStats.get(algorithmName + "_time");
  }
  
  if (comparisonStats.containsKey(algorithmName + "_path_length")) {
    pathLength = comparisonStats.get(algorithmName + "_path_length");
  }
  
  text(algorithmName + " ALGORİTMA PERFORMANS RAPORU", xOffset + 10, yOffset + 10);
  text("Çalışma Süresi: " + nf((float)(timeMs), 0, 2) + " ms", xOffset + 10, yOffset + 40);
  text("Yol Uzunluğu: " + (int)pathLength + " adım", xOffset + 10, yOffset + 70);
  text("Ziyaret Edilen Düğüm: " + visitedNodes, xOffset + 10, yOffset + 100);
  text("Algoritma Adımları: " + steps, xOffset + 10, yOffset + 130);
  
  String algoritmaTipi = algorithmName.equals("A*") ? "Forward Search (İleri Arama)" : "Backward Search (Geri Arama)";
  text("Algoritma Tipi: " + algoritmaTipi, xOffset + 10, yOffset + 160);
}

void drawComparisonSummary() {
  fill(245, 245, 255, 220);
  stroke(180);
  rect(400, 750, 800, 120, 10);
  
  fill(0);
  textSize(18);
  textAlign(CENTER, TOP);
  text("ALGORİTMA KARŞILAŞTIRMA ÖZET", width/2, 760);
  
  textAlign(LEFT, TOP);
  textSize(14);
  
  // Güvenli şekilde değerlere eriş
  double aStarTime = 0.0;
  double dStarTime = 0.0;
  double aStarLength = 0.0; 
  double dStarLength = 0.0;
  
  if (comparisonStats.containsKey("A*_time")) {
    aStarTime = comparisonStats.get("A*_time");
  }
  
  if (comparisonStats.containsKey("D*_time")) {
    dStarTime = comparisonStats.get("D*_time");
  }
  
  if (comparisonStats.containsKey("A*_path_length")) {
    aStarLength = comparisonStats.get("A*_path_length");
  }
  
  if (comparisonStats.containsKey("D*_path_length")) {
    dStarLength = comparisonStats.get("D*_path_length");
  }
  
  double timeDiff = dStarTime - aStarTime;
  double pathDiff = dStarLength - aStarLength;
  double visitedDiff = totalNodesVisitedDStar - totalNodesVisitedAStar;
  
  text("Hız Karşılaştırması: " + (timeDiff > 0 ? "A* " + nf((float)timeDiff, 0, 2) + " ms daha hızlı" : "D* " + nf((float)(-timeDiff), 0, 2) + " ms daha hızlı"), 450, 790);
  text("Yol Uzunluğu Karşılaştırması: " + (pathDiff > 0 ? "A* " + (int)pathDiff + " adım daha kısa" : "D* " + (int)(-pathDiff) + " adım daha kısa"), 450, 820);
  text("Ziyaret Edilen Düğüm Karşılaştırması: " + (visitedDiff > 0 ? "A* " + (int)visitedDiff + " daha az düğüm ziyaret etti" : "D* " + (int)(-visitedDiff) + " daha az düğüm ziyaret etti"), 450, 850);
}

void drawStatusAndControls() {
  // Panel arka planı
  fill(240);
  stroke(200);
  rect(0, height - 50, width, 50);
  
  // İçerik
  fill(0);
  textSize(14);
  textAlign(LEFT, CENTER);
  
  String aStarStatus = !isAnimating ? "TAMAMLANDI" : (currentPhase == AnimationPhase.EXPLORING ? "KEŞİF" : "YOL OLUŞTURMA");
  String dStarStatus = !isAnimating ? "TAMAMLANDI" : (currentPhase == AnimationPhase.EXPLORING ? "KEŞİF" : "YOL OLUŞTURMA");
  
  text("A* Durum: " + aStarStatus + " - Adım: " + aStarSteps, 300, height - 30);
  text("D* Durum: " + dStarStatus + " - Adım: " + dStarSteps, 300, height - 10);
  
  text("KONTROLLER:", 50, height - 30);
  text("SPACE: Görselleştirme / Rapor", 50, height - 10);
  text("R: Yeni Labirent", 650, height - 30);
  text("P: Algoritmaları Çalıştır", 650, height - 10);
}

void updateAnimation() {
  if (isAnimating) {
    int currentTime = millis();
    if (currentTime - lastAnimationTime > animationSpeed) {
      lastAnimationTime = currentTime;
      
      // Keşif aşaması (ziyaret edilen düğümleri göster)
      if (currentPhase == AnimationPhase.EXPLORING) {
        currentVisitedIndex++;
        
        if (currentVisitedIndex <= visitedNodesAStarOrdered.size()) {
          aStarSteps++;
        }
        
        if (currentVisitedIndex <= visitedNodesDStarOrdered.size()) {
          dStarSteps++;
        }
        
        int maxVisited = Math.max(visitedNodesAStarOrdered.size(), visitedNodesDStarOrdered.size());
        if (currentVisitedIndex >= maxVisited) {
          currentPhase = AnimationPhase.PATH_BUILDING;
          currentPathIndex = 0;
        }
      } 
      // Yol oluşturma aşaması
      else if (currentPhase == AnimationPhase.PATH_BUILDING) {
        currentPathIndex++;
        
        int maxPath = Math.max(pathAStar.size(), pathDStar.size());
        if (currentPathIndex >= maxPath) {
          currentPhase = AnimationPhase.COMPLETED;
          isAnimating = false;
          generateComparisonReport();
        }
      }
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    // Görselleştirme ve rapor arasında geçiş
    activePage = 1 - activePage;
  } else if (key == 'r') {
    resetSimulation();
  } else if (key == 'p' && !isAnimating) {
    startSimulation();
  }
}

void resetSimulation() {
  initializeGrid();
  pathAStar.clear();
  pathDStar.clear();
  visitedNodesAStar.clear();
  visitedNodesDStar.clear();
  visitedNodesAStarOrdered.clear();
  visitedNodesDStarOrdered.clear();
  totalNodesVisitedAStar = 0;
  totalNodesVisitedDStar = 0;
  isAnimating = false;
  currentPathIndex = 0;
  currentVisitedIndex = 0;
  currentPhase = AnimationPhase.EXPLORING;
}

void startSimulation() {
  // Grid'lerin açık bir yolu olmasını garantile
  ensurePathExists();
  
  // A* algoritmasını çalıştır
  visitedNodesAStar.clear();
  visitedNodesAStarOrdered.clear();
  aStarSteps = 0;
  long startTimeAStar = System.currentTimeMillis();
  pathAStar = findPathAStar(visitedNodesAStar, visitedNodesAStarOrdered);
  long endTimeAStar = System.currentTimeMillis();
  comparisonStats.put("A*_time", (double)(endTimeAStar - startTimeAStar));
  comparisonStats.put("A*_path_length", (double)pathAStar.size());
  totalNodesVisitedAStar = visitedNodesAStar.size();
  
  // D* algoritmasını çalıştır
  visitedNodesDStar.clear();
  visitedNodesDStarOrdered.clear();
  dStarSteps = 0;
  long startTimeDStar = System.currentTimeMillis();
  pathDStar = findPathDStar(visitedNodesDStar, visitedNodesDStarOrdered);
  long endTimeDStar = System.currentTimeMillis();
  comparisonStats.put("D*_time", (double)(endTimeDStar - startTimeDStar));
  comparisonStats.put("D*_path_length", (double)pathDStar.size());
  totalNodesVisitedDStar = visitedNodesDStar.size();
  
  // Eğer yollar çok kısaysa, animasyon hızını düzenle
  animationSpeed = 50; // Varsayılan hız
  int maxNodes = Math.max(visitedNodesAStarOrdered.size(), visitedNodesDStarOrdered.size());
  int maxPath = Math.max(pathAStar.size(), pathDStar.size());
  
  if (maxNodes > 300) {
    animationSpeed = 10; // Daha hızlı
  } else if (maxNodes < 50) {
    animationSpeed = 100; // Daha yavaş
  }
  
  isAnimating = true;
  currentPhase = AnimationPhase.EXPLORING;
  currentVisitedIndex = 0;
  currentPathIndex = 0;
  lastAnimationTime = millis();
  
  println("Yollar başarıyla bulundu!");
  println("A* Yol Uzunluğu: " + pathAStar.size() + ", D* Yol Uzunluğu: " + pathDStar.size());
  println("A* Ziyaret Edilen Düğümler: " + totalNodesVisitedAStar + ", D* Ziyaret Edilen Düğümler: " + totalNodesVisitedDStar);
}

List<Node> findPathAStar(Set<Node> visitedNodes, List<Node> visitedOrdered) {
  PriorityQueue<Node> openSet = new PriorityQueue<Node>((a, b) -> Double.compare(a.f, b.f));
  Map<String, Node> openSetMap = new HashMap<>(); // Hızlı erişim için
  Set<String> closedSet = new HashSet<String>();
  Map<String, Node> cameFrom = new HashMap<String, Node>();
  Map<String, Double> gScore = new HashMap<String, Double>();
  
  Node start = new Node(startNode.x, startNode.y);
  Node end = new Node(endNode.x, endNode.y);
  
  start.g = 0;
  start.h = heuristic(start, end);
  start.f = start.g + start.h;
  
  String startKey = nodeToKey(start);
  openSet.add(start);
  openSetMap.put(startKey, start);
  gScore.put(startKey, Double.valueOf(0.0));
  
  int steps = 0;
  int maxSteps = GRID_SIZE * GRID_SIZE * 4; // Sonsuz döngü önlemi
  
  while (!openSet.isEmpty() && steps < maxSteps) {
    steps++;
    Node current = openSet.poll();
    String currentKey = nodeToKey(current);
    openSetMap.remove(currentKey);
    
    if (!visitedNodes.contains(current)) {
      visitedNodes.add(current);
      visitedOrdered.add(current);
    }
    
    if (current.equals(end)) {
      aStarSteps = steps;
      return reconstructPath(cameFrom, current);
    }
    
    closedSet.add(currentKey);
    
    for (Node neighbor : getNeighbors(current)) {
      String neighborKey = nodeToKey(neighbor);
      
      if (closedSet.contains(neighborKey)) continue;
      
      double tentativeGScore = gScore.getOrDefault(currentKey, Double.MAX_VALUE) + 1.0;
      
      Node existingNeighbor = openSetMap.get(neighborKey);
      if (existingNeighbor == null) {
        // Düğüm daha önce görülmemiş
        gScore.put(neighborKey, tentativeGScore);
        neighbor.g = tentativeGScore;
        neighbor.h = heuristic(neighbor, end);
        neighbor.f = neighbor.g + neighbor.h;
        neighbor.parent = current;
        
        openSet.add(neighbor);
        openSetMap.put(neighborKey, neighbor);
        cameFrom.put(neighborKey, current);
      } else if (tentativeGScore < gScore.getOrDefault(neighborKey, Double.MAX_VALUE)) {
        // Daha iyi bir yol bulundu
        gScore.put(neighborKey, tentativeGScore);
        existingNeighbor.g = tentativeGScore;
        existingNeighbor.f = existingNeighbor.g + existingNeighbor.h;
        existingNeighbor.parent = current;
        cameFrom.put(neighborKey, current);
        
        // Önceliği güncelle (PriorityQueue'da update işlemi)
        openSet.remove(existingNeighbor);
        openSet.add(existingNeighbor);
      }
    }
  }
  
  // Yol bulunamadıysa, en azından başlangıç noktasını içeren bir yol döndür
  aStarSteps = steps;
  if (visitedNodes.size() > 0) {
    List<Node> singleNodePath = new ArrayList<Node>();
    singleNodePath.add(start);
    println("A* yol bulunamadı, sadece başlangıç noktası döndürülüyor. Adım sayısı: " + steps);
    return singleNodePath;
  }
  
  return new ArrayList<Node>();
}

List<Node> findPathDStar(Set<Node> visitedNodes, List<Node> visitedOrdered) {
  PriorityQueue<Node> openSet = new PriorityQueue<Node>((a, b) -> Double.compare(a.f, b.f));
  Map<String, Node> openSetMap = new HashMap<>(); // Hızlı erişim için
  Set<String> closedSet = new HashSet<String>();
  Map<String, Node> cameFrom = new HashMap<String, Node>();
  Map<String, Double> gScore = new HashMap<String, Double>();
  
  // D* algoritmasında bitiş noktasından başlarız
  Node tempStart = new Node(endNode.x, endNode.y);
  Node tempEnd = new Node(startNode.x, startNode.y);
  
  tempStart.g = 0;
  tempStart.h = heuristic(tempStart, tempEnd);
  tempStart.f = tempStart.g + tempStart.h;
  
  String startKey = nodeToKey(tempStart);
  openSet.add(tempStart);
  openSetMap.put(startKey, tempStart);
  gScore.put(startKey, Double.valueOf(0.0));
  
  int steps = 0;
  int maxSteps = GRID_SIZE * GRID_SIZE * 4; // Sonsuz döngü önlemi
  
  while (!openSet.isEmpty() && steps < maxSteps) {
    steps++;
    Node current = openSet.poll();
    String currentKey = nodeToKey(current);
    openSetMap.remove(currentKey);
    
    if (!visitedNodes.contains(current)) {
      visitedNodes.add(current);
      visitedOrdered.add(current);
    }
    
    if (current.equals(tempEnd)) {
      dStarSteps = steps;
      
      // Yolu tersine çevir (D* bitiş noktasından başlangıca doğru arama yapar)
      List<Node> reversedPath = reconstructPath(cameFrom, current);
      List<Node> forwardPath = new ArrayList<Node>();
      
      // Yolu tekrar düzelt (başlangıçtan hedefe doğru)
      for (int i = reversedPath.size() - 1; i >= 0; i--) {
        Node node = reversedPath.get(i);
        forwardPath.add(new Node(node.x, node.y));
      }
      
      return forwardPath;
    }
    
    closedSet.add(currentKey);
    
    for (Node neighbor : getNeighbors(current)) {
      String neighborKey = nodeToKey(neighbor);
      
      if (closedSet.contains(neighborKey)) continue;
      
      double tentativeGScore = gScore.getOrDefault(currentKey, Double.MAX_VALUE) + 1.0;
      
      Node existingNeighbor = openSetMap.get(neighborKey);
      if (existingNeighbor == null) {
        // Düğüm daha önce görülmemiş
        gScore.put(neighborKey, tentativeGScore);
        neighbor.g = tentativeGScore;
        neighbor.h = heuristic(neighbor, tempEnd);
        neighbor.f = neighbor.g + neighbor.h;
        neighbor.parent = current;
        
        openSet.add(neighbor);
        openSetMap.put(neighborKey, neighbor);
        cameFrom.put(neighborKey, current);
      } else if (tentativeGScore < gScore.getOrDefault(neighborKey, Double.MAX_VALUE)) {
        // Daha iyi bir yol bulundu
        gScore.put(neighborKey, tentativeGScore);
        existingNeighbor.g = tentativeGScore;
        existingNeighbor.f = existingNeighbor.g + existingNeighbor.h;
        existingNeighbor.parent = current;
        cameFrom.put(neighborKey, current);
        
        // Önceliği güncelle
        openSet.remove(existingNeighbor);
        openSet.add(existingNeighbor);
      }
    }
  }
  
  // Yol bulunamadıysa, en azından bitiş noktasını içeren bir yol döndür
  dStarSteps = steps;
  if (visitedNodes.size() > 0) {
    List<Node> singleNodePath = new ArrayList<Node>();
    singleNodePath.add(tempStart);
    println("D* yol bulunamadı, sadece bitiş noktası döndürülüyor. Adım sayısı: " + steps);
    return singleNodePath;
  }
  
  return new ArrayList<Node>();
}

double heuristic(Node a, Node b) {
  return abs(a.x - b.x) + abs(a.y - b.y);
}

List<Node> getNeighbors(Node node) {
  List<Node> neighbors = new ArrayList<Node>();
  int[][] directions = {{-1,0}, {1,0}, {0,-1}, {0,1}};
  
  for (int[] dir : directions) {
    int newX = node.x + dir[0];
    int newY = node.y + dir[1];
    
    if (newX >= 0 && newX < GRID_SIZE && newY >= 0 && newY < GRID_SIZE && grid[newX][newY] == 0) {
      neighbors.add(new Node(newX, newY));
    }
  }
  
  return neighbors;
}

List<Node> reconstructPath(Map<String, Node> cameFrom, Node current) {
  List<Node> path = new ArrayList<Node>();
  path.add(current);
  
  String currentKey = nodeToKey(current);
  while (cameFrom.containsKey(currentKey)) {
    current = cameFrom.get(currentKey);
    path.add(0, current);
    currentKey = nodeToKey(current);
  }
  
  return path;
}

void generateComparisonReport() {
  println("\n=== Algoritma Karşılaştırma Raporu ===");
  println("Grid Boyutu: " + GRID_SIZE + "x" + GRID_SIZE);
  println("Engel Oranı: %30");
  
  // Güvenli şekilde değerlere eriş
  double aStarTime = 0.0;
  double dStarTime = 0.0;
  double aStarLength = 0.0; 
  double dStarLength = 0.0;
  
  if (comparisonStats.containsKey("A*_time")) {
    aStarTime = comparisonStats.get("A*_time");
  }
  
  if (comparisonStats.containsKey("D*_time")) {
    dStarTime = comparisonStats.get("D*_time");
  }
  
  if (comparisonStats.containsKey("A*_path_length")) {
    aStarLength = comparisonStats.get("A*_path_length");
  }
  
  if (comparisonStats.containsKey("D*_path_length")) {
    dStarLength = comparisonStats.get("D*_path_length");
  }
  
  println("\nA* Algoritması:");
  println("Çalışma Süresi: " + aStarTime + " ms");
  println("Yol Uzunluğu: " + aStarLength + " adım");
  println("Ziyaret Edilen Düğüm Sayısı: " + totalNodesVisitedAStar);
  
  println("\nD* Algoritması:");
  println("Çalışma Süresi: " + dStarTime + " ms");
  println("Yol Uzunluğu: " + dStarLength + " adım");
  println("Ziyaret Edilen Düğüm Sayısı: " + totalNodesVisitedDStar);
  
  // Performans karşılaştırması
  double timeDiff = dStarTime - aStarTime;
  double pathDiff = dStarLength - aStarLength;
  double visitedDiff = totalNodesVisitedDStar - totalNodesVisitedAStar;
  
  println("\nKarşılaştırma Sonuçları:");
  println("Hız Farkı: " + (timeDiff > 0 ? "A* " + timeDiff + " ms daha hızlı" : "D* " + (-timeDiff) + " ms daha hızlı"));
  println("Yol Uzunluğu Farkı: " + (pathDiff > 0 ? "A* " + pathDiff + " adım daha kısa" : "D* " + (-pathDiff) + " adım daha kısa"));
  println("Ziyaret Edilen Düğüm Farkı: " + (visitedDiff > 0 ? "A* " + visitedDiff + " daha az düğüm ziyaret etti" : "D* " + (-visitedDiff) + " daha az düğüm ziyaret etti"));
}

void drawLegend(String algorithmName, int xOffset) {
  fill(0);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Başlangıç (Yeşil)", xOffset + 10, 10);
  text("Bitiş (Kırmızı)", xOffset + 10, 30);
  text("Engeller (Siyah)", xOffset + 10, 50);
  text("Ziyaret Edilen Düğümler (" + (algorithmName.equals("A*") ? "Açık Mavi" : "Açık Mor") + ")", xOffset + 10, 70);
  text("Bulunan Yol (" + (algorithmName.equals("A*") ? "Mavi" : "Mor") + ")", xOffset + 10, 90);
  text("Algoritma: " + algorithmName, xOffset + 10, 110);
  if (isAnimating) {
    text("Animasyon Devam Ediyor...", xOffset + 10, 130);
  }
}

// Node'un PriorityQueue içinde olup olmadığını kontrol eder
boolean containsNode(PriorityQueue<Node> queue, Node node) {
  for (Node n : queue) {
    if (n.equals(node)) {
      return true;
    }
  }
  return false;
}

// Node'u benzersiz bir anahtar stringine dönüştür
String nodeToKey(Node node) {
  return node.x + "," + node.y;
}

class Node {
  int x, y;
  double g, h, f;
  Node parent;
  
  Node(int x, int y) {
    this.x = x;
    this.y = y;
    g = 0;
    h = 0;
    f = 0;
  }
  
  @Override
  public boolean equals(Object obj) {
    if (obj instanceof Node) {
      Node other = (Node) obj;
      return this.x == other.x && this.y == other.y;
    }
    return false;
  }
  
  @Override
  public int hashCode() {
    // x ve y değerlerinden benzersiz bir hash kodu oluştur
    return x * 31 + y;
  }
}

// Yardımcı fonksiyon: Tüm ziyaret edilen düğümler içinde bir düğümün indeksini bul
int findIndexInVisited(Node node, List<Node> visitedNodes) {
  for (int i = 0; i < visitedNodes.size(); i++) {
    if (node.equals(visitedNodes.get(i))) {
      return i;
    }
  }
  return -1;
}

// Yardımcı fonksiyon: İki nokta arasındaki yolun açık olup olmadığını kontrol et
boolean hasDirectPath(Node a, Node b) {
  // Düz çizgi çizerek engelleri kontrol et
  int x0 = a.x;
  int y0 = a.y;
  int x1 = b.x;
  int y1 = b.y;
  
  int dx = abs(x1 - x0);
  int dy = abs(y1 - y0);
  int sx = x0 < x1 ? 1 : -1;
  int sy = y0 < y1 ? 1 : -1;
  int err = dx - dy;
  
  while (x0 != x1 || y0 != y1) {
    if (x0 >= 0 && x0 < GRID_SIZE && y0 >= 0 && y0 < GRID_SIZE) {
      if (grid[x0][y0] == 1) {
        return false; // Engel var
      }
    } else {
      return false; // Grid dışına çıkıldı
    }
    
    int e2 = 2 * err;
    if (e2 > -dy) {
      err -= dy;
      x0 += sx;
    }
    if (e2 < dx) {
      err += dx;
      y0 += sy;
    }
  }
  
  return true;
} 
