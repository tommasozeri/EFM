% Carica i dati dal file Excel
filePath = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';
sheetNameAssets = 'nasdaq monthly';
sheetNameIndex = 'NASindexD';
dataAssets = readtable(filePath, 'Sheet', sheetNameAssets, 'VariableNamingRule', 'preserve');
dataIndex = readtable(filePath, 'Sheet', sheetNameIndex, 'VariableNamingRule', 'preserve');

% Estrai i dati del titolo Moderna
modernaPrices = dataAssets{:, 'MODERNA'}; % Supponendo che la colonna si chiami 'Moderna'
returnsModerna = diff(modernaPrices) ./ modernaPrices(1:end-1);

% Calcola i rendimenti mensili dell'indice NASDAQ
pricesIndex = dataIndex{:, 2}; % Supponendo che la prima colonna sia la data
returnsIndex = diff(pricesIndex) ./ pricesIndex(1:end-1);

% Allinea le date tra i rendimenti di Moderna e dell'indice
datesAssets = dataAssets{2:end, 1};
datesIndex = dataIndex{2:end, 1};
[commonDates, idxAssets, idxIndex] = intersect(datesAssets, datesIndex);
returnsModerna = returnsModerna(idxAssets);
returnsIndex = returnsIndex(idxIndex);

% Calcola le statistiche
meanReturnModerna = mean(returnsModerna);
stdReturnModerna = std(returnsModerna);

% Calcola il beta di Moderna tramite regressione
mdl = fitlm(returnsIndex, returnsModerna);
betaModerna = mdl.Coefficients.Estimate(2);

% Calcola il tasso risk-free mensile
riskFreeRate = 0.02 / 12; % 2% annuo convertito in mensile

% Calcola la SML per Moderna
marketReturn = mean(returnsIndex);
marketRiskPremium = marketReturn - riskFreeRate;
smlValueModerna = riskFreeRate + marketRiskPremium * betaModerna;

% Stampa i risultati e confronta i rendimenti attesi con i rendimenti effettivi
fprintf('Rendimento atteso di Moderna: %f\n', meanReturnModerna);
fprintf('Beta di Moderna: %f\n', betaModerna);
fprintf('Valore della SML per Moderna: %f\n', smlValueModerna);
fprintf('Confronto tra rendimento atteso e rendimento effettivo di Moderna:\n');
fprintf('Rendimento atteso = %f, Rendimento effettivo = %f\n', smlValueModerna, meanReturnModerna);

% Traccia il piano media-varianza con Moderna e la SML
figure;
scatter(betaModerna, meanReturnModerna, 'b', 'filled');
hold on;
text(betaModerna, meanReturnModerna, 'Moderna', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
plot([0, betaModerna], [riskFreeRate, smlValueModerna], '-r', 'LineWidth', 2);
xlabel('Beta');
ylabel('Rendimento Atteso');
title('Piano Media-Varianza con SML per Moderna');
legend('Moderna', 'SML');
grid on;
xlim([0, betaModerna * 1.1]); % Aggiungi un po' di spazio extra sull'asse x
ylim([min(meanReturnModerna) * 0.9, max(meanReturnModerna) * 1.1]); % Aggiungi un po' di spazio extra sull'asse y
