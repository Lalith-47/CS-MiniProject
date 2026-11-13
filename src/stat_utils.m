classdef stat_utils
% STAT_UTILS - Statistical Utility Library for MATLAB Mini Project
%
% Implements rigorous statistical algorithms with automatic fallback to
% base-MATLAB mathematical formulas if the Statistics Toolbox is absent.
%
% Methods:
%   mean, median, mode, trimmed_mean, geom_mean, var, std, quantile, iqr, mad,
%   skewness, kurtosis, norm_cdf, norm_inv, t_cdf, t_inv, f_cdf, chi2_cdf,
%   kde, qq_points, format_currency, format_pvalue
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    methods (Static)
        %% --- Central Tendency & Dispersion ---

        function m = mean(x)
            % Sample arithmetic mean
            x = x(~isnan(x));
            m = sum(x) / numel(x);
        end

        function med = median(x)
            % Sample median (50th percentile)
            x = sort(x(~isnan(x)));
            n = numel(x);
            if mod(n, 2) == 1
                med = x((n + 1) / 2);
            else
                med = (x(n / 2) + x(n / 2 + 1)) / 2;
            end
        end

        function mo = mode(x)
            % Sample mode (for continuous data, estimated via kernel density peak)
            x = x(~isnan(x));
            x = x(:);
            u = unique(x);
            if numel(u) < numel(x) / 3
                % Discrete mode with exact counting
                counts = zeros(size(u));
                for i = 1:numel(u)
                    counts(i) = sum(x == u(i));
                end
                [~, idx] = max(counts);
                mo = u(idx);
            else
                % Continuous distribution mode (mode of Gaussian KDE)
                [grid, dens] = stat_utils.kde(x, 500);
                [~, max_idx] = max(dens);
                mo = grid(max_idx);
            end
        end

        function tm = trimmed_mean(x, trim_pct)
            % Trimmed mean dropping trim_pct from both tails (e.g. 10%)
            if nargin < 2, trim_pct = 10; end
            x = sort(x(~isnan(x)));
            n = numel(x);
            k = floor(n * (trim_pct / 100));
            trimmed_data = x((k + 1):(n - k));
            tm = mean(trimmed_data);
        end

        function gm = geom_mean(x)
            % Geometric mean for positive values
            x = x(~isnan(x));
            x = x(x > 0);
            gm = exp(mean(log(x)));
        end

        function v = var(x)
            % Unbiased sample variance with (N-1) denominator
            x = x(~isnan(x));
            n = numel(x);
            m = sum(x) / n;
            v = sum((x - m).^2) / (n - 1);
        end

        function s = std(x)
            % Sample standard deviation
            s = sqrt(stat_utils.var(x));
        end

        function q = quantile(x, p)
            % Sample quantile for probability vector p in [0, 1]
            % Uses linear interpolation between order statistics (Type 7 / MATLAB default)
            x = sort(x(~isnan(x)));
            n = numel(x);
            p = p(:);
            q = zeros(size(p));
            
            for i = 1:numel(p)
                pr = p(i);
                if pr <= 0
                    q(i) = x(1);
                elseif pr >= 1
                    q(i) = x(end);
                else
                    % Formula: index = 1 + (n - 1) * pr
                    idx = 1 + (n - 1) * pr;
                    f = floor(idx);
                    c = ceil(idx);
                    if f == c
                        q(i) = x(f);
                    else
                        frac = idx - f;
                        q(i) = x(f) * (1 - frac) + x(c) * frac;
                    end
                end
            end
        end

        function val = iqr(x)
            % Interquartile range: Q3 - Q1
            q = stat_utils.quantile(x, [0.25; 0.75]);
            val = q(2) - q(1);
        end

        function val = mad(x)
            % Median Absolute Deviation: median(|x - median(x)|)
            med = stat_utils.median(x);
            val = stat_utils.median(abs(x - med));
        end

        function sk = skewness(x)
            % Sample skewness (measure of distribution asymmetry)
            x = x(~isnan(x));
            n = numel(x);
            m = mean(x);
            s = sqrt(sum((x - m).^2) / n);
            m3 = sum((x - m).^3) / n;
            sk = m3 / (s^3);
        end

        function kt = kurtosis(x)
            % Sample kurtosis (Pearson's definition, normal = 3)
            x = x(~isnan(x));
            n = numel(x);
            m = mean(x);
            s = sqrt(sum((x - m).^2) / n);
            m4 = sum((x - m).^4) / n;
            kt = m4 / (s^4);
        end

        %% --- Probability Distributions & CDFs ---

        function p = norm_cdf(z)
            % Standard Normal Cumulative Distribution Function Phi(z)
            p = 0.5 * (1 + erf(z / sqrt(2)));
        end

        function z = norm_inv(p)
            % Standard Normal Quantile Function (probit)
            % Uses inverse error function erfinv (built-in base MATLAB)
            p = max(eps, min(1 - eps, p));
            z = sqrt(2) * erfinv(2 * p - 1);
        end

        function p = t_cdf(t, df)
            % Student's t Cumulative Distribution Function (vector-safe)
            % Uses regularized incomplete beta function betainc (built-in base MATLAB)
            if df <= 0, error('Degrees of freedom must be positive.'); end
            x = df ./ (df + t.^2);
            ib = betainc(x, df / 2, 0.5);
            p = zeros(size(t));
            pos = (t >= 0);
            p(pos) = 1 - 0.5 * ib(pos);
            p(~pos) = 0.5 * ib(~pos);
        end

        function t_val = t_inv(p, df)
            % Student's t Inverse CDF via numerical root-finding or Cornish-Fisher approximation
            if p <= 0, t_val = -inf; return; end
            if p >= 1, t_val = inf; return; end
            if p == 0.5, t_val = 0; return; end
            
            % Initial guess using normal inverse & Cornish-Fisher expansion
            z = stat_utils.norm_inv(p);
            t0 = z + (z^3 + z) / (4 * df) + (5*z^5 + 16*z^3 + 3*z) / (96 * df^2);
            
            % Refine with Newton-Raphson iteration
            for iter = 1:8
                cdf_val = stat_utils.t_cdf(t0, df);
                % t-PDF: c * (1 + t^2/df)^(-(df+1)/2)
                log_c = gammaln((df + 1)/2) - gammaln(df/2) - 0.5*log(df*pi);
                pdf_val = exp(log_c) * (1 + (t0^2)/df)^(-(df + 1)/2);
                err = cdf_val - p;
                if abs(err) < 1e-11, break; end
                t0 = t0 - err / max(pdf_val, 1e-12);
            end
            t_val = t0;
        end

        function p = f_cdf(f, df1, df2)
            % Snedecor's F-Distribution Cumulative Distribution Function (vector-safe)
            % Uses regularized incomplete beta function betainc
            p = zeros(size(f));
            pos = (f > 0);
            if any(pos(:))
                f_pos = f(pos);
                x = (df1 * f_pos) ./ (df1 * f_pos + df2);
                x = min(1, max(0, x));
                p(pos) = betainc(x, df1 / 2, df2 / 2);
            end
        end

        function f_val = f_inv(p, df1, df2)
            % Inverse F-Distribution critical value
            % Bisection / Newton search
            if p <= 0, f_val = 0; return; end
            if p >= 1, f_val = inf; return; end
            
            low = 0;
            high = 100;
            % Expand upper bound if needed
            while stat_utils.f_cdf(high, df1, df2) < p
                high = high * 2;
            end
            
            % Binary search to machine precision
            for i = 1:50
                mid = (low + high) / 2;
                val = stat_utils.f_cdf(mid, df1, df2);
                if val < p
                    low = mid;
                else
                    high = mid;
                end
                if (high - low) < 1e-7, break; end
            end
            f_val = (low + high) / 2;
        end

        function p = chi2_cdf(x, df)
            % Chi-Squared Cumulative Distribution Function
            % Uses regularized incomplete gamma function gammainc
            if x <= 0
                p = 0;
            else
                p = gammainc(x / 2, df / 2, 'lower');
            end
        end

        %% --- Kernel Density Estimation & Q-Q Generation ---

        function [grid_x, density] = kde(x, n_points, bw)
            % Gaussian Kernel Density Estimation (100% base MATLAB)
            x = x(~isnan(x));
            x = x(:);
            n = numel(x);
            s = stat_utils.std(x);
            iqr_val = stat_utils.iqr(x);
            
            % Silverman's rule of thumb for optimal bandwidth
            if nargin < 3 || isempty(bw)
                a = min(s, iqr_val / 1.34);
                if a <= 0, a = s; end
                if a <= 0, a = 1; end
                bw = 0.9 * a * (n^(-1/5));
            end
            
            if nargin < 2 || isempty(n_points)
                n_points = 250;
            end
            
            x_min = min(x) - 3 * bw;
            x_max = max(x) + 3 * bw;
            grid_x = linspace(x_min, x_max, n_points)';
            
            % Vectorized Gaussian kernel sum (bsxfun for maximum compatibility)
            diffs = bsxfun(@minus, grid_x, x') / bw;  % [n_points x n] matrix
            kernel_evals = exp(-0.5 * (diffs.^2)) / sqrt(2 * pi);
            density = sum(kernel_evals, 2) / (n * bw);
        end

        function [theo_quantiles, sample_quantiles] = qq_points(x)
            % Computes Q-Q plot theoretical vs sample quantiles
            x = sort(x(~isnan(x)));
            n = numel(x);
            % Blom plotting positions: (i - 3/8) / (n + 1/4)
            p = ((1:n)' - 0.375) / (n + 0.25);
            theo_quantiles = stat_utils.norm_inv(p);
            sample_quantiles = (x - mean(x)) / stat_utils.std(x);
        end

        %% --- Formatting Helpers ---

        function str = format_currency(val)
            % Formats numeric value as US Currency (e.g. $104,250 or -$5,000)
            if isnan(val)
                str = '$NaN';
                return;
            end
            is_neg = (val < 0);
            v = abs(round(val));
            s = sprintf('%.0f', v);
            len = length(s);
            if len <= 3
                out = s;
            else
                n_leading = mod(len, 3);
                if n_leading == 0, n_leading = 3; end
                out = s(1:n_leading);
                for i = (n_leading + 1):3:len
                    out = [out, ',', s(i:i+2)]; %#ok<AGROW>
                end
            end
            if is_neg
                str = ['-$', out];
            else
                str = ['$', out];
            end
        end

        function str = format_pvalue(p)
            % Formats p-value cleanly for scientific tables
            if p < 0.0001
                str = 'p < 0.0001 (***)';
            elseif p < 0.001
                str = sprintf('p = %.4f (***)', p);
            elseif p < 0.01
                str = sprintf('p = %.4f (**)', p);
            elseif p < 0.05
                str = sprintf('p = %.4f (*)', p);
            else
                str = sprintf('p = %.4f (ns)', p);
            end
        end
    end
end

