function rmse = getCompletionError(model)
	pv = fopen('partial_view_test.data','rb');
	cv = fopen('complete_view_test.data','rb');
    lb = fopen('labels_test.data','r');

	num_samples = 0;
    max_samples = 50;
	num_elements = 30*30*30;
	mse_array = [];
    ctime = [];
	while ~feof(pv)
		[input,count] = fread(pv,num_elements,'int8');
        if (count <= 0)
            break
        end
		input = reshape(input,30,30,30);
		target = fread(cv,num_elements,'int8');
		target = reshape(target,30,30,30);
        line = fgets(lb);
        [~,~,~,nextindex] = sscanf(line,'%d');
        cl = sscanf(line(nextindex:end),'%s');
        if (~exist('classname','var'))
            classname = cl;
        end
        if (strcmp(classname,cl))
            if (num_samples >= max_samples)
                continue
            end
        else 
            save(['results/' classname '_test_error.mat'],'mse_array');
            min_err = min(mse_array);
            err25 = prctile(mse_array,25);
            err50 = prctile(mse_array,50);
            err75 = prctile(mse_array,75);
            max_err = max(mse_array);
            fprintf('%s %.0f %.0f %.0f %.0f %.0f for %d samples\n',classname,min_err,err25,err50,err75,max_err,length(mse_array));
            mse_array = [];
            num_samples = 0;
            classname = cl;
        end
        

        sample_param = [];
        sample_param.epochs = 30;
        sample_param.nparticles = 1;
        sample_param.gibbs_iter = 1;
        sample_param.earlyStop = true;
        batch_data = repmat(permute(input,[4,1,2,3]),sample_param.nparticles,1); % running n chains altogether
        mask = batch_data < 0;
        tic;
        [completed_samples, ~] = rec_completion_test(model, batch_data, mask, 0, sample_param);
        ctime = [ctime toc];
        
        mask = input < 0;
        visible = input == 1;
        output = reshape(completed_samples(1,:,:,:),30,30,30) .* mask + visible;
		err = target - output;
        err = sum(sum(sum(err.*err))) / 2;
        %fprintf('%s %d %f\n',cl,num_samples,err);
        mse_array = [mse_array err];
        num_samples = num_samples + 1;
    end

    save(['results/' classname '_test_error.mat'],'mse_array');
    
    min_err = min(mse_array);
	err25 = prctile(mse_array,25);
	err50 = prctile(mse_array,50);
	err75 = prctile(mse_array,75);
    max_err = max(mse_array);
    fprintf('%s %.0f %.0f %.0f %.0f %.0f for %d samples\n',classname,min_err,err25,err50,err75,max_err,length(mse_array));
    fprintf('Completion time: %f avg (%d samples)\n',mean(ctime),length(ctime));

    % plot completion
%     figure;
%     subplot(1,3,1);
%     plotPointCloud(input);
%     subplot(1,3,2);
%     plotPointCloud(output>0.5);
%     subplot(1,3,3);
%     plotPointCloud(target);
end
