function B = bs_field(Peval, paths, currents)
%BS_FIELD  Biot-Savart field of filamentary coils at arbitrary points.
%
%   B = BS_FIELD(Peval, PATHS, CURRENTS)
%
%   Peval    : N x 3 evaluation points, SI units [m]
%   PATHS    : cell array of polyline vertex arrays (Mk x 3) [m]; each
%              polyline is one continuous filament (consecutive points
%              joined by straight segments)
%   CURRENTS : nPath x 1 current per path [A] (default +1 A each)
%   B        : N x 3 flux density [T], columns = [Bx By Bz]
%
%   Uses the exact closed-form field of a straight finite segment:
%     B = (mu0*I/4pi) * (R1 x R2)/|R1 x R2|^2 * ( d . (R1/|R1| - R2/|R2|) )
%   where R1, R2 point from the segment ends to the field point and d is
%   the segment vector. Vectorised over all segments, blocked over
%   evaluation points. Requires MATLAB R2016b+ (implicit expansion).
%
%   通用库：任意线圈的毕奥-萨伐尔磁场计算（见 matlab/README.md）。

mu0   = 4*pi*1e-7;
nPath = numel(paths);
if nargin < 3 || isempty(currents)
    currents = ones(nPath,1);
end
currents = currents(:);

% ---- 把所有折线展开成直线段列表 -----------------------------------------
A  = zeros(0,3); B2 = zeros(0,3); Is = zeros(0,1);
for k = 1:nPath
    P  = paths{k};
    a  = P(1:end-1,:);
    b  = P(2:end,:);
    A  = [A; a];                              %#ok<AGROW>
    B2 = [B2; b];                             %#ok<AGROW>
    Is = [Is; currents(k)*ones(size(a,1),1)]; %#ok<AGROW>
end
d = B2 - A;                        % S x 3 段矢量
S = size(A,1);
if S == 0
    B = zeros(size(Peval,1),3); return
end

N   = size(Peval,1);
B   = zeros(N,3);
blk = 256;                         % 每块计算的场点数
A3  = reshape(A ,1,S,3);
B3  = reshape(B2,1,S,3);
d3  = reshape(d ,1,S,3);
I3  = reshape(Is,1,S,1);

for i0 = 1:blk:N
    ii = i0:min(i0+blk-1,N);
    P  = reshape(Peval(ii,:), [], 1, 3);    % p x 1 x 3（与 1 x S x 3 隐式展开）
    R1 = P - A3;                            % p x S x 3
    R2 = P - B3;
    C  = cross(R1,R2,3);                    % p x S x 3
    c2 = sum(C.^2,3);                       % |R1 x R2|^2
    r1 = sqrt(sum(R1.^2,3));
    r2 = sqrt(sum(R2.^2,3));
    u1 = R1./r1;
    u2 = R2./r2;
    fv = sum(d3.*(u1-u2),3);                % p x S
    fv(c2 < 1e-20) = 0;                     % 场点位于导线上的退化保护
    Bv = squeeze(sum(C.*(fv./c2).*I3, 2));  % 沿段维求和 -> p x 3
    B(ii,:) = (mu0/(4*pi))*Bv;
end
end
