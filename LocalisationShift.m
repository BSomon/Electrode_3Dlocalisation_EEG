[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
StandLoc = readlocs('Template.ced'); %load the template !!CED!! file
nElec = 16; %The number of electrodes in your setup
StandFields = fieldnames(StandLoc);
StandFields = StandFields(2:end, :);
StandRef = squeeze(struct2cell(StandLoc(end-2:end)));%3 last lines are fiducials
StandRef = cell2mat(StandRef(4:6,:));
StandLoc = squeeze(struct2cell(StandLoc(1:nElec))); 
StandLoc = cell2mat(StandLoc(2:end,:));

AllLoc = []; %Localisation sujet par sujet
SubjFields = []; %Champs des localisation sujet par sujet car ordre différents de champs dans localisation standard
SubjRef = [];
DiffLoc = [];
DiffLoc_norm = [];
DiffLoc_StandLoc = [];
ceSubj = {};
lim = [];

foDir = dir;
for iFolder = 1:size(foDir,1)
	if exist(fullfile(foDir(iFolder).folder, foDir(iFolder).name, [foDir(iFolder).name, '.ced']), 'file')
			SubjLoc = readlocs(fullfile(foDir(iFolder).folder, foDir(iFolder).name, [foDir(iFolder).name, '.ced']));
			SubjFields = cat(3, SubjFields, fieldnames(SubjLoc));
			Ref = squeeze(struct2cell(SubjLoc(20:end)));
			[~,idx] = sort(Ref(1,:));
			Ref=Ref(:,idx);
			SubjRef = cat(3,SubjRef,cell2mat(Ref(2:9,:)));
			SubjLoc = squeeze(struct2cell(SubjLoc(1:16)));
			AllLoc = cat(3, AllLoc, cell2mat(SubjLoc(2:end,:)));
			ceSubj = cat(1, ceSubj, foDir(iFolder).name);
	end
end

StandLoc = StandLoc([3 4 5 6 7 8 1 2],:);
StandRef = [StandRef(1,3); StandRef(2,1); max(abs(StandLoc(3,:)))];
StandLoc_norm = StandLoc([1:3],:)./StandRef;
AllLoc = AllLoc([[3 4 5 6 7 8 1 2]],:,:);

colors = colorcube(size(AllLoc,3));
figure
hold on;
% normalisation avec les valeurs de fiducials
Allxyz(1,:,:) =  AllLoc(1,:,:)./SubjRef(3,2,:);
Allxyz(2,:,:) =  AllLoc(2,:,:)./SubjRef(4,1,:);
Allxyz(3,:,:) =  AllLoc(3,:,:)./max(abs(AllLoc(3,:,:)));
%Nomalisation avec le maximum
Allxyz_bis =  AllLoc(1:3,:,:)./repmat(max(abs(AllLoc(1:3,:,:)),[],2),1,nElec,1);
StandLoc_norm_bis = StandLoc(1:3,:)./repmat(max(abs(StandLoc(1:3,:)),[],2),1,nElec,1);
Norm = sqrt(sum((Allxyz(1:3,:,:)-StandLoc_norm).^2));
Norm_bis = sqrt(sum((Allxyz_bis-StandLoc_norm_bis).^2));
for iSubj = 1:size(Allxyz,3)
	plotchans3d_compare(Allxyz_bis(1:3,:,iSubj)',[],[], colors(iSubj,:))
end
plotchans3d_compare(StandLoc_norm_bis(1:3,:)',[],[],'r')

% plot3([0.08 0.12],[0 0],[0 0],'r','LineWidth',4) % nose
plot3([0 1],[0 0],[0 0],'b--')                 % axis
plot3([0 0],[0 1],[0 0],'g--')
plot3([0 0],[0 0],[0 1],'r--')
plot3(0,0,0,'b+')
text(1.5,0,0,'X','HorizontalAlignment','center',...
'VerticalAlignment','middle','Color',[0 0 0],...
'FontSize',10)
text(0,1.5,0,'Y','HorizontalAlignment','center',...
'VerticalAlignment','middle','Color',[0 0 0],...
'FontSize',10)
text(0,0,1.5,'Z','HorizontalAlignment','center',...
'VerticalAlignment','middle','Color',[0 0 0],...
'FontSize',10)
box on
legend(cat(1,ceSubj,'Reference'))

figure
for iSubj = 1:size(Allxyz,3)
	plotchans3d_compare(AllLoc(1:3,:,iSubj)',[],[],colors(iSubj,:))
	lim = cat(1,lim, max(AllLoc(1:3,:,iSubj)'));
end
plotchans3d_compare(StandLoc(1:3,:)',[],[],'r')
plot3([0 max(lim(:,1))],[0 0],[0 0],'b--')                 % axis
plot3([0 0],[0 max(lim(:,2))],[0 0],'g--')
plot3([0 0],[0 0],[0 max(lim(:,3))],'r--')
plot3(0,0,0,'b+')
text(1.05*max(lim(:,1)),0,0,'X','HorizontalAlignment','center',...
'VerticalAlignment','middle','Color',[0 0 0],...
'FontSize',10)
text(0,1.05*max(lim(:,2)),0,'Y','HorizontalAlignment','center',...
'VerticalAlignment','middle','Color',[0 0 0],...
'FontSize',10)
text(0,0,1.05*max(lim(:,3)),'Z','HorizontalAlignment','center',...
'VerticalAlignment','middle','Color',[0 0 0],...
'FontSize',10)
box on
legend(cat(1,ceSubj,'Reference'))

for iElec = 1:(nElec-1)
	DiffLoc = cat(1, DiffLoc, sqrt(sum((AllLoc(1:3,iElec,:)-AllLoc(1:3, iElec+1,:)).^2)));
    DiffLoc_norm = cat(1, DiffLoc_norm, sqrt(sum((Allxyz(1:3,iElec,:)-Allxyz(1:3, iElec+1,:)).^2)));
	DiffLoc_StandLoc = cat(1, DiffLoc_StandLoc, sqrt(sum((StandLoc(1:3,iElec)-StandLoc(1:3, iElec+1)).^2)));
end
mLoc = mean(AllLoc,3);
[h2,p2,c2,s2] = ttest(squeeze(Norm)');
t2 = {h2, p2, s2};
[h4,p4,c4,s4] = ttest(squeeze(DiffLoc)');
t4 = {h4, p4, s4};

Localisation = struct('Fields', {SubjFields([4:9,2,3],:,1)}, 'Loc_init', AllLoc, ...
	'Loc_stand', StandLoc, 'Loc_norm', Allxyz, 'Loc_norm_max', Allxyz_bis,...
	'Dist_interelec', DiffLoc, 'Dist_interelec_norm', DiffLoc_norm, 'Dist_ref', Norm);
t_tests = struct('Dist_interelec', t4, 'Dist_to_ref', t2);
save('Localisation.mat', 'Localisation', 't_tests')


	function  plotchans3d_compare(elpfile, arg2, arg3, arg4)
	zs = [];
	X = elpfile(:,1)';
	Y = elpfile(:,2)';
	Z = elpfile(:,3)';
	if nargin > 1
		elocname = arg2;
	else 
		elocname = [];
	end
	if nargin > 2
		zs = arg3;
	end


	if isempty(zs)
	zs = [1:length(elocname)];
	end
  
	lim=1.2;
	eps=lim/20;
	plot3(X,Y,Z, '+', 'color', arg4)
	hold on

	if ~isempty(elocname)
	plot3(X(zs),Y(zs),Z(zs),'b*')
	end

	if ~isempty(elocname)
	for i = 1:length(zs)
		text(X(zs(i)),Y(zs(i)),Z(zs(i))+eps,elocname(zs(i)),'HorizontalAlignment','center',...
			 'VerticalAlignment','middle','Color',[0 0 0],...
			 'FontSize',10)
	end
	end

	axis([-lim lim -lim lim -lim lim])
	axis equal;
	set(gca, 'LineWidth', 1, 'FontSize', 18, 'BoxStyle', 'full')
	rotate3d on
	set(gcf, 'Color', [1 1 1])
	end


