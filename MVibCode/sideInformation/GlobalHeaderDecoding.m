function [stream,origlength,dwtlevel] = GlobalHeaderDecoding(stream)
%decodes the header for the encoded signal; the returned stream is the
%full stream without the leading header

switch stream(1)
    case 1
        origlength = 32;
        dwtlevel = 3;
        stream = stream(2:end);
    case 0
        switch stream(2)
            case 1
                origlength = 64;
                dwtlevel = 4;
                stream = stream(3:end);
            case 0
                switch stream(3)
                    case 1
                        origlength = 128;
                        dwtlevel = 5;
                        stream = stream(4:end);
                    case 0
                        switch stream(4)
                            case 1
                                origlength = 256;
                                dwtlevel = 6;
                                stream = stream(5:end);
                            case 0
                            switch stream(5)
                                case 0
                                    origlength = 512;
                                    dwtlevel = 7;
                                    stream = stream(6:end);
                                case 1
                                    origlength = 1024;
                                    dwtlevel = 8;
                                    stream = stream(6:end);
                            end
                        
                        end
                end
        end
end

end
