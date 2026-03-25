@tool
extends Node
class_name MSMeshes

static var VERTEX_ARRAYS: Array[PackedVector2Array] = [
	[],
	[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0,  1)],
	[Vector2( 1,  0), Vector2( 0,  1), Vector2( 1,  1)],
	[Vector2(-1,  0), Vector2(-1,  1), Vector2( 1,  1), Vector2( 1,  0)],
	[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0, -1)],
	[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0, -1), Vector2(-1,  0), Vector2(-1, 1), Vector2(0, 1)],
	[Vector2( 0, -1), Vector2( 0,  1), Vector2( 1,  1), Vector2( 1, -1)],
	[Vector2( 1,  1), Vector2( 1, -1), Vector2( 0, -1), Vector2(-1,  0), Vector2(-1, 1)],
	[Vector2( 0, -1), Vector2(-1, -1), Vector2(-1,  0)],
	[Vector2( 0, -1), Vector2(-1, -1), Vector2(-1,  1), Vector2( 0,  1)],
	[Vector2( 1,  0), Vector2( 0, -1), Vector2(-1, -1), Vector2(-1,  0), Vector2( 0, 1), Vector2(1, 1)],
	[Vector2( 1,  0), Vector2( 0, -1), Vector2(-1, -1), Vector2(-1,  1), Vector2( 1, 1)],
	[Vector2(-1, -1), Vector2(-1,  0), Vector2( 1,  0), Vector2( 1, -1)],
	[Vector2( 1,  0), Vector2( 1, -1), Vector2(-1, -1), Vector2(-1,  1), Vector2( 0, 1)],
	[Vector2( 1,  1), Vector2( 1, -1), Vector2(-1, -1), Vector2(-1,  0), Vector2( 0, 1)],
	[Vector2(-1, -1), Vector2(-1,  1), Vector2( 1,  1), Vector2( 1, -1)],
]

static var NEXT_VERTEX_ARRAYS: Array[PackedVector2Array] = [
	[],
	[Vector2.DOWN, Vector2.LEFT],
	[Vector2.RIGHT, Vector2.DOWN],
	[Vector2.RIGHT, Vector2.LEFT],
	[Vector2.RIGHT, Vector2.UP],
	[Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP],
	[Vector2.DOWN, Vector2.UP],
	[Vector2.LEFT, Vector2.UP],
	[Vector2.LEFT, Vector2.UP],
	[Vector2.DOWN, Vector2.UP],
	[Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP],
	[Vector2.RIGHT, Vector2.UP],
	[Vector2.RIGHT, Vector2.LEFT],
	[Vector2.RIGHT, Vector2.DOWN],
	[Vector2.DOWN, Vector2.LEFT],
	[Vector2.ZERO]
]
		 #Null = END
		 #Only SW == One down, one left
		 #Only SE == One Down, one right
		 #SW + SE == One left, one right (NO DOWN AS FULL)
		 #Only NE == One Up, One right
		# NE + SW == One Up, One right, one down, one left
		# NE+SE = One Up, one down, (NO RIGHT AS FULL)
		# NE, SE, SW = One UP, one left (NO DOWN or RIGHT AS FULL)
		# Only NW = One UP, ONe left
		# NW + SW = One Up, One down (NO LEFT AS FULL)
		# NW + SW = One Up, One RIght, One Down, One left
		# NW, SW, SE = One Up, One Right (NO DOWN OR LEFT AS FULL)
		# NW + NE = One Right, One Left
		# NW, NE, SW = One Right, One Down (NO UP OR LEFT AS FULL)
		# NW, NE, SE = One Left, One Down (NO UP OR RIGHT AS FULL)
		# ALL FULL = SKIP in same direction

static var INDEX_ARRAYS: Array[PackedInt32Array] = [
	[],
	[0, 1, 2],
	[0, 1, 2],
	[0, 1, 2, 0, 2, 3],
	[0, 1, 2],
	[0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 5],
	[0, 1, 2, 0, 2, 3],
	[0, 1, 2, 0, 2, 3, 0, 3, 4],
	[0, 1, 2],
	[0, 1, 2, 0, 2, 3],
	[0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 5],
	[0, 1, 2, 0, 2, 3, 0, 3, 4],
	[0, 1, 2, 0, 2, 3],
	[0, 1, 2, 0, 2, 3, 0, 3, 4],
	[0, 1, 2, 0, 2, 3, 0, 3, 4],
	[0, 1, 2, 0, 2, 3],
]
