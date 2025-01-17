function f = PrimaFunzObbP1(x)
    % Carica i dati dal file Excel
    A = readtable('NAS30BM.xlsx', 'ReadRowNames', true);

    % Converti la tabella in una matrice di numeri
    A = table2array(A);
    A = cellfun(@str2double, A);

    % Calcola i rendimenti
    n = size(A, 1);
    R = log(A(2:n, :) ./ A(1:n-1, :));

    % Calcola la matrice di covarianza
    V = cov(R);

    % Calcola la funzione obiettivo
    f = x' * V * x;
end
