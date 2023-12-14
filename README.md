# Indoor-gps

## Pedometer (dev/pedometer)
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
* `pedometer/mainStepCounter.m`: Test step counter algorithm.

## Indoor GPS (dev/indoor_gps)
Indoor GPS (IPS), which is also known as Pedestrian dead reckoning (PDR), can be described as
an GPS for the indoor environments. It collects the data from the internal sensors of smartphone to
estimate the position and orientation of the device.

### Aim
The objective of this project is to build a simple IPS using the data from the sensors (accelerometer, gyroscope and magnetometer) and determine the location (distance and orientation) in real-time. In particular, in this project, the IPS is coded as an application on smart phone (Android), uses the signal from the build-in IMU and shows walking distance and device’s heading as people walk.

Due to the complex behaviours of human (walking, running) and various phone positions and orientation, this project has to deal with a wide range of patterns and challenges. For example, the device orientation may change during straight walking. In the scope of this project, the phone’s heading is assumed to coincide with human’s heading and there is no major noise source near the
phone.

### Algorithm
Refer to `dev/indoor_gps/README.md`
