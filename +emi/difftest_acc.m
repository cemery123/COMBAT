function ret = difftest_acc(obj,sys)
%DIFFTEST_ACC 此处显示有关此函数的摘要
obj.l.info('start to comile and compare %s',sys)
%% 开始编译执行
%读取列表
loc = split(obj.r.mutant.loc,'\');
loc_path = [loc{1} '\' loc{2}]
try
    load([loc_path '\' 'acc_err.error.mat']);
catch
    obj.l.info('first mutant will creat a mat')
    error = {};
    save([loc_path '\' 'acc_err.error.mat'],'error');
end
% model = [modelsPath '\' fileNames{i}];
% sprintf('start to compile %s',fileNames{i})
%% 标注信号
err = load([loc_path '\' 'acc_err.error.mat']);
error = err.error;
load_system(obj.r.mutant.filepath());
model_name = sys;
emi.slsf.signal_logging_setup(sys);
save_system(sys,[],'OverwriteIfChangedOnDisk',true);
close_system(obj.r.mutant.filepath());
%% 编译运行
try
    simOut1 = sim(obj.r.mutant.filepath());
catch e
    disp(e);
    m = size(error,1);
    error{m+1,1} = obj.r.mutant.loc;
    ret = false;
end
try
    simOut2 = sim(obj.r.mutant.filepath(),'SimulationMode', 'Accelerator');
catch e
    disp(e);
    m = size(error,1);
    error{m+1,1} = obj.r.mutant.loc;
    ret = false;
end
for j = 1:simOut1.logsout.numElements
    simData = simOut1.logsout.getElement(j);
    portIndex = simData.PortIndex;
    blkName = simData.BlockPath.getBlock(1);
    datas = find(simOut2.logsout,'BlockPath',blkName,'PortIndex',portIndex);
    %% 比较程序
    % outputArg1 = inputArg1;
    % outputArg2 = inputArg2;
    % data_1 = f(blkName);
    % data_2 = next_refined(blkName);

    % Last Data
    data_1 = simData.Values;
    data_2 = datas{1}.Values;
    num_data_1 = numel(data_1.Data);
    num_data_2 = numel(data_2.Data);

    num_time_1 = numel(data_1.Time);
    num_time_2 = numel(data_2.Time);

    if (num_data_1 ~= num_data_2 || num_time_1 ~= num_time_2)
        obj.l.info('Time/data len mismatch');
        e =  MException('RandGen:SL:Compareerr.errorLen',...
            sprintf('Len mismatch %s: data1: %d; data2: %d; time1: %d; time2:%d',...
            blkName, num_data_1, num_data_2, num_time_1, num_time_2)) ;
        m = size(error,1);
        error{m+1,1} = obj.r.mutant.loc;
        error{m+1,2} = sprintf('Len mismatch %s: data1: %d; data2: %d; time1: %d; time2:%d',...
            blkName, num_data_1, num_data_2, num_time_1, num_time_2) ;

        %             obj.handle_comp_err(obj.r.comp_diffs, blkName,...
        %                 next_exec, [], [], e, next_exec_idx);
    else
        try
            d_1 = data_1.Data(numel(data_1.Data));
            d_2 = data_2.Data(numel(data_2.Data));
        catch e
            disp(e)
            rethrow(e);
        end

        t_1 = data_1.Time(numel(data_1.Time));
        t_2 = data_2.Time(numel(data_2.Time));

        if (isnan(d_1) && isnan(d_2)) || (d_1 == d_2)
            %                         fprintf('Data No Mismatch\n');
        else
            obj.l.info('Data Mismatch!');
            e = MException('RandGen:SL:Compareerr.errorData',...
                sprintf('Data mismatch %s: data1: %f; data2: %f; len1: %d; len2:%d',...
                blkName, d_1, d_2, num_data_1, num_data_2 )) ;
            m = size(error,1);
            error{m+1,1} = obj.r.mutant.loc;
            error{m+1,2} = sprintf('Data mismatch %s: data1: %f; data2: %f; len1: %d; len2:%d',...
                blkName, d_1, d_2, num_data_1, num_data_2 );

            %                 obj.handle_comp_err(obj.r.comp_diffs, blkName,...
            %                     next_exec, d_1, d_2, e, next_exec_idx);
        end


        if t_1 == t_2
            %                         fprintf('Time No Mismatch\n');
        else
            obj.l.info('Time Mismatch!');
            e = MException('RandGen:SL:Compareerr.errorTime',...
                sprintf('Time mismatch %s: time1: %f; time2: %f; len1: %d; len2:%d',...
                blkName, t_1, t_2, num_time_1, num_time_2 )) ;

            m = size(error,1);
            error{m+1,1} = obj.r.mutant.loc;
            error{m+1,2} = sprintf('Time mismatch %s: time1: %f; time2: %f; len1: %d; len2:%d',...
                blkName, t_1, t_2, num_time_1, num_time_2 );

            %                 obj.handle_comp_err(obj.r.comp_diffs, blkName,...
            %                     next_exec, t_1, t_2, e, next_exec_idx);
        end
    end
end
% err.error{1,1} = 'sy';
obj.l.info('end compile %s',sys)
save([loc_path '\' 'acc_err.error.mat'],'error');
ret = true;
end

