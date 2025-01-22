% Definisci il percorso del file
filename = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';
sheet = 'nasdaq monthly';

% Carica il file Excel
opts = detectImportOptions(filename, 'Sheet', sheet);
opts.VariableNamingRule = 'preserve';
data = readtable(filename, opts);

% Visualizza i dati
disp(data);

% Estrai le date e i ticker
dates = data{:, 1};
tickers = data.Properties.VariableNames(2:end);

% Calcola i rendimenti mensili
returns = diff(log(data{:, 2:end}));

% Inizializza le variabili per i risultati
mean_values = zeros(1, length(tickers));
variance_values = zeros(1, length(tickers));
std_dev_values = zeros(1, length(tickers));
skewness_values = zeros(1, length(tickers));
kurtosis_values = zeros(1, length(tickers));

% Calcola le statistiche per ogni ticker
for i = 1:length(tickers)
    mean_values(i) = mean(returns(:, i));
    variance_values(i) = var(returns(:, i));
    std_dev_values(i) = std(returns(:, i));
    skewness_values(i) = skewness(returns(:, i));
    kurtosis_values(i) = kurtosis(returns(:, i));
end

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

