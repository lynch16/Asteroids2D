extends RigidBody2D


# On ready, pick from 1 of 5 different asteroid options, apply a random rotation and velocity.
# Calculate mass/density based on asteroid option
# Break up asteroid based on sum of force applied - could come from weapons, ship or other bodies. At min size, dequeue
# This class should instead be OrbitingBody?
