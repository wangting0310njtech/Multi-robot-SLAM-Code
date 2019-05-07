
% disp(['************************************************************************']);
% disp(['**************************** Original RPSO ***************************']);
% disp(['**pobs=0.18****ps=0.42*****pc=0.42****']);
SimNbr=1;

while (SimNbr<31)
    disp(['sim n ' num2str(SimNbr)]);
    simviewcb load
    simviewcb sim
    simviewcb stop
    SimNbr = SimNbr+1;
end

% disp(['**********************************************************************']);
% disp(['**********2222******************* RPSO *******************************']);
% disp(['**********************************************************************']);
% SimNbr=1;
% while (SimNbr<2)
%     disp(['simulation RPSO numero ' num2str(SimNbr) '   ++++++++++++++++++++']);
%     simviewcbRPSO load
%     simviewcbRPSO sim
%     simviewcbRPSO stop
%     SimNbr = SimNbr+1;
% end
% 
% disp(['**********************************************************************']);
% disp(['**********3333*** Our Democratic RPSO w/o threshold ******************']);
% disp(['**********************************************************************']);
% SimNbr=1;
% while (SimNbr<2)
%     disp(['simulation DRPSO sans seuil numero ' num2str(SimNbr) '   ++++++++++++++++++++']);
%     simviewcbMyDRPSO1	load
%     simviewcbMyDRPSO1 sim
%     simviewcbMyDRPSO1 stop
%     SimNbr = SimNbr+1;
% end
% 
% disp(['**********************************************************************']);
% disp(['**********4444* Our Democratic RPSO using threshold ******************']);
% disp(['**********************************************************************']);
% SimNbr=1;
% while (SimNbr<2)
%     disp(['simulation DRPSO avec seuil numero ' num2str(SimNbr) '   ++++++++++++++++++++']);
%     simviewcbMyDRPSO2 load
%     simviewcbMyDRPSO2 sim
%     simviewcbMyDRPSO1 stop
%     SimNbr = SimNbr+1;
% end

disp(['****:)**-_-**:)**-_-**:)**-_-**:)**-_-**:)**-_-**:)**-_-**:)**-_-*****']);
disp(['******************* Simulations end successfully *********************']);
disp(['****:)**-_-**:)**-_-**:)**-_-**:)**-_-**:)**-_-**:)**-_-**:)**-_-*****']);