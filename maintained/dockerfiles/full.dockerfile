FROM ros:noetic

# Makking sure our ROS node has ports to connect trough.
# These are the ports specified in `rospy.init_node()` in hardware.py
EXPOSE 45100
EXPOSE 45101

RUN apt-get update -y && apt-get install -y python3 python3-pip git && rm -rf /var/lib/apt/lists/*

# Install dependencies.

# These are package requirements for the dependencies.
# You should add to these if you add python packages that require c libraries to be installed
RUN apt-get update -y && apt-get install ffmpeg libsm6 libxext6 ros-noetic-opencv-apps -y && rm -rf /var/lib/apt/lists/*

# The python3 interpreter is already being shilled by ros:noetic, so no need for a venv.
COPY ./requirements.txt /requirements.txt
RUN python3 -m pip install -r /requirements.txt && rm /requirements.txt

# This cd's into a new `catkin_ws` directory anyone starting the shell will end up in.
WORKDIR /root/catkin_ws

# This copies the local catkin_ws into the docker container, and then runs catkin_make on it.
COPY ./catkin_ws .
RUN bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

# Set up the envoirement to actually run the code
COPY ./scripts/entrypoint.bash ./entrypoint.bash
COPY ./scripts/setup.bash ./setup.bash
COPY ./scripts/convert_line_endings.py ./convert_line_endings.py
RUN python3 ./convert_line_endings.py "*.bash" "**/*.py"
RUN chmod -R u+x /root/catkin_ws/

# Uncomment these lines and comment out the last line for debugging
# RUN echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc
# RUN echo 'source /root/catkin_ws/devel/setup.bash' >> /root/.bashrc
# RUN echo 'source /root/catkin_ws/setup.bash' >> /root/.bashrc

ENTRYPOINT ["./entrypoint.bash"]
