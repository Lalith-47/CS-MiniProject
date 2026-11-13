function hyp = run_hypothesis_tests(tbl, cfg)
% RUN_HYPOTHESIS_TESTS - Performs Rigorous Inferential Hypothesis Tests
%
% Tests Conducted:
% 1. Two-Sample Welch's t-test:
%    H0: Mean productivity of High Training (>= 35 hrs) == Low Training (< 35 hrs)
% 2. One-Way Analysis of Variance (ANOVA):
%    H0: Mean annual salary across Education levels (Bachelor, Master, PhD) are identical
% 3. Pearson & Spearman Correlation Significance:
%    H0: True correlation between Productivity and Salary rho == 0
%
% Inputs:
%   tbl - Employee dataset table
%   cfg - Configuration struct
% Outputs:
%   hyp - Structured results containing test statistics, p-values, degrees of freedom
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 2, cfg = config(); end
    alpha = cfg.Alpha;
    N = cfg.SampleSize;

    %% =========================================================================
    %% TEST 1: Two-Sample Welch's t-test (Training Effect on Productivity)
    %% =========================================================================
    high_mask = (tbl.TrainingHours >= 35);
    low_mask  = ~high_mask;

    x1 = tbl.ProductivityScore(high_mask); % High training
    x2 = tbl.ProductivityScore(low_mask);  % Low training

    n1 = numel(x1);
    n2 = numel(x2);
    m1 = stat_utils.mean(x1);
    m2 = stat_utils.mean(x2);
    v1 = stat_utils.var(x1);
    v2 = stat_utils.var(x2);
    s1 = sqrt(v1);
    s2 = sqrt(v2);

    mean_diff = m1 - m2;
    se_diff = sqrt(v1 / n1 + v2 / n2);
    t_stat = mean_diff / se_diff;

    % Welch-Satterthwaite degrees of freedom
    df_welch = ((v1/n1 + v2/n2)^2) / (((v1/n1)^2)/(n1 - 1) + ((v2/n2)^2)/(n2 - 1));

    % Two-tailed p-value
    t_pval = 2 * (1 - stat_utils.t_cdf(abs(t_stat), df_welch));
    t_crit = stat_utils.t_inv(1 - alpha/2, df_welch);

    ci_diff_lower = mean_diff - t_crit * se_diff;
    ci_diff_upper = mean_diff + t_crit * se_diff;

    % Pooled std for Cohen's d effect size
    s_pooled = sqrt(((n1 - 1)*v1 + (n2 - 1)*v2) / (n1 + n2 - 2));
    cohen_d = mean_diff / s_pooled;

    hyp.TTest.Group1_Name = 'High Training (>= 35 hrs)';
    hyp.TTest.Group2_Name = 'Low Training (< 35 hrs)';
    hyp.TTest.n1 = n1; hyp.TTest.n2 = n2;
    hyp.TTest.m1 = m1; hyp.TTest.m2 = m2;
    hyp.TTest.s1 = s1; hyp.TTest.s2 = s2;
    hyp.TTest.MeanDiff = mean_diff;
    hyp.TTest.SE = se_diff;
    hyp.TTest.t_stat = t_stat;
    hyp.TTest.df = df_welch;
    hyp.TTest.t_crit = t_crit;
    hyp.TTest.p_value = t_pval;
    hyp.TTest.CI95 = [ci_diff_lower, ci_diff_upper];
    hyp.TTest.CohensD = cohen_d;
    hyp.TTest.RejectH0 = (t_pval < alpha);

    %% =========================================================================
    %% TEST 2: One-Way ANOVA (Salary Across Education Levels)
    %% =========================================================================
    edu_cats = {'Bachelor', 'Master', 'PhD'};
    k_groups = numel(edu_cats);
    y_grand = stat_utils.mean(tbl.Salary);

    group_n = zeros(k_groups, 1);
    group_mean = zeros(k_groups, 1);
    group_std  = zeros(k_groups, 1);
    ss_within  = 0;
    ss_between = 0;

    for g = 1:k_groups
        cat_name = edu_cats{g};
        mask = (tbl.Education == cat_name);
        y_g = tbl.Salary(mask);
        group_n(g) = numel(y_g);
        group_mean(g) = stat_utils.mean(y_g);
        group_std(g) = stat_utils.std(y_g);

        ss_between = ss_between + group_n(g) * (group_mean(g) - y_grand)^2;
        ss_within  = ss_within + sum((y_g - group_mean(g)).^2);
    end

    df_between = k_groups - 1;
    df_within  = N - k_groups;
    df_total   = N - 1;
    ss_total   = ss_between + ss_within;

    ms_between = ss_between / df_between;
    ms_within  = ss_within / df_within;
    f_stat     = ms_between / ms_within;

    f_pval = 1 - stat_utils.f_cdf(f_stat, df_between, df_within);
    f_crit = stat_utils.f_inv(1 - alpha, df_between, df_within);
    eta_sq = ss_between / ss_total;

    hyp.ANOVA.Categories = edu_cats;
    hyp.ANOVA.Group_N    = group_n;
    hyp.ANOVA.Group_Mean = group_mean;
    hyp.ANOVA.Group_Std  = group_std;
    hyp.ANOVA.GrandMean  = y_grand;
    hyp.ANOVA.SS_Between = ss_between;
    hyp.ANOVA.SS_Within  = ss_within;
    hyp.ANOVA.SS_Total   = ss_total;
    hyp.ANOVA.df_Between = df_between;
    hyp.ANOVA.df_Within  = df_within;
    hyp.ANOVA.df_Total   = df_total;
    hyp.ANOVA.MS_Between = ms_between;
    hyp.ANOVA.MS_Within  = ms_within;
    hyp.ANOVA.F_Stat     = f_stat;
    hyp.ANOVA.F_Crit     = f_crit;
    hyp.ANOVA.p_value    = f_pval;
    hyp.ANOVA.EtaSquared = eta_sq;
    hyp.ANOVA.RejectH0   = (f_pval < alpha);

    %% =========================================================================
    %% TEST 3: Pearson & Spearman Correlation (Productivity vs. Salary)
    %% =========================================================================
    xp = tbl.ProductivityScore;
    yp = tbl.Salary;
    mx = stat_utils.mean(xp);
    my = stat_utils.mean(yp);
    dx = xp - mx;
    dy = yp - my;

    % Pearson r
    r_pearson = sum(dx .* dy) / (sqrt(sum(dx.^2)) * sqrt(sum(dy.^2)));
    t_corr = r_pearson * sqrt((N - 2) / (1 - r_pearson^2));
    p_corr = 2 * (1 - stat_utils.t_cdf(abs(t_corr), N - 2));

    % Fisher's z 95% Confidence Interval
    z_corr = 0.5 * log((1 + r_pearson) / (1 - r_pearson));
    se_z = 1 / sqrt(N - 3);
    z_low = z_corr - 1.96 * se_z;
    z_high = z_corr + 1.96 * se_z;
    r_ci_low = (exp(2*z_low) - 1) / (exp(2*z_low) + 1);
    r_ci_high = (exp(2*z_high) - 1) / (exp(2*z_high) + 1);

    % Spearman Rank Correlation
    [~, rank_x] = sort(xp);
    [~, order_x] = sort(rank_x);
    [~, rank_y] = sort(yp);
    [~, order_y] = sort(rank_y);
    d_ranks = order_x - order_y;
    r_spearman = 1 - (6 * sum(d_ranks.^2)) / (N * (N^2 - 1));
    t_spearman = r_spearman * sqrt((N - 2) / (1 - r_spearman^2));
    p_spearman = 2 * (1 - stat_utils.t_cdf(abs(t_spearman), N - 2));

    hyp.Correlation.Pearson_r = r_pearson;
    hyp.Correlation.Pearson_t = t_corr;
    hyp.Correlation.Pearson_p = p_corr;
    hyp.Correlation.Pearson_CI95 = [r_ci_low, r_ci_high];
    hyp.Correlation.Spearman_rho = r_spearman;
    hyp.Correlation.Spearman_p = p_spearman;
    hyp.Correlation.RejectH0 = (p_corr < alpha);

    %% Console ASCII Table
    fprintf('\n========================================================================================\n');
    fprintf('                           SECTION 3: HYPOTHESIS TESTING RESULTS                        \n');
    fprintf('========================================================================================\n');
    fprintf('TEST 1: Two-Sample Welch t-Test (Training Effect on Productivity)\n');
    fprintf('  H0: mu(High Training) == mu(Low Training) | H1: mu(High Training) > mu(Low Training)\n');
    fprintf('  High Training (N=%d): Mean = %.2f pts, Std = %.2f\n', n1, m1, s1);
    fprintf('  Low Training  (N=%d): Mean = %.2f pts, Std = %.2f\n', n2, m2, s2);
    fprintf('  Difference in Means : +%.2f pts [95%% CI: +%.2f to +%.2f]\n', mean_diff, ci_diff_lower, ci_diff_upper);
    fprintf('  t-Statistic         : %.3f (df = %.1f, critical t = %.3f)\n', t_stat, df_welch, t_crit);
    fprintf('  p-Value             : %s | Cohen''s d = %.2f (Large Effect)\n', ...
        stat_utils.format_pvalue(t_pval), cohen_d);
    fprintf('  Verdict             : %s\n\n', ternary(hyp.TTest.RejectH0, 'REJECT H0: High training significantly enhances productivity!', 'FAIL TO REJECT H0'));

    fprintf('TEST 2: One-Way ANOVA (Salary Variation Across Education Levels)\n');
    fprintf('  H0: mu(Bachelor) == mu(Master) == mu(PhD) | H1: At least one group differs\n');
    for g = 1:k_groups
        fprintf('  - %-8s (N=%3d): Mean = %s (Std = %s)\n', ...
            edu_cats{g}, group_n(g), stat_utils.format_currency(group_mean(g)), ...
            stat_utils.format_currency(group_std(g)));
    end
    fprintf('  ANOVA Summary Table:\n');
    fprintf('    Between Groups: SS = %12.2e, df = %2d, MS = %12.2e\n', ss_between, df_between, ms_between);
    fprintf('    Within Groups : SS = %12.2e, df = %2d, MS = %12.2e\n', ss_within, df_within, ms_within);
    fprintf('  F-Statistic   : %.2f (F_critical = %.2f at alpha=0.05)\n', f_stat, f_crit);
    fprintf('  p-Value       : %s | Eta-Squared (eta^2) = %.3f\n', stat_utils.format_pvalue(f_pval), eta_sq);
    fprintf('  Verdict       : %s\n\n', ternary(hyp.ANOVA.RejectH0, 'REJECT H0: Highly significant compensation premium across education levels!', 'FAIL TO REJECT H0'));

    fprintf('TEST 3: Correlation Significance (Productivity vs. Annual Salary)\n');
    fprintf('  H0: rho == 0 (No correlation) | H1: rho != 0 (Significant correlation)\n');
    fprintf('  Pearson Correlation (r) : %.3f [95%% CI: %.3f to %.3f]\n', r_pearson, r_ci_low, r_ci_high);
    fprintf('  t-Statistic             : %.3f (p = %s)\n', t_corr, stat_utils.format_pvalue(p_corr));
    fprintf('  Spearman Rank Corr (rho): %.3f (p = %s)\n', r_spearman, stat_utils.format_pvalue(p_spearman));
    fprintf('  Verdict                 : %s\n', ternary(hyp.Correlation.RejectH0, 'REJECT H0: Statistically significant positive association confirmed!', 'FAIL TO REJECT H0'));
    fprintf('========================================================================================\n\n');
end

function out = ternary(condition, val_true, val_false)
    if condition, out = val_true; else, out = val_false; end
end

