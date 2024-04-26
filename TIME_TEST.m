
% 테스트 파라미터
num_test = 30;
Original = true;

% 실행 시간을 저장할 배열 초기화
execution_times = [];
path_lengths = [];
successes = [];
testtime1 = [];
testtime2 = [];

% 코드를 num_test번 실행
%i = 1;
for i = 1:num_test
    tic;  % 실행 시간 측정 시작
    if Original
        run('DBPRM.m');        
    else
        run('Normal_PRM.m');
    end
    
    %run('Original_PRM_Binmap_save.m');
    % Original_PRM_Binmap.m에서 success 변수 가져오기
    successes = [successes;success];
    execution_times = [execution_times; toc];  % 실행 시간 측정 종료 및 저장
    if total_distance ~= 0
        path_lengths = [path_lengths;total_distance];
    end
end

if Original
    fprintf('Original PRM Binmap');
    testtime1 = execution_times;
    save('testtime1.mat', "testtime1"); % 결과 저장
    test_path_length1 = path_lengths;
    save('test_path_length1',"test_path_length1");
else
    fprintf('Normal PRM');
    testtime2 = execution_times;
    save('testtime2.mat', "testtime2");
    test_path_length2 = path_lengths;
    save('test_path_length2',"test_path_length2");
end
save('num_test.mat',"num_test");

% 성공 확률 계산
probability = mean(successes);

% 결과 출력
disp(execution_times);
average_time = mean(execution_times);
standard_deviation_time = std(execution_times);
average_path_length = mean(total_distance);
standard_deviation_path_length = std(path_lengths);

fprintf('Average execution time: %.6f seconds\n', average_time);
fprintf('Standard Deviation of execution time: %.6f seconds\n', standard_deviation_time);
fprintf('Average path length: %.6f pixels\n', average_path_length);
fprintf('Standard Deviation of path length: %.6f pixels\n', standard_deviation_path_length);
fprintf('Success Probability: %.6f\n', probability);



%성공 지표로 성공확률, 이동 거리는 거의 같은데, 런타임이 매우 짧아졌다는 점을 강조