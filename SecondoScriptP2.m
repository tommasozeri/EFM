


    %% GRAFICI -------------------------------------------------
    
    % Calcola la frontiera efficiente
    p = Portfolio('AssetList', tickers, 'RiskFreeRate', 0.02 / 252); % Tasso risk-free giornaliero
    p = setAssetMoments(p, m, V);
    p = setDefaultConstraints(p);
    pwgt = estimateFrontier(p, 20);
    [prsk, pret] = estimatePortMoments(p, pwgt);

    % Calcola la linea tangente
    q = setBudget(p, 0, 1);
    qwgt = estimateFrontier(q, 20);
    [qrsk, qret] = estimatePortMoments(q, qwgt);

    % Grafico della frontiera efficiente (valori giornalieri)
    figure;
    plot(prsk, pret, 'b-', 'LineWidth', 2);
    hold on;
    plot(qrsk, qret, 'g--', 'LineWidth', 2); % Linea tangente
    scatter(portfolio_risk, portfolio_return, 'r', 'filled');
    text(portfolio_risk, portfolio_return, 'Portafoglio Ottimo', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    for i = 1:length(m)
        scatter(sqrt(V(i, i)), m(i), 'k', 'filled');
        text(sqrt(V(i, i)), m(i), tickers{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    xlabel('Rischio (Deviazione Standard)');
    ylabel('Rendimento Atteso');
    title('Frontiera Efficiente sul Piano Media-Varianza (Valori Giornalieri)');
    legend('Frontiera Efficiente', 'Linea Tangente', 'Portafoglio Ottimo', 'Location', 'Best');
    grid on;
    hold off;

    % Converti i rendimenti e i rischi in valori annualizzati
    annualized_prsk = prsk * sqrt(252);
    annualized_pret = (1 + pret) .^ 252 - 1;
    annualized_qrsk = qrsk * sqrt(252);
    annualized_qret = (1 + qret) .^ 252 - 1;

    % Grafico della frontiera efficiente (valori annualizzati)
    figure;
    plot(annualized_prsk, annualized_pret, 'b-', 'LineWidth', 2);
    hold on;
    plot(annualized_qrsk, annualized_qret, 'g--', 'LineWidth', 2); % Linea tangente
    scatter(annualized_risk, annualized_return, 'r', 'filled');
    text(annualized_risk, annualized_return, 'Portafoglio Ottimo', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    for i = 1:length(m)
        scatter(sqrt(V(i, i)) * sqrt(252), (1 + m(i)) ^ 252 - 1, 'k', 'filled');
        text(sqrt(V(i, i)) * sqrt(252), (1 + m(i)) ^ 252 - 1, tickers{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    xlabel('Rischio Annualizzato (Deviazione Standard)');
    ylabel('Rendimento Annualizzato Atteso');
    title('Frontiera Efficiente sul Piano Media-Varianza (Valori Annualizzati)');
    legend('Frontiera Efficiente', 'Linea Tangente', 'Portafoglio Ottimo', 'Location', 'Best');
    grid on;
    hold off;

%% SML

    % Calcola il portafoglio di mercato (su DB principale non su indice)
    market_weights = mean(R) / sum(mean(R)); % Pesi del portafoglio di mercato basati sui rendimenti medi
    market_return = sum(market_weights .* m) * 252; % Rendimento annualizzato del portafoglio di mercato
    market_beta = 1; % Beta del portafoglio di mercato è 1

    % Grafico della Security Market Line (SML)
    figure;
    risk_free_rate = 0.02; % Tasso risk-free annuale
    market_premium = market_return - risk_free_rate; % Premio per il rischio di mercato
    sml_x = [0, 1]; % Beta va da 0 a 1
    sml_y = [risk_free_rate, risk_free_rate + market_premium]; % SML
    plot(sml_x, sml_y, 'b-', 'LineWidth', 2);
    hold on;
    
    % Aggiungi il portafoglio di mercato
    scatter(market_beta, market_return, 'g', 'filled');
    text(market_beta, market_return, 'Portafoglio di Mercato', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    
    % Aggiungi il portafoglio ottimo
    scatter(portfolio_beta, annualized_return, 'r', 'filled');
    text(portfolio_beta, annualized_return, 'Portafoglio Ottimo', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    
    % Aggiungi tutti gli altri titoli
    for i = 1:length(beta_assets)
        scatter(beta_assets(i), m(i) * 252, 'k', 'filled');
        text(beta_assets(i), m(i) * 252, tickers{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    
    xlabel('Beta');
    ylabel('Rendimento Atteso');
    title('Security Market Line (SML)');
    legend('SML', 'Portafoglio di Mercato', 'Portafoglio Ottimo', 'Titoli', 'Location', 'Best');
    grid on;
    hold off;


end
