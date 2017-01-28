function result = isoctave()
% returns logical 1 if under OCTAVE enviorment. Otherwise, return 0

result = exist('OCTAVE_VERSION','builtin')~=0;

end