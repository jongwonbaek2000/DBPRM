
mean_group1 = 1.804545; % 첫 번째 집단의 평균
std_dev_group1 = 0.037059; % 첫 번째 집단의 표준편차
sample_size_group1 = 30; % 첫 번째 집단의 샘플 크기

mean_group2 = 1.152652; % 두 번째 집단의 평균
std_dev_group2 = 0.026167; % 두 번째 집단의 표준편차
sample_size_group2 = 30; % 두 번째 집단의 샘플 크기
alpha = 0.00001;

% 양측 검정
[t_stat, p_value, df] = custom_ttest(mean_group1, std_dev_group1, sample_size_group1, mean_group2, std_dev_group2, sample_size_group2, alpha, 'both');

disp(['t-통계량: ', num2str(t_stat)]);
disp(['p-값: ', num2str(p_value)]);
disp(['자유도: ', num2str(df)]);

% 우측 검정
[t_stat, p_value, df] = custom_ttest(mean_group1, std_dev_group1, sample_size_group1, mean_group2, std_dev_group2, sample_size_group2, alpha, 'greater');

disp(['t-통계량: ', num2str(t_stat)]);
disp(['p-값: ', num2str(p_value)]);
disp(['자유도: ', num2str(df)]);

% 좌측 검정
[t_stat, p_value, df] = custom_ttest(mean_group1, std_dev_group1, sample_size_group1, mean_group2, std_dev_group2, sample_size_group2, alpha, 'less');

disp(['t-통계량: ', num2str(t_stat)]);
disp(['p-값: ', num2str(p_value)]);
disp(['자유도: ', num2str(df)]);
disp(eps);

function [t_stat, p_value, df] = custom_ttest(mean1, std_dev1, n1, mean2, std_dev2, n2, alpha, direction)
    % 두 집단의 표본 수
    df1 = n1 - 1;
    df2 = n2 - 1;

    % 두 집단의 분산 추정치
    var1 = std_dev1^2;
    var2 = std_dev2^2;

    % 두 집단의 풀 분산 추정치
    pooled_var = ((df1 * var1) + (df2 * var2)) / (df1 + df2);

    % 두 집단의 평균 차이
    mean_diff = mean1 - mean2;

    % t-통계량
    t_stat = mean_diff / sqrt(pooled_var * (1/n1 + 1/n2));

    % 자유도
    df = df1 + df2;

    % p-value 계산
    if strcmp(direction, 'both') || strcmp(direction, '양측')
        disp([newline,'양측검정입니다.']);
        p_val_temp = 2 * (1 - tcdf(abs(t_stat), df));
    elseif strcmp(direction, 'greater') || strcmp(direction, '우측')
        disp([newline, '우측검정입니다.']);
        p_val_temp = 1 - tcdf(t_stat, df);
    elseif strcmp(direction, 'less') || strcmp(direction, '좌측')
        disp([newline,'좌측검정입니다.']);
        p_val_temp = tcdf(t_stat, df);
    else
        error('잘못된 검정 방향입니다.');
    end

    % 극한값 처리
    p_value = max(p_val_temp, eps);
    if p_value <=eps
        disp('eps 2.2204e-16보다 작습니다')
    end
    % 유의수준(alpha)와 비교하여 유의미한지 판단
    if p_value < alpha
        disp('귀무가설을 기각합니다. 두 집단의 평균은 유의하게 다릅니다.');
    else
        disp('귀무가설을 기각하지 않습니다. 두 집단의 평균은 유의하지 않게 다릅니다.');
    end
end


