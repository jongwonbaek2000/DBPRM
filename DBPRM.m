%TIME_TEST에서 시간 재기위해서, 주석 처리한 부분 있음. PLOT을 보고 싶다면, DBPRM_PLOT.m을 참고하기 바람.


tic; % 타이머 시작
load("DensityBasedMap.mat"); % CircleMap 데이터 로드

image = imread('study_map.png'); % 지도 이미지 로드
grayimage = rgb2gray(image); % 이미지를 회색조로 변환
bwimage = grayimage < 0.5; % 흰색 영역을 장애물로 설정 (장애물 = 1, 자유공간 = 0)

% 이진 점유 그리드 맵 생성
occupancy_grid = binaryOccupancyMap(bwimage);

% 장애물이 없는 영역과 CircleMap에서 1(군집화된 영역)과 0(비군집화된 영역)의 좌표 추출
[free_areas_row, free_areas_col] = find(bwimage == 0);
[clustered_areas_row, clustered_areas_col] = find(DensityBasedMap == 1); 
[non_clustered_areas_row, non_clustered_areas_col] = find(DensityBasedMap == 0);

% 시작점과 목표점 설정
start_point = [500, 500];
goal_point = [3859, 3745];

% PRM 알고리즘 설정
total_nodes = 1000; % 전체 노드 수
non_clustered_portion = 0.1; % 비군집화된 영역에 할당할 노드 비율
connection_dist_non_clustered = 300; % 비군집화된 영역의 연결 거리
connection_dist_clustered = 400; % 군집화된 영역의 연결 거리

nodes = [start_point; goal_point]; % 시작점과 목표점을 노드 리스트에 추가

% 군집화된 영역과 비군집화된 영역의 노드 수 계산
nodes_non_clustered = round(non_clustered_portion * total_nodes);
nodes_clustered = total_nodes - nodes_non_clustered;

% 군집화된 영역의 노드 생성
clustered_nodes = create_random_nodes(clustered_areas_row, clustered_areas_col, bwimage, nodes_clustered);
nodes = [nodes; clustered_nodes];

% 비군집화된 영역의 노드 생성
non_clustered_nodes = create_random_nodes(non_clustered_areas_row, non_clustered_areas_col, bwimage, nodes_non_clustered);
nodes = [nodes; non_clustered_nodes];

% CircleMap을 기반으로 각 노드의 연결 거리 계산
connection_distances = calculate_connection_distances(DensityBasedMap, nodes, connection_dist_clustered, connection_dist_non_clustered);

% 간선 생성 및 최적 경로 계산
[edges, optimal_path] = create_edges_and_find_path(nodes, connection_distances, bwimage, start_point, goal_point);

% 결과 시각화
success = plot_prm(nodes, edges, start_point, goal_point, bwimage, optimal_path);
disp(['Time:', num2str(toc)]); % 실행 시간 출력

% 주행 경로의 총합을 계산
total_distance = 0;
for i = 1:(size(optimal_path, 1) - 1)
    current_point = optimal_path(i, :);
    next_point = optimal_path(i + 1, :);
    distance = sqrt(sum((next_point - current_point) .^ 2));
    total_distance = total_distance + distance;
end
disp(total_distance);
% 계산된 총 거리를 MAT 파일로 저장
%save('total_distance_DBPRM.mat', 'total_distance_DBPRM');




% 필요한 함수들을 여기에 정의 ...
% 장애물과의 충돌 여부 확인 함수
function is_free = is_collision_free(point, image)
    % 이미지에서 지정된 포인트가 자유 공간인지 확인 (장애물이 없으면 참)
    is_free = image(point(1), point(2)) == 0; 
end

% 최단 경로 찾기 함수
function path = find_shortest_path(nodes, edges, start, goal)
    % PRM 그래프 생성
    G = graph(edges(:, 1), edges(:, 2), edges(:, 3));
    
    % 시작점과 목표점에 가장 가까운 노드 인덱스 찾기
    start_idx = nearest_node_index(nodes, start);
    goal_idx = nearest_node_index(nodes, goal);
    
    % 시작점과 목표점 사이의 최단 경로 찾기
    path_indices = shortestpath(G, start_idx, goal_idx);
    
    % 경로 인덱스를 좌표로 변환
    path = nodes(path_indices, :);
end

% 가장 가까운 노드의 인덱스 찾기 함수
function index = nearest_node_index(nodes, point)
    % 모든 노드와 지정된 포인트 사이의 거리 계산
    distances = sum((nodes - point).^2, 2);
    
    % 가장 가까운 노드의 인덱스 찾기
    [~, index] = min(distances);
end



% 노드를 생성하는 함수 (여기서는 임의의 좌표를 선택하는 로직을 사용합니다)
function random_nodes = create_random_nodes(row_coords, col_coords, image, num_nodes)
    random_nodes = zeros(num_nodes, 2); % 초기화
    count = 0;
    numPoints = size(row_coords, 1);

    while count < num_nodes
        idx = randi(numPoints);
        x = row_coords(idx);
        y = col_coords(idx);

        if image(x, y) == 0 % 장애물이 없는 지역인지 확인
            count = count + 1;
            random_nodes(count, :) = [x, y];
        end
    end
end

% 각 노드의 연결 거리 계산 함수
function connection_distances = calculate_connection_distances(DensityBasedMap, nodes, dist_clustered, dist_non_clustered)
    DensityBasedMap_values = DensityBasedMap(sub2ind(size(DensityBasedMap), nodes(:, 1), nodes(:, 2)));
    connection_distances = zeros(size(DensityBasedMap_values));
    connection_distances(DensityBasedMap_values == 1) = dist_clustered; % 군집화된 영역의 연결 거리
    connection_distances(DensityBasedMap_values == 0) = dist_non_clustered; % 비군집화된 영역의 연결 거리
    connection_distances(DensityBasedMap_values ~= 0 & DensityBasedMap_values ~= 1) = (dist_clustered + dist_non_clustered) / 2; % 혼합 영역의 연결 거리
end

% 간선 생성 및 최적 경로 계산 함수
function [edges, path] = create_edges_and_find_path(nodes, connection_distances, image, start, goal)
    num_nodes = size(nodes, 1);
    edges = []; % 간선 목록 초기화
    distances = squareform(pdist(nodes)); % 모든 노드 쌍 사이의 거리 계산

    for i = 1:num_nodes-1
        for j = i+1:num_nodes
            if distances(i, j) < connection_distances(i)
                % 두 노드 사이의 선형 경로를 20개 점으로 나누어 장애물 확인
                path_points_x = round(linspace(nodes(i, 1), nodes(j, 1), 20)');
                path_points_y = round(linspace(nodes(i, 2), nodes(j, 2), 20)');
                path_points = [path_points_x, path_points_y];

                if all(arrayfun(@(k) is_collision_free(path_points(k, :), image), 1:size(path_points, 1)))
                    edges = [edges; i, j, distances(i, j)]; % 간선 추가
                end
            end
        end
    end

    % 최단 경로 찾기
    path = find_shortest_path(nodes, edges, start, goal);
end

% PRM 결과 시각화 함수
function success = plot_prm(nodes, edges, start, goal, image, path)
    %figure;
    %imshow(~image); % 이미지 반전하여 표시 (장애물은 밝게, 자유 공간은 어둡게)
    hold on;
    
    % 노드 위치에 파란색 점으로 표시
    %scatter(nodes(:, 2), nodes(:, 1), 'b', 'filled');
    
    % 시작점과 목표점을 각각 빨간색, 녹색 점으로 표시
    %scatter(start(2), start(1), 'r', 'filled');
    %scatter(goal(2), goal(1), 'g', 'filled');
    
    % 모든 간선을 검은색 선으로 표시
    for i = 1:size(edges, 1)
        %plot([nodes(edges(i, 1), 2), nodes(edges(i, 2), 2)], [nodes(edges(i, 1), 1), nodes(edges(i, 2), 1)], 'k');
    end
    
    % 최단 경로를 빨간색 굵은 선으로 표시
    if ~isempty(path)
        %plot(path(:, 2), path(:, 1), 'r', 'LineWidth', 2);
        success = 1;
    else 
        success = 0;
    end
    
    hold off;
    title('PRM 알고리즘 결과 시각화');
end
