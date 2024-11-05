# Peer-Review for Programming Exercise 2 #

# Solution Assessment #

## Peer-reviewer Information

* *name:* Darroll Saddi
* *email:* dwsaddi@ucdavis.edu

___

## Solution Assessment ##

### Stage 1 ###

- [x] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
The position lock camera was implemented as specified.

___
### Stage 2 ###

- [ ] Perfect
- [x] Great
- [ ] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
The player is able to move inside the box, with the box properly auto-scrolling and moving with the camera, and the player being pushed by the box when touching it. However, the implementation could have been made better by moving the player with respect to the box rather than independent of it, as found in Scramble, ©1981 Konami. Also, the box size does not change when the camera zooms in or out, meaning if the player zoomed all the way out, they would only be able to move in a tiny area on the screen.

___
### Stage 3 ###

- [ ] Perfect
- [ ] Great
- [x] Good
- [ ] Satisfactory
- [ ] Unsatisfactory

___
#### Justification ##### 
The camera follows the player nicely with lerping. However, if the player moves outside the camera FOV the camera snaps to position to keep the player in view. This doesn't look great when the camera is moving at hyperspeed.
```py
var distance_to_target = cpos.distance_to(tpos)
if distance_to_target > leash_distance:
    if target_velocity.length() > follow_speed:
        camera_speed *= target.HYPER_SPEED
    else:
        camera_speed += (distance_to_target - leash_distance) * 0.4  
```
The snapping is a result of this multiplication of camera_speed by the target's HYPER_SPEED. In general, this is a hacky solution to following the "maximum allowed distance between the vessel and the center of the camera" for the leash_distance, and results in the unpleasant snapping when going beyond the leash_distance. An alternative solution is to simply keep the player within a circular leash_distance radius around the camera similar to the push_box.

___
### Stage 4 ###

- [ ] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [x] Unsatisfactory

___
#### Justification ##### 
Although the camera moves to be in front of the player's motion, it does not smoothly move to these positions due to a misunderstanding of how lerp works, and a mishandling of camera_speed during the state of leading in front of the player. The camera does return to the player when they stop moving in a smooth manner. An effort to understand camera_speed and lerp may assist in fixing these issues.

___
### Stage 5 ###

- [ ] Perfect
- [ ] Great
- [ ] Good
- [ ] Satisfactory
- [x] Unsatisfactory

___
#### Justification ##### 
Stage 5 was not implemented correctly. It appears that this is particularly due to a miscalculation of where the player is within the bounds of the inner and outer squares, and therefore whether the player is within or outside the inner square. This results in unexpected output such as:
1. Moving downwards inside the inner square moves the camera down, when it shouldn't.
2. Moving upwards outside the inner square does not move camera up, when it should.

The push_box behavior when touching the edges of the outer square seems to be working though.
___
# Code Style #

#### Style Guide Infractions ####
1. [Prefer two empty lines between functions, private variable declarations, and class definition](https://github.com/ensemble-ai/exercise-2-camera-control-Salgado-alex/blob/f5d4cef947d4ea91454c6d64cfa4329b041a27e2/Obscura/scripts/camera_controllers/lerp_smoothing_target_focus.gd#L1C1-L14C1) throughout code

#### Style Guide Exemplars ####
1. [Occasional comments](https://github.com/ensemble-ai/exercise-2-camera-control-Salgado-alex/blob/f5d4cef947d4ea91454c6d64cfa4329b041a27e2/Obscura/scripts/camera_controllers/lerp_smoothing_target_focus.gd#L33)

# Best Practices #

#### Best Practices Infractions ####
* Did not remove unnecessary/unused cameras from World tree (additional PushBoxCamera nodes)
* Better commenting practices, like commenting the purpose of [large blocks](https://github.com/ensemble-ai/exercise-2-camera-control-Salgado-alex/blob/f5d4cef947d4ea91454c6d64cfa4329b041a27e2/Obscura/scripts/camera_controllers/lerp_smoothing_target_focus.gd#L39C1-L44C63) of code are preferred.

#### Best Practices Exemplars ####
* Semi-frequent commits are a good practice.