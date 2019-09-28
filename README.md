# machine-learning

## Install OpenCV

| Environment Variable | Value |
| -------------------- | ----- |
| ENABLE_GPU           | false |
| OPENCV_VERSION       | 4.1.0 |

```shell
curl -L https://raw.githubusercontent.com/ahkui/machine-learning/master/install/opencv.sh -o install-opencv.sh
chmod +x install-opencv.sh
./install-opencv.sh
```

## Install Openpose

| Environment Variable     | Value                                                   |
| ------------------------ | ------------------------------------------------------- |
| ENABLE_GPU               | false                                                   |
| OPENPOSE_MODELS_PROVIDER | <http://posefs1.perception.cs.cmu.edu/OpenPose/models/> |

```shell
curl -L https://raw.githubusercontent.com/ahkui/machine-learning/master/install/openpose.sh -o install-openpose.sh
chmod +x install-openpose.sh
./install-openpose.sh
```
