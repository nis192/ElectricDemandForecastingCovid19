function y = mape(y1,y2)
    y = mean(abs(y1-y2)./y2);
end