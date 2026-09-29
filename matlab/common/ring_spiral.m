function P = ring_spiral(outer, inner, nTurns, z, nResample)
%RING_SPIRAL  Multi-turn spiral between two similar closed curves / polygons.
%
%   P = RING_SPIRAL(outer, inner, nTurns, z, nResample)
%   outer/inner : M x 2 (or M x 3, z column ignored) point lists describing
%                 the outermost and innermost turn. Both lists must start at
%                 the matching point and run the same direction. The spiral
%                 interpolates radially from `outer` (turn 1) to `inner`
%                 (last turn) and is closed automatically.
%   nResample   : optional; if > 2, both curves are resampled to this many
%                 points per turn with equal arc length (use for smooth
%                 curves such as stadiums/ellipses). Omit for polygons so
%                 that corners are preserved.
%
%   通用库：在两条相似闭合曲线（或多边形顶点表）之间生成等距过渡螺旋，
%   用于 H 形、T 形、跑道形等异形线圈的多圈绕组。

if nargin < 5, nResample = 0; end
outer = outer(:,1:2);
inner = inner(:,1:2);
if nResample > 2
    outer = resample_closed(outer, nResample);
    inner = resample_closed(inner, nResample);
end
outer = [outer; outer(1,:)];       % 闭合
inner = [inner; inner(1,:)];
M  = size(outer,1) - 1;            % 每圈边数
n  = round(nTurns*M);
u  = (0:n).'/M;                    % 以边为单位的位置参数, 0..nTurns
w  = mod(u,1);
i0 = floor(w*M) + 1;
i1 = mod(i0, M) + 1;
f  = w*M - floor(w*M);
Aq = outer(i0,:) + (outer(i1,:) - outer(i0,:)).*f;
Bq = inner(i0,:) + (inner(i1,:) - inner(i0,:)).*f;
fr = min(u/nTurns, 1);             % 径向过渡比例
P  = [Aq + (Bq - Aq).*fr, z*ones(n+1,1)];
end

function Q = resample_closed(P, M)
% 等弧长重采样闭合曲线到 M 个点（先去除首尾/相邻重复点，保证弧长严格递增）
Pc = [P; P(1,:)];
keep = [true; sum(abs(diff(Pc, 1, 1)).^2, 2) > 1e-18];
Pc = Pc(keep, :);
ds = sqrt(sum(diff(Pc).^2, 2));
s  = [0; cumsum(ds)];
ss = linspace(0, s(end), M+1).'; ss(end) = [];
Q  = [interp1(s, Pc(:,1), ss), interp1(s, Pc(:,2), ss)];
end
