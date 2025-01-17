function f = SecondaFunzObbP2(z)
    Dati = readtable('NAS30BM.xlsx', 'ReadRowNames', true);
    Dati = table2array(Dati);
    Dati = cellfun(@str2double, Dati);

    n = size(Dati, 1);
    R = log(Dati(2:n, :) ./ Dati(1:n-1, :));
    m = mean(R);
    V = cov(R);
    f = -m * z + z' * (V * z);
end
