tic; % 타이머 시작

% 이미지를 사용하여 점유 그리드 맵 형성
image = imread('study_map.png');
grayimage = rgb2gray(image);
bwimage = grayimage < 0.5; % 흰색 영역을 장애물로 설정 (장애물 = 1, 자유 공간 = 0)
grid = binaryOccupancyMap(bwimage);

run('DBSCAN.m'); % DBSCAN 군집화 스크립트 실행

% 각 군집의 중심점을 픽셀 좌표로 변환
Pixel_clusterCenters = round([clusterCenters(:,1), ypixel - clusterCenters(:,2)]);

% DensityBasedMap 초기화
DensityBasedMap = zeros(4525, 4525);

% 각 군집의 중심점과 반지름을 사용하여 DensityBasedMap에 원형 영역 추가
for i = 1:size(Pixel_clusterCenters, 1)
    DensityBasedMap = addClusterToMap(Pixel_clusterCenters(i, :), radius_s(i, 1), DensityBasedMap);
end

save('DensityBasedMap.mat', "DensityBasedMap"); % 결과 저장

% DensityBasedMap 시각화
figure;
ax = axes;
show(binaryOccupancyMap(DensityBasedMap),'Parent',ax);
% 그래픽 요소 추가
xlabel(ax, '');
ylabel(ax, '');
title(ax, 'DensityBasedMap');

% DensityBasedMap에서 1인 지역(군집화된 영역)과 0인 지역(비군집화된 영역)의 좌표 추출
[ones_row, ones_col] = find(DensityBasedMap == 1);
[zeros_row, zeros_col] = find(DensityBasedMap == 0);

disp(['time:', num2str(toc)]); % 실행 시간 출력

% 원형 영역을 이진 맵에 추가하는 함수
function binary_map = addClusterToMap(center, radius, input_map)
    [height, width] = size(input_map); % 맵의 높이와 너비
    
    % 원의 중심점 설정
    centerX = center(1);
    centerY = center(2);
    
    % 맵 상의 모든 좌표에 대해 반복
    for y = 1:height
        for x = 1:width
            distance = sqrt((x - centerX)^2 + (y - centerY)^2); % 중심점으로부터의 거리 계산
            if distance <= radius
                input_map(y, x) = 1; % 거리가 반지름 이내이면 해당 좌표를 1로 설정
            end
        end
    end
    
    binary_map = input_map;
end
