macro "YAP_intensity_at_adhesions" {
	// Parameters
	cleanup_flag = 1;
	batchModeFlag = false;
	
	// Ask the user to choose input folder 
	input_dir = getDirectory("Choose a directory");

	//  Create output folder
	res_dir_line = input_dir + "Res_LineScan" + File.separator;

	File.makeDirectory(res_dir_line);
	

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
////////  Notes: 1. make masks for whole cell based on the RGB color of three channels, and measure YAP Y357, vinculin, total YAP intensity.           
/////////////////// Making MASKS PART/////////////////////////////////////////			
			Stack.setActiveChannels("11");
			setSlice(1);
			run("Enhance Contrast", "saturated=0.35");
			setSlice(2);
			run("Enhance Contrast", "saturated=0.35");
			
			selectWindow("cell");
			run("Stack to RGB");
			run("8-bit");
			setAutoThreshold("Li dark");
			setOption("BlackBackground", false);
			run("Convert to Mask");
			run("Fill Holes");
		    run("Analyze Particles...", "size=200-Infinity show=Masks add");
			selectWindow("Mask of cell (RGB)");
			run("Duplicate...", "title=CellMaskforSaving");	
			saveAs("Tiff", res_dir_line+name_no_ext+"_Cells.tif");			
			close();
			selectWindow("Mask of cell (RGB)");
			run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1.0000000");            			
			selectWindow("Mask of cell (RGB)");
/////////////////// Making MASKS PART over/////////////////////////////////////////	

/////////////////// Line scanning PART starts/////////////////////////////////////////				
			setBackgroundColor(0, 0, 0);
			no_of_ROIs = roiManager("count");
			print("No. of ROIs whole cell:" +no_of_ROIs);			
			for (k = 0; k < no_of_ROIs; k++) {
			selectWindow("cell");
			run("Duplicate...", "duplicate");
			run("Select None");
			roiManager("Select", k);
			run("Clear Outside");
								
			selectWindow("Mask of cell (RGB)");
			run("Select None");
			roiManager("Select", k);
			roiManager("Measure");								
			Xc = Table.get("XM", 0);
			Yc = Table.get("YM", 0);
			Major_axis = Table.get("Major", 0);
			run("Line Width...", "line=10");
			makeLine(Xc, Yc - Major_axis/2 - 300, Xc, Yc + Major_axis/2 + 300);
			selectWindow("cell-1");
			run("Restore Selection");
			for (rotation_time = 0; rotation_time < 12; rotation_time++)
			{
			    setSlice(1);
				run("Clear Results");
				profile = getProfile();
				for (i=0; i<profile.length; i++)
				  setResult("Value", i, profile[i]);
				  updateResults;		
				  saveAs("Results", res_dir_line+name_no_ext+"_"+k+1+"_pYAP"+rotation_time+1+".csv");
				
				
				print("rotation_time="+rotation_time+1);
			  run("Rotate...", "  angle=15"); //wait(200);
					}	//rotation loop ends
					print("k="+k);
					selectWindow("cell-1");
					close();
					//wait(1500);				
				} // end of roi loop
			} // if loop ends
		} //for loop ends
	roiManager("Delete");			
    run("Close All");
	print("Done");
    run("Clear Results");
	// Cleanup

	endTime = getTime();
	//diffTime=endTime-startTime;
	diffTime=d2s((endTime-startTime)/1000,2)
	setBatchMode(false);
	print("Batch="+batchModeFlag+", diffTime="+diffTime+", startTime="+startTime+", endTime="+endTime);
	
} // end of macro