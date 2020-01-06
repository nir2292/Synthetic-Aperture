files = dir('banana\*.jpg');

for i=1:length(files)
%     % Get the file name (minus the extension)
%     [~, f] = fileparts(files(id).name);
%     % Convert to number
%     num = str2double(f);
%     if ~isnan(num)
%         % If numeric, rename
%         movefile(files(id).name, sprintf('%03d.pdf', num));
%     end
    Filename = files(i).name;
    movefile(sprintf('banana\\%s', Filename), sprintf('banana\\%s', Filename(15:end)) );
end