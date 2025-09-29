function [stream,segmentlength] = HeaderDecoding(stream,bl,settings)
%decodes the header for the encoded signal; the returned stream is the
%full stream without the leading header

%bits = 15;
bits = log2(bl)+5; %adaptive max bitstream length depending on bl
%bits = settings.bits_streamLength;
segmentlength = bi2de(stream(1:bits));
stream = stream(bits+1:end);

end
