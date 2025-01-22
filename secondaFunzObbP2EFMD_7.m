function f = secondaFunzObbP2EFMDQ7(z)
    % Carica i dati dal file Excel DBEXAM.xlsx, worksheet NYSEselectedD
    Dati = readtable('DBEXAM.xlsx', 'Sheet', 'NYSEselectedD', 'ReadRowNames', true, 'VariableNamingRule', 'preserve');

    % Converti la tabella in una matrice di numeri
    Dati = table2array(Dati);

    % Calcola i rendimenti logaritmici giornalieri
    n = size(Dati, 1);
    R = log(Dati(2:n, :) ./ Dati(1:n-1, :));
    m = mean(R);
    V = cov(R);

    % Calcola la funzione obiettivo
    f = -m * z + z' * (V * z);
end
