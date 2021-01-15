%BrainAct is MUA obtained through online spike sorting (Through OpenEx,
%Tucker-Davis Technology)
load('SampleRecording.mat') 
%BrainAct is 32 x t, where t is in centiseconds. Entries are spike per
%centisecond bin.

clear signal 

%common mode noise rejection
average_channels1=mean((wavb(1:16,:)));
average_channels2=mean((wavb(17:32,:)));
average_channels3=nanmean((wav2(1:16,:)));   
for ch_i=1:16
        signal(ch_i,:) = wavb(ch_i,:) - average_channels1;
end
for ch_i=17:32
        signal(ch_i,:) = wavb(ch_i,:) - average_channels2;
end
for ch_i=1:16
        signal(ch_i+32,:) = wav2(ch_i,:) - average_channels3;
end
signal=signal';

%Butterworth filter
n = 3; Wn = [700 3000]/(sampFreq/2);
ftype = 'bandpass';
[Bb,Ab] = butter(n,Wn,ftype);
clear signalf
for chan = 1:48
    signalf(:,chan) = filtfilt(Bb,Ab,double(signal(:,chan)));    
end

%z-score
msignal=mean(signalf);
ssignal=std(signalf);
signalf=(signalf-repmat(msignal,length(signalf),1))./repmat(ssignal,length(signalf),1);

%finding spike timings
keeptime = cell(size(signal,2));
tresh=-3; %any event that passes a threshold of 3 SD is considered a MUA spike
for chan = 1:48 
    for s_i = 1:length(signalf(:,chan))
        if signalf(s_i,chan) < tresh && signalf(s_i-1,chan) > tresh    
            keeptime{chan}=[keeptime{chan},(s_i/sampFreq)];
        end
    end
end     
 
%binning
granul=0.01;
ND=[];
for chI_i=1:48
    for t=(granul:granul:length(signalf)/sampFreq)
        ND(chI_i,round((t)*1/granul))=length(find(abs(keeptime{chI_i}-t)<granul/2));
    end
end

%sorting MLR by depth
order=[5 11 6 12 4 14 2 16 8 10 15 1 13 3  9 7];
ND(33:48,:)=ND(32+order(end:-1:1),:);

%display
figure
subplot(2,1,1)
imagesc(zscore(ND(1:32,:)')')
title('Spike raster')
ylabel('M1 channels')
subplot(5,1,3)
imagesc(zscore(ND(33:48,:)')')
ylabel('MLR channels')
xlabel('time (s)')
xticks(100:100:350)
xticklabels({'1' '2' '3'  })
subplot(4,1,4)


%cumulative firing
%causal gaussian filter 
halfWidth=20;
gaussFilter = gausswin(halfWidth*2-1);
gaussFilter = gaussFilter(1:halfWidth);
gaussFilter = gaussFilter / sum(gaussFilter); 
for ch_i=1:48
        for t_i=1:halfWidth %initialized
            NDf(ch_i,t_i)=...
                mean(ND(ch_i,1:t_i));
        end
        for t_i=halfWidth:length(ND) %causal filter
            NDf(ch_i,t_i)=...
                sum(gaussFilter'.*ND(ch_i,t_i-halfWidth+1:t_i));
        end 
end
tC=mean(NDf(1:32,:));  %tC is the cumulative cortical trace
tC=(tC-min(tC));
tC=tC/(max(tC));
tM=mean(NDf(33:48,:)); %tM is the cumulative MLR trace
tM=(tM-min(tM));
tM=tM/(max(tM));

%integrating timing of first foot-off
FS=floor((firststep-synchdelay)/granul);
tW=zeros(size(tC));
tW(FS:end)=1;

plot(tW)
hold on
plot(tC)
plot(tM)
title('Activations')
xlabel('time (s)')
ylabel('Normalized activation')
xticks(100:100:350)
xticklabels({'1' '2' '3'  })
legend('First foot off','M1','MLR')


