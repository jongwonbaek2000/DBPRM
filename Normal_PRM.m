%TIME_TEST에서 시간 재기위해서, 주석 처리한 부분 있음. PLOT을 보고 싶다면, Normal_PRM_PLOT.m을 참고하기 바람.



tic;


image = imread('study_map.png');

grayimage = rgb2gray(image);
bwimage = grayimage < 0.5; % 흰색 영역을 장애물로 설정

grid = binaryOccupancyMap(bwimage);

% 시작점과 도착점 설정
startLocation = [500, 500];
endLocation = [3859, 3745];

% PRM 알고리즘을 직접 구현
numNodes = 1000; % PRM 알고리즘의 노드 수 설정
prmConnectionDistance = 400; % PRM 알고리즘의 연결 거리 설정
nodes = [];
nodes = [nodes;startLocation; endLocation]; % 시작점과 도착점을 노드로 추가



% 장애물이 없는 영역과 CircleMap에서 1(군집화된 영역)과 0(비군집화된 영역)의 좌표 추출
[free_areas_row, free_areas_col] = find(bwimage == 0);

%노드 생성
indices = randperm(length(free_areas_row), numNodes); % 랜덤으로 인덱스 선택
randoms=  [free_areas_row(indices), free_areas_col(indices)];
nodes = [nodes; randoms]; % 랜덤으로 선택된 좌표



% 모든 노드 간의 연결을 확인하여 간선 추가
edges = [];
for i = 1:size(nodes, 1)
    for j = (i + 1):size(nodes, 1)
        distance = norm(nodes(i, :) - nodes(j, :));

        if distance < prmConnectionDistance % 수정된 부분
            path_points = [round(linspace(nodes(i, 1), nodes(j, 1), 20)'), round(linspace(nodes(i, 2), nodes(j, 2), 20)')];

            if all(arrayfun(@(x) is_collision_free(path_points(x, :), bwimage), 1:size(path_points, 1)))    
                edges = [edges; i, j, distance];

            end
            
        end


        %{
        if distance < prmConnectionDistance && any(is_edge_free(nodes(i, :), nodes(j, :), bwimage)) % 수정된 부분
            
        end
        %}

    end
end

% 시작점과 도착점 사이의 최적 경로 찾기
path = find_shortest_path(nodes, edges, startLocation, endLocation);

disp(path);

% PRM 결과 시각화
success = plot_prm(nodes, edges, startLocation, endLocation, bwimage, path);

osp = getOccupancy(grid);
disp(['time :', num2str(toc)]);

% 주행 경로의 총합을 계산
total_distance = 0;
for i = 1:(size(path, 1) - 1)
    current_point = path(i, :);
    next_point = path(i + 1, :);
    distance = sqrt(sum((next_point - current_point) .^ 2));
    total_distance = total_distance + distance;
end
disp(total_distance);
% 계산된 총 거리를 MAT 파일로 저장
%save('total_distance_Normal_PRM.mat', 'total_distance_Normal_PRM');






% 장애물과의 충돌 여부 확인 함수
function collision_free = is_collision_free(point, image)
    collision_free = image(point(1), point(2)) == 0; % 흰색 부분이면 충돌이 없음
end





% 최단 경로 찾기 함수
function path = find_shortest_path(nodes, edges, start, goal)
    % 그래프 생성
    G = graph(edges(:, 1), edges(:, 2), edges(:, 3));
    % 시작점과 도착점 인덱스 찾기
    start_index = nearest_node_index(nodes, start);
    goal_index = nearest_node_index(nodes, goal);
    % 최단 경로 찾기
    path_indices = shortestpath(G, start_index, goal_index);
    % 인덱스를 좌표로 변환
    path = nodes(path_indices, :);
end

% 가장 가까운 노드의 인덱스 찾기 함수
function index = nearest_node_index(nodes, point)
    distances = sum((nodes - point).^2, 2);
    [~, index] = min(distances);
end

% PRM 결과 시각화 함수
function success = plot_prm(nodes, edges, start, goal, image, path)
    %figure;
    %imshow(~image);
    hold on;
    % 노드 표시
    %scatter(nodes(:, 2), nodes(:, 1), 'b', 'filled'); % 행과 열의 순서 변경
    % 시작점과 도착점 표시
    %scatter(start(2), start(1), 'r', 'filled'); % 행과 열의 순서 변경
    %scatter(goal(2), goal(1), 'g', 'filled'); % 행과 열의 순서 변경
    % 간선 표시
    for i = 1:size(edges, 1)
        %plot([nodes(edges(i, 1), 2), nodes(edges(i, 2), 2)], [nodes(edges(i, 1), 1), nodes(edges(i, 2), 1)], 'k'); % 행과 열의 순서 변경
    end
    % 최단 경로 표시
    if ~isempty(path)
        %plot(path(:, 2), path(:, 1), 'r', 'LineWidth', 2); % 행과 열의 순서 변경
        success = 1;
    else 
        success = 0;
    end
    
    hold off;
    title('PRM 알고리즘 결과 시각화');
end
