function out = limexp_vapp(x)
breakpoint = 40;
maxslope = exp(breakpoint);
out = exp(x.*(x <= breakpoint)).*(x <= breakpoint) + ...
    (x>breakpoint).*(maxslope + maxslope*(x-breakpoint));
end % limexp
