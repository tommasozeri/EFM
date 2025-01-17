function z = portafoglio1
    % Aggiungi la cartella contenente la funzione obiettivo alla MATLAB path
    addpath('C:\Users\Tomma\MATLAB Drive\PortOpt MATLAB\PortfolioOptimization MATLAB(Tesi)');

    % Carica i dati dal file Excel NAS30BM.xlsx
    A = readtable('NAS30BM.xlsx', 'ReadRowNames', true);
    tickers = A.Properties.VariableNames;
    A = table2array(A);
    A = cellfun(@str2double, A);

    % Carica i dati di mercato dal file Excel S&P500HistoricalData.xlsx
    MercatoDati = readtable('S&P500HistoricalData.xlsx', 'ReadRowNames', true);
    MercatoDati = table2array(MercatoDati);
    MercatoDati = cellfun(@str2double, MercatoDati);

    % Assicurati che i dati di mercato e i dati degli asset abbiano lo stesso numero di osservazioni
    min_length = min(size(A, 1), length(MercatoDati));
    A = A(1:min_length, :);
    MercatoDati = MercatoDati(1:min_length);

    % Calcola i rendimenti logaritmici
    n = size(A, 1);
    R = log(A(2:n, :) ./ A(1:n-1, :));
    MercatoR = log(MercatoDati(2:end) ./ MercatoDati(1:end-1));

    % Calcola i momenti statistici
    m = mean(R);
    V = cov(R);

    % Calcola il beta di ogni asset rispetto al mercato
    beta_assets = zeros(1, size(R, 2));
    var_mercato = var(MercatoR);
    for i = 1:size(R, 2)
        cov_mercato_asset = cov(MercatoR, R(:, i));
        beta_assets(i) = cov_mercato_asset(1, 2) / var_mercato;
    end

    % Ottimizzazione del portafoglio
    z0 = (1/length(m)) * ones(length(m), 1);
    A = -m;
    p = 0.001;
    B = [-p];
    Aeq = ones(1, length(m));
    Beq = [1];
    LB = zeros(length(m), 1);
    %LB = -inf(length(m), 1); % Permette pesi negativi per le vendite allo scoperto
    UB = [];

    options = optimoptions('fmincon', 'MaxFunctionEvaluations', 10000);
    [x, fval, exitflag, output] = fmincon(@(x) PrimaFunzObbP1(x), z0, A, B, Aeq, Beq, LB, UB, [], options);

    % Calcola il rendimento del portafoglio
    portfolio_return = m * x;

    % Calcola il rendimento annualizzato
    annualized_return = (1 + portfolio_return) ^ 252 - 1;

    % Calcola il rischio del portafoglio
    portfolio_risk = sqrt(x' * V * x);

    % Calcola il rischio annualizzato
    annualized_risk = portfolio_risk * sqrt(252);

    % Calcola la skewness e la curtosi del portafoglio
    portfolio_skewness = skewness(R * x);
    portfolio_kurtosis = kurtosis(R * x);

    % Calcola il beta del portafoglio rispetto al mercato
    portfolio_beta = sum(x' .* beta_assets);

    % Calcola il rendimento senza rischio (ad esempio, il rendimento dei titoli di stato a breve termine)
    risk_free_rate = 0.01; % 1% annuo

    % Calcola il rapporto di Sharpe
    sharpe_ratio = (portfolio_return - risk_free_rate) / portfolio_risk;

    % Calcola il rapporto di Sortino
    downside_risk = sqrt(mean(min(0, R * x).^2));
    sortino_ratio = (portfolio_return - risk_free_rate) / downside_risk;

    % Calcola l'alpha di Jensen
    market_return = mean(MercatoR);
    alpha_jensen = portfolio_return - (risk_free_rate + portfolio_beta * (market_return - risk_free_rate));

    % Stampa i risultati dell'ottimizzazione
    disp('Risultati dell''ottimizzazione:');
    disp(['Valore della funzione obiettivo: ', num2str(fval)]);
    disp(['Exit flag: ', num2str(exitflag)]);
    disp('Output:');
    disp(output);
    disp('Pesi ottimali del portafoglio:');
    for i = 1:length(x)
        disp([tickers{i}, ': ', num2str(x(i))]);
    end

    % Stampa i risultati aggiuntivi
    disp(['Rendimento del portafoglio: ', num2str(portfolio_return)]);
    disp(['Rendimento annualizzato: ', num2str(annualized_return)]);
    disp(['Rischio del portafoglio: ', num2str(portfolio_risk)]);
    disp(['Rischio annualizzato: ', num2str(annualized_risk)]);
    disp(['Skewness del portafoglio: ', num2str(portfolio_skewness)]);
    disp(['Curtosi del portafoglio: ', num2str(portfolio_kurtosis)]);
    disp(['Beta del portafoglio: ', num2str(portfolio_beta)]);
    disp(['Rapporto di Sharpe: ', num2str(sharpe_ratio)]);
    disp(['Rapporto di Sortino: ', num2str(sortino_ratio)]);
    disp(['Alpha di Jensen: ', num2str(alpha_jensen)]);

    % Stampa il beta di ogni singolo asset
    disp('Beta di ogni singolo asset:');
    for i = 1:length(beta_assets)
        disp([tickers{i}, ': ', num2str(beta_assets(i))]);
    end

    %% GRAFICI -----------------------------------------------------

    % Calcola la frontiera efficiente
    p = Portfolio('AssetList', tickers, 'RiskFreeRate', 0.02 / 252); % Tasso risk-free giornaliero
    p = setAssetMoments(p, m, V);
    p = setDefaultConstraints(p);
    pwgt = estimateFrontier(p, 20);
    [prsk, pret] = estimatePortMoments(p, pwgt);

    % Calcola la linea tangente
    q = setBudget(p, 0, 1);
    qwgt = estimateFrontier(q, 20);
    [qrsk, qret] = estimatePortMoments(q, qwgt);

    % Grafico della frontiera efficiente (valori giornalieri)
    figure;
    plot(prsk, pret, 'b-', 'LineWidth', 2);
    hold on;
    plot(qrsk, qret, 'g--', 'LineWidth', 2); % Linea tangente
    scatter(portfolio_risk, portfolio_return, 'r', 'filled');
    text(portfolio_risk, portfolio_return, 'Portafoglio Ottimo', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    for i = 1:length(m)
        scatter(sqrt(V(i, i)), m(i), 'k', 'filled');
        text(sqrt(V(i, i)), m(i), tickers{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    xlabel('Rischio (Deviazione Standard)');
    ylabel('Rendimento Atteso');
    title('Frontiera Efficiente sul Piano Media-Varianza (Valori Giornalieri)');
    legend('Frontiera Efficiente', 'Linea Tangente', 'Portafoglio Ottimo', 'Location', 'Best');
    grid on;
    hold off;

    % Converti i rendimenti e i rischi in valori annualizzati
    annualized_prsk = prsk * sqrt(252);
    annualized_pret = (1 + pret) .^ 252 - 1;
    annualized_qrsk = qrsk * sqrt(252);
    annualized_qret = (1 + qret) .^ 252 - 1;

    % Grafico della frontiera efficiente (valori annualizzati)
    figure;
    plot(annualized_prsk, annualized_pret, 'b-', 'LineWidth', 2);
    hold on;
    plot(annualized_qrsk, annualized_qret, 'g--', 'LineWidth', 2); % Linea tangente
    scatter(annualized_risk, annualized_return, 'r', 'filled');
    text(annualized_risk, annualized_return, 'Portafoglio Ottimo', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    for i = 1:length(m)
        scatter(sqrt(V(i, i)) * sqrt(252), (1 + m(i)) ^ 252 - 1, 'k', 'filled');
        text(sqrt(V(i, i)) * sqrt(252), (1 + m(i)) ^ 252 - 1, tickers{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    xlabel('Rischio Annualizzato (Deviazione Standard)');
    ylabel('Rendimento Annualizzato Atteso');
    title('Frontiera Efficiente sul Piano Media-Varianza (Valori Annualizzati)');
    legend('Frontiera Efficiente', 'Linea Tangente', 'Portafoglio Ottimo', 'Location', 'Best');
    grid on;
    hold off;

   % Calcola il portafoglio di mercato (su DB principale non su indice)
market_weights = mean(R) / sum(mean(R)); % Pesi del portafoglio di mercato basati sui rendimenti medi
market_return = sum(market_weights .* m) * 252; % Rendimento annualizzato del portafoglio di mercato
market_beta = 1; % Beta del portafoglio di mercato è 1

% Grafico della Security Market Line (SML)
figure;
risk_free_rate = 0.01; % Tasso risk-free annuale
market_premium = market_return - risk_free_rate; % Premio per il rischio di mercato
sml_x = [0, 1]; % Beta va da 0 a 1
sml_y = [risk_free_rate, risk_free_rate + market_premium]; % SML
plot(sml_x, sml_y, 'b-', 'LineWidth', 2);
hold on;

% Aggiungi il portafoglio di mercato
scatter(market_beta, market_return, 'g', 'filled');
text(market_beta, market_return, 'Portafoglio di Mercato', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

% Aggiungi il portafoglio ottimo
scatter(portfolio_beta, annualized_return, 'r', 'filled');
text(portfolio_beta, annualized_return, 'Portafoglio Ottimo', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

% Aggiungi tutti gli altri titoli
for i = 1:length(beta_assets)
    scatter(beta_assets(i), m(i) * 252, 'k', 'filled');
    text(beta_assets(i), m(i) * 252, tickers{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

xlabel('Beta');
ylabel('Rendimento Atteso');
title('Security Market Line (SML)');
legend('SML', 'Portafoglio di Mercato', 'Portafoglio Ottimo', 'Titoli', 'Location', 'Best');
grid on;
hold off;
    xlabel('Beta');
    ylabel('Rendimento Atteso');
    title('Security Market Line (SML)');
    legend('SML', 'Portafoglio di Mercato', 'Portafoglio Ottimo', 'Titoli', 'Location', 'Best');
    grid on;
    hold off;
end

