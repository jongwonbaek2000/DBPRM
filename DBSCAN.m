tic; % 타이머 시작
epsilon = 140; % 군집화에 사용될 이웃 반경 (ε)
minPts = 20; % 최소 포인트 수, 이 값으로 군집의 최소 크기 결정

% DBSCAN 알고리즘을 사용하여 밀도 기반의 장애물 영역 군집화
ypixel = 4525; % y-좌표 상한값
occupancy_data = getOccupancy(grid); % 점유 그리드에서 데이터 추출
[y, x] = find(occupancy_data); % 장애물 있는 위치의 좌표 추출
data = [x, ypixel - y]; % 장애물 데이터 정리

% 데이터의 일부 샘플링
data_sampled_indices = datasample(1:size(data, 1), round(0.001 * size(data, 1)), 'Replace', false);
data_sampled = data(data_sampled_indices, :); % 샘플링된 데이터 추출

% DBSCAN 알고리즘 실행
[clusters, ~] = dbscan(data_sampled, epsilon, minPts);

% 각 군집의 중심점 계산
numClusters = max(clusters); % 군집 수
clusterCenters = zeros(numClusters, 2); % 각 군집의 중심점 저장
for i = 1:numClusters
    clusterPoints = data_sampled(clusters == i, :);
    clusterCenters(i, :) = mean(clusterPoints); % 각 군집의 평균 좌표(중심점) 계산
end

% 군집의 경계 영역을 원으로 시각화하고 저장
figure;
%xlim([-500 5000]);  % x축 범위 설정
%ylim([-500 5000]);  % y축 범위 설정
xlim([0 4525]);  % x축 범위 설정
ylim([0 4525]);  % y축 범위 설정
set(gcf, 'Position', [500, 100, 600, 570]); % [x, y, width, height]
hold on;
colors = lines(numClusters); % 군집마다 다른 색상 할당
non_clustered_points = data_sampled(clusters == -1, :);
scatter(non_clustered_points(:, 1), non_clustered_points(:, 2), 20, [0.5, 0.5, 0.5], 'filled'); % 군집되지 않은 데이터 표시
radius_s = [];
for i = 1:numClusters
    clusterPoints = data_sampled(clusters == i, :);
    scatter(clusterPoints(:, 1), clusterPoints(:, 2), 20, colors(i, :), 'filled'); % 군집화된 데이터 표시

    % 각 군집의 중심점과 원 그리기
    plot(clusterCenters(i, 1), clusterCenters(i, 2), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(i, :));
    maxDist = max(pdist2(clusterCenters(i, :), clusterPoints)); % 중심점에서 가장 먼 점까지의 거리 계산
    theta = linspace(0, 2*pi, 100);
    circle_x = maxDist * cos(theta) + clusterCenters(i, 1);
    circle_y = maxDist * sin(theta) + clusterCenters(i, 2);
    plot(circle_x, circle_y, 'Color', colors(i, :)); % 경계 원 그리기
    radius_s =[radius_s; maxDist];
    %save(sprintf('Cluster%d_boundary.mat', i), 'circle_x', 'circle_y'); % 각 군집의 원형 영역 저장
end
hold off;
title('DBSCAN Clustering 결과');

% 각 군집의 중심점 출력
disp('각 군집의 중심점:');
disp(clusterCenters);
