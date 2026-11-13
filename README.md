# Employee Productivity & Salary: Advanced Statistical & Econometric Analysis

[![MATLAB](https://img.shields.io/badge/MATLAB-R2018b%20to%20R2024b%2B-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![Toolbox-Free](https://img.shields.io/badge/Dependencies-Zero%20Commercial%20Toolboxes-brightgreen.svg)](#zero-toolbox-dependency)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Sample Size](https://img.shields.io/badge/Sample%20Size-N%20%3D%20500-orange.svg)](#dataset-specification)
[![Bootstrap Replicates](https://img.shields.io/badge/Bootstrap-B%20%3D%203000-purple.svg)](#section-4-non-parametric-bootstrap-resampling)

A comprehensive, publication-grade MATLAB computational project investigating the structural determinants of workplace productivity and employee compensation dynamics. The project implements a complete econometric and statistical workflow encompassing **Central Tendency**, **Normality Testing**, **Hypothesis Testing**, **Non-Parametric Bootstrap Resampling**, and **Ordinary Least Squares (OLS) Regression Diagnostics**.

Designed with clean software engineering principles, the codebase runs out-of-the-box on **base MATLAB** without requiring the commercial Statistics and Machine Learning Toolbox™.

---

## Table of Contents
1. [Project Highlights](#project-highlights)
2. [Statistical Architecture](#statistical-architecture)
3. [Core Statistical Modules](#core-statistical-modules)
   - [Section 1: Central Tendency & Dispersion](#section-1-central-tendency--dispersion)
   - [Section 2: Normality Testing & Goodness-of-Fit](#section-2-normality-testing--goodness-of-fit)
   - [Section 3: Inferential Hypothesis Testing](#section-3-inferential-hypothesis-testing)
   - [Section 4: Non-Parametric Bootstrap Resampling](#section-4-non-parametric-bootstrap-resampling)
   - [Section 5: Econometric Regression & Residual Diagnostics](#section-5-econometric-regression--residual-diagnostics)
   - [Section 6: Master Executive Dashboard](#section-6-master-executive-dashboard)
4. [Visual Gallery & Figure Overview](#visual-gallery--figure-overview)
5. [Repository Structure](#repository-structure)
6. [Getting Started & Execution Guide](#getting-started--execution-guide)
7. [Mathematical Formulations](#mathematical-formulations)
8. [Empirical Insights & Managerial Takeaways](#empirical-insights--managerial-takeaways)
9. [Zero-Toolbox Dependency Implementation](#zero-toolbox-dependency-implementation)

---

## Project Highlights

- **5-Pillar Statistical Suite**: Complete coverage of Descriptive Statistics, Normality Diagnostics, Inferential Hypothesis Testing, Monte Carlo Resampling, and Econometric Modeling.
- **Publication-Quality Visuals**: High-resolution figures (300 DPI) generated via MATLAB's `tiledlayout` with modern executive color styling, shaded confidence/prediction ribbons, and styled infographic cards.
- **100% Native Base MATLAB**: All statistical algorithms (Student's $t$, Snedecor's $F$, Chi-Square CDFs, Cornish-Fisher expansions, Kernel Density Estimation, and matrix-form OLS) are built from pure mathematical primitives (`betainc`, `gammainc`, `erf`, `erfinv`).
- **Reproducible Data Pipeline**: Controlled pseudo-random number generator (`rng(42, 'twister')`) generating realistic workforce dynamics with non-linear fatigue thresholds, hybrid remote-work bonuses, and log-normal salary asymmetry.

---

## Statistical Architecture

```
+-----------------------------------------------------------------------------------+
|                        EMPLOYEE PRODUCTIVITY & SALARY PIPELINE                    |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
                         +---------------------------------+
                         |      generate_dataset.m         |
                         |   (N = 500 Employees, 10 Vars)  |
                         +---------------------------------+
                                          |
        +-------------------+-------------+-------------+-------------------+
        |                   |                           |                   |
        v                   v                           v                   v
+---------------+   +---------------+           +---------------+   +---------------+
|   Module 1    |   |   Module 2    |           |   Module 3    |   |   Module 4    |
|    Central    |   |   Normality   |           |  Hypothesis   |   |   Bootstrap   |
|   Tendency    |   |    Testing    |           |    Testing    |   |   Inference   |
+---------------+   +---------------+           +---------------+   +---------------+
| Mean, Median, |   | Jarque-Bera,  |           | Welch t-Test, |   | B=3000 reps,  |
| Mode, StDev,  |   | Lilliefors,   |           | One-Way ANOVA,|   | Percentile vs |
| Skewness, IQR |   | Q-Q Plots,    |           | Pearson &     |   | Normal CI,    |
| & Dept Stats  |   | Log-Transform |           | Spearman Rho  |   | Convergence   |
+---------------+   +---------------+           +---------------+   +---------------+
        |                   |                           |                   |
        +-------------------+-------------+-------------+-------------------+
                                          |
                                          v
                                 +-----------------+
                                 |    Module 5     |
                                 |  OLS Regression |
                                 +-----------------+
                                 | Simple & Multi  |
                                 | OLS, Conf/Pred  |
                                 | Bands, Cook's D |
                                 +-----------------+
                                          |
                                          v
                                 +-----------------+
                                 |  Master Figures |
                                 |  (Figures 1-6)  |
                                 +-----------------+
```

---

## Core Statistical Modules

### Section 1: Central Tendency & Dispersion
- **Script**: [`src/calc_central_tendency.m`](src/calc_central_tendency.m)
- **Visualizer**: [`visual/plot_central_tendency.m`](visual/plot_central_tendency.m)
- **Key Metrics Evaluated**:
  - **Location**: Arithmetic Mean, Median (50th percentile), Mode (via continuous Kernel Density Estimation peak), 10% Symmetric Trimmed Mean, Geometric Mean.
  - **Dispersion**: Standard Deviation ($s$), Unbiased Variance ($s^2$), Interquartile Range ($IQR = Q_3 - Q_1$), Median Absolute Deviation ($MAD$), Total Range.
  - **Shape**: Fisher Skewness ($g_1$) and Pearson Kurtosis ($g_2$).
  - **Departmental Breakdowns**: Metrics segmented across Engineering, Data Science, Sales, Marketing, and Human Resources with jittered scatter overlays.

### Section 2: Normality Testing & Goodness-of-Fit
- **Script**: [`src/test_normality.m`](src/test_normality.m)
- **Visualizer**: [`visual/plot_normality.m`](visual/plot_normality.m)
- **Series Tested**:
  1. `ProductivityScore`: Engineered to reflect natural Gaussian human performance.
  2. `Salary (Raw USD)`: Exhibits strong right-skewness typical of labor compensation data.
  3. `LogSalary (ln USD)`: Evaluates normalization via logarithmic variance-stabilizing transformation.
- **Formal Tests**:
  - **Jarque-Bera Test**: Assesses asymptotic joint normality of skewness and kurtosis against $\chi^2(2)$.
  - **Lilliefors / Kolmogorov-Smirnov Distance**: Measures supremum discrepancy between empirical and theoretical CDFs:
    $$D = \sup_x |F_n(x) - \Phi(x; \hat{\mu}, \hat{\sigma})|$$
  - **Quantile-Quantile (Q-Q) Diagnostics**: Blom plotting positions against standard normal inverse CDF.

### Section 3: Inferential Hypothesis Testing
- **Script**: [`src/run_hypothesis_tests.m`](src/run_hypothesis_tests.m)
- **Visualizer**: [`visual/plot_hypothesis_tests.m`](visual/plot_hypothesis_tests.m)
- **Hypotheses Evaluated**:
  1. **Two-Sample Welch's t-Test** (Heteroscedastic Training Hours Effect):
     - $H_0: \mu_{\text{High Training}} = \mu_{\text{Low Training}}$ vs. $H_1: \mu_{\text{High}} > \mu_{\text{Low}}$
     - Computes Satterthwaite degrees of freedom and Cohen's $d$ effect size.
  2. **One-Way Analysis of Variance (ANOVA)** (Educational Attainment):
     - $H_0: \mu_{\text{Bachelor}} = \mu_{\text{Master}} = \mu_{\text{PhD}}$
     - Decomposes total sum of squares into Between-Group ($SS_{\text{between}}$) and Within-Group ($SS_{\text{within}}$) components; computes effect size $\eta^2$.
     - Visualizes theoretical Snedecor $F$-distribution density curve with shaded critical rejection area ($\alpha = 0.05$).
  3. **Bivariate Correlation Significance**:
     - Tests $H_0: \rho = 0$ for both Pearson's linear correlation coefficient ($r$) and Spearman's non-parametric rank coefficient ($\rho$).
     - Constructs Fisher $z$-transformation 95% Confidence Interval and bivariate 95% confidence ellipse.

### Section 4: Non-Parametric Bootstrap Resampling
- **Script**: [`src/run_bootstrap.m`](src/run_bootstrap.m)
- **Visualizer**: [`visual/plot_bootstrap.m`](visual/plot_bootstrap.m)
- **Monte Carlo Setup**:
  - $B = 3000$ independent resamples with replacement ($N = 500$).
  - Target Estimator 1: Population Median Annual Salary ($\tilde{\theta} = \text{Median}(S)$).
  - Target Estimator 2: Mean Productivity Training Differential ($\Delta\mu = \mu_{\text{high}} - \mu_{\text{low}}$).
- **Inference Diagnostics**:
  - Calculation of bootstrap Standard Error ($SE_{\text{boot}}$) and estimation of finite-sample bias ($\widehat{\text{Bias}} = \bar{\theta}^* - \hat{\theta}$).
  - Construction of 95% Percentile Confidence Intervals and 95% Normal-Approximation Confidence Intervals.
  - Convergence trace tracking CI upper and lower bounds as $B$ scales from 50 to 3000 resamples.

### Section 5: Econometric Regression & Residual Diagnostics
- **Script**: [`src/run_regression.m`](src/run_regression.m)
- **Visualizer**: [`visual/plot_regression.m`](visual/plot_regression.m)
- **Models Fitted**:
  1. **Simple Linear Regression (SLR)**:
     $$\text{Salary}_i = \beta_0 + \beta_1 \cdot \text{Productivity}_i + \epsilon_i$$
     Computes analytical 95% Confidence Bands for the mean response and 95% Individual Prediction Bands across the observation domain.
  2. **Multiple Linear Regression (MLR)**:
     $$\text{Salary}_i = \beta_0 + \beta_1 \text{Exp}_i + \beta_2 \text{Prod}_i + \beta_3 \text{Hours}_i + \beta_4 \text{Training}_i + \epsilon_i$$
     Evaluated via matrix normal equations: $\hat{\boldsymbol{\beta}} = (\mathbf{X}^T \mathbf{X})^{-1} \mathbf{X}^T \mathbf{y}$.
- **4-in-1 Diagnostic Suite**:
  - Fitted vs. Residuals with moving average trendline (Homoscedasticity and Linearity verification).
  - Normal Q-Q Plot of Standardized Residuals ($\epsilon \sim \mathcal{N}(0, \sigma^2)$ verification).
  - Cook's Distance ($D_i$) influence screening against the standard threshold $D_i > \frac{4}{N}$.
  - Variance decomposition: $R^2$, Adjusted $R^2$, Root Mean Squared Error (RMSE), and overall model $F$-test.

### Section 6: Master Executive Dashboard
- **Script**: [`visual/plot_executive_summary.m`](visual/plot_executive_summary.m)
- Consolidates all key analytics into a unified 12-tile dashboard:
  - Top KPI cards (Total Workforce, Median Salary with 95% Bootstrap CI, Training Gain, Model $R^2$).
  - Multi-variable scatter linking Experience, Productivity, and Salary with OLS fit.
  - Education ROI bar chart with 95% confidence intervals.
  - Standardized density comparisons (Productivity vs. Raw Salary vs. Log Salary).
  - High-level Inferential Decision Matrix infographic card.

---

## Visual Gallery & Figure Overview

| Figure | Description | Output File |
| :--- | :--- | :--- |
| **Fig 1** | **Central Tendency & Dispersion**<br>Histograms with KDE & Mean/Median/Mode markers, Department Boxplots with Jitter, Summary Card | [`figures/fig1_central_tendency.png`](figures/fig1_central_tendency.png) |
| **Fig 2** | **Normality Testing & Q-Q Mapping**<br>Histograms with fitted Gaussian curves and Standardized Q-Q plots across 3 series | [`figures/fig2_normality_tests.png`](figures/fig2_normality_tests.png) |
| **Fig 3** | **Hypothesis Testing & Significance**<br>Welch t-Test error bars, ANOVA across education, Theoretical F-distribution, Correlation ellipse | [`figures/fig3_hypothesis_tests.png`](figures/fig3_hypothesis_tests.png) |
| **Fig 4** | **Bootstrap Resampling & Inference**<br>Sampling distributions of Median Salary & Training Delta, Monte Carlo convergence trace, CI comparisons | [`figures/fig4_bootstrap_inference.png`](figures/fig4_bootstrap_inference.png) |
| **Fig 5** | **Regression Modeling & Diagnostics**<br>OLS fit with 95% Confidence & Prediction bands, Residuals vs Fitted, Residual Q-Q, Cook's Distance | [`figures/fig5_regression_diagnostics.png`](figures/fig5_regression_diagnostics.png) |
| **Fig 6** | **Master Executive Analytics Dashboard**<br>High-level executive layout with KPI cards, multi-factor scatter, education ROI, and Decision Matrix | [`figures/fig6_executive_dashboard.png`](figures/fig6_executive_dashboard.png) |

---

## Repository Structure

```
.
├── config.m                         # Global parameters, paths, seeds, and UI color palettes
├── main.m                           # Master project script executing all 5 modules sequentially
├── run_all.m                        # Single-command runner shortcut (press F5 to run)
├── README.md                        # Comprehensive project documentation (this file)
│
├── data/
│   ├── generate_dataset.m           # Parametric workforce dataset synthesizer
│   └── employee_data.csv            # Exported N=500 employee records
│
├── src/
│   ├── calc_central_tendency.m      # Module 1: Location, dispersion, and department breakdowns
│   ├── test_normality.m             # Module 2: Jarque-Bera, Lilliefors, and Q-Q calculations
│   ├── run_hypothesis_tests.m       # Module 3: Welch t-test, One-way ANOVA, and Correlation
│   ├── run_bootstrap.m              # Module 4: Monte Carlo resampling (B=3000) and CIs
│   ├── run_regression.m             # Module 5: Simple & Multiple OLS regression & diagnostics
│   └── stat_utils.m                 # Pure Base-MATLAB statistical primitives & math library
│
├── visual/
│   ├── plot_central_tendency.m      # Figure 1: 4-tile central tendency dashboard
│   ├── plot_normality.m             # Figure 2: 2x3 normality & goodness-of-fit diagnostic suite
│   ├── plot_hypothesis_tests.m      # Figure 3: 4-tile inferential hypothesis & F-distribution plot
│   ├── plot_bootstrap.m             # Figure 4: 4-tile bootstrap distributions & convergence plot
│   ├── plot_regression.m            # Figure 5: 4-panel OLS bands & residual diagnostics
│   └── plot_executive_summary.m     # Figure 6: Master executive analytics dashboard
│
└── figures/                         # Generated high-resolution 300 DPI publication images
    ├── fig1_central_tendency.png
    ├── fig2_normality_tests.png
    ├── fig3_hypothesis_tests.png
    ├── fig4_bootstrap_inference.png
    ├── fig5_regression_diagnostics.png
    └── fig6_executive_dashboard.png
```

---

## Getting Started & Execution Guide

### Prerequisites
- **MATLAB**: R2018b or later (tested through R2024b).
- **Required Toolboxes**: **None**. All algorithms are written in base MATLAB.
- **Operating System**: Windows, macOS, or Linux.

### Execution Options

#### Option A: One-Click Execution (MATLAB Editor)
1. Open MATLAB and set your Current Folder to the project directory:
   ```matlab
   cd('/path/to/CS MiniProject');
   ```
2. Open `run_all.m` or `main.m` and press **F5** (or click **Run**).
3. The script will execute all statistical modules, print comprehensive formatted ASCII tables to the Command Window, and save all 6 figures to the `figures/` folder.

#### Option B: MATLAB Command Window
In the MATLAB command prompt, simply enter:
```matlab
run_all
```

#### Option C: Headless Batch Mode (Terminal / CI / Linux)
To run the analysis without opening the desktop GUI:
```bash
matlab -batch "run_all"
```

#### Option D: Interactive Cell-by-Cell Mode
Open `main.m` in the MATLAB Editor and use **Ctrl + Enter** (or **Cmd + Enter** on macOS) to execute individual modules section-by-section.

---

## Mathematical Formulations

### 1. Central Tendency & Shape
- **Arithmetic Mean**:
  $$\bar{x} = \frac{1}{n} \sum_{i=1}^n x_i$$
- **Fisher's Sample Skewness**:
  $$g_1 = \frac{\frac{1}{n} \sum_{i=1}^n (x_i - \bar{x})^3}{\left[\frac{1}{n} \sum_{i=1}^n (x_i - \bar{x})^2\right]^{3/2}}$$
- **Pearson's Sample Kurtosis**:
  $$g_2 = \frac{\frac{1}{n} \sum_{i=1}^n (x_i - \bar{x})^4}{\left[\frac{1}{n} \sum_{i=1}^n (x_i - \bar{x})^2\right]^2}$$

### 2. Normality Assessment (Jarque-Bera)
$$JB = \frac{n}{6} \left( g_1^2 + \frac{(g_2 - 3)^2}{4} \right) \xrightarrow{d} \chi^2(2)$$
Rejection rule: Reject $H_0$ if $JB > \chi^2_{2, 1-\alpha} = 5.9915$ at $\alpha = 0.05$.

### 3. Two-Sample Welch's t-Test
$$t = \frac{\bar{x}_1 - \bar{x}_2}{\sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}}$$
Degrees of freedom via Welch-Satterthwaite equation:
$$\nu \approx \frac{\left(\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}\right)^2}{\frac{(s_1^2/n_1)^2}{n_1 - 1} + \frac{(s_2^2/n_2)^2}{n_2 - 1}}$$

### 4. One-Way ANOVA F-Statistic
$$F = \frac{MS_{\text{between}}}{MS_{\text{within}}} = \frac{\frac{1}{k - 1} \sum_{j=1}^k n_j (\bar{y}_{\cdot j} - \bar{y}_{\cdot\cdot})^2}{\frac{1}{N - k} \sum_{j=1}^k \sum_{i=1}^{n_j} (y_{ij} - \bar{y}_{\cdot j})^2}$$
Effect size:
$$\eta^2 = \frac{SS_{\text{between}}}{SS_{\text{total}}}$$

### 5. OLS Confidence and Prediction Bands
For a target predictor value $x_0$, the Standard Error of the **Mean Response** is:
$$SE(\hat{\mu}_{Y|x_0}) = s_e \sqrt{\frac{1}{n} + \frac{(x_0 - \bar{x})^2}{\sum (x_i - \bar{x})^2}}$$
The Standard Error of an **Individual Forecast** is:
$$SE(\hat{Y}_{\text{new}|x_0}) = s_e \sqrt{1 + \frac{1}{n} + \frac{(x_0 - \bar{x})^2}{\sum (x_i - \bar{x})^2}}$$

### 6. Cook's Distance Influence Metric
$$D_i = \frac{e_i^2}{(p + 1) s_e^2} \left[ \frac{h_{ii}}{(1 - h_{ii})^2} \right]$$
where $h_{ii}$ represents the $i$-th diagonal element of the hat matrix $\mathbf{H} = \mathbf{X} (\mathbf{X}^T \mathbf{X})^{-1} \mathbf{X}^T$.

---

## Empirical Insights & Managerial Takeaways

From executing the analysis on $N = 500$ employee records:

1. **Salary Asymmetry Mandates Non-Parametric Metrics**:
   - Raw salary exhibits noticeable positive skewness ($g_1 \approx +0.55$), pulling the Arithmetic Mean ($104,800) above the Median ($102,600) by over $2,200.
   - For compensation benchmarking, the **Median** ($102,600, 95% Bootstrap CI: [$100,600, $104,500]) provides a substantially more robust estimate than the sample mean.
2. **Log-Transformation Restores Classical Normality**:
   - While raw salary fails the Jarque-Bera test ($JB \approx 28.4, p < 10^{-4}$), the log-transformed series $\ln(\text{Salary})$ conforms to Gaussian normality ($JB \approx 3.12, p = 0.21 > 0.05$). This validates log-linear wage models in econometric theory.
3. **Training Yields High-Impact Productivity Gains**:
   - Employees participating in high training programs ($\ge 35$ hours) outperform peers with low training by $+6.0$ productivity points ($p < 10^{-4}$, Cohen's $d \approx 0.84$). This confirms training programs as a high-leverage lever for workforce optimization.
4. **Significant Educational Wage Premium**:
   - One-way ANOVA reveals pronounced compensation premiums across educational tiers ($F \approx 48.7, p < 10^{-4}, \eta^2 \approx 0.16$). Master's degree holders command an average premium of $\approx \$14,000$, and PhDs command $\approx \$28,000$ over Bachelor's credentials.
5. **Human Capital Explains $> 72\%$ of Salary Variance**:
   - The multiple OLS regression model ($\text{Salary} \sim \text{Exp} + \text{Prod} + \text{Hours} + \text{Training}$) achieves $R^2 \approx 0.727$ ($Adj\ R^2 \approx 0.725, RMSE \approx \$7,650$).
   - Experience (+$3,400 per year, $p < 10^{-4}$) and Productivity (+$620 per point, $p < 10^{-4}$) represent the primary drivers of financial reward.

---

## Zero-Toolbox Dependency Implementation

A core architectural strength of this project is its independence from proprietary toolboxes. The utility library [`src/stat_utils.m`](src/stat_utils.m) implements:

- **Student's t CDF**: Vectorized incomplete beta function:
  $$F(t; \nu) = 1 - \frac{1}{2} I_x\left(\frac{\nu}{2}, \frac{1}{2}\right), \quad x = \frac{\nu}{\nu + t^2}$$
- **Student's t Inverse CDF**: Initial Cornish-Fisher expansion refined via Newton-Raphson root finding:
  $$t_{k+1} = t_k - \frac{F(t_k; \nu) - p}{f(t_k; \nu)}$$
- **Snedecor's F CDF**: Evaluated via regularized incomplete beta function `betainc`.
- **Chi-Square CDF**: Evaluated via regularized lower incomplete gamma function `gammainc`.
- **Kernel Density Estimation**: Vectorized Gaussian kernel evaluated using Silverman's optimal bandwidth:
  $$h = 0.9 \min\left(s, \frac{IQR}{1.34}\right) n^{-1/5}$$

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

