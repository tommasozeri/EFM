function analisi_portafoglio_3d
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

    % Calcola il rendimento medio e il rischio (deviazione standard)
    m = mean(R);
    s = std(R);

    % Calcolo del beta di ogni asset rispetto al mercato
    beta = zeros(1, size(R, 2));
    var_mercato = var(MercatoR);
    for i = 1:size(R, 2)
        cov_mercato_asset = cov(MercatoR, R(:, i));
        beta(i) = cov_mercato_asset(1, 2) / var_mercato;
    end

    % Grafico 3D del Piano Media-Varianza-Beta
    figure;
    scatter3(s, m, beta, 'filled');
    text(s, m, beta, tickers, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    xlabel('Rischio (Deviazione Standard)');
    ylabel('Rendimento Medio');
    zlabel('Beta');
    title('Piano Media-Varianza-Beta');
    grid on;

    % Calcola i valori annualizzati
    annualized_m = (1 + m) .^ 252 - 1;
    annualized_s = s * sqrt(252);
    annualized_V = V * 252;

    % Grafico 3D del Piano Media-Varianza-Beta (valori annualizzati)
    figure;
    scatter3(annualized_s, annualized_m, beta, 'filled');
    text(annualized_s, annualized_m, beta, tickers, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    xlabel('Rischio Annualizzato (Deviazione Standard)');
    ylabel('Rendimento Annualizzato Medio');
    zlabel('Beta');
    title('Piano Media-Varianza-Beta (Valori Annualizzati)');
    grid on;

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
