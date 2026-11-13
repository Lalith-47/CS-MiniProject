function fig = plot_executive_summary(tbl, ct, norm_res, hyp, boot_res, reg, cfg)
% PLOT_EXECUTIVE_SUMMARY - Generates Master Executive Analytics Dashboard
%
% Integrates all 5 analytical pillars into a single presentation visual:
% 1. Top KPI Metric Cards (Headcount, Median Salary, Training Lift, R-squared)
% 2. Multi-Factor Compensation Scatter (Experience, Productivity & Salary)
% 3. Education ROI Analysis (ANOVA Group Means with 95% Confidence Intervals)
% 4. Empirical Density Comparison (Productivity, Raw Salary, Log Salary)
% 5. Hypothesis Testing & Statistical Decision Matrix Infographic
%
% Inputs:
%   tbl      - Dataset table
%   ct       - Central tendency results
%   norm_res - Normality results
%   hyp      - Hypothesis testing results
%   boot_res - Bootstrap results
%   reg      - Regression results
%   cfg      - Configuration struct
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 7, cfg = config(); end

    fig = figure('Name', 'Master Executive Analytics Dashboard', ...
                 'Color', cfg.Color.White, ...
                 'Position', [40, 40, 1400, 900]);

    t = tiledlayout(3, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, 'EXECUTIVE ANALYTICS DASHBOARD: EMPLOYEE PRODUCTIVITY & SALARY DYNAMICS', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTitle + 3, 'FontWeight', 'bold', ...
          'Color', cfg.Color.DarkSlate);

    %% -------------------------------------------------------------------------
    %% Row 1: KPI Cards (4 Tiles across top)
    %% -------------------------------------------------------------------------
    kpis = {
        'TOTAL WORKFORCE', sprintf('%d', numel(tbl.ProductivityScore)), 'Active Employees Analyzed', cfg.Color.PrimaryBlue;
        'MEDIAN SALARY', stat_utils.format_currency(boot_res.Salary.OriginalEstimate), ...
            sprintf('95%% Boot CI: [%s, %s]', stat_utils.format_currency(boot_res.Salary.CI_Percentile(1)), ...
            stat_utils.format_currency(boot_res.Salary.CI_Percentile(2))), cfg.Color.EmeraldGreen;
        'TRAINING GAIN', sprintf('+%.1f pts', hyp.TTest.MeanDiff), ...
            sprintf('Welch t = %.2f (%s)', hyp.TTest.t_stat, stat_utils.format_pvalue(hyp.TTest.p_value)), cfg.Color.AmberGold;
        'MODEL EXPLANATION', sprintf('%.1f%%', reg.MLR.R2 * 100), ...
            sprintf('Adj R^2 = %.1f%% | RMSE = %s', reg.MLR.AdjR2 * 100, stat_utils.format_currency(reg.MLR.RMSE)), cfg.Color.Purple
    };

    for k = 1:4
        ax_kpi = nexttile(t, k);
        axis(ax_kpi, 'off');
        hold(ax_kpi, 'on');

        col = kpis{k, 4};
        % Background card
        patch(ax_kpi, [0.03, 0.97, 0.97, 0.03], [0.05, 0.05, 0.95, 0.95], ...
              cfg.Color.LightGray, 'EdgeColor', cfg.Color.CardBorder, 'LineWidth', 1.2);
        % Left color accent pill
        patch(ax_kpi, [0.03, 0.08, 0.08, 0.03], [0.05, 0.05, 0.95, 0.95], ...
              col, 'EdgeColor', col);

        % KPI text
        text(ax_kpi, 0.14, 0.76, kpis{k, 1}, 'FontName', cfg.FontName, 'FontSize', 9, ...
             'FontWeight', 'bold', 'Color', [0.45, 0.50, 0.55]);
        text(ax_kpi, 0.14, 0.44, kpis{k, 2}, 'FontName', cfg.FontName, 'FontSize', 18, ...
             'FontWeight', 'bold', 'Color', cfg.Color.DarkSlate);
        text(ax_kpi, 0.14, 0.18, kpis{k, 3}, 'FontName', cfg.FontName, 'FontSize', 8.5, ...
             'FontAngle', 'italic', 'Color', col * 0.8);

        xlim(ax_kpi, [0, 1]);
        ylim(ax_kpi, [0, 1]);
    end

    %% -------------------------------------------------------------------------
    %% Middle Row: Scatter Fit (Tiles 5-6) & Education ANOVA (Tiles 7-8)
    %% -------------------------------------------------------------------------
    % Left Panel: Experience, Productivity & Salary
    ax_mid_l = nexttile(t, 5, [1, 2]);
    hold(ax_mid_l, 'on');

    scatter(ax_mid_l, tbl.ProductivityScore, tbl.Salary, 32, tbl.Experience, 'filled', ...
            'MarkerFaceAlpha', 0.65, 'MarkerEdgeColor', [0.2, 0.2, 0.2]);
    cb = colorbar(ax_mid_l);
    cb.Label.String = 'Experience (Years)';
    cb.Label.FontWeight = 'bold';
    colormap(ax_mid_l, 'parula');

    % Simple Regression Line
    gx = reg.SLR.Grid_X;
    gy = reg.SLR.Grid_Y;
    plot(ax_mid_l, gx, gy, 'Color', cfg.Color.CoralRed, 'LineWidth', 2.8);

    xlabel(ax_mid_l, 'Productivity Score (pts)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax_mid_l, 'Annual Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax_mid_l, 'Compensation Determinants: Productivity, Experience & Salary', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax_mid_l, cfg);

    % Right Panel: ANOVA Education ROI
    ax_mid_r = nexttile(t, 7, [1, 2]);
    hold(ax_mid_r, 'on');

    cats = hyp.ANOVA.Categories;
    k_edu = numel(cats);
    b_cols = [cfg.Color.PrimaryBlue; cfg.Color.EmeraldGreen; cfg.Color.Purple];

    for g = 1:k_edu
        m_val = hyp.ANOVA.Group_Mean(g);
        ci_val = 1.96 * hyp.ANOVA.Group_Std(g) / sqrt(hyp.ANOVA.Group_N(g));

        % Bar
        bar(ax_mid_r, g, m_val, 0.55, 'FaceColor', b_cols(g, :), 'FaceAlpha', 0.70, ...
            'EdgeColor', b_cols(g, :) * 0.7, 'LineWidth', 1.2);
        % Error Bar
        errorbar(ax_mid_r, g, m_val, ci_val, 'Color', cfg.Color.DarkSlate, ...
                 'LineWidth', 2.0, 'CapSize', 14);

        % Text value on bar
        text(ax_mid_r, g, m_val / 2, stat_utils.format_currency(m_val), ...
             'HorizontalAlignment', 'center', 'FontName', cfg.FontName, 'FontSize', 10, ...
             'FontWeight', 'bold', 'Color', cfg.Color.White);
    end

    yline(ax_mid_r, hyp.ANOVA.GrandMean, '--', 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.5);
    set(ax_mid_r, 'XTick', 1:k_edu, 'XTickLabel', cats);
    ylabel(ax_mid_r, 'Mean Annual Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax_mid_r, sprintf('Education Compensation Premium (ANOVA F = %.1f, p < 0.0001)', hyp.ANOVA.F_Stat), ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax_mid_r, cfg);

    %% -------------------------------------------------------------------------
    %% Bottom Row: Density Transformations (Tiles 9-10) & Decision Card (Tiles 11-12)
    %% -------------------------------------------------------------------------
    ax_bot_l = nexttile(t, 9, [1, 2]);
    hold(ax_bot_l, 'on');

    % Normalized KDE curves comparison
    [g_p, d_p] = stat_utils.kde((tbl.ProductivityScore - mean(tbl.ProductivityScore)) / std(tbl.ProductivityScore), 200);
    [g_s, d_s] = stat_utils.kde((tbl.Salary - mean(tbl.Salary)) / std(tbl.Salary), 200);
    [g_l, d_l] = stat_utils.kde((tbl.LogSalary - mean(tbl.LogSalary)) / std(tbl.LogSalary), 200);

    z_grid = linspace(-3.5, 3.5, 200);
    pdf_z = exp(-0.5 * z_grid.^2) / sqrt(2*pi);
    plot(ax_bot_l, z_grid, pdf_z, 'k--', 'LineWidth', 1.5);

    p1 = plot(ax_bot_l, g_p, d_p, 'Color', cfg.Color.PrimaryBlue, 'LineWidth', 2.2);
    p2 = plot(ax_bot_l, g_s, d_s, 'Color', cfg.Color.CoralRed, 'LineWidth', 2.2);
    p3 = plot(ax_bot_l, g_l, d_l, 'Color', cfg.Color.EmeraldGreen, 'LineWidth', 2.2);

    xlabel(ax_bot_l, 'Standardized Score (z-score)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax_bot_l, 'Density', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax_bot_l, 'Distributional Shapes: Productivity (Normal) vs. Raw Salary (Skewed) vs. Log-Salary', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    legend(ax_bot_l, [p1, p2, p3], {'Productivity (Symmetric)', 'Raw Salary (Right-Skewed)', 'Log-Salary (Normalized)'}, ...
           'Location', 'northwest', 'Box', 'off', 'FontSize', cfg.FontSizeTick);
    xlim(ax_bot_l, [-3.5, 3.5]);
    format_axes(ax_bot_l, cfg);

    % Decision Infographic Card
    ax_bot_r = nexttile(t, 11, [1, 2]);
    axis(ax_bot_r, 'off');
    hold(ax_bot_r, 'on');

    patch(ax_bot_r, [0.02, 0.98, 0.98, 0.02], [0.02, 0.02, 0.98, 0.98], ...
          cfg.Color.LightGray, 'EdgeColor', cfg.Color.CardBorder, 'LineWidth', 1.2);
    patch(ax_bot_r, [0.02, 0.98, 0.98, 0.02], [0.82, 0.82, 0.98, 0.98], ...
          cfg.Color.DarkSlate, 'EdgeColor', cfg.Color.DarkSlate);
    text(ax_bot_r, 0.50, 0.90, 'PROJECT INFERENTIAL DECISION MATRIX', ...
         'FontName', cfg.FontName, 'FontSize', 10, 'FontWeight', 'bold', ...
         'Color', cfg.Color.White, 'HorizontalAlignment', 'center');

    if norm_res.ProductivityScore.JB_Reject
        norm_prod_msg = 'Non-Normal (H0 Rejected)';
    else
        norm_prod_msg = 'Gaussian Normal Confirmed (H0 Accepted)';
    end

    if norm_res.SalaryRaw.JB_Reject
        norm_sal_msg = 'Non-Normal Positive Skew (H0 Rejected)';
    else
        norm_sal_msg = 'Gaussian Normal (H0 Accepted)';
    end

    matrix_rows = {
        'Normality (Productivity)', sprintf('JB = %.2f (%s)', norm_res.ProductivityScore.JB_Stat, stat_utils.format_pvalue(norm_res.ProductivityScore.JB_PVal)), norm_prod_msg;
        'Normality (Raw Salary)',   sprintf('JB = %.1f (%s)', norm_res.SalaryRaw.JB_Stat, stat_utils.format_pvalue(norm_res.SalaryRaw.JB_PVal)), norm_sal_msg;
        'Training Hypothesis',      sprintf('t = %.2f (%s)', hyp.TTest.t_stat, stat_utils.format_pvalue(hyp.TTest.p_value)), ...
            sprintf('High Training Lifts Productivity (+%.1f pts, d=%.2f)', hyp.TTest.MeanDiff, hyp.TTest.CohensD);
        'Education Hypothesis',     sprintf('F = %.1f (%s)', hyp.ANOVA.F_Stat, stat_utils.format_pvalue(hyp.ANOVA.p_value)), ...
            sprintf('Education Significant (\\eta^2 = %.2f, p < 0.0001)', hyp.ANOVA.EtaSquared);
        'Bootstrap Resampling',     sprintf('B = %d resamples', boot_res.B), ...
            sprintf('Median 95%% CI [%s, %s]', stat_utils.format_currency(boot_res.Salary.CI_Percentile(1)), stat_utils.format_currency(boot_res.Salary.CI_Percentile(2)));
        'Regression Explanatory',   sprintf('R^2 = %.1f%% (Adj %.1f%%)', reg.MLR.R2 * 100, reg.MLR.AdjR2 * 100), ...
            sprintf('Exp (+$%.0f/yr) & Prod (+$%.0f/pt) Dominant Drivers', reg.MLR.Beta(2), reg.MLR.Beta(3))
    };

    y_mat = 0.70;
    for r = 1:size(matrix_rows, 1)
        text(ax_bot_r, 0.05, y_mat, matrix_rows{r, 1}, 'FontName', cfg.FontName, 'FontSize', 8.5, 'FontWeight', 'bold', 'Color', cfg.Color.DarkSlate);
        text(ax_bot_r, 0.42, y_mat, matrix_rows{r, 2}, 'FontName', cfg.FontName, 'FontSize', 8.5, 'FontWeight', 'bold', 'Color', cfg.Color.PrimaryBlue);
        text(ax_bot_r, 0.65, y_mat, matrix_rows{r, 3}, 'FontName', cfg.FontName, 'FontSize', 8.0, 'Color', [0.10, 0.50, 0.25]);
        plot(ax_bot_r, [0.04, 0.96], [y_mat - 0.035, y_mat - 0.035], 'Color', cfg.Color.CardBorder, 'LineWidth', 0.8);
        y_mat = y_mat - 0.125;
    end

    xlim(ax_bot_r, [0, 1]);
    ylim(ax_bot_r, [0, 1]);

    %% Export Figure
    if cfg.SaveFigures
        save_plot(fig, fullfile(cfg.FigDir, 'fig6_executive_dashboard.png'), cfg);
    end
end

function format_axes(ax, cfg)
    set(ax, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, ...
            'Color', cfg.Color.White, 'XColor', cfg.Color.DarkSlate, 'YColor', cfg.Color.DarkSlate, ...
            'GridColor', cfg.Color.GridGray, 'GridAlpha', 0.8, 'Box', 'off', 'TickDir', 'out');
    grid(ax, 'on');
end

function save_plot(fig, filepath, cfg)
    try
        exportgraphics(fig, filepath, 'Resolution', cfg.DPI);
        fprintf('[VISUAL] Saved Figure to: %s\n', filepath);
    catch
        saveas(fig, filepath);
        fprintf('[VISUAL] Saved Figure via saveas to: %s\n', filepath);
    end
end

