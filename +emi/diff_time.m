function diff_time(~,~,sys)
%DIFF_TIME Summary of this function goes here
%   Detailed explanation goes here
set_param(sys, 'SimulationCommand', 'stop');
disp('Time out');
end

