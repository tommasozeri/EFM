% Path del file
filePath = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';

% Leggi i dati dal worksheet "SP500indexD" mantenendo i nomi originali delle colonne
opts = detectImportOptions(filePath, 'Sheet', 'SP500indexD');
opts.VariableNamingRule = 'preserve';
data = readtable(filePath, opts);

% Calcola i rendimenti giornalieri
returns = diff(log(data.('S&P 500 COMPOSITE - PRICE INDEX')));

% Calcola le statistiche giornaliere
meanReturn = mean(returns);
varianceReturn = var(returns);
stdDevReturn = std(returns);
skewnessReturn = skewness(returns);
kurtosisReturn = kurtosis(returns);

% Crea una tabella con le statistiche giornaliere
dailyStatsTable = table(meanReturn, varianceReturn, stdDevReturn, skewnessReturn, kurtosisReturn, ...
    'VariableNames', {'Media_Giornaliera', 'Varianza_Giornaliera', 'Deviazione_Standard_Giornaliera', 'Skewness_Giornaliera', 'Kurtosi_Giornaliera'});

% Visualizza la tabella
disp('Statistiche Giornaliera:');
disp(dailyStatsTable);

% Plot della distribuzione dei rendimenti giornalieri
figure;
histogram(returns, 'Normalization', 'pdf');
hold on;

% Sovrapposizione della curva di Gauss giornaliera
x = linspace(min(returns), max(returns), 100);
gaussCurve = normpdf(x, meanReturn, stdDevReturn);
plot(x, gaussCurve, 'r', 'LineWidth', 2);

title('Distribuzione dei Rendimenti e Curva di Gauss');
xlabel('Rendimenti');
ylabel('Densità di Probabilità');
legend('Distribuzione dei Rendimenti', 'Curva di Gauss');
hold off;
