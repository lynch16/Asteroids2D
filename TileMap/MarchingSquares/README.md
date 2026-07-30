1. Canvas needs to be part of the persisted resource
2. Process
	1. Load Canvas X by Y size
	1b. Pick a tile size (stored with resource)
	2a. Manual Editing
		1. Left click to increase value (gradually or all at once)
		2. Right click to decreate value (gradually or all at once)
		3. For each value, represent as a dot drawn on screen, scaled to the tile size proportionately. 


Current Process:
1. Editor creates the points based on the viewport and fixed tile size (bitmap)
2. Create collisions with MarchingSquaresGenerate.generate_collision_shapes
3. Create sub-bitmaps based on what points exist within the polygons (This is to chucnk)
4. Genreate ArrayMesh based on viewport, sub-bitmaps and a texture. **Need to save this in resource**
5. Create a MeshInstance2D and assign the mesh and texture to it
6. Store the resulting mesh, corner dictionary and collisions in a resource. 
7. Calculate where center would be based on the center of all polygon points.
