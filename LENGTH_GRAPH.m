%path_length 사이즈 에 기반하여, 그래프 그리기....



load("test_path_length1.mat",'test_path_length1');
load("test_path_length2.mat","test_path_length2");
testnum1 = 1:size(test_path_length1);  % 1부터 num_test까지의 값을 가진 배열을 생성합니다.
testnum2 = 1:size(test_path_length2);

figure;
hold on;

% 그리드를 흐리게 표시
grid on;
ax = gca; % 현재 축 가져오기
ax.GridColor = [0.5 0.5 0.5]; % 그리드 색상을 밝은 회색으로 설정

% Plot 외곽 표시
ax.Box = 'on'; % 외곽선 표시 활성화



plot(testnum1, test_path_length1, 'LineStyle', '-', 'Marker', '*', 'Color', 'b'); % 그래프 그리기
xlim([0 30]);  % x축 범위 설정
ylim([4500 7500]);  % y축 범위 설정

xlabel('Trial Number (count)'); % x축 라벨
ylabel('Path Length (pixel)'); % y축 라벨
title('DBPRM과 PRM 경로 길이 비교'); % 그래프 제목

set(gcf, 'Position', [500, 200, 600, 300]); % [x, y, width, height]







p1 = plot(testnum2, test_path_length2, 'LineStyle', '-', 'Marker', '.', 'Color', 'r','LineWidth',1); % 그래프 그리기
p1.MarkerSize = 10;
%xlim([0 30]);  % x축 범위 설정
%ylim([4 7]);  % y축 범위 설정

%xlabel('x 축'); % x축 라벨
%ylabel('y 축'); % y축 라벨
%title('x와 y의 관계'); % 그래프 제목

%set(gcf, 'Position', [500, 300, 600, 300]); % [x, y, width, height]

legend('DBPRM','PRM');
hold off;

%}