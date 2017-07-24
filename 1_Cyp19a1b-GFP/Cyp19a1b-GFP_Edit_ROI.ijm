//	Cyp19a1b-GFP_Edit_ROI v 1.2 - 06/2016 - Cyril TURIÈS - any comment/improvement is welcome (mailto: cyril.turies@ineris.fr)
// Image processing pipeline:
// 	- Select image (.czi, .zvi or .tif)
// 	- The macro opens automatically Image + ROI.zip file if existing or ask to create one
// 	- Apply user defined threshold
// 	- Updated ROI.zip is saved to the image directory
// 06/2016 extension autoselection with filename

requires("1.47r");
v = "v1.2";

// Select image
	path = File.openDialog("Select a File");
	dir = File.getParent(path);
	name = File.getName(path);
	prefix = File.nameWithoutExtension();
	ext = substring(name, lastIndexOf(name, "."), lengthOf(name));
	print(path);
	print(dir);
	print(name);
	print(prefix);
	print(ext);
	print(dir+prefix);
	print(dir+"\\"+prefix);
	
	
// Open image
	if (ext == ".zvi"||ext == ".czi") {
		run("Bio-Formats Importer", "open=["+ path +"]" + " autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
	} else {
		open(path);
	}
	getLocationAndSize(x, y, width, height);
	
// DialogBox to set options
	Dialog.create("Analyze Cyp19b-GFP "+v);
	Dialog.addMessage("Process Options:");
	Dialog.addNumber("Threshold:", 290);
//	Dialog.addChoice("File type", newArray(".czi",".zvi",".tif"), ".czi");
	Dialog.addCheckbox("Measure new ROI after edition", false);
	Dialog.addCheckbox("Close after edition", false);
	Dialog.setLocation(x+width,y);
	Dialog.show();

	thr = Dialog.getNumber();
//	ext = Dialog.getChoice();
	mes = Dialog.getCheckbox();
	cls = Dialog.getCheckbox();

// Reset ROI Manager
	c = roiManager("count");
	if (c != 0) {
//		showMessageWithCancel("Warning!","Content from ROI manager will be erased");
		roiManager("reset");
	}

// Open ROI if existing
	roiManager("Show None");
	if (File.exists(dir+"\\"+prefix+".zip")) {
		open(dir+"\\"+prefix+".zip");
		roiManager("select", 0);
		def = 0;
// Prompt to create ROI if not existing
	} else {
		choice = getBoolean("No ROI.zip for:\n"+prefix+"\nCreate one?");
		if (choice == 1) {
			def = 1;
		}
	}
// Apply defined threshold
	showMessageWithCancel("Action","Apply threshold");
	resetThreshold;
	getMinAndMax(min, max);
	setThreshold(thr, max, "over/under");
	if (def == 1) {
		run("Analyze Particles...", "size=2-Infinity exclude include add");
		n = roiManager("count");
		if (n>1) {
			roiManager("deselect");
			roiManager("XOR");
			roiManager("add");
			for (j=1; j<n+1; j++) {
				roiManager("select", 0);
				roiManager("delete");
			}
			roiManager("select", 0);
		}
	}
// Check or edit ROI and update ROI.zip
	setTool("freehand");
	waitForUser("ROI selection","Select or Edit ROI\nbefore you click on -OK-\n\nHold:\n   ALT = Substract\n   SHIFT = Add");
	if (selectionType() == -1) waitForUser("WARNING","No selection detected\n \n=> Select ROI then click on -OK-");
	if (selectionType() != -1) {
		roiManager("Update");
		roiManager("Save", dir+"\\"+prefix+".zip");
		showMessage("ROI Edition:", prefix+".zip\nsuccessfully updated");
	}
// Measure new ROI
	if (mes == 1) {
		run("Set Measurements...", "area mean standard min integrated limit display redirect=None decimal=0");
		roiManager("deselect");
		roiManager("select", 0);
		if (nResults > 0) {
			choice = getBoolean("All content from previous Result table will be erased\n \nContinue?");
			if (choice == 1) {
				roiManager("Measure");
				setResult("Label", nResults-1, name);
			}
		} else {
			roiManager("Measure");
			setResult("Label", nResults-1, name);
		}

	}
	
	if (cls == 1) {
		roiManager("reset");
		close();
	}

	
