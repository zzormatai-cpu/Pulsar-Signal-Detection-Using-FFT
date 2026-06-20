clc;
clear;
close all;

%% Parameters

Fs = 1000;              % Sampling Frequency (Hz)
T = 1;                  % Duration (seconds)
t = 0:1/Fs:T-1/Fs;

f_pulse = 50;           % Pulsar Frequency (Hz)
pulse_width = 0.01;     % Pulse Width

%% Generate Clean Pulsar Signal

signal_clean = zeros(size(t));

for i = 1:length(t)

    if mod(t(i),1/f_pulse) < pulse_width
        signal_clean(i) = 1;
    end

end

%% Generate Noise

noise = 0.5*randn(size(t));

%% Received Signal

signal_raw = signal_clean + noise;

%% Figure 1: Time Domain

figure;

h1 = plot(t,signal_clean,'b','LineWidth',1.5);
hold on;

h2 = plot(t,signal_raw,'r');

h3 = plot(t,noise,'k');

legend([h1 h2 h3], ...
{'Clean Pulsar Signal','Noisy Signal','Noise'});

title('Time Domain Analysis');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% FFT Analysis

N = length(signal_raw);

Y = fft(signal_raw);

P2 = abs(Y/N);

P1 = P2(1:N/2+1);

P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(N/2))/N;

%% Figure 2: FFT Spectrum

figure;

h4 = plot(f,P1,'LineWidth',1.5);

hold on;

xline(f_pulse,'r--','50 Hz');

legend(h4,'FFT Magnitude Spectrum');

title('FFT-Based Spectral Analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;

%% Peak Detection

[max_amp,index] = max(P1);

peak_frequency = f(index);

fprintf('Detected Peak Frequency = %.2f Hz\n',peak_frequency);
fprintf('Peak FFT Amplitude = %.4f\n',max_amp);

%% PSD Analysis

[pxx,f_psd] = pwelch(signal_raw,[],[],[],Fs);

figure;

h5 = plot(f_psd,pxx,'m','LineWidth',1.5);

legend(h5,'Power Spectral Density');

title('PSD Using Welch Method');
xlabel('Frequency (Hz)');
ylabel('Power/Hz');
grid on;

%% Estimated SNR

signal_power = mean(signal_clean.^2);
noise_power  = mean(noise.^2);

SNR_dB = 10*log10(signal_power/noise_power);

fprintf('Estimated SNR = %.2f dB\n',SNR_dB);