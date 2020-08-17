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
% lineB=[left_color,"b","m","g"];
lineC=["*","s","o","^","+","s"];
lineS=["-.r","--m",":b"];
%% Set Parameters for Loading Data
data_root = './';

fig=figure;
set(fig,'DefaultAxesFontSize',18);
set(fig,'DefaultAxesFontWeight','bold');
%tailor the pdf
left_color = [0.929 0.262 0.564];
right_color = [0.439, 0.188, 0.627];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

set(fig,'PaperSize',[7.5 3.8]);

%% data_1
% x=[1,2,3,4];
% psnr=[14.64,12.39,10.728,10.259];
% ocr_acc=[100,98,95,94];
% 
% yyaxis left
% b=bar(x,psnr,'FaceColor',left_color);
% % b.CData=lineB(1);
% ylabel('PSNR(db)'); % y label
% ylim([0 25])
% 
% yyaxis right
% h=plot(x,ocr_acc);
% h.LineStyle=lineA(2);
% h.Color=right_color;
% h.Marker=lineC(2);
% h.LineWidth=2;
% ylabel('OCR Accuracy(%)'); % y label
% ylim([85 100])
% 
% % legend(['Toward (-1)'],['Static (0)'])
% xlabel('Day/Night & Distance(m)'); % x label
% xticklabels({'D, 1.4','D, 1.8','N, 1.4','N, 1.8'})
% % xlim([0 5])
% title('')
% %adjust the ratio
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"../pic/data_1.pdf")

%% data_1_2
% x=[5,5.5,6,6.5,7,7.5];
% psnr=[14.64,12.39,10.728,10.259];
% ocr_acc_day=[100,100,94,91,62,21];
% ocr_acc_night=[100,97,93,82,43,12];
% 
% h=plot(x,ocr_acc_day);
% h.LineStyle=lineA(1);
% h.Color=left_color;
% h.Marker=lineC(1);
% h.LineWidth=2;
% 
% hold on
% h=plot(x,ocr_acc_night);
% h.LineStyle=lineA(2);
% h.Color=right_color;
% h.Marker=lineC(2);
% h.LineWidth=2;
% 
% ylabel('OCR Accuracy(%)'); % y label
% % ylim([85 100])
% 
% legend(['Day Time'],['Night Time'])
% xlabel('Distance(m)'); % x label
% % xticklabels({'D, 1.4','D, 1.8','N, 1.4','N, 1.8'})
% % xlim([0 5])
% title('')
% %adjust the ratio
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"../pic/data_1_2.pdf")

%% data_2
% x=[1,2,3,4];
% psnr=[13.32,11.17,9.744,9.558];
% ocr_acc=[100,97,92,85];
% 
% yyaxis left
% b=bar(x,psnr,'FaceColor',left_color);
% % b.CData=lineB(1);
% ylabel('PSNR(db)'); % y label
% ylim([0 25])
% 
% yyaxis right
% h=plot(x,ocr_acc);
% h.LineStyle=lineA(2);
% h.Color=right_color;
% h.Marker=lineC(2);
% h.LineWidth=2;
% ylabel('OCR Accuracy(%)'); % y label
% ylim([75 100])
% 
% % legend(['Toward (-1)'],['Static (0)'])
% xlabel('Day/Night & Distance(m)'); % x label
% xticklabels({'D, 1.4','D, 1.8','N, 1.4','N, 1.8'})
% % xlim([0 5])
% title('')
% %adjust the ratio
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"../pic/data_2.pdf")

%% data_2_2
% x=[5,5.5,6,6.5,7,7.5];
% psnr=[14.64,12.39,10.728,10.259];
% ocr_acc_day=[100,93,89,71,33,5];
% ocr_acc_night=[100,88,87,60,41,5];
% 
% h=plot(x,ocr_acc_day);
% h.LineStyle=lineA(1);
% h.Color=left_color;
% h.Marker=lineC(1);
% h.LineWidth=2;
% 
% hold on
% h=plot(x,ocr_acc_night);
% h.LineStyle=lineA(2);
% h.Color=right_color;
% h.Marker=lineC(2);
% h.LineWidth=2;
% 
% ylabel('OCR Accuracy(%)'); % y label
% % ylim([85 100])
% 
% legend(['Day Time'],['Night Time'])
% xlabel('Distance(m)'); % x label
% % xticklabels({'D, 1.4','D, 1.8','N, 1.4','N, 1.8'})
% % xlim([0 5])
% title('')
% %adjust the ratio
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"../pic/data_2_2.pdf")
% data_3
% x=[1,2,3,4];
% psnr=[13.32,9.15,9.94,8.85];
% ocr_acc=[100,73,80,52];
% 
% yyaxis left
% b=bar(x,psnr,'FaceColor',left_color);
% % b.CData=lineB(1);
% ylabel('PSNR(db)'); % y label
% ylim([0 25])
% 
% yyaxis right
% h=plot(x,ocr_acc);
% h.LineStyle=lineA(2);
% h.Color=right_color;
% h.Marker=lineC(2);
% h.LineWidth=2;
% ylabel('OCR Accuracy(%)'); % y label
% ylim([50 100])
% 
% % legend(['Toward (-1)'],['Static (0)'])
% xlabel('Different Parameters'); % x label
% xticklabels({'All','Light','Distance','Angle'})
% % xlim([0 5])
% title('')
% %adjust the ratio
% set(gcf,'WindowStyle','normal','Position', [200,200,700,360]);
% saveas(gcf,"../pic/data_3.pdf")
% 
% % data_4
% x=[1,2,3,4];
% psnr=[12.23,11.72,10.3,9.57];
% ocr_acc=[92,81,59,34];
% 
% yyaxis left
% b=bar(x,psnr,'FaceColor',left_color);
% % b.CData=lineB(1);
% ylabel('PSNR(db)'); % y label
% ylim([0 25])
% 
% yyaxis right
% h=plot(x,ocr_acc);
% h.LineStyle=lineA(2);
% h.Color=right_color;
% h.Marker=lineC(2);
% h.LineWidth=2;
% ylabel('OCR Accuracy(%)'); % y label
% ylim([20 100])
% 
% % legend(['Toward (-1)'],['Static (0)'])
% xlabel('Different Parameters'); % x label
% xticklabels({'All','Light','Distance','Angle'})
% % xlim([0 5])
% title('')
% %adjust the ratio
% set(gcf,'WindowStyle','normal','Position', [200,200,700,360]);
% saveas(gcf,"../pic/data_4.pdf")

%% data_5
x=[1,2,3,4,5];
psnr=[13.32,12.91,11.17,9.1,8.42];
ocr_acc=[100,95,76,31,14];

yyaxis left
b=bar(x,psnr,'FaceColor',left_color);
% b.CData=lineB(1);
ylabel('PSNR(db)'); % y label
ylim([0 25])

yyaxis right
h=plot(x,ocr_acc);
h.LineStyle=lineA(2);
h.Color=right_color;
h.Marker=lineC(2);
h.LineWidth=2;
ylabel('OCR Accuracy(%)'); % y label
ylim([0 100])

% legend(['Toward (-1)'],['Static (0)'])
xlabel('Different Numbers of Images'); % x label
xticklabels({'20','15','10','6','3'})
% xlim([0 5])
title('')
%adjust the ratio
set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
saveas(gcf,"./pic/data_5.pdf")

%% data_6
x=[1,2,3,4,5];
psnr=[12.23,11.34,10.8,10.2,9.18];
ocr_acc=[92,86,69,51,24];

yyaxis left
b=bar(x,psnr,'FaceColor',left_color);
% b.CData=lineB(1);
ylabel('PSNR(db)'); % y label
ylim([0 25])

yyaxis right
h=plot(x,ocr_acc);
h.LineStyle=lineA(2);
h.Color=right_color;
h.Marker=lineC(2);
h.LineWidth=2;
ylabel('OCR Accuracy(%)'); % y label
ylim([0 100])

% legend(['Toward (-1)'],['Static (0)'])
xlabel('Different Numbers of Images'); % x label
xticklabels({'20','15','10','6','3'})
% xlim([0 5])
title('')
%adjust the ratio
set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
saveas(gcf,"./pic/data_6.pdf")

%% data_7
% x=[1,2,3];
% human_acc_processed=[95,85,70];
% ocr_acc=[100,10,23];
% human_acc_raw=[5,0.1,0.1];
% 
% h=plot(x,human_acc_processed);
% h.LineStyle=lineA(1);
% h.Color=left_color;
% h.Marker=lineC(1);
% h.LineWidth=2;
% 
% hold on;
% h=plot(x,ocr_acc);
% h.LineStyle=lineA(2);
% h.Color=right_color;
% h.Marker=lineC(2);
% h.LineWidth=2;
% 
% hold on;
% b=bar(x,human_acc_raw,'FaceColor','g');
% 
% ylabel('Recognition Accuracy(%)'); % y label
% % legend(['Toward (-1)'],['Static (0)'])
% xlabel('Different Scenarios'); % x label
% xticklabels({'Home','Transport','Theater'})
% % xlim([0 5])
% title('')
% %adjust the ratio
% set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
% saveas(gcf,"../pic/data_7.pdf")