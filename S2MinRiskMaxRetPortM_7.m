function z = portafoglio2EFM
    % Aggiungi la cartella contenente la funzione obiettivo alla MATLAB path
    addpath('C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025');

    % Carica i dati dal file Excel DBEXAM.xlsx, worksheet NYSEselectedD
    A = readtable('DBEXAM.xlsx', 'Sheet', 'NYSEselectedM', 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
    tickers = A.Properties.VariableNames;
    A = table2array(A);

    % Carica i dati di mercato dal file Excel DBEXAM.xlsx, worksheet SP500indexD
    MercatoDati = readtable('DBEXAM.xlsx', 'Sheet', 'SP500indexM', 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
    MercatoDati = table2array(MercatoDati);

    % Assicurati che i dati di mercato e i dati degli asset abbiano lo stesso numero di osservazioni
    min_length = min(size(A, 1), length(MercatoDati));
    A = A(1:min_length, :);
    MercatoDati = MercatoDati(1:min_length);

    % Calcola i rendimenti logaritmici mensili
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
    [x, fval, exitflag, output] = fmincon(@(x) SecondaFunzObbP2EFMMQ7(x), z0, A, B, Aeq, Beq, LB, UB, [], options);

    % Calcola il rendimento del portafoglio
    portfolio_return = m * x;

    % Calcola il rendimento annualizzato
    annualized_return = (1 + portfolio_return) ^ 12 - 1;

    % Calcola il rischio del portafoglio
    portfolio_risk = sqrt(x' * V * x);

    % Calcola il rischio annualizzato
    annualized_risk = portfolio_risk * sqrt(12);

    % Calcola la skewness e la curtosi del portafoglio
    portfolio_skewness = skewness(R * x);
    portfolio_kurtosis = kurtosis(R * x);

    % Calcola il beta del portafoglio rispetto al mercato
    portfolio_beta = sum(x' .* beta_assets);

    % Calcola il rendimento senza rischio (ad esempio, il rendimento dei titoli di stato a breve termine)
    risk_free_rate = (1 + 0.02)^(1/12) - 1; % Convertito a mensile

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

    %% GRAFICI ----------------------------------------------------------------------

    % Calcola la frontiera efficiente
p = Portfolio('AssetList', tickers, 'RiskFreeRate', risk_free_rate); % Tasso risk-free mensile
p = setAssetMoments(p, m, V);
p = setDefaultConstraints(p);
pwgt = estimateFrontier(p, 20);
[prsk, pret] = estimatePortMoments(p, pwgt);

% Calcola la linea tangente
q = setBudget(p, 0, 1);
qwgt = estimateFrontier(q, 20);
[qrsk, qret] = estimatePortMoments(q, qwgt);

% Grafico della frontiera efficiente (valori mensili)
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
title('Frontiera Efficiente sul Piano Media-Varianza (Valori Mensili)');
legend('Frontiera Efficiente', 'Linea Tangente', 'Portafoglio Ottimo', 'Location', 'Best');
grid on;
hold off;

