//////////////////////////////////////////////////////////////////////////////////////////////////////
// segmentation of mixed cultures using NLS-BFP as a marker for the genotype
// followed by quantification of cleavage body intensities (GFP live cell imaging)
/////////////////////////////////////////////////////////////////////////////////////////////////////////
	// stick to naming conventions as indicated to keep compatibility with downstream R script
	// run in chunks as indicated

////////////////////////////////////////////
//// part 1 ////////////////////////////////
////////////////////////////////////////////

//// selects cell shapes based on thresholding on transmitted light image
	// --> select image stack
	// choose transmitted light image at low range so that white rim shows up (for me, usually 2-3)
		  
			Dialog.create("Set variable");
		  	Dialog.addNumber("DIC channel:", 1);
		  	Dialog.show();
		  	channel = Dialog.getNumber();
			run("Duplicate...", "duplicate channels=channel");
		//run("Brightness/Contrast...");
		run("Z Project...", "projection=[Min Intensity]");
		run("Bandpass Filter...", "filter_large=40 filter_small=3 suppress=None tolerance=5 autoscale saturate");
		run("Median...", "radius=2");
		run("Threshold...");
		
	// threshold manually so that cell content is selected and clearly separated from surroundings
		
		/////////////////////////////////////////////
		//// end of part 1 //////////////////////////
		/////////////////////////////////////////////	
					
////////////////////////////////////////////
//// part 2 ////////////////////////////////
////////////////////////////////////////////	
						
// on final image, select cell bodies via analyze particles (area around thirty, circulartiy around 0.5); if necessary, use results table to detrermine best settings
	
	run("Duplicate...", " ");
	run("Analyze Particles...", "size=7.00-60.00 circularity=0.10-1.00 show=Masks display exclude clear add in_situ");
	
// after running: check selected ROIs and delete any obvious junk manually (e.g., joint cells; debris)

		/////////////////////////////////////////////
		//// end of part 2 //////////////////////////
		/////////////////////////////////////////////	
		
////////////////////////////////////////////
//// part 3 ////////////////////////////////
////////////////////////////////////////////	

// renaming ROIs to cell1 - cellXY
		
		roiManager("UseNames", "false");
		for (i = 0; i < roiManager("count") ; i++) {
		    roiManager("Select", i);
		    roiManager("Rename", "cell"+i+1);
		    Roi.setGroup(4);
		}

		/////////////////////////////////////////////
		//// end of part 3 //////////////////////////
		/////////////////////////////////////////////	
		

////////////////////////////////////////////
//// part 4 ////////////////////////////////
////////////////////////////////////////////

// selects cells that carry NLS-BFP as a marker; here we use a z projection across the entire stack
	// --> select image stack /
	
			Dialog.create("Set variable");
		  	Dialog.addNumber("BFP channel:", 3);
		  	Dialog.show();
		  	channel = Dialog.getNumber();
			run("Duplicate...", "duplicate channels=channel");
			run("Z Project...", "projection=[Average Intensity]");
			run("Duplicate...", " ");
			run("Threshold...");
			
		// set threshold manually to select NLS-BFP-marked nuclei
			
		/////////////////////////////////////////////
		//// end of part 4 //////////////////////////
		/////////////////////////////////////////////	
		

////////////////////////////////////////////
//// part 5 ////////////////////////////////
////////////////////////////////////////////	
		
		// on final image, select nuclei via analyze particles (circularity around 0.8); use results table to adjust, if necessary
		run("Analyze Particles...", "size=1-9.00 circularity=0.50-1.00 show=Masks display exclude add in_situ");

		/////////////////////////////////////////////
		//// end of part 5 //////////////////////////
		/////////////////////////////////////////////	
		

////////////////////////////////////////////
//// part 6 ////////////////////////////////
////////////////////////////////////////////	


// Overlapping ROIs select and pairwise renaming
/// this will work on a set of ROIs where cells are labelled cell1 to cellXY (in ascending order without gaps!) and ROIs for nuclei marked by <nls-BFP have already been added
/// nuclei ROIs can be in random order and with random names


// Matches overlapping cell / NLS-BFP ROIs
	/// assigns cells without NLS-BFP signal to group == 4
	/// assigns cells with NLS-BFP signal to group == 2  
	/// this will work on a set of ROIs where cells are labelled cell1 to cellXY (in ascending order without gaps!) and ROIs for nuclei have already been added
	/// NLS-BFP ROIs can be in random order and with random names
	/// nuclei without cells and cells without nuclei are fine --> will be removed
	/// cells with two nuclei are fine
	
			
			cellArray = newArray();  
							for (i = 0; i < roiManager("Count"); i++){
								roiManager("Select", i);
								if (Roi.getGroup()==4) {
									cellArray = Array.concat(cellArray, i);
								} 
							}
							cellNumber = cellArray.length;
							print("there are ", cellNumber, " cells");
	for (i = 0; i < cellNumber; i++){ 
		for (j = cellNumber; j < roiManager("Count"); j++){
		   if (i != j){
		   	   	roiManager("Select", newArray(i,j));
		   		roiManager("AND");
		    
				if (selectionType()>-1) {
					print (i, " and ", j," do intersect");
					roiManager("Deselect");
					roiManager("Select", j);
					roiManager("Rename", "nuc"+i+1);
					Roi.setGroup(1); /// all nuclei that were assigned to cells
					roiManager("Deselect");
					roiManager("Select", i);
					Roi.setGroup(2); /// all cells that were assigned to nuclei
		   		} 
		   }
		}
	}

		
		/////////////////////////////////////////////
		//// end of part 6 //////////////////////////
		/////////////////////////////////////////////	
		

////////////////////////////////////////////
//// part 7 ////////////////////////////////
////////////////////////////////////////////	

// quantifies GFP signal using ROIs
	// keep cell ROIs, DELETE all others; for documentation, save roiset
	// select image stack

			Dialog.create("Set variable");
		  	Dialog.addNumber("GFP channel:", 2);
		  	Dialog.show();
		  	channel = Dialog.getNumber();
			run("Duplicate...", "duplicate channels=channel");
			run("Z Project...", "projection=[Max Intensity]");
			run("Set Measurements...", "area mean min shape integrated display redirect=None decimal=5");
			run("Clear Results");
		// select all ROIs,  measure on MAX intensity projection
				// selects all ROIs
					count = roiManager("count");
					array = newArray(count);
					  for (i=0; i<array.length; i++) {
					      array[i] = i;
					  }
					roiManager("select", array);	
		roiManager("Measure");
		
		// save results


