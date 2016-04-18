function rmse = getCompletionError(model)
	pv = fopen('table_partial.data','rb');
	cv = fopen('table_complete.data','rb');

	num_samples = 0;
    test_samples = 1;
	num_elements = 30*30*30;
	rmse_array = zeros(1,test_samples);
	while ~feof(pv)
		num_samples = num_samples + 1;
		input = fread(pv,num_elements,'int8');
		input = reshape(input,30,30,30);
		target = fread(cv,num_elements,'int8');
		target = reshape(target,30,30,30);

        sample_param = [];
        sample_param.epochs = 30;
        sample_param.nparticles = 1;
        sample_param.gibbs_iter = 1;
        sample_param.earlyStop = true;
        batch_data = repmat(permute(input,[4,1,2,3]),sample_param.nparticles,1); % running n chains altogether
        mask = batch_data < 0;
        [completed_samples, ~] = rec_completion_test(model, batch_data, mask, 0, sample_param);

        output = reshape(completed_samples(1,:,:,:),30,30,30);
		err = target - output;
        err = sum(sum(sum(err.*err)));
        fprintf('Err %f\n',err);
		rmse_array(num_samples) = err;
        if (num_samples >= test_samples)
            break
        end
	end

	rmse = sqrt(sum(rmse_array) / num_samples);
    min_err = sqrt(min(rmse_array));
    max_err = sqrt(max(rmse_array));
	fprintf('Completion error is %f(RMSE) %f(min) %f(max) for %d samples\n',rmse,min_err,max_err,num_samples);
    
    % plot completion
    figure;
    subplot(1,3,1);
    plotPointCloud(input);
    subplot(1,3,2);
    plotPointCloud(output>0.5);
    subplot(1,3,3);
    plotPointCloud(target);
end
