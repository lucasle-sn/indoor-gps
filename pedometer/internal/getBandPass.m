%% Get band pass
% @return a vector of band pass filtered signal
function bandPassSignal = getBandPass(signal, lowerFreqFilterCoeff, upperFreqFilterCoeff)
    len = length(signal);

    lowerFreqLowPassSignal = ones(1,len);
    lowerFreqHighPassSignal = zeros(1,len);
    bandPassSignal = zeros(1,len);
    for i=1:len-1
        lowerFreqLowPassSignal(i+1) = (1-lowerFreqFilterCoeff)*lowerFreqLowPassSignal(i) + lowerFreqFilterCoeff*signal(i);
        lowerFreqHighPassSignal(i) = signal(i)-lowerFreqLowPassSignal(i);
        % Apply low pass filter with upper Freq on a high passed signal 
        bandPassSignal(i+1) = (1-upperFreqFilterCoeff)*bandPassSignal(i) + upperFreqFilterCoeff*lowerFreqHighPassSignal(i);
    end
end
