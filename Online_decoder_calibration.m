
%BrainAct is MUA obtained through online spike sorting (Through OpenEx,
%Tucker-Davis Technology)
load('BrainAct.mat') 
%BrainAct is 32 x t, where t is in centiseconds. Entries are spike per
%centisecond bin.

% visualize
figure
    imagesc(BrainAct)
    BrainActBase=BrainAct;
xticks(100:100:700)
xticklabels({'1' '2' '3' '4' '5' '6' '7' })
title('M1 spike raster')
ylabel('M1 channels')
xlabel('time (s)')
nCh=size(BrainAct,1);

%% decoder preparation

%BrainAct undergoes gaussian filtering
t_gauss=40; %gaussian window
windowWidth = int16(t_gauss); 
halfWidth = windowWidth / 2; 
gaussFilter = gausswin(t_gauss); %gaussian filter
gaussFilter = gaussFilter / sum(gaussFilter); % normalize
gaussFilterHalf=gaussFilter(1:floor(end/2))+gaussFilter(end:-1:floor(end/2)+1);
clear ND_smoothed
for i=1:nCh    %gaussian filter
        ND_smoothed(i,:)= conv(BrainAct(i,:), gaussFilterHalf(end:-1:1));        
end

%self-organizing map
net = selforgmap([4 1],100);    
net.trainParam.showWindow = false;
net.trainParam.showCommandLine = false; 
net = train(net,ND_smoothed);    
y = net(ND_smoothed);
y2=[1 2 3 4]*y;

% ordering SOM states per amount of neuronal firing. 
% Active state: more firing.
clear m
sumBrainAct=sum(ND_smoothed);  %cumulative firing        
m=(y*sumBrainAct')./sum(y,2); %mean firing per state
[~,b]=sort(m);
y2=b'*y;
labels=(y2'-1)/3;

% w_est are the estimated decoder weights
w_est=labels'*pinv(ND_smoothed);


%% visualization
%here we simulate an online test on the trained decoder.

% current control variable value
reg_var=w_est*ND_smoothed;

%decoding state machine, turning stimulation on and off
decoded=zeros(size(reg_var));
state=0;
for t_i=1:length(reg_var)
    if state==0 && reg_var(t_i)>.8 %stimulation on when passing .8
        state=1;
    elseif state==1 && reg_var(t_i)<.2 %stimulation off when dropping below .2
        state=0;
    end %the thresholds are further available for user tuning on the online TDT controller
    decoded(t_i)=state;
end

%visualization of filtered data, SOM training and decoder output
figure;
subplot(2,1,1)
imagesc([ND_smoothed])
title('smoothed cortical activity')
subplot(6,1,4)
imagesc([labels'])
title('Self-organizing-map state')
caxis([0,1.5])
subplot(6,1,6)
imagesc([reg_var;decoded])
title('decoder output (top: simulated state, bottom: simulated decoding)')
caxis([0,1.5])






