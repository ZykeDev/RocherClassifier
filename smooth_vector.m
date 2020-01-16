function out = smooth_vector(v, n, c)
%SMOOTH_VECTOR Smoothes a vector given n adjacent values
    step = floor(n/2);
    
    for i = step : step : c - (step-1)
        s = [];
        for j = i-(step-1) : i+step
            s = [s; v(j)];
        end
        v(i) = mean(s);
    end

    v(1) = min(v(1 : step));
    v(c) = min(v(c - (step-1) : c));

    for i = 1 : step
        v(i) = v(1) + i*(v(step) - v(1)) / step;
    end

    for i = c-(step-1) : c
        v(i) = v(c) + i*(v(c-(step-1)) - v(c)) / step;
    end

    out = v;

end
