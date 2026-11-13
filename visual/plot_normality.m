function fig = plot_normality(tbl, norm_res, cfg)
% PLOT_NORMALITY - Visualizes Normality Assessments & Goodness-of-Fit
%
% Produces a 2x3 comprehensive diagnostic layout:
% Row 1: Histograms with Overlaid Gaussian PDF and KDE Fits
% Row 2: Standardized Quantile-Quantile (Q-Q) Plots with Reference Lines
%
% Columns:
% 1. ProductivityScore (Gaussian profile, H0 retained)
% 2. Annual Salary Raw (Right-skewed, H0 rejected)
% 3. Log-Transformed Salary (Normalized, H0 retained)
%
% Inputs:
%   tbl      - Dataset table
%   norm_res - Normality results from test_normality
%   cfg      - Configuration struct
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    if nargin < 3, cfg = config(); end

    fig = figure('Name', 'Section 2: Normality Testing & Diagnostics', ...
                 'Color', cfg.Color.White, ...
                 'Position', [70, 70, cfg.FigureWidth, cfg.FigureHeight]);

    t = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, 'Figure 2: Empirical Normality Testing, Q-Q Diagnostics & Log Transformation', ...
          'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTitle + 2, 'FontWeight', 'bold', ...
          'Color', cfg.Color.DarkSlate);

    series_list = {
        tbl.ProductivityScore, 'Productivity Score', norm_res.ProductivityScore, cfg.Color.PrimaryBlue;
        tbl.Salary,            'Salary (Raw USD)',    norm_res.SalaryRaw,          cfg.Color.CoralRed;
        tbl.LogSalary,         'Log-Salary ln(USD)', norm_res.LogSalary,          cfg.Color.EmeraldGreen
    };

    %% -------------------------------------------------------------------------
    %% Row 1: Histograms + Fitted Gaussian vs KDE
    %% -------------------------------------------------------------------------
    for c = 1:3
        ax = nexttile(t, c);
        hold(ax, 'on');

        x = series_list{c, 1};
        name = series_list{c, 2};
        res  = series_list{c, 3};
        col  = series_list{c, 4};

        % Histogram
        histogram(ax, x, 'Normalization', 'pdf', ...
                  'FaceColor', col, 'FaceAlpha', 0.35, ...
                  'EdgeColor', col, 'LineWidth', 0.8);

        % Smooth KDE
        [gx, dens] = stat_utils.kde(x, 250);
        h_kde = plot(ax, gx, dens, 'Color', col, 'LineWidth', 2.2);

        % Fitted Theoretical Normal PDF: N(mu, sigma^2)
        x_span = linspace(min(x), max(x), 300);
        pdf_norm = (1 / (res.Std * sqrt(2*pi))) * exp(-0.5 * ((x_span - res.Mean) / res.Std).^2);
        h_norm = plot(ax, x_span, pdf_norm, '--', 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.8);

        % Verdict Badge
        if res.JB_Reject
            badge_color = [cfg.Color.CoralRed, 0.15];
            badge_edge  = cfg.Color.CoralRed;
            badge_text  = sprintf('\\bfREJECT H0: Non-Normal\\rm\nJB = %.1f (%s)\nSkew = %+.2f, Kurt = %.2f', ...
                                  res.JB_Stat, stat_utils.format_pvalue(res.JB_PVal), res.Skewness, res.Kurtosis);
        else
            badge_color = [cfg.Color.EmeraldGreen, 0.15];
            badge_edge  = cfg.Color.EmeraldGreen;
            badge_text  = sprintf('\\bfACCEPT H0: Gaussian\\rm\nJB = %.2f (%s)\nSkew = %+.2f, Kurt = %.2f', ...
                                  res.JB_Stat, stat_utils.format_pvalue(res.JB_PVal), res.Skewness, res.Kurtosis);
        end

        text(ax, 0.05, 0.92, badge_text, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
             'BackgroundColor', badge_color, 'EdgeColor', badge_edge, ...
             'LineWidth', 1.2, 'Margin', 6, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick);

        xlabel(ax, name, 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
        ylabel(ax, 'Probability Density', 'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
        title(ax, sprintf('%s: Density & Normal Fit', name), ...
              'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
        legend(ax, [h_kde, h_norm], {'Empirical KDE', 'Fitted Gaussian N(\mu,\sigma^2)'}, ...
               'Location', 'northeast', 'Box', 'off', 'FontSize', cfg.FontSizeTick - 1);
        format_axes(ax, cfg);
    end

    %% -------------------------------------------------------------------------
    %% Row 2: Standardized Quantile-Quantile (Q-Q) Plots
    %% -------------------------------------------------------------------------
    for c = 1:3
        ax = nexttile(t, c + 3);
        hold(ax, 'on');

        res  = series_list{c, 3};
        name = series_list{c, 2};
        col  = series_list{c, 4};

        q_theo = res.QQ_Theo;
        q_samp = res.QQ_Sample;

        % 45-Degree Theoretical Gaussian Reference Line
        ref_x = linspace(-3.5, 3.5, 100);
        plot(ax, ref_x, ref_x, '--', 'Color', cfg.Color.DarkSlate, 'LineWidth', 1.8);

        % Empirical Quantile Points
        scatter(ax, q_theo, q_samp, 24, col, 'filled', ...
                'MarkerFaceAlpha', 0.55, 'MarkerEdgeColor', [col * 0.7, 0.8]);

        % Annotate Key Quartiles (-1 and +1 std)
        plot(ax, [-1, -1], [-3.5, 3.5], ':', 'Color', cfg.Color.GridGray, 'LineWidth', 1.0);
        plot(ax, [1, 1], [-3.5, 3.5], ':', 'Color', cfg.Color.GridGray, 'LineWidth', 1.0);

        xlim(ax, [-3.5, 3.5]);
        ylim(ax, [-3.5, 3.5]);

        if c == 1
            qq_annotation = 'Linear alignment confirms Gaussianity';
        elseif c == 2
            qq_annotation = 'Upward curvature indicates heavy right tail';
        else
            qq_annotation = 'Log transform restores linear alignment';
        end

        text(ax, 0.05, 0.12, qq_annotation, 'Units', 'normalized', ...
             'BackgroundColor', [cfg.Color.LightGray, 0.85], 'EdgeColor', cfg.Color.CardBorder, ...
             'FontName', cfg.FontName, 'FontSize', cfg.FontSizeTick, 'FontAngle', 'italic');

        xlabel(ax, 'Theoretical Standard Normal Quantiles', ...
               'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
        ylabel(ax, 'Standardized Sample Quantiles', ...
               'FontName', cfg.FontName, 'FontSize', cfg.FontSizeLabel, 'FontWeight', 'bold');
        title(ax, sprintf('%s: Normal Q-Q Plot', name), ...
              'FontName', cfg.FontName, 'FontSize', cfg.FontSizeSubtitle, 'FontWeight', 'bold');
        format_axes(ax, cfg);
    end

    %% Export Figure
    if cfg.SaveFigures
        save_plot(fig, fullfile(cfg.FigDir, 'fig2_normality_tests.png'), cfg);
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

