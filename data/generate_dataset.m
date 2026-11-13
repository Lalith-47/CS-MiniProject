function tbl = generate_dataset(cfg)
% GENERATE_DATASET - Generates Realistic Employee Productivity & Salary Dataset
%
% Generates N = 500 employee records with realistic correlations:
% - Experience, Training, Weekly Hours, and Remote Ratio influence Productivity
% - Productivity, Experience, Education, and Department influence Salary
% - Demonstrates mild right-skewness in Salary (typical of real-world labor markets)
% - Exports data to employee_data.csv
%
% Inputs:
%   cfg - Configuration struct from config.m
% Outputs:
%   tbl - MATLAB table with all features
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 1, cfg = config(); end
    rng(cfg.Seed, 'twister');
    N = cfg.SampleSize;

    %% 1. Employee Identifiers
    EmployeeID = (1:N)';

    %% 2. Department & Education Categoricals
    dept_names = {'Engineering', 'Data Science', 'Sales', 'Marketing', 'Human Resources'};
    dept_prob  = [0.28, 0.22, 0.20, 0.16, 0.14];
    dept_cum   = cumsum(dept_prob);
    r_dept     = rand(N, 1);
    Department = repmat({'Engineering'}, N, 1);
    for i = 1:N
        idx = find(r_dept(i) <= dept_cum, 1, 'first');
        Department{i} = dept_names{idx};
    end

    edu_levels = {'Bachelor', 'Master', 'PhD'};
    edu_prob   = [0.55, 0.35, 0.10];
    edu_cum    = cumsum(edu_prob);
    r_edu      = rand(N, 1);
    Education  = repmat({'Bachelor'}, N, 1);
    edu_bonus  = zeros(N, 1);
    for i = 1:N
        idx = find(r_edu(i) <= edu_cum, 1, 'first');
        Education{i} = edu_levels{idx};
        if idx == 2
            edu_bonus(i) = 14000; % Master's premium
        elseif idx == 3
            edu_bonus(i) = 28000; % PhD premium
        end
    end

    %% 3. Quantitative Employee Predictors
    % Experience: Right-skewed distribution (gamma-like or positive beta), bounded 0.5 to 25 yrs
    u1 = rand(N, 1);
    u2 = rand(N, 1);
    u3 = rand(N, 1);
    exp_raw = -4 * log(max(u1, 1e-4)) - 2.5 * log(max(u2, 1e-4)) + 1.2 * u3;
    Experience = max(0.5, min(24.0, round(exp_raw * 1.3, 1)));

    % Weekly Hours: Centered around 42 hours, std ~ 4
    WeeklyHours = round(max(32, min(58, 42.0 + 3.8 * randn(N, 1))), 1);

    % Training Hours: Annual training sessions attended (centered around 35 hrs)
    TrainingHours = round(max(6, min(75, 34.0 + 13.0 * randn(N, 1))));

    % Remote Work Percentage (0%, 20%, 50%, 80%, 100%)
    remote_options = [0; 20; 50; 80; 100];
    r_remote = randi(numel(remote_options), N, 1);
    RemoteRatio = remote_options(r_remote);

    %% 4. Employee Productivity Score (Target Metric 1)
    % Productivity Model:
    % - Positive return on Experience (+1.35 pts/yr)
    % - Positive return on Training (+0.32 pts/hr)
    % - Diminishing returns / burnout penalty for excessive hours (> 48 hrs)
    % - Hybrid remote flexibility bonus
    % - Department innovation variance
    hours_effect = -0.06 * (WeeklyHours - 42.0).^2;
    remote_effect = 3.5 * sin(pi * RemoteRatio / 100.0);
    noise_prod = 4.2 * randn(N, 1);

    prod_raw = 46.0 ...
             + 1.35 * Experience ...
             + 0.32 * TrainingHours ...
             + hours_effect ...
             + remote_effect ...
             + noise_prod;

    ProductivityScore = max(35.0, min(98.0, round(prod_raw, 1)));

    %% 5. Annual Salary in USD (Target Metric 2)
    % Salary Model:
    % - Base salary: $42,000
    % - Experience premium: $3,400 / year
    % - Productivity return: $620 / productivity point
    % - Education premium: Master (+$14,000), PhD (+$28,000)
    % - Department market adjustments: Data Science (+$10,000), Engineering (+$8,000)
    % - Log-normal multiplicative noise: exp(N(0, 0.09)) introduces realistic right-skewness!
    dept_salary_bonus = zeros(N, 1);
    for i = 1:N
        switch Department{i}
            case 'Data Science'
                dept_salary_bonus(i) = 11000;
            case 'Engineering'
                dept_salary_bonus(i) = 9000;
            case 'Sales'
                dept_salary_bonus(i) = 4500;
            case 'Marketing'
                dept_salary_bonus(i) = 1500;
            case 'Human Resources'
                dept_salary_bonus(i) = 0;
        end
    end

    deterministic_comp = 42000 ...
                       + 3400 * Experience ...
                       + 620 * ProductivityScore ...
                       + edu_bonus ...
                       + dept_salary_bonus;

    log_noise = exp(0.09 * randn(N, 1));
    salary_raw = deterministic_comp .* log_noise;
    Salary = round(salary_raw, -2); % Round to nearest hundred dollars
    LogSalary = log(Salary);

    %% 6. Assemble into MATLAB Table
    tbl = table(EmployeeID, ...
                categorical(Department), ...
                categorical(Education, {'Bachelor', 'Master', 'PhD'}, 'Ordinal', true), ...
                Experience, ...
                WeeklyHours, ...
                TrainingHours, ...
                RemoteRatio, ...
                ProductivityScore, ...
                Salary, ...
                LogSalary, ...
                'VariableNames', {'EmployeeID', 'Department', 'Education', ...
                                  'Experience', 'WeeklyHours', 'TrainingHours', ...
                                  'RemoteRatio', 'ProductivityScore', 'Salary', 'LogSalary'});

    %% 7. Export Dataset to CSV
    writetable(tbl, cfg.CsvPath);
    fprintf('[DATA] Successfully generated %d records and exported to: %s\n', N, cfg.CsvPath);
end

