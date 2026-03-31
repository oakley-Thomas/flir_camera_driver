# Docker Usage

This repository includes a ROS 2 Humble Docker image that builds and installs the
`flir_camera_driver` workspace into `/opt/flir_ws`.

## Contents

- `../Dockerfile`: builds the image on top of `ros:humble-ros-base-jammy`
- `ros_entrypoint.sh`: sources both `/opt/ros/humble` and the built workspace overlay

## Build

From the repository root:

```bash
docker build -t flir-camera-driver:humble .
```

## Quick Verification

Check that the ROS overlay is sourced:

```bash
docker run --rm flir-camera-driver:humble bash -lc "printenv ROS_DISTRO && test -f /opt/flir_ws/install/setup.bash && echo overlay_ok"
```

List the installed driver packages:

```bash
docker run --rm flir-camera-driver:humble ros2 pkg list | grep -E "^(flir_camera_msgs|flir_camera_description|spinnaker_camera_driver|spinnaker_synchronized_camera_driver)$"
```

Inspect the main launch file:

```bash
docker run --rm flir-camera-driver:humble ros2 launch spinnaker_camera_driver driver_node.launch.py --show-args
```

List the driver executables:

```bash
docker run --rm flir-camera-driver:humble ros2 pkg executables spinnaker_camera_driver
```

## Run Interactively

```bash
docker run --rm -it flir-camera-driver:humble
```

The default entrypoint starts a shell with the ROS 2 Humble environment and the
workspace overlay already sourced.

## Using Real Cameras

The image build verifies that the driver compiles and the ROS packages are present,
but camera access requires additional runtime configuration.

For USB cameras, you will typically need to pass through the USB bus:

```bash
docker run --rm -it \
  --device=/dev/bus/usb \
  flir-camera-driver:humble
```

For GigE cameras, `--network host` is often the simplest option:

```bash
docker run --rm -it \
  --network host \
  flir-camera-driver:humble
```

Depending on your host setup, you may also need:

- udev permissions configured on the host
- additional device mappings
- privileged mode for troubleshooting only

If the Spinnaker SDK is not already installed on the host, this workspace downloads
the SDK during `docker build` so the image build needs outbound network access.
