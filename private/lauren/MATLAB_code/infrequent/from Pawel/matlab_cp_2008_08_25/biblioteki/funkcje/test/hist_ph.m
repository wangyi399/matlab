function y=hist_ph(dane,n,fontsize);

if nargin==1 
	hist(dane);
else
	hist(dane,n);
end

h=gca;
if nargin>2
	if fontsize
		set(h,'FontSize',fontsize);
	end
end
	
xl=get(h,'XLim');
tx=xl(1)+(xl(2)-xl(1))*0.82;
yl=get(h,'YLim');
ty=yl(1)+(yl(2)-yl(1))*0.82;

h=text(tx,ty,['mean:' num2str(mean(dane),4)]);
if nargin>2
	if fontsize
		set(h,'FontSize',fontsize);
	end
end

h=text(tx,ty*0.85,['sd:' num2str(std(dane)/mean(dane)*100,'%3.1f') '%']);
if nargin>2
	if fontsize
		set(h,'FontSize',fontsize);
	end
end

grid on;
