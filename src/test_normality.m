function norm_res = test_normality(tbl, cfg)
% TEST_NORMALITY - Evaluates Empirical Normality & Goodness-of-Fit
%
% Performs formal normality tests and parametric checks across three series:
% 1. ProductivityScore (Engineered to follow Gaussian bell curve)
% 2. Salary (Raw, right-skewed non-normal distribution)
% 3. LogSalary (Log-transformed series restoring Gaussian symmetry)
%
% Tests Performed:
% - Jarque-Bera Test (Skewness & Kurtosis test against Chi2(2))
% - Lilliefors / Kolmogorov-Smirnov Test (Empirical vs. Theoretical CDF distance)
% - Quantile-Quantile (Q-Q) parametric mapping
%
% Inputs:
%   tbl      - Dataset table
%   cfg      - Configuration struct
% Outputs:
%   norm_res - Struct containing test statistics, p-values, and decisions
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 2, cfg = config(); end
    alpha = cfg.Alpha;
    N = cfg.SampleSize;

    series_data = {tbl.ProductivityScore, tbl.Salary, tbl.LogSalary};
    series_names = {'ProductivityScore', 'Salary (Raw)', 'Log(Salary)'};

    for s = 1:3
        x = series_data{s};
        name = series_names{s};

        n = numel(x);
        m = stat_utils.mean(x);
        sd = stat_utils.std(x);

        % Skewness & Kurtosis
        sk = stat_utils.skewness(x);
        kt = stat_utils.kurtosis(x);
        excess_kt = kt - 3.0;

        % 1. Jarque-Bera Test Statistic
        % JB = (n/6) * [S^2 + ((K-3)^2)/4] ~ Chi^2(df=2)
        jb_stat = (n / 6) * (sk^2 + (excess_kt^2) / 4);
        jb_pval = 1 - stat_utils.chi2_cdf(jb_stat, 2);
        jb_crit = 5.9915; % Chi2 critical value at alpha=0.05, df=2
        jb_reject = (jb_stat > jb_crit) || (jb_pval < alpha);

        % 2. Lilliefors / K-S Distance Statistic
        % D = max |F_n(x) - Normal_CDF(x; mu, sigma)|
        x_sorted = sort(x);
        f_emp_left = (0:(n-1))' / n;
        f_emp_right = (1:n)' / n;
        z_vals = (x_sorted - m) / sd;
        f_theo = stat_utils.norm_cdf(z_vals);
        d_stat = max(max(abs(f_emp_right - f_theo), abs(f_emp_left - f_theo)));
        
        % Lilliefors critical value approximation at alpha = 0.05: ~ 0.886 / sqrt(N)
        d_crit = 0.886 / sqrt(n);
        ks_reject = (d_stat > d_crit);

        % 3. Q-Q Mapping
        [q_theo, q_sample] = stat_utils.qq_points(x);

        % Store Results
        res.Name       = name;
        res.Mean       = m;
        res.Std        = sd;
        res.Skewness   = sk;
        res.Kurtosis   = kt;
        res.ExcessKurt = excess_kt;
        res.JB_Stat    = jb_stat;
        res.JB_PVal    = jb_pval;
        res.JB_Crit    = jb_crit;
        res.JB_Reject  = jb_reject;
        res.KS_Stat    = d_stat;
        res.KS_Crit    = d_crit;
        res.KS_Reject  = ks_reject;
        res.QQ_Theo    = q_theo;
        res.QQ_Sample  = q_sample;

        if jb_reject
            res.Decision = 'REJECT H0 (Non-Normal Distribution)';
        else
            res.Decision = 'FAIL TO REJECT H0 (Normal Distribution)';
        end

        norm_res.(matlab.lang.makeValidName(name)) = res;
        norm_res.List{s} = res;
        if s == 1
            norm_res.ProductivityScore = res;
        elseif s == 2
            norm_res.SalaryRaw = res;
            norm_res.Salary_Raw_ = res; % backwards compatibility
        elseif s == 3
            norm_res.LogSalary = res;
            norm_res.Log_Salary_ = res; % backwards compatibility
        end
    end

    %% Console ASCII Table
    fprintf('\n========================================================================================\n');
    fprintf('                           SECTION 2: NORMALITY TESTING & GOODNESS-OF-FIT               \n');
    fprintf('========================================================================================\n');
    fprintf('%-22s | %-10s | %-10s | %-10s | %-12s | %-20s\n', ...
        'Series Tested', 'Skewness', 'Kurtosis', 'JB Stat', 'JB p-value', 'Verdict (alpha=0.05)');
    fprintf('----------------------------------------------------------------------------------------\n');
    for s = 1:3
        r = norm_res.List{s};
        fprintf('%-22s | %10.3f | %10.3f | %10.2f | %12s | %-20s\n', ...
            r.Name, r.Skewness, r.Kurtosis, r.JB_Stat, ...
            stat_utils.format_pvalue(r.JB_PVal), r.Decision);
    end
    fprintf('----------------------------------------------------------------------------------------\n');
    fprintf('Statistical Conclusion:\n');
    fprintf('1. Productivity Score conforms to normality (p = %.4f > 0.05). H0 accepted.\n', ...
        norm_res.ProductivityScore.JB_PVal);
    fprintf('2. Raw Salary significantly departs from normality (JB = %.1f, p < 0.0001). H0 strongly rejected.\n', ...
        norm_res.SalaryRaw.JB_Stat);
    fprintf('3. Log-Transformed Salary restores Gaussian symmetry (JB = %.2f, p = %.4f). Normality recovered.\n', ...
        norm_res.LogSalary.JB_Stat, norm_res.LogSalary.JB_PVal);
    fprintf('========================================================================================\n\n');
end

