% Path del file
filePath = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';

% Leggi i dati dal worksheet "NASindexM" mantenendo i nomi originali delle colonne
opts = detectImportOptions(filePath, 'Sheet', 'NASindexM');
opts.VariableNamingRule = 'preserve';
data = readtable(filePath, opts);

% Calcola i rendimenti mensili
returns = diff(log(data.('NASDAQ COMPOSITE - PRICE INDEX')));

% Calcola le statistiche mensili
meanReturn = mean(returns);
varianceReturn = var(returns);
stdDevReturn = std(returns);
skewnessReturn = skewness(returns);
kurtosisReturn = kurtosis(returns);

% Crea una tabella con le statistiche mensili
statsTable = table(meanReturn, varianceReturn, stdDevReturn, skewnessReturn, kurtosisReturn, ...
    'VariableNames', {'Media_Mensile', 'Varianza_Mensile', 'Deviazione_Standard_Mensile', 'Skewness_Mensile', 'Kurtosi_Mensile'});

% Visualizza la tabella
disp('Statistiche per NASindexM:');
disp(statsTable);

% Plot della distribuzione dei rendimenti mensili
figure;
histogram(returns, 'Normalization', 'pdf');
hold on;

% Sovrapposizione della curva di Gauss mensile
x = linspace(min(returns), max(returns), 100);
gaussCurve = normpdf(x, meanReturn, stdDevReturn);
plot(x, gaussCurve, 'r', 'LineWidth', 2);

title('Distribuzione dei Rendimenti e Curva di Gauss per NASindexM');
xlabel('Rendimenti');
ylabel('Densità di Probabilità');
legend('Distribuzione dei Rendimenti', 'Curva di Gauss');
hold off;
