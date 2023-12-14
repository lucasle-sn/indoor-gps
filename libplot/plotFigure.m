%% Figure
% Plot Figure with given title, x label & y label
function plotFigure(titleText, xlabelText, ylabelText)
    figure; hold on; grid on;
    title(titleText);
    xlabel(xlabelText);
    ylabel(ylabelText);
end
