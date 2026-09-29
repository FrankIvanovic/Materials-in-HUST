function [K, E] = elliptic_ke(m)
%ELLIPTIC_KE  Complete elliptic integrals K(m), E(m) by the AGM iteration.
%
%   [K,E] = ELLIPTIC_KE(m)   m = k^2 (parameter), element-wise, 0 <= m < 1.
%   Base MATLAB, no toolboxes. Converges to double precision in ~6-10
%   iterations (Abramowitz & Stegun 17.6; Borwein, Pi and the AGM):
%     a0 = 1, b0 = sqrt(1-m), c_n^2 = a_n^2 - b_n^2
%     K = pi / (2*a_inf),  E = K * (1 - sum_{n>=0} 2^(n-1) * c_n^2)
%
%   论文专用：供 loop_field_elliptic.m 使用。

m = min(max(m, 0), 1 - 1e-15);     % 保护：m < 1
a = ones(size(m));
b = sqrt(1 - m);
c = sqrt(m);
s = 0.5*c.^2;                      % 级数 n = 0 项，权重 2^(-1)
w = ones(size(m));                 % 下一项（n = 1）权重 2^0
for it = 1:60
    cn = 0.5*(a - b);              % c_n，n = 1, 2, ...
    s  = s + w.*cn.^2;
    w  = 2*w;
    a  = 0.5*(a + b);
    b  = sqrt(max(a.^2 - cn.^2, 0));   % b_{n+1} = sqrt(a_n*b_n)
    if max(cn) < 1e-16
        break
    end
end
K = pi ./ (2*a);
E = K .* (1 - s);
end
