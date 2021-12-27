# Music Visualizer on Processing 3
This project is still very much in development.

A music visualizer written for Processing 3 which currently visualizes the primary audio input (which is probably your computer's microphone unless you make some adjustments).
You should somehow feed a copy of the audio output of your computer back into your computer as an audio input, and then make that the primary input, so that the visualizer reacts to the music you are playing.

## An overview of the building blocks
The flocking behavior of the visualizer particles (the movements you see without any music playing in the background) is based on [@ozdenizdolu](https://github.com/ozdenizdolu)'s old work.

First a 250/255 multiplicative, then a 1 point subtractive dimming filter is applied between each frame to achieve a trailing effect.

To make the particles react to the beats:
- For 5 disjoint (← might be a point to improve) frequency ranges:
  - *Stressful* moments in the music are *sensed* by observing the *power*, and their change over time.
  - Some [hysteresis](https://en.wikipedia.org/wiki/Hysteresis#Electronic_circuits) is added to this sensing of stress (i.e. there is a gap between the conditions that initiate and relieve stress, during which the state of stressfulness is preserved) to prevent it from alternating rapidly.
  - An *action potential* is fired up momentarily whenever the stress is initiated (i.e. on the stress pos-edge).
- These 5 analyses are combined into an overall action potential, which is fired up when the following two conditions hold:
  - There currently is an action potential from one of the frequency ranges.
  - There is no lingering stress from the action potential that raised the last overall action potential.
- Each overall action potential randomizes the velocities (directions and speeds) of each particle, disabling their flocking behavior for 10 frames. Particles in larger flocks are given a greater random speed.

## Ideas
The beat detection might be improved by:
1) Overlapping the frequency ranges to not miss beats that span across two adjacent ranges
2) Changing non-relative thresholds for initiating and relieving stress with something relative, so that the sensing of stress is not affected by overall loudness of music
3) Developing a guess for the fundamental BPM of the music and somehow incorporating that into future detections (this one can be a little problematic as the music changes or the BPM of the music changes)
4) ...

Visualization might be improved by:
1) Visualizing beats in different frequency ranges differently (e.g. some swirling effect on mid-range and vibrating effect on treble beats)
2) (Possiblities are endless here)
3) ...
