function [L, Rdc, wireLen] = coil_L_R(paths, rWire, wall, currents)
%COIL_L_R  Segment-wise Neumann estimate of coil inductance and DC resistance.
%
%   [L,Rdc,wireLen] = COIL_L_R(paths, rWire, wall, currents)
%   rWire   : conductor outer radius [m]
%   wall    : wall thickness [m]; pass wall = rWire for a solid round wire
%   currents: optional nPath x 1 current per path (default +1 each). Required
%             for multilayer_* windings whose even layers are stored reversed
%             with sign -1 (see MULTILAYER_SPIRAL) — otherwise layer mutual
%             inductance cancels spuriously.
%   L       : inductance [H]   -- Neumann-type estimate (mutual terms by
%             midpoint rule + straight-segment self terms); typical accuracy
%             ±15% for compact windings, use as an engineering estimate.
%   Rdc     : DC resistance [ohm] (copper, 20 C)
%   wireLen : total conductor length [m]
%
%   通用库：电感 / 直流电阻估算（用于与图纸标注的 19~20 μH 规格对比）。

mu0   = 4*pi*1e-7;
rhoCu = 1.72e-8;
ri = max(rWire - wall, 1e-9);
Aw = pi*(rWire^2 - ri^2);
if nargin < 4 || isempty(currents), currents = ones(numel(paths), 1); end
currents = currents(:);

wireLen = 0;
A = zeros(0,3); d = zeros(0,3); mid = zeros(0,3); Is = zeros(0,1);
for k = 1:numel(paths)
    P = paths{k};
    wireLen = wireLen + sum(sqrt(sum(diff(P).^2, 2)));
    Q  = resample_path(P, 0.012);          % ~12 mm 等弧长重采样
    a  = Q(1:end-1,:);
    b  = Q(2:end,:);
    A  = [A; a];                           %#ok<AGROW>
    d  = [d; b - a];                       %#ok<AGROW>
    mid= [mid; (a + b)/2];                 %#ok<AGROW>
    Is = [Is; currents(k)*ones(size(a,1),1)];  %#ok<AGROW>
end
l = sqrt(sum(d.^2, 2));
S = numel(l);

% 直线段自感项（圆截面导体经验公式）
Lself = (mu0/(2*pi))*sum(l .* (log(2*l/rWire) - 0.75));

% 互感项（分段 Neumann，中点近似），分块防内存峰值；按各路径电流符号加权
Lm  = 0;
blk = 256;
for i0 = 1:blk:S
    ii  = i0:min(i0+blk-1, S);
    Dv  = reshape(mid(ii,:), [], 1, 3) - reshape(mid, 1, [], 3);   % b x S x 3
    Rij = sqrt(sum(Dv.^2, 3));                                     % b x S
    Mij = (d(ii,:)*d.') ./ max(Rij, 1e-9);                         % b x S
    Mij = Mij .* (Is(ii)*Is.');            % 电流符号（多层反向存储补偿）
    Mij(Rij < 1e-9) = 0;                   % 排除自身
    Lm  = Lm + sum(Mij(:));
end
L = Lself + (mu0/(4*pi))*Lm;

Rdc = rhoCu*wireLen/Aw;
end

function Q = resample_path(P, dsMax)
% 开折线等弧长重采样（自动消除零长度段）
s  = [0; cumsum(sqrt(sum(diff(P).^2, 2)))];
L  = s(end);
n  = max(2, ceil(L/dsMax) + 1);
ss = linspace(0, L, n).';
Q  = [interp1(s, P(:,1), ss), interp1(s, P(:,2), ss), interp1(s, P(:,3), ss)];
end
