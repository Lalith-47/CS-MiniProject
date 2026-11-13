function fig = plot_central_tendency(tbl, ct, cfg)
% PLOT_CENTRAL_TENDENCY - Generates Publication-Quality Central Tendency Visuals
%
% Visualizes:
% 1. Productivity Score Distribution (Histogram, KDE, Mean/Median/Mode markers)
% 2. Annual Salary Distribution (Demonstrating positive skewness)
% 3. Department-level Distribution (Boxplot with jittered scatter overlay)
% 4. Executive Statistical Metrics Comparison Card
%
% Inputs:
%   tbl - Dataset table
%   ct  - Central tendency results from calc_central_tendency
%   cfg - Configuration struct
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 3, cfg = config(); end

    fig = figure('Name', 'Section 1: Central Tendency & Dispersion', ...
                 'Color', cfg.Color.White, ...
                 'Position', [50, 50, cfg.FigureWidth, cfg.FigureHeight]);

    t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, 'Figure 1: Employee Productivity & Salary - Central Tendency & Dispersion Analysis', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTitle + 2, 'FontWeight', 'bold', ...
          'Color', cfg.Color.DarkSlate);

    %% -------------------------------------------------------------------------
    %% Tile 1: Productivity Distribution & Central Tendency
    %% -------------------------------------------------------------------------
    ax1 = nexttile(t, 1);
    hold(ax1, 'on');

    p = tbl.ProductivityScore;
    % Histogram
    h1 = histogram(ax1, p, 'Normalization', 'pdf', ...
                   'FaceColor', cfg.Color.PrimaryBlue, 'FaceAlpha', 0.40, ...
                   'EdgeColor', cfg.Color.PrimaryBlue, 'LineWidth', 0.8);

    % KDE Curve
    [grid_p, dens_p] = stat_utils.kde(p, 300);
    plot(ax1, grid_p, dens_p, 'Color', cfg.Color.PrimaryBlue, 'LineWidth', 2.5);

    % Central Tendency Markers
    y_limits = ylim(ax1);
    y_max = y_limits(2) * 1.05;
    ylim(ax1, [0, y_max]);

    l_mean = xline(ax1, ct.Prod.Mean, 'Color', [0.05, 0.25, 0.55], 'LineWidth', 2.2, 'LineStyle', '-');
    l_med  = xline(ax1, ct.Prod.Median, 'Color', cfg.Color.CoralRed, 'LineWidth', 2.2, 'LineStyle', '--');
    l_mode = xline(ax1, ct.Prod.Mode, 'Color', cfg.Color.AccentTeal, 'LineWidth', 2.0, 'LineStyle', ':');

    % Metric Annotation Box
    msg_prod = sprintf(['\\bfProductivity Metrics\\rm\n', ...
                        'Mean: %.2f pts\n', ...
                        'Median: %.2f pts\n', ...
                        'Mode: %.2f pts\n', ...
                        'Std Dev: %.2f pts\n', ...
                        'IQR: %.2f pts\n', ...
                        'Skewness: %.2f (Symmetric)'], ...
                        ct.Prod.Mean, ct.Prod.Median, ct.Prod.Mode, ...
                        ct.Prod.Std, ct.Prod.IQR, ct.Prod.Skewness);
    text(ax1, 0.04, 0.93, msg_prod, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [cfg.Color.LightGray, 0.90], 'EdgeColor', cfg.Color.CardBorder, ...
         'LineWidth', 1.0, 'Margin', 8, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    xlabel(ax1, 'Productivity Score (pts)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax1, 'Probability Density', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax1, 'Productivity Score Distribution (Near-Gaussian Profile)', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    legend(ax1, [l_mean, l_med, l_mode], ...
           {sprintf('Mean (%.1f)', ct.Prod.Mean), sprintf('Median (%.1f)', ct.Prod.Median), sprintf('Mode (%.1f)', ct.Prod.Mode)}, ...
           'Location', 'northeast', 'Box', 'off', 'FontSize', cfg.FontSizeTick);
    format_axes(ax1, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 2: Salary Distribution (Positive Skewness)
    %% -------------------------------------------------------------------------
    ax2 = nexttile(t, 2);
    hold(ax2, 'on');

    s = tbl.Salary;
    h2 = histogram(ax2, s, 'Normalization', 'pdf', ...
                   'FaceColor', cfg.Color.EmeraldGreen, 'FaceAlpha', 0.40, ...
                   'EdgeColor', cfg.Color.EmeraldGreen, 'LineWidth', 0.8);

    [grid_s, dens_s] = stat_utils.kde(s, 300);
    plot(ax2, grid_s, dens_s, 'Color', [0.10, 0.52, 0.30], 'LineWidth', 2.5);

    y_limits2 = ylim(ax2);
    y_max2 = y_limits2(2) * 1.05;
    ylim(ax2, [0, y_max2]);

    l2_mean = xline(ax2, ct.Salary.Mean, 'Color', [0.05, 0.25, 0.55], 'LineWidth', 2.2, 'LineStyle', '-');
    l2_med  = xline(ax2, ct.Salary.Median, 'Color', cfg.Color.CoralRed, 'LineWidth', 2.2, 'LineStyle', '--');

    % Annotated Skewness Arrow
    delta_sal = ct.Salary.Mean - ct.Salary.Median;
    x_mid = (ct.Salary.Mean + ct.Salary.Median) / 2;
    text(ax2, ct.Salary.Mean + 2000, y_max2 * 0.70, ...
         sprintf('\\leftarrow Mean > Median by %s\n(Positive Right Skew)', stat_utils.format_currency(delta_sal)), ...
         'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, 'Color', cfg.Color.DarkSlate, 'FontWeight', 'bold');

    msg_sal = sprintf(['\\bfSalary Metrics\\rm\n', ...
                       'Mean: %s\n', ...
                       'Median: %s\n', ...
                       '10%% Trimmed: %s\n', ...
                       'Std Dev: %s\n', ...
                       'IQR: %s\n', ...
                       'Skewness: +%.2f (Right-Skewed)'], ...
                       stat_utils.format_currency(ct.Salary.Mean), ...
                       stat_utils.format_currency(ct.Salary.Median), ...
                       stat_utils.format_currency(ct.Salary.TrimmedMean), ...
                       stat_utils.format_currency(ct.Salary.Std), ...
                       stat_utils.format_currency(ct.Salary.IQR), ...
                       ct.Salary.Skewness);
    text(ax2, 0.65, 0.93, msg_sal, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [cfg.Color.LightGray, 0.90], 'EdgeColor', cfg.Color.CardBorder, ...
         'LineWidth', 1.0, 'Margin', 8, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

    xlabel(ax2, 'Annual Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    ylabel(ax2, 'Probability Density', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax2, 'Annual Salary Distribution (Right-Skewed Earnings Profile)', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    legend(ax2, [l2_mean, l2_med], ...
           {sprintf('Mean (%s)', stat_utils.format_currency(ct.Salary.Mean)), ...
            sprintf('Median (%s)', stat_utils.format_currency(ct.Salary.Median))}, ...
           'Location', 'northwest', 'Box', 'off', 'FontSize', cfg.FontSizeTick);
    format_axes(ax2, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 3: Department-Level Boxplots with Jittered Scatter
    %% -------------------------------------------------------------------------
    ax3 = nexttile(t, 3);
    hold(ax3, 'on');

    depts = ct.DeptNames;
    n_depts = numel(depts);
    colors_dept = cfg.Color.DeptPalette;

    for i = 1:n_depts
        dept_name = depts{i};
        mask = (tbl.Department == dept_name);
        p_sub = tbl.ProductivityScore(mask);
        n_sub = numel(p_sub);

        % Jittered raw points
        jitter = (rand(n_sub, 1) - 0.5) * 0.28;
        scatter(ax3, i + jitter, p_sub, 22, colors_dept(i, :), 'filled', ...
                'MarkerFaceAlpha', 0.40, 'MarkerEdgeAlpha', 0.60);

        % Box plot metrics
        q = stat_utils.quantile(p_sub, [0.25; 0.50; 0.75]);
        q1 = q(1); qmed = q(2); q3 = q(3);
        iqr_box = q3 - q1;
        whisker_low = max(min(p_sub), q1 - 1.5 * iqr_box);
        whisker_upp = min(max(p_sub), q3 + 1.5 * iqr_box);

        % Draw Whisker lines
        plot(ax3, [i, i], [whisker_low, q1], 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.2);
        plot(ax3, [i, i], [q3, whisker_upp], 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.2);
        plot(ax3, [i - 0.1, i + 0.1], [whisker_low, whisker_low], 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.2);
        plot(ax3, [i - 0.1, i + 0.1], [whisker_upp, whisker_upp], 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.2);

        % Draw Interquartile Box
        patch(ax3, [i-0.24, i+0.24, i+0.24, i-0.24], [q1, q1, q3, q3], ...
              colors_dept(i, :), 'FaceAlpha', 0.65, 'EdgeColor', cfg.Color.DarkSlate, 'LineWidth', 1.2);

        % Median Line
        plot(ax3, [i-0.24, i+0.24], [qmed, qmed], 'Color', cfg.Color.White, 'LineWidth', 2.5);

        % Mean Marker (Diamond)
        m_dept = stat_utils.mean(p_sub);
        plot(ax3, i, m_dept, 'd', 'MarkerFaceColor', cfg.Color.AmberGold, ...
             'MarkerEdgeColor', cfg.Color.DarkSlate, 'MarkerSize', 8, 'LineWidth', 1.2);
    end

    set(ax3, 'XTick', 1:n_depts, 'XTickLabel', depts);
    xtickangle(ax3, 15);
    ylabel(ax3, 'Productivity Score (pts)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
    title(ax3, 'Productivity Distribution Across Departments (Boxplot + Jitter Overlay)', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
    format_axes(ax3, cfg);

    %% -------------------------------------------------------------------------
    %% Tile 4: Executive Infographic Summary Table
    %% -------------------------------------------------------------------------
    ax4 = nexttile(t, 4);
    axis(ax4, 'off');
    hold(ax4, 'on');

    % Render stylized graphical summary card
    patch(ax4, [0.02, 0.98, 0.98, 0.02], [0.02, 0.02, 0.98, 0.98], ...
          cfg.Color.LightGray, 'EdgeColor', cfg.Color.CardBorder, 'LineWidth', 1.5);

    % Card Header
    patch(ax4, [0.02, 0.98, 0.98, 0.02], [0.85, 0.85, 0.98, 0.98], ...
          cfg.Color.PrimaryBlue, 'EdgeColor', cfg.Color.PrimaryBlue);
    text(ax4, 0.50, 0.915, 'CENTRAL TENDENCY & DISPERSION SUMMARY TABLE', ...
         'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold', ...
         'Color', cfg.Color.White, 'HorizontalAlignment', 'center');

    % Column Headers
    y_row = 0.79;
    text(ax4, 0.06, y_row, 'Statistical Metric', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick + 1, 'FontWeight', 'bold', 'Color', cfg.Color.DarkSlate);
    text(ax4, 0.48, y_row, 'Productivity Score', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick + 1, 'FontWeight', 'bold', 'Color', cfg.Color.PrimaryBlue);
    text(ax4, 0.76, y_row, 'Annual Salary (USD)', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick + 1, 'FontWeight', 'bold', 'Color', [0.10, 0.52, 0.30]);
    plot(ax4, [0.05, 0.95], [y_row - 0.03, y_row - 0.03], 'Color', cfg.Color.CardBorder, 'LineWidth', 1.0);

    % Metrics Rows
    rows = {
        'Sample Size (N)',      sprintf('%d employees', numel(p)), sprintf('%d employees', numel(s));
        'Arithmetic Mean',     sprintf('%.2f pts', ct.Prod.Mean), stat_utils.format_currency(ct.Salary.Mean);
        'Median (50th %tile)', sprintf('%.2f pts', ct.Prod.Median), stat_utils.format_currency(ct.Salary.Median);
        'Estimated Mode',      sprintf('%.2f pts', ct.Prod.Mode), stat_utils.format_currency(ct.Salary.Mode);
        '10% Trimmed Mean',    sprintf('%.2f pts', ct.Prod.TrimmedMean), stat_utils.format_currency(ct.Salary.TrimmedMean);
        'Geometric Mean',      sprintf('%.2f pts', ct.Prod.GeomMean), stat_utils.format_currency(ct.Salary.GeomMean);
        'Standard Deviation',  sprintf('%.2f pts', ct.Prod.Std), stat_utils.format_currency(ct.Salary.Std);
        'Interquartile Range', sprintf('%.2f pts', ct.Prod.IQR), stat_utils.format_currency(ct.Salary.IQR);
        'Median Abs Dev (MAD)',sprintf('%.2f pts', ct.Prod.MAD), stat_utils.format_currency(ct.Salary.MAD);
        'Range (Max - Min)',   sprintf('%.1f to %.1f (%.1f)', ct.Prod.Min, ct.Prod.Max, ct.Prod.Range), ...
                               sprintf('%s to %s', stat_utils.format_currency(ct.Salary.Min), stat_utils.format_currency(ct.Salary.Max));
        'Fisher Skewness',     sprintf('%+.2f (Symmetric)', ct.Prod.Skewness), sprintf('%+.2f (Right-Skewed)', ct.Salary.Skewness);
        'Pearson Kurtosis',    sprintf('%.2f (Mesokurtic)', ct.Prod.Kurtosis), sprintf('%.2f (Leptokurtic)', ct.Salary.Kurtosis);
    };

    y_pos = 0.71;
    for r = 1:size(rows, 1)
        text(ax4, 0.06, y_pos, rows{r, 1}, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, 'Color', cfg.Color.DarkSlate);
        text(ax4, 0.48, y_pos, rows{r, 2}, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, 'FontWeight', 'bold', 'Color', cfg.Color.DarkSlate);
        text(ax4, 0.76, y_pos, rows{r, 3}, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, 'FontWeight', 'bold', 'Color', cfg.Color.DarkSlate);
        y_pos = y_pos - 0.053;
    end

    xlim(ax4, [0, 1]);
    ylim(ax4, [0, 1]);

    %% Export Figure
    if cfg.SaveFigures
        save_plot(fig, fullfile(cfg.FigDir, 'fig1_central_tendency.png'), cfg);
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

