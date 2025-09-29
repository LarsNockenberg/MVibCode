function max_d = max_Descendant2(m)

bl = length(m);
dwtlevel = log2(bl/4);
book = bl./(2.^([dwtlevel,dwtlevel:-1:1]))';
book_sum = zeros(size(book));
for k=1:length(book)
    book_sum(k) = sum(book(1:k));
end

m = abs(m);
max_d = m;
max_d_1 = m;

for k=1:length(book)-2
    index = length(book)-k;
    temp = max_d(book_sum(index)+1:book_sum(index+1));
    temp = reshape(temp,[2,book(index)]);

    temp = max(temp,[],1);
    %temp2 = max([temp;max_d(book_sum(index-1)+1:book_sum(index))],[],1);
    temp2 = m(book_sum(index)+1:book_sum(index+1));
    temp2 = reshape(temp2,[2,book(index)]);
    temp2 = max([temp;temp2],[],1);
    max_d_1(book_sum(index-1)+1:book_sum(index)) = temp;
    max_d(book_sum(index-1)+1:book_sum(index)) = temp2;
end

max_d_1(4) = max(max_d(7:8));
max_d_1(3) = max(max_d(5:6));
max_d(4) = max([max_d(7:8),m(7:8)]);
max_d(3) = max([max_d(5:6),m(5:6)]);
max_d_1(2) = max(max_d(3:4));
max_d_1(1) = 0;
max_d(2) = max([max_d(3:4),m(3:4)]);
max_d(1) = 0;



max_d = [max_d;max_d_1];

end