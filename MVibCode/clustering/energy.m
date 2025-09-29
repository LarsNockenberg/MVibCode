function [E] = energy(sig,book)

E = zeros(1,length(book));

m = 0;
for b = 1:length(book)
    E(b) = sum(abs(sig(m+1:m+book(b))).^2);
    m = m+book(b);
end

end