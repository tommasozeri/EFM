function analisi_portafoglio
    % Carica i dati dal file Excel
    Dati = readtable('NAS30BM.xlsx', 'ReadRowNames', true);
    tickers = Dati.Properties.VariableNames;
    Dati = table2array(Dati);
    Dati = cellfun(@str2double, Dati);

    % Carica i dati di mercato dal file Excel
    MercatoDati = readtable('S&P500HistoricalData.xlsx', 'ReadRowNames', true);
    MercatoDati = table2array(MercatoDati);
    MercatoDati = cellfun(@str2double, MercatoDati);

    % Assicurati che i dati di mercato e i dati degli asset abbiano lo stesso numero di osservazioni
    min_length = min(size(Dati, 1), length(MercatoDati));
    Dati = Dati(1:min_length, :);
    MercatoDati = MercatoDati(1:min_length);

    % Calcola i rendimenti logaritmici
    R = log(Dati(2:end, :) ./ Dati(1:end-1, :));
    MercatoR = log(MercatoDati(2:end) ./ MercatoDati(1:end-1));

    % Calcola la matrice di varianza-covarianza
    V = cov(R);

    % Calcola la matrice di correlazione
    C = corrcoef(R);

    % Grafico heatmap della matrice di varianza-covarianza
    figure;
    heatmap(tickers, tickers, V, 'Colormap', parula, 'ColorbarVisible', 'on');
    title('Matrice di Varianza-Covarianza (Valori Giornalieri)');

    % Grafico heatmap della matrice di correlazione
    figure;
    heatmap(tickers, tickers, C, 'Colormap', parula, 'ColorbarVisible', 'on');
    title('Matrice di Correlazione (Valori Giornalieri)');

    % Calcola il rendimento medio e il rischio (deviazione standard)
    m = mean(R);
    s = std(R);

    % Grafico del piano media-varianza
    figure;
    scatter(s, m, 'filled');
    text(s, m, tickers, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    xlabel('Rischio (Deviazione Standard)');
    ylabel('Rendimento Medio');
    title('Piano Media-Varianza (Valori Giornalieri)');

    % Andamento dei prezzi degli asset normalizzati
    prezzi_normalizzati = Dati ./ Dati(1, :);
    figure;
    plot(prezzi_normalizzati);
    legend(tickers, 'Location', 'best');
    xlabel('Giorni');
    ylabel('Prezzi Normalizzati');
    title('Andamento dei Prezzi degli Asset Normalizzati');

    % Confronto tra i rendimenti logaritmici degli asset
    figure;
    plot(R);
    legend(tickers, 'Location', 'best');
    xlabel('Giorni');
    ylabel('Rendimenti Logaritmici');
    title('Confronto tra i Rendimenti Logaritmici degli Asset');

    % Calcolo del beta di ogni asset rispetto al mercato
    beta = zeros(1, size(R, 2));
    var_mercato = var(MercatoR);
    for i = 1:size(R, 2)
        cov_mercato_asset = cov(MercatoR, R(:, i));
        beta(i) = cov_mercato_asset(1, 2) / var_mercato;
    end

    % Grafico del beta di ogni asset
    figure;
    bar(beta);
    set(gca, 'XTick', 1:length(tickers), 'XTickLabel', tickers, 'XTickLabelRotation', 45, 'FontSize', 8);
    ylabel('Beta');
    title('Beta di Ogni Asset');

    % Calcola i valori annualizzati
    annualized_m = (1 + m) .^ 252 - 1;
    annualized_s = s * sqrt(252);

    % Grafico heatmap della matrice di varianza-covarianza (valori annualizzati)
    annualized_V = V * 252;
    figure;
    heatmap(tickers, tickers, annualized_V, 'Colormap', parula, 'ColorbarVisible', 'on');
    title('Matrice di Varianza-Covarianza (Valori Annualizzati)');

    % Grafico heatmap della matrice di correlazione (valori annualizzati)
    figure;
    heatmap(tickers, tickers, C, 'Colormap', parula, 'ColorbarVisible', 'on');
    title('Matrice di Correlazione (Valori Annualizzati)');

    % Grafico del piano media-varianza (valori annualizzati)
    figure;
    scatter(annualized_s, annualized_m, 'filled');
    text(annualized_s, annualized_m, tickers, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    xlabel('Rischio Annualizzato (Deviazione Standard)');
    ylabel('Rendimento Annualizzato Medio');
    title('Piano Media-Varianza (Valori Annualizzati)');

    % Confronto tra i rendimenti logaritmici annualizzati degli asset
    annualized_R = (1 + R) .^ 252 - 1;
    figure;
    plot(annualized_R);
    legend(tickers, 'Location', 'best');
    xlabel('Giorni');
    ylabel('Rendimenti Logaritmici Annualizzati');
    title('Confronto tra i Rendimenti Logaritmici Annualizzati degli Asset');

    % Stampa i risultati
    disp('Matrice di Varianza-Covarianza (Valori Giornalieri):');
    disp(V);
    disp('Matrice di Correlazione (Valori Giornalieri):');
    disp(C);
    disp('Beta di Ogni Asset:');
    disp(array2table(beta, 'VariableNames', tickers));
    disp('Matrice di Varianza-Covarianza (Valori Annualizzati):');
    disp(annualized_V);
    disp('Matrice di Correlazione (Valori Annualizzati):');
    disp(C);
end

