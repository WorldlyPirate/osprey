% io_loadspec_niimrs.m
% Georg Oeltzschner, Johns Hopkins University 2021
%
% USAGE:
% out = io_loadspec_niimrs(filename);
%
% DESCRIPTION:
% Reads in MRS data stored according to the NIfTI MRS format.
% See the specification under
% https://docs.google.com/document/d/1tC4ugzGUPLoqHRGrWvOcGCuCh_Dogx_uu0cxKub0EsM/edit
%
% io_loadspec_niimrs outputs the data in structure format, with fields
% corresponding to time scale, fids, frequency scale, spectra, and header
% fields containing information about the acquisition. The resulting matlab
% structure can be operated on by the other functions in this MRS toolbox.
%
% This function is currently work-in-progress and is being tested on more
% and more datasets. Please contact the FID-A developers for help with a
% particular NIfTI-MRS file that you might encounter problems with when
% using this function.
%
% Currently, this function is limited to single-voxel MRS data. It is
% planned to develop it for full compatibility with 2D and 3D multi-voxel
% and spectroscopic imaging data.
%
% DEPENDENCIES:
% This function requires the dcm2nii toolbox (Xiangrui Li) to be on the
% MATLAB path
% https://github.com/xiangruili/dicm2nii
%
% INPUTS:
% filename   = filename of NIfTI MRS file (*.nii) to load.
%
% OUTPUTS:
% out        = Input dataset in FID-A structure format.

function out = io_loadspec_niimrs(filename,undoPhaseCycle)

if nargin < 2
    undoPhaseCycle = 0;
end

% Read in the data using the dicm2nii toolbox
% (https://github.com/xiangruili/dicm2nii)
try
    nii = nii_tool('load', filename);
catch ME
    switch ME.identifier
        case 'MATLAB:UndefinedFunction'
            error(['Cannot find the function ''nii_tool.m''.' ...
                ' Please ensure that you have downloaded the required', ...
                ' dcm2nii toolbox (https://github.com/xiangruili/dicm2nii)', ...
                ' and added it to your MATLAB path.']);
        otherwise
            rethrow(ME);
    end
end

% Extract the header and header extensions
hdr = nii.hdr;
hdr_ext = jsondecode(nii.ext.edata_decoded);

% Extract the time-domain data
fids = double(nii.img);

% Extract spectrometer frequency and dwell time
f0 = hdr_ext.SpectrometerFrequency;
dt = hdr.pixdim(5);
sw = 1/dt;

% Specify dimensions
% In NIfTI MRS, the three spatial dimensions and the time dimension occupy
% fixed indices in the (maximum) 7-D array
dims.x = 1;
dims.y = 2;
dims.z = 3;
dims.t = 4;

% There are some pre-defined dimension names according to the FID-A
% convention. These dimensions may or may not be stored in the NIfTI MRS
% header, so we'll initialize them as 0.
dims.coils = 0;
dims.averages = 0;
dims.subSpecs = 0;
dims.extras = 0;

% The NIfTI MRS standard reserves the remaining 3 dimensions, which are
% then explicitly specified in the JSON header extension fields dim_5,
% dim_6 and dim_7.
if isfield(hdr_ext, 'dim_5')
    dim_number = 5;

    % This field may come in as a cell or a string.
    if iscell(hdr_ext.dim_5)
        dim_5 = hdr_ext.dim_5{1};
    else
        dim_5 = hdr_ext.dim_5;
    end
    switch dim_5
        case 'DIM_COIL'
            dims.coils      = dim_number;
        case 'DIM_DYN'
            dims.averages   = dim_number;
        case 'DIM_INDIRECT_0'
            dims.extras     = dim_number;
        case 'DIM_INDIRECT_1'
            dims.extras     = dim_number;
        case 'DIM_INDIRECT_2'
            dims.extras     = dim_number;
        case 'DIM_PHASE_CYCLE'
            dims.extras     = dim_number;
        case 'DIM_EDIT'
            dims.subSpecs   = dim_number;
        case 'DIM_MEAS'
            dims.extras     = dim_number;
        case 'DIM_USER_0'
            dims.extras     = dim_number;
        case 'DIM_USER_1'
            dims.extras     = dim_number;
        case 'DIM_USER_2'
            dims.extras     = dim_number;
        case 'DIM_ISIS'
            dims.subSpecs   = dim_number;
        otherwise
            error('Unknown dimension value specified in dim_5: %s', dim_5);
    end

end

if isfield(hdr_ext, 'dim_6')
    dim_number = 6;

    % This field may come in as a cell or a string.
    if iscell(hdr_ext.dim_6)
        dim_6 = hdr_ext.dim_6{1};
    else
        dim_6 = hdr_ext.dim_6;
    end
    switch dim_6
        case 'DIM_COIL'
            dims.coils      = dim_number;
        case 'DIM_DYN'
            dims.averages   = dim_number;
        case 'DIM_INDIRECT_0'
            dims.extras     = dim_number;
        case 'DIM_INDIRECT_1'
            dims.extras     = dim_number;
        case 'DIM_INDIRECT_2'
            dims.extras     = dim_number;
        case 'DIM_PHASE_CYCLE'
            dims.extras     = dim_number;
        case 'DIM_EDIT'
            dims.subSpecs   = dim_number;
        case 'DIM_MEAS'
            dims.extras     = dim_number;
        case 'DIM_USER_0'
            dims.extras     = dim_number;
        case 'DIM_USER_1'
            dims.extras     = dim_number;
        case 'DIM_USER_2'
            dims.extras     = dim_number;
        case 'DIM_ISIS'
            dims.subSpecs   = dim_number;
        otherwise
            error('Unknown dimension value specified in dim_6: %s', dim_6);
    end
end
if isfield(hdr_ext, 'dim_7')
    dim_number = 7;

    % This field may come in as a cell or a string.
    if iscell(hdr_ext.dim_7)
        dim_7 = hdr_ext.dim_7{1};
    else
        dim_7 = hdr_ext.dim_7;
    end
    switch dim_7
        case 'DIM_COIL'
            dims.coils      = dim_number;
        case 'DIM_DYN'
            dims.averages   = dim_number;
        case 'DIM_INDIRECT_0'
            dims.extras     = dim_number;
        case 'DIM_INDIRECT_1'
            dims.extras     = dim_number;
        case 'DIM_INDIRECT_2'
            dims.extras     = dim_number;
        case 'DIM_PHASE_CYCLE'
            dims.extras     = dim_number;
        case 'DIM_EDIT'
            dims.subSpecs   = dim_number;
        case 'DIM_MEAS'
            dims.extras     = dim_number;
        case 'DIM_USER_0'
            dims.extras     = dim_number;
        case 'DIM_USER_1'
            dims.extras     = dim_number;
        case 'DIM_USER_2'
            dims.extras     = dim_number;
        case 'DIM_ISIS'
            dims.subSpecs   = dim_number;
        otherwise
            error('Unknown dimension value specified in dim_7: %s', dim_7);
    end
end

% Parse the NIfTI hdr.dim field:
allDims = hdr.dim(2:end); % all dimensions (including singletons)

% Find the number of points
nPts = allDims(dims.t);

% Find the number of averages.  'averages' will specify the current number
% of averages in the dataset as it is processed, which may be subject to
% change.  'rawAverages' will specify the original number of acquired
% averages in the dataset, which is unchangeable.
if dims.subSpecs ~= 0
    if dims.averages ~= 0
        averages = allDims(dims.averages)*allDims(dims.subSpecs);
        rawAverages = averages;
    else
        averages = allDims(dims.subSpecs);
        rawAverages = 1;
    end
else
    if dims.averages ~= 0
        averages = allDims(dims.averages);
        rawAverages = averages;
    else
        averages = 1;
        rawAverages = 1;
    end
end

% FIND THE NUMBER OF SUBSPECS
% 'subspecs' will specify the current number of subspectra in the dataset
% as it is processed, which may be subject to change. 'rawSubspecs' will
% specify the original number of acquired  subspectra in the dataset, which
% is unchangeable.
if dims.subSpecs ~=0
    subspecs = allDims(dims.subSpecs);
    rawSubspecs = subspecs;
else
    subspecs = 1;
    rawSubspecs = subspecs;
end

% ORDERING THE DATA AND DIMENSIONS
% The FID-A array ordering conventions differ from the NIfTI MRS
% convention. Most importantly, FID-A is primarily tailored towards
% single-voxel data. We will start designing this function towards this
% purpose, and later adapt the formalism proposed in the csi_mod branch of
% the FID-A GitHub repository.

if allDims(1)*allDims(2)*allDims(3) == 1 % x=y=z=1
    dims.x = 0;
    dims.y = 0;
    dims.z = 0;
    fids = squeeze(fids);

    %Now that we've indexed the dimensions of the data array, we now need to
    %permute it so that the order of the dimensions is standardized:  we want
    %the order to be as follows:
    %   1) time domain data.
    %   2) coils.
    %   3) averages.
    %   4) subSpecs.
    %   5) extras.

    % Adjust dimension indices for the fact that we have collapsed the
    % three spatial dimensions (which we don't need for SVS data)
    sqzDims = {};
    dimsFieldNames = fieldnames(dims);
    for rr = 1:length(dimsFieldNames)
        if dims.(dimsFieldNames{rr}) ~= 0
            % Subtract 3 (x, y, z) from the dimension indices
            dims.(dimsFieldNames{rr}) = dims.(dimsFieldNames{rr}) - 3;
            sqzDims{end+1} = dimsFieldNames{rr};
        end
    end

    if length(sqzDims) > length(size(fids)) % The case for 1 average with multiple subspectra
        if dims.averages < dims.subSpecs
            dims.subSpecs = 0;
        end
        sqzDims = {};
        dimsFieldNames = fieldnames(dims);
        for rr = 1:length(dimsFieldNames)
            if dims.(dimsFieldNames{rr}) ~= 0
                % Subtract 3 (x, y, z) from the dimension indices
                sqzDims{end+1} = dimsFieldNames{rr};
            end
        end
        subspecs    = 0;
        if rawSubspecs > 0
            subspecs    = rawSubspecs;
        end
    end

    if length(sqzDims)==5
        fids=permute(fids,[dims.t dims.coils dims.averages dims.subSpecs dims.extras]);
        dims.t=1;dims.coils=2;dims.averages=3;dims.subSpecs=4;dims.extras=5;
    elseif length(sqzDims)==4
        if dims.extras==0
            fids=permute(fids,[dims.t dims.coils dims.averages dims.subSpecs]);
            dims.t=1;dims.coils=2;dims.averages=3;dims.subSpecs=4;dims.extras=0;
        elseif dims.subSpecs==0
            fids=permute(fids,[dims.t dims.coils dims.averages dims.extras]);
            dims.t=1;dims.coils=2;dims.averages=3;dims.subSpecs=0;dims.extras=4;
        elseif dims.averages==0
            fids=permute(fids,[dims.t dims.coils dims.subSpecs dims.extras]);
            dims.t=1;dims.coils=2;dims.averages=0;dims.subSpecs=3;dims.extras=4;
        elseif dims.coils==0
            fids=permute(fids,[dims.t dims.averages dims.subSpecs dims.extras]);
            dims.t=1;dims.coils=0;dims.averages=2;dims.subSpecs=3;dims.extras=4;
        end
    elseif length(sqzDims)==3
        if dims.extras==0 && dims.subSpecs==0
            fids=permute(fids,[dims.t dims.coils dims.averages]);
            dims.t=1;dims.coils=2;dims.averages=3;dims.subSpecs=0;dims.extras=0;
        elseif dims.extras==0 && dims.averages==0
            fids=permute(fids,[dims.t dims.coils dims.subSpecs]);
            dims.t=1;dims.coils=2;dims.averages=0;dims.subSpecs=3;dims.extras=0;
        elseif dims.extras==0 && dims.coils==0
            fids=permute(fids,[dims.t dims.averages dims.subSpecs]);
            dims.t=1;dims.coils=0;dims.averages=2;dims.subSpecs=3;dims.extras=0;
        end
    elseif length(sqzDims)==2
        if dims.extras==0 && dims.subSpecs==0 && dims.averages==0
            fids=permute(fids,[dims.t dims.coils]);
            dims.t=1;dims.coils=2;dims.averages=0;dims.subSpecs=0;dims.extras=0;
        elseif dims.extras==0 && dims.subSpecs==0 && dims.coils==0
            fids=permute(fids,[dims.t dims.averages]);
            dims.t=1;dims.coils=0;dims.averages=2;dims.subSpecs=0;dims.extras=0;
        elseif dims.extras==0 && dims.averages==0 && dims.coils==0
            fids=permute(fids,[dims.t dims.subSpecs]);
            dims.t=1;dims.coils=0;dims.averages=0;dims.subSpecs=2;dims.extras=0;
        end
    elseif length(sqzDims)==1
        dims.t=1;dims.coils=0;dims.averages=0;dims.subSpecs=0;dims.extras=0;
    end

    %Now get the size of the data array:
    sz=size(fids);

    %Remove phase cycle for Philips data
    if isfield(hdr_ext, 'Manufacturer') && (strcmp(hdr_ext.Manufacturer,'Philips') || strcmp(hdr_ext.Manufacturer,'GE')) && undoPhaseCycle
        fids = fids .* repmat(conj(fids(1,:,:,:))./abs(fids(1,:,:,:)),[size(fids,1) 1]);
    end

    %Compared to NIfTI MRS, FID-A needs the conjugate
    fids = conj(fids);

    %Now take fft of time domain to get fid:
    specs=fftshift(fft(fids,[],dims.t),dims.t);

end



% Fill in additional FID-A format variables
% Nucleus (new field)
out.nucleus = hdr_ext.ResonantNucleus;
% Calculate B0 from spectrometer frequency depending on nucleus
% Gamma from Wikipedia article "Gyromagnetic ratio" (3 signif. digits)
for rr = 1:length(out.nucleus)
    switch strtrim(out.nucleus{rr})
        case '1H'
            gamma = 42.577;
        case '2H'
            gamma = 6.536;
        case '3HE'
            gamma = -32.434;
        case '7LI'
            gamma = 16.546;
        case '13C'
            gamma = 10.708;
        case '19F'
            gamma = 40.052;
        case '23NA'
            gamma = 11.262;
        case '31P'
            gamma = 17.235;
        case '129XE'
            gamma = -11.777;
    end
    Bo(rr) = f0(rr) ./ gamma;
end

% Calculate t and ppm arrays using the calculated parameters:
f   =[(-sw/2) + (sw/(2*nPts)) : sw/(nPts) : (sw/2) - (sw/(2*nPts))];
ppm = f / (Bo(1)*42.577);
centerFreq = 4.68;
ppm = ppm + centerFreq;
t   = [0 : dt : (nPts-1)*dt];

% Try and grab sequence name from header
if isfield(hdr_ext, 'SequenceName')
    seq = hdr_ext.SequenceName;
else
    seq = 'nii_spec';
end
out.seq=seq;

% MANDATORY FIELDS
% Data & dimensions
out.fids = fids;
out.specs = specs;
out.sz = sz;
out.dims = dims;
out.Bo = Bo;
out.averages = averages;
out.rawAverages = rawAverages;
out.subspecs = subspecs;
out.rawSubspecs = rawSubspecs;

% Echo/repetition time
out.te = hdr_ext.EchoTime * 1e3;        %convert to [ms]
out.tr = hdr_ext.RepetitionTime * 1e3;  %convert to [ms]

% time and frequency axis
out.t   = t;
out.ppm = ppm;
out.centerFreq = centerFreq;

% Dwell time & spectral width & field strength
out.spectralwidth = sw;
out.dwelltime = dt;
out.txfrq = f0*1e6;

% NIfTI-MRS-SPECIFIC FIELDS
% Save the NIfTI header
out.nii_mrs.hdr = hdr;
% Save the header extension
out.nii_mrs.hdr_ext = hdr_ext;

% Geometry
geometry.size.dim1     = hdr.pixdim(2); % [mm]
geometry.size.dim2     = hdr.pixdim(3); % [mm]
geometry.size.dim3     = hdr.pixdim(4); % [mm]
out.geometry = geometry;

%FILLING IN THE FLAGS
out.flags.writtentostruct=1;
out.flags.gotparams=1;
out.flags.leftshifted=0;
out.flags.filtered=0;
out.flags.zeropadded=0;
out.flags.freqcorrected=0;
out.flags.phasecorrected=0;
if out.dims.averages==0
    out.flags.averaged=1;
else
    out.flags.averaged=0;
end
if out.dims.coils==0
    out.flags.addedrcvrs=1;
else
    out.flags.addedrcvrs=0;
end
out.flags.subtracted=0;
out.flags.writtentotext=0;
out.flags.downsampled=0;
if out.dims.subSpecs==0
    out.flags.isFourSteps=0;
else
    out.flags.isFourSteps=(out.sz(out.dims.subSpecs)==4);
end
% Sequence flags
out.flags.isUnEdited = 0;
out.flags.isMEGA = 0;
out.flags.isHERMES = 0;
out.flags.isHERCULES = 0;
out.flags.isPRIAM = 0;
out.flags.isMRSI = 0;
if strcmp(seq,'PRESS') || strcmp(seq,'STEAM') || strcmp(seq,'SLASER')
    out.flags.isUnEdited = 1;
end
if contains(seq,'MEGA')
    out.flags.isMEGA = 1;
end
if strcmp(seq,'HERMES')
    out.flags.isHERMES = 1;
end
if strcmp(seq,'HERCULES')
    out.flags.isHERCULES = 1;
end

% Store additional information from the nii header
    if out.dims.extras
        if ischar(out.seq)
            temp_seq = out.seq;
            out = rmfield(out,'seq');
            out.seq{1} = temp_seq;
        end
        for ex = 1 : out.sz(out.dims.extras)
            out.seq{ex} = out.seq{1};
            out.spectralwidth(ex) = out.spectralwidth(1);
            out.dwelltime(ex) = out.dwelltime(1);
            out.centerFreq(ex) = out.centerFreq(1);
            out.txfrq(ex) = out.txfrq(1);

            if isfield(hdr_ext.(['dim_' num2str(dim_number) '_header']), 'EchoTime')
                out.te(ex) = hdr_ext.(['dim_' num2str(dim_number) '_header']).EchoTime(ex) * 1e3; % convert to [ms]
                out.extra_names{ex} = ['TE_' num2str(ex)];
                out.exp_var(ex) = out.te(ex);
            else
                out.te(ex) = out.te(1);
            end

            if isfield(hdr_ext.(['dim_' num2str(dim_number) '_header']), 'RepetitionTime')
                out.tr(ex) = hdr_ext.(['dim_' num2str(dim_number) '_header']).RepetitionTime(ex) * 1e3; % convert to [ms]
                out.extra_names{ex} = ['TR_' num2str(ex)];
                out.exp_var(ex) = out.tr(ex);
            else
                out.tr(ex) = out.tr(1);
            end

            if isfield(hdr_ext.(['dim_' num2str(dim_number) '_header']), 'InversionTime')
                out.ti(ex) = hdr_ext.(['dim_' num2str(dim_number) '_header']).InversionTime(ex) * 1e3; % convert to [ms]
                out.extra_names{ex} = ['TI_' num2str(ex)];
                out.exp_var(ex) = out.ti(ex);
            end
        end
        out.extras = out.sz(out.dims.extras);

    end
end
