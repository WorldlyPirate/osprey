function [out, commuteOrder] = osp_onOffClassifyHERMES(in, target,Order)
%% [outA, outB, outC, outD, commuteOrder] = osp_onOffClassifyHERMES(in, target,Order)
%   This function decides how the four-provided HERMES/HERCULES sub-spectra are
%   being edited. Currently, this function works for all combinations of
%   HERMES and HERCULES that include GABA and GSH editing.
%   The NAA/NAAG/Asp-editing flavor of HERMES is currently not supported.
%
%   To determine the editing pattern, this function ranks the four spectra
%   according to the amplitude of the residual water (suppressed for GSH-ON)
%   and NAA (suppressed for GABA-ON) signals.
%
%   The function finally assigns:
%       - the GABA-OFF-GSH-OFF spectrum to field A
%       - the GABA-ON-GSH-OFF spectrum to field B
%       - the GABA-OFF-GSH-ON spectrum to field C
%       - the GABA-ON-GSH-ON spectrum to field D
%
%   USAGE:
%       [out] = osp_onOffClassifyHERMES(in, target,Order)
%
%   INPUTS:
%       in     = FID-A structure containing the all sub-spectra.
%       target = editing targets
%       Order  = manual overwrite order
%
%   OUTPUTS:
%       out    = FID-A structure containing sorted sub-spectra.

%
%   AUTHOR:
%       Dr. Georg Oeltzschner (Johns Hopkins University, 2019-08-15)
%       goeltzs1@jhmi.edu
%
%   CREDITS:
%       This code is based on numerous functions from the FID-A toolbox by
%       Dr. Jamie Near (McGill University)
%       https://github.com/CIC-methods/FID-A
%       Simpson et al., Magn Reson Med 77:23-33 (2017)
%
%   HISTORY:
%       2019-08-15: First version of the code.

if nargin < 2
    target = 'GABAGSH';
    Order = [];
end
if nargin < 3
    Order = [];
end

if isempty(Order)
    inA = op_takesubspec(in,1);
    inB = op_takesubspec(in,2);
    inC = op_takesubspec(in,3);
    inD = op_takesubspec(in,4);
    
    
    switch target
        case 'GABAGSH'
            % Determine maximum signal intensities for water and NAA in each
            % sub-spectrum.
            [max_first(1), max_second(1)]  = findMaxNAAw(inA);
            [max_first(2), max_second(2)]  = findMaxNAAw(inB);
            [max_first(3), max_second(3)]  = findMaxNAAw(inC);
            [max_first(4), max_second(4)]  = findMaxNAAw(inD);
        case 'GABALac'
            [max_first(1), max_second(1)]  = findMaxNAACr(inA);
            [max_first(2), max_second(2)]  = findMaxNAACr(inB);
            [max_first(3), max_second(3)]  = findMaxNAACr(inC);
            [max_first(4), max_second(4)]  = findMaxNAACr(inD);
        otherwise
            [max_first(1), max_second(1)]  = findMaxNAAw(inA);
            [max_first(2), max_second(2)]  = findMaxNAAw(inB);
            [max_first(3), max_second(3)]  = findMaxNAAw(inC);
            [max_first(4), max_second(4)]  = findMaxNAAw(inD);
    end
    
    % Sort the intensities in ascending order
    [~,order_first]   = sort(max_first);
    [~,order_second] = sort(max_second);
    
    % Now loop over the subspectra indices (A = 1, B = 2, etc) to determine
    % whether the respective experiments have high or low intensities:
    for ll = 1:4
        idx_first   = find(order_first == ll);
        idx_second = find(order_second == ll);
    
        if ismember(idx_first,[3 4])
            first.ON(ll) = 0;
        elseif ismember(idx_first,[1 2])
            first.ON(ll) = 1;
        end
    
        if ismember(idx_second,[3 4])
            second.ON(ll) = 0;
        elseif ismember(idx_second,[1 2])
            second.ON(ll) = 1;
        end
    
    end
    
    % Determine the sub-spectra indices belonging to each editing pattern
    idx_OFF_OFF = ~second.ON & ~first.ON;
    idx_ON_OFF  = second.ON & ~first.ON;
    idx_OFF_ON  = ~second.ON & first.ON;
    idx_ON_ON   = second.ON & first.ON;
    
    % Commute for output
    try
        temp = in;
        out = in;
        out.specs(:,1) = temp.specs(:,idx_OFF_OFF);
        out.specs(:,2) = temp.specs(:,idx_ON_OFF);
        out.specs(:,3) = temp.specs(:,idx_OFF_ON);
        out.specs(:,4) = temp.specs(:,idx_ON_ON);
        out.fids(:,1) = temp.fids(:,idx_OFF_OFF);
        out.fids(:,2) = temp.fids(:,idx_ON_OFF);
        out.fids(:,3) = temp.fids(:,idx_OFF_ON);
        out.fids(:,4) = temp.fids(:,idx_ON_ON);
    catch
        idx_OFF_OFF = logical([0 0 0 1]);
        idx_ON_OFF  = logical([0 1 0 0]);
        idx_OFF_ON  = logical([1 0 0 0]);
        idx_ON_ON   = logical([0 0 1 0]);
        temp = in;
        out = in;
        out.specs(:,1) = temp.specs(:,idx_OFF_OFF);
        out.specs(:,2) = temp.specs(:,idx_ON_OFF);
        out.specs(:,3) = temp.specs(:,idx_OFF_ON);
        out.specs(:,4) = temp.specs(:,idx_ON_ON);
        out.fids(:,1) = temp.fids(:,idx_OFF_OFF);
        out.fids(:,2) = temp.fids(:,idx_ON_OFF);
        out.fids(:,3) = temp.fids(:,idx_OFF_ON);
        out.fids(:,4) = temp.fids(:,idx_ON_ON);
    end
    
    % Save commute order
    commuteOrder = [find(idx_OFF_OFF), find(idx_ON_OFF), find(idx_OFF_ON), find(idx_ON_ON)];
else
    temp = in;
    out = in;
    idx_OFF_OFF = logical([0 0 0 0]);
    idx_ON_OFF  = logical([0 0 0 0]);
    idx_OFF_ON  = logical([0 0 0 0]);
    idx_ON_ON   = logical([0 0 0 0]);
    idx_OFF_OFF(Order(1)) = 1;
    idx_ON_OFF(Order(2)) = 1;
    idx_OFF_ON(Order(3)) = 1;
    idx_ON_ON(Order(4)) = 1;
    out.specs(:,1) = temp.specs(:,idx_OFF_OFF);
    out.specs(:,2) = temp.specs(:,idx_ON_OFF);
    out.specs(:,3) = temp.specs(:,idx_OFF_ON);
    out.specs(:,4) = temp.specs(:,idx_ON_ON);
    out.fids(:,1) = temp.fids(:,idx_OFF_OFF);
    out.fids(:,2) = temp.fids(:,idx_ON_OFF);
    out.fids(:,3) = temp.fids(:,idx_OFF_ON);
    out.fids(:,4) = temp.fids(:,idx_ON_ON);
    % Save commute order
    commuteOrder = Order;
end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [max_w, max_NAA] = findMaxNAAw(in)
% This embedded function finds the maximum intensities of the water
% and NAA signals of an input spectrum.

% Determine relevant frequency ranges
out_w   = op_freqrange(in,4.2,5.2);
out_NAA = op_freqrange(in,1.8,2.2);

% Determine maximum absolute signal
max_w   = max([abs(max(real(out_w.specs))), abs(min(real(out_w.specs)))]);
max_NAA = max([abs(max(real(out_NAA.specs))), abs(min(real(out_NAA.specs)))]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [max_ins, max_NAA] = findMaxNAACr(in)
% This embedded function finds the maximum intensities of the creatine and
% siganls at 3.9 ppm and NAA signals of an input spectrum.

% Determine relevant frequency ranges
out_ins   = op_freqrange(in,3.8,4);
out_NAA = op_freqrange(in,1.8,2.2);

% Determine maximum absolute signal
max_ins   = max([abs(max(real(out_ins.specs))), abs(min(real(out_ins.specs)))]);
max_NAA = max([abs(max(real(out_NAA.specs))), abs(min(real(out_NAA.specs)))]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
