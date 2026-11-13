%% =========================================================================
% MATLAB MINI PROJECT: EMPLOYEE PRODUCTIVITY & SALARY ANALYSIS
% =========================================================================
%
% This project implements a comprehensive statistical and econometric
% investigation of workplace productivity and compensation dynamics:
%
% 1. CENTRAL TENDENCY & DISPERSION:
%    - Mean, Median, Mode, Trimmed Mean, Geometric Mean
%    - Variance, Standard Deviation, IQR, MAD, Skewness, Kurtosis
%
% 2. NORMALITY TESTING & GOODNESS-OF-FIT:
%    - Jarque-Bera Test & Lilliefors/KS Distance
%    - Standardized Q-Q Plots & Logarithmic Normalization
%
% 3. HYPOTHESIS TESTING:
%    - Two-sample Welch t-test (Training Hours vs. Productivity)
%    - One-way ANOVA (Salary Across Education Levels)
%    - Pearson & Spearman Correlation Significance Tests
%
% 4. NON-PARAMETRIC BOOTSTRAP INFERENCE:
%    - Resampling (B = 3000 iterations) for Population Median Salary
%    - 95% Percentile and Normal-Approximation Confidence Intervals
%    - Monte Carlo convergence tracking across replicates
%
% 5. REGRESSION MODELING & RESIDUAL DIAGNOSTICS:
%    - Simple & Multiple OLS Regression (Salary ~ Exp + Prod + Hours + Training)
%    - 95% Confidence & Individual Prediction Bands
%    - 4-in-1 Residual Diagnostics (Homoscedasticity, Q-Q, Cook's Distance)
%
% Author: Antigravity AI & Pair Programmer
% File: main.m (Master Project Execution Script)
% =========================================================================

clc;
clear;
close all;

fprintf('========================================================================================\n');
fprintf('       MATLAB MINI PROJECT: EMPLOYEE PRODUCTIVITY & SALARY STATISTICAL ANALYSIS         \n');
fprintf('========================================================================================\n');

%% 0. Setup Search Paths & Load Configuration
project_dir = fileparts(mfilename('fullpath'));
if isempty(project_dir), project_dir = pwd; end
addpath(genpath(project_dir));

cfg = config();
fprintf('[CONFIG] Project initialized. Sample size N = %d, Bootstrap B = %d, Alpha = %.2f\n', ...
    cfg.SampleSize, cfg.BootstrapReplicates, cfg.Alpha);

%% 1. Generate / Load Synthetic Dataset
fprintf('\n[STEP 1/6] Generating realistic employee productivity & salary dataset...\n');
tbl = generate_dataset(cfg);

%% 2. Section 1: Central Tendency & Dispersion
fprintf('\n[STEP 2/6] Computing central tendency, dispersion, and department breakdowns...\n');
ct = calc_central_tendency(tbl, cfg);
fig1 = plot_central_tendency(tbl, ct, cfg);

%% 3. Section 2: Normality Testing & Diagnostics
fprintf('\n[STEP 3/6] Conducting formal normality tests (Jarque-Bera & Q-Q mapping)...\n');
norm_res = test_normality(tbl, cfg);
fig2 = plot_normality(tbl, norm_res, cfg);

%% 4. Section 3: Inferential Hypothesis Testing
fprintf('\n[STEP 4/6] Executing inferential hypothesis tests (t-Test, ANOVA, Correlation)...\n');
hyp = run_hypothesis_tests(tbl, cfg);
fig3 = plot_hypothesis_tests(tbl, hyp, cfg);

%% 5. Section 4: Bootstrap Resampling & Confidence Intervals
fprintf('\n[STEP 5/6] Performing Monte Carlo bootstrap resampling (B = %d)...\n', cfg.BootstrapReplicates);
boot_res = run_bootstrap(tbl, cfg);
fig4 = plot_bootstrap(boot_res, cfg);

%% 6. Section 5: Regression Modeling & Diagnostics
fprintf('\n[STEP 6/6] Fitting OLS regression models and computing residual diagnostics...\n');
reg = run_regression(tbl, cfg);
fig5 = plot_regression(tbl, reg, cfg);

%% 7. Master Executive Dashboard
fprintf('\n[DASHBOARD] Rendering Master Executive Analytics Dashboard...\n');
fig6 = plot_executive_summary(tbl, ct, norm_res, hyp, boot_res, reg, cfg);

%% Final Completion Message
fprintf('\n========================================================================================\n');
fprintf('                              PROJECT EXECUTION COMPLETE                                \n');
fprintf('========================================================================================\n');
fprintf('All 5 core modules successfully executed.\n');
fprintf('6 publication-grade high-resolution figures generated and saved to:\n  --> %s\n\n', cfg.FigDir);
fprintf('Generated Figures:\n');
fprintf('  1. fig1_central_tendency.png     - Central Tendency & Dispersion Dashboard\n');
fprintf('  2. fig2_normality_tests.png      - Normality Tests & Q-Q Diagnostics\n');
fprintf('  3. fig3_hypothesis_tests.png     - Welch t-Test, ANOVA & Correlation Analysis\n');
fprintf('  4. fig4_bootstrap_inference.png  - Bootstrap Sampling Distributions & CIs\n');
fprintf('  5. fig5_regression_diagnostics.png- OLS Regression Bands & Residual Diagnostics\n');
fprintf('  6. fig6_executive_dashboard.png   - Master Executive Summary Dashboard\n');
fprintf('========================================================================================\n');

