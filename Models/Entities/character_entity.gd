class_name CharacterEntity
extends CharacterBody2D

@export var min_velocity := 10:
	set(val):
		min_velocity = max(0, min(val, max_velocity if max_velocity != null else INF)) # Ensures min doesn't exceed max
@export var max_velocity := 100:
	set(val):
		max_velocity = max(min_velocity if min_velocity != null else 0, val) # Ensures max doesn't go below min
