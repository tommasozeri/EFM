% Carica i dati dal file Excel NAS30BM.xlsx
A = readtable('NAS30BM.xlsx', 'ReadRowNames', true);
tickers = A.Properties.VariableNames;
A = table2array(A);
A = cellfun(@str2double, A);

% Calcola la matrice di covarianza dei rendimenti degli asset.
sigma = std(A); % Deviazione standard dei rendimenti degli asset
rho = corrcoef(A); % Matrice di correlazione dei rendimenti degli asset
Sigma = corr2cov(sigma, rho); % Matrice di covarianza

% Verifica che Sigma sia semidefinita positiva. Tutti
% gli autovalori dovrebbero essere non negativi (>= 0).
if any(eig(Sigma) < 0)
    error('La matrice di covarianza non è semidefinita positiva.');
end

% Definisci un budget di rischio inversamente proporzionale alla volatilità.
budget = 1 ./ sigma'; % Inverso della volatilità
budget = budget / sum(budget); % Normalizza il budget di rischio

% Assicurati che la dimensione del budget corrisponda al numero di asset.
if length(budget) ~= size(Sigma, 1)
    error('La dimensione del budget di rischio deve corrispondere al numero di asset nella matrice di covarianza.');
end

% Funzione di ottimizzazione per il portafoglio di risk budgeting.
options = optimoptions('fmincon', 'Display', 'off');
wRB = fmincon(@(w) w' * Sigma * w, ones(size(Sigma, 1), 1) / size(Sigma, 1), [], [], [], [], zeros(size(Sigma, 1), 1), ones(size(Sigma, 1), 1), @(w) deal([], budget' * log(w) - sum(budget .* log(budget))), options);

% Calcola il contributo al rischio per ciascun asset.
prc = portfolioRiskContribution(wRB, Sigma);
mrc = portfolioRiskContribution(wRB, Sigma, 'RiskContributionType', 'absolute');

% Calcola le statistiche giornaliere e annuali per il portafoglio di risk budgeting.
dailyReturnRB = mean(A * wRB);
annualReturnRB = (1 + dailyReturnRB) ^ 252 - 1; % Correzione del calcolo del rendimento annuale
dailyVolatilityRB = std(A * wRB);
annualVolatilityRB = dailyVolatilityRB * sqrt(252);

% Visualizza una tabella dei pesi per i portafogli di risk budgeting.
RBtable = array2table(wRB', 'VariableNames', tickers);

% Stampa a schermo le informazioni per ogni titolo e i pesi di portafoglio.
disp('Informazioni per ogni titolo e pesi di portafoglio:');
for i = 1:length(tickers)
    fprintf('Titolo: %s\n', tickers{i});
    fprintf('Peso Risk Budgeting: %.4f\n', wRB(i));
    fprintf('Contributo al Rischio Relativo: %.4f\n', prc(i));
    fprintf('Contributo al Rischio Assoluto: %.4f\n\n', mrc(i));
end

% Stampa a schermo le statistiche giornaliere e annuali per il portafoglio di risk budgeting.
fprintf('Statistiche del portafoglio di Risk Budgeting:\n');
fprintf('Rendimento giornaliero: %.4f\n', dailyReturnRB);
fprintf('Rendimento annuale: %.4f\n', annualReturnRB);
fprintf('Volatilità giornaliera: %.4f\n', dailyVolatilityRB);
fprintf('Volatilità annuale: %.4f\n\n', annualVolatilityRB);
