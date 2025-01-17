function z = portafoglio2
    % Carica i dati dal file Excel
    Dati = readtable('NAS30BM.xlsx', 'ReadRowNames', true);
    tickers = Dati.Properties.VariableNames;
    Dati = table2array(Dati);
    Dati = cellfun(@str2double, Dati);

    % Carica i dati di mercato dal file Excel S&P500HistoricalData.xlsx
    MercatoDati = readtable('S&P500HistoricalData.xlsx', 'ReadRowNames', true);
    MercatoDati = table2array(MercatoDati);
    MercatoDati = cellfun(@str2double, MercatoDati);

    % Assicurati che i dati di mercato e i dati degli asset abbiano lo stesso numero di osservazioni
    min_length = min(size(Dati, 1), length(MercatoDati));
    Dati = Dati(1:min_length, :);
    MercatoDati = MercatoDati(1:min_length);

    % Calcola i rendimenti logaritmici
    n = size(Dati, 1);
    R = log(Dati(2:n, :) ./ Dati(1:n-1, :));
    MercatoR = log(MercatoDati(2:end) ./ MercatoDati(1:end-1));

    % Calcola i momenti statistici
    m = mean(R);
    V = cov(R); %Unbiased estimator

    % Calcola il beta di ogni asset rispetto al mercato
    beta_assets = zeros(1, size(R, 2));
    var_mercato = var(MercatoR);
    for i = 1:size(R, 2)
        cov_mercato_asset = cov(MercatoR, R(:, i));
        beta_assets(i) = cov_mercato_asset(1, 2) / var_mercato;
    end

    % Ottimizzazione del portafoglio
    p = size(Dati, 2);
    z0 = (1/p) * ones(p, 1);
    A = [];
    B = [];
    Aeq = ones(1, p);
    Beq = [1];
    LB = zeros(p, 1);
    %LB = -inf(length(m), 1); % Permette pesi negativi per le vendite allo scoperto
    UB = [];
    UB = [];
    options = optimoptions('fmincon', 'MaxFunctionEvaluations', 10000); % Aumenta il limite massimo di valutazioni della funzione
    [z, fval, exitflag, output] = fmincon(@TerzaFunzObbP3, z0, A, B, Aeq, Beq, LB, UB, @NonLinearConstraintsP3, options);

    % Calcola il rendimento del portafoglio
    portfolio_return = m * z;

    % Calcola il rendimento annualizzato (assumendo 252 giorni di trading all'anno)
    annualized_return = (1 + portfolio_return) ^ 252 - 1;

    % Calcola il rischio del portafoglio
    portfolio_risk = sqrt(z' * V * z);

    % Calcola il rischio annualizzato (assumendo 252 giorni di trading all'anno)
    annualized_risk = portfolio_risk * sqrt(252);

    % Calcola la skewness e la curtosi del portafoglio
    portfolio_skewness = skewness(R * z);
    portfolio_kurtosis = kurtosis(R * z);

    % Calcola il beta del portafoglio rispetto al mercato
    portfolio_beta = sum(z' .* beta_assets);

    % Calcola il contributo marginale al rischio di ciascun titolo
    marginal_risk_contribution = (V * z) / portfolio_risk;

    % Stampa i risultati dell'ottimizzazione
    disp('Risultati dell''ottimizzazione:');
    disp(['Valore della funzione obiettivo: ', num2str(fval)]);
    disp(['Exit flag: ', num2str(exitflag)]);
    disp('Output:');
    disp(output);
    disp('Pesi ottimali del portafoglio:');
    for i = 1:length(z)
        disp([tickers{i}, ': ', num2str(z(i))]);
    end

    % Stampa i risultati aggiuntivi
    disp(['Rendimento del portafoglio: ', num2str(portfolio_return)]);
    disp(['Rendimento annualizzato: ', num2str(annualized_return)]);
    disp(['Rischio del portafoglio: ', num2str(portfolio_risk)]);
    disp(['Rischio annualizzato: ', num2str(annualized_risk)]);
    disp(['Skewness del portafoglio: ', num2str(portfolio_skewness)]);
    disp(['Curtosi del portafoglio: ', num2str(portfolio_kurtosis)]);
    disp(['Beta del portafoglio: ', num2str(portfolio_beta)]);

    % Stampa il beta di ogni singolo asset
    disp('Beta di ogni singolo asset:');
    for i = 1:length(beta_assets)
        disp([tickers{i}, ': ', num2str(beta_assets(i))]);
    end

    % Stampa il contributo marginale al rischio di ciascun titolo
    disp('Contributo marginale al rischio di ciascun titolo:');
    for i = 1:length(marginal_risk_contribution)
        disp([tickers{i}, ': ', num2str(marginal_risk_contribution(i))]);
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

