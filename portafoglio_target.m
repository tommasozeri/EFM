function portafoglio_target_annualizzato
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

    % Stima la frontiera efficiente
    pwgt = estimateFrontier(p, 20);
    [prsk, pret] = estimatePortMoments(p, pwgt);

    % Definisci il rendimento target e il rischio target
    TargetReturn = 0.30; % Rendimento annualizzato target
    TargetRisk = 0.15;   % Rischio annualizzato target

    % Ottieni i portafogli con rendimento e rischio target
    awgt = estimateFrontierByReturn(p, TargetReturn / 252);
    [arsk, aret] = estimatePortMoments(p, awgt);

    bwgt = estimateFrontierByRisk(p, TargetRisk / sqrt(252));
    [brsk, bret] = estimatePortMoments(p, bwgt);

    % Converti i valori in annualizzati
    annualized_prsk = prsk * sqrt(252);
    annualized_pret = (1 + pret) .^ 252 - 1;
    annualized_arsk = arsk * sqrt(252);
    annualized_aret = (1 + aret) .^ 252 - 1;
    annualized_brsk = brsk * sqrt(252);
    annualized_bret = (1 + bret) .^ 252 - 1;

    % Grafico della frontiera efficiente con i portafogli target
    figure;
    plot(annualized_prsk, annualized_pret, 'b-', 'LineWidth', 2);
    hold on;
    scatter(annualized_arsk, annualized_aret, 'r', 'filled');
    scatter(annualized_brsk, annualized_bret, 'g', 'filled');
    scatter(sqrt(diag(p.AssetCovar)) * sqrt(252), (1 + p.AssetMean) .^ 252 - 1, 'k', 'filled');
    text(sqrt(diag(p.AssetCovar)) * sqrt(252), (1 + p.AssetMean) .^ 252 - 1, tickers, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    xlabel('Rischio Annualizzato (Deviazione Standard)');
    ylabel('Rendimento Annualizzato Atteso');
    title('Frontiera Efficiente con Portafogli Target (Valori Annualizzati)');
    legend('Frontiera Efficiente', sprintf('%g%% Rendimento', 100 * TargetReturn), sprintf('%g%% Rischio', 100 * TargetRisk), 'Asset', 'Location', 'Best');
    grid on;
    hold off;

    % Mostra i portafogli target e stampa rendimento e rischio
    disp(sprintf('Portafoglio con %g%% Rendimento Target:', 100 * TargetReturn));
    disp(array2table(awgt(awgt > 0), 'VariableNames', {'Peso'}, 'RowNames', p.AssetList(awgt > 0)));
    disp(sprintf('Rendimento Annualizzato: %g%%', 100 * annualized_aret));
    disp(sprintf('Rischio Annualizzato: %g%%', 100 * annualized_arsk));

    disp(sprintf('Portafoglio con %g%% Rischio Target:', 100 * TargetRisk));
    disp(array2table(bwgt(bwgt > 0), 'VariableNames', {'Peso'}, 'RowNames', p.AssetList(bwgt > 0)));
    disp(sprintf('Rendimento Annualizzato: %g%%', 100 * annualized_bret));
    disp(sprintf('Rischio Annualizzato: %g%%', 100 * annualized_brsk));
end
