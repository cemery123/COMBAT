modelsPath = 'E:\slemi\slemi-master\emi_results';
fileFolder=fullfile(modelsPath);
dirOutput=dir(fullfile(fileFolder,'**/*difftest.slx'));
fileNames={dirOutput.name};
res3 = load('tj.mat');
model1 = res3.model1;
for i = 1:numel(fileNames)
    res1 = load("tj_blk.mat");
    res2 = load('tj_num.mat');
    %numel(fileNames)
    num = res2.num;
    classin = res1.classin;
    %
    disp('start')
    %% 开始编译执行
    model =  fileNames{i};
    fprintf('start to compile %s',fileNames{i});
    %% 标注信号
    load_system(model);
    sys_pr = strsplit(model,'.');
    sys = sys_pr{1};
    BlockPaths = find_system(sys,'Type','Block');
    BlockTypes = get_param(BlockPaths,'BlockType');
    %得到连线信息
    L = find_system(sys,'FindAll','on','type','line');
    metric_engine = slmetric.Engine();
    setAnalysisRoot(metric_engine,'Root',sys,'RootType','Model');
    execute(metric_engine, {'mathworks.metrics.SimulinkBlockCount',...
        'mathworks.metrics.SubSystemCount','mathworks.metrics.ExplicitIOCount', ...
        'mathworks.metrics.CyclomaticComplexity'});
    res_col = getMetrics(metric_engine,{'mathworks.metrics.SimulinkBlockCount',...
        'mathworks.metrics.SubSystemCount','mathworks.metrics.ExplicitIOCount', ...
        'mathworks.metrics.CyclomaticComplexity'});
    %metricData ={'MetricID','ComponentPath','Value'};
    cnt = ones(1,4);
    for n=1:length(res_col)
        if res_col(n).Status == 0
            results = res_col(n).Results;

            w = length(results);
            cntw = ones(1,w);
            for m=1:length(results)
                %disp(['MetricID: ',results(m).MetricID]);
                %disp(['  ComponentPath: ',results(m).ComponentPath]);
                %disp(['  Value: ',num2str(results(m).Value)]);
                %metricData{cnt+1,1} = results(m).MetricID;
                %metricData{cnt+1,2} = results(m).ComponentPath;
                %metricData{cnt+1,3} = results(m).Value;
                cntw(m) = results(m).Value;
                cnt(n) = max(cntw);
            end
        else
            fprintf('No results for');
        end
    end

    %%  修改一下depth
    depth = cnt(2);
    line_value = numel(L);
    CyclomaticComplexity = cnt(4);
    block_num = numel(BlockTypes);
    if depth >num{3,2}
        num{3,2} = depth;
    end
    num{1,2} = block_num+num{1,2};
    num{2,2} = line_value+num{2,2};
    save('tj_num.mat','num');
    fprintf('save success');
    continues = 0;
    Dashboard = 0;
    Discontinuities = 0;
    Discrete = 0;
    Math_Operations = 0;
    other = 0;
    %% 比率统计
    for j = 1:numel(BlockTypes)
        idx = find(strcmp(model1, BlockTypes{j} ));
        if ~isempty(idx)
            %102行，换算为二维坐标
            id =idx-102;
            Library = model1{id,1};
            if strcmp(Library,'continues')
                continues=continues+1;
            elseif strcmp(Library,'Dashboard')
                Dashboard =Dashboard+1;
            elseif strcmp(Library,'Discontinuities')
                Discontinuities =Discontinuities+1;
            elseif strcmp(Library,'Discrete')
                Discrete =Discrete+1;
            elseif strcmp(Library,'Math Operations')
                Math_Operations =Math_Operations+1;
            end
        else
            other = other+1;
        end
    end
    bl1 = continues/numel(BlockTypes);
    bl2 = Dashboard/numel(BlockTypes);
    bl3 = Discontinuities/numel(BlockTypes);
    bl4 = Discrete/numel(BlockTypes);
    bl5 = Math_Operations/numel(BlockTypes);
    bl6 = other/numel(BlockTypes);
    %% write in file
    if i>1
    classin{1,2} =(bl1+classin{1,2})/2;
    classin{2,2} =(bl2+classin{2,2})/2;
    classin{3,2} =(bl3+classin{3,2})/2;
    classin{4,2} =(bl4+classin{4,2})/2;
    classin{5,2} =(bl5+classin{5,2})/2;
    classin{6,2} =(bl6+classin{6,2})/2;
    else
        classin{1,2} =(bl1+classin{1,2})/i;
    classin{2,2} =(bl2+classin{2,2})/i;
    classin{3,2} =(bl3+classin{3,2})/i;
    classin{4,2} =(bl4+classin{4,2})/i;
    classin{5,2} =(bl5+classin{5,2})/i;
    classin{6,2} =(bl6+classin{6,2})/i;
    end
    %% save file
    save('tj_blk.mat','classin')
    close_system(sys)
    fprintf('close system success')
end