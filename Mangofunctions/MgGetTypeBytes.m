function byteCount = MgGetTypeBytes(type)
% byteCount = MgGetTypeBytes(type)
% Get the number of bytes for a given data type.
% type:
%       'uchar'     unsigned integer,  8 bits.
%       'schar'     signed integer,  8 bits.
%       'int8'      integer, 8 bits.
%       'int16'     integer, 16 bits.
%       'int32'     integer, 32 bits.
%       'int64'     integer, 64 bits.
%       'uint8'     unsigned integer, 8 bits.
%       'uint16'    unsigned integer, 16 bits.
%       'uint32'    unsigned integer, 32 bits.
%       'uint64'    unsigned integer, 64 bits.
%       'single'    floating point, 32 bits.
%       'float32'   floating point, 32 bits.
%       'double'    floating point, 64 bits.
%       'float64'   floating point, 64 bits.

switch type
    case 'uchar'
        byteCount = 1;
    case 'schar'
        byteCount = 1;
    case 'int8'
        byteCount = 1;
    case 'int16'
        byteCount = 2;
    case 'int32'
        byteCount = 4;
    case 'int64'
        byteCount = 8;
    case 'uint8'
        byteCount = 1;
    case 'uint16'
        byteCount = 2;
    case 'uint32'
        byteCount = 4;
    case 'uint64'
        byteCount = 8;
    case 'single'
        byteCount = 4;
    case 'float32'
        byteCount = 4;
    case 'double'
        byteCount = 8;
    case 'float64'
        byteCount = 8;   
    otherwise
        % parameter error
        disp("Invalid type argument");
end

end

