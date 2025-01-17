function [C, Ceq] = NonLinearConstraintsP3(z)
    Dati = readtable('NAS30BM.xlsx', 'ReadRowNames', true);
    Dati = table2array(Dati);
    Dati = cellfun(@str2double, Dati);

    n = size(Dati, 1);
    R = log(Dati(2:n, :) ./ Dati(1:n-1, :));
    V = cov(R);
    Vs = 6.0e-004;
    C = z' * V * z - Vs;
    Ceq = [];
end
