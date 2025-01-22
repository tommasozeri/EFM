% Definisci il percorso del file
filename = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';
sheet = 'nasdaq daily';

% Carica il file Excel
opts = detectImportOptions(filename, 'Sheet', sheet);
opts.VariableNamingRule = 'preserve';
data = readtable(filename, opts);

% Visualizza i dati
disp(data);

% Estrai le date e i ticker
dates = data{:, 1};
tickers = data.Properties.VariableNames(2:end);

% Converti i dati delle celle in valori numerici se necessario
for i = 2:width(data)
    if iscell(data{:, i})
        data{:, i} = str2double(data{:, i});
    end
end

% Calcola i rendimenti giornalieri
returns = diff(log(data{:, 2:end}));

% Inizializza le variabili per i risultati
mean_values = mean(returns);
variance_values = var(returns);
std_dev_values = std(returns);
skewness_values = skewness(returns);
kurtosis_values = kurtosis(returns);

% Crea una tabella con i risultati
results = table(tickers', mean_values', variance_values', std_dev_values', skewness_values', kurtosis_values', ...
    'VariableNames', {'Ticker', 'Mean', 'Variance', 'StandardDeviation', 'Skewness', 'Kurtosis'});

% Visualizza i risultati
disp(results);

%% GRAFICI --------------------------------------------------------------------------------------------------------------------------------------------------------

% Crea i grafici per ogni categoria
figure;
bar(mean_values);
title('Mean');
set(gca, 'XTick', 1:length(tickers), 'XTickLabel', tickers);
xtickangle(45);
ylabel('Value');
xlabel('Tickers');

figure;
bar(variance_values);
title('Variance');
set(gca, 'XTick', 1:length(tickers), 'XTickLabel', tickers);
xtickangle(45);
ylabel('Value');
xlabel('Tickers');

figure;
bar(std_dev_values);
title('Standard Deviation');
set(gca, 'XTick', 1:length(tickers), 'XTickLabel', tickers);
xtickangle(45);
ylabel('Value');
xlabel('Tickers');

figure;
bar(skewness_values);
title('Skewness');
set(gca, 'XTick', 1:length(tickers), 'XTickLabel', tickers);
xtickangle(45);
ylabel('Value');
xlabel('Tickers');

figure;
bar(kurtosis_values);
title('Kurtosis');
set(gca, 'XTick', 1:length(tickers), 'XTickLabel', tickers);
xtickangle(45);
ylabel('Value');
xlabel('Tickers');

% Aggiusta la dimensione della figura
set(gcf, 'Position', [100, 100, 1200, 800]);

% Visualizza i grafici
sgtitle('Comparison of Statistics for Each Ticker');
