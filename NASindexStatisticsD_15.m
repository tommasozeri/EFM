% Path del file
filePath = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';

% Leggi i dati dal worksheet "SP500indexDRet" mantenendo i nomi originali delle colonne
opts = detectImportOptions(filePath, 'Sheet', 'SP500indexDRet');
opts.VariableNamingRule = 'preserve';
data = readtable(filePath, opts);

% Calcola i rendimenti giornalieri
returns = diff(log(data.('S&P 500 COMPOSITE - TOT RETURN IND')));

% Calcola le statistiche
meanReturn = mean(returns);
varianceReturn = var(returns);
stdDevReturn = std(returns);
skewnessReturn = skewness(returns);
kurtosisReturn = kurtosis(returns);

% Crea una tabella con le statistiche
statsTable = table(meanReturn, varianceReturn, stdDevReturn, skewnessReturn, kurtosisReturn, ...
    'VariableNames', {'Media', 'Varianza', 'Deviazione_Standard', 'Skewness', 'Kurtosi'});

% Visualizza la tabella
disp(statsTable);

% Plot della distribuzione dei rendimenti
figure;
histogram(returns, 'Normalization', 'pdf');
hold on;

% Sovrapposizione della curva di Gauss
x = linspace(min(returns), max(returns), 100);
gaussCurve = normpdf(x, meanReturn, stdDevReturn);
plot(x, gaussCurve, 'r', 'LineWidth', 2);

title('Distribuzione dei Rendimenti e Curva di Gauss');
xlabel('Rendimenti');
ylabel('Densità di Probabilità');
legend('Distribuzione dei Rendimenti', 'Curva di Gauss');
hold off;
