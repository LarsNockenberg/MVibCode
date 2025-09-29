function out = rescaleCounter(in)
    out = floor(in./in(2,:)*32);
    out(out==0) = 1;
end