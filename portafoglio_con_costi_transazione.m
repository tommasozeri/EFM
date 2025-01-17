function portafoglio_con_costi_transazione
    % Carica i dati dal file Excel
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

    % Stima la frontiera efficiente senza costi di transazione
    pwgt = estimateFrontier(p, 20);
    [prsk, pret] = estimatePortMoments(p, pwgt);

    % Definisci i costi di transazione
    BuyCost = 0.0010;
    SellCost = 0.0010;

    % Imposta i costi di transazione
    q = setCosts(p, BuyCost, SellCost);

    % Stima la frontiera efficiente con costi di transazione
    qwgt = estimateFrontier(q, 20);
    [qrsk, qret] = estimatePortMoments(q, qwgt);

    % Converti i valori in annualizzati
    annualized_prsk = prsk * sqrt(252);
    annualized_pret = (1 + pret) .^ 252 - 1;
    annualized_qrsk = qrsk * sqrt(252);
    annualized_qret = (1 + qret) .^ 252 - 1;

    % Grafico delle frontiere efficienti con e senza costi di transazione
    figure;
    plot(annualized_prsk, annualized_pret, 'b-', 'LineWidth', 2);
    hold on;
    plot(annualized_qrsk, annualized_qret, 'r-', 'LineWidth', 2);
    scatter(sqrt(diag(p.AssetCovar)) * sqrt(252), (1 + p.AssetMean) .^ 252 - 1, 'k', 'filled');
    text(sqrt(diag(p.AssetCovar)) * sqrt(252), (1 + p.AssetMean) .^ 252 - 1, tickers, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    xlabel('Rischio Annualizzato (Deviazione Standard)');
    ylabel('Rendimento Annualizzato Atteso');
    title('Frontiera Efficiente con e senza Costi di Transazione (Valori Annualizzati)');
    legend('Senza Costi di Transazione', 'Con Costi di Transazione', 'Asset', 'Location', 'Best');
    grid on;
    hold off;

    % Mostra i portafogli senza costi di transazione e stampa rendimento e rischio
    disp('Portafogli senza costi di transazione:');
    for i = 1:size(pwgt, 2)
        disp(array2table(pwgt(:, i), 'VariableNames', {sprintf('Portafoglio %d', i)}, 'RowNames', tickers));
        disp(sprintf('Rendimento Annualizzato: %g%%', 100 * annualized_pret(i)));
        disp(sprintf('Rischio Annualizzato: %g%%', 100 * annualized_prsk(i)));
    end

    % Mostra i portafogli con costi di transazione e stampa rendimento e rischio
    disp('Portafogli con costi di transazione:');
    for i = 1:size(qwgt, 2)
        disp(array2table(qwgt(:, i), 'VariableNames', {sprintf('Portafoglio %d', i)}, 'RowNames', tickers));
        disp(sprintf('Rendimento Annualizzato: %g%%', 100 * annualized_qret(i)));
        disp(sprintf('Rischio Annualizzato: %g%%', 100 * annualized_qrsk(i)));
    end
end

