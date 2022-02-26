res1 = load('xinxi.mat');
res1 =res1.xinxi(1:1000,:);
x1 = res1(:,1);
res2 = load('slemi\slemi-master\xinxi.mat');
res2 = res2.xinxi(7001:8000,:);
x2 = res2(:,1);
tiledlayout(1,4);
ax1 = nexttile;
Data1 = {};
Data1(1:1000,1) = x1;
Data1(1001:2000,1) = x2;
Data1 = cell2mat(Data1);
name = {};
for i =1:1000
    name{i,1} = 1;
end
for i = 1001:2000
       name{i,1} = 2;
end
name = cell2mat(name);
chartData = table(Data1,name); 
% % g2 = repmat(1:2,2,1);
% % g2 = g2(:);
% c = hsv;
% g2(1,:) = c(171,:);
% g2(2,:) = c(22,:);
% % g2= colormap(g2);
pr_name = ["SLEMI","SLBug-Hunter"];
name1 = categorical(chartData.name,1:2,pr_name);
b = boxchart(ax1,name1,chartData.Data1,'GroupByColor',name1);
b(1).SeriesIndex = 107;
b(2).SeriesIndex = 1;
title('Blocks');

ax2 = nexttile;
x3 = (res1(:,2));
x4 = (res2(:,2));
Data2 = {};
Data2(1:1000,1) = x3;
Data2(1001:2000,1) = x4;
Data2 = cell2mat(Data2);
chartData1 = table(Data2,name); 
b = boxchart(ax2,name1,chartData1.Data2,'GroupByColor',name1);
b(1).SeriesIndex = 107;
b(2).SeriesIndex = 1;
title('Connections')

ax3  = nexttile;
x5 = (res1(:,3));
x6 = (res2(:,3));
Data3 = {};
Data3(1:1000,1) = x5;
Data3(1001:2000,1) = x6;
Data3 = cell2mat(Data3);
chartData2 = table(Data3,name); 
b = boxchart(ax3,name1,chartData2.Data3,'GroupByColor',name1);
b(1).SeriesIndex = 107;
b(2).SeriesIndex = 1;
title('Add Blocks');

ax4 = nexttile;
x7 = (res1(:,4));
x8 = (res2(:,4));
Data4 = {};
Data4(1:1000,1) = x7;
Data4(1001:2000,1) = x8;
Data4 = cell2mat(Data4);
chartData3 = table(Data4,name); 
b = boxchart(ax4,name1,chartData3.Data4,'GroupByColor',name1);
b(1).SeriesIndex = 107;
b(2).SeriesIndex = 1;
title('Add Connections');