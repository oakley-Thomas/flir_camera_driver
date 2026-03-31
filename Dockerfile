FROM ros:humble-ros-base-jammy

SHELL ["/bin/bash", "-lc"]

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_WS=/opt/flir_ws

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    dpkg \
    git \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

RUN if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then rosdep init; fi && \
    rosdep update --rosdistro humble

WORKDIR ${ROS_WS}

COPY . ${ROS_WS}/src/flir_camera_driver

RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    apt-get update && \
    rosdep install \
      --from-paths src \
      --ignore-src \
      --rosdistro ${ROS_DISTRO} \
      --as-root apt:false \
      -y && \
    rm -rf /var/lib/apt/lists/*

RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    colcon build \
      --merge-install \
      --cmake-args -DCMAKE_BUILD_TYPE=Release

COPY docker/ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
