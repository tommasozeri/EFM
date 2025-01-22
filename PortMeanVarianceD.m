% Carica i dati dal file Excel
filePath = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';
sheetNameAssets = 'NASselectedD';
sheetNameIndex = 'NASindexD';
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

% Assicurati che il numero di osservazioni sia lo stesso
minLength = min(size(returnsAssets, 1), length(returnsIndex));
returnsAssets = returnsAssets(1:minLength, :);
returnsIndex = returnsIndex(1:minLength);

% Calcola le statistiche
meanReturns = mean(returnsAssets);
stdReturns = std(returnsAssets);
covMatrix = cov(returnsAssets);

% Calcola i pesi del portafoglio ottimale media-varianza con vincoli
numAssets = size(returnsAssets, 2);
options = optimoptions('quadprog', 'Display', 'off');
Aeq = ones(1, numAssets);
beq = 1;
lb = zeros(numAssets, 1);
ub = ones(numAssets, 1);
weights = quadprog(covMatrix, [], [], [], Aeq, beq, lb, ub, [], options);

% Calcola la media e la deviazione standard del portafoglio
portfolioMean = meanReturns * weights;
portfolioStd = sqrt(weights' * covMatrix * weights);

% Calcola i beta dei titoli
beta_assets = zeros(1, numAssets);
var_mercato = var(returnsIndex);
for i = 1:numAssets
    cov_mercato_asset = cov(returnsIndex, returnsAssets(:, i));
    beta_assets(i) = cov_mercato_asset(1, 2) / var_mercato;
end

% Calcola il beta del portafoglio
portfolioBeta = sum(weights' .* beta_assets);

% Calcola il tasso risk-free giornaliero
riskFreeRate = 0.02 / 252; % 2% annuo convertito in giornaliero

% Calcola la SML per il portafoglio
marketReturn = mean(returnsIndex);
marketRiskPremium = marketReturn - riskFreeRate;
smlValue = riskFreeRate + marketRiskPremium * portfolioBeta;

% Stampa i risultati
fprintf('Pesi del portafoglio ottimale:\n');
for i = 1:numAssets
    fprintf('%s: %f\n', assetNames{i}, weights(i));
end
fprintf('Media del portafoglio: %f\n', portfolioMean);
fprintf('Deviazione standard del portafoglio: %f\n', portfolioStd);
fprintf('Beta dei titoli:\n');
for i = 1:numAssets
    fprintf('%s: %f\n', assetNames{i}, beta_assets(i));
end
fprintf('Beta del portafoglio: %f\n', portfolioBeta);
fprintf('Valore della SML per il portafoglio: %f\n', smlValue);
