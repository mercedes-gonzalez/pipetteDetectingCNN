%% Fix incorrectly annotated training data
clc;
info_table = struct2table(info);
file_names = info_table.filepath;
xyz = info_table.xyz;
%% Find indices of first of the bad images 
base_path = 'C:\Users\myip7\Dropbox (GaTech)\Shared folders\Pipette and cell finding\2019-2020 NET\Training and Validation Data\10-Mar-2020-data\b-';
image_names = [3654271797 3654271879 3654271947 3654271997 3654272055 3654272143];
found = zeros(length(file_names),1);
for i = 1:length(file_names)
    found(i) = (contains(file_names(i),num2str(image_names(1))) ||...
                contains(file_names(i),num2str(image_names(2))) ||...
                contains(file_names(i),num2str(image_names(3))) ||...
                contains(file_names(i),num2str(image_names(4))) ||...
                contains(file_names(i),num2str(image_names(5))) ||...
                contains(file_names(i),num2str(image_names(6))) );
end
%% get beginning indices into an array

counter = 1;
bad_idx = zeros(length(image_names),1);
for i = 1:length(found)
    if found(i)
        bad_idx(counter) = i;
        counter = counter + 1; 
    end
end
bad_idx
