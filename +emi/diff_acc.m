%function [outputArg1,outputArg2] = diff_acc(inputArg1,inputArg2)
%DIFF_ACC 此处显示有关此函数的摘要
%   此处显示详细说明
% modelsPath = getenv("COVEXPEXPLORE");
modelsPath = 'E:\slemi\slemi-master\reproduce\acc';
fileFolder=fullfile(modelsPath);
dirOutput=dir(fullfile(fileFolder,'*.slx'));
fileNames={dirOutput.name};
% 定义存储异常的元胞数组
error = {};
duration = 150;
for i = 1:numel(fileNames)
    %
    disp('start')
    %% 开始编译执行
    model = [modelsPath '\' fileNames{i}];
    fprintf('start to compile %s',fileNames{i});
    %% 标注信号
    load_system(model);
    model_name = strsplit(fileNames{i},'.');
    try
        emi.slsf.signal_logging_setup(model_name{1});
        save_system(model_name{1},[],'OverwriteIfChangedOnDisk',true);
    catch
        disp('An abnormal error')
        continue;
    end
    %%set timeOut {@utility.TimedSim.sim_timeout_callback}
    myTimer = timer('StartDelay', duration, 'TimerFcn',{@emi.diff_time,model_name{1}});
    start(myTimer);
    %             e = [];
    %             try
    %                 if compile_only
    %                     Sending the compile command results in error similar
    %                     to the bug we reported for slicing. So not reporting
    %                     it
    %                     obj.l.info('COMPILING ONLY %s...', obj.sys);
    %                     eval([obj.sys '([], [], [], ''compile'')']);
    %                     set_param(obj.sys,'SimulationCommand','Update');
    %                 else
    %                     obj.l.info('Simulating %s...', obj.sys);
    %                     obj.simOut = sim(obj.sys, obj.simargs);
    %                 end
    %% 编译运行
    try
        simOut1 = sim(model,'SimulationMode', 'Normal' ,'SimCompilerOptimization', 'on')
       % simOut1 = sim(model,'SimulationMode', 'Normal' ,'ZeroCrossAlgorithm', 'Adaptive');
%         simOut1 = sim(model,'SimulationMode', 'Normal','SimCompilerOptimization', 'on','SolverType', 'Fixed-step');
    catch e
        disp(e);
        m = size(error,1);
        error{m+1,1} = model;
        error{m+1,2} =  e.cause{1}.identifier
        error{m+1,3} = 'normal'
        continue;
    end
    stop(myTimer);
    delete(myTimer);
    myTimer = timer('StartDelay', duration, 'TimerFcn', {@emi.diff_time,model_name{1}});
    start(myTimer);
    try
         simOut2 = sim(model,'SimulationMode', 'Accelerator','SimCompilerOptimization', 'on');
        %simOut2 = sim(model,'SimulationMode', 'Accelerator','ZeroCrossAlgorithm', 'Adaptive');
%         simOut2 = sim(model,'SimulationMode', 'Accelerator','SimCompilerOptimization', 'on','SolverType', 'Fixed-step');
    catch e
        disp(e);
        m = size(error,1);
        error{m+1,1} = model;
        error{m+1,2} =  e.cause{1}.identifier
        error{m+1,3} = 'acc'
        continue;
    end
    stop(myTimer);
    delete(myTimer);
    close_system(model);
    try
        simOut1.logsout.numElements;
        simOut2.logsout;
    catch
        disp('An abnormal error');
        continue;
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
            warning('Time/data len mismatch');
            e =  MException('RandGen:SL:CompareErrorLen',...
                sprintf('Len mismatch %s: data1: %d; data2: %d; time1: %d; time2:%d',...
                blkName, num_data_1, num_data_2, num_time_1, num_time_2)) ;
            m = size(error,1);
            error{m+1,1} = model;
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
                warning('Data Mismatch!');
                e = MException('RandGen:SL:CompareErrorData',...
                    sprintf('Data mismatch %s: data1: %f; data2: %f; len1: %d; len2:%d',...
                    blkName, d_1, d_2, num_data_1, num_data_2 )) ;
                m = size(error,1);
                error{m+1,1} = model;
                error{m+1,2} = sprintf('Data mismatch %s: data1: %f; data2: %f; len1: %d; len2:%d',...
                    blkName, d_1, d_2, num_data_1, num_data_2 );

                %                 obj.handle_comp_err(obj.r.comp_diffs, blkName,...
                %                     next_exec, d_1, d_2, e, next_exec_idx);
            end


            if t_1 == t_2
                %                         fprintf('Time No Mismatch\n');
            else
                warning('Time Mismatch!');
                e = MException('RandGen:SL:CompareErrorTime',...
                    sprintf('Time mismatch %s: time1: %f; time2: %f; len1: %d; len2:%d',...
                    blkName, t_1, t_2, num_time_1, num_time_2 )) ;

                m = size(error,1);
                error{m+1,1} = model;
                error{m+1,2} = sprintf('Time mismatch %s: time1: %f; time2: %f; len1: %d; len2:%d',...
                    blkName, t_1, t_2, num_time_1, num_time_2 );

                %                 obj.handle_comp_err(obj.r.comp_diffs, blkName,...
                %                     next_exec, t_1, t_2, e, next_exec_idx);
            end
        end
    end
    %disp('end compile')
    fprintf('end complie %s',fileNames{i});
    save('acc.mat','error');
end
%end

