function cfg = config()
% CONFIG - Global Configuration for Employee Productivity & Salary Project
%
% Defines dataset parameters, statistical parameters, color themes,
% figure dimensions, and output directories.
%
% Author: Antigravity AI & Pair Programmer
% Project: MATLAB Mini Project - Employee Productivity & Salary Analysis

    %% 1. Random Number Seed & Sample Size
    cfg.Seed = 42;               % Fixed seed for exact reproducibility
    cfg.SampleSize = 500;        % N = 500 employee records
    cfg.Alpha = 0.05;            % Standard significance level (95% confidence)

    %% 2. Bootstrap Parameters
    cfg.BootstrapReplicates = 3000; % B = 3000 resamples for high Monte Carlo precision
    cfg.ConvergenceStep = 50;       % Sample interval for convergence tracking

    %% 3. Directory Paths
    cfg.RootDir = fileparts(mfilename('fullpath'));
    cfg.DataDir = fullfile(cfg.RootDir, 'data');
    cfg.SrcDir  = fullfile(cfg.RootDir, 'src');
    cfg.VisDir  = fullfile(cfg.RootDir, 'visual');
    cfg.FigDir  = fullfile(cfg.RootDir, 'figures');
    cfg.CsvPath = fullfile(cfg.DataDir, 'employee_data.csv');

    % Create folders if they do not exist
    dirs = {cfg.DataDir, cfg.SrcDir, cfg.VisDir, cfg.FigDir};
    for i = 1:numel(dirs)
        if ~exist(dirs{i}, 'dir')
            mkdir(dirs{i});
        end
    end

    %% 4. Visual Styling & Modern Color Palette
    % Executive Professional Theme
    cfg.Color.PrimaryBlue   = [0.12, 0.44, 0.73];  % #1F70BA - Royal Navy Blue
    cfg.Color.AccentTeal    = [0.12, 0.68, 0.68];  % #1FAEB0 - Modern Teal
    cfg.Color.CoralRed      = [0.92, 0.30, 0.24];  % #EB4C3D - Crimson / Coral
    cfg.Color.EmeraldGreen  = [0.18, 0.70, 0.44];  % #2FB370 - Emerald Green
    cfg.Color.AmberGold     = [0.95, 0.62, 0.08];  % #F39E14 - Amber / Gold
    cfg.Color.Purple        = [0.55, 0.28, 0.68];  % #8C47AE - Deep Purple
    cfg.Color.DarkSlate     = [0.15, 0.18, 0.22];  % #262E38 - Dark Slate (Text & Axes)
    cfg.Color.LightGray     = [0.95, 0.96, 0.97];  % #F2F5F8 - Card Background
    cfg.Color.GridGray      = [0.88, 0.89, 0.91];  % #E0E3E8 - Gridlines
    cfg.Color.CardBorder    = [0.80, 0.83, 0.87];  % #CCD4DE - Card Borders
    cfg.Color.White         = [1.00, 1.00, 1.00];

    % Categorical Department Palette
    cfg.Color.DeptPalette = [
        0.12, 0.44, 0.73;  % Engineering - Navy Blue
        0.18, 0.70, 0.44;  % Data Science - Emerald
        0.95, 0.62, 0.08;  % Sales - Amber Gold
        0.55, 0.28, 0.68;  % Marketing - Purple
        0.92, 0.30, 0.24   % Human Resources - Coral
    ];

    %% 5. Typography & Export Settings
    cfg.FontName = 'Helvetica';  % Clean universally-available font
    cfg.FontSizeTitle = 13;
    cfg.FontSizeSubtitle = 11;
    cfg.FontSizeLabel = 10;
    cfg.FontSizeTick = 9;
    cfg.FigureWidth = 1350;
    cfg.FigureHeight = 850;
    cfg.DPI = 300;               % High-resolution 300 DPI for publication quality
    cfg.SaveFigures = true;      % Automatically save figures to figures/ directory
end

