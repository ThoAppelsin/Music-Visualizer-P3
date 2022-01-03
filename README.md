# Music Visualizer on Processing 3
This project is still very much in development.
A sketch of a changelog is available at the very end of this readme.

A music visualizer written for Processing 3 which currently visualizes the primary audio input (which is probably your computer's microphone unless you make some adjustments).
You should somehow feed a copy of the audio output of your computer back into your computer as an input (aka. "stereo mix" on Windows), and then make it the primary input, so that the visualizer reacts to the music you are playing.

## An overview of the building blocks
The flocking behavior of the visualizer particles (the movements you see without any music playing in the background) is based on [@ozdenizdolu](https://github.com/ozdenizdolu)'s old work. See [this video](https://www.youtube.com/watch?v=mhjuuHl6qHM) for more on the flocking algorithm.

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
- [ ] Overlapping the frequency ranges to not miss beats that span across two adjacent ranges
- [x] Changing non-relative thresholds for initiating and relieving stress with something relative, so that the sensing of stress is not affected by overall loudness of music
- [ ] Developing a guess for the fundamental BPM of the music and somehow incorporating that into future detections (this one can be a little problematic as the music changes or the BPM of the music changes)
- [ ] ...

Visualization might be improved by:
- [ ] Visualizing beats in different frequency ranges differently (e.g. some swirling effect on mid-range and vibrating effect on treble beats)
- [ ] Visualizing the sustained stress
- [ ] ... (possiblities are endless here)


## Changelog

##### 2022-01-03
- Introduced a whacky normalization (using logit-normal distribution) that redistributes the values in 0-1 such that if a value coincides with the running average, it is mapped to 0.5.  The mapping curve is smooth, i.e. its derivative is continuous.  See [this graph](https://www.desmos.com/calculator/yjsz5uig7o) for a taste; `m` controls the running average at that time, `s` controls the shape of the curve (`Parameters.Normalizing.stdev` in code), and then the values on `x` are mapped to values on `y`.  This is used to normalize the energy measurements and to eliminate the effects of playback volume on the visualization.
- Introduced a 0-mean 1-stdev standardizer that redistributes values that average approximately at 0. It just subtracts the running average from the value and then divides it with the running standard deviation (which probably isn't a very accurate approximation of the real standard deviation).  This is used to standardize the calculated differences between subsequent un-normalized energy measurements.
