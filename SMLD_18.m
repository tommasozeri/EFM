% Carica i dati dal file Excel
filePath = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';
sheetNameAssets = 'nyse daily';
sheetNameIndex = 'SP500indexD';
dataAssets = readtable(filePath, 'Sheet', sheetNameAssets, 'VariableNamingRule', 'preserve');
dataIndex = readtable(filePath, 'Sheet', sheetNameIndex, 'VariableNamingRule', 'preserve');

% Estrai i nomi dei titoli
assetNames = dataAssets.Properties.VariableNames(2:end);

% Calcola i rendimenti giornalieri dei titoli
pricesAssets = dataAssets{:, 2:end}; % Supponendo che la prima colonna sia la data
returnsAssets = diff(pricesAssets) ./ pricesAssets(1:end-1, :);

% Calcola i rendimenti giornalieri dell'indice NASDAQ
pricesIndex = dataIndex{:, 2}; % Supponendo che la prima colonna sia la data
returnsIndex = diff(pricesIndex) ./ pricesIndex(1:end-1);

% Allinea le date tra i rendimenti dei titoli e dell'indice
datesAssets = dataAssets{2:end, 1};
datesIndex = dataIndex{2:end, 1};
[commonDates, idxAssets, idxIndex] = intersect(datesAssets, datesIndex);
returnsAssets = returnsAssets(idxAssets, :);
returnsIndex = returnsIndex(idxIndex);

% Calcola le statistiche
meanReturns = mean(returnsAssets);
stdReturns = std(returnsAssets);

% Calcola i beta dei titoli tramite regressione
beta_assets = zeros(1, size(returnsAssets, 2));
for i = 1:size(returnsAssets, 2)
    mdl = fitlm(returnsIndex, returnsAssets(:, i));
    beta_assets(i) = mdl.Coefficients.Estimate(2);
end

% Calcola il tasso risk-free giornaliero
riskFreeRate = 0.02 / 252; % 2% annuo convertito in giornaliero

% Calcola la SML per ogni titolo
marketReturn = mean(returnsIndex);
marketRiskPremium = marketReturn - riskFreeRate;
smlValues = riskFreeRate + marketRiskPremium * beta_assets;

% Stampa i risultati e confronta i rendimenti attesi con i rendimenti effettivi
fprintf('Rendimento atteso dei titoli:\n');
for i = 1:length(assetNames)
    fprintf('%s: %f\n', assetNames{i}, meanReturns(i));
end
fprintf('Beta dei titoli:\n');
for i = 1:length(assetNames)
    fprintf('%s: %f\n', assetNames{i}, beta_assets(i));
end
fprintf('Valore della SML per i titoli:\n');
for i = 1:length(assetNames)
    fprintf('%s: %f\n', assetNames{i}, smlValues(i));
end
fprintf('Confronto tra rendimenti attesi e rendimenti effettivi:\n');
for i = 1:length(assetNames)
    fprintf('%s: Rendimento atteso = %f, Rendimento effettivo = %f\n', assetNames{i}, smlValues(i), meanReturns(i));
end

% Traccia il piano media-varianza con tutti i titoli e la SML
figure;
scatter(beta_assets, meanReturns, 'b', 'filled');
hold on;
for i = 1:length(assetNames)
    text(beta_assets(i), meanReturns(i), assetNames{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
plot([0, max(beta_assets)], [riskFreeRate, max(smlValues)], '-r', 'LineWidth', 2);
xlabel('Beta');
ylabel('Rendimento Atteso');
title('Piano Media-Varianza con SML');
legend('Titoli', 'SML');
grid on;
xlim([0, max(beta_assets) * 1.1]); % Aggiungi un po' di spazio extra sull'asse x
ylim([min(meanReturns) * 0.9, max(meanReturns) * 1.1]); % Aggiungi un po' di spazio extra sull'asse y
