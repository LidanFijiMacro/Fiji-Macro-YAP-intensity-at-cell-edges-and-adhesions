macro "YAP_Vinculin colocalization" {
	// Parameters
	cleanup_flag = 1;
	batchModeFlag = false;
	
	// Ask the user to choose input folder 
	input_dir = getDirectory("Choose a directory");

	//  Create output folder
	res_dir = input_dir + "z_Res" + File.separator;
	File.makeDirectory(res_dir);

	setBatchMode(batchModeFlag);
	startTime = getTime();
	list = getFileList(input_dir);
	for (n = 0; n < list.length; n++)
	{
		if (indexOf(list[n], "Airy") >= 0) 
		{
			// clean-up for the next time
			run("Close All");
			run("Clear Results");	
		    roiManager("reset"); 	
		   // Report Progress
			showProgress(n+1, list.length);
			n_for_print = n+1;
			//print("processing file "+n_for_print+"/"+list.length+": "+list[n]);
			print("processing file "+n_for_print+": "+list[n]);

			name = list[n];
			filename = input_dir+name;			
			run("Set Measurements...", "area mean min center perimeter fit shape integrated display redirect=None decimal=2");		
			run("Bio-Formats Importer", "open=[" + filename +"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
			name_no_ext = File.nameWithoutExtension();
			
			selectWindow(name);

			rename("cell");				
			Stack.setActiveChannels("111");
			setSlice(1);
			//run("Brightness/Contrast...");
			run("Enhance Contrast", "saturated=0.35");
			setSlice(2);
			//run("Brightness/Contrast...");
			run("Enhance Contrast", "saturated=0.35");
			setSlice(3);
			//run("Brightness/Contrast...");
			run("Enhance Contrast", "saturated=0.35");			
			run("Stack to RGB");
			run("8-bit");
			//run("Brightness/Contrast...");
			run("Enhance Contrast", "saturated=0.35");
			//run("Enhance Contrast", "saturated=0.35");
			run("Apply LUT");
			//setAutoThreshold("IsoData dark");
			//run("Threshold...");
			setAutoThreshold("Li dark");
			//setThreshold(32, 255);
			setOption("BlackBackground", false);
			run("Convert to Mask");
			run("Fill Holes");
			selectWindow("cell (RGB)");
			rename("cell_mask");
			selectWindow("cell");
			run("Duplicate...", "title=YAP duplicate channels=1");
			selectWindow("cell");
			run("Duplicate...", "title=vinc duplicate channels=2");
			selectWindow("vinc");
			run("Duplicate...", "title=vinc1 duplicate channels=1");
			setAutoThreshold("IJ_IsoData dark");
			run("Convert to Mask");
			
			run("Create Selection");
			selectWindow("vinc");
			run("Restore Selection");
			setBackgroundColor(0, 0, 0);
			run("Clear Outside");
			selectWindow("cell_mask");
			run("Select None");
			run("Analyze Particles...", "size=100-Infinity show=Masks add");
			run("Clear Results");	
			selectWindow("Mask of cell_mask");
			selectWindow("vinc");
			roiManager("Select", 0);
			run("Clear Outside");
			run("Enlarge...", "enlarge=-1.5");
			run("Clear", "slice");
			run("Select None");		
			
			
			selectWindow("YAP");
			run("Duplicate...", " ");
			setAutoThreshold("IJ_IsoData dark");
			//run("Threshold...");
			setOption("BlackBackground", false);
			run("Convert to Mask");
			
			run("Create Selection");
			selectWindow("YAP");
			run("Restore Selection");
			setBackgroundColor(0, 0, 0);
			run("Clear Outside");
			roiManager("Select", 0);
			run("Clear Outside");
			run("Enlarge...", "enlarge=-1.5");
			run("Clear", "slice");
			print("\\Clear");
			run("Select None");			
			
			run("JACoP ", "imga=vinc imgb=YAP thra=55500 thrb=55500 manders mm");			
			selectWindow("Log");
			temp_log = getInfo("log");
			split_output = split(temp_log, " \t\n\r");			
			M1 = split_output[10];			
			M_1 = replace(M1, "M1=", "");
			M2=split_output[16];
			M_2 = replace(M2, "M2=", "");
			setResult("Image", 0, name_no_ext);
			setResult("M1", 0, M_1);
			setResult("M2", 0, M_2);
			saveAs("Results", res_dir+name_no_ext+".csv");
			run("Clear Results");
			} // if loop ends						
		} //for loop ends
		
	
	roiManager("Delete");			
    run("Close All");
	print("Done");
	// Cleanup
   
	endTime = getTime();
	//diffTime=endTime-startTime;
	diffTime=d2s((endTime-startTime)/1000,2)
	setBatchMode(false);
	print("Batch="+batchModeFlag+", diffTime="+diffTime+", startTime="+startTime+", endTime="+endTime);
	
} // end of macro



