% MAIN
% Version 30-Nov-2019
% Help on http://liecn.github.com
clear;
% clc;
close all;
%% Set Parameters for Transceivers
wave_length = 299792458 / 5.825e9;
sample_rate=1000;
n_receivers = 2;    % Receiver count
n_antennas = 3;    % Antenna count for each receiver
n_subcarriers=30;

%% Set Parameters for Data Description
total_user=12;
total_gait = 1;
total_track = 6;
total_instance = 4;

lineA=["-",":","--",'-.'];
lineB=["r","b","m","g"];
lineC=["*","s","o","^","+","s"];
lineS=["-.r","--m",":b"];
%% Set Parameters for Loading Data
data_root = './';

fig=figure;
set(fig,'DefaultAxesFontSize',18);
set(fig,'DefaultAxesFontWeight','bold');
%tailor the pdf
set(fig,'PaperSize',[7 4]);

error_dir = [data_root,'20191124_preliminaryssd_widir.mat'];
error_path = string(join(error_dir,''));
load(error_path);

up=[];
down=[];
sta_1=[];
sta_2=[];
for ii=1:3
    for jj=1:4
        if mod(jj,2)==1
            up=[up error_matrix{ii,jj}'];
        else
            down=[down error_matrix{ii,jj}'];
        end
    end
end

for ii=[4,6,8]
    for jj=1:4
          if mod(jj,2)==1
            sta_1=[sta_1 error_matrix{ii,jj}'];
        else
            sta_2=[sta_2 error_matrix{ii,jj}'];
        end
    end
end



bar_sign=zeros(4,3);
y=(up(:));
for ii=1:3
    bar_sign(1,ii)=numel(find(y==ii));
end

b=(down(:));
for ii=1:3
    bar_sign(2,ii)=numel(find(b==ii));
end

a=(sta_1(:));
for ii=1:3
    bar_sign(3,ii)=numel(find(a==ii));
end

d=(sta_2(:));
for ii=1:3
    bar_sign(4,ii)=numel(find(d==ii));
end

b = bar(bar_sign,'FaceColor','flat');
for k = 1:size(y,2)
    b(k).CData = lineB(k);
end

legend(['Toward (-1)'],['Static (0)'],['Away  (+1)'])
xlabel('Sign distribution of delay'); % x label
xticklabels({'Path 1','Path 2','Path 3','Path 4'})
ylabel('Sampling Points'); % y label
xlim([0 5])
title('')
%adjust the ratio
set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
saveas(gcf,"./cdf_ssd_widir.pdf")