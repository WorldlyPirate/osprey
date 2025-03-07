function osp_iniOverviewWindow(gui)
%% osp_iniOverviewWindow
%   This function creates the initial overview window in the gui.
%
%
%   USAGE:
%       osp_iniOverviewWindow(gui);
%
%   INPUT:      gui      = gui class containing all handles and the MRSCont 
%
%   OUTPUT:     Changes in gui parameters and MRSCont are written into the
%               gui class
%
%
%   AUTHORS:
%       Dr. Helge Zoellner (Johns Hopkins University, 2020-01-16)
%       hzoelln2@jhmi.edu
%
%   CREDITS:
%       This code is based on numerous functions from the FID-A toolbox by
%       Dr. Jamie Near (McGill University)
%       https://github.com/CIC-methods/FID-A
%       Simpson et al., Magn Reson Med 77:23-33 (2017)
%
%   HISTORY:
%       2020-01-16: First version of the code.
%%% 1. GET HANDLES %%%
%This function creates the initial overview window
        MRSCont = getappdata(gui.figure,'MRSCont'); % Get MRSCont from hidden container in gui class
        gui.layout.tabs.TabEnables{6} = 'on';  
        gui.layout.tabs.Selection  = 6;  
% Creating subtabs
        gui.layout.specsOvTab = uix.HBox('Parent', gui.layout.overviewTab, 'Padding', 5,'BackgroundColor',gui.colormap.Background);
        gui.layout.meanOvTab = uix.HBox('Parent', gui.layout.overviewTab, 'Padding', 5,'BackgroundColor',gui.colormap.Background);
        gui.layout.quantOvTab = uix.HBox('Parent', gui.layout.overviewTab, 'Padding', 5,'BackgroundColor',gui.colormap.Background);
        gui.layout.distrOvTab = uix.HBox('Parent', gui.layout.overviewTab, 'Padding', 5,'BackgroundColor',gui.colormap.Background);
        gui.layout.corrOvTab = uix.HBox('Parent', gui.layout.overviewTab, 'Padding', 5,'BackgroundColor',gui.colormap.Background);
        gui.layout.diceOvTab = uix.HBox('Parent', gui.layout.overviewTab, 'Padding', 5,'BackgroundColor',gui.colormap.Background);  
        gui.layout.overviewTab.TabTitles  = {'spectra', 'mean spectra', 'quantify table', 'distribution', 'correlation','dice overlap'};    
        gui.layout.overviewTab.TabEnables = {'on', 'on', 'off', 'off', 'off', 'off'};   
        gui.layout.overviewTab.TabWidth   = 115;
        gui.layout.overviewTab.Selection  = 1;

        gui.layout.overviewTabhandels = {'specsOvTab','meanOvTab','quantOvTab','distrOvTab','corrOvTab','diceOvTab'};
% Check version of Osprey - since we have changed the layout of the Overview struct with the implementation of DualVoxel
if isfield(MRSCont.overview.Osprey, 'sort_data')
    sort_data = 'sort_data';
else
    sort_data = 'sort_data_voxel_1';
end        
        
%%% 2. SPECS OVERVIEW %%% 
%Overview Panel for all specs sorted by groups
        gui.Plot.specsOv = uix.VBox(...
            'Parent', gui.layout.specsOvTab, ...
            'BackgroundColor',gui.colormap.Background,'Padding', 5);

%Creates popup menu for the processed Subspectra (A,B,C,D,mm,ref,water) .... re_mm
       SubNames = fieldnames(MRSCont.overview.SubSpecNamesStruct);
       k=1;
       if ~isempty(SubNames) 
           for i = 1 : gui.process.Number
               for j = 1 :size(MRSCont.overview.SubSpecNamesStruct.(SubNames{i}),2)
                    tempSubNames{k} = [SubNames{i}, ' ', MRSCont.overview.SubSpecNamesStruct.(SubNames{i}){1,j}]; 
                    k=k+1;
               end
           end
       end
       
       FitNames = fieldnames(MRSCont.overview.FitSpecNamesStruct);
       k=1;
       if ~isempty(FitNames) 
           for i = 1 : gui.fit.Number
               for j = 1 :size(MRSCont.overview.FitSpecNamesStruct.(FitNames{i}),2)
                    tempFitNames{k} = ['Model ', FitNames{i}, ' ', MRSCont.overview.FitSpecNamesStruct.(FitNames{i}){1,j}]; 
                    k=k+1;
               end
           end
       end
       
       gui.upperBox.specsOv.box = uix.HBox('Parent', gui.Plot.specsOv,'BackgroundColor',gui.colormap.Background, 'Spacing',5);
              
       gui = upper_navigate_box(gui, 'specsOv','metab',1);
       
       gui.controls.specsOvPlot = uix.Panel('Parent', gui.upperBox.specsOv.box,'Title', 'Individual spectra or fit', ...
                                            'Padding', 5,'HighlightColor', gui.colormap.Foreground,'BackgroundColor',gui.colormap.Background,...
                                            'ForegroundColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
       gui.controls.specsOv = uix.HBox('Parent', gui.controls.specsOvPlot,...
                                       'Padding', 5, 'Spacing', 10,'BackgroundColor',gui.colormap.Background);
       gui.controls.pop_specsOvPlot = uicontrol('Parent',gui.controls.specsOv,'style','popupmenu',...
                                                'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font, ...
                                                'String',[tempSubNames';tempFitNames'], 'Value', 1);
       gui.controls.check_specsOvPlot = uicontrol('Parent',gui.controls.specsOv,'Style','checkbox','BackgroundColor',gui.colormap.Background,'String','Grand Mean', ...
                                                    'Value',gui.controls.GM,'Position',[0 0 1 1],'FontName', gui.font);
       gui.upperBox.specsOv.upperButtons = uix.Panel('Parent', gui.upperBox.specsOv.box, ...
                                     'Padding', 5, 'Title', ['Save'],...
                                     'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground,...
                                     'HighlightColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
       gui.controls.b_save_specOvTab = uicontrol('Parent',gui.upperBox.specsOv.upperButtons,'Style','PushButton');
       [img, ~, ~] = imread('Printer.png', 'BackgroundColor', gui.colormap.Background);
       [img2] = imresize(img, 0.05);
       set(gui.controls.b_save_specOvTab,'CData', img2, 'TooltipString', 'Create EPS figure from current file');
       set(gui.controls.b_save_specOvTab,'Callback',{@osp_onPrint,gui});
       set(gui.upperBox.specsOv.box, 'Width',  [-0.16 -0.74 -0.1])  
       set(gui.controls.specsOv, 'Width', [-0.85 -0.15])

%op_plotspec is used to visualize the processed data
        gui.layout.shiftind = 0.2;
        for g = 1 :  gui.overview.Number.Groups %Loop over groups. Difterenc colors and shifts for different groups
            temp = osp_plotOverviewSpec(MRSCont, tempSubNames{1}, g, gui.layout.shiftind);
            if g == 1
                ViewAxes=get(temp,'Children');
                drawnow
                set(ViewAxes, 'Parent', gui.Plot.specsOv);
                h = findall(groot,'Type','figure');
                for ff = 1 : length(h)
                    if ~(strcmp(h(ff).Tag, 'Osprey') ||  strcmp(h(ff).Tag, 'TMWWaitbar'))
                        close(h(ff))
                    end
                end
            else
                ViewAxes=get(temp,'Children');
                copyobj(ViewAxes.Children, gui.Plot.specsOv.Children(2));
                h = findall(groot,'Type','figure');
                for ff = 1 : length(h)
                    if ~(strcmp(h(ff).Tag, 'Osprey') ||  strcmp(h(ff).Tag, 'TMWWaitbar'))
                        close(h(ff))
                    end
                end
            end
        end
        if gui.load.Selected ==1 %Metabolite data?
            set(gui.Plot.specsOv.Children(2), 'XLim', [0.2 4.5])
        else %Water data?
            set(gui.Plot.specsOv.Children(2), 'XLim', [0 2*4.68])
        end
        set(gui.Plot.specsOv,'Heights', [-0.1 -0.9]);

%%% 3. MEAN SPECS %%%
       gui.layout.overviewTab.Selection  = 2;
       gui.Plot.meanOv = uix.VBox('Parent', gui.layout.meanOvTab,'BackgroundColor',gui.colormap.Background,'Padding', 5);

       
       SubNames = fieldnames(MRSCont.overview.SubSpecNamesStruct);
       k=1;
       if ~isempty(SubNames) 
           for i = 1 : gui.process.Number
               for j = 1 :size(MRSCont.overview.SubSpecNamesStruct.(SubNames{i}),2)
                   if ~isempty(find(strcmp(FitNames,SubNames{i})))
                        if (~isempty(find(strcmp(MRSCont.overview.FitSpecNamesStruct.(SubNames{i}),MRSCont.overview.SubSpecNamesStruct.(SubNames{i}){1,j}))))
                            tempSubNamesFit{k} = ['Model ' , SubNames{i}, ' ', MRSCont.overview.SubSpecNamesStruct.(SubNames{i}){1,j}];
                        else
                            tempSubNamesFit{k} = [SubNames{i}, ' ', MRSCont.overview.SubSpecNamesStruct.(SubNames{i}){1,j}]; 
                        end
                   else
                       tempSubNamesFit{k} = [SubNames{i}, ' ', MRSCont.overview.SubSpecNamesStruct.(SubNames{i}){1,j}]; 
                   end
                    k=k+1;
               end
           end
       end
       
%Creates popup menu for the processed Subspectra and fits (A,B,C,D,ref,water)
       gui.upperBox.meanOv.box = uix.HBox('Parent', gui.Plot.meanOv,'BackgroundColor',gui.colormap.Background, 'Spacing',5); 
       gui = upper_navigate_box(gui, 'meanOv','metab',1);
       gui.controls.meanOvPlot = uix.Panel('Parent', gui.upperBox.meanOv.box,'Title', 'Actual spectrum', ...
                                          'Padding', 5,'HighlightColor', gui.colormap.Foreground,'BackgroundColor',gui.colormap.Background,...
                                          'ForegroundColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
       gui.controls.meanOv = uix.HBox('Parent', gui.controls.meanOvPlot,...
                                       'Padding', 5, 'Spacing', 10,'BackgroundColor',gui.colormap.Background);                               
       gui.controls.pop_meanOvPlot = uicontrol('Parent',gui.controls.meanOv,'style','popupmenu',...
                                              'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font, ...
                                              'String',tempSubNamesFit, 'Value', 1);
       gui.controls.check_meanOvPlot = uicontrol('Parent',gui.controls.meanOv,'Style','checkbox','BackgroundColor',gui.colormap.Background,'String','Grand Mean', ...
                                                    'Value',gui.controls.GM,'Position',[0 0 1 1],'FontName', gui.font);                                          
       gui.upperBox.meanOv.upperButtons = uix.Panel('Parent', gui.upperBox.meanOv.box, ...
                                     'Padding', 5, 'Title', ['Save'],...
                                     'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground,...
                                     'HighlightColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
       gui.controls.b_save_meanOvTab = uicontrol('Parent',gui.upperBox.meanOv.upperButtons,'Style','PushButton');
       [img, ~, ~] = imread('Printer.png', 'BackgroundColor', gui.colormap.Background);
       [img2] = imresize(img, 0.05);
       set(gui.controls.b_save_meanOvTab,'CData', img2, 'TooltipString', 'Create EPS figure from current file');
       set(gui.controls.b_save_meanOvTab,'Callback',{@osp_onPrint,gui});
       set(gui.upperBox.meanOv.box, 'Width', [-0.16 -0.74 -0.1])  
       set(gui.controls.meanOv, 'Width', [-0.85 -0.15])
%op_plotspec is used for a dummy plot which is update later
        gui.layout.shift = 0.5;
        temp = figure( 'Visible', 'off' );
        if gui.load.Selected ==1 %Metabolite data
            if length(gui.process.Names)>1
                temp = op_plotspec(MRSCont.overview.Osprey.(sort_data).(['g_' num2str(1)]).(gui.process.Names{2}),2,1,gui.colormap.cb(1,:),gui.layout.shift*(1-1),['Overview ' gui.layout.proTab.TabTitles{gui.load.Selected}]);
            else
                temp = op_plotspec(MRSCont.overview.Osprey.(sort_data).(['g_' num2str(1)]).(gui.process.Names{1}),2,1,gui.colormap.cb(1,:),gui.layout.shift*(1-1),['Overview ' gui.layout.proTab.TabTitles{gui.load.Selected}]);
            end
        else %Water data?
            temp = op_plotspec(MRSCont.overview.Osprey.(sort_data).(['g_' num2str(1)]).(gui.process.Names{1}),2,1,gui.colormap.cb(1,:),gui.layout.shift*(1-1),['Overview ' gui.layout.proTab.TabTitles{gui.load.Selected}]);
        end
        set(gca, 'YColor', MRSCont.colormap.Background);
        set(gca,'YTickLabel',{})
        set(gca,'YTick',{});
        set(gca,'XColor',MRSCont.colormap.Foreground);
        set(gca,'Color','w');
        set(gcf,'Color','w');
        title(['Overview ' gui.layout.proTab.TabTitles{gui.load.Selected}],'Color', MRSCont.colormap.Foreground);
        ax=get(temp,'Parent');
        if iscell(ax)
            ax = ax{1};
        end
        figpl = get(ax,'Parent');
        ViewAxes = gca();
        drawnow
        set(ViewAxes, 'Parent', gui.Plot.meanOv);
        close( figpl );
        if gui.load.Selected ==1
            set(gui.Plot.meanOv.Children(2), 'XLim', [0.2 4.5])
        else
            set(gui.Plot.meanOv.Children(2), 'XLim', [0 2*4.68])
        end
        osp_updatemeanOvWindow(gui); %Update the plot with the mean and SD
        set(gui.Plot.meanOv,'Heights', [-0.1 -0.9]);

%%% 4. QUANTIFICATION TABLE %%%
        if isfield(gui.quant, 'Number')
            gui.layout.overviewTab.TabEnables = {'on', 'on', 'on', 'on', 'on', 'off'};  
            gui.layout.overviewTab.Selection  = 3;
            gui.Plot.quantOv = uix.VBox('Parent', gui.layout.quantOvTab,'BackgroundColor',gui.colormap.Background,'Padding', 5);

    %Creates Popup menu to change between quantifications (tCr, waterScaled etc.)           
           FitNames = fieldnames(MRSCont.overview.FitSpecNamesStruct);
           l=1;
           if ~isempty(FitNames) 
               for i = 1 : gui.fit.Number                                  
                   for k = 1 :size(MRSCont.overview.FitSpecNamesStruct.(FitNames{i}),2)
                       if isfield(MRSCont.quantify.tables,FitNames{i})
                           for j = 1 : length(fieldnames(MRSCont.quantify.tables.(FitNames{i})))
                               QuantNames = fieldnames(MRSCont.quantify.tables.(FitNames{i}));
                               if ~strcmp(FitNames{i},'ref') && ~strcmp(FitNames{i},'w') && ~strcmp(FitNames{i},'mm')
                                    tempFitNames{l} = [FitNames{i}, '-', MRSCont.overview.FitSpecNamesStruct.(FitNames{i}){1,k}, '-', QuantNames{j}]; 
                                    l=l+1;
                               end
                           end
                       end
                   end
               end
           end
          
           
            tempFitNames{end+1} = 'Quality';
            gui.quant.popMenuNames = tempFitNames;
            gui.upperBox.quantOv.box = uix.HBox('Parent', gui.Plot.quantOv,'BackgroundColor',gui.colormap.Background, 'Spacing',5); 
            gui = upper_navigate_box(gui, 'quantOv','metab',1);
            gui.controls.quantOvPlot = uix.Panel('Parent', gui.upperBox.quantOv.box,'Title', 'Actual Quantification', ...
                                                'Padding', 5,'HighlightColor', gui.colormap.Foreground,'BackgroundColor',gui.colormap.Background,...
                                                'ForegroundColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
            gui.controls.pop_quantOvPlot = uicontrol('Parent',gui.controls.quantOvPlot,'style','popupmenu',...
                                                    'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font, ...
                                                    'String',gui.quant.popMenuNames, 'Value', 1);

    % Quantification table is created based on uicontrol
            if ~(isfield(MRSCont.flags,'isPRIAM') || isfield(MRSCont.flags,'isMRSI')) || ~(MRSCont.flags.isPRIAM || MRSCont.flags.isMRSI)
                gui.Results.quantOv = uix.Panel('Parent', gui.Plot.quantOv, 'Padding', 5, ...
                                                'Title', ['Results: ' (gui.quant.Names.Model{gui.quant.Selected.Model}) '-' (gui.quant.Names.Quants{gui.quant.Selected.Quant})],...
                                                'FontName', gui.font,'HighlightColor', gui.colormap.Foreground,'BackgroundColor',gui.colormap.Background,...
                                                'ForegroundColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
                QuantTextOv = cell(MRSCont.nDatasets(1)+1,length(MRSCont.quantify.names.(gui.quant.Names.Model{gui.quant.Selected.Model}){1,1}));
                QuantTextOv(1,:) = MRSCont.quantify.names.(gui.quant.Names.Model{gui.quant.Selected.Model}){1,1};
                QuantTextOv(2:end,:) = table2cell(MRSCont.quantify.tables.(gui.quant.Names.Model{gui.quant.Selected.Model}).(gui.quant.Names.Quants{gui.quant.Selected.Quant}).Voxel_1{1,1}(:,:));
                temp=uimulticollist ( 'units', 'normalized', 'position', [0 0 1 1], 'string', QuantTextOv,...
                    'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                set(temp,'BackgroundColor',gui.colormap.Background)
                set(temp, 'Parent', gui.Results.quantOv );
                set(gui.Plot.quantOv,'Heights', [-0.10 -0.9]);
            else
                gui.Results.quantOv1 = uix.Panel('Parent', gui.Plot.quantOv, 'Padding', 5, ...
                                                'Title', ['Results Voxel 1: ' (gui.quant.Names.Model{gui.quant.Selected.Model}) '-' (gui.quant.Names.Quants{gui.quant.Selected.Quant})],...
                                                'FontName', gui.font,'HighlightColor', gui.colormap.Foreground,'BackgroundColor',gui.colormap.Background,...
                                                'ForegroundColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
                QuantTextOv = cell(MRSCont.nDatasets+1,length(MRSCont.quantify.metabs.(gui.quant.Names.Model{gui.quant.Selected.Model})));
                QuantTextOv(1,:) = MRSCont.quantify.metabs.(gui.quant.Names.Model{gui.quant.Selected.Model});
                QuantTextOv(2:end,:) = table2cell(MRSCont.quantify.tables.(gui.quant.Names.Model{gui.quant.Selected.Model}).(gui.quant.Names.Quants{gui.quant.Selected.Quant}).Voxel_1(:,:));
                temp=uimulticollist ( 'units', 'normalized', 'position', [0 0 1 1], 'string', QuantTextOv,...
                    'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                set(temp,'BackgroundColor',gui.colormap.Background)
                set(temp, 'Parent', gui.Results.quantOv1 );

                gui.Results.quantOv2 = uix.Panel('Parent', gui.Plot.quantOv, 'Padding', 5, ...
                                                'Title', ['Results Voxel 2: ' (gui.quant.Names.Model{gui.quant.Selected.Model}) '-' (gui.quant.Names.Quants{gui.quant.Selected.Quant})],...
                                                'FontName', gui.font,'HighlightColor', gui.colormap.Foreground,'BackgroundColor',gui.colormap.Background,...
                                                'ForegroundColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
                QuantTextOv = cell(MRSCont.nDatasets+1,length(MRSCont.quantify.metabs.(gui.quant.Names.Model{gui.quant.Selected.Model})));
                QuantTextOv(1,:) = MRSCont.quantify.metabs.(gui.quant.Names.Model{gui.quant.Selected.Model});
                QuantTextOv(2:end,:) = table2cell(MRSCont.quantify.tables.(gui.quant.Names.Model{gui.quant.Selected.Model}).(gui.quant.Names.Quants{gui.quant.Selected.Quant}).Voxel_2(:,:));
                temp=uimulticollist ( 'units', 'normalized', 'position', [0 0 1 1], 'string', QuantTextOv,...
                    'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                set(temp,'BackgroundColor',gui.colormap.Background)
                set(temp, 'Parent', gui.Results.quantOv2 );

                set(gui.Plot.quantOv,'Heights', [-0.10 -0.45 -0.45]);
            end
               set(gui.upperBox.quantOv.box, 'Width', [-0.16 -0.84])  
    %%% 5. RAINCLOUD PLOTS %%%
            gui.layout.overviewTab.Selection  = 4;
            gui.Plot.distrOv = uix.VBox('Parent', gui.layout.distrOvTab, 'BackgroundColor',gui.colormap.Background,'Padding', 5);

    %Creates popup menus for differnt quantifications and metabolites
            gui.upperBox.distrOv.box = uix.HBox('Parent', gui.Plot.distrOv,'BackgroundColor',gui.colormap.Background, 'Spacing',5); 
            gui = upper_navigate_box(gui, 'distrOv','metab',1);
            
            if  (isfield(MRSCont.flags, 'isPRIAM') || isfield(MRSCont.flags, 'isMRSI')) &&  (MRSCont.flags.isPRIAM || MRSCont.flags.isMRSI)
                    gui.upperBox.distrOv.upperLeftButtons = uix.Panel('Parent', gui.upperBox.distrOv.box, ...
                                             'Padding', 5, 'Title', ['Navigate voxel'],...
                                             'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground,...
                                             'HighlightColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
                    gui.controls.Buttonbox = uix.HBox('Parent',gui.upperBox.distrOv.upperLeftButtons, 'BackgroundColor',gui.colormap.Background);
                    gui.controls.navigate_RawTab = uix.Grid('Parent',gui.controls.Buttonbox,'BackgroundColor',gui.colormap.Background);
                    gui.controls.text_x = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','X:',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.text_y = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','Y:',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.text_z = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','Z:',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.b_left_x = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','<');
                    gui.controls.b_left_y = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','<');
                    gui.controls.b_left_z = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','<');
                    set(gui.controls.b_left_x,'Callback',{@osp_onLeftX,gui});
                    set(gui.controls.b_left_y,'Callback',{@osp_onLeftY,gui});
                    set(gui.controls.b_left_z,'Callback',{@osp_onLeftZ,gui});
                    if gui.info.nXvoxels <= 1
                        gui.controls.b_left_x.Enable = 'off';
                    end
                    if gui.info.nYvoxels <= 1
                        gui.controls.b_left_y.Enable = 'off';
                    end
                    if gui.info.nZvoxels <= 1
                        gui.controls.b_left_z.Enable = 'off';
                    end
                    gui.controls.text_act_x = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','1',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.text_act_y = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','1',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.text_act_z = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','1',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.b_right_x = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','>');
                    gui.controls.b_right_y = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','>');
                    gui.controls.b_right_z = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','>');
                    set(gui.controls.b_right_x,'Callback',{@osp_onRightX,gui});
                    set(gui.controls.b_right_y,'Callback',{@osp_onRightY,gui});
                    set(gui.controls.b_right_z,'Callback',{@osp_onRightZ,gui});
                    if gui.info.nXvoxels <= 1
                        gui.controls.b_right_x.Enable = 'off';
                    end
                    if gui.info.nYvoxels <= 1
                        gui.controls.b_right_y.Enable = 'off';
                    end
                    if gui.info.nZvoxels <= 1
                        gui.controls.b_right_z.Enable = 'off';
                    end  
                    set( gui.controls.navigate_RawTab, 'Widths', [-20 -30 -20 -30], 'Heights', [-33 -33 -33] );
            end
            gui.controls.distrOvPanel = uix.Panel('Parent', gui.upperBox.distrOv.box,'Title', ['Actual Quantification and Metabolite in Voxel ' num2str(gui.controls.act_x)], ...
                                                 'Padding', 5,'HighlightColor', gui.colormap.Foreground,'BackgroundColor',gui.colormap.Background,...
                                                 'ForegroundColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
            gui.controls.distrOv = uix.HBox('Parent', gui.controls.distrOvPanel,...
                                           'Padding', 5, 'Spacing', 10,'BackgroundColor',gui.colormap.Background);
            gui.controls.pop_distrOvQuant = uicontrol('Parent',gui.controls.distrOv,'style','popupmenu',...
                                                     'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font,...
                                                     'String',gui.quant.popMenuNames, 'Value', 1);
            gui.controls.pop_distrOvMetab = uicontrol('Parent',gui.controls.distrOv,'style','popupmenu',...
                                                     'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font, ...
                                                     'String',MRSCont.quantify.names.(gui.quant.Names.Model{gui.quant.Selected.Model}){1,1}, 'Value', 1);
           gui.controls.check_distrOv = uicontrol('Parent',gui.controls.distrOv,'Style','checkbox','BackgroundColor',gui.colormap.Background,'String','Grand Mean', ...
                                                        'Value',gui.controls.GM,'Position',[0 0 1 1],'FontName', gui.font);                                         
           gui.upperBox.distrOv.upperButtons = uix.Panel('Parent', gui.upperBox.distrOv.box, ...
                                         'Padding', 5, 'Title', ['Save'],...
                                         'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground,...
                                         'HighlightColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);                                            
           gui.controls.b_save_distrOvTab = uicontrol('Parent',gui.upperBox.distrOv.upperButtons,'Style','PushButton');
           [img, ~, ~] = imread('Printer.png', 'BackgroundColor', gui.colormap.Background);
           [img2] = imresize(img, 0.05);
           set(gui.controls.b_save_distrOvTab,'CData', img2, 'TooltipString', 'Create EPS figure from current file');
           set(gui.controls.b_save_distrOvTab,'Callback',{@osp_onPrint,gui});
           
           set(gui.upperBox.distrOv.box, 'Width', [-0.16 -0.74 -0.1])   


    %osp_plotQuantifyTable to create distribution overview as raincloud plot
            temp = figure( 'Visible', 'off' );
            [temp] = osp_plotRaincloud(MRSCont,MRSCont.overview.FitSpecNamesStruct.metab{gui.quant.Selected.Model}, gui.quant.Names.Quants{gui.quant.Selected.Quant},MRSCont.quantify.names.metab{gui.quant.Selected.Model}{gui.overview.Selected.Metab},'Raincloud plot',0,1);
            ViewAxes = gca();
            set(ViewAxes, 'Parent', gui.Plot.distrOv);
            close( temp );
            set(gui.Plot.distrOv,'Heights', [-0.1 -0.87 -0.03]);
            gui.Plot.distrOv.Children(3).Legend.Location = 'North';
            set(gui.controls.distrOv, 'Width', [-0.42 -0.42 -0.15])

     %%% 6. CORRELATION PLOTS %%%

            gui.layout.overviewTab.Selection  = 5;
            gui.Plot.corrOv = uix.VBox('Parent', gui.layout.corrOvTab,'BackgroundColor',gui.colormap.Background,'Padding', 5);
     %%%%%%%%%%%%%%%%%%DATA CONTROLS FOR THIS TAB%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Creates popup menu for differnt quantification, metabolite and
    % correaltion measure
            gui.upperBox.corrOv.box = uix.HBox('Parent', gui.Plot.corrOv,'BackgroundColor',gui.colormap.Background, 'Spacing',5); 
            gui = upper_navigate_box(gui, 'corrOv','metab',1);
            
            if  (isfield(MRSCont.flags, 'isPRIAM') || isfield(MRSCont.flags, 'isMRSI')) &&  (MRSCont.flags.isPRIAM || MRSCont.flags.isMRSI)
                    gui.upperBox.corrOv.upperLeftButtons = uix.Panel('Parent', gui.upperBox.corrOv.box, ...
                                             'Padding', 5, 'Title', ['Navigate voxel'],...
                                             'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground,...
                                             'HighlightColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
                    gui.controls.Buttonbox = uix.HBox('Parent',gui.upperBox.corrOv.upperLeftButtons, 'BackgroundColor',gui.colormap.Background);
                    gui.controls.navigate_RawTab = uix.Grid('Parent',gui.controls.Buttonbox,'BackgroundColor',gui.colormap.Background);
                    gui.controls.text_x = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','X:',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.text_y = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','Y:',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.text_z = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','Z:',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.b_left_x = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','<');
                    gui.controls.b_left_y = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','<');
                    gui.controls.b_left_z = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','<');
                    set(gui.controls.b_left_x,'Callback',{@osp_onLeftX,gui});
                    set(gui.controls.b_left_y,'Callback',{@osp_onLeftY,gui});
                    set(gui.controls.b_left_z,'Callback',{@osp_onLeftZ,gui});
                    if gui.info.nXvoxels <= 1
                        gui.controls.b_left_x.Enable = 'off';
                    end
                    if gui.info.nYvoxels <= 1
                        gui.controls.b_left_y.Enable = 'off';
                    end
                    if gui.info.nZvoxels <= 1
                        gui.controls.b_left_z.Enable = 'off';
                    end
                    gui.controls.text_act_x = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','1',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.text_act_y = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','1',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.text_act_z = uicontrol(gui.controls.navigate_RawTab,'Style','text','String','1',...
                        'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground);
                    gui.controls.b_right_x = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','>');
                    gui.controls.b_right_y = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','>');
                    gui.controls.b_right_z = uicontrol(gui.controls.navigate_RawTab,'Style','PushButton', 'BackgroundColor',gui.colormap.Background,'String','>');
                    set(gui.controls.b_right_x,'Callback',{@osp_onRightX,gui});
                    set(gui.controls.b_right_y,'Callback',{@osp_onRightY,gui});
                    set(gui.controls.b_right_z,'Callback',{@osp_onRightZ,gui});
                    if gui.info.nXvoxels <= 1
                        gui.controls.b_right_x.Enable = 'off';
                    end
                    if gui.info.nYvoxels <= 1
                        gui.controls.b_right_y.Enable = 'off';
                    end
                    if gui.info.nZvoxels <= 1
                        gui.controls.b_right_z.Enable = 'off';
                    end  
                    set( gui.controls.navigate_RawTab, 'Widths', [-20 -30 -20 -30], 'Heights', [-33 -33 -33] );
            end
            gui.controls.corrOvPanel = uix.Panel('Parent', gui.upperBox.corrOv.box,'Title', ['Actual Quantification, Metabolite, and Correlation Measure in Voxel ' num2str(gui.controls.act_x)], ...
                                                'Padding', 5,'HighlightColor', gui.colormap.Foreground,'BackgroundColor',gui.colormap.Background,...
                                                'ForegroundColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);
            gui.controls.corrOv = uix.HBox('Parent', gui.controls.corrOvPanel,'Padding', 5, 'Spacing', 10,'BackgroundColor',gui.colormap.Background);
            gui.controls.pop_corrOvQuant = uicontrol('Parent',gui.controls.corrOv,'style','popupmenu',...
                                                    'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font,...
                                                    'String',gui.quant.popMenuNames, 'Value', 1);
            gui.controls.pop_corrOvMetab = uicontrol('Parent',gui.controls.corrOv,'style','popupmenu',...
                                                    'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font, ...
                                                    'String',MRSCont.quantify.names.(gui.quant.Names.Model{gui.quant.Selected.Model}){1,1}, 'Value', 1);
            gui.controls.pop_corrOvCorr = uicontrol('Parent',gui.controls.corrOv,'style','popupmenu',...
                                                   'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font, ...
                                                   'String',gui.overview.Names.QM, 'Value', 1); 
           if isfield(MRSCont.overview,'corr')
                gui.controls.pop_whichcorrOvCorr = uicontrol('Parent',gui.controls.corrOv,'style','popupmenu',...
                                               'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font, ...
                                               'String',{'QM','metabolites','MRSCont.overview.corr'}, 'Value', 1);   
           else
                gui.controls.pop_whichcorrOvCorr = uicontrol('Parent',gui.controls.corrOv,'style','popupmenu',...
                                               'Units', 'Normalized', 'Position', [0 0 1 1],'FontName', gui.font, ...
                                               'String',{'QM','metabolites'}, 'Value', 1);              
           end
           gui.upperBox.corrOv.upperButtons = uix.Panel('Parent', gui.upperBox.corrOv.box, ...
                                         'Padding', 5, 'Title', ['Save'],...
                                         'FontName', gui.font, 'BackgroundColor',gui.colormap.Background,'ForegroundColor', gui.colormap.Foreground,...
                                         'HighlightColor', gui.colormap.Foreground, 'ShadowColor', gui.colormap.Foreground);                                            
           gui.controls.b_save_corrOvTab = uicontrol('Parent',gui.upperBox.corrOv.upperButtons,'Style','PushButton');
           [img, ~, ~] = imread('Printer.png', 'BackgroundColor', gui.colormap.Background);
           [img2] = imresize(img, 0.05);
           set(gui.controls.b_save_corrOvTab,'CData', img2, 'TooltipString', 'Create EPS figure from current file');
           set(gui.controls.b_save_corrOvTab,'Callback',{@osp_onPrint,gui});
           
           set(gui.upperBox.corrOv.box, 'Width', [-0.16 -0.74 -0.1])   


        %%%%%%%%%%%%%%%%%%VISUALIZATION PART OF THIS TAB%%%%%%%%%%%%%%%%%%%%%%%%
        %osp_plotQuantifyTable is used to create a correlation plot
                temp = figure( 'Visible', 'off' );
                if ~(isfield(MRSCont.flags,'isPRIAM') || isfield(MRSCont.flags,'isMRSI')) || ~(MRSCont.flags.isPRIAM || MRSCont.flags.isMRSI)
                    [temp] = osp_plotScatter(MRSCont, MRSCont.overview.FitSpecNamesStruct.(FitNames{1}){1,1}, gui.quant.Names.Quants{gui.quant.Selected.Quant},MRSCont.quantify.names.(gui.quant.Names.Model{gui.quant.Selected.Model}){1,1}{gui.overview.Selected.Metab},MRSCont.QM.SNR.metab(1,:,1)',gui.overview.Names.QM{gui.overview.Selected.Corr});
                elseif isfield(MRSCont.flags,'isPRIAM')  && MRSCont.flags.isPRIAM
                    [temp] = osp_plotScatter(MRSCont, MRSCont.overview.FitSpecNamesStruct.(FitNames{1}){1,1}, gui.quant.Names.Quants{gui.quant.Selected.Quant},MRSCont.quantify.names.(gui.quant.Names.Model{gui.quant.Selected.Model}){gui.overview.Selected.Metab},MRSCont.QM{1,gui.controls.act_x}.SNR.A(1,:,1)',gui.overview.Names.QM{gui.overview.Selected.Corr},1);
                end
                ViewAxes = gca();
                drawnow
                set(ViewAxes, 'Parent', gui.Plot.corrOv);
                set(gui.Plot.corrOv,'Heights', [-0.1 -0.87 -0.03]);
                gui.Plot.corrOv.Children(3).Legend.Location = 'North';
                close( temp );
        end
        gui.layout.overviewTab.Selection  = 2;
        h = findall(groot,'Type','figure');
        for ff = 1 : length(h)
            if ~(strcmp(h(ff).Tag, 'Osprey') ||  strcmp(h(ff).Tag, 'TMWWaitbar'))
                close(h(ff))
            end
        end        
        setappdata(gui.figure,'MRSCont',MRSCont); % Write MRSCont into hidden container in gui class
end
