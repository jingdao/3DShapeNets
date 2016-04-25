
%classes = {'table'};
classes = {'bathtub','bed','chair','desk','dresser','monitor','night_stand','sofa','table','toilet'};
num_classes = length(classes);
volume_size = 24;
pad_size = 3;
data_size = 30;

angle_inc=360/12;
obj_center = [0,0,-2]'; % object coordinate in camera system
camera_center = [0,0,0]'; camera_direction = [0,0,1]';
axis = cross(camera_direction, obj_center - camera_center);
if all(axis == 0)
   axis = cross(camera_direction, [1,0,0]'); 
end
angle = atan2(norm(cross(camera_direction, obj_center - camera_center)),dot(camera_direction, obj_center - camera_center));
axis_angle = axis / norm(axis) * (-angle);
R_o = AngleAxis2RotationMatrix(axis_angle); trans_o = [0,0,0]';

pv = fopen('partial_view_test.data','wb');
cv = fopen('complete_view_test.data','wb');
lb = fopen('labels_test.data','w');

for c = 1 : num_classes
	category_path = [ 'ModelNet10/' classes{c} '/test'];
	files = dir(category_path);
	j=1;
    for i = 1 : length(files)
		filename = files(i).name;
		l = length(filename);
		if (l>=5 && strcmp(filename(length(filename)-3:length(filename)),'.off'))
			for viewpoint = 1 : 360/angle_inc
				fprintf(lb,'%d %s\n',c,classes{c});
				off_data = off_loader([category_path '/' filename],-(viewpoint-1)*angle_inc);
				instance = polygon2voxel(off_data,[volume_size,volume_size,volume_size],'auto');
				instance_data = zeros(data_size,data_size,data_size);
				i1 = 1 + pad_size;
				i2 = pad_size + volume_size;
				instance_data(i1:i2,i1:i2,i1:i2) = instance;
				fwrite(cv,instance_data,'int8');

				[depth_new, K, crop] = off2im([category_path '/' filename], 1, (viewpoint - 1) * angle_inc * pi / 180, R_o, obj_center(1), obj_center(2), obj_center(3), [1;1;1], 0, 0);
				depth{1} = depth_new; R{1} = R_o; trans{1} = trans_o; mult = 5;
				gridDists = TSDF(depth, K, obj_center, R, trans, volume_size * mult, pad_size * mult, [], crop);
				gridDists = cubicle2col(gridDists, mult);
				surface_num = sum((gridDists < 1 & gridDists > -1),1);
				out_num = sum((gridDists == 1),1);
				in_num = sum((gridDists == -1),1);
				sur_index = (surface_num > 0 & in_num > 0 & out_num > 0) | surface_num > mult^2;
				out_index = (out_num >= in_num) & ~sur_index;
				gridDists = ones([data_size, data_size, data_size]);
				gridDists = -1 * gridDists;
				gridDists(sur_index) = 1;
				gridDists(out_index) = 0;
				gridDists = permute(gridDists, [3,1,2]);
				fwrite(pv,gridDists,'int8');
			end
			fprintf('Processed %s\n',filename);
		end
	end
end

fclose(pv);
fclose(cv);
fclose(lb);

