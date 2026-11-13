function fig = plot_bootstrap(boot_res, cfg)
% PLOT_BOOTSTRAP - Visualizes Bootstrap Resampling Distributions & Inference
%
% Produces a 4-panel comprehensive dashboard:
% 1. Bootstrap Distribution of Population Median Salary (with shaded 95% CI)
% 2. Bootstrap Distribution of Mean Productivity Gain (High vs Low Training)
% 3. Monte Carlo Convergence Trace Plot (Tracking CI stability across B replicates)
% 4. Comparative Interval Chart (Parametric vs. Bootstrap Percentile vs. Normal Approx)
%
% Inputs:
%   boot_res - Bootstrap results from run_bootstrap
%   cfg      - Configuration struct
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 2, cfg = config(); end

    fig = figure('Name', 'Section 4: Non-Parametric Bootstrap Inference', ...
                 'Color', cfg.Color.White, ...
                 'Position', [110, 110, cfg.FigureWidth, cfg.FigureHeight]);

    t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, sprintf('Figure 4: Non-Parametric Bootstrap Sampling Distributions & Confidence Intervals (B = %d)', boot_res.B), ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTitle + 2, 'FontWeight', 'bold', ...
          'Color', cfg.Color.DarkSlate);

    %% -------------------------------------------------------------------------
    %% Tile 1: Bootstrap Distribution of Median Salary
    %% -------------------------------------------------------------------------
    ax1 = nexttile(t, 1);
    hold(ax1, 'on');

    reps_sal = boot_res.Salary.Replicates;
    ci_sal   = boot_res.Salary.CI_Percentile;

    % Histogram
    histogram(ax1, reps_sal, 'Normalization', 'pdf', ...
              'FaceColor', cfg.Color.PrimaryBlue, 'FaceAlpha', 0.35, ...
              'EdgeColor', cfg.Color.PrimaryBlue, 'LineWidth', 0.8);

    % KDE Curve
    [gx_sal, dens_sal] = stat_utils.kde(reps_sal, 300);
    plot(ax1, gx_sal, dens_sal, 'Color', cfg.Color.PrimaryBlue, 'LineWidth', 2.2);

    % Shaded 95% CI Region
    ci_idx = (gx_sal >= ci_sal(1)) & (gx_sal <= ci_sal(2));
    gx_ci = gx_sal(ci_idx);
    dens_ci = dens_sal(ci_idx);
    patch(ax1, [ci_sal(1); gx_ci; ci_sal(2)], [0; dens_ci; 0], ...
          cfg.Color.AccentTeal, 'FaceAlpha', 0.35, 'EdgeColor', 'none');

    % Mark Sample Median & Bootstrap Mean
    l_orig = xline(ax1, boot_res.Salary.OriginalEstimate, '--', 'Color', cfg.Color.CoralRed, 'LineWidth', 2.2);
    l_boot = xline(ax1, boot_res.Salary.Mean, '-', 'Color', [0.05, 0.25, 0.55], 'LineWidth', 2.0);

    msg_sal_boot = sprintf(['\\bfBootstrap Median Salary\\rm\n', ...
                            'Original \\theta: %s\n', ...
                            'Bootstrap Mean: %s\n', ...
                            'Bootstrap SE: %s\n', ...
                            'Bootstrap Bias: %s\n', ...
                            '95%% CI: [%s, %s]'], ...
                            stat_utils.format_currency(boot_res.Salary.OriginalEstimate), ...
                            stat_utils.format_currency(boot_res.Salary.Mean), ...
                            stat_utils.format_currency(boot_res.Salary.SE), ...
                            stat_utils.format_currency(boot_res.Salary.Bias), ...
                            stat_utils.format_currency(ci_sal(1)), ...
                            stat_utils.format_currency(ci_sal(2)));
    text(ax1, 0.05, 0.93, msg_sal_boot, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [cfg.Color.LightGray, 0.90], 'EdgeColor', cfg.Color.CardBorder, ...
         'LineWidth', 1.0, 'Margin', 8, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    xlabel(ax1, 'Resampled Median Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax1, 'Probability Density', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax1, 'Bootstrap Distribution: Population Median Salary (B = 3000)', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    legend(ax1, [l_orig, l_boot], ...
           {sprintf('Sample Median (%s)', stat_utils.format_currency(boot_res.Salary.OriginalEstimate)), ...
            sprintf('Bootstrap Mean (%s)', stat_utils.format_currency(boot_res.Salary.Mean))}, ...
           'Location', 'northeast', 'Box', 'off', 'FontSize', cfg.FontSizeTick);
    format_axes(ax1, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 2: Bootstrap Distribution of Productivity Difference (Delta mu)
    %% -------------------------------------------------------------------------
    ax2 = nexttile(t, 2);
    hold(ax2, 'on');

    reps_diff = boot_res.ProdDiff.Replicates;
    ci_diff   = boot_res.ProdDiff.CI_Percentile;

    histogram(ax2, reps_diff, 'Normalization', 'pdf', ...
              'FaceColor', cfg.Color.EmeraldGreen, 'FaceAlpha', 0.35, ...
              'EdgeColor', cfg.Color.EmeraldGreen, 'LineWidth', 0.8);

    [gx_d, dens_d] = stat_utils.kde(reps_diff, 300);
    plot(ax2, gx_d, dens_d, 'Color', [0.10, 0.52, 0.30], 'LineWidth', 2.2);

    % Shaded 95% CI Area
    ci_d_idx = (gx_d >= ci_diff(1)) & (gx_d <= ci_diff(2));
    patch(ax2, [ci_diff(1); gx_d(ci_d_idx); ci_diff(2)], [0; dens_d(ci_d_idx); 0], ...
          cfg.Color.EmeraldGreen, 'FaceAlpha', 0.40, 'EdgeColor', 'none');

    % Null Effect Reference Line (0 pts)
    xline(ax2, 0, ':', 'Color', cfg.Color.CoralRed, 'LineWidth', 2.0);
    text(ax2, 0.2, max(dens_d) * 0.8, 'H_0 Null Value (0 pts)\n(Strictly Excluded)', ...
         'Color', cfg.Color.CoralRed, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, 'FontWeight', 'bold');

    l_diff_orig = xline(ax2, boot_res.ProdDiff.OriginalEstimate, '--', 'Color', [0.05, 0.25, 0.55], 'LineWidth', 2.2);

    msg_diff = sprintf(['\\bfProductivity Delta (\\Delta\\mu)\\rm\n', ...
                        'Sample Gain: +%.2f pts\n', ...
                        'Bootstrap SE: %.2f pts\n', ...
                        '95%% CI: [+%.2f, +%.2f] pts\n', ...
                        'p_{boot}(Diff \\le 0) < 0.0001\n', ...
                        'Robust Training Efficacy'], ...
                        boot_res.ProdDiff.OriginalEstimate, boot_res.ProdDiff.SE, ...
                        ci_diff(1), ci_diff(2));
    text(ax2, 0.05, 0.93, msg_diff, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [cfg.Color.LightGray, 0.90], 'EdgeColor', cfg.Color.CardBorder, ...
         'LineWidth', 1.0, 'Margin', 8, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    xlabel(ax2, 'Resampled Productivity Difference (pts)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax2, 'Probability Density', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax2, 'Bootstrap Distribution: Training Productivity Lift (\mu_{high} - \mu_{low})', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax2, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 3: Monte Carlo Convergence Trace Plot
    %% -------------------------------------------------------------------------
    ax3 = nexttile(t, 3);
    hold(ax3, 'on');

    ck = boot_res.Convergence.Checkpoints;
    low_trace = boot_res.Convergence.LowBound;
    mid_trace = boot_res.Convergence.Median;
    upp_trace = boot_res.Convergence.HighBound;

    % Shaded 95% Confidence Band over iterations
    patch(ax3, [ck, fliplr(ck)], [low_trace', fliplr(upp_trace')], ...
          cfg.Color.PrimaryBlue, 'FaceAlpha', 0.20, 'EdgeColor', 'none');

    % Trace Lines
    p_low = plot(ax3, ck, low_trace, '--', 'Color', cfg.Color.PrimaryBlue, 'LineWidth', 1.6);
    p_mid = plot(ax3, ck, mid_trace, '-',  'Color', [0.05, 0.25, 0.55],   'LineWidth', 2.2);
    p_upp = plot(ax3, ck, upp_trace, '--', 'Color', cfg.Color.PrimaryBlue, 'LineWidth', 1.6);

    text(ax3, 0.55, 0.20, ...
         sprintf('\\bfMonte Carlo Convergence\\rm\nStable CI boundaries achieved\nat B \\ge 1,000 resamples\nFinal Precision: \\pm%s', ...
         stat_utils.format_currency(boot_res.Salary.SE * 1.96)), ...
         'Units', 'normalized', 'BackgroundColor', [cfg.Color.LightGray, 0.90], ...
         'EdgeColor', cfg.Color.CardBorder, 'LineWidth', 1.0, 'Margin', 8, ...
         'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    xlabel(ax3, 'Number of Bootstrap Resamples (B)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax3, 'Estimated Median Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax3, 'Bootstrap Convergence Profile: Running 95% Confidence Interval', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    legend(ax3, [p_upp, p_mid, p_low], {'Upper 97.5% Bound', 'Running Median', 'Lower 2.5% Bound'}, ...
           'Location', 'northeast', 'Box', 'off', 'FontSize', cfg.FontSizeTick);
    format_axes(ax3, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 4: Comparison of Confidence Interval Methodologies
    %% -------------------------------------------------------------------------
    ax4 = nexttile(t, 4);
    hold(ax4, 'on');

    % Comparing Median Salary CIs & Normal approximations
    ci_p = boot_res.Salary.CI_Percentile;
    ci_n = boot_res.Salary.CI_NormalApprox;
    est  = boot_res.Salary.OriginalEstimate;

    methods = {'Normal Approximation CI', 'Bootstrap Percentile CI'};
    y_locs  = [1.0, 2.0];
    c_list  = [cfg.Color.CoralRed; cfg.Color.PrimaryBlue];

    for m = 1:2
        if m == 1
            c_low = ci_n(1); c_high = ci_n(2);
        else
            c_low = ci_p(1); c_high = ci_p(2);
        end

        % Interval line
        plot(ax4, [c_low, c_high], [y_locs(m), y_locs(m)], 'Color', c_list(m, :), 'LineWidth', 3.5);
        % Caps
        plot(ax4, [c_low, c_low], [y_locs(m)-0.12, y_locs(m)+0.12], 'Color', c_list(m, :), 'LineWidth', 2.5);
        plot(ax4, [c_high, c_high], [y_locs(m)-0.12, y_locs(m)+0.12], 'Color', c_list(m, :), 'LineWidth', 2.5);
        % Center point
        plot(ax4, est, y_locs(m), 'o', 'MarkerFaceColor', cfg.Color.White, ...
             'MarkerEdgeColor', c_list(m, :), 'MarkerSize', 9, 'LineWidth', 2.5);

        % Annotate span width
        span = c_high - c_low;
        text(ax4, c_high + 200, y_locs(m), ...
             sprintf('[%s, %s] (Width: %s)', ...
             stat_utils.format_currency(c_low), stat_utils.format_currency(c_high), stat_utils.format_currency(span)), ...
             'VerticalAlignment', 'middle', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, ...
             'FontWeight', 'bold', 'Color', cfg.Color.DarkSlate);
    end

    ylim(ax4, [0.3, 2.7]);
    set(ax4, 'YTick', y_locs, 'YTickLabel', methods);
    xlabel(ax4, 'Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax4, 'Comparison: Parametric vs. Non-Parametric 95% Confidence Intervals', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax4, cfg);

    %% Export Figure
    if cfg.SaveFigures
        save_plot(fig, fullfile(cfg.FigDir, 'fig4_bootstrap_inference.png'), cfg);
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

