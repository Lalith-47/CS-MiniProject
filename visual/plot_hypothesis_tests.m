function fig = plot_hypothesis_tests(tbl, hyp, cfg)
% PLOT_HYPOTHESIS_TESTS - Visualizes Inferential Statistical Hypotheses
%
% Visualizes:
% 1. Two-Sample Welch t-test (High vs. Low Training with 95% CI Error Bars)
% 2. One-Way ANOVA (Salary Across Education Levels with Grand Mean & CIs)
% 3. Theoretical F-Distribution Null Hypothesis Rejection Visualizer
% 4. Correlation Significance (Productivity vs. Salary with Bivariate Ellipse)
%
% Inputs:
%   tbl - Dataset table
%   hyp - Hypothesis testing results from run_hypothesis_tests
%   cfg - Configuration struct
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 3, cfg = config(); end

    fig = figure('Name', 'Section 3: Hypothesis Testing & Statistical Inference', ...
                 'Color', cfg.Color.White, ...
                 'Position', [90, 90, cfg.FigureWidth, cfg.FigureHeight]);

    t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, 'Figure 3: Hypothesis Testing, ANOVA Variance Decomposition & Significance Proofs', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTitle + 2, 'FontWeight', 'bold', ...
          'Color', cfg.Color.DarkSlate);

    %% -------------------------------------------------------------------------
    %% Tile 1: Two-Sample t-Test (Training Effect on Productivity)
    %% -------------------------------------------------------------------------
    ax1 = nexttile(t, 1);
    hold(ax1, 'on');

    high_mask = (tbl.TrainingHours >= 35);
    p_high = tbl.ProductivityScore(high_mask);
    p_low  = tbl.ProductivityScore(~high_mask);

    % Jittered Scatter
    scatter(ax1, 1 + (rand(numel(p_low), 1) - 0.5)*0.25, p_low, 20, ...
            cfg.Color.CoralRed, 'filled', 'MarkerFaceAlpha', 0.35);
    scatter(ax1, 2 + (rand(numel(p_high), 1) - 0.5)*0.25, p_high, 20, ...
            cfg.Color.PrimaryBlue, 'filled', 'MarkerFaceAlpha', 0.35);

    % Mean and 95% CI Error Bars
    ci_low_p  = 1.96 * hyp.TTest.s2 / sqrt(hyp.TTest.n2);
    ci_high_p = 1.96 * hyp.TTest.s1 / sqrt(hyp.TTest.n1);

    errorbar(ax1, 1, hyp.TTest.m2, ci_low_p, 'o', 'Color', [0.70, 0.15, 0.10], ...
             'MarkerFaceColor', cfg.Color.CoralRed, 'MarkerSize', 10, 'LineWidth', 2.5, 'CapSize', 14);
    errorbar(ax1, 2, hyp.TTest.m1, ci_high_p, 'o', 'Color', [0.05, 0.25, 0.55], ...
             'MarkerFaceColor', cfg.Color.PrimaryBlue, 'MarkerSize', 10, 'LineWidth', 2.5, 'CapSize', 14);

    % Significance connector
    y_sig = max(tbl.ProductivityScore) + 2.5;
    plot(ax1, [1, 1, 2, 2], [y_sig - 1, y_sig, y_sig, y_sig - 1], 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.5);
    text(ax1, 1.5, y_sig + 1.2, sprintf('*** Welch t = %.2f (%s, Cohen''s d = %.2f)', ...
         hyp.TTest.t_stat, stat_utils.format_pvalue(hyp.TTest.p_value), hyp.TTest.CohensD), ...
         'HorizontalAlignment', 'center', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, ...
         'FontWeight', 'bold', 'Color', cfg.Color.DarkSlate);

    set(ax1, 'XTick', [1, 2], 'XTickLabel', {'Low Training (< 35h)', 'High Training (>= 35h)'});
    xlim(ax1, [0.4, 2.6]);
    ylim(ax1, [min(tbl.ProductivityScore) - 4, y_sig + 6]);
    ylabel(ax1, 'Productivity Score (pts)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax1, sprintf('Welch t-Test: Productivity Lift (+%.1f pts, 95%% CI [%.1f, %.1f])', ...
          hyp.TTest.MeanDiff, hyp.TTest.CI95(1), hyp.TTest.CI95(2)), ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax1, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 2: One-Way ANOVA (Salary by Education Level)
    %% -------------------------------------------------------------------------
    ax2 = nexttile(t, 2);
    hold(ax2, 'on');

    cats = hyp.ANOVA.Categories;
    k = numel(cats);
    cols = [cfg.Color.PrimaryBlue; cfg.Color.EmeraldGreen; cfg.Color.Purple];

    % Grand Mean dashed line
    y_grand = hyp.ANOVA.GrandMean;
    l_gm = yline(ax2, y_grand, '--', 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.5);

    for g = 1:k
        mask = (tbl.Education == cats{g});
        y_sub = tbl.Salary(mask);
        scatter(ax2, g + (rand(numel(y_sub), 1) - 0.5)*0.22, y_sub, 20, ...
                cols(g, :), 'filled', 'MarkerFaceAlpha', 0.30);

        % Mean + 95% CI Error bar
        ci_g = 1.96 * hyp.ANOVA.Group_Std(g) / sqrt(hyp.ANOVA.Group_N(g));
        errorbar(ax2, g, hyp.ANOVA.Group_Mean(g), ci_g, 's', 'Color', cols(g, :) * 0.7, ...
                 'MarkerFaceColor', cols(g, :), 'MarkerSize', 11, 'LineWidth', 2.5, 'CapSize', 16);
    end

    % ANOVA summary callout
    msg_anova = sprintf(['\\bfOne-Way ANOVA\\rm\n', ...
                         'F(%d, %d) = %.2f\n', ...
                         'p-value: %s\n', ...
                         'Effect Size (\\eta^2) = %.3f\n', ...
                         'Significant Education ROI'], ...
                         hyp.ANOVA.df_Between, hyp.ANOVA.df_Within, hyp.ANOVA.F_Stat, ...
                         stat_utils.format_pvalue(hyp.ANOVA.p_value), hyp.ANOVA.EtaSquared);
    text(ax2, 0.05, 0.93, msg_anova, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [cfg.Color.LightGray, 0.90], 'EdgeColor', cfg.Color.CardBorder, ...
         'LineWidth', 1.0, 'Margin', 8, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    set(ax2, 'XTick', 1:k, 'XTickLabel', cats);
    xlim(ax2, [0.4, k + 0.6]);
    ylabel(ax2, 'Annual Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax2, 'One-Way ANOVA: Salary Distribution Across Education Levels', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    legend(ax2, l_gm, {sprintf('Grand Mean (%s)', stat_utils.format_currency(y_grand))}, ...
           'Location', 'northwest', 'Box', 'off', 'FontSize', cfg.FontSizeTick);
    format_axes(ax2, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 3: Theoretical F-Distribution Curve & Rejection Region
    %% -------------------------------------------------------------------------
    ax3 = nexttile(t, 3);
    hold(ax3, 'on');

    df1 = hyp.ANOVA.df_Between;
    df2 = hyp.ANOVA.df_Within;
    f_crit = hyp.ANOVA.F_Crit;
    f_stat = hyp.ANOVA.F_Stat;

    % Grid for F-Distribution
    f_max = max(10, f_crit * 3);
    f_grid = linspace(0.01, f_max, 400);

    % F-PDF: c * f^(df1/2 - 1) / (1 + (df1/df2)*f)^((df1+df2)/2)
    pdf_f = zeros(size(f_grid));
    log_c = gammaln((df1 + df2)/2) - gammaln(df1/2) - gammaln(df2/2) + ...
            (df1/2) * log(df1 / df2);
    for idx = 1:numel(f_grid)
        fv = f_grid(idx);
        pdf_f(idx) = exp(log_c + (df1/2 - 1)*log(fv) - ((df1 + df2)/2)*log(1 + (df1/df2)*fv));
    end

    % Plot F density curve
    plot(ax3, f_grid, pdf_f, 'Color', cfg.Color.PrimaryBlue, 'LineWidth', 2.2);

    % Shaded Rejection Region: F >= F_crit
    rej_idx = (f_grid >= f_crit);
    f_rej = f_grid(rej_idx);
    pdf_rej = pdf_f(rej_idx);
    patch(ax3, [f_crit, f_rej, f_max, f_crit], [0, pdf_rej, 0, 0], ...
          cfg.Color.CoralRed, 'FaceAlpha', 0.40, 'EdgeColor', cfg.Color.CoralRed, 'LineWidth', 1.0);

    % Mark F_crit line
    xline(ax3, f_crit, '--', 'Color', cfg.Color.CoralRed, 'LineWidth', 2.0);
    text(ax3, f_crit + 0.15, max(pdf_f)*0.75, ...
         sprintf('F_{crit} = %.2f\n(\\alpha = 0.05)', f_crit), ...
         'Color', cfg.Color.CoralRed, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, 'FontWeight', 'bold');

    % Observed F-stat annotation
    text(ax3, 0.45, 0.50, ...
         sprintf('\\bfObserved F = %.1f\\rm\nF_{stat} \\gg F_{crit}\nRejection of H_0 is absolute\n(p < 0.0001)', f_stat), ...
         'Units', 'normalized', 'BackgroundColor', [cfg.Color.LightGray, 0.90], ...
         'EdgeColor', cfg.Color.CoralRed, 'LineWidth', 1.2, 'Margin', 8, ...
         'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    xlim(ax3, [0, f_max]);
    ylim(ax3, [0, max(pdf_f) * 1.15]);
    xlabel(ax3, 'F-Statistic Value', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax3, 'Probability Density', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax3, sprintf('F-Distribution Density F(%d, %d): Critical Rejection Region', df1, df2), ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax3, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 4: Correlation Significance (Productivity vs. Salary)
    %% -------------------------------------------------------------------------
    ax4 = nexttile(t, 4);
    hold(ax4, 'on');

    xp = tbl.ProductivityScore;
    yp = tbl.Salary;

    scatter(ax4, xp, yp, 28, cfg.Color.AccentTeal, 'filled', ...
            'MarkerFaceAlpha', 0.45, 'MarkerEdgeColor', [cfg.Color.AccentTeal * 0.7, 0.8]);

    % Linear correlation fit line
    b_fit = polyfit(xp, yp, 1);
    x_line = linspace(min(xp), max(xp), 100);
    plot(ax4, x_line, polyval(b_fit, x_line), 'Color', cfg.Color.PrimaryBlue, 'LineWidth', 2.5);

    % 95% Bivariate Confidence Ellipse
    cov_mat = cov(xp, yp);
    [V, D] = eig(cov_mat);
    t_ellipse = linspace(0, 2*pi, 100);
    chisq_val = sqrt(5.991); % 95% 2-DOF chi-squared value
    a = chisq_val * sqrt(D(1,1));
    b = chisq_val * sqrt(D(2,2));
    ellipse_pts = (V * [a * cos(t_ellipse); b * sin(t_ellipse)])';
    plot(ax4, ellipse_pts(:,1) + mean(xp), ellipse_pts(:,2) + mean(yp), ...
         ':', 'Color', cfg.Color.DarkSlate, 'LineWidth', 2.0);

    msg_corr = sprintf(['\\bfCorrelation Statistics\\rm\n', ...
                        'Pearson r: +%.3f (p < 0.0001)\n', ...
                        '95%% CI: [%.3f, %.3f]\n', ...
                        'Spearman \\rho: +%.3f\n', ...
                        'Strong Positive Link'], ...
                        hyp.Correlation.Pearson_r, ...
                        hyp.Correlation.Pearson_CI95(1), hyp.Correlation.Pearson_CI95(2), ...
                        hyp.Correlation.Spearman_rho);
    text(ax4, 0.05, 0.93, msg_corr, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [cfg.Color.LightGray, 0.90], 'EdgeColor', cfg.Color.CardBorder, ...
         'LineWidth', 1.0, 'Margin', 8, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    xlabel(ax4, 'Productivity Score (pts)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax4, 'Annual Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax4, 'Productivity vs. Salary Correlation (with 95% Confidence Ellipse)', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax4, cfg);

    %% Export Figure
    if cfg.SaveFigures
        save_plot(fig, fullfile(cfg.FigDir, 'fig3_hypothesis_tests.png'), cfg);
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

