function diversificaPortafogliHRP
    % Carica i dati dal file Excel DBEXAM.xlsx
    opts = detectImportOptions('DBEXAM.xlsx', 'Sheet', 'nasdaq daily');
    opts.VariableNamingRule = 'preserve';
    Dati = readtable('DBEXAM.xlsx', opts);
    tickers = Dati.Properties.VariableNames(2:end); % Escludi la colonna delle date
    Dati = Dati(:, 2:end); % Escludi la colonna delle date
    Dati = table2array(Dati);

    % Calcola i rendimenti giornalieri normali
    n = size(Dati, 1);
    R = (Dati(2:n, :) ./ Dati(1:n-1, :)) - 1;

    % Calcola i rendimenti attesi e la matrice di covarianza
    mu = mean(R)'; % Rendimento atteso (trasposto per ottenere un vettore colonna)
    Sigma = cov(R); % Matrice di covarianza

    % Calcola la matrice di correlazione
    C = corrcov(Sigma);
    figure;
    heatmap(C);
    title('Matrice di Correlazione');

    % Calcola la matrice di distanza di correlazione
    distCorr = ((1 - C) / 2) .^ 0.5;

    % Calcola il linkage
    link = linkage(distCorr);
    figure;
    h = dendrogram(link, 'ColorThreshold', 'default');
    set(h, 'LineWidth', 2);
    title('Default Leaf Order');

    % Ordina gli asset per quasi-diagonalizzazione
    nLeafNodes = size(link, 1) + 1;
    rootNodeId = 2 * nLeafNodes - 1;
    sortedIdx = getLeafNodesInGroup(rootNodeId, link);
    figure;
    heatmap(C(sortedIdx, sortedIdx), 'XData', sortedIdx, 'YData', sortedIdx);
    title('Matrice di Correlazione Ordinata');

    % Ottieni i cluster
    T = cluster(link, 'MaxClust', 6);

    % Calcola il portafoglio HRP
    wHRP = hrpPortfolio(T, Sigma);

    % Crea un oggetto Portfolio
    p = Portfolio('AssetMean', mu, 'AssetCovar', Sigma);
    p = setDefaultConstraints(p); % portafoglio long-only, fully-invested

    % Calcola il portafoglio a varianza minima
    wMV = estimateFrontierLimits(p, 'min');

    % Definisci il numero di asset
    nAssets = size(Sigma, 1);

    % Crea etichette per i grafici a torta
    labels = tickers;

    % Ordina gli asset seguendo l'ordine di quasi-diagonalizzazione
    labels = labels(sortedIdx);
    wMV = wMV(sortedIdx);
    wHRP = wHRP(sortedIdx);

    % Calcola rischio e rendimento dei portafogli
    riskMV = sqrt(wMV' * Sigma * wMV);
    retMV = wMV' * mu * 252; % Annualizza il rendimento
    riskHRP = sqrt(wHRP' * Sigma * wHRP);
    retHRP = wHRP' * mu * 252; % Annualizza il rendimento

    % Annualizza rischio
    annualized_riskMV = riskMV * sqrt(252);
    annualized_riskHRP = riskHRP * sqrt(252);

    % Stampa i pesi dei portafogli con i rispettivi ticker
    disp('Pesi del portafoglio a varianza minima:');
    disp(table(labels', wMV, 'VariableNames', {'Ticker', 'Peso'}));
    disp('Pesi del portafoglio HRP:');
    disp(table(labels', wHRP, 'VariableNames', {'Ticker', 'Peso'}));

    % Stampa rischio e rendimento dei portafogli
    disp('Rischio e rendimento del portafoglio a varianza minima:');
    disp(table({'Giornaliero'; 'Annualizzato'}, [riskMV; annualized_riskMV], [retMV / 252; retMV], 'VariableNames', {'Periodo', 'Rischio', 'Rendimento'}));
    disp('Rischio e rendimento del portafoglio HRP:');
    disp(table({'Giornaliero'; 'Annualizzato'}, [riskHRP; annualized_riskHRP], [retHRP / 252; retHRP], 'VariableNames', {'Periodo', 'Rischio', 'Rendimento'}));

    % Plotta i grafici a torta
    figure;
    tiledlayout(1, 2);
    % Portafoglio a varianza minima
    nexttile
    pie(wMV(wMV >= 1e-8), labels(wMV >= 1e-8))
    title('Min Variance Portfolio', 'Position', [0, 1.5]);
    % Portafoglio HRP
    nexttile
    pie(wHRP, labels)
    title('HRP Portfolio', 'Position', [0, 1.5]);
end

function pwgt = hrpPortfolio(T, Sigma)
    % Funzione che calcola un portafoglio di parità di rischio gerarchico (HRP)
    nAssets = size(Sigma, 1);
    nClusters = max(T);

    % Calcola il portafoglio di parità di rischio all'interno di ogni cluster
    W = zeros(nAssets, nClusters);
    for i = 1:nClusters
        % Identifica gli asset nel cluster i e la sotto-matrice di covarianza
        idx = T == i;
        tempSigma = Sigma(idx, idx);
        % Calcola il portafoglio di parità di rischio del cluster i
        W(idx, i) = riskBudgetingPortfolio(tempSigma);
    end

    % Calcola la covarianza tra i portafogli di parità di rischio di ogni cluster
    covCluster = W' * Sigma * W;

    % Calcola i pesi di ogni cluster
    wBetween = riskBudgetingPortfolio(covCluster);

    % Moltiplica il peso assegnato a ogni cluster con il suo portafoglio e
    % assegna agli asset corrispondenti
    pwgt = W * wBetween;
end

function idxInGroup = getLeafNodesInGroup(nodeId, link)
    % Trova tutti i nodi foglia per un dato id nodo in una matrice di linkage
    nLeaves = size(link, 1) + 1;
    if nodeId > nLeaves
        tempNodeIds = link(nodeId - nLeaves, 1:2);
        idxInGroup = [getLeafNodesInGroup(tempNodeIds(1), link), ...
                      getLeafNodesInGroup(tempNodeIds(2), link)];
    else
        idxInGroup = nodeId;
    end
end


%%
%Un portafoglio di parità di rischio (Risk Parity Portfolio) è una strategia di allocazione degli investimenti che mira a distribuire il rischio in modo uniforme tra gli asset del portafoglio. In altre parole, invece di allocare il capitale in base ai rendimenti attesi o ad altri criteri, la parità di rischio si concentra sull'allocazione del rischio, cercando di garantire che ogni asset contribuisca in modo uguale al rischio complessivo del portafoglio.

%Ecco come funziona in pratica:

%Calcolo della matrice di covarianza: Si calcola la matrice di covarianza degli asset nel portafoglio, che misura come i rendimenti degli asset si muovono insieme.

%Clusterizzazione gerarchica: Si utilizza un algoritmo di clusterizzazione gerarchica per raggruppare gli asset in base alla loro somiglianza o distanza. Questo crea una struttura ad albero gerarchica che mostra come gli asset sono correlati tra loro.

%Allocazione del rischio all'interno dei cluster: All'interno di ciascun cluster, si calcola un portafoglio di parità di rischio utilizzando la matrice di covarianza ridotta che include solo le informazioni sugli asset all'interno del cluster. Questo garantisce che il rischio sia distribuito uniformemente tra gli asset del cluster.

%Allocazione del rischio tra i cluster: Si calcola la covarianza tra i portafogli di parità di rischio di ciascun cluster e si utilizza una strategia di allocazione del rischio per assegnare i pesi a ciascun cluster. Questo garantisce che il rischio sia distribuito uniformemente tra i cluster.

%Combinazione dei pesi: I pesi assegnati a ciascun cluster vengono moltiplicati per i pesi degli asset all'interno del cluster per ottenere l'allocazione finale degli asset nel portafoglio.

%Il risultato è un portafoglio diversificato in cui il rischio è distribuito in modo uniforme tra gli asset, riducendo la dipendenza da singoli asset o cluster di asset
