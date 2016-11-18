function [ Wc, bw, A, Q ] = rauchbp( R1, R2, R3, C )
%rauchbp: Compute and return Gain , resonnance frequency and bandwith of a
%rauch bandpass filter.

A = R3/(2*R1);
bw = 2/(R3*C*1E-12*2*pi);
Wc = sqrt((R1+R2)/(R1*R2*R3))/(C*1E-12*2*pi);
Q = Wc/bw;

end

