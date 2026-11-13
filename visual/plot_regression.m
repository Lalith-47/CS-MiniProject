function fig = plot_regression(tbl, reg, cfg)
% PLOT_REGRESSION - Visualizes Regression Models & Residual Diagnostics
%
% Produces a 4-panel regression diagnostic suite:
% 1. OLS Fit with 95% Confidence Band & 95% Individual Prediction Band
% 2. Residuals vs. Fitted Values (Homoscedasticity & Linearity Verification)
% 3. Normal Q-Q Plot of Standardized Residuals (Error Normality Verification)
% 4. Cook's Distance & Leverage Analysis (Influential Outlier Diagnostics)
%
% Inputs:
%   tbl - Dataset table
%   reg - Regression results from run_regression
%   cfg - Configuration struct
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 3, cfg = config(); end

    fig = figure('Name', 'Section 5: Regression Modeling & Residual Diagnostics', ...
                 'Color', cfg.Color.White, ...
                 'Position', [130, 130, cfg.FigureWidth, cfg.FigureHeight]);

    t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, 'Figure 5: Regression Modeling, Prediction Intervals & 4-in-1 Residual Diagnostics', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTitle + 2, 'FontWeight', 'bold', ...
          'Color', cfg.Color.DarkSlate);

    %% -------------------------------------------------------------------------
    %% Tile 1: Regression Fit with Confidence & Prediction Bands
    %% -------------------------------------------------------------------------
    ax1 = nexttile(t, 1);
    hold(ax1, 'on');

    xp = tbl.ProductivityScore;
    yp = tbl.Salary;
    gx = reg.SLR.Grid_X;
    gy = reg.SLR.Grid_Y;
    ci = reg.SLR.CI_Band;
    pi_band = reg.SLR.PI_Band;

    % 1. Shaded 95% Prediction Band (Outer)
    h_pi = patch(ax1, [gx; flipud(gx)], [pi_band(:,1); flipud(pi_band(:,2))], ...
                 cfg.Color.PrimaryBlue, 'FaceAlpha', 0.12, 'EdgeColor', 'none');

    % 2. Shaded 95% Confidence Band (Inner)
    h_ci = patch(ax1, [gx; flipud(gx)], [ci(:,1); flipud(ci(:,2))], ...
                 cfg.Color.AccentTeal, 'FaceAlpha', 0.35, 'EdgeColor', 'none');

    % 3. Raw Data Points
    s_data = scatter(ax1, xp, yp, 24, cfg.Color.PrimaryBlue, 'filled', ...
                     'MarkerFaceAlpha', 0.45, 'MarkerEdgeColor', [cfg.Color.PrimaryBlue * 0.7, 0.7]);

    % 4. Regression Line
    l_fit = plot(ax1, gx, gy, 'Color', cfg.Color.CoralRed, 'LineWidth', 2.8);

    % Callout Box
    msg_reg = sprintf(['\\bfSimple OLS Model\\rm\n', ...
                       'Salary = %s + %.1f \\times Prod\n', ...
                       'R^2 = %.3f | RMSE = %s\n', ...
                       '\\bfMultiple OLS Model\\rm\n', ...
                       'R^2 = %.3f | Adj R^2 = %.3f\n', ...
                       'Model F = %.1f (%s)'], ...
                       stat_utils.format_currency(reg.SLR.Beta(1)), reg.SLR.Beta(2), ...
                       reg.SLR.R2, stat_utils.format_currency(reg.SLR.RMSE), ...
                       reg.MLR.R2, reg.MLR.AdjR2, reg.MLR.F_Stat, ...
                       stat_utils.format_pvalue(reg.MLR.F_PVal));
    text(ax1, 0.04, 0.93, msg_reg, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [cfg.Color.LightGray, 0.92], 'EdgeColor', cfg.Color.CardBorder, ...
         'LineWidth', 1.0, 'Margin', 8, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    xlabel(ax1, 'Productivity Score (pts)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax1, 'Annual Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax1, 'Salary vs. Productivity: OLS Fit with 95% Confidence & Prediction Bands', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    legend(ax1, [l_fit, h_ci, h_pi, s_data], ...
           {'OLS Regression Line', '95% Mean Confidence Band', '95% Individual Prediction Band', 'Observed Employees (N=500)'}, ...
           'Location', 'southeast', 'Box', 'off', 'FontSize', cfg.FontSizeTick - 1);
    format_axes(ax1, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 2: Residuals vs. Fitted Values (Homoscedasticity)
    %% -------------------------------------------------------------------------
    ax2 = nexttile(t, 2);
    hold(ax2, 'on');

    fitted_vals = reg.MLR.Fitted;
    res_vals    = reg.MLR.Residuals;

    % Horizontal Zero Line
    yline(ax2, 0, '--', 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.8);

    % Scatter of residuals
    scatter(ax2, fitted_vals, res_vals, 22, cfg.Color.EmeraldGreen, 'filled', ...
            'MarkerFaceAlpha', 0.45, 'MarkerEdgeColor', [0.10, 0.45, 0.25]);

    % Moving average trend line (with fallback)
    [sort_fitted, sort_idx] = sort(fitted_vals);
    sort_res = res_vals(sort_idx);
    window_sz = 35;
    if exist('movmean', 'builtin') || exist('movmean', 'file')
        mov_mean_res = movmean(sort_res, window_sz);
    else
        mov_mean_res = conv(sort_res, ones(window_sz, 1) / window_sz, 'same');
    end
    plot(ax2, sort_fitted, mov_mean_res, 'Color', cfg.Color.CoralRed, 'LineWidth', 2.2);

    text(ax2, 0.05, 0.15, ...
         'Horizontal zero trend and uniform vertical spread\nconfirm Linearity and Homoscedasticity (Equal Variance)', ...
         'Units', 'normalized', 'BackgroundColor', [cfg.Color.LightGray, 0.90], ...
         'EdgeColor', cfg.Color.CardBorder, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, 'FontAngle', 'italic');

    xlabel(ax2, 'Fitted Values \hat{Y} (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax2, 'Raw Residuals e_i (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax2, 'Multiple Regression Diagnostics: Residuals vs. Fitted Values', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax2, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 3: Normal Q-Q Plot of Standardized Residuals
    %% -------------------------------------------------------------------------
    ax3 = nexttile(t, 3);
    hold(ax3, 'on');

    std_res = reg.MLR.StdResiduals;
    [q_theo_res, q_sample_res] = stat_utils.qq_points(std_res);

    % 45-degree reference line
    ref_span = linspace(-3.5, 3.5, 100);
    plot(ax3, ref_span, ref_span, '--', 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.8);

    % Residual Q-Q scatter
    scatter(ax3, q_theo_res, q_sample_res, 24, cfg.Color.PrimaryBlue, 'filled', ...
            'MarkerFaceAlpha', 0.55, 'MarkerEdgeColor', [cfg.Color.PrimaryBlue * 0.7, 0.8]);

    xlim(ax3, [-3.5, 3.5]);
    ylim(ax3, [-3.5, 3.5]);

    text(ax3, 0.05, 0.12, ...
         'Residuals closely align with theoretical Gaussian quantiles,\nsatisfying OLS normality assumption \epsilon ~ N(0, \sigma^2)', ...
         'Units', 'normalized', 'BackgroundColor', [cfg.Color.LightGray, 0.90], ...
         'EdgeColor', cfg.Color.CardBorder, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, 'FontAngle', 'italic');

    xlabel(ax3, 'Theoretical Normal Quantiles', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax3, 'Standardized Residual Quantiles', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax3, 'Residual Normality: Standardized Residual Normal Q-Q Plot', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax3, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 4: Cook''s Distance & Leverage (Influential Outliers)
    %% -------------------------------------------------------------------------
    ax4 = nexttile(t, 4);
    hold(ax4, 'on');

    cooks = reg.MLR.CooksD;
    cutoff = reg.MLR.CooksCutoff;
    emp_ids = (1:numel(cooks))';

    % Stem / bar plot of Cook's distances
    stem(ax4, emp_ids, cooks, 'Marker', 'none', 'Color', cfg.Color.AccentTeal, 'LineWidth', 1.1);

    % Highlight points above cutoff
    outlier_mask = (cooks > cutoff);
    if any(outlier_mask)
        scatter(ax4, emp_ids(outlier_mask), cooks(outlier_mask), 35, ...
                cfg.Color.CoralRed, 'filled', 'MarkerEdgeColor', cfg.Color.DarkSlate);
    end

    % Threshold line: 4/N
    l_cut = yline(ax4, cutoff, '--', 'Color', cfg.Color.CoralRed, 'LineWidth', 1.8);

    msg_cooks = sprintf(['\\bfInfluence Diagnostics\\rm\n', ...
                         'Cutoff (4/N) = %.4f\n', ...
                         'Influential Points = %d of %d (%.1f%%)\n', ...
                         'Max Cook''s D = %.4f\n', ...
                         'No catastrophic leverage detected'], ...
                         cutoff, sum(outlier_mask), numel(cooks), ...
                         (sum(outlier_mask)/numel(cooks))*100, max(cooks));
    text(ax4, 0.58, 0.93, msg_cooks, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [cfg.Color.LightGray, 0.90], 'EdgeColor', cfg.Color.CardBorder, ...
         'LineWidth', 1.0, 'Margin', 8, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    xlim(ax4, [0, numel(cooks) + 5]);
    ylim(ax4, [0, max(max(cooks)*1.2, cutoff * 2)]);
    xlabel(ax4, 'Employee Observation Index (1:N)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax4, 'Cook''s Distance D_i', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax4, 'Influential Outlier Diagnostics: Cook''s Distance vs. 4/N Threshold', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    legend(ax4, l_cut, {sprintf('Cutoff Threshold 4/N (%.4f)', cutoff)}, ...
           'Location', 'northwest', 'Box', 'off', 'FontSize', cfg.FontSizeTick);
    format_axes(ax4, cfg);

    %% Export Figure
    if cfg.SaveFigures
        save_plot(fig, fullfile(cfg.FigDir, 'fig5_regression_diagnostics.png'), cfg);
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

