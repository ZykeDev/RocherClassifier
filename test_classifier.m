function out = test_classifier(dex, labels, cvp)
% Testa un classificatore dati descrittori, etichette e partizionamento.
    % Parametri: 
    %   descriptor : descrittore/i da usare per la classificazione
    %   labels : etichette delle immagini
    %   cv : output di cvpartition con le partizioni train set / test set

    train_values = dex(cvp.training(1), :);
    train_labels = labels(cvp.training(1));

    test_values  = dex(cvp.test(1), :);
    test_labels  = labels(cvp.test(1));

    % Uses KNN with k = 7
    c = fitcknn(train_values, train_labels, "NumNeighbors", 7);

    train_predicted = predict(c, train_values);
    out.train_perf = confmat(train_labels, train_predicted);

    test_predicted = predict(c, test_values);
    out.test_perf = confmat(test_labels, test_predicted);

end