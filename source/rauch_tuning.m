%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%               Band Pass Filter - Rauch Structure              
%
%
%              |----------C---------|
%              |                    |
%              |     |----R3--------|
%              |     |  _________   |      
%   IN----R1---|--C--|-|e-       |  |
%              |       |    AOP  |--|--OUT
%              R2  |---|e+       | 
%              |   |   |_________|
%              |___| 
%               GND
%
%
% Argument priority:
%   - Fc
%   - A0
%   - BW
%   
%   Choosing the AOP : the AOP picked to build this filter must have the
%   highest bandwidth and slew rate possible.
%   Because this tuning tool uses ideal amplifier model, implementation
%   with common AOP (BW few MHz) will have a lower Fc than the
%   theorical. Set a higher Fc in the input until you get satisfactory
%   result with your AOP.
%
% Written by Theophile Leurent.
% https://github.com/The00
% Last modification: 16/11/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
clear;
close all;

%% Input Parameters
A0 = 7;     % no unit - Resonance gain (not in dB).
Fc = 50E3;   % Hz - Frequency resonnance
BW = 7E3;    % Hz - Bandwidth at -3dB

% plot setting
% those value set the boundaries values of the displayed solutions .
plot_cmin = 50;     % pF
plot_cmax = 2700;   % pF

%% Passive components value
E24 = [10, 11, 12, 13, 15, 18, 20, 22, 24, 27, 30, 33, 36, 39, 47, 51, 56, 62, 68, 75, 82, 91];
E12 = [10, 12, 15, 18, 22, 27, 33, 47, 56, 68, 82];
C_MUL = [1,10,100];
R_MUL = [10, 100, 1000, 10000];

R_VAL = cartesian(E24,R_MUL); % unit: ohm 
C_VAL = sort(cartesian(E12,C_MUL)); % unit: pF


%% algorithm

x = size(C_VAL);
N = x(1,2);       % Number of solution

target_val = [2*pi*Fc, 2*pi*BW, A0];
best_val = zeros(N,7);      % Wc, BW, A0, R1, R2, R3, C 
current_val = zeros(0,7);   % Wc, BW, A0, R1, R2, R3, C


i=1;

for C = C_VAL
      
        R2 = target_val(1,2)/(2*C*1E-12*target_val(1,1)^2); % compute R2 exact value
        R2 = get_closest(R2, R_VAL); % get the closest value of R2 from a E-serie.
        
        new_BP  = 2*R2*C*1E-12*target_val(1,1)^2; % change the BW value to get closer of the desired Wc.
        
        R3 = 2/(C*1E-12*target_val(1,2)); % compute R3 exact value
        R3 = get_closest(R3, R_VAL); % get the closest value of R3 from a E-serie.
        
        R1 = R3/(2*target_val(1,3));% compute R1 exact value
        R1 = get_closest(R1, R_VAL); % get the closest value of R1 from a E-serie.
        
        % compute and store the parameters of this solution
        current_val = [sqrt((R1+R2)/(R1*R2*R3))/(C*1E-12*2*pi), 2/(R3*C*1E-12*2*pi), R3/(2*R1), R1, R2, R3, C];
        
        % store the solution for this C value.
        best_val(i,:) = current_val; 
       
        i = i+1;
        
end

%% Plot

min_bound = find(best_val(:,7)==get_closest(plot_cmin,transpose(best_val(:,7))));
max_bound = find(best_val(:,7)==get_closest(plot_cmax,transpose(best_val(:,7))));

intervalle = [min_bound:max_bound];
figure;

subplot(3,1,1);
plot(best_val(intervalle,7),best_val(intervalle,1), 'r-o','LineWidth',2); % Fc function of C.
hold on;
plot([plot_cmin,plot_cmax], [target_val(1,1)/(2*pi), target_val(1,1)/(2*pi)], 'b');
title('Fc');
legend('Fc versus C (pF)','Wc target');

subplot(3,1,2);
plot(best_val(intervalle,7),best_val(intervalle,3),'r-o','LineWidth',2); % A0 function of C.
hold on;
plot([plot_cmin,plot_cmax], [target_val(1,3), target_val(1,3)], 'b');
title('Gain');
legend('Gain versus C (pF)','Gain target');

subplot(3,1,3);
plot(best_val(intervalle,7),best_val(intervalle,2),'r-o','LineWidth',2); % BW function of C.
hold on;
plot([plot_cmin,plot_cmax], [target_val(1,2)/(2*pi), target_val(1,2)/(2*pi)], 'b');
title('bandwidth');
legend('BW(Hz) versus C (pF)','BW target');


%% Solution extraction

c_selected = input('Enter selected capacitor in pF:');
solution = find(best_val(:,7)==c_selected);
disp('Filter caracteristics:');
disp('Frequency resonnance Fc:');
disp(best_val(solution,1));
disp('Bandwidth BW:');
disp(best_val(solution,2));
disp('Gain at resonnance A0:');
disp(best_val(solution,3));
disp('Quality factor Q:');
disp(best_val(solution,1)/best_val(solution,2));

disp('Component Values:');
disp('R1:');
disp(best_val(solution,4));
disp('R2:');
disp(best_val(solution,5));
disp('R3:');
disp(best_val(solution,6));
disp('C(pF):');
disp(best_val(solution,7));


