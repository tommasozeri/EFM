% Percorso del file Excel
filePath = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';

% Leggi i dati dal worksheet "nasdaq daily" preservando i nomi originali delle colonne
opts = detectImportOptions(filePath, 'Sheet', 'nasdaq daily');
opts.VariableNamingRule = 'preserve';
data = readtable(filePath, opts);

% Estrai i nomi dei titoli e i prezzi dei titoli (assumendo che siano nella seconda colonna in poi)
stockNames = data.Properties.VariableNames(2:end);
prices = data{:, 2:end};

% Calcola i rendimenti giornalieri
returns = diff(log(prices));

% Esegui i test di normalità per ogni titolo
numStocks = size(returns, 2);
jb_h = zeros(1, numStocks);
jb_p = zeros(1, numStocks);
ad_h = zeros(1, numStocks);
ad_p = zeros(1, numStocks);
ks_h = zeros(1, numStocks);
ks_p = zeros(1, numStocks);

for i = 1:numStocks
    % Test di Jarque-Bera
    [jb_h(i), jb_p(i)] = jbtest(returns(:, i));
    
    % Test di Anderson-Darling
    [ad_h(i), ad_p(i)] = adtest(returns(:, i));
    
    % Test di Lilliefors (Kolmogorov-Smirnov)
    [ks_h(i), ks_p(i)] = lillietest(returns(:, i));
end

% Crea una tabella riassuntiva dei risultati
resultsTable = table(stockNames', jb_h', jb_p', ad_h', ad_p', ks_h', ks_p', ...
    'VariableNames', {'Titolo', 'JarqueBera_h', 'JarqueBera_p', 'AndersonDarling_h', 'AndersonDarling_p', 'Lilliefors_h', 'Lilliefors_p'});

% Crea una tabella riassuntiva della normalità
normalitySummary = cell(numStocks, 1);
for i = 1:numStocks
    if jb_h(i) == 0 && ad_h(i) == 0 && ks_h(i) == 0
        normalitySummary{i} = 'Si';
    else
        normalitySummary{i} = 'No';
    end
end

summaryTable = table(stockNames', normalitySummary, 'VariableNames', {'Titolo', 'Normale'});

% Visualizza le tabelle
disp('Risultati dei test di normalità per ciascun titolo:');
disp(resultsTable);

disp('Tabella riassuntiva della normalità per ciascun titolo:');
disp(summaryTable);

% Commenta i risultati
for i = 1:numStocks
    disp(['Titolo ', stockNames{i}, ':']);
    if jb_h(i) == 0
        disp('  Jarque-Bera: Non possiamo rifiutare l''ipotesi nulla: i rendimenti seguono una distribuzione normale.');
    else
        disp('  Jarque-Bera: Rifiutiamo l''ipotesi nulla: i rendimenti non seguono una distribuzione normale.');
    end
    
    if ad_h(i) == 0
        disp('  Anderson-Darling: Non possiamo rifiutare l''ipotesi nulla: i rendimenti seguono una distribuzione normale.');
    else
        disp('  Anderson-Darling: Rifiutiamo l''ipotesi nulla: i rendimenti non seguono una distribuzione normale.');
    end
    
    if ks_h(i) == 0
        disp('  Lilliefors: Non possiamo rifiutare l''ipotesi nulla: i rendimenti seguono una distribuzione normale.');
    else
        disp('  Lilliefors: Rifiutiamo l''ipotesi nulla: i rendimenti non seguono una distribuzione normale.');
    end
end
