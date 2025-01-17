function portafoglio_max_sharpe_ratio_con_tangente
    % Carica i dati dal file Excel NAS30BM.xlsx
    Dati = readtable('NAS30BM.xlsx', 'ReadRowNames', true);
    tickers = Dati.Properties.VariableNames;
    Dati = table2array(Dati);
    Dati = cellfun(@str2double, Dati);

    % Calcola i rendimenti logaritmici
    R = log(Dati(2:end, :) ./ Dati(1:end-1, :));

    % Calcola la matrice di varianza-covarianza
    V = cov(R);

    % Calcola il rendimento medio
    m = mean(R);

    % Crea un oggetto Portfolio
    p = Portfolio('AssetList', tickers, 'RiskFreeRate', 0.02 / 252);
    p = setAssetMoments(p, m, V);
    p = setDefaultConstraints(p);

    % Stima la frontiera efficiente
    pwgt = estimateFrontier(p, 20);
    [prsk, pret] = estimatePortMoments(p, pwgt);

    % Imposta il portafoglio iniziale a zero
    p = setInitPort(p, 0);

    % Stima il portafoglio che massimizza lo Sharpe ratio
    swgt = estimateMaxSharpeRatio(p);
    [srsk, sret] = estimatePortMoments(p, swgt);

    % Crea un oggetto Portfolio per la linea tangente
    q = setBudget(p, 0, 1);
    qwgt = estimateFrontier(q, 20);
    [qrsk, qret] = estimatePortMoments(q, qwgt);

    % Converti i valori in annualizzati
    annualized_prsk = prsk * sqrt(252);
    annualized_pret = (1 + pret) .^ 252 - 1;
    annualized_srsk = srsk * sqrt(252);
    annualized_sret = (1 + sret) .^ 252 - 1;
    annualized_qrsk = qrsk * sqrt(252);
    annualized_qret = (1 + qret) .^ 252 - 1;

    % Grafico della frontiera efficiente con il portafoglio che massimizza lo Sharpe ratio e la linea tangente
    figure;
    plot(annualized_prsk, annualized_pret, 'b-', 'LineWidth', 2);
    hold on;
    plot(annualized_qrsk, annualized_qret, 'g--', 'LineWidth', 2);
    scatter(annualized_srsk, annualized_sret, 'r', 'filled');
    scatter(0, 0.02, 'k', 'filled');
    scatter(sqrt(diag(p.AssetCovar)) * sqrt(252), (1 + p.AssetMean) .^ 252 - 1, 'k', 'filled');
    text(sqrt(diag(p.AssetCovar)) * sqrt(252), (1 + p.AssetMean) .^ 252 - 1, tickers, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    xlabel('Rischio Annualizzato (Deviazione Standard)');
    ylabel('Rendimento Annualizzato Atteso');
    title('Frontiera Efficiente con Portafoglio che Massimizza lo Sharpe Ratio e Linea Tangente (Valori Annualizzati)');
    legend('Frontiera Efficiente', 'Linea Tangente', 'Sharpe Ratio', 'Tasso Risk-Free', 'Asset', 'Location', 'Best');
    grid on;
    hold off;

    % Mostra il portafoglio che massimizza lo Sharpe ratio e stampa rendimento e rischio
    disp('Portafoglio che Massimizza lo Sharpe Ratio:');
    disp(array2table(swgt(swgt > 0), 'VariableNames', {'Peso'}, 'RowNames', p.AssetList(swgt > 0)));
    disp(sprintf('Rendimento Annualizzato: %g%%', 100 * annualized_sret));
    disp(sprintf('Rischio Annualizzato: %g%%', 100 * annualized_srsk));

    % Conferma che il massimo Sharpe ratio è un massimo
    psratio = (pret - p.RiskFreeRate) ./ prsk;
    ssratio = (sret - p.RiskFreeRate) / srsk;

    figure;
    subplot(2,1,1);
    plot(annualized_prsk, annualized_pret, 'LineWidth', 2);
    hold on;
    scatter(annualized_srsk, annualized_sret, 'g', 'filled');
    title('\bfFrontiera Efficiente');
    xlabel('Rischio del Portafoglio');
    ylabel('Rendimento del Portafoglio');
    hold off;

    subplot(2,1,2);
    plot(annualized_prsk, psratio, 'LineWidth', 2);
    hold on;
    scatter(annualized_srsk, ssratio, 'g', 'filled');
    title('\bfSharpe Ratio');
    xlabel('Rischio del Portafoglio');
    ylabel('Sharpe Ratio');
    hold off;
end
