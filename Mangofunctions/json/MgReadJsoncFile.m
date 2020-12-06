function json = MgReadJsoncFile(filename)
% json = MgReadJsoncFile(filename)
% This function reads jsonc file.
% Comments and tail comma are allowed in json file.
% filename: json file name.
% json: json struct.

json = jsondecode(MgRemoveJsoncComments(fileread(filename)));

end