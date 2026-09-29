function [Brho, Bz] = loop_field_elliptic(a, I, rho, z)
%LOOP_FIELD_ELLIPTIC  Exact off-axis field of a single current loop.
%
%   [BRHO,BZ] = LOOP_FIELD_ELLIPTIC(a, I, rho, z)
%   a    : loop radius [m]
%   I    : current [A]
%   rho  : radial coordinate(s) [m] (array, same size as z or scalar)
%   z    : axial coordinate(s) [m]
%   Returns cylindrical components (B_rho, B_z) [T], evaluated with
%   complete elliptic integrals (MATLAB ellipticK/E, argument m = k^2):
%
%     k^2 = 4 a rho / ((a+rho)^2 + z^2)
%     B_rho = mu0*I*z / (2*pi*rho*s) * [ -K(k) + (a^2+rho^2+z^2)/Q * E(k) ]
%     B_z   = mu0*I / (2*pi*s)       * [  K(k) + (a^2-rho^2-z^2)/Q * E(k) ]
%     s = sqrt((a+rho)^2+z^2),  Q = (a-rho)^2 + z^2
%
%   (Smythe, Static and Dynamic Electricity, 3rd ed., §7; Jackson §5.5)
%   rho -> 0 handled by the analytic axis limit. 椭圆积分用 AGM 算法
%   自实现（elliptic_ke.m），不依赖 Symbolic Math Toolbox。
%
%   论文专用：单匝圆环离轴磁场精确解（§2 数值核验证基准）。

mu0 = 4*pi*1e-7;
rho = rho + 0*z;   % 广播成同尺寸
z   = z + 0*rho;

s = sqrt((a + rho).^2 + z.^2);
Q = (a - rho).^2 + z.^2;
m = 4*a.*rho ./ s.^2;                    % = k^2
[K, E] = elliptic_ke(m);

f1 = -K + (a^2 + rho.^2 + z.^2) ./ Q .* E;
f2 =  K + (a^2 - rho.^2 - z.^2) ./ Q .* E;

Brho = (mu0*I*z) ./ (2*pi*rho.*s) .* f1;
Bz   = (mu0*I) ./ (2*pi*s) .* f2;

% ---- 轴上（rho = 0）解析极限 -------------------------------------------
onAx = (rho == 0);
if any(onAx(:))
    Bax = mu0*I*a^2 ./ (2*(a^2 + z(onAx).^2).^1.5);
    Brho(onAx) = 0;
    Bz(onAx)   = Bax;
end
end
