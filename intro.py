import heapq
import numpy as np
import matplotlib.pyplot as plt
import time

def heuristic(a, b):
    """Manhattan uzaklığı hesaplama"""
    return abs(a[0] - b[0]) + abs(a[1] - b[1])

def create_maze(size, p_wall=0.2):
    """Çözülebilir labirent oluşturma"""
    # Daha az duvar ile başla
    maze = np.random.choice([0, 1], size=(size, size), p=[1-p_wall, p_wall])
    
    # Başlangıç ve bitiş noktalarını ve çevrelerini temizle
    maze[0:2, 0:2] = 0
    maze[-2:, -2:] = 0
    
    # Köşegen boyunca yol oluştur (garanti çözüm için)
    for i in range(size):
        maze[i, i] = 0
        if i < size-1:
            maze[i, i+1] = maze[i+1, i] = 0
    
    # Ek yollar ekle
    for i in range(1, size-1):
        if np.random.random() < 0.6:
            maze[i, :] = np.minimum(maze[i, :], np.random.choice([0, 1], size=size, p=[0.8, 0.2]))
        if np.random.random() < 0.6:
            maze[:, i] = np.minimum(maze[:, i], np.random.choice([0, 1], size=size, p=[0.8, 0.2]))
    
    return maze

class PathFinder:
    """Yol bulma algoritmaları sınıfı"""
    def __init__(self, maze, start, goal):
        self.maze = maze
        self.start = start
        self.goal = goal
        self.rows, self.cols = maze.shape
        self.directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    def is_valid(self, pos):
        """Geçerli pozisyon kontrolü"""
        x, y = pos
        return (0 <= x < self.rows and 
                0 <= y < self.cols and 
                self.maze[x, y] == 0)

    def get_path(self, came_from, current):
        """Yol oluşturma"""
        path = []
        while current in came_from:
            path.append(current)
            current = came_from[current]
        path.append(self.start)
        return path[::-1]

    def a_star(self):
        """A* algoritması implementasyonu"""
        pq = [(0, self.start)]
        came_from = {self.start: None}
        cost_so_far = {self.start: 0}
        nodes_visited = 0
        
        while pq:
            _, current = heapq.heappop(pq)
            nodes_visited += 1
            
            if current == self.goal:
                path = self.get_path(came_from, current)
                return path, nodes_visited
            
            for dx, dy in self.directions:
                neighbor = (current[0] + dx, current[1] + dy)
                if self.is_valid(neighbor):
                    new_cost = cost_so_far[current] + 1
                    if neighbor not in cost_so_far or new_cost < cost_so_far[neighbor]:
                        cost_so_far[neighbor] = new_cost
                        priority = new_cost + heuristic(neighbor, self.goal)
                        heapq.heappush(pq, (priority, neighbor))
                        came_from[neighbor] = current
        
        return [], nodes_visited

    def dijkstra(self):
        """Dijkstra algoritması implementasyonu"""
        pq = [(0, self.start)]
        came_from = {self.start: None}
        cost_so_far = {self.start: 0}
        nodes_visited = 0
        
        while pq:
            _, current = heapq.heappop(pq)
            nodes_visited += 1
            
            if current == self.goal:
                path = self.get_path(came_from, current)
                return path, nodes_visited
            
            for dx, dy in self.directions:
                neighbor = (current[0] + dx, current[1] + dy)
                if self.is_valid(neighbor):
                    new_cost = cost_so_far[current] + 1
                    if neighbor not in cost_so_far or new_cost < cost_so_far[neighbor]:
                        cost_so_far[neighbor] = new_cost
                        heapq.heappush(pq, (new_cost, neighbor))
                        came_from[neighbor] = current
        
        return [], nodes_visited

def run_multiple_comparisons(maze_count=10, maze_size=30):
    """10 farklı labirent üzerinde karşılaştırmalı test yap"""
    # Sonuçları saklamak için listeler
    results = []
    
    # Ana figür oluştur
    fig = plt.figure(figsize=(20, maze_count * 4))
    plt.suptitle('A* ve Dijkstra Algoritmalarının 10 Farklı Labirentte Karşılaştırması', 
                 fontsize=16, y=0.99)
    
    for i in range(maze_count):
        print(f"\nLabirent {i+1}/{maze_count} test ediliyor...")
        
        # Labirent oluştur ve test et
        maze = create_maze(maze_size)
        finder = PathFinder(maze, (0,0), (maze_size-1,maze_size-1))
        
        # A* algoritması
        start_time = time.time()
        path_astar, nodes_astar = finder.a_star()
        time_astar = time.time() - start_time
        
        # Dijkstra algoritması
        start_time = time.time()
        path_dijkstra, nodes_dijkstra = finder.dijkstra()
        time_dijkstra = time.time() - start_time
        
        # Her labirent için subplot oluştur
        ax1 = plt.subplot2grid((maze_count, 3), (i, 0))
        ax2 = plt.subplot2grid((maze_count, 3), (i, 1))
        ax3 = plt.subplot2grid((maze_count, 3), (i, 2))
        
        # Labirenti göster
        ax1.imshow(maze, cmap='gray_r')
        ax1.set_title(f'Labirent {i+1}')
        
        # A* sonuçları
        ax2.imshow(maze, cmap='gray_r')
        if path_astar:
            path = np.array(path_astar)
            ax2.plot(path[:, 1], path[:, 0], 'b-', linewidth=2)
        ax2.set_title(f'A*: {nodes_astar} düğüm, {time_astar*1000:.1f}ms')
        
        # Dijkstra sonuçları
        ax3.imshow(maze, cmap='gray_r')
        if path_dijkstra:
            path = np.array(path_dijkstra)
            ax3.plot(path[:, 1], path[:, 0], 'y-', linewidth=2)
        ax3.set_title(f'Dijkstra: {nodes_dijkstra} düğüm, {time_dijkstra*1000:.1f}ms')
        
        # Sonuçları kaydet
        results.append({
            'maze': maze,
            'astar_path': path_astar,
            'dijkstra_path': path_dijkstra,
            'astar_nodes': nodes_astar,
            'dijkstra_nodes': nodes_dijkstra,
            'astar_time': time_astar,
            'dijkstra_time': time_dijkstra
        })
    
    plt.tight_layout()
    plt.savefig('10_labirent_karsilastirma.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    # İstatistiksel analiz
    print("\nİstatistiksel Analiz:")
    print("-" * 60)
    print(f"{'Metrik':<20} {'A* (Ortalama)':^20} {'Dijkstra (Ortalama)':^20}")
    print("-" * 60)
    
    avg_astar_nodes = np.mean([r['astar_nodes'] for r in results])
    avg_dijkstra_nodes = np.mean([r['dijkstra_nodes'] for r in results])
    avg_astar_time = np.mean([r['astar_time'] for r in results])
    avg_dijkstra_time = np.mean([r['dijkstra_time'] for r in results])
    avg_astar_path = np.mean([len(r['astar_path']) for r in results])
    avg_dijkstra_path = np.mean([len(r['dijkstra_path']) for r in results])
    
    print(f"{'Yol Uzunluğu':<20} {avg_astar_path:^20.2f} {avg_dijkstra_path:^20.2f}")
    print(f"{'Ziyaret Edilen':<20} {avg_astar_nodes:^20.2f} {avg_dijkstra_nodes:^20.2f}")
    print(f"{'Süre (ms)':<20} {avg_astar_time*1000:^20.2f} {avg_dijkstra_time*1000:^20.2f}")
    print("-" * 60)
    
    # Performans karşılaştırma grafiği
    plt.figure(figsize=(12, 6))
    metrics = ['Yol Uzunluğu', 'Ziyaret Edilen\nDüğüm', 'Süre (ms)']
    astar_avgs = [avg_astar_path, avg_astar_nodes, avg_astar_time*1000]
    dijkstra_avgs = [avg_dijkstra_path, avg_dijkstra_nodes, avg_dijkstra_time*1000]
    
    x = np.arange(len(metrics))
    width = 0.35
    
    plt.bar(x - width/2, astar_avgs, width, label='A*', color='blue', alpha=0.6)
    plt.bar(x + width/2, dijkstra_avgs, width, label='Dijkstra', color='yellow', alpha=0.6)
    
    plt.ylabel('Ortalama Değer')
    plt.title('Algoritmaların Ortalama Performans Karşılaştırması')
    plt.xticks(x, metrics)
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('performans_karsilastirma.png', dpi=300, bbox_inches='tight')
    plt.show()

if __name__ == "__main__":
    np.random.seed(42)  # Tekrarlanabilirlik için
    run_multiple_comparisons()