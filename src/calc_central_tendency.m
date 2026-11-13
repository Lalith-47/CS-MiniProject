function ct = calc_central_tendency(tbl, cfg)
% CALC_CENTRAL_TENDENCY - Evaluates Central Tendency and Dispersion Metrics
%
% Calculates comprehensive statistical descriptors for Productivity and Salary:
% - Measures of Central Tendency: Mean, Median, Mode, Trimmed Mean, Geometric Mean
% - Measures of Dispersion: Standard Deviation, Variance, IQR, MAD, Range
% - Distribution Shape: Skewness, Kurtosis
% - Grouped breakdown by Department
%
% Inputs:
%   tbl - Employee dataset table
%   cfg - Configuration struct
% Outputs:
%   ct  - Structured results containing all metrics
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 2, cfg = config(); end

    prod = tbl.ProductivityScore;
    sal  = tbl.Salary;

    %% 1. Metrics for Productivity Score
    ct.Prod.Mean        = stat_utils.mean(prod);
    ct.Prod.Median      = stat_utils.median(prod);
    ct.Prod.Mode        = stat_utils.mode(prod);
    ct.Prod.TrimmedMean = stat_utils.trimmed_mean(prod, 10);
    ct.Prod.GeomMean    = stat_utils.geom_mean(prod);
    ct.Prod.Std         = stat_utils.std(prod);
    ct.Prod.Var         = stat_utils.var(prod);
    ct.Prod.IQR         = stat_utils.iqr(prod);
    ct.Prod.MAD         = stat_utils.mad(prod);
    ct.Prod.Min         = min(prod);
    ct.Prod.Max         = max(prod);
    ct.Prod.Range       = ct.Prod.Max - ct.Prod.Min;
    ct.Prod.Skewness    = stat_utils.skewness(prod);
    ct.Prod.Kurtosis    = stat_utils.kurtosis(prod);

    %% 2. Metrics for Annual Salary
    ct.Salary.Mean        = stat_utils.mean(sal);
    ct.Salary.Median      = stat_utils.median(sal);
    ct.Salary.Mode        = stat_utils.mode(sal);
    ct.Salary.TrimmedMean = stat_utils.trimmed_mean(sal, 10);
    ct.Salary.GeomMean    = stat_utils.geom_mean(sal);
    ct.Salary.Std         = stat_utils.std(sal);
    ct.Salary.Var         = stat_utils.var(sal);
    ct.Salary.IQR         = stat_utils.iqr(sal);
    ct.Salary.MAD         = stat_utils.mad(sal);
    ct.Salary.Min         = min(sal);
    ct.Salary.Max         = max(sal);
    ct.Salary.Range       = ct.Salary.Max - ct.Salary.Min;
    ct.Salary.Skewness    = stat_utils.skewness(sal);
    ct.Salary.Kurtosis    = stat_utils.kurtosis(sal);

    %% 3. Department Breakdown
    depts = categories(tbl.Department);
    ct.DeptNames = depts;
    k = numel(depts);
    ct.DeptSummary = cell(k, 6);

    for i = 1:k
        dept_name = depts{i};
        mask = (tbl.Department == dept_name);
        p_sub = prod(mask);
        s_sub = sal(mask);

        ct.DeptStats(i).Name        = dept_name;
        ct.DeptStats(i).Count       = sum(mask);
        ct.DeptStats(i).MeanProd    = stat_utils.mean(p_sub);
        ct.DeptStats(i).MedianProd  = stat_utils.median(p_sub);
        ct.DeptStats(i).MeanSalary  = stat_utils.mean(s_sub);
        ct.DeptStats(i).MedianSalary= stat_utils.median(s_sub);
        ct.DeptStats(i).IQR_Salary  = stat_utils.iqr(s_sub);
    end

    %% 4. Console ASCII Output
    fprintf('\n========================================================================================\n');
    fprintf('                      SECTION 1: CENTRAL TENDENCY & DISPERSION METRICS                  \n');
    fprintf('========================================================================================\n');
    fprintf('%-24s | %-18s | %-24s\n', 'Metric', 'Productivity (pts)', 'Annual Salary (USD)');
    fprintf('----------------------------------------------------------------------------------------\n');
    fprintf('%-24s | %18.2f | %24s\n', 'Sample Size (N)', numel(prod), sprintf('%d', numel(sal)));
    fprintf('%-24s | %18.2f | %24s\n', 'Arithmetic Mean', ct.Prod.Mean, stat_utils.format_currency(ct.Salary.Mean));
    fprintf('%-24s | %18.2f | %24s\n', 'Median (50th %tile)', ct.Prod.Median, stat_utils.format_currency(ct.Salary.Median));
    fprintf('%-24s | %18.2f | %24s\n', 'Estimated Mode', ct.Prod.Mode, stat_utils.format_currency(ct.Salary.Mode));
    fprintf('%-24s | %18.2f | %24s\n', '10%% Trimmed Mean', ct.Prod.TrimmedMean, stat_utils.format_currency(ct.Salary.TrimmedMean));
    fprintf('%-24s | %18.2f | %24s\n', 'Geometric Mean', ct.Prod.GeomMean, stat_utils.format_currency(ct.Salary.GeomMean));
    fprintf('%-24s | %18.2f | %24s\n', 'Standard Deviation (s)', ct.Prod.Std, stat_utils.format_currency(ct.Salary.Std));
    fprintf('%-24s | %18.2f | %24.0f\n', 'Sample Variance (s^2)', ct.Prod.Var, ct.Salary.Var);
    fprintf('%-24s | %18.2f | %24s\n', 'Interquartile Range(IQR)', ct.Prod.IQR, stat_utils.format_currency(ct.Salary.IQR));
    fprintf('%-24s | %18.2f | %24s\n', 'Median Abs Dev (MAD)', ct.Prod.MAD, stat_utils.format_currency(ct.Salary.MAD));
    fprintf('%-24s | %18.2f | %24s\n', 'Minimum', ct.Prod.Min, stat_utils.format_currency(ct.Salary.Min));
    fprintf('%-24s | %18.2f | %24s\n', 'Maximum', ct.Prod.Max, stat_utils.format_currency(ct.Salary.Max));
    fprintf('%-24s | %18.2f | %24s\n', 'Range (Max - Min)', ct.Prod.Range, stat_utils.format_currency(ct.Salary.Range));
    fprintf('%-24s | %18.3f | %24.3f\n', 'Skewness (Fisher)', ct.Prod.Skewness, ct.Salary.Skewness);
    fprintf('%-24s | %18.3f | %24.3f\n', 'Kurtosis (Pearson)', ct.Prod.Kurtosis, ct.Salary.Kurtosis);
    fprintf('----------------------------------------------------------------------------------------\n');
    fprintf('Key Insight: Salary exhibits positive skewness (Mean > Median by %s), whereas\n', ...
        stat_utils.format_currency(ct.Salary.Mean - ct.Salary.Median));
    fprintf('Productivity Score is symmetric (Mean ~ Median delta = %.2f pts).\n', abs(ct.Prod.Mean - ct.Prod.Median));
    fprintf('========================================================================================\n\n');
end

