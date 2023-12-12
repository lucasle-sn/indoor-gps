3 tests are conducted seperately:
1. Travelled distance is estimated using integration technique (distance is proportional to step counter and height). 
2. Heading algorithm is fused with absolute and relative heading (Discrete Kalman filter).
3. Travelled distance is written to file over time. This data is reused later on for map plot (file `data/imu/sample.csv`).
