function Types=NS_ClusterAndPrint(StimElectrodes,RecElectrodes,Movies,BadElectrodes,ReadPath,FileName,WritePath,NumberOfClusters,ClustersForDiff,TracesNumbers,FigureProperties);

for i=StimElectrodes
    for j=Movies
        [Types,TypesNew,EIs,Traces]=NS_PCA_test_function_meeting(i,j,RecElectrodes,BadElectrodes,ReadPath,FileName,WritePath,NumberOfClusters,ClustersForDiff,TracesNumbers,FigureProperties);
        %clear;
    end
end