3 tests are conducted seperately:
1. `mainStepCounter.m`: Travelled distance is estimated using integration technique (distance is proportional to step counter and height). 
```
Distance = StepCount ∗ StepLength
```
2. `mainHeading.m`: Heading algorithm is to fuse with absolute and relative heading using Discrete Kalman filter.
3. `mainMapping.m`: Travelled distance is written to file over time. This data is reused later on for map plot (file `data/imu/sample.csv`).
