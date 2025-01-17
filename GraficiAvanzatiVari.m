function analisi_portafoglio_avanzata
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

    % Grafico della frontiera efficiente
    p = Portfolio('AssetList', tickers, 'RiskFreeRate', 0.02 / 252);
    p = setAssetMoments(p, m, V);
    p = setDefaultConstraints(p);
    pwgt = estimateFrontier(p, 20);
    [prsk, pret] = estimatePortMoments(p, pwgt);
    q = setBudget(p, 0, 1);
    qwgt = estimateFrontier(q, 20);
    [qrsk, qret] = estimatePortMoments(q, qwgt);

    figure;
    plot(prsk, pret, 'b-', 'LineWidth', 2);
    hold on;
    plot(qrsk, qret, 'g--', 'LineWidth', 2);
    scatter(s, m, 'filled');
    text(s, m, tickers, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    xlabel('Rischio (Deviazione Standard)');
    ylabel('Rendimento Atteso');
    title('Frontiera Efficiente sul Piano Media-Varianza');
    legend('Frontiera Efficiente', 'Linea Tangente', 'Asset', 'Location', 'Best');
    grid on;
    hold off;

    % Grafico del rapporto di Sharpe
    sharpe_ratio = (pret - 0.02 / 252) ./ prsk;
    figure;
    plot(prsk, sharpe_ratio, 'b-', 'LineWidth', 2);
    xlabel('Rischio (Deviazione Standard)');
    ylabel('Rapporto di Sharpe');
    title('Rapporto di Sharpe lungo la Frontiera Efficiente');
    grid on;

    % Grafico del turnover
    turnover = sum(abs(diff(pwgt, 1, 2)), 1);
    figure;
    plot(1:length(turnover), turnover, 'b-', 'LineWidth', 2);
    xlabel('Portafogli');
    ylabel('Turnover');
    title('Turnover lungo la Frontiera Efficiente');
    grid on;

    % Grafico del tracking error
    tracking_error = sqrt(sum((pwgt - repmat(mean(pwgt, 2), 1, size(pwgt, 2))).^2, 1));
    figure;
    plot(1:length(tracking_error), tracking_error, 'b-', 'LineWidth', 2);
    xlabel('Portafogli');
    ylabel('Tracking Error');
    title('Tracking Error lungo la Frontiera Efficiente');
    grid on;

    % Grafico del peso degli asset
    figure;
    area(pwgt');
    xlabel('Portafogli');
    ylabel('Peso degli Asset');
    title('Peso degli Asset lungo la Frontiera Efficiente');
    legend(tickers, 'Location', 'best');
    grid on;

    % Grafico del rendimento cumulativo
    rendimento_cumulativo = cumprod(1 + R);
    figure;
    plot(rendimento_cumulativo);
    legend(tickers, 'Location', 'best');
    xlabel('Giorni');
    ylabel('Rendimento Cumulativo');
    title('Rendimento Cumulativo degli Asset');
    grid on;

    % Grafico del drawdown
    drawdown = max(1 - rendimento_cumulativo ./ cummax(rendimento_cumulativo), [], 2);
    figure;
    plot(drawdown);
    legend(tickers, 'Location', 'best');
    xlabel('Giorni');
    ylabel('Drawdown');
    title('Drawdown degli Asset');
    grid on;

    % Grafico della distribuzione dei ritorni
    figure;
    histogram(R, 'Normalization', 'pdf');
    legend(tickers, 'Location', 'best');
    xlabel('Rendimenti Logaritmici');
    ylabel('Densità di Probabilità');
    title('Distribuzione dei Ritorni degli Asset');
    grid on;

    % Calcola i valori annualizzati
    annualized_m = (1 + m) .^ 252 - 1;
    annualized_s = s * sqrt(252);
    annualized_V = V * 252;

    % Grafico heatmap della matrice di varianza-covarianza (valori annualizzati)
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


