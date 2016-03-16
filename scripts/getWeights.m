function [] = getWeights()
	g10 = load('generative_10_class.mat');
	fid = fopen('generative_10_class.txt','w');
	saveModel(g10.model,true,fid)
	fclose(fid);
	g40 = load('generative_40_class.mat');
	fid = fopen('generative_40_class.txt','w');
	saveModel(g40.model,true,fid)
	fclose(fid);
	d10 = load('discriminative_10_class.mat');
	fid = fopen('discriminative_10_class.txt','w');
	saveModel(d10.model,false,fid)
	fclose(fid);
	d40 = load('discriminative_40_class.mat');
	fid = fopen('discriminative_40_class.txt','w');
	saveModel(d40.model,false,fid)
	fclose(fid);
end

function [] = saveModel(model,isGenerative,fid)
	fprintf(fid,'numLayer: %d\n',model.numLayer);
	fprintf(fid,'classes: %d\n',model.classes);
	fprintf(fid,'validation: %d\n',model.validation);
	fprintf(fid,'duplicate: %d\n',model.duplicate);
	fprintf(fid,'volume_size: %d\n',model.volume_size);
	fprintf(fid,'pad_size: %d\n',model.pad_size);
	for i=1:model.numLayer
		fprintf(fid,'layer{%d}\n',i);
		saveLayer(model.layers{i},isGenerative,fid);
	end
end

function [] = saveLayer(layer,isGenerative,fid)
	fprintf(fid,'type: %s\n',layer.type);
	fprintf(fid,'layerSize: ');
	for i=1:length(layer.layerSize)
		fprintf(fid,'%d ',layer.layerSize(i));
	end
	fprintf(fid,'\n');
	if (!strcmp(layer.type,'input'))
		fprintf(fid,'actFun: %s\n',layer.actFun);
		if (strcmp(layer.type,'convolution'))
			fprintf(fid,'stride: %d\n',layer.stride);
			fprintf(fid,'kernelSize: ');
			for i=1:length(layer.kernelSize)
				fprintf(fid,'%d ',layer.kernelSize(i));
			end
			fprintf(fid,'\n');
		end
		fprintf(fid,'w\n');
		saveWeights(layer.w,fid);
		fprintf(fid,'c\n');
		saveWeights(layer.c,fid);
		if (isGenerative)
			fprintf(fid,'b\n');
			saveWeights(layer.b,fid);
		end
	end
end

function [] = saveWeights(matrix,fid)
	sz = size(matrix);
	for i=1:length(sz)
		fprintf(fid,'%d ',sz(i));
	end
	fprintf(fid,'\n');
	fwrite(fid,matrix,'float32');
end

