% Importa i dati dal file Excel con la regola di denominazione delle variabili preservata
opts = detectImportOptions('C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx', 'Sheet', 'SP500indexDRet');
opts.VariableNamingRule = 'preserve';
data = readtable('C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx', opts);

% Calcola i rendimenti giornalieri
dailyReturns = diff(log(data{:, 2}));

% Calcola i rendimenti annuali
annualReturns = (1 + dailyReturns).^252 - 1;

% Calcola le statistiche giornaliere
dailyMean = mean(dailyReturns);
dailyVariance = var(dailyReturns);
dailyStdDev = std(dailyReturns);
dailySkewness = skewness(dailyReturns);
dailyKurtosis = kurtosis(dailyReturns);

% Calcola le statistiche annuali
annualMean = mean(annualReturns);
annualVariance = var(annualReturns);
annualStdDev = std(annualReturns);
annualSkewness = skewness(annualReturns);
annualKurtosis = kurtosis(annualReturns);

% Crea una tabella con i risultati
results = table({'Daily'; 'Annual'}, [dailyMean; annualMean], [dailyVariance; annualVariance], ...
    [dailyStdDev; annualStdDev], [dailySkewness; annualSkewness], [dailyKurtosis; annualKurtosis], ...
    'VariableNames', {'Frequency', 'Mean', 'Variance', 'StdDev', 'Skewness', 'Kurtosis'});
disp(results);

% Crea il grafico della distribuzione dei rendimenti giornalieri
figure;
histogram(dailyReturns, 'Normalization', 'pdf');
hold on;

% Aggiungi la curva gaussiana
x = linspace(min(dailyReturns), max(dailyReturns), 100);
y = normpdf(x, dailyMean, dailyStdDev);
plot(x, y, 'r', 'LineWidth', 2);
title('Distribuzione dei Rendimenti Giornalieri con Curva Gaussiana');
xlabel('Rendimenti');
ylabel('Densità di Probabilità');
hold off;
