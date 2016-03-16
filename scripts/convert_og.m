
%classes = {'bathtub', 'bed', 'chair', 'desk', 'dresser', 'monitor', 'night_stand', 'sofa', 'table', 'toilet', ...
%           'airplane', 'bench', 'bookshelf', 'bottle', 'bowl', 'car', 'cone', 'cup', 'curtain', 'door', ...
%           'flower_pot', 'glass_box', 'guitar', 'keyboard', 'lamp', 'laptop', 'mantel', 'person', 'piano', 'plant', ...
%           'radio', 'range_hood', 'sink', 'stairs', 'stool', 'tent', 'tv_stand', 'vase', 'wardrobe', 'xbox'};
classes = {'cup'};
num_classes = length(classes);
for c = 1 : num_classes
	category_path = [ 'volumetric_data/' classes{c} '/30/test'];
	files = dir(category_path);
	j=1;
    for i = 1 : length(files)
		filename = files(i).name;
		l = length(filename);
		if (l>=5 && strcmp(filename(length(filename)-3:length(filename)),'.mat'))
		%	fprintf('%s\n',filename);
			data = load([category_path '/' filename]);
			sz = size(data.instance);
			fd = fopen([category_path '/' num2str(j) '.og'],'w');
			fprintf(fd,'%d %d %d\n',sz(1),sz(2),sz(3));
			for z = 1:sz(3)
				for y=1:sz(2)
					for x=1:sz(1)
						fprintf(fd,'%d ',data.instance(x,y,z));
					end
				end
			end
			fprintf(fd,'\n');
			fclose(fd);
			j+=1;
		end
	end
end

