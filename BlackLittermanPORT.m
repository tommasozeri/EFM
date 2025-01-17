% Leggi il file Excel
T = readtable('NAS30BM.xlsx');

% Definisci i nomi degli asset e del benchmark
assetNames = ["PCAR", "MRNA", "AMGN", "TSLA", "MAR", "DLTR", "JD"];
benchmarkName = "QQQ";

% Visualizza i nomi delle colonne
disp(T.Properties.VariableNames);

% Visualizza le prime righe della tabella
head(T(:,["Date" benchmarkName assetNames]))

% Calcola i rendimenti
prices = T{:, 2:end}; % Escludi la colonna delle date
pricesArray = str2double(prices); % Converte i dati in un array di tipo double
retnsT = tick2ret(pricesArray);
assetRetns = array2table(retnsT(:, ismember(T.Properties.VariableNames(2:end), assetNames)), 'VariableNames', cellstr(assetNames));
benchRetn = array2table(retnsT(:, ismember(T.Properties.VariableNames(2:end), benchmarkName)), 'VariableNames', cellstr(benchmarkName));
numAssets = size(assetRetns, 2);

% Visualizza i rendimenti degli asset e del benchmark
disp(assetRetns);
disp(benchRetn);
% Definisci le viste
v = 3;  % totale 3 viste
P = zeros(v, numAssets);
q = zeros(v, 1);
Omega = zeros(v);

% Vista 1 (assoluta)
P(1, assetNames=="TSLA") = 1; 
q(1) = 0.05;
Omega(1, 1) = 1e-3;

% Vista 2 (assoluta)
P(2, assetNames=="JD") = 1; 
q(2) = 0.03;
Omega(2, 2) = 1e-3;

% Vista 3 (assoluta)
P(3, assetNames=="PCAR") = 1; 
P(3, assetNames=="AMGN") = -1; 
q(3) = 0.05;
Omega(3, 3) = 1e-5;

viewTable = array2table([P q diag(Omega)], 'VariableNames', [cellstr(assetNames) "View_Return" "View_Uncertainty"]) 

bizyear2bizday = 1/252;
q = q*bizyear2bizday; 
Omega = Omega*bizyear2bizday;

Sigma = cov(assetRetns.Variables);

tau = 1/size(assetRetns.Variables, 1);
C = tau*Sigma;

[wtsMarket, PI] = findMarketPortfolioAndImpliedReturn(assetRetns.Variables, benchRetn.Variables);

% Correggi le dimensioni di PI
PI_corrected = mean(PI, 1)'; % Calcola la media delle colonne e trasponi per ottenere un vettore colonna 7x1

% Calcola il rendimento atteso e la covarianza utilizzando il modello Black-Litterman
mu_bl = (P'*(Omega\P) + inv(C)) \ (C*PI_corrected + P'*(Omega\q));
cov_mu = inv(P'*(Omega\P) + inv(C));

% Confronta il rendimento atteso del modello Black-Litterman con la convinzione precedente
resultTable = table(assetNames', PI_corrected*252, mu_bl*252, 'VariableNames', ["Asset_Name", "Prior_Belief_of_Expected_Return", "Black_Litterman_Blended_Expected_Return"]);

% Stampa a schermo il confronto tra il rendimento atteso del modello Black-Litterman e la convinzione precedente
disp(resultTable);
% Crea il portafoglio Mean Variance
port = Portfolio('NumAssets', numAssets, 'lb', 0, 'budget', 1, 'Name', 'Mean Variance');
port = setAssetMoments(port, mean(assetRetns.Variables), Sigma);
wts = estimateMaxSharpeRatio(port);

% Crea il portafoglio Mean Variance con Black-Litterman
portBL = Portfolio('NumAssets', numAssets, 'lb', 0, 'budget', 1, 'Name', 'Mean Variance with Black-Litterman');
portBL = setAssetMoments(portBL, mu_bl, Sigma + cov_mu);  
wtsBL = estimateMaxSharpeRatio(portBL);

% Visualizza i pesi dei portafogli
ax1 = subplot(1,2,1);
idx = wts > 0.001;
pie(ax1, wts(idx), assetNames(idx));
title(ax1, port.Name, 'Position', [-0.05, 1.6, 0]);

ax2 = subplot(1,2,2);
idx_BL = wtsBL > 0.001;
pie(ax2, wtsBL(idx_BL), assetNames(idx_BL));
title(ax2, portBL.Name, 'Position', [-0.05, 1.6, 0]);

% Definisci la funzione findMarketPortfolioAndImpliedReturn
function [wtsMarket, PI] = findMarketPortfolioAndImpliedReturn(assetRetns, benchRetn)
    % Calcola i pesi del portafoglio di mercato utilizzando la regressione lineare
    X = [ones(size(benchRetn)), benchRetn];
    b = X \ assetRetns;
    wtsMarket = b(2:end, :);
    
    % Calcola i rendimenti impliciti del mercato
    PI = X * b;
end
