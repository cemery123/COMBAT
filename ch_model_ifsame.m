function final_data = ch_model_ifsame(model,model_pp)
    model_len = length(model);
    pp_len = length(model_pp);
    
    res = 0; %最终比较值大小
    
    model_diff_index = [];%存储差异索引
    pp_diff_index = [];
    final_data = struct;    %存储所有比较结果
    load_system(model)  
    load_system(model_pp)
    %模型模块路径和类型以及模块个数
    model_sys = split(model,'.');
    model_sys = model_sys{1};
    model_pp_sys = split(model_pp,'.');
    model_pp_sys = model_pp_sys{1};
    BlockPaths = find_system(model_sys,'LookUnderMasks','on','FollowLinks','on','Type','Block');
    BlockTypes = get_param(BlockPaths,'BlockType');
    model_size = numel(BlockPaths);
    
    %变体模型模块路径和类型以及模块个数
    pp_BlockPaths = find_system(model_pp_sys,'LookUnderMasks','on','FollowLinks','on','Type','Block');
    pp_BlockTypes = get_param(pp_BlockPaths,'BlockType');
    pp_size = numel(pp_BlockPaths);
    
    model_diff_data = struct;   %保存原模型数据(model_data,model_diff_index)
    pp_diff_data = struct;  %保存变体数据（pp_data,pp_diff_index）
    model_data = cell(model_size,2);%m_type,m_path
    pp_data = cell(pp_size,2);%p_type,p_path
    pre_Blocks = cell(model_size,1);
    
    %保存元模型的胞体cell并预处理格式%{/cfblk10/DataTypeProp'
    %随后将变体的路径与cell中的匹配
    for i = 1:numel(BlockPaths)
        pre_Blocks{i} = BlockPaths{i}((model_len+1):end);
    end
    
    %
    if pp_size > model_size
        %变体大
        big_size = pp_size;
        sm_size = model_size;
    else
        big_size = model_size;
        sm_size = pp_size;
    end
    
    for i =1:sm_size
        %比较模型中的模块
        bpath = BlockPaths{i};%{'sampleModel2/cfblk10/DataTypeProp'}
        bpath = bpath(model_len+1:end);%{/cfblk10/DataTypeProp'
        pp_bpath = pp_BlockPaths{i};%{'sampleModel2/cfblk10/DataTypeProp'}
        pp_bpath = pp_bpath(pp_len+1:end);%{'/cfblk10/DataTypeProp'}

        %判断当前变体模块是否存在于原模型模块路径，若是判断是否类型相同（同一模块）
        if all(ismember(pp_bpath,pre_Blocks))
            %若包含，找出索引位置
            p_idex = find(strcmp(pre_Blocks,pp_bpath));  %在原模型的位置
            if ~ strcmp(pp_BlockTypes{i},BlockTypes{p_idex})   
                %若类型不同，则加一
                res = res+1;
                pp_data{i,1} = pp_BlockTypes{i};
                model_data{p_idex,1} = BlockTypes{p_idex};
                model_diff_index = [model_diff_index,p_idex];
                pp_diff_index = [pp_diff_index,i];
            end
        else
            %不包含，说明是新的模块
            res = res+2;
            pp_data{i,1} = pp_BlockTypes{i};
            pp_data{i,2} = pp_BlockPaths{i};
            pp_diff_index = [pp_diff_index,i];
        end

    end
    
    %其余未比较模块均加1
    if pp_size >= model_size 
        for s = (sm_size+1):big_size
            res = res+big_size-sm_size;
            pp_data{s,2} = pp_BlockPaths{s};
            pp_data{s,1} = pp_BlockTypes{s};
            pp_diff_index = [pp_diff_index,s];
        end
    else
        for s = (sm_size+1):big_size
            res = res+big_size-sm_size;
            model_data{s,2} = BlockPaths{s};
            model_data{s,1} = BlockTypes{s};
            model_diff_index = [model_diff_index,s];
        end
    end  
    %相对于原模型的变化
    res = (res/model_size);
    
    pp_diff_index = num2cell(pp_diff_index);
    model_diff_index = num2cell(model_diff_index);
    model_diff_data.model_data = model_data;   %保存原模型数据(model_data,model_diff_index)
    model_diff_data.model_diff_index = model_diff_index;
    pp_diff_data.pp_data = pp_data;
    pp_diff_data.pp_diff_index= pp_diff_index;  %保存变体数据（pp_data,pp_diff_index）
    

    final_data.res = res;
    final_data.model_diff_data = model_diff_data;
    final_data.pp_diff_data = pp_diff_data;
end