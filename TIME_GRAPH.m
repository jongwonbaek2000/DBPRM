%testnum1 = [1, 2, 3, 4, 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 ];  % x 데이터
%testtime1 = [5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6];  % y 데이터
%testnum = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30];

load("testtime1.mat",'testtime1');
load("testtime2.mat","testtime2");
load("num_test.mat", "num_test");
testnum = 1:num_test;  % 1부터 num_test까지의 값을 가진 배열을 생성합니다.
figure;
hold on;

% 그리드를 흐리게 표시
grid on;
ax = gca; % 현재 축 가져오기
ax.GridColor = [0.5 0.5 0.5]; % 그리드 색상을 밝은 회색으로 설정

% Plot 외곽 표시
ax.Box = 'on'; % 외곽선 표시 활성화



plot(testnum, testtime1, 'LineStyle', '-', 'Marker', '*', 'Color', 'b'); % 그래프 그리기
xlim([0 30]);  % x축 범위 설정
ylim([0 3]);  % y축 범위 설정

xlabel('Trial Number (count)'); % x축 라벨
ylabel('Runtime (s)'); % y축 라벨
title('DBPRM과 PRM 실행시간 비교'); % 그래프 제목

set(gcf, 'Position', [500, 300, 600, 300]); % [x, y, width, height]






%testnum2 = [1, 2, 3, 4, 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 ];  % x 데이터
%testtime2 = [5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,7];  % y 데이터

p1 = plot(testnum, testtime2, 'LineStyle', '-', 'Marker', '.', 'Color', 'r','LineWidth',1); % 그래프 그리기
p1.MarkerSize = 10;
%xlim([0 30]);  % x축 범위 설정
%ylim([4 7]);  % y축 범위 설정

%xlabel('x 축'); % x축 라벨
%ylabel('y 축'); % y축 라벨
%title('x와 y의 관계'); % 그래프 제목

%set(gcf, 'Position', [500, 300, 600, 300]); % [x, y, width, height]

legend('DBPRM','PRM');
hold off;














