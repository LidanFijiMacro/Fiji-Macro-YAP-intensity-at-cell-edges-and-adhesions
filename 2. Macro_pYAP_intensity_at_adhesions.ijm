macro "analyze adhesions with watershed" {
	 run("Close All");
	
	// Parameters
	cleanup_flag = 1;
	batchModeFlag = false;

	run("Set Measurements...", "area mean min center bounding shape feret's redirect=None decimal=3");
	
	// Ask the user to choose input folder 
	input_dir = getDirectory("Choose a directory");

	//  Create output folder
	res_dir_pYAP = input_dir + "pYAP_adhesion" + File.separator;	
	File.makeDirectory(res_dir_pYAP);
	
	
	setBatchMode(batchModeFlag);
	startTime = getTime();
	list = getFileList(input_dir);
	for (n = 0; n < list.length; n++)
	{
		if (indexOf(list[n], "Airy") >= 0) 
		{
			// Report Progress
			showProgress(n+1, list.length);
			n_for_print = n+1;
			//print("processing file "+n_for_print+"/"+list.length+": "+list[n]);
			print("processing file "+n_for_print+": "+list[n]);

			name = list[n];
			filename = input_dir+name;
	
			run("Set Measurements...", "area mean min center shape feret's redirect=None decimal=3");
			//open(filename);
			run("Bio-Formats Importer", "open=[" + filename +"] autoscale color_mode=Colorized view=Hyperstack stack_order=XYCZT");
			name_no_ext = File.nameWithoutExtension();
			selectWindow(name);



run("Clear Results");
roiManager("reset");
print("\\Clear");
run("Set Measurements...", "area mean min center perimeter fit shape integrated clear redirect=None decimal=2");	
//////////// cell mask////

rename("cell");
run("Duplicate...", "title=cell_mask duplicate channels=1-3");
setSlice(1);
run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");
setSlice(2);
run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");
setSlice(3);
run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");
//setSlice(4);
//run("Enhance Contrast", "saturated=0.35");
//run("Enhance Contrast", "saturated=0.35");
run("Split Channels");
run("Merge Channels...", "c1=C1-cell_mask c2=C2-cell_mask c3=C3-cell_mask create");
run("Stack to RGB");
selectWindow("cell_mask");
close();
selectWindow("cell_mask (RGB)");
rename("cell_mask1");
//run("Brightness/Contrast...");
run("Enhance Contrast", "saturated=0.35");
//run("Threshold...");
run("8-bit");
//run("Threshold...");
setAutoThreshold("Li dark");
//setThreshold(7, 255);
run("Convert to Mask");
run("Fill Holes");
run("Analyze Particles...", "size=100-Infinity exclude display display exclude add");

run("Select All");
run("Duplicate...", "title=cell_mask2");
run("Select All");
setBackgroundColor(255, 255, 255);
run("Clear", "slice");
/////

selectWindow("cell_mask1");

roiManager("Select", 0);
run("Interpolate", "interval=20 smooth");
run("Interpolate", "interval=20 smooth");
run("Clear Outside");
setForegroundColor(0, 0, 0);
fill();
roiManager("reset");

run("Select All");
run("Duplicate...", "title=cell_mask");

selectWindow("cell_mask1");
run("Analyze Particles...", "size=5-Infinity display clear add");
roiManager("Select", 0);
run("Clear", "slice");
setForegroundColor(0, 0, 0);
run("Line Width...", "line=5");
run("Draw", "slice");
run("Select All");
run("Duplicate...", "title=cell_mask_for_curved_edges");
selectWindow("cell_mask1");
roiManager("Select", 0);
run("Convex Hull");
setForegroundColor(255, 255, 255);
run("Line Width...", "line=40");
run("Draw", "slice");
roiManager("Deselect");
roiManager("Delete");
run("Select All");
imageCalculator("XOR create", "cell_mask_for_curved_edges","cell_mask1");
selectWindow("cell_mask1");
close();
selectWindow("cell_mask_for_curved_edges");
close();
selectWindow("Result of cell_mask_for_curved_edges");
////

run("Gaussian Blur...", "sigma=3");
setAutoThreshold("IsoData dark");
run("Convert to Mask");
run("Invert");
run("Analyze Particles...", "size=0.2-Infinity circularity=0.00-0.5 display clear add");
selectWindow("cell_mask2");
setForegroundColor(0, 0, 0);

numROIs = roiManager("count");
roiManager("Show All without labels");
run("Line Width...", "line=1");
roiManager("Fill");


/////

roiManager("reset");
selectWindow("cell_mask");
run("Analyze Particles...", "size=5-Infinity display clear add");
selectWindow("cell");
run("Duplicate...", "title=pYAP duplicate channels=1");
//selectWindow("cell");
//run("Duplicate...", "title=tYAP duplicate channels=1");
selectWindow("cell");
run("Duplicate...", "title=vinc duplicate channels=2");
roiManager("Select", 0);
run("Interpolate", "interval=30 smooth");
setBackgroundColor(0, 0, 0);
run("Clear Outside");
			//	run("Enlarge...", "enlarge=-100 pixel");
			//	run("Clear", "slice");
run("Select All");
//run("Brightness/Contrast...");
resetMinAndMax();
run("Enhance Contrast", "saturated=0.35");

run("Duplicate...", "title=vinc2");
run("Subtract Background...", "rolling=15 sliding");
//run("Gaussian Blur...", "sigma=1");
run("Enhance Local Contrast (CLAHE)", "blocksize=200 histogram=256 maximum=2 mask=*None* fast_(less_accurate)");
//run("Exp");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");
//run("Bandpass Filter...", "filter_large=500 filter_small=5 suppress=None tolerance=5 autoscale saturate");
run("LoG 3D", "sigmax=3.5 sigmay=3.5 displaykernel=0 volume=1");
selectWindow("LoG of vinc2");
run("16-bit");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");
setAutoThreshold("Li"); // Threshold
run("Convert to Mask");
//run("Invert");
rename("detected_adhesions");
run("Duplicate...", "title=detected_adhesions_with_edges");
selectWindow("vinc2");
close();

////////


selectWindow("cell_mask");
run("Select None");
run("Create Selection");
run("Enlarge...", "enlarge=-1.5");
selectWindow("detected_adhesions");
run("Restore Selection");
setBackgroundColor(255,255,255);
run("Clear", "slice");
roiManager("reset");
run("Clear Results");
selectWindow("detected_adhesions");
run("Select None");
run("Analyze Particles...", "size=0.03-Infinity clear add");
roiManager("Show None");

numROIs = roiManager("count");

for(i=0; i<numROIs;i++) // loop through ROIs
	{ 
	print(i);
	selectWindow("detected_adhesions");
	//roiManager("Show None");
	roiManager("Select", i);
	roiManager("Measure");
	adhesion_area = getResult("Area",0);
		
	if (adhesion_area>30) {
		adhesion_width = getResult("Width",0);
		selection_width = adhesion_width/2;
		adhesion_angle = getResult("FeretAngle",0);
		rotation_angle = 90 - adhesion_angle;
		adhesion_x = getResult("XM",0);
		adhesion_y = getResult("YM",0);
		run("Clear Results");	
		
		run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
		selectWindow("detected_adhesions");
		roiManager("Select", i);
		run("Fit Ellipse");
		run("Make Band...", "band=25"); 
		selectWindow("cell_mask2");
		run("Restore Selection");
		run("Duplicate...", "title=edge_temp");
		run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
		run("Select None");
		run("Create Selection");
		run("Measure");

		mean_itensity = getResult("Mean",0);
		if  (mean_itensity == 0) {
			    print("outside the curve area");
				selectWindow("edge_temp");
				close();
				selectWindow("detected_adhesions");	
				run("Select None");
				roiManager("select", i);
				run("Clear", "slice");
	    	}else{
	    		edge_angle = getResult("FeretAngle",0);
	    		print("adhesion angle=",adhesion_angle," edge angle=",edge_angle);
	    		if (abs(abs(adhesion_angle) - abs(edge_angle))>30) {
					print("no");
					selectWindow("edge_temp");
					close();
				selectWindow("detected_adhesions");	
				run("Select None");
				roiManager("select", i);
				run("Clear", "slice");
					} else{
			print("yes");
			selectWindow("detected_adhesions");	
			run("Select All");
			run("Duplicate...", "title=temp2");
			roiManager("select", i);
			setBackgroundColor(255, 255, 255);
			run("Clear Outside");
			run("Select All");
			run("Watershed");
			roiManager("select", i);
			run("Copy");
			selectWindow("detected_adhesions");	
			roiManager("select", i);
			run("Clear", "slice");
			run("Paste");
			selectWindow("temp2");
			close();
	    	selectWindow("edge_temp");
			close();
			run("Clear Results");
	    	}
	    	}
	}else {
			selectWindow("detected_adhesions");	
			run("Select None");
			roiManager("select", i);
			run("Clear", "slice");
		run("Clear Results");
	}
	}
	
///pYAP
	selectWindow("detected_adhesions");
	run("Select All");
	roiManager("reset");
	run("Set Measurements...", "area mean min center perimeter fit shape integrated display redirect=pYAP decimal=3");
	run("Analyze Particles...", "size=0.03-Infinity circularity=0.00-1 display add");
	roiManager("Show None");

	saveAs("Results", res_dir_pYAP+"adhesions_"+name_no_ext+".csv");
	run("Clear Results");
	roiManager("reset");

	
	selectWindow("detected_adhesions_with_edges");
	saveAs("Tiff", res_dir_pYAP+"orig_adhs_"+name_no_ext+".tif");
	close();	

	selectWindow("detected_adhesions");
	saveAs("Tiff", res_dir_pYAP+"adhs_"+name_no_ext+".tif");
	close();
	 run("Close All");	}
 run("Close All");	}  //////////////////////
	
 run("Close All");

////////

	
 run("Close All");	}



 				

