function f = PrimaFunzObbP1_con_costi(x, V, z0)
    % Definisci i costi di transazione come una percentuale del valore delle transazioni
    transaction_cost_rate = 0.001; % 0.1%
    transaction_costs = transaction_cost_rate * sum(abs(x - z0));

    % Calcola la funzione obiettivo con i costi di transazione
    f = x' * V * x + transaction_costs;
end
