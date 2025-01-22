% Leggi il file Excel
T = readtable('NASBLALLDaily.xlsx', 'VariableNamingRule', 'preserve');

% Definisci i nomi degli asset e del benchmark
assetNames = ["APPLE", "NVIDIA", "MICROSOFT", "AMAZON.COM", "META PLATFORMS A", "TESLA", "PEPSICO"];
benchmarkName = "NASDAQ COMPOSITE PRICE INDEX";

% Visualizza i nomi delle colonne
disp(T.Properties.VariableNames);

% Trova il nome corretto della colonna per il benchmark
nasdaqIndex = find(contains(T.Properties.VariableNames, 'NASDAQ'), 1);
if ~isempty(nasdaqIndex)
    benchmarkName = T.Properties.VariableNames{nasdaqIndex};
else
    error('Nessuna colonna trovata con "NASDAQ" nel nome.');
end

% Visualizza tutte le righe della tabella
disp(T(:, ["Date", benchmarkName, assetNames]));

% Calcola i rendimenti
retnsT = tick2ret(T(:, 2:end));
assetRetns = retnsT(:, assetNames);
benchRetn = retnsT(:, benchmarkName);
numAssets = size(assetRetns, 2);

% Definisci le viste
v = 4;  % totale 4 viste
P = zeros(v, numAssets);
q = zeros(v, 1);
Omega = zeros(v);

% Vista 1
P(1, assetNames=="PEPSICO") = 1; 
q(1) = 0.05;
Omega(1, 1) = 1e-3;

% Vista 2
P(2, assetNames=="NVIDIA") = 1; 
q(2) = 0.03;
Omega(2, 2) = 1e-3;

% Vista 3
P(3, assetNames=="APPLE") = 1; 
P(3, assetNames=="MICROSOFT") = -1; 
q(3) = 0.05;
Omega(3, 3) = 1e-5;

% Vista 4
P(4, assetNames=="NVIDIA") = 1; 
P(4, assetNames=="MICROSOFT") = -1; 
q(4) = 0.05;
Omega(4, 4) = 1e-5;

% Converti le viste da rendimenti annuali a rendimenti giornalieri
bizyear2bizday = 1/252;
q = q * bizyear2bizday; 
Omega = Omega * bizyear2bizday;

% Crea la tabella delle viste
viewTable = array2table([P q diag(Omega)], 'VariableNames', [assetNames "View_Return" "View_Uncertainty"]);
disp(viewTable);

% Stima la covarianza dai rendimenti storici degli asset
Sigma = cov(assetRetns.Variables);

% Definisci l'incertezza C
tau = 1/size(assetRetns.Variables, 1);
C = tau * Sigma;
disp(C);

% Trova il portafoglio di mercato e i rendimenti impliciti
[wtsMarket, PI] = findMarketPortfolioAndImpliedReturn(assetRetns.Variables, benchRetn.Variables);

% Calcola il rendimento medio stimato e la covarianza utilizzando il modello Black-Litterman
mu_bl = (P'*(Omega\P) + inv(C)) \ ( C\PI + P'*(Omega\q));
cov_mu = inv(P'*(Omega\P) + inv(C));

% Ottimizzazione del portafoglio
port = Portfolio('NumAssets', numAssets, 'lb', 0, 'budget', 1, 'Name', 'Mean Variance');
port = setAssetMoments(port, mean(assetRetns.Variables), Sigma);
wts = estimateMaxSharpeRatio(port);

portBL = Portfolio('NumAssets', numAssets, 'lb', 0, 'budget', 1, 'Name', 'Mean Variance with Black-Litterman');
portBL = setAssetMoments(portBL, mu_bl, Sigma + cov_mu);  
wtsBL = estimateMaxSharpeRatio(portBL);

% Calcola le statistiche del portafoglio media-varianza
meanMV = mean(assetRetns.Variables * wts);
stdMV = std(assetRetns.Variables * wts);
skewMV = skewness(assetRetns.Variables * wts);
kurtMV = kurtosis(assetRetns.Variables * wts);

% Calcola le statistiche del portafoglio Black-Litterman
meanBL = mean(assetRetns.Variables * wtsBL);
stdBL = std(assetRetns.Variables * wtsBL);
skewBL = skewness(assetRetns.Variables * wtsBL);
kurtBL = kurtosis(assetRetns.Variables * wtsBL);

% Stampa le statistiche a schermo
fprintf('Statistiche del Portafoglio Media-Varianza:\n');
fprintf('Media: %f\n', meanMV);
fprintf('Deviazione Standard: %f\n', stdMV);
fprintf('Skewness: %f\n', skewMV);
fprintf('Curtosi: %f\n', kurtMV);

fprintf('\nStatistiche del Portafoglio Black-Litterman:\n');
fprintf('Media: %f\n', meanBL);
fprintf('Deviazione Standard: %f\n', stdBL);
fprintf('Skewness: %f\n', skewBL);
fprintf('Curtosi: %f\n', kurtBL);

% Visualizza la matrice di covarianza utilizzando l'approccio Black-Litterman
figure;
imagesc(cov_mu);
colorbar;
title('Covarianza dei Rendimenti Stimati con Black-Litterman');
xlabel('Asset');
ylabel('Asset');
set(gca, 'XTick', 1:numAssets, 'XTickLabel', assetNames, 'YTick', 1:numAssets, 'YTickLabel', assetNames);

% Funzione locale per trovare il portafoglio di mercato e i rendimenti impliciti
function [wtsMarket, PI] = findMarketPortfolioAndImpliedReturn(assetRetn, benchRetn)
    % Trova la matrice di covarianza
    Sigma = cov(assetRetn);
    
    % Trova il portafoglio di mercato
    numAssets = size(assetRetn, 2);
    LB = zeros(1, numAssets);
    Aeq = ones(1, numAssets);
    Beq = 1;
    opts = optimoptions('lsqlin', 'Algorithm', 'interior-point', 'Display', 'off');
    wtsMarket = lsqlin(assetRetn, benchRetn, [], [], Aeq, Beq, LB, [], [], opts);
    
    % Trova delta
    shpr = mean(benchRetn) / std(benchRetn);
    delta = shpr / sqrt(wtsMarket' * Sigma * wtsMarket);
    
    % Calcola i rendimenti impliciti
    PI = delta * Sigma * wtsMarket;
end
