/***
* Name: CustomableCityScope
* Author: Arnaud Grignard
* Description: This is a custom template to create any species on top of the orginal CityScope Main model.
* Tags: Tag1, Tag2, TagN
***/



model CityScope_Custom_Template

import "CityScope_main.gaml"
import "UserClient.gaml"

/* Insert your model definition here */

global{
	int nbBlockCarUser <- 0;
	int nbBlockCar <- 0;
	int numPod <-15;
	int currentHour update: (time / #hour) mod 24;
	float step <- 1 #mn;
	//list<BlockCar> freeBlockCars <- nil;
	
	int distanceStart <- 1000;
	int distanceEnd <- 1000;
	init{
	}
	
	action  customInit{
		list<building> tallestBuildingList <- world.building sort_by(each.depth);
		int k <- 4;
		
		loop i from: 0 to: k 
		{
			last(tallestBuildingList).colorChange <- true;
			remove last(tallestBuildingList) from: tallestBuildingList;
		}
		create Pod number: numPod;		
  }
}

species Pod skills:[moving3D]{
	
	building initialLocation;
	building destinationLocation;
	building targetLocation;
	point initialPoint;
	point destinationPoint;
	point targetPoint;
	float speed <- 1.2 #km/#h;
	bool goToInitial <- false;
	
	
	init{
		list<building> buildLst;
		buildLst <-(world.building where (each.colorChange = true));
		initialLocation <- buildLst closest_to(self);
		destinationLocation <- any(world.building where (each.colorChange = true and each != initialLocation));
		
		point buildingPoint <- any_point_in(initialLocation);
		initialPoint <- buildingPoint;
		point myLocation<-{buildingPoint.x, buildingPoint.y, initialLocation.depth};
		location <- myLocation;
		
		
		buildingPoint <- any_point_in(destinationLocation);
		destinationPoint<-buildingPoint;
		
		targetPoint <- destinationPoint;
		targetLocation <- destinationLocation;
		goToInitial <- true;
	}
	
	aspect realistic{
//		draw sphere(10) color:rgb(0, 51, 153);
		draw obj_file("../includes/pod_glider_30.obj") color:rgb(0,51,153) rotate: 90 + heading;
	}

	reflex move{
		do goto target:targetPoint;
		if (location = targetPoint){
			if(location.z = 0){
				targetPoint<-{targetPoint.x+1, targetPoint.y+1, targetLocation.depth};
				speed <- 0.01#km/#h;
			}
			else{
				speed <- 1.2 #km/#h ;
				if(goToInitial = false){
					targetPoint <- destinationPoint;
					targetLocation <- destinationLocation;
					goToInitial <- true;
				}
				else{
					targetPoint <- initialPoint;
					targetLocation <- initialLocation;
					goToInitial <- false;
				}
			}		
		}
			

	}
}


experiment customizedExperiment type:gui parent:CityScopeMain{
	output{
		display CityScopeAndCustomSpecies type:opengl parent:CityScopeVirtual{
			//species BlockCar aspect:base;
			//species BlockCarUser aspect:realistic;
			species Pod aspect:realistic;
				
		}		
	}
}

