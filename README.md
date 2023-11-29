# Indoor-gps

## Pedometer
Pedometer is a device which automatically detects human walking steps. It plays an important
role in monitoring the human’s daily routine and behavior recognition.

### Aim
The objective of this project is to build a simple pedometer using the data of an accelerometer
and count the number of walking step in real-time. For simplification, in this project, the step
counter is coded as an application on smart phone (Android or iOS), uses the signal from the
build-in accelerometer and shows the steps as people walk.

Although, due to complex behaviours of human (walking,running) and various phone positions,
the real pedometer has to deal with different patterns and challenges. In the scope of this project,
the phone is put inside a pant’s pocket and it will track only the walking activity.

### Algorithm 
* `pedometer/tools/preprocessData.m`: Analyse sample data.
* `pedometer/tools/mainFFT.m`: Apply Fast Fourier transform to sample data.
* `pedometer/tools/mainStepCounter.m`: Test step counter algorithm.
